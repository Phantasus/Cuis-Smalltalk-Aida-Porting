Object subclass: #HTTPConnection
	instanceVariableNames: 'stream loop server task other'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!

!HTTPConnection methodsFor: 'serving'!
close
	self isOpen ifFalse: [^nil].
	self stream notNil ifTrue: 
		[self stream close. 
		stream := nil].
	self server notNil ifTrue: 
		[self server removeConnection: self.
		self server: nil].
	self task notNil ifTrue:
		[self task nilInstvars.
		self task: nil].
	self closeHandler ifNotNil:
		[self closeHandler 
			closedConnection: self].
	self loop notNil ifTrue: 
		[ | process | 
		process := loop. loop := nil. 
		process terminate]. "beware, this can terminate currenttly executing process!!"! !

!HTTPConnection methodsFor: 'serving'!
closeHandler
	"a #closedConnection: aHTTPConnection will be send to this object after connection close"
	^self 
		otherAt: #CloseHandler
		ifAbsent: [nil]! !

!HTTPConnection methodsFor: 'serving'!
closeHandler: anObject
	"a #closedConnection: aHTTPConnection will be send to this object after connection close"
	^self 
		otherAt: #CloseHandler
		put: anObject! !

!HTTPConnection methodsFor: 'serving'!
getAndDispatchMessages
	self stream anyDataReady  "wait for data and if anything read, proceed"
		ifTrue:
			[self task: (SwazooTask newOn: self).
			self readRequestFor: self task.
			(self isAllowedRequest: self task request) ifFalse: [self close]. "filtering out malicious reqs"
			self produceResponseFor: self task.
			self task request wantsConnectionClose ifTrue: [self close].
			(self task request isHttp10 and: [self task request isKeepAlive not] ) ifTrue: [self close].
			self mustUpgrade ifTrue: [self upgradeConnection] ] "like to WebSocket"
		ifFalse: 
			[self keepAliveTimeout ifTrue: [^self close].
			(Delay forMilliseconds: 100) wait. "to finish sending, if any"
			self close].! !

!HTTPConnection methodsFor: 'serving' stamp: 'janko 8/26/2013 16:34'!
interact
	"longer description is below method"
	| interactionBlock |
	interactionBlock := 
		[[	[ [true] whileTrue: 
				[self getAndDispatchMessages.
				Processor yield] 
			]
			on: Error
			do: [:ex | "just ignore"] ]
		ifCurtailed: [ 
			(Delay forMilliseconds: 50) wait. "to finish sending, if any"
			self close] ].
	self server isMultiThreading 
		ifTrue: 
			[self loop: interactionBlock newProcess.
			self loop
				priority: Processor userBackgroundPriority;
				resume]
		ifFalse: [interactionBlock value].
	^self

"I represent a specifc connection with an HTTP client (a browser, probably) over which will come an HTTP request.  Here, I fork the handling of the request so that the current thread (which is most likely the HTTP server main loop) can carry on with the next request.  This means that more than one request may being handled in the image at a time, and that means that the application developer must worry about thread safety - e.g the problem of a given business object being updated by more than one HTTP request thread.
For a GemStone implementation of Swazoo, one may want only one request is handled at a time, multi-threadedness being handled by having multiple gems.  This is a nice option because the application developer does not have to worry about thread safety in this case - GemStone handles the hard stuff.
*And* the thing called a loop that was in this method was no such thing.  In all circumstances, >>getAndDispatchMessages handles exactly one requst and then closes the socket!! (very non-HTTP1.1).  Anyway, for now I'm just going to make that explicit.  This needs to be re-visited to support HTTP 1.1."! !

!HTTPConnection methodsFor: 'serving'!
produceResponseFor: aSwazooTask 
	aSwazooTask request isNil ifTrue: [^nil].
	aSwazooTask response: (self server answerTo: aSwazooTask request).
	aSwazooTask request ensureFullRead. "in case if defered parsing not done in HTTPost"
	aSwazooTask request wantsConnectionClose 
		ifTrue: [aSwazooTask response informConnectionClose]
		ifFalse: [aSwazooTask request isKeepAlive 
			ifTrue: [aSwazooTask response informConnectionKeepAlive] ].
	aSwazooTask response isStreamed 
		ifFalse: "streamed ones did that by themselves"
			[self nextPutResponse: aSwazooTask response toRequest: aSwazooTask request]
		ifTrue: [aSwazooTask response waitClose]. "to be sure all is sent"
	aSwazooTask request isGet ifFalse: [self close]  "to avoid strange 200 bad requests after two consecutive POSTs, but it is really a hack and original reason must be found!!" "jan11: do we still need this?"! !

!HTTPConnection methodsFor: 'serving' stamp: 'janko 10/30/2012 11:13'!
readRequestFor: aSwazooTask 
	| request |
	SpExceptionContext for: 
		[request := HTTPRequest readFrom: self stream.
		request uri port: self server port.
		(request httpVersion last = 1 
			and: [(request headers includesFieldOfClass: HTTPHostField) not]) 
				ifTrue: [aSwazooTask response: HTTPResponse badRequest].
		[request peer: self stream socket remoteAddress]
			on: Error do: [:ex | "do nothing for now"].
		request
			ip: self stream socket localAddress;
			setTimestamp.
		aSwazooTask request: request]
	on: SpError, HTTPException
	do: [:ex | 
		aSwazooTask response: HTTPResponse badRequest.
		[self nextPutError: aSwazooTask response]
			on: Error
			do: [:ex2 | "ignore" ].
		self close].! !


!HTTPConnection methodsFor: 'initialize-release'!
initOther
	other := Dictionary new! !


!HTTPConnection methodsFor: 'filtering'!
isAllowedRequest: aHTTPRequest
	 "Peer IP is not on blacklist or is on whitelist"
	(self server isPeerIPAlwaysAllowed: self) ifTrue: [^true]. "from this IPs is kind of 'root' access"
	^(self isUrlBlacklisted: aHTTPRequest) not! !

!HTTPConnection methodsFor: 'filtering'!
isUrlBlacklisted: aHTTPRequest
	 "Absolute Url pattern"
	| srv fullUrl |
	srv := SwazooServer singleton.
	srv urlBlacklist isEmpty ifTrue: [^false].  "in case there is no blacklist"
	fullUrl := aHTTPRequest uri protocol, '://',      "warning, without port!! "
		aHTTPRequest host, aHTTPRequest uri asString. 
	^srv urlBlacklist contains: [:ipString | ipString match: fullUrl]! !


!HTTPConnection methodsFor: 'testing'!
isHTTPConnection
	^true! !

!HTTPConnection methodsFor: 'testing' stamp: 'janko 7/26/2008 13:20'!
isOpen
	"not yet closed"
	^self stream notNil! !

!HTTPConnection methodsFor: 'testing'!
isWebSocketConnection
	^false! !

!HTTPConnection methodsFor: 'testing' stamp: 'janko 7/26/2008 13:21'!
keepAliveTimeout
	| seconds |
	self task isNil ifTrue: [^false].
	self task request isKeepAlive ifFalse: [^false].
	seconds := self task request keepAlive notNil
		ifTrue: [self task request keepAlive asInteger - 10 "to be sure"]
		ifFalse: [20]. "probably enough?"
	^(SpTimestamp now asSeconds - self task request timestamp asSeconds) >= seconds! !


!HTTPConnection methodsFor: 'private' stamp: ' 14/4/07 23:09'!
loop
	^loop! !

!HTTPConnection methodsFor: 'private' stamp: ' 14/4/07 23:09'!
loop: aProcess
	loop := aProcess! !

!HTTPConnection methodsFor: 'private' stamp: ' 14/4/07 23:09'!
server
	^server! !

!HTTPConnection methodsFor: 'private' stamp: ' 14/4/07 23:09'!
server: aServer 
	server := aServer! !

!HTTPConnection methodsFor: 'private' stamp: ' 14/4/07 23:09'!
socket
	^self stream socket! !

!HTTPConnection methodsFor: 'private' stamp: ' 14/4/07 23:09'!
stream
	^stream! !

!HTTPConnection methodsFor: 'private' stamp: ' 14/4/07 23:09'!
stream: aSwazooStream 
	stream := aSwazooStream! !

!HTTPConnection methodsFor: 'private' stamp: ' 14/8/07 21:49'!
task
	"request/response pair, current or last one (until next request)"
	^task! !

!HTTPConnection methodsFor: 'private' stamp: ' 14/8/07 21:49'!
task: aSwazooTask
	"request/response pair, current or last one (until next request)"
	task := aSwazooTask! !


!HTTPConnection methodsFor: 'upgrading'!
mustUpgrade
	^self otherAt: #Upgrade ifAbsent: [false]! !

!HTTPConnection methodsFor: 'upgrading'!
upgradeConnection
	"from HTTP to some other protocol, like WebSocket"
	self mustUpgradeToWebSocket 
		ifTrue: [^self upgradeToWebSocket]! !

!HTTPConnection methodsFor: 'upgrading'!
upgradeConnectionAfterResponse
	"wait to finish sending response, then upgrade"
	self otherAt: #Upgrade put: true! !


!HTTPConnection methodsFor: 'websocket'!
mustUpgradeToWebSocket
	^self otherAt: #UpgradeToWebSocket ifAbsent: [false]! !

!HTTPConnection methodsFor: 'websocket'!
upgradeToWebSocket
	"Upgrade HTTP connection to a WebSocket one"
	self become: (self as: WebSocketConnection).! !

!HTTPConnection methodsFor: 'websocket'!
upgradeToWebSocketAfterResponse
	"let we first finish sending response, then upgrade"
	self otherAt: #UpgradeToWebSocket put: true.
	self upgradeConnectionAfterResponse! !

!HTTPConnection methodsFor: 'websocket'!
webSocket
	"resource to hande incoming WebSocket messages. Only one WebSocket per connection!!"
	^self otherAt: #SwazooWebSocket ifAbsent: [nil]! !

!HTTPConnection methodsFor: 'websocket'!
webSocket: aWebSocektResource
	"only one WebSocket per connection!!"
	self otherAt: #SwazooWebSocket put: aWebSocektResource! !


!HTTPConnection methodsFor: 'serving-responses' stamp: ' 14/8/07 21:49'!
nextPutError: aResponse 
	aResponse informConnectionClose.
	aResponse writeTo: self stream.
	self stream closeResponse.! !

!HTTPConnection methodsFor: 'serving-responses' stamp: 'mivsek 12/31/2007 16:04'!
nextPutResponse: aMessage toRequest: aRequest 
	aRequest isHead 
		ifTrue: [aMessage writeHeaderTo: self stream]
		ifFalse: [aMessage writeTo: self stream].
	self stream closeResponse.! !


!HTTPConnection methodsFor: 'private-other'!
other
	^other! !

!HTTPConnection methodsFor: 'private-other'!
otherAt: aSymbol
	"other values"
	^self otherAt: aSymbol ifAbsent: [nil]! !

!HTTPConnection methodsFor: 'private-other'!
otherAt: aSymbol ifAbsent: aBlock
	"other values"
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!HTTPConnection methodsFor: 'private-other'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!HTTPConnection methodsFor: 'private-other'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPConnection class
	instanceVariableNames: ''!

!HTTPConnection class methodsFor: 'instance creation' stamp: ' 14/4/07 23:09'!
socket: aSocket 
	^self new stream: aSocket stream! !


Object subclass: #HTTPServer
	instanceVariableNames: 'ip port connections sites socket loop isMultiThreading'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!

!HTTPServer methodsFor: 'private'!
acceptConnection
	| clientConnection |
	clientConnection := SpExceptionContext 
		for: [HTTPConnection socket: self socket accept]
		on: SpError
		do: [:ex | 
			Transcript cr; cr; show: '*** HTTPServer accept error: ' , ex errorString, 
				', restarting on ', self ip, ':', self port printString; cr; cr. 
			(Delay forMilliseconds: 1000) wait. "to avoid endless loop"
			[(Delay forSeconds: 1) wait. 
			self restart]   "in case of broken socket"
				fork.
			^self].
	(self isAllowedConnection: clientConnection) "IP is not on blacklist or is on whitelist"
		ifTrue: 
			[self addConnection: clientConnection.
			clientConnection interact]
		ifFalse: [clientConnection close].! !

!HTTPServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
addConnection: aConnection 
	self connections add: aConnection.
	aConnection server: self! !

!HTTPServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
connections
	connections isNil ifTrue: [self initConnections].
	^connections! !

!HTTPServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
loop
	^loop! !

!HTTPServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
loop: aProcess
	loop := aProcess! !

!HTTPServer methodsFor: 'private'!
printString
	^'aHTTPServer
	ip: ', self ip printString, '
	port: ', self port printString, ' 
	serving: ', self isServing printString! !

!HTTPServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
removeConnection: aConnection 
	self connections remove: aConnection ifAbsent: [nil]! !

!HTTPServer methodsFor: 'private'!
server
	"a SwazooServer on which we are running"
	^SwazooServer singleton! !

!HTTPServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
sites
	sites isNil ifTrue: [self initSites].
	^sites! !

!HTTPServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
socket
	^socket! !

!HTTPServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
socket: aSocket
	socket := aSocket! !

!HTTPServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
socketClass
	"^a Class
I use SwazooSocket to wrap the actual socket.  SwazooSocket does some of the byte translation work for me."

	^SwazooSocket! !


!HTTPServer methodsFor: 'sites' stamp: ' 14/4/07 23:09'!
addSite: aSite
	(self sites includesResource: aSite) ifFalse: [^self sites addResource: aSite]! !

!HTTPServer methodsFor: 'sites' stamp: ' 14/4/07 23:09'!
hasNoSites
	^self sites hasNoResources! !

!HTTPServer methodsFor: 'sites'!
removeSite: aSite 
	aSite parent: nil.
	^self sites removeResource: aSite! !


!HTTPServer methodsFor: 'serving' stamp: 'jm 11/29/2010 15:47'!
answerTo: aRequest 
	| response |
	response := URIResolution resolveRequest: aRequest startingAt: self sites.
	^response isNil
		ifTrue: [HTTPResponse notFound]
		ifFalse: [response]! !


!HTTPServer methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
initConnections
	connections := OrderedCollection new.! !

!HTTPServer methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
initSites
	sites := ServerRootComposite new! !

!HTTPServer methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
initialize
	self initConnections.
	self initSites! !

!HTTPServer methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
ip
	^ip! !

!HTTPServer methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
ip: anIPString 
	ip := anIPString! !

!HTTPServer methodsFor: 'private-initialize' stamp: 'mivsek 11/15/2007 13:50'!
ipCorrected
	"in case of '*' always return '0.0.0.0'"
	^self ip = '*' 
		ifTrue: ['0.0.0.0'] 
		ifFalse: [self ip]! !

!HTTPServer methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
port
	^port! !

!HTTPServer methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
port: aNumber
	port := aNumber! !


!HTTPServer methodsFor: 'filtering'!
isAllowedConnection: aHTTPConnection
	 "Peer IP is not on blacklist or is on whitelist"
	(self isPeerIPAlwaysAllowed: aHTTPConnection) ifTrue: [^true]. "from this IPs is kind of 'root' access"
	^(self isPeerIPWhitelisted: aHTTPConnection) and:
		[(self isPeerIPBlacklisted: aHTTPConnection) not]! !

!HTTPServer methodsFor: 'filtering'!
isPeerIPAlwaysAllowed: aHTTPConnection
	 "Peer IP is on always allowed list (a collection of IP patterns like '222.123.*' "
	| peerIP |
	self server ipAllowedList isEmpty ifTrue: [^false].  "in case there is noone on allowed list"
	peerIP := [aHTTPConnection socket remoteAddress]
		on: Error
		do: [:ex | ^false]. "mailformed requests are blacklisted by default"
	^self server ipAllowedList contains: [:ipString | ipString match: peerIP]! !

!HTTPServer methodsFor: 'filtering'!
isPeerIPBlacklisted: aHTTPConnection
	 "Peer IP is on blacklist (a collection of IP patterns like '222.123.*' "
	| peerIP |
	self server ipBlacklist isEmpty ifTrue: [^false].  "in case there is no blacklist"
	peerIP := [aHTTPConnection socket remoteAddress] 
		on: Error
		do: [:ex | ^true]. "mailformed requests are blacklisted by default"
	^self server ipBlacklist contains: [:ipString | ipString match: peerIP]! !

!HTTPServer methodsFor: 'filtering'!
isPeerIPWhitelisted: aHTTPConnection
	 "Peer IP is on whitelist (a collection of IP patterns like '222.123.*' "
	| peerIP |
	self server ipWhitelist isEmpty ifTrue: [^true].  "in case there is no whitelist"
	peerIP := [aHTTPConnection socket remoteAddress]
		on: Error
		do: [:ex | ^false]. "mailformed requests are blacklisted by default"
	^(self server ipWhitelist contains: [:ipString | ipString match: peerIP]) not! !


!HTTPServer methodsFor: 'multithreading' stamp: ' 14/4/07 23:09'!
isMultiThreading
	"^a Boolean
I return true if each inbound HTTP connection will be handled in its own thread.  See the senders of this message to see where that is important.  Note that the default mode is mult-threaded because this is how Swazoo has worked so far.  This is tricky for the application programmer, though, as they must ensure that they work in a thread safe way (e.g. avoid the many threads updating the same object).  For those deploying to GemStone, you wil find things much easier if you do *not* run multithreaded, but rather run many gems each with a single-threaded Swazoo instance (and your app logic) in each.  Also in GemStone, run the main loop in the foreground, c.f. >>mainLoopInForeground"

	isMultiThreading isNil ifTrue: [self setMultiThreading].
	^isMultiThreading! !

!HTTPServer methodsFor: 'multithreading' stamp: ' 14/4/07 23:09'!
setMultiThreading
	"^self
I record that this HTTP server is to operate in a multi-threaded mode.  c.f. isMultiThreading"

	isMultiThreading := true.
	^self! !

!HTTPServer methodsFor: 'multithreading' stamp: ' 14/4/07 23:09'!
setSingleThreading
	"^self
I record that this HTTP server is to operate in a single-threaded mode.  c.f. isMultiThreading"

	isMultiThreading := false.
	^self! !


!HTTPServer methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
isServing
	^self loop notNil! !


!HTTPServer methodsFor: 'start/stop' stamp: 'mivsek 11/15/2007 13:51'!
restart
	"usefull after image startup, when socket is probably not valid anymore"
	self stop.
	self start.! !

!HTTPServer methodsFor: 'start/stop'!
start
	self loop isNil ifTrue: 
		[self socket: 
			(SwazooSocket serverOnIP: self ipCorrected port: self port).
		self socket listenFor: 128.
		self loop: 
			[ [self acceptConnection] repeat]  
				newProcess.
		self loop
			priority: Processor userBackgroundPriority;
			resume
		]! !

!HTTPServer methodsFor: 'start/stop' stamp: ' 14/4/07 23:09'!
stop
	self loop isNil 
		ifFalse: 
			[self connections copy do: [:each | each close].
			self loop terminate.
			self loop: nil.
			self socket close.
			self socket: nil]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPServer class
	instanceVariableNames: ''!

!HTTPServer class methodsFor: 'intialize-release' stamp: ' 14/4/07 23:09'!
initialize
	SpEnvironment addImageShutdownTask: [self shutDown] for: self! !

!HTTPServer class methodsFor: 'intialize-release' stamp: ' 14/4/07 23:09'!
shutDown 
	"HTTPServer shutDown"
	self allInstances do: [:each | each stop].
	SpEnvironment removeShutdownActionFor: self.! !


!HTTPServer class methodsFor: 'instance creation' stamp: ' 14/4/07 23:09'!
new
	^super new initialize! !


Object subclass: #HTTPString
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!
!HTTPString commentStamp: '<historical>' prior: 0!
This class contains some utility methods that were previously implemented as extentions to system classes.  This is really a stop-gap until, perhaps, the SwazooStream yeilds HTTPStrings.

!


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPString class
	instanceVariableNames: ''!

!HTTPString class methodsFor: 'decoding' stamp: ' 14/4/07 23:09'!
decodedHTTPFrom: aCharacterArray 
	"Code taken from the swazoo specific extention to the CharacterArray class"

	| targetStream sourceStream |
	targetStream := WriteStream on: aCharacterArray class new.
	sourceStream := ReadStream on: aCharacterArray.
	[sourceStream atEnd] whileFalse: 
			[| char |
			char := sourceStream next.
			char = $% 
				ifTrue: 
					[targetStream 
						nextPut: (SpEnvironment integerFromString: '16r' , (sourceStream next: 2)) 
								asCharacter]
				ifFalse: 
					[char == $+ 
						ifTrue: [targetStream nextPut: Character space]
						ifFalse: [targetStream nextPut: char]]].
	^targetStream contents! !

!HTTPString class methodsFor: 'decoding' stamp: 'mivsek 6/13/2007 14:06'!
encodedHTTPFrom: aCharacterArray 
	"Code taken from the swazoo specific extention to the CharacterArray class"

	| targetStream |
	targetStream := WriteStream on: aCharacterArray class new.
	aCharacterArray do: 
			[:char | 
			(self isHTTPReservedCharacter: char) 
				ifTrue: 
					[targetStream nextPut: $%.
					targetStream nextPutAll:
						(char asInteger printPaddedWith: $0 to: 2 base: 16)
"					char asInteger 
						printOn: targetStream
						paddedWith: $0
						to: 2
						base: 16" ]
				ifFalse: [targetStream nextPut: char]].
	^targetStream contents! !

!HTTPString class methodsFor: 'decoding' stamp: ' 14/4/07 23:09'!
isHTTPReservedCharacter: aCharacter 
	"Code taken from the swazoo specific extention to the Character class"

	^(aCharacter isAlphaNumeric or: ['-_.!!~*''()' includes: aCharacter]) not! !

!HTTPString class methodsFor: 'decoding' stamp: ' 14/4/07 23:09'!
stringFromBytes: aByteArray 
	"^a String
In GemStone ['Hello, World' asByteArray asString] returns the string 'aByteArray' !!
This is the boring long way of getting a string from a ByteArray - but it does work
in GemStone."

	"HTTPString stringFromBytes: ('Hello, World' asByteArray)"

	| targetStream |
	targetStream := WriteStream on: String new.
	aByteArray do: [:aByte | targetStream nextPut: aByte asCharacter].
	^targetStream contents! !

!HTTPString class methodsFor: 'decoding' stamp: ' 14/4/07 23:09'!
trimBlanksFrom: aString 
	"^a String
I return a copy of aString with all leading and trailing blanks removed."

	| first last |
	first := 1.
	last := aString size.
	[last > 0 and: [(aString at: last) isSeparator]] 
		whileTrue: [last := last - 1].
	^last == 0 
		ifTrue: [String new]
		ifFalse: 
			[[first < last and: [(aString at: first) isSeparator]] 
				whileTrue: [first := first + 1].
			aString copyFrom: first to: last]! !


!HTTPString class methodsFor: 'instance creation' stamp: ' 14/4/07 23:09'!
newRandomString: anInteger 
	| numbersThroughAlphas targetStream char random |
	numbersThroughAlphas := (48 to: 122) collect: [:each | each asCharacter].
	targetStream := WriteStream on: (String new: anInteger).
	random := Random new.
	[targetStream contents size < anInteger] whileTrue: 
			[char := numbersThroughAlphas 
						at: (random next * (numbersThroughAlphas size - 1)) rounded + 1.
			char isAlphaNumeric ifTrue: [targetStream nextPut: char]].
	^targetStream contents! !


!HTTPString class methodsFor: 'tokens' stamp: ' 14/4/07 23:09'!
subCollectionsFrom: aCollection delimitedBy: anObject 
	"^an OrderedCollection
I return the ordered collection of sub-collections from aCollection, delimited
by anObject."

	"HTTPString subCollectionsFrom: 'aaa/bbb/' delimitedBy: $/"

	| subCollections sourceStream |
	subCollections := OrderedCollection new.
	sourceStream := ReadStream on: aCollection.
	[sourceStream atEnd] 
		whileFalse: [subCollections add: (sourceStream upTo: anObject)].
	(aCollection isEmpty 
		or: [(sourceStream
				skip: -1;
				next) == anObject]) 
			ifTrue: [subCollections add: aCollection class new].
	^subCollections! !


CompositeResource subclass: #ServerRootComposite
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!

!ServerRootComposite methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
helpResolve: aResolution 
	^aResolution resolveServerRoot: self! !


ReadWriteStream subclass: #SwazooBuffer
	instanceVariableNames: 'type resize'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!
!SwazooBuffer commentStamp: 'janko 7/26/2008 18:23' prior: 0!
SwazooBuffer is used for efficient buffering of receiving or sending data to TCP socket. Efficiency is achieved with reusing of stream content array instead of initializing it everytime buffer is emptied, as was in previous Swazoo versions. 

SwazooBuffer is a subclass of ReadWriteStream, with additional #clear to empty buffer.

!


!SwazooBuffer methodsFor: 'testing' stamp: 'janko 7/26/2008 18:22'!
atEnd
	^super atEnd "for now"! !

!SwazooBuffer methodsFor: 'testing' stamp: 'janko 7/26/2008 18:22'!
isBinary
	^collection class == ByteArray! !

!SwazooBuffer methodsFor: 'testing' stamp: 'janko 7/26/2008 18:21'!
isFull
	"buffer full or even more"
	^position >= self class defaultBufferSize! !

!SwazooBuffer methodsFor: 'testing' stamp: 'janko 8/3/2008 16:57'!
isRead
	^type = #read! !

!SwazooBuffer methodsFor: 'testing' stamp: 'janko 8/3/2008 16:57'!
isWrite
	^type = #write! !


!SwazooBuffer methodsFor: 'writing-chunked' stamp: ' 14/8/07 21:49'!
closeChunkTo: aSocket
	"a zero sized chunk determine and end of chunked data and also response"
	"pack all together to send one TCP packet ony"
	| chunk written |
	chunk := ByteString new: 5.
	chunk at: 1 put: $0 .
	chunk at: 2 put: Character cr. "first crlf ends 0 length line "
	chunk at: 3 put: Character lf.
	chunk at: 4 put: Character cr. "second crlf ends whole response"
	chunk at: 5 put: Character lf.
	written := aSocket writeFrom: chunk asByteArray startingAt: 1 for: chunk size.
	written = chunk size ifFalse: [self error: 'socket write error'].! !

!SwazooBuffer methodsFor: 'writing-chunked' stamp: 'mivsek 8/22/2007 20:22'!
flushChunkTo: aSocket
	"a buffer will be sent as a chunk, with hex size in first line then crlf, buffer, then crlf"
	"send a complete chunk in one piece, don't partition TCP sending in too many packets!!"
	| length |
	 self size > 16rFFFF ifTrue: [self error: 'chunk too long!!']. "preamble has no room for bigger"
	length := self size printStringRadix: 16.
	SpEnvironment isSqueak ifTrue: [length := length copyFrom: 4 to: length size]. "trim 16r"
	1 to: length size do: [:inx | collection at: inx put: (length at: inx) asInteger].
	 (length size+1) to: 4 do: [:inx | collection at: inx put: $ asInteger]. "add spaces"
	collection at: 5 put: Character cr asInteger.
	collection at: 6 put: Character lf asInteger.
	"add finishing crlf to buffer"
	self nextPut: Character cr asInteger.
	self nextPut: Character lf asInteger.
	self flushTo: aSocket chunked: true. "flush all at once"! !


!SwazooBuffer methodsFor: 'accessing' stamp: 'janko 7/26/2008 18:21'!
contents
	"Answer a copy of the receiver's collection, skipping preamble."
	readLimit := readLimit max: position.
	^collection copyFrom: self class preambleSize+1 to: readLimit! !

!SwazooBuffer methodsFor: 'accessing' stamp: 'janko 7/26/2008 18:16'!
readContents
	^(position = 0 and: [readLimit = self class defaultBufferSize]) "whole buffer?"
		ifTrue: [collection] "avoid copying for performance"
		ifFalse: [collection copyFrom: position+1 to: readLimit]! !

!SwazooBuffer methodsFor: 'accessing' stamp: 'janko 7/26/2008 18:21'!
size
	^position - self class preambleSize! !


!SwazooBuffer methodsFor: 'mime boundary' stamp: 'janko 7/26/2008 18:16'!
copyBufferTo: anIndex
	"from current position to desired index"
	| start |
	start := position+1.
	position := anIndex.
	^collection copyFrom: start to: anIndex.! !

!SwazooBuffer methodsFor: 'mime boundary' stamp: 'janko 7/26/2008 18:17'!
indexOfBoundary: aBoundaryBytes
	"index of boundary start, beeing full boundary or part at the end of buffer. 0 if not found"
	| inx innerInx firstInx |
	inx := position+1.
	[inx <= readLimit] whileTrue:
		[innerInx := 1. firstInx := inx.
		[(aBoundaryBytes at: innerInx) = (collection at: inx)] whileTrue:
			[innerInx = aBoundaryBytes size ifTrue: [^firstInx]. "full boundary found"
			inx = readLimit ifTrue: [^firstInx].  "partial boundary at the edge of buffer found"
			inx := inx + 1. innerInx := innerInx + 1].
		inx := inx + 1].
	^0! !

!SwazooBuffer methodsFor: 'mime boundary' stamp: 'janko 7/26/2008 18:17'!
signsOfBoundary: aBoundaryBytes
	"detect as fast as possible if any if not all MIME part boundary is present in buffer contents"
	"return number of bundary bytes detected, 0 = no boundary"
	| first index |
	first := aBoundaryBytes first.
	"fast test"
	((self position+1 to: readLimit) contains: [:inx | (collection at: inx) = first]) ifFalse: [^0].
	"full or partial boundary on the edge of buffer test"
	index := self indexOfBoundary: aBoundaryBytes. "index of full, or partial boundary at the edge"
	index = 0 ifTrue: [^0]. "no boundary found"
	readLimit-index >= aBoundaryBytes size ifTrue: [^aBoundaryBytes size]. "full boundary detected"
	^readLimit-index+1  "partial boundary at the end of buffer"! !

!SwazooBuffer methodsFor: 'mime boundary' stamp: 'janko 7/26/2008 18:17'!
startsWith: aPartialBoundaryBytes
	"is remaining part of MIME part boundary at the start of buffer?"
	"VW specific!! "
	1 to: aPartialBoundaryBytes size do: [:inx |
		(collection at: position + inx) = (aPartialBoundaryBytes at: inx) ifFalse: [^false] ].
	^true! !


!SwazooBuffer methodsFor: 'writing' stamp: ' 14/8/07 21:49'!
flushTo: aSocket
	"actually write to the tcp socket as direclty as possible"
	self flushTo: aSocket chunked: false.
! !


!SwazooBuffer methodsFor: 'private-sending' stamp: 'janko 8/3/2008 17:00'!
flushTo: aSocket chunked: chunkedBoolean
	"actually write to the tcp socket as direclty as possible 
	(directly from stream's instvar collection)"
	| remaining start written |
	remaining := chunkedBoolean 
		ifTrue: [position]  "ensure to send preamble too"
		ifFalse: [position - self class preambleSize]. "skip preamble"
	[remaining > 0] whileTrue: 
		[start := position - remaining + 1.
		written := aSocket 
			writeFrom: collection startingAt: start for: (position - start + 1).
		remaining := remaining - written].
	self writeClear.
	self shouldResize ifTrue: [self resizeBuffer; resizeNil]. "enlarge or shrink buffer if requested"! !


!SwazooBuffer methodsFor: 'initialize-release' stamp: 'jm 2/8/2009 23:33'!
initDefaultBuffer
	"Squeak specific - writeLimit"
	| size |
	size := self isWrite
		ifTrue: [self class defaultBufferSize + self class preambleSize + 2] "possible chunk crlf"
		ifFalse: [self class defaultBufferSize].
	collection := ByteArray new: size.
	writeLimit := size. "Squeak specific"
	self reset.
	self isWrite ifTrue: [self initPreamble].! !

!SwazooBuffer methodsFor: 'initialize-release' stamp: 'jm 2/8/2009 23:33'!
initLargeBuffer
	"Squeak specific - writeLimit"
	| size |
	size := self isWrite
		ifTrue: [self class largeBufferSize + self class preambleSize + 2] "possible chunk crlf"
		ifFalse: [self class largeBufferSize].
	collection := ByteArray new: size.
	writeLimit := size. "Squeak specific"
	self reset.
	self isWrite ifTrue: [self initPreamble].! !

!SwazooBuffer methodsFor: 'initialize-release' stamp: ' 14/8/07 21:49'!
initPreamble
	"make room for possible chunk 'preamble' = length line"
	position := self class preambleSize.
! !

!SwazooBuffer methodsFor: 'initialize-release' stamp: 'janko 7/26/2008 18:14'!
readClear
	"reset as you'd make another one, just don't replace content array"
	position := 0.
	readLimit := self class defaultBufferSize.! !

!SwazooBuffer methodsFor: 'initialize-release' stamp: 'janko 8/3/2008 16:56'!
setRead
	type := #read! !

!SwazooBuffer methodsFor: 'initialize-release' stamp: 'janko 8/3/2008 16:56'!
setWrite
	type := #write! !

!SwazooBuffer methodsFor: 'initialize-release' stamp: 'janko 7/26/2008 18:12'!
writeClear
	"reset as you'd make another one, just don't replace content array"
	self reset.
	readLimit := 0.
	self initPreamble.! !


!SwazooBuffer methodsFor: 'private-resizing' stamp: 'janko 8/3/2008 16:58'!
isEnlarged
	^collection size > self class defaultBufferSize! !

!SwazooBuffer methodsFor: 'private-resizing' stamp: 'janko 8/3/2008 16:59'!
resizeBuffer
	"actually do a buffer resize"
	self shouldEnlarge ifTrue: [^self initLargeBuffer].
	self shouldShrink ifTrue: [^self initDefaultBuffer].! !

!SwazooBuffer methodsFor: 'private-resizing' stamp: 'janko 8/3/2008 16:59'!
resizeEnlarge
	"request resizing buffer to larger size at the next fill or flush"
	resize := #enlarge! !

!SwazooBuffer methodsFor: 'private-resizing' stamp: 'janko 8/3/2008 16:59'!
resizeNil
	"nil resizing command"
	resize := nil! !

!SwazooBuffer methodsFor: 'private-resizing' stamp: 'janko 8/3/2008 16:59'!
resizeShrink
	"request shrinking buffer to default size at the next fill or flush"
	resize := #shrink! !

!SwazooBuffer methodsFor: 'private-resizing' stamp: 'janko 8/3/2008 16:59'!
shouldEnlarge
	"should be resized buffer to larger size?"
	^resize = #enlarge! !

!SwazooBuffer methodsFor: 'private-resizing' stamp: 'janko 8/3/2008 16:58'!
shouldResize
	^resize notNil! !

!SwazooBuffer methodsFor: 'private-resizing' stamp: 'janko 8/3/2008 16:58'!
shouldShrink
	"should be resized buffer to default size?"
	^resize = #shrink! !


!SwazooBuffer methodsFor: 'reading' stamp: 'janko 8/3/2008 17:01'!
refillFrom: aSocket
	"reset and read from to the tcp socket as direclty as possible 
	(directly from stream's instvar collection)"
	aSocket isNil ifTrue: [^self]. "if SwazooStream is used for tests only"
	self readClear. "just reset pointers, not a collection!! "
	self shouldResize ifTrue: [self resizeBuffer; resizeNil]. "enlarge or shrink buffer if requested"
	readLimit "nr. of actuall bytes read ":= aSocket
		readInto: collection startingAt: 1 for: collection size.
	self atEnd ifTrue: 
		[SwazooStreamNoDataError raiseSignal: 'No data available.  Socket probably closed']! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooBuffer class
	instanceVariableNames: ''!

!SwazooBuffer class methodsFor: 'defaults' stamp: 'janko 7/26/2008 18:25'!
defaultBufferSize
	"length of buffer at creation. Later not nessesary exactly this number!! "
	^8000 "about 8KB-preamble"
! !

!SwazooBuffer class methodsFor: 'defaults' stamp: 'janko 8/3/2008 19:55'!
largeBufferSize
	"size of buffer for large uploads/downloads"
	^1000000	"about 1MB"! !

!SwazooBuffer class methodsFor: 'defaults' stamp: ' 14/8/07 21:49'!
preambleSize
	"chunk size line (fixed to 4 hex characters) + crlf"
	^6! !


!SwazooBuffer class methodsFor: 'instance creation' stamp: 'jm 2/8/2009 14:47'!
newRead
	^(super on: Array new) setRead; initDefaultBuffer! !

!SwazooBuffer class methodsFor: 'instance creation' stamp: 'jm 2/8/2009 14:46'!
newWrite
	^(super on: Array new) setWrite;  initDefaultBuffer! !

!SwazooBuffer class methodsFor: 'instance creation' stamp: 'janko 7/26/2008 18:24'!
on: aByteStringOrArray
	^(self with: aByteStringOrArray) position: 0! !


Object subclass: #SwazooSocket
	instanceVariableNames: 'accessor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!

!SwazooSocket methodsFor: 'server accessing' stamp: ' 14/4/07 23:09'!
accept
	^self class accessor: self accessor acceptRetryingIfTransientErrors! !

!SwazooSocket methodsFor: 'server accessing' stamp: ' 14/4/07 23:09'!
listenFor: anInteger 
	self accessor listenBackloggingUpTo: anInteger! !


!SwazooSocket methodsFor: 'private' stamp: ' 14/4/07 23:09'!
accessor
	^accessor! !

!SwazooSocket methodsFor: 'private' stamp: ' 14/4/07 23:09'!
accessor: aSocketAccessor 
	accessor := aSocketAccessor.! !

!SwazooSocket methodsFor: 'private' stamp: ' 14/4/07 23:09'!
stream
	^SwazooStream socket: self! !


!SwazooSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
close
	self accessor close! !

!SwazooSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
localAddress
	^self accessor getSocketName hostAddressString! !

!SwazooSocket methodsFor: 'accessing' stamp: 'janko 7/26/2008 18:28'!
read: anInteger 
	^self accessor read: anInteger.! !

!SwazooSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
read: anInteger timeout: aNumberOfMilliseconds 
	^(self accessor waitForReadDataUpToMs: aNumberOfMilliseconds) 
		ifTrue: [self read: anInteger]
		ifFalse: [ByteArray new]! !

!SwazooSocket methodsFor: 'accessing' stamp: 'janko 7/26/2008 18:29'!
readInto: aByteArray startingAt: start for: length
	^self accessor readInto: aByteArray startingAt: start for: length! !

!SwazooSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
remoteAddress
	^self accessor getPeerName hostAddressString! !

!SwazooSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
write: aByteArray 
	^self accessor write: aByteArray! !

!SwazooSocket methodsFor: 'accessing' stamp: 'mivsek 7/22/2007 19:14'!
writeFrom: aByteArray startingAt: start for: length
	^self accessor writeFrom: aByteArray startingAt: start for: length! !


!SwazooSocket methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
isActive
	^self accessor isActive! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooSocket class
	instanceVariableNames: ''!

!SwazooSocket class methodsFor: 'private' stamp: ' 14/4/07 23:09'!
accessor: aSocketAccessor 
	^self new accessor: aSocketAccessor! !


!SwazooSocket class methodsFor: 'instance creation' stamp: 'janko 7/26/2008 18:30'!
connectTo: aHostString port: anInteger 
	| newSocket |
	newSocket := SpSocket newTCPSocket.
	newSocket 
		connectTo: (SpIPAddress hostName: aHostString port: anInteger).
	^self accessor: newSocket! !

!SwazooSocket class methodsFor: 'instance creation' stamp: 'janko 7/26/2008 18:29'!
connectedPair
	^SpSocket newSocketPair collect: [:each | self accessor: each]! !

!SwazooSocket class methodsFor: 'instance creation' stamp: 'janko 7/26/2008 18:30'!
serverOnIP: anIPString port: anInteger 
	| newSocket |
	newSocket := SpSocket newTCPSocket.
	newSocket
		setAddressReuse: true;
		bindSocketAddress: (SpIPAddress hostName: anIPString port: anInteger).
	^self accessor: newSocket! !


Object subclass: #SwazooStream
	instanceVariableNames: 'socket readBuffer writeBuffer chunked'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!

!SwazooStream methodsFor: 'accessing-reading' stamp: 'janko 10/30/2012 10:43'!
anyDataReady
	"wait for data and return true if any data ready. On VW somethimes happen that data 
      receipt is signaled but no data is actually received"
	self readBuffer atEnd ifFalse: [^true]. "data is there from before"
	[self fillBuffer]
		on: SpError
		do: [:ex | "do nothing"].
	^self readBuffer atEnd not! !

!SwazooStream methodsFor: 'accessing-reading' stamp: ' 14/8/07 21:49'!
atEnd
	"TCP socket data never ends!!"
	^false! !

!SwazooStream methodsFor: 'accessing-reading' stamp: ' 14/8/07 21:49'!
next
	^self nextByte asCharacter! !

!SwazooStream methodsFor: 'accessing-reading' stamp: 'janko 7/26/2008 18:51'!
next: anInteger 
	^(self nextBytes: anInteger) asString! !

!SwazooStream methodsFor: 'accessing-reading' stamp: 'janko 7/26/2008 18:36'!
nextLine
	| stream |
	stream := WriteStream on: (String new: 50).
	self writeNextLineTo: stream.
	^stream contents! !

!SwazooStream methodsFor: 'accessing-reading' stamp: 'janko 7/26/2008 18:37'!
nextUnfoldedLine
	| stream ch |
	stream := WriteStream on: (String new: 50).
	self writeNextLineTo: stream.
	stream contents isEmpty ifFalse: [
		[ch := self peek.
		ch notNil and: [ch == Character space or: [ch == Character tab]]] 
			whileTrue: [self writeNextLineTo: stream]
		].
	^stream contents! !

!SwazooStream methodsFor: 'accessing-reading' stamp: ' 14/8/07 21:49'!
peek
	| byte |
	byte := self peekByte.
	^byte notNil 
		ifTrue: [byte asCharacter] 
		ifFalse: [nil]! !

!SwazooStream methodsFor: 'accessing-reading' stamp: 'janko 7/26/2008 18:39'!
skip: anInteger
	anInteger timesRepeat: [self nextByte].! !

!SwazooStream methodsFor: 'accessing-reading' stamp: ' 14/8/07 21:49'!
upTo: aCharacterOrByte
	| targetByte ws byte |
	targetByte := aCharacterOrByte asInteger.
	ws := ByteArray new writeStream.
	[byte := self nextByte.
	byte = targetByte] whileFalse: [ws nextPut: byte].
	^ws contents! !

!SwazooStream methodsFor: 'accessing-reading' stamp: 'mivsek 8/14/2007 22:41'!
writeNextLineTo: aStream 
	aStream nextPutAll: (self upTo: Character cr asInteger) asString.
	^self peekByte = Character lf asInteger 
		ifTrue: [self nextByte]  "skip remaining linefeed"
		ifFalse: [SwazooHTTPParseError raiseSignal: 'CR without LF']! !


!SwazooStream methodsFor: 'initialize-release' stamp: 'janko 7/26/2008 18:33'!
close
	"close TCP socket and relase buffers"
	self socket close.
	self nilWriteBuffer.
	self nilReadBuffer.  "to GC buffers"! !

!SwazooStream methodsFor: 'initialize-release'!
closeResponse
	"for chunked response: close it by sending null chunk"
	"do a bit cleanup after response is sent"
	[self flush]
		on: Error
		do: [:exc | "ignore"].
	self isChunked ifTrue: 
		[self writeBuffer closeChunkTo: self socket.
		self resetChunked].
	self socket notNil "not simulation" ifTrue: [self nilWriteBuffer]. "to release memory"! !

!SwazooStream methodsFor: 'initialize-release' stamp: 'janko 5/7/2008 16:57'!
flush
	"actually write to the tcp socket and clear write buffer"
	self socket isNil ifTrue: [^nil]. "for simulations and tests"
	self isChunked
		ifTrue: [self writeBuffer flushChunkTo: self socket]
		ifFalse: [	self writeBuffer flushTo: self socket].! !

!SwazooStream methodsFor: 'initialize-release' stamp: 'janko 7/26/2008 18:34'!
initReadBuffer
	"temporary read buffer"
	readBuffer := SwazooBuffer newRead! !

!SwazooStream methodsFor: 'initialize-release' stamp: 'janko 7/26/2008 18:35'!
initWriteBuffer
	"temporary write buffer. flush it to socket ocassionaly!!"
	writeBuffer := SwazooBuffer newWrite! !

!SwazooStream methodsFor: 'initialize-release' stamp: 'janko 7/26/2008 18:37'!
nilReadBuffer
	"to release memory"
	readBuffer := nil! !

!SwazooStream methodsFor: 'initialize-release' stamp: ' 14/8/07 21:49'!
nilWriteBuffer
	"to release memory"
	writeBuffer := nil! !


!SwazooStream methodsFor: 'accessing-writing' stamp: ' 14/8/07 21:49'!
cr
	self nextPut: Character cr asInteger! !

!SwazooStream methodsFor: 'accessing-writing' stamp: 'janko 7/26/2008 18:34'!
crlf
	self cr; lf.! !

!SwazooStream methodsFor: 'accessing-writing' stamp: ' 14/8/07 21:49'!
lf
	self nextPut: Character lf asInteger! !

!SwazooStream methodsFor: 'accessing-writing'!
next: anInteger put: aCharacterOrInteger 
	"Make aCharacterOrInteger be the next anInteger number of objects accessible by the 
	receiver. Answer anObject."
	anInteger timesRepeat: [self nextPut: aCharacterOrInteger].
	^aCharacterOrInteger! !

!SwazooStream methodsFor: 'accessing-writing'!
next: anInteger putAll: aByteStringOrArray
	"Store the next anInteger elements from the given collection."
	^self next: anInteger putAll: aByteStringOrArray startingAt: 1! !

!SwazooStream methodsFor: 'accessing-writing'!
next: anInteger putAll: aByteStringOrArray startingAt: startIndex
	"Store the next anInteger elements from the given collection."
	(startIndex = 1 and: [anInteger = aByteStringOrArray size])
		ifTrue:[^self nextPutAll: aByteStringOrArray].
	^self nextPutAll: (aByteStringOrArray copyFrom: startIndex to: startIndex+anInteger-1)! !

!SwazooStream methodsFor: 'accessing-writing' stamp: 'hmm 6/6/2012 16:08'!
nextNumber: n put: v 
	"copied from PositionableStream, needed for WebSocket support"

	1 to: n do: [:i | self nextPut: (v digitAt: n+1-i)].
	^ v
! !

!SwazooStream methodsFor: 'accessing-writing' stamp: ' 14/8/07 21:49'!
nextPut: aCharacterOrInteger
	self nextPutByte: aCharacterOrInteger asInteger.
	^aCharacterOrInteger! !

!SwazooStream methodsFor: 'accessing-writing' stamp: ' 14/8/07 21:49'!
nextPutAll: aByteStringOrArray
	self nextPutBytes: aByteStringOrArray asByteArray.
	^aByteStringOrArray! !

!SwazooStream methodsFor: 'accessing-writing' stamp: 'janko 7/26/2008 18:36'!
nextPutLine: aByteStringOrArray 
	self nextPutAll: aByteStringOrArray.
	self crlf.! !

!SwazooStream methodsFor: 'accessing-writing' stamp: ' 14/8/07 21:49'!
space
	self nextPut: Character space! !


!SwazooStream methodsFor: 'private' stamp: 'janko 7/26/2008 18:34'!
fillBuffer
	self socket isNil ifTrue: [^self]. "if SwazooStream is used for tests only"
	self readBuffer refillFrom: self socket.! !

!SwazooStream methodsFor: 'private' stamp: ' 14/8/07 21:49'!
print: anObject 
	anObject printOn: self! !

!SwazooStream methodsFor: 'private' stamp: 'janko 7/26/2008 18:37'!
readBuffer
	readBuffer isNil ifTrue: [self initReadBuffer].
	^readBuffer! !

!SwazooStream methodsFor: 'private' stamp: 'janko 7/26/2008 18:38'!
readBuffer: aSwazooBuffer
	readBuffer := aSwazooBuffer! !

!SwazooStream methodsFor: 'private' stamp: 'janko 7/26/2008 18:38'!
setSocket: aSwazooSocket 
	self socket: aSwazooSocket.! !

!SwazooStream methodsFor: 'private' stamp: ' 14/8/07 21:49'!
socket
	^socket! !

!SwazooStream methodsFor: 'private' stamp: ' 14/4/07 23:09'!
socket: aSocket
	socket := aSocket! !

!SwazooStream methodsFor: 'private' stamp: ' 14/4/07 23:09'!
syncBuffer
	self readBuffer atEnd ifTrue: [self fillBuffer]! !

!SwazooStream methodsFor: 'private' stamp: ' 10/7/07 17:21'!
writeBuffer
	writeBuffer isNil ifTrue: [self initWriteBuffer].
	^writeBuffer! !


!SwazooStream methodsFor: 'chunking' stamp: ' 14/8/07 21:49'!
isChunked
	"sending in chunks (transfer encoding: chunked)"
	^chunked notNil and: [chunked]! !

!SwazooStream methodsFor: 'chunking' stamp: ' 14/8/07 21:49'!
resetChunked
	"sending in chunks (transfer encoding: chunked)"
	chunked := false! !

!SwazooStream methodsFor: 'chunking' stamp: ' 14/8/07 21:49'!
setChunked
	"sending in chunks (transfer encoding: chunked)"
	chunked := true! !


!SwazooStream methodsFor: 'private-stream' stamp: ' 14/8/07 21:49'!
nextByte
	self syncBuffer.
	^self readBuffer next.
! !

!SwazooStream methodsFor: 'private-stream' stamp: 'janko 7/26/2008 18:36'!
nextBytes: aNumber 
	| array |
	array := ByteArray new: aNumber.
	1 to: aNumber do: [:index |  array at: index put: self nextByte].
	^array! !

!SwazooStream methodsFor: 'private-stream' stamp: ' 14/8/07 21:49'!
nextPutByte: aByte 
	self writeBuffer nextPut: aByte.
	self writeBuffer isFull ifTrue: [self flush].
	^aByte! !

!SwazooStream methodsFor: 'private-stream' stamp: ' 14/8/07 21:49'!
nextPutBytes: aByteArray 
	self writeBuffer nextPutAll: aByteArray.
	self writeBuffer isFull ifTrue: [self flush]. 
	^aByteArray! !

!SwazooStream methodsFor: 'private-stream' stamp: ' 14/8/07 21:49'!
peekByte
	self syncBuffer.
	^self readBuffer peek! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooStream class
	instanceVariableNames: ''!

!SwazooStream class methodsFor: 'instance creation' stamp: ' 14/4/07 23:09'!
connectedPair
	^SwazooSocket connectedPair collect: [:each | self socket: each]! !

!SwazooStream class methodsFor: 'instance creation' stamp: 'janko 7/26/2008 18:31'!
on: aString 
	"use only for testing!!"
	^self new readBuffer: (SwazooBuffer on: aString)! !

!SwazooStream class methodsFor: 'instance creation' stamp: ' 14/4/07 23:09'!
socket: aSwazooSocket 
	^self new setSocket: aSwazooSocket! !


Object subclass: #SwazooURI
	instanceVariableNames: 'protocol hostname port identifier queries'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!

!SwazooURI methodsFor: 'printing' stamp: ' 14/4/07 23:09'!
asString
	| targetStream |
	targetStream := WriteStream on: String new.
	self printOn: targetStream.
	^targetStream contents! !

!SwazooURI methodsFor: 'printing' stamp: 'janko 7/26/2008 13:28'!
printOn: targetStream 
	(self hostname notNil and: [self protocol notNil]) 
		ifTrue: 
			[targetStream
				nextPutAll: self protocol;
				nextPutAll: '://'].
	self hostname notNil ifTrue: [targetStream nextPutAll: self hostname].
	(self hostname notNil and: [self port notNil and: [self port ~= 80]]) 
		ifTrue: 
			[targetStream
				nextPut: $:;
				nextPutAll: self port printString].
	self identifier notNil ifTrue: [targetStream nextPutAll: self identifier].
	self printQueriesOn: targetStream.
	^self! !

!SwazooURI methodsFor: 'printing' stamp: ' 14/4/07 23:09'!
printQueriesOn: targetStream 
	| firstQuery |
	self queries isEmpty 
		ifFalse: 
			[firstQuery := self queries at: 1.
			targetStream
				nextPut: $?;
				nextPutAll: firstQuery key;
				nextPut: $=;
				nextPutAll: firstQuery value.
			2 to: self queries size
				do: 
					[:queryIndex | 
					| aQuery |
					aQuery := self queries at: queryIndex.
					targetStream
						nextPut: $&;
						nextPutAll: aQuery key;
						nextPut: $=;
						nextPutAll: aQuery value]].
	^self! !


!SwazooURI methodsFor: 'private' stamp: ' 14/4/07 23:09'!
defaultPort
	^80! !

!SwazooURI methodsFor: 'private'!
readHostFrom: aStream 
	"^self
I read the host name from the URI presumed to be in aStream.  The stream should be positioned right at the start, or just after the '//' of the protocol.  The host name is terminated by one of $:, $/, $? or the end of the stream depending on wether there is a port, path, query or nothing following the host.  If the host name is of zero length, I record a nil host name.  The stream is left positioned at the terminating character."

	| hostnameStream |
	aStream peek = $/ ifTrue: [^self]. "obivously no host in this stream"
	hostnameStream := WriteStream on: String new.
	[|nextCharacter| 
	nextCharacter := aStream peek.
	#($: $/ $? nil) includes: nextCharacter]
		whileFalse: [hostnameStream nextPut: aStream next].
	 hostnameStream contents isEmpty ifFalse: [hostname := hostnameStream contents].
	^self! !

!SwazooURI methodsFor: 'private' stamp: ' 14/4/07 23:09'!
readIdentifierFrom: sourceStream 

	self identifier: (sourceStream upTo: $?).
	^self! !

!SwazooURI methodsFor: 'private'!
readPortFrom: aStream 
	"^self
I read the port nnumber from the URI presumed to be in aStream.  If a port number has been specified, the stream should be positioned right at before a $: charcter.  So, if the next chacter is a :, we have a port number.  I read up to one of $/, $? or the end of the stream depending on wether there is a path, query or nothing following the host.  The stream is left positioned at the terminating character."

	| targetStream |
	aStream peek = $/ ifTrue: [^self]. "obivously no port in this stream"
	targetStream := WriteStream on: String new.
	aStream peek == $: 
		ifTrue: 
			[| terminators |
			terminators := Array 
						with: $/
						with: $?
						with: nil.
			aStream next.
			
			[| nextCharacter |
			nextCharacter := aStream peek.
			terminators includes: nextCharacter] 
					whileFalse: 
						[| nextDigit |
						nextDigit := aStream next.
						nextDigit isDigit ifTrue: [targetStream nextPut: nextDigit]].
			targetStream contents isEmpty 
				ifFalse: [port := targetStream contents asNumber]].
	^self! !

!SwazooURI methodsFor: 'private'!
readProtocolFrom: aStream 
	"^self
I read the protocol from the URI presumed to be in aStream.  The protocol preceeds '://' in the URI.  I leave the stream position either right after the '//' if there is a protocol, otherwise I reset the position to the start of the stream."

	| candidateProtocol |
	self protocol: 'http'. "by default"
	aStream peek = $/ ifTrue: [^self]. "obviously no protocol in this stream"
	candidateProtocol := aStream upTo: $:.
	(aStream size - aStream position >= 2 
		and: [aStream next == $/ and: [aStream next == $/]]) 
			ifTrue: [self protocol: candidateProtocol]
			ifFalse: [aStream reset].
	^self! !

!SwazooURI methodsFor: 'private' stamp: ' 14/4/07 23:09'!
readQueryFrom: sourceStream 
	[sourceStream atEnd] whileFalse: 
		[| nameValue name value |
		nameValue := sourceStream upTo: $& .
		name := nameValue copyUpTo: $= .
		value := nameValue readStream upTo: $= "if any"; upToEnd.
		self queries add: name -> (HTTPString decodedHTTPFrom: value)].
	^self! !


!SwazooURI methodsFor: 'initialize-release' stamp: ' 14/4/07 23:09'!
fromStream: sourceStream 
	self readProtocolFrom: sourceStream.
	self readHostFrom: sourceStream.
	self readPortFrom: sourceStream.
	self readIdentifierFrom: sourceStream.
	self readQueryFrom: sourceStream.
	^self! !

!SwazooURI methodsFor: 'initialize-release' stamp: ' 14/4/07 23:09'!
fromString: aString 
	| sourceStream |
	sourceStream := ReadStream on: (HTTPString decodedHTTPFrom: aString).
	self fromStream: sourceStream.
	^self! !


!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
host
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: self hostname.
	self port = self defaultPort 
		ifFalse: 
			[ws nextPut: $:.
			self port printOn: ws].
	^ws contents! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
host: aString 
	| rs |
	rs := ReadStream on: aString.
	self hostname: (rs upTo: $: ).
	rs atEnd ifFalse: [self port: rs upToEnd asNumber]! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
hostname
	^hostname! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
hostname: aHostname 
	hostname := aHostname! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
identifier
	^identifier! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
identifier: anObject
	identifier := anObject! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
identifierPath
	| parts |
	parts := (HTTPString subCollectionsFrom: self identifier delimitedBy: $/) 
				collect: [:each | HTTPString decodedHTTPFrom: each].
	self identifier first = $/ ifTrue: [parts addFirst: '/'].
	^parts reject: [:each | each isEmpty]! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
identifierPathString
	"^aString
I return the 'directory' part of the path name."

	| sourceStream targetStream |
	targetStream := WriteStream on: String new.
	sourceStream := ReadStream on: self identifier.
	[sourceStream atEnd] whileFalse: 
			[| fragment |
			fragment := sourceStream throughAll: '/'.
			fragment last = $/ ifTrue: [targetStream nextPutAll: fragment]].
	^targetStream contents! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
port
	"^an Integer
The port number defaults to 80 for HTTP."

	^port isNil ifTrue: [80] ifFalse: [port]! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
port: anInteger 
	port := anInteger! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
protocol
	protocol isNil ifTrue: [self protocol: 'http'].
	^protocol! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
protocol: aString
	protocol := aString.! !

!SwazooURI methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
value
	"1 halt: 'Use >>asString or >>printOn: instead'. "
	^self asString! !


!SwazooURI methodsFor: 'accessing-queries' stamp: ' 14/4/07 23:09'!
includesQuery: aString 
	| result |
	result := self queries detect: [:aQuery | aQuery key = aString]
				ifNone: [nil].
	^result notNil! !

!SwazooURI methodsFor: 'accessing-queries' stamp: ' 14/4/07 23:09'!
queries
	"^an OrderedCollection
This is an ordered colleciton of associations.  It can't be a dictionary, because it is legal to have many entries with the same key value."

	queries isNil ifTrue: [queries := OrderedCollection new].
	^queries! !

!SwazooURI methodsFor: 'accessing-queries' stamp: ' 14/4/07 23:09'!
queries: anOrderedCollection 
	"^self
The queries must be an OrderedCollection of Associations c.f. >>queries"

	queries := anOrderedCollection.
	^self! !

!SwazooURI methodsFor: 'accessing-queries' stamp: ' 14/4/07 23:09'!
queriesNamed: aString 
	^self queries select: [:aQuery | aQuery key = aString]! !

!SwazooURI methodsFor: 'accessing-queries' stamp: ' 14/4/07 23:09'!
queryAt: aString 
	^self queryAt: aString ifAbsent: [nil]! !

!SwazooURI methodsFor: 'accessing-queries' stamp: ' 14/4/07 23:09'!
queryAt: aString ifAbsent: aBlock 
	"^aString
I return the value of the first query I find with the key aString.  If there are none I execute aBlock."

	| result |
	result := self queries detect: [:aQuery | aQuery key = aString]
				ifNone: [aBlock].
	^result == aBlock ifTrue: [aBlock value] ifFalse: [result value]! !


!SwazooURI methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
isDirectory
	^self identifier last = $/! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooURI class
	instanceVariableNames: ''!

!SwazooURI class methodsFor: 'instance creation' stamp: ' 14/4/07 23:09'!
fromString: aString
	^self new fromString: aString! !

!SwazooURI class methodsFor: 'instance creation' stamp: ' 14/4/07 23:09'!
value: aString
	^self new value: aString! !


Object subclass: #SwazooWebSocket
	instanceVariableNames: 'version connection recBlock'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!
!SwazooWebSocket commentStamp: 'hmm 6/6/2012 12:46' prior: 0!
This class implements the WebSocket handshake protocol as defined in RFC 6455 (WebSocket version 13)!


!SwazooWebSocket methodsFor: 'private'!
answerTo: aHTTPRequest
	aHTTPRequest isConnectionUpgrade ifFalse: [^HTTPResponse forbidden].
	connection := aHTTPRequest task connection.
	self connection: connection.
	connection 
		webSocket: self;
		closeHandler: self closeHandler.
	connection upgradeToWebSocketAfterResponse.
	^self handshakeResponseTo: aHTTPRequest.! !

!SwazooWebSocket methodsFor: 'private'!
asByteArray: anInteger
	"32bit integer into 4 bytes, big endian"
	"Implemented here because VW 7.8 depreceate that method because it is ambigious. Agreed!!"
	| stream |
	stream := ByteArray new writeStream.
	anInteger digitLength to: 1 by: -1 do: [:digitIndex |
		stream nextPut: (anInteger digitAt: digitIndex)].
	^ stream contents

"(SwazooWebSocket new asByteArray: 420453648) = #[25 15 157 16] "! !

!SwazooWebSocket methodsFor: 'private'!
connection: aWebSocketConnection
	connection := aWebSocketConnection! !

!SwazooWebSocket methodsFor: 'private'!
receiveBlock
	recBlock ifNil: [self receiveBlock: self defaultReceiveBlock].
	^recBlock! !

!SwazooWebSocket methodsFor: 'private' stamp: 'janko 11/1/2012 19:29'!
version: aNumber
	"WebSocket protocol version"
	version := aNumber! !


!SwazooWebSocket methodsFor: 'private-handshake' stamp: 'janko 10/30/2012 10:32'!
base64From: aByteArray 
	"Squeak specific"
	^(Base64MimeConverter mimeEncode: aByteArray readStream) contents

"SwazooWebSocket new base64From: (SwazooWebSocket new shaHashFrom: ' 258EAFA5')"! !

!SwazooWebSocket methodsFor: 'private-handshake'!
calculateAcceptValueFrom:  aHTTPRequest
	| key string hash |
	key := (aHTTPRequest headerAt: 'Sec-WebSocket-Key' ifAbsent: []) value.
	key = nil ifTrue: [^nil].
	string := key, '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'.
	hash := self shaHashFrom: string.
	^self base64From: hash! !

!SwazooWebSocket methodsFor: 'private-handshake'!
handshakeResponseTo: aHTTPRequest
	"this implementation only supports version 13"
	| response header |
	header := (aHTTPRequest headerValueAt: 'Sec-WebSocket-Version').
	header notNil ifTrue: [self version:  header asNumber].
	self version = 13 ifFalse: [  "only version 13 (final RFC) currently supported!!" 
		response := HTTPResponse badRequest.
		response addHeaderName: 'Sec-WebSocket-Version' value: '13'.
		^response].
	response := HTTPResponse webSocketHandshake.
	response addHeaderName: 'Upgrade' value: 'websocket'.
	response headers addField: (HTTPConnectionField new setToUpgrade).
"	response addHeaderName: 'Sec-WebSocket-Origin' value: (aHTTPRequest headerValueAt: 'Origin'). "
"	response addHeaderName: 'Sec-WebSocket-Location' value: (self prepareLocationFrom: aHTTPRequest).  "
	header := aHTTPRequest headerValueAt: 'Sec-WebSocket-Protocol'.
	header notNil ifTrue: 
		[response addHeaderName: 'Sec-WebSocket-Protocol' value: header value].
	response addHeaderName: 'Sec-WebSocket-Accept' value: (self calculateAcceptValueFrom: aHTTPRequest).
	response body: ''.
	^response! !

!SwazooWebSocket methodsFor: 'private-handshake'!
prepareLocationFrom: aHTTPRequest
	| portString |
	portString := (aHTTPRequest port ~= 80)
		ifTrue: [':', aHTTPRequest port printString]
		ifFalse: [''].
	^'ws://', aHTTPRequest host, portString, aHTTPRequest urlString.! !

!SwazooWebSocket methodsFor: 'private-handshake' stamp: 'janko 8/29/2013 20:24'!
shaHashFrom: aByteString
	"Squeak specific"
	| hnumber top answer |
	AIDASite onPharo ifTrue: [^(Smalltalk at: #SHA1) hashMessage: aByteString].
	"Squeak has different SHA class than Pharo"	
	hnumber := (Smalltalk at: #SecureHashAlgorithm) new hashMessage: aByteString.
	top := hnumber basicSize + 1.
	answer := ByteArray new: top - 1.
	1 to: top - 1 do: [:i |
		answer at: i put: (hnumber basicAt: top - i)].
	^answer

	
"(SwazooWebSocket new shaHashFrom: '258EAFA5-E914-47DA-95CA-C5AB0DC85B11') 
       = #[41 248 125 64 139 12 85 151 37 235 17 15 99 19 199 205 111 18 103 204] "! !


!SwazooWebSocket methodsFor: 'sending-receiving'!
close
	self receiveBlock: nil.
	self connection notNil ifTrue: 
		[self connection close].! !

!SwazooWebSocket methodsFor: 'sending-receiving'!
receiveBlock: aBlock
	"register a block to handle a message received"
	" [:message | do something with that message, plain Unicode text string]"
	recBlock := aBlock! !

!SwazooWebSocket methodsFor: 'sending-receiving'!
send: aString 
	"an Unicode string (don't UTF8 encode it in advance!!)"
	^self connection sendMessage: aString! !


!SwazooWebSocket methodsFor: 'accessing'!
closeHandler
	"a #closedConnection: aWebsocketConnection will be send to this object after
	 websocket connection close"
	^closeHandler! !

!SwazooWebSocket methodsFor: 'accessing'!
closeHandler: aWebSocketConnection
	"a #closedConnection: aWebSocketConnection will be send to this object after 
	websocket connection close"
	closeHandler := aWebSocketConnection! !

!SwazooWebSocket methodsFor: 'accessing'!
connection
	"a WebSocket connection to send and receive messages"
	^connection! !

!SwazooWebSocket methodsFor: 'accessing'!
version
	"WebSocket protocol version"
	^version! !


!SwazooWebSocket methodsFor: 'defaults'!
defaultReceiveBlock
	"echo every message received"
	^[:message | self send: message]! !


!SwazooWebSocket methodsFor: 'testing'!
isOpen
	"is WebSocket connection open?"
	^self connection notNil and: [self connection isOpen]! !


!SwazooWebSocket methodsFor: '*Aida' stamp: 'janko 10/31/2012 11:03'!
sendUtf8Text: aString 
	"send an already UTF8 encoded string"
	^self connection sendUtf8Text: aString! !


Object subclass: #URIIdentifier
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!

!URIIdentifier methodsFor: 'comparing' stamp: ' 14/4/07 23:09'!
= anIdentifier 
	^self match: anIdentifier! !

!URIIdentifier methodsFor: 'comparing' stamp: ' 14/4/07 23:09'!
hash
	^1! !


!URIIdentifier methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
match: anotherIdentifier 
	^(self typeMatch: anotherIdentifier) 
		and: [self valueMatch: anotherIdentifier]! !


!URIIdentifier methodsFor: 'private' stamp: ' 14/4/07 23:09'!
typeMatch: anotherIdentifier 
	^self class == anotherIdentifier class! !

!URIIdentifier methodsFor: 'private' stamp: ' 14/4/07 23:09'!
valueMatch: anotherIdentifier 
	^self subclassResponsibility! !


URIIdentifier subclass: #SiteIdentifier
	instanceVariableNames: 'ip port host'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!

!SiteIdentifier methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
currentUrl
	| stream |
	stream := WriteStream on: String new.
	self printUrlOn: stream.
	^stream contents! !

!SiteIdentifier methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
host
	^host! !

!SiteIdentifier methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
ip
	^ip! !

!SiteIdentifier methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
port
	^port! !


!SiteIdentifier methodsFor: 'private' stamp: ' 14/4/07 23:09'!
host: aString
	host := aString! !

!SiteIdentifier methodsFor: 'private' stamp: ' 14/4/07 23:09'!
ip: aString
	ip := aString! !

!SiteIdentifier methodsFor: 'private' stamp: ' 14/4/07 23:09'!
port: aNumber
	port := aNumber! !

!SiteIdentifier methodsFor: 'private' stamp: 'janko 7/26/2008 13:23'!
printHostPortStringOn: stream 
	stream nextPutAll: (self host notNil ifTrue: [self host] ifFalse: ['']).
	self port = 80 ifFalse: [stream nextPut: $:; nextPutAll: self port printString]! !

!SiteIdentifier methodsFor: 'private' stamp: ' 14/4/07 23:09'!
printString
	^'a Swazoo.SiteIndentifier
	host: ', (self host isNil ifTrue: [''] ifFalse: [self host]), '
	ip: ', (self ip isNil ifTrue: [''] ifFalse: [self ip]), '
	port: ', self port printString! !

!SiteIdentifier methodsFor: 'private' stamp: ' 14/4/07 23:09'!
printUrlOn: aWriteStream 
	aWriteStream nextPutAll: 'http://'.
	self printHostPortStringOn: aWriteStream! !


!SiteIdentifier methodsFor: 'initialize-release'!
host:  hostName ip: anIP port: aPort
	self host: hostName.
	self ip: anIP.
	self port: aPort.! !

!SiteIdentifier methodsFor: 'initialize-release' stamp: ' 14/4/07 23:09'!
newServer
	^ HTTPServer new ip: self ip;  port: self port! !


!SiteIdentifier methodsFor: 'private-comparing' stamp: 'janko 7/26/2008 13:23'!
hostMatch: aSiteIdentifier
	(self host asLowercase = aSiteIdentifier host asLowercase) ifTrue: [^true].
	(self host = '*' or: [aSiteIdentifier host = '*']) ifTrue: [^true]. "is this always good?"
 	^false! !

!SiteIdentifier methodsFor: 'private-comparing' stamp: 'mivsek 11/15/2007 13:53'!
ipMatch: aSiteIdentifier
	"ip can be in numbers or named!!"
	| myIP otherIP |
	self ip = aSiteIdentifier ip ifTrue: [^true].
	(self ip = '*' or: [self ip = '0.0.0.0']) ifTrue: [^true].
	(aSiteIdentifier ip = '*' or: [aSiteIdentifier ip = '0.0.0.0']) ifTrue: [^true]. 
																"is this always good?"
	myIP := SpIPAddress hostName: self ip port: self port.
	otherIP := SpIPAddress hostName: aSiteIdentifier ip port: aSiteIdentifier port.
	^myIP hostAddress = otherIP hostAddress! !

!SiteIdentifier methodsFor: 'private-comparing' stamp: 'mivsek 11/15/2007 13:53'!
portMatch: aSiteIdentifier
	"ih host can be anything then same goes for the port of request too"
	self port = aSiteIdentifier port ifTrue: [^true].
	(self host = '*' or: [aSiteIdentifier host = '*']) ifTrue: [^true].
 	^false! !

!SiteIdentifier methodsFor: 'private-comparing' stamp: 'mivsek 11/15/2007 13:53'!
valueMatch: aSiteIdentifier
	^(self portMatch: aSiteIdentifier)
		and: [(self ipMatch: aSiteIdentifier)
			and: [self hostMatch: aSiteIdentifier] ]! !


!SiteIdentifier methodsFor: 'testing' stamp: 'jm 2/8/2009 14:50'!
isEmpty
	"host ip port empty or nil"
	(host isNil or: [host isEmpty]) ifTrue: [^true].
	(ip isNil or: [ip isEmpty]) ifTrue: [^true].
	port isNil ifTrue: [^true].
	^false! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SiteIdentifier class
	instanceVariableNames: ''!

!SiteIdentifier class methodsFor: 'instance creation'!
host: hostName ip: anIP port: aPort 
	^self new 
		host: hostName ip: anIP port: aPort! !


Object subclass: #URIResolution
	instanceVariableNames: 'position request'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!

!URIResolution methodsFor: 'private' stamp: ' 14/4/07 23:09'!
advance
	self position: self position + 1! !

!URIResolution methodsFor: 'private' stamp: ' 14/4/07 23:09'!
currentIdentifier
	^self currentPath last! !

!URIResolution methodsFor: 'private' stamp: ' 14/4/07 23:09'!
currentPath
	^self request uri identifierPath copyFrom: 1 to: self position! !

!URIResolution methodsFor: 'private' stamp: ' 14/4/07 23:09'!
getAnswerFrom: aResource
	^aResource answerTo: self request! !

!URIResolution methodsFor: 'private' stamp: ' 14/4/07 23:09'!
position: anInteger
	position := anInteger! !

!URIResolution methodsFor: 'private' stamp: ' 14/4/07 23:09'!
request: aRequest
	request := aRequest! !

!URIResolution methodsFor: 'private' stamp: ' 14/4/07 23:09'!
retreat
	self position: self position - 1.
	^nil! !

!URIResolution methodsFor: 'private'!
siteMatch: aSite 
	| hostName |
	hostName := self request headers 
				fieldOfClass: HTTPHostField
				ifPresent: [:field | field hostName]
				ifAbsent: [self request requestLine requestURI hostname].
	^aSite uriPattern contains: [:siteIdentifier | 
		siteIdentifier host = '*' 
			or: [siteIdentifier host = hostName] ]


" old, too restrictive, hard for proxies.  Mivsek jul2019
	siteIdentifier := SiteIdentifier 
				host: (hostName notNil ifTrue: [hostName] ifFalse: [''])
				ip: self request ip
				port: self request port.
	^aSite match: siteIdentifier
"! !

!URIResolution methodsFor: 'private' stamp: ' 14/4/07 23:09'!
stringMatch: aResource 
	^aResource uriPattern = self currentIdentifier! !

!URIResolution methodsFor: 'private' stamp: ' 14/4/07 23:09'!
tailStream
	^ReadStream on: self tailPath! !


!URIResolution methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
atEnd
	^self position = self request uri identifierPath size! !

!URIResolution methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
fullPath
	^self request uri identifierPath! !

!URIResolution methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
position
	^position! !

!URIResolution methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
request
	^request! !

!URIResolution methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
resourcePath
	^self request uri identifierPath copyFrom: 1 to: self position! !

!URIResolution methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
tailPath
	| fullPath |
	fullPath := self fullPath.
	^fullPath copyFrom: self position + 1 to: fullPath size! !


!URIResolution methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
initializeRequest: aRequest 
	self request: aRequest.
	self request resolution: self.
	self position: 1! !


!URIResolution methodsFor: 'resolving' stamp: ' 14/4/07 23:09'!
resolveCompositeResource: aResource 
	(aResource canAnswer and: [aResource match: self currentIdentifier]) 
		ifFalse: [^nil].
	^self visitChildrenOf: aResource advancing: true! !

!URIResolution methodsFor: 'resolving' stamp: ' 14/4/07 23:09'!
resolveLeafResource: aResource 
	(aResource canAnswer and: [self stringMatch: aResource]) ifFalse: [^nil].
	^self getAnswerFrom: aResource! !

!URIResolution methodsFor: 'resolving' stamp: ' 14/4/07 23:09'!
resolveServerRoot: aServerRoot 
	^self resolveTransparentComposite: aServerRoot! !

!URIResolution methodsFor: 'resolving' stamp: ' 14/4/07 23:09'!
resolveSite: aSite 
	(aSite canAnswer and: [self siteMatch: aSite]) ifFalse: [^nil].
	^self visitChildrenOf: aSite advancing: false! !

!URIResolution methodsFor: 'resolving' stamp: ' 14/4/07 23:09'!
resolveTransparentComposite: aCompositeResource 
	^self visitChildrenOf: aCompositeResource advancing: false! !

!URIResolution methodsFor: 'resolving' stamp: ' 14/4/07 23:09'!
visitChildrenOf: aResource advancing: aBoolean 
	| response |
	self atEnd & aBoolean ifTrue: [^self getAnswerFrom: aResource].
	aBoolean ifTrue: [self advance].
	aResource children do: 
			[:each | 
			response := self visitResource: each.
			response isNil ifFalse: [^response]].
	^aBoolean ifTrue: [self retreat] ifFalse: [nil]! !

!URIResolution methodsFor: 'resolving' stamp: ' 14/4/07 23:09'!
visitResource: aResource 
	^aResource helpResolve: self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

URIResolution class
	instanceVariableNames: ''!

!URIResolution class methodsFor: 'instance creation' stamp: ' 14/4/07 23:09'!
resolveRequest: aRequest startingAt: aResource 
	^(self new initializeRequest: aRequest) visitResource: aResource! !


HTTPConnection subclass: #WebSocketConnection
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-HTTP'!

!WebSocketConnection methodsFor: 'serving' stamp: 'jmivsek 5/24/2020 18:30'!
close
"	Transcript cr; show: '*** WebSocketConnection close', 
		(self isOpen ifFalse: ['(already closed)'] ifTrue: ['']). 
"	super close.! !


!WebSocketConnection methodsFor: 'private-framing'!
frameString: aString
	"This is currently only used to satisfy the unit test, actual framing is done differently (which should be reflected in the test soon)"
	| out len utf8String |
	utf8String := self toUtf8: aString.
	out := WriteStream on: (String new: utf8String size + 16).
	out nextPut: 129 asCharacter.	"text frame, FIN=1, RSV1,RSV2,RSV3 all zero"
	len := utf8String size.
	len <= 125
		ifTrue: [out nextPut: len asCharacter.	"7 bits, MASK = 0"]
		ifFalse: [
			len < 65536
				ifTrue: [out nextPut: 126 asCharacter; nextNumber: 2 put: len]
				ifFalse: [out nextPut: 127 asCharacter; nextNumber: 8 put: len]].
	out nextPutAll: utf8String.
	^out contents! !

!WebSocketConnection methodsFor: 'private-framing' stamp: 'janko 10/30/2012 10:21'!
fromUtf8: aString
	"Squeak specific"
	^[aString convertFromEncoding: #utf8] on: Error do: [:ex | aString ]! !

!WebSocketConnection methodsFor: 'private-framing' stamp: 'janko 10/30/2012 10:22'!
toUtf8: aString
	"Squeak specific"
	| converter in out |
	converter := UTF8TextConverter new.
	in := aString readStream.
	out := WriteStream on: ''.
	[in atEnd] whileFalse: 
		[converter nextPut: in next toStream: out].
	^out contents
! !


!WebSocketConnection methodsFor: 'private-serving' stamp: 'janko 7/13/2011 20:43'!
getAndDispatchMessages
	self stream anyDataReady  "wait for data and if anything read, proceed"
		ifTrue:
			[self receiveMessage]
		ifFalse: 
			[(Delay forMilliseconds: 100) wait. "to finish sending, if any"
			self close].! !


!WebSocketConnection methodsFor: 'sending-receiving' stamp: 'hmm 6/6/2012 16:00'!
handleBinaryMessage: aByteString
	self webSocket receiveBlock value: aByteString asByteArray! !

!WebSocketConnection methodsFor: 'sending-receiving'!
handleCloseMessage: aByteString
	"not used right now"! !

!WebSocketConnection methodsFor: 'sending-receiving' stamp: 'hmm 6/6/2012 16:11'!
handleContinuationMessage: aByteString
	"not used right now"! !

!WebSocketConnection methodsFor: 'sending-receiving' stamp: 'hmm 6/6/2012 16:10'!
handlePingMessage: aByteString
	self sendFramedData: aByteString opcode: 10! !

!WebSocketConnection methodsFor: 'sending-receiving' stamp: 'hmm 6/6/2012 16:10'!
handlePongMessage: aByteString
	"not used right now"! !

!WebSocketConnection methodsFor: 'sending-receiving'!
handleTextMessage: aByteString
	self webSocket receiveBlock value: (self fromUtf8: aByteString)! !

!WebSocketConnection methodsFor: 'sending-receiving'!
receiveMessage
	| message flags maskingKey mask len b opc |
	[
		flags := self stream next asInteger.
		len := self stream next asInteger.
		mask := len >= 128.
		len := len bitAnd: 127.
		len > 125 ifTrue: [len := self stream nextNumber: (len = 126 ifTrue: [2] ifFalse: [8])].
		mask ifTrue: [maskingKey := self stream next: 4].
		flags < 128 ifTrue: [self close. self halt: 'FIN not set'].
		message := self stream next: len.
		mask ifTrue: [
			1 to: len do: [:i |
				b := message byteAt: i.
				b := b bitXor: (maskingKey byteAt: i-1\\4+1).
				message byteAt: i put: b]].
		opc := flags bitAnd: 15.
		opc = 0 ifTrue: [self handleContinuationMessage: message].
		opc = 1 ifTrue: [self handleTextMessage: message].
		opc = 2 ifTrue: [self handleBinaryMessage: message].
		opc = 8 ifTrue: [self handleCloseMessage: message].
		opc = 9 ifTrue: [self handlePingMessage: message].
		opc = 10 ifTrue: [self handlePongMessage: message]
	] 
		on: Error 
		do: [:ex | self close]! !

!WebSocketConnection methodsFor: 'sending-receiving'!
sendFramedData: data opcode: opc
	| len |
	[self stream nextPut: 128 + opc.
	len := data size.
	len <= 125
		ifTrue: [self stream nextPut: len]
		ifFalse: [
			len < 65536
				ifTrue: [self stream nextPut: 126; nextNumber: 2 put: len]
				ifFalse: [self stream nextPut: 127; nextNumber: 8 put: len]].
	[self stream nextPutAll: data; flush]
		on: Error
		do: [:ex | "ignore"]
	]
		ifCurtailed: [self close]! !

!WebSocketConnection methodsFor: 'sending-receiving'!
sendMessage: aStringOrByteArray
	aStringOrByteArray isString
		ifTrue: [self sendFramedData: (self toUtf8: aStringOrByteArray) opcode: 1]
		ifFalse: [self sendFramedData: aStringOrByteArray opcode: 2]! !


!WebSocketConnection methodsFor: 'testing'!
isHTTPConnection
	^false! !

!WebSocketConnection methodsFor: 'testing'!
isWebSocketConnection
	^true! !


!WebSocketConnection methodsFor: '*Aida' stamp: 'janko 10/31/2012 09:31'!
sendUtf8Text: aString
	"already UTF8 encoded string"
	self sendFramedData: aString opcode: 1! !

HTTPServer initialize!