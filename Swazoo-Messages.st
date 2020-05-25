Object subclass: #HTTPMessage
	instanceVariableNames: 'task headers body'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

!HTTPMessage methodsFor: 'initialize-release' stamp: ' 14/4/07 23:10'!
addInitialHeaders
	"^self 
This is a no-op.  My subclasses may wish to add some initial headers."

	^self! !

!HTTPMessage methodsFor: 'initialize-release' stamp: ' 14/4/07 23:10'!
initHeaders
	headers := HTTPHeaders new.
	self addInitialHeaders.! !


!HTTPMessage methodsFor: 'accessing'!
body
	^body! !

!HTTPMessage methodsFor: 'accessing'!
body: aByteArray
	body := aByteArray! !

!HTTPMessage methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
headers
	headers isNil ifTrue: [self initHeaders].
	^headers! !

!HTTPMessage methodsFor: 'accessing' stamp: 'mivsek 12/31/2007 15:28'!
task
	"on which task (request/response pair) this message belongs"
	"to get a connection on which this task belongs, use task connection"
	^task! !

!HTTPMessage methodsFor: 'accessing' stamp: 'mivsek 12/31/2007 15:28'!
task: aSwazooTask
	task := aSwazooTask! !


!HTTPMessage methodsFor: 'accessing-headers'!
headerAt: aKey ifAbsent: aBlock
	^self headers fieldNamed: aKey  ifNone: aBlock! !

!HTTPMessage methodsFor: 'accessing-headers'!
headerValueAt: aKey
	^(self headerAt: aKey ifAbsent: [^nil]) value! !


Object subclass: #HTTPPostDataArray
	instanceVariableNames: 'underlyingCollection stream parsed'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!
!HTTPPostDataArray commentStamp: '<historical>' prior: 0!
Introduced the HTTPPostDataArray to hold post data in an HTTPRequest in place of a Dictionary.  This is because it is legal for there to be more than one entry with the same name (key) and using a Dictionary  looses data (!!).

Instance Variables:
	underlyingCollection	<>	

!


!HTTPPostDataArray methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
allAt: aKey 
	| candidates |
	candidates := self underlyingCollection 
				select: [:anAssociation | anAssociation key = aKey].
	^candidates collect: [:anAssociation| anAssociation value]! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
allNamesForValue: aString 
	| candidates |
	candidates := self underlyingCollection 
				select: [:anAssociation | anAssociation value value = aString].
	^candidates collect: [:anAssociation| anAssociation key]! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
associations
	^self underlyingCollection! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
at: aKey 
	^(self allAt: aKey) last! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
at: aKey ifAbsent: aBlock 
	| candidates |
	candidates := self underlyingCollection 
				select: [:anAssociation | anAssociation key = aKey].
	^candidates isEmpty ifTrue: [aBlock value] ifFalse: [candidates last value]! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
at: key put: anObject 
	self underlyingCollection add: (Association key: key value: anObject).
	^anObject! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: 'mivsek 7/19/2007 22:07'!
clearParsed
	parsed := false! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
includesKey: aKey 
	| candidates |
	candidates := self underlyingCollection 
				select: [:anAssociation | anAssociation key = aKey].
	^candidates notEmpty! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
includesValue: aString 
	| candidates |
	candidates := self underlyingCollection 
				select: [:anAssociation | anAssociation value value = aString].
	^candidates notEmpty! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
keys
"^a Set
I mimick the behavior of a Dictionay which I replace.  I return a set of the keys in my underlying collection of associations."

	^(self underlyingCollection collect: [:anAssociation| anAssociation key]) asSet! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
nameForValue: aString
	^(self allNamesForValue: aString) last! !

!HTTPPostDataArray methodsFor: 'accessing' stamp: 'mivsek 7/19/2007 22:08'!
setParsed
	parsed := true! !


!HTTPPostDataArray methodsFor: 'initialize-release' stamp: 'mivsek 7/19/2007 22:07'!
initialize
	self clearParsed! !


!HTTPPostDataArray methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isEmpty
	^self underlyingCollection isEmpty! !

!HTTPPostDataArray methodsFor: 'testing' stamp: 'mivsek 7/19/2007 22:08'!
isParsed
	"postdata is already read and parsed from a request"
	^parsed! !


!HTTPPostDataArray methodsFor: 'enumerating' stamp: ' 14/4/07 23:10'!
keysAndValuesDo: aTwoArgumentBlock 
	self underlyingCollection do: 
		[:anAssociation | aTwoArgumentBlock value: anAssociation key value: anAssociation value]! !

!HTTPPostDataArray methodsFor: 'enumerating' stamp: ' 14/4/07 23:10'!
select: aBlock 
"^an Object
I run the select on the values of the associations in my underlying collection.  This mimicks the behavior when a Dictionary was used in my place."
	^self underlyingCollection select:  [:anAssociation| aBlock value: anAssociation value]! !


!HTTPPostDataArray methodsFor: 'private' stamp: ' 14/4/07 23:10'!
printOn: aStream
	aStream nextPutAll: 'a Swazoo.HttpPostDataArray 
	'.
	self underlyingCollection do: [:each | aStream nextPutAll: each key printString , '->', 
		each value value printString, '
	'].! !

!HTTPPostDataArray methodsFor: 'private' stamp: 'mivsek 7/19/2007 22:08'!
stream
	^stream! !

!HTTPPostDataArray methodsFor: 'private' stamp: 'mivsek 7/19/2007 22:08'!
stream: aSwazooStream
	"needed for defered postData parsing"
	stream := aSwazooStream! !

!HTTPPostDataArray methodsFor: 'private' stamp: ' 14/4/07 23:10'!
underlyingCollection
	underlyingCollection isNil 
		ifTrue: [underlyingCollection := OrderedCollection new].
	^underlyingCollection! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPPostDataArray class
	instanceVariableNames: ''!

!HTTPPostDataArray class methodsFor: 'instance creation' stamp: 'mivsek 7/19/2007 22:09'!
newOn: aSwazooStream
	^super new 
		initialize;
		stream: aSwazooStream! !


HTTPMessage subclass: #HTTPRequest
	instanceVariableNames: 'requestLine peer timestamp ip environmentData resolution encrypted authenticated'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

!HTTPRequest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
authenticated
	^authenticated! !

!HTTPRequest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
encrypted
	^encrypted! !

!HTTPRequest methodsFor: 'private' stamp: 'mivsek 7/19/2007 22:09'!
ensureFullRead
	"that is, that everything is read from a socket stream. Importanf for HTTPost 
	and defered parsing of postData"! !

!HTTPRequest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
environmentData
	environmentData isNil ifTrue: [self initEnvironmentData].
	^environmentData! !

!HTTPRequest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
ip: anObject
	ip := anObject! !

!HTTPRequest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
peer: anObject
	peer := anObject! !

!HTTPRequest methodsFor: 'private'!
printOn: aStream 
	| isAjax |
	isAjax := (self headerAt: 'X-Requested-With' ifAbsent: [nil->nil]) value = 'XMLHttpRequest'.
	aStream nextPutAll: 'a HTTPRequest ', (isAjax ifTrue: ['AJAX '] ifFalse: ['']), self methodName.
	self isHttp10 ifTrue: [aStream nextPutAll: ' HTTP/1.0'].
	self isForwarded "behind proxy server"
		ifTrue: [aStream cr; tab; nextPutAll: ' fwd from: ', (self headerAt: 'X-Forwarded-For' ifAbsent: ['']) value]
		ifFalse: [	self peer notNil ifTrue: [aStream cr; tab; nextPutAll: ' from: '; nextPutAll: self peer] ].
	aStream cr; tab; nextPutAll: ' at: '. aStream nextPutAll: 
		self timestamp printString, '.', self timestamp milliseconds printString.
	aStream cr; tab; nextPutAll: ' host: '; nextPutAll: (self headerAt: 'Host' ifAbsent: ['']) hostName.
	aStream cr; tab; nextPutAll: ' url: '. self uri printOn: aStream.
	self referer notNil ifTrue:
		[aStream cr; tab; nextPutAll: ' referer: '. self referer printOn: aStream].
	self userAgent notNil ifTrue: [aStream cr; tab; nextPutAll: ' browser: '; nextPutAll: self userAgent].
	self connection notNil ifTrue: [aStream cr; tab; nextPutAll: ' connection: '; nextPutAll: self connection].
	self keepAlive notNil ifTrue: [aStream cr; tab; nextPutAll: ' keep-alive: '; nextPutAll: self keepAlive].
	^self! !

!HTTPRequest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
queries
	^self uri queries! !

!HTTPRequest methodsFor: 'private'!
readBodyFrom: aStream 
	(self headers includesFieldOfClass: HTTPContentLengthField) ifFalse: 
		[self isWebSocketRequest  "upgrade to WebSocket request has no contentLength"
			ifTrue: [^self]
"			ifTrue: [^self body: (aStream nextBytes: 8)] " "in some old version of WebSocket"
			ifFalse: [^nil] ].
	self body: (aStream nextBytes: self contentLength)! !

!HTTPRequest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
request: aUriString from: aHostString at: anIPString 
	"For testing only (I'm guessing / hoping!!).
A request is manufactured that has a request line method of >>methodName and a request line URI with an identifier of aUriString.  A Host header is added to the headers and the ip address is set to anIP string.  I also set the HTTP version to #(1 1).
This may result in a corrupt or invalid request, but that's the natutre of testing, I guess."

	requestLine := (HTTPRequestLine new)
				method: self class methodName;
				requestURI: ((SwazooURI new)
							identifier: aUriString;
							yourself);
				httpVersion: #(1 1);
				yourself.
	self headers addField: (HTTPHostField newWithValueFrom: aHostString).
	self ip: anIPString.
	^self! !

!HTTPRequest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
setAuthenticated 	
	authenticated := true! !

!HTTPRequest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
setEncrypted
	encrypted := true! !


!HTTPRequest methodsFor: 'services' stamp: ' 14/4/07 23:10'!
conditionalHeaderFields
	"^an OrderedCollection
I return my collection of conditional header fields.  A conditional GET requires that each of these is checked against the current state of the target resource."

	^self headers fields select: [:aField | aField isConditional]! !

!HTTPRequest methodsFor: 'services' stamp: ' 14/4/07 23:10'!
respondUsing: responseBlock 
	"^an HTTPResponse
By default, I let aBlock handle creating the response by passing myself as the agrument to the block.  My subclasses may override this method and directly respond.  This is most likely for Unsupported requests and for things like OPTIONS requsts.  c.f. HTTPServer>>answerTo: "

	^responseBlock value: self! !


!HTTPRequest methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
connection
	^(self headers fieldOfClass: HTTPConnectionField ifNone: [^nil]) 
		connectionToken! !

!HTTPRequest methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
contentLength
	^(self headers fieldOfClass: HTTPContentLengthField) contentLength! !

!HTTPRequest methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
cookie
	| field |
	field := self headers fields at: 'COOKIE' ifAbsent: [^nil].
	^field value

"	field := self headers fieldOfClass: HTTPCookieField ifNone: [nil].
	^field isNil ifTrue: [nil] ifFalse: [field valuesAsString]
"! !

!HTTPRequest methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
host
	^(self headers fieldOfClass: HTTPHostField ifNone: [^String new]) 
		hostName! !

!HTTPRequest methodsFor: 'accessing-headers' stamp: 'mivsek 12/31/2007 15:44'!
keepAlive
	"how many seconds a connection must be kept alive"
	^(self headers fieldNamed: 'KeepAlive' ifNone: [^nil]) value! !

!HTTPRequest methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
port
	"^an Integer
I return the port number to which the request was directed."
	| host |
	host := self headers fieldOfClass: HTTPHostField.
	^(host notNil and: [(self httpVersion at: 2) = 1])
		ifTrue: [host portNumber]
		ifFalse: [self requestLine requestURI port]! !

!HTTPRequest methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
referer
	| field |
	field := self headers fieldOfClass: HTTPRefererField ifNone: [nil].
	^field isNil ifTrue: [nil] ifFalse: [field uri asString]! !

!HTTPRequest methodsFor: 'accessing-headers'!
upgrade
	"protocol to upgrade to"
	^(self headerAt: 'Upgrade' ifAbsent: [^nil]) value! !

!HTTPRequest methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
userAgent
	| userAgentField |
	userAgentField := self headers fieldOfClass: HTTPUserAgentField
				ifNone: [nil].
	^userAgentField isNil ifTrue: [nil] ifFalse: [userAgentField productTokens]! !


!HTTPRequest methodsFor: 'accessing-queries'!
contextId
	"unique id of the web context this request is executing. May be in query part or post data"
	| id |
	id := self 
		queryAt: WebContext contextIdName "aidaCtx" 
		ifAbsent: [nil].
	id notNil ifTrue: 
		[^id asInteger].
	^self isPost 
		ifTrue: [(self postDataAt: WebContext contextIdName ifAbsent: [^nil]) value asInteger]
		ifFalse: [nil]! !

!HTTPRequest methodsFor: 'accessing-queries' stamp: ' 14/4/07 23:10'!
includesQuery: aString 
	^self uri includesQuery: aString! !

!HTTPRequest methodsFor: 'accessing-queries' stamp: ' 14/4/07 23:10'!
queryAt: aKey 
	^self uri queryAt: aKey! !

!HTTPRequest methodsFor: 'accessing-queries' stamp: ' 14/4/07 23:10'!
queryAt: aKey ifAbsent: aBlock 
	^self uri queryAt: aKey ifAbsent: aBlock! !

!HTTPRequest methodsFor: 'accessing-queries' stamp: ' 14/4/07 23:10'!
queryData
	^self uri queryData! !


!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
environmentAt: aKey 
	^self environmentAt: aKey ifAbsent: [nil]! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
environmentAt: aKey ifAbsent: aBlock 
	^self environmentData at: aKey ifAbsent: aBlock! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
environmentAt: aKey put: aValue 
	self environmentData at: aKey put: aValue! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
httpVersion
	^self requestLine httpVersion! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
ip
	^ip! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
methodName
	"HTTP method used for a request"
	^self class methodName! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
peer
	^peer! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
requestLine
	"^an HTTPRequestLine"

	requestLine isNil ifTrue: [self initRequestLine].
	^requestLine! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
resolution
	^resolution! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
resolution: anObject
	resolution := anObject! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
resourcePath
	^self resolution resourcePath! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
session
	^self environmentAt: #session! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
session: aSession 
	self environmentAt: #session put: aSession! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
tailPath
	^self resolution tailPath! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
timestamp
	^timestamp! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
uri
	^self requestLine requestURI! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
uriString
	^self uri identifier! !

!HTTPRequest methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
urlString
	^self uri value! !


!HTTPRequest methodsFor: 'initialize-release'!
for: aRequestLine readFrom: aSwazooStream 
	"^self
I parse my headers from aStream and update my URI and HTTP version information from aRequest line.  I need to parse the headers first because, for some reason, the URI insists on knowing the host, and this is taken from the Host: header field."

	requestLine := aRequestLine.
	headers := HTTPHeaders readFrom: aSwazooStream.
	self isGet ifTrue: [self readBodyFrom: aSwazooStream]. "if any"
	self setTimestamp.
	^self! !

!HTTPRequest methodsFor: 'initialize-release' stamp: ' 14/4/07 23:10'!
initEnvironmentData
	environmentData := Dictionary new! !

!HTTPRequest methodsFor: 'initialize-release' stamp: ' 14/4/07 23:10'!
initRequestLine
	requestLine := HTTPRequestLine new! !

!HTTPRequest methodsFor: 'initialize-release' stamp: ' 14/4/07 23:10'!
setTimestamp
	timestamp := SpTimestamp now! !


!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
hasCookie
	"check if  Cookie:  was in request header"

	"it is GenericHeaderField!!"
	^self headers fields includesKey: 'COOKIE'

"	^self headers includesFieldOfClass: HTTPCookieField"! !

!HTTPRequest methodsFor: 'testing'!
isAjaxRequest
	"Asynchronous JavaScript (AJAX) request, it has additional parameter ajaxRequest"
	| header |
	header := self headerAt: 'X-Requested-With' ifAbsent: [nil].
	(header notNil and: [header  value = 'XMLHttpRequest' ]) ifTrue: [^true].
	^self isPost and: [self uriString = '/aidasession/ajax']! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isAuthenticated
	^self authenticated isNil not! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isClose
	| connectionField |
	connectionField := self headers fieldOfClass: HTTPConnectionField
				ifNone: [nil].
	^connectionField notNil and: [connectionField connectionTokenIsClose]! !

!HTTPRequest methodsFor: 'testing' stamp: 'janko 10/31/2012 17:30'!
isConnectionUpgrade
	((self headerAt: 'Connection' ifAbsent: [^false]) 
		connectionToken tokensBasedOn: $,) do: [:each |
			each trimBlanks = 'Upgrade' ifTrue: [^true]].
	^ false! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isDelete
	^false! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isEncrypted
	^self encrypted isNil not! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isFromLinux
	^self userAgent notNil and: ['*Linux*' match: self userAgent]! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isFromMSIE
	^self userAgent notNil and: ['*MSIE*' match: self userAgent]! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isFromNetscape
	"NS>7.0 or Mozilla or Firefox"
	^self userAgent notNil and: ['*Gecko*' match: self userAgent]! !

!HTTPRequest methodsFor: 'testing'!
isFromOtherAidaSite
	"request comes from other Aida site in AidaGroup"
	^self includesQuery: 'originAidaSite'! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isFromWindows
	^self userAgent notNil and: ['*Windows*' match: self userAgent]! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isGet
	^false! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isHead
	^false! !

!HTTPRequest methodsFor: 'testing' stamp: 'mivsek 12/31/2007 15:43'!
isHttp10
	"Version of requests's HTTP protocol is 1.0"
	^self requestLine isHttp10! !

!HTTPRequest methodsFor: 'testing' stamp: 'mivsek 12/31/2007 15:43'!
isHttp11
	"Version of requests's HTTP protocol is 1.0"
	^self requestLine isHttp11! !

!HTTPRequest methodsFor: 'testing' stamp: 'mivsek 12/31/2007 15:44'!
isKeepAlive
	| header |
	header := self connection.
	header isNil ifTrue: [^false].
	^'*Keep-Alive*' match: header! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isOptions
	^false! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isPost
	^false! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isPut
	^false! !

!HTTPRequest methodsFor: 'testing'!
isSlovenianAccepted
	"Slovenian language among those accepting by web browser sending this request"
	| headerValue |
	headerValue := 
		(self headers 
			fieldNamed: 'ACCEPT-LANGUAGE' 
			ifNone: [^false]) 
				value.
	^'*sl*' match: headerValue! !

!HTTPRequest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isTrace
	^false! !

!HTTPRequest methodsFor: 'testing'!
isWebSocketRequest
	"upgrade connection to WebSocket request. See http://www.swazoo.org/websocket for more"
	^self isConnectionUpgrade 
		and: [self upgrade asLowercase =  'websocket']! !

!HTTPRequest methodsFor: 'testing' stamp: 'mivsek 12/31/2007 15:47'!
wantsConnectionClose
	self isClose ifTrue: [^true].
	^self isHttp10 and: [self isKeepAlive not]! !


!HTTPRequest methodsFor: 'accessing-response' stamp: 'mivsek 12/31/2007 15:46'!
streamedResponse
	"prepares (if not already) and return a streamed response"
	"necessary because we need an output stream to stream into"
	self task response isNil ifTrue: 
		[self task response: 
			(HTTPStreamedResponse on: self task stream: self task connection stream)].
	self task response class == HTTPStreamedResponse 
		ifFalse: [self error: 'not streamed response?'].  "this can happen if resp. is from before"
	^self task response! !

!HTTPRequest methodsFor: 'accessing-response'!
webSocket
	"creates and returns a WebSocket instance to send/receive messages bidirectionally to/from browser"
	" 'all webSocket answerToUpgradeRequest: aRequest ' immediatelly after this call"
	"More on http://www.swazoo.org/websocket"
	self isWebSocketRequest ifFalse: [^self error: 'This must be an upgrade to WebSocket request'].
	^SwazooWebSocket new.! !


!HTTPRequest methodsFor: '*Aida'!
aidaPresentationType
	"depending on Accept header or URL extension it can be #web, #json or #xml"
	| acceptHeader lastPart  |
	acceptHeader := self headerAt: #Accept ifAbsent: [nil].
	acceptHeader ifNotNil:
		[(acceptHeader mediaTypes includes: 'text/json') ifTrue: [^#json].
		 (acceptHeader mediaTypes includes: 'text/xml') ifTrue: [^#xml].].
	lastPart := self requestLine requestURI identifierPath last.
	('*.json' match: lastPart) ifTrue: [^#json].
	('*.xml' match: lastPart) ifTrue: [^#xml].
	^#web! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 11/10/2010 21:23'!
ajaxElementId
	"Asynchronous JavaScript (AJAX) request, it has additional parameter ajaxGetElementId, 
       usually used to identify an element to update"
	| id |
	id := self queryAt: 'ajaxGetElementId' ifAbsent: [nil].
	id notNil ifTrue: [^id asSymbol].
	^self isPost 
		ifTrue: [(self postDataAt: 'ajaxGetElementId' ifAbsent: [^nil]) value asSymbol]
		ifFalse: [nil]
! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 11/10/2010 21:23'!
ajaxElementToRecreateId
	"for Ajax updates from contents of another element "
	"see WebElement>>onClickPopup:, WebApplication>>ajaxUpdate:with: etc."
	| id |
	id := self queryAt: 'ajaxElementToRecreateId' ifAbsent: [nil].
	id notNil ifTrue: [^id asSymbol].
	^self isPost 
		ifTrue: [(self postDataAt: 'ajaxElementToRecreateId' ifAbsent: [^nil]) value asSymbol]
		ifFalse: [nil]! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 4/24/2009 20:08'!
context
	"an execution context for that request"
	^self environmentAt: #context ifAbsent: [nil]! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 4/24/2009 20:08'!
context: aWebContext
	"an execution context for that request"
	self environmentAt: #context put: aWebContext! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 12/14/2010 23:42'!
creationStContexts
	"Smalltalk contexts of element creation methods, to determine, which elements are 
	created first in each method. See WebElement class new, checkIfFirstInMethod, isFirstInMethod"
	^self environmentAt: #creationStContexts ifAbsent: 
		[self environmentAt: #creationStContexts put: Set new.
		^self creationStContexts]! !

!HTTPRequest methodsFor: '*Aida' stamp: 'mivsek 1/10/2008 18:06'!
idFromCookie
	"return session id from our cookie. nil if not aida field present in cookie"
	| stream part |
	stream := self cookie readStream.
	[stream atEnd] whileFalse:
		[part := stream upTo: $; .
		('*aida9357*' match: part) ifTrue:
			[^part readStream upTo: $=; upToEnd] ].
	^nil! !

!HTTPRequest methodsFor: '*Aida' stamp: 'JM 4/22/2007 15:18'!
isAjaxAutocompleteRequest
	"AJAX autocomplete input field request, see WebAutocompleteField"
	self isAjaxRequest ifFalse: [^false].
	^self includesQuery: 'ajaxAutocompleteField'! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 8/20/2009 22:05'!
isAjaxCloseWindowRequest
	"to Ajax close the window and its context (by WebElement>>addCloseWindowText: )"
	| parm2 |
	(self isPost and: [self isAjaxRequest]) ifFalse: [^false].
	parm2 := (self postDataAt: 'parm2').
	^parm2 notNil and: [parm2 value = 'aidaCloseWindow']! !

!HTTPRequest methodsFor: '*Aida' stamp: 'JM 4/22/2007 15:18'!
isAjaxInPlaceEditingRequest
	"AJAX in place editor request, see WebInPlaceEditingText"
	self isAjaxRequest ifFalse: [^false].
	^self includesQuery: 'ajaxInPlaceEditing'! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 8/20/2009 22:05'!
isAjaxPopupWindowRequest
	"to Ajax open some element in a popup window, (WebElement>>onClickPopup: )"
	| parm2 |
	(self isPost and: [self isAjaxRequest]) ifFalse: [^false].
	parm2 := (self postDataAt: 'parm2').
	^parm2 notNil and: [parm2 value = 'aidaPopupWindow']! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 8/20/2009 22:05'!
isAjaxPostRequest
	"Asynchronous JavaScript (AJAX) request, with posting an input field in a query"
	^self isAjaxRequest and: [self isPost]
! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 8/25/2009 22:46'!
isAjaxPostWithInput
	"Asynchronous JavaScript (AJAX) request, with posting an input field in a post data"
	(self isPost and: [self isAjaxRequest]) ifFalse: [^false].
	^(self postDataKeys contains: [:each | 'field*' match: each]) 
		or: [self isAjaxPostWithSingleInput "uncheck a single checkbox doesn't have any add. field !! "
			or: [self postDataKeys includes: 'ajaxPressedButton'] ]! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 8/20/2009 22:06'!
isAjaxPostWithSingleInput
	"Ajax post with of one form element only"
	(self isPost and: [self isAjaxRequest]) ifFalse: [^false].
	^(self postDataKeys includes: 'ajaxSingleField')
		or: [self isAjaxAutocompleteRequest | self isAjaxInPlaceEditingRequest]! !

!HTTPRequest methodsFor: '*Aida' stamp: 'JM 4/22/2007 15:19'!
isAjaxWikiFormatedRequest
	"AJAX in place editor request, see WebInPlaceEditingText"
	self isAjaxRequest ifFalse: [^false].
	^self includesQuery: 'wikiFormated'! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 2/1/2011 21:13'!
isClassicalRequest
	"a classical (not Ajax) request"
	^self isAjaxRequest not! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 12/14/2010 23:42'!
isForwarded
	"Request is forwarded by Proxy server"
	^(self headerAt: 'X-Forwarded-For' ifAbsent: [^false]) notNil! !

!HTTPRequest methodsFor: '*Aida' stamp: 'janko 7/13/2008 11:28'!
isPing
	"/ping.html, for monitoring the site etc."
	^self requestLine requestURI identifier = '/ping.html'! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jm 2/1/2011 21:14'!
isWebEvent
	^false! !

!HTTPRequest methodsFor: '*Aida' stamp: 'jmivsek 5/24/2020 14:46'!
realPeerIp
	"if behind a proxy, for instance"
	^self isForwarded "behind proxy server"
		ifTrue: [(self headerAt: 'X-Forwarded-For' ifAbsent: ['']) value]
		ifFalse: [	self peer notNil ifTrue: [self peer] ifFalse: [''] ].
! !

!HTTPRequest methodsFor: '*Aida'!
view
	| view |
	view := self queryAt: 'view' ifAbsent: [nil].
	view notNil ifTrue: [^(view readStream upTo: $# )  asSymbol]. "skip #anchor if any"
	^self isPost 
		ifTrue: [(self postDataAt: 'view' ifAbsent: [^#main]) value asSymbol]
		ifFalse: [#main]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPRequest class
	instanceVariableNames: ''!

!HTTPRequest class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
allMethodNames
	"...of all request methods we support there"
	self subclasses collect: [:each | each methodName].! !

!HTTPRequest class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
methodName
	"HTTP method used for a request"
	^self subclassResponsibility! !


!HTTPRequest class methodsFor: 'instance creation' stamp: ' 10/7/07 17:21'!
newFor: aRequestLine readFrom: aSwazooStream 
	"to support an additional http method, simply subclass a HTTPRequest!!"
	| targetClass |
	targetClass := aRequestLine method = 'GET' 
		ifTrue: [HTTPGet] "most used anyway"
		ifFalse: [aRequestLine method = 'POST'  
			ifTrue: [HTTPPost]  "second most used"
			ifFalse: [self subclasses detect: [:each | 
				each methodName = aRequestLine method] ifNone: [nil] ] ].
	targetClass isNil ifTrue: [^HTTPException notImplemented].
	^targetClass new for: aRequestLine readFrom: aSwazooStream! !

!HTTPRequest class methodsFor: 'instance creation' stamp: ' 10/7/07 17:21'!
readFrom: aSwazooStream 
	"^an HTTPRequest
I create and return a new instance of one of my subclasses which will represent the HTTP request presumed to be the contents of aStream.
The first step is to work out which of my subclasses to create.  I do this by parsing the 'request-line' from the stream.  The request-line contains the 'method', and I look for the subclass that handles this method and delegate the rest of the message parsing to a new instance of that class."

	| requestLine |
	requestLine := HTTPRequestLine readFrom: aSwazooStream.
	^self newFor: requestLine readFrom: aSwazooStream! !


!HTTPRequest class methodsFor: 'tests support' stamp: ' 14/4/07 23:10'!
request: aUriString 
	"For testing only (I'm guessing / hoping!!).  The idea to to create a request for a resource with the URI 'someHost/aUriString'."

	^self 
		request: aUriString
		from: 'someHost'
		at: 'someIP'! !

!HTTPRequest class methodsFor: 'tests support' stamp: ' 14/4/07 23:10'!
request: aUriString from: aHostString at: anIPString 
	"For testing only (I'm guessing / hoping!!).
A request is manufactured that has a request line method of >>methodName and a request line URI with an identifier of aUriString.  A Host header is added to the headers and the ip address is set to anIP string.
This may result in a corrupt or invalid request, but that's the natutre of testing, I guess."

	^self new 
		request: aUriString
		from: aHostString
		at: anIPString! !


HTTPRequest subclass: #HTTPDelete
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!
!HTTPDelete commentStamp: '<historical>' prior: 0!
HTTPDelete 

rfc26216 section 9.7

The DELETE method requests that the origin server delete the resource
   identified by the Request-URI. This method MAY be overridden by human
   intervention (or other means) on the origin server. The client cannot
   be guaranteed that the operation has been carried out, even if the
   status code returned from the origin server indicates that the action
   has been completed successfully. However, the server SHOULD NOT
   indicate success unless, at the time the response is given, it
   intends to delete the resource or move it to an inaccessible
   location.
 ...
!


!HTTPDelete methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isDelete
	^true! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPDelete class
	instanceVariableNames: ''!

!HTTPDelete class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
methodName
	"HTTP method used for a request"
	^'DELETE'! !


HTTPRequest subclass: #HTTPGet
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!
!HTTPGet commentStamp: '<historical>' prior: 0!
HTTPGet 

rfc26216 section 9.3

   The GET method means retrieve whatever information (in the form of an
   entity) is identified by the Request-URI. If the Request-URI refers
   to a data-producing process, it is the produced data which shall be
   returned as the entity in the response and not the source text of the
   process, unless that text happens to be the output of the process.
!


!HTTPGet methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isGet
	^true! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPGet class
	instanceVariableNames: ''!

!HTTPGet class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
methodName
	^'GET'! !


HTTPRequest subclass: #HTTPHead
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!
!HTTPHead commentStamp: '<historical>' prior: 0!
HTTPHead

rfc26216 section 9.4

   The HEAD method is identical to GET except that the server MUST NOT
   return a message-body in the response. The metainformation contained
   in the HTTP headers in response to a HEAD request SHOULD be identical
   to the information sent in response to a GET request. This method can
   be used for obtaining metainformation about the entity implied by the
   request without transferring the entity-body itself. This method is
   often used for testing hypertext links for validity, accessibility,
   and recent modification.

!


!HTTPHead methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isHead
	^true! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPHead class
	instanceVariableNames: ''!

!HTTPHead class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
methodName
	^'HEAD'! !


HTTPRequest subclass: #HTTPOptions
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!
!HTTPOptions commentStamp: '<historical>' prior: 0!
HTTPOptions

rfc26216 section 9.2

   The OPTIONS method represents a request for information about the
   communication options available on the request/response chain
   identified by the Request-URI. This method allows the client to
   determine the options and/or requirements associated with a resource,
   or the capabilities of a server, without implying a resource action
   or initiating a resource retrieval.

!


!HTTPOptions methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isOptions
	^true! !


!HTTPOptions methodsFor: 'services' stamp: ' 14/4/07 23:10'!
respondUsing: responseBlock 
	"^an HTTPResponse
I represent a request for the options supported by this server.  I respond with a 200 (OK) and a list of my supported methods in an Allow: header.  I ignore the responseBlock."

	| response allowField |
	response := HTTPResponse ok.
	allowField := HTTPAllowField new.
	allowField methods addAll: self class allMethodNames.
	response headers addField: allowField.
	^response! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPOptions class
	instanceVariableNames: ''!

!HTTPOptions class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
methodName
	^'OPTIONS'! !


HTTPRequest subclass: #HTTPPost
	instanceVariableNames: 'postData entityBody readPosition'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!
!HTTPPost commentStamp: '<historical>' prior: 0!
HTTPPost 

rfc26216 section 9.5

   The POST method is used to request that the origin server accept the
   entity enclosed in the request as a new subordinate of the resource
   identified by the Request-URI in the Request-Line.

Instance Variables:
	entityBody	<>	
	postData	<HTTPPostDataArray>	

!


!HTTPPost methodsFor: 'private' stamp: ' 14/4/07 23:10'!
applicationOctetStreamFrom: aStream 
	"^self 
rfc 2046 says:
The recommended action for an implementation that receives an 'application/octet-stream' entity is to simply offer to put the data in a file, with any Content-Transfer-Encoding undone, or perhaps to use it as input to a user-specified process.
This method used to do a crlf -> cr conversion on the octet-stream, but was not clear why."

	self entityBody: (HTTPString 
				stringFromBytes: (aStream nextBytes: self contentLength)).
	^self! !

!HTTPPost methodsFor: 'private' stamp: ' 14/4/07 23:10'!
entityBody: aString
	entityBody := aString! !

!HTTPPost methodsFor: 'private' stamp: ' 10/7/07 17:21'!
incReadPosition
	self readPosition: self readPosition + 1! !

!HTTPPost methodsFor: 'private' stamp: 'janko 7/26/2008 18:43'!
incReadPosition: anInteger
	self readPosition: self readPosition + anInteger! !

!HTTPPost methodsFor: 'private' stamp: 'mivsek 7/19/2007 22:12'!
postData
	^postData! !

!HTTPPost methodsFor: 'private'!
printOn: aStream
	super printOn: aStream.
	self postData isParsed not ifTrue:
		[aStream cr; tab; nextPutAll: '** not yet fully parsed!!'].
	self postData notEmpty ifTrue:
		[aStream cr; tab; nextPutAll: 'postData: '.
		self postData keysAndValuesDo: [:key :value | 
			aStream cr; tab; tab; nextPutAll: key, '='; nextPutAll: value value printString.] ].
	self entityBody notNil ifTrue:
		[aStream cr; tab; nextPutAll: 'entityBody: '.
		aStream nextPutAll: self entityBody ].! !

!HTTPPost methodsFor: 'private' stamp: ' 10/7/07 17:21'!
readPosition
	"position in a read stream. just temporary"
	readPosition isNil ifTrue: [^1].
	^readPosition! !

!HTTPPost methodsFor: 'private' stamp: ' 10/7/07 17:21'!
readPosition: aNumber
	readPosition := aNumber! !


!HTTPPost methodsFor: 'private-parsing support' stamp: 'janko 8/4/2008 13:16'!
blockStreamingFrom: aSwazooStream to: outStream until: aBoundaryBytes "detected"
	"copy by 8k blocks for optimal performance until a boundary of MIME part is detected"
	"Finish appropriatelly streaming at the end (skip crlf etc.)"
	| boundary start nrOfBoundary contents inPrevious remainingBoundary boundaryIndex |
	boundary := aSwazooStream readBuffer isBinary 
		ifTrue: [aBoundaryBytes asByteArray] ifFalse: [aBoundaryBytes asByteString].
	start := self readPosition.
	[true] whileTrue:
		[nrOfBoundary := 0.
		[nrOfBoundary = 0] whileTrue:
			[nrOfBoundary := aSwazooStream readBuffer signsOfBoundary: boundary.
			nrOfBoundary = 0 ifTrue: "no boundary in current buffer content"
				[contents := aSwazooStream readBuffer readContents.
				outStream nextPutAll: contents. 
				self incReadPosition: contents size.
				self checkToEnlargeBufferIn: aSwazooStream from: start. "for effective streaming"
				aSwazooStream fillBuffer] ].
		"copy and stream out content up to potential boundary"
		boundaryIndex := aSwazooStream readBuffer indexOfBoundary: boundary.
		inPrevious := aSwazooStream readBuffer copyBufferTo: boundaryIndex-1.
		outStream nextPutAll: 
			(inPrevious copyFrom: 1 to: (inPrevious size-2 max: 0) "without potential crlf"). 
		self incReadPosition: inPrevious size. "potential crlf included!!"

		nrOfBoundary = boundary size ifTrue: "full boundary detected, lets finish here"
			[aSwazooStream skip: boundary size. "skip boundary"
			self incReadPosition: boundary size.
			^true].  "streaming complete"

		self incReadPosition: nrOfBoundary.
		aSwazooStream fillBuffer. "let's get next buffer"
		remainingBoundary := boundary copyFrom: nrOfBoundary+1 to: boundary size.
		(aSwazooStream readBuffer startsWith:  remainingBoundary) ifTrue: "bound. ends in next buff?"
			[aSwazooStream skip: remainingBoundary size + 2.  "skip remaining bound. and crlf"
			self incReadPosition: remainingBoundary size + 2.
			^true]. "streaming complete"

		outStream 
			nextPutAll: (inPrevious copyFrom: inPrevious size-2 to: inPrevious size);  "potential crlf"
			nextPutAll: (boundary copyFrom: 1 to: nrOfBoundary).  "boundary part in prev.buff."
		] "continue from the start"! !

!HTTPPost methodsFor: 'private-parsing support' stamp: 'janko 8/3/2008 17:21'!
checkToEnlargeBufferIn: aSwazooStream from: startPosition
	"enlarge buffer to 1MB (if not already) if more than 100KB already read"
	aSwazooStream readBuffer isEnlarged ifTrue: [^nil].
	(self readPosition - startPosition) > 100000 "about 100KB" 
		ifTrue: [aSwazooStream readBuffer resizeEnlarge].! !

!HTTPPost methodsFor: 'private-parsing support'!
containsHeaderNecessaryFields
	"content type and (content length or chunked transfer encoding)"
	(self headers includesFieldOfClass: HTTPContentLengthField) ifTrue: [^true].
	(self headers includesFieldOfClass: ContentTypeField) ifFalse: [^false].
	^(self headers fieldNamed: 'Transfer-encoding' ifNone: [^false]) value = 'chunked'! !

!HTTPPost methodsFor: 'private-parsing support' stamp: 'mivsek 8/7/2007 18:53'!
skipMimeEpilogueFrom: aSwazooStream
	"skip a mime epilogue until end of post data defined by contentLength"
	"example:
		--boundary--
		This is the epilogue.  It is also to be ignored
	"
	[self readPosition < self contentLength] whileTrue: 
		[aSwazooStream next. "just skip"
		self incReadPosition].! !

!HTTPPost methodsFor: 'private-parsing support' stamp: 'janko 7/26/2008 18:49'!
skipMimePreambleAndBoundary: aBoundaryBytes from: aSwazooStream
	"skip a mime preamble until first boundary starts then skip that boundary too"
	"example:
		Content-type: multipart/mixed; boundary=''boundary''

		This is the preamble.  It is to be ignored, though it is
		a handy place to include an explanatory note to non-MIME compliant readers.
		--boundary
		..."
	| dummy |
	dummy := WriteStream on: ByteArray new.
	self blockStreamingFrom: aSwazooStream to: dummy until: ('--', aBoundaryBytes)! !


!HTTPPost methodsFor: 'accessing' stamp: 'mivsek 7/19/2007 22:13'!
emptyData
	self ensureFullRead.
	^self postData select: [:each | each value isEmpty]! !

!HTTPPost methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
entityBody
	^entityBody! !

!HTTPPost methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
postDataAt: aKey 
	^self postDataAt: aKey ifAbsent: [nil]! !

!HTTPPost methodsFor: 'accessing' stamp: 'mivsek 7/24/2007 21:05'!
postDataAt: aKey beforeStreamingDo: aBlockClosure
	"announce that you want to receive post data directly to a binary stream, which will be set
	by aBlockClosure. That block must receive and argument, which is a HTTPostDatum and 
	here it can set a writeStream"
	"Fails if post data is already read"
	self postData isParsed 
		ifTrue: [^self error: 'HTTPost already parsed, streaming not possible anymore!!'].
	^self postDataAt: aKey put: (HTTPPostDatum new writeBlock: aBlockClosure)! !

!HTTPPost methodsFor: 'accessing' stamp: 'mivsek 7/19/2007 22:15'!
postDataAt: aKey do: aBlock 
	| val |
	self ensureFullRead. "defered parsing of postData"
	val := self postData at: aKey ifAbsent: [nil].
	val isNil ifFalse: [aBlock value: val]! !

!HTTPPost methodsFor: 'accessing' stamp: 'mivsek 7/19/2007 22:15'!
postDataAt: aKey ifAbsent: aBlock 
	self ensureFullRead. "defered parsing of postData"
	^self postData at: aKey ifAbsent: aBlock! !

!HTTPPost methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
postDataAt: aKey put: aPostDatum 
	"for testing purposes"

	self postData at: aKey put: aPostDatum! !

!HTTPPost methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
postDataAt: aKey putString: aString 
	"for testing purposes"

	self postDataAt: aKey put: (HTTPPostDatum new value: aString)! !

!HTTPPost methodsFor: 'accessing' stamp: 'mivsek 7/20/2007 23:45'!
postDataAt: aKey streamTo: aWriteStream
	"announce that you want to receive post data directly to aWriteStream, 
	which must be binary. Fails if post data is already read"
	self postData isParsed 
		ifTrue: [^self error: 'HTTPost already parsed, streaming not possible anymore!!'].
	^self postDataAt: aKey put: (HTTPPostDatum new writeStream: aWriteStream)! !

!HTTPPost methodsFor: 'accessing' stamp: 'mivsek 7/19/2007 22:15'!
postDataKeys
	self ensureFullRead. "defered parsing of postData"
	^self postData keys! !

!HTTPPost methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
postDataStringAt: aKey 
	^(self postDataAt: aKey ifAbsent: [^nil]) value! !

!HTTPPost methodsFor: 'accessing' stamp: 'mivsek 7/19/2007 22:15'!
postKeysAndValuesDo: aTwoArgBlock 
	self ensureFullRead. "defered parsing of postData"
	self postData 
		keysAndValuesDo: [:key :each | aTwoArgBlock value: key value: each value]! !


!HTTPPost methodsFor: 'parsing'!
ensureFullRead
	"that is, everything is read from a socket stream. Important because of defered parsing
	of postData"
	self postData isParsed ifTrue: [^nil]. 
	[self parsePostDataFrom: self postData stream]
		on: Error
		do: [:ex | "just ignore"].
	self postData setParsed.! !

!HTTPPost methodsFor: 'parsing' stamp: 'mivsek 7/19/2007 22:12'!
for: aRequestLine readFrom: aSwazooStream 
	super for: aRequestLine readFrom: aSwazooStream.
	self initPostDataFor: aSwazooStream.
"	self parsePostDataFrom: aSwazooStream." "defered until first access of postData!! "! !

!HTTPPost methodsFor: 'parsing'!
parsePostDataFrom: aSwazooStream 
	| contentType |
	self containsHeaderNecessaryFields ifFalse: 
		[^SwazooHTTPPostError raiseSignal: 'Content-Type and Content-Length or chunked needed'].
	contentType := self headers fieldOfClass: ContentTypeField.
	contentType notNil ifTrue: 
		[contentType mediaType = 'application/x-www-form-urlencoded' 
			ifTrue: [^self urlencodedDataFrom: aSwazooStream].
		contentType mediaType = 'multipart/form-data' 
			ifTrue: [^self multipartDataFrom: aSwazooStream] ].
	^self applicationOctetStreamFrom: aSwazooStream.! !


!HTTPPost methodsFor: 'initialize-release' stamp: 'mivsek 7/19/2007 22:12'!
initPostDataFor: aSwazooStream
	postData := HTTPPostDataArray newOn: aSwazooStream! !


!HTTPPost methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isPost
	^true! !

!HTTPPost methodsFor: 'testing' stamp: 'mivsek 7/19/2007 22:13'!
isPostDataEmpty
	self ensureFullRead.
	^self postData isEmpty! !

!HTTPPost methodsFor: 'testing' stamp: 'mivsek 7/21/2007 22:47'!
isPostDataStreamedAt: aKey
	^(self postData at: aKey ifAbsent: [^false]) isStreamed! !


!HTTPPost methodsFor: 'private-parsing' stamp: 'jm 2/8/2009 14:55'!
multipartDataFrom: aSwazooStream
	"read all mime parts and put them in postData" 
	"read directly from stream, without intermediate buffers"
	| contentTypeField boundary part |
	contentTypeField := self headers fieldOfClass: ContentTypeField
				ifNone: [^aSwazooStream nextBytes: self contentLength]. "just skip"
	boundary := contentTypeField transferCodings at: 'boundary'
				ifAbsent: [^aSwazooStream nextBytes: self contentLength]. "just skip"
	self skipMimePreambleAndBoundary: boundary from: aSwazooStream. 
	part := #something. 
	[part notNil] whileTrue: 
		[part := self partFromStream: aSwazooStream boundary: boundary.
		part notNil ifTrue: [self postDataAt: part key put: part value]].
	self skipMimeEpilogueFrom: aSwazooStream. "all to the end  as defined by contentLegth"
	aSwazooStream readBuffer isEnlarged  "if MIME part larger that 100KB was read"
		ifTrue: [aSwazooStream readBuffer resizeShrink]. "that is, release memory"! !

!HTTPPost methodsFor: 'private-parsing' stamp: 'jm 2/8/2009 23:59'!
partFromStream: aSwazooStream boundary: aBoundaryBytes
	"one mime part from a stream. Nil if no more multipart data"
	"Squeak specific"
	| bytes name filename datum contentType |
	bytes := aSwazooStream nextBytes: 2. self incReadPosition: 2.
	bytes = '--' asByteArray  ifTrue: [^nil].    "end of multipart data"
		
	name := nil. datum := nil. contentType := nil. "just to avoid compilation warning"
	[true] whileTrue: [| line |  "read all lines and at the end a body of that part"
		line := [(aSwazooStream upTo: Character cr asInteger) asString] "Squeak specific"
			on: Error do: [:ex | ''].  "usually nothing to read anymore), why happen this anyway?"
		self readPosition: self readPosition + line size + 1 "cr".
		line := bytes asString, line. bytes := ''.
		aSwazooStream peekByte = Character lf asInteger ifTrue: [| field | "this is a name line"
			aSwazooStream nextByte.  self incReadPosition. "skip linefeed"
			line isEmpty 	ifTrue: [| | "empty line indicates start of entity"
				name isNil ifTrue: [^nil].  "name must be read in previous circle"
				datum contentType: contentType. "completes datum's contentType read in a prev step"
 				^name -> (self readEntityFrom: aSwazooStream 
					datum: datum boundary: aBoundaryBytes)].
			field := HeaderField fromLine: line.
			field isContentDisposition ifTrue: 
					[name := (field parameterAt: 'name') copyWithout: $". 
					datum := (self isPostDataStreamedAt: name)
						ifTrue: [self postData at: name]  "streamed datum must exist before"
						ifFalse: [HTTPPostDatum new].
					contentType notNil ifTrue: [datum contentType: contentType]. "if read in prev.circle"
					filename := field parameterAt: 'filename' .   "only for file uploads"
					filename notNil ifTrue: [datum filename: (filename copyWithout: $")] ].
			field isContentType ifTrue: [contentType := field mediaType ] ] ]! !

!HTTPPost methodsFor: 'private-parsing' stamp: 'janko 7/26/2008 18:48'!
readEntityFrom: aSwazooStream datum: aDatum boundary: aBoundaryBytes
	"read one entity from a stream and put into datum. Stream it if streamed. Also call a block 
	(if any) just before start of streaming, with a datum as parameter. This block can then set 
	a write stream in datum (for instance open a output file and stream on it)"
	| outStream |
	aDatum writeBlock notNil 
		ifTrue: [aDatum writeBlock value: aDatum]. "this should set writeStream if not already!!" 
	outStream := (aDatum isStreamed and: [aDatum writeStream notNil])
		ifTrue: [aDatum writeStream] ifFalse: [WriteStream on: ByteArray new].
	self blockStreamingFrom: aSwazooStream to: outStream until: ('--', aBoundaryBytes). "efficient streaming"
	aDatum isStreamed not ifTrue: "otherwise entity is already streamed to the output"
		[aDatum value: outStream contents asString].
	^aDatum! !

!HTTPPost methodsFor: 'private-parsing' stamp: 'mivsek 12/31/2007 15:29'!
urlencodedDataFrom: aStream 
	| entity tokens |
	(self headers includesFieldOfClass: HTTPContentLengthField) ifFalse: [^self].
	entity := aStream nextBytes: self contentLength.
	tokens := HTTPString subCollectionsFrom: (HTTPString stringFromBytes: entity) delimitedBy: $&.
	(tokens collect: [:each | HTTPString subCollectionsFrom: each delimitedBy: $=]) 
		do: 	[:keyVal | | datum key |
			datum := HTTPPostDatum new.
			datum value: (HTTPString decodedHTTPFrom: 
 				(keyVal last collect: [:char | 
					char = $+ ifTrue: [Character space] ifFalse: [char]])).
			key := (HTTPString decodedHTTPFrom: 
 				(keyVal first collect: [:char | 
					char = $+ ifTrue: [Character space] ifFalse: [char]])).
			self postDataAt: key put: datum]! !


!HTTPPost methodsFor: '*Aida'!
ajaxSingleInputName
	"Single form field Ajax posts have additional parameter carying the name of that field"
	"except for autocomplete and inplace editing fields, where a first and only field is returned"
	| pdata |
	pdata := self postDataAt: 'ajaxSingleField' ifAbsent: [nil].
	pdata notNil ifTrue: [^pdata value].
	(self isAjaxAutocompleteRequest | self isAjaxInPlaceEditingRequest) ifTrue: 
		[^self postDataKeys detect: [:each | 'field*' match: each] ifNone: nil].
	^nil! !

!HTTPPost methodsFor: '*Aida' stamp: 'np 10/20/2008 16:44'!
postDataKeysNotStreamed
	"keys for a postData which is not streamed"
	self ensureFullRead. "defered parsing of postData"
	^(self postData underlyingCollection select: [:assoc | assoc value isStreamed not])
		collect: [:assoc | assoc key]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPPost class
	instanceVariableNames: ''!

!HTTPPost class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
methodName
	^'POST'! !


HTTPRequest subclass: #HTTPPut
	instanceVariableNames: 'putData'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!
!HTTPPut commentStamp: '<historical>' prior: 0!
HTTPPut 

rfc26216 section 9.6

   The PUT method requests that the enclosed entity be stored under the
   supplied Request-URI. If the Request-URI refers to an already
   existing resource, the enclosed entity SHOULD be considered as a
   modified version of the one residing on the origin server. If the
   Request-URI does not point to an existing resource, and that URI is
   capable of being defined as a new resource by the requesting user
   agent, the origin server can create the resource with that URI. If a
   new resource is created, the origin server MUST inform the user agent
   via the 201 (Created) response. If an existing resource is modified,
   either the 200 (OK) or 204 (No Content) response codes SHOULD be sent
   to indicate successful completion of the request. If the resource
   could not be created or modified with the Request-URI, an appropriate
   error response SHOULD be given that reflects the nature of the
   problem. The recipient of the entity MUST NOT ignore any Content-*
   (e.g. Content-Range) headers that it does not understand or implement
   and MUST return a 501 (Not Implemented) response in such cases.

Instance Variables:
	putData	<>	

!


!HTTPPut methodsFor: 'reading'!
for: aRequestLine readFrom: aSwazooStream 
	super for: aRequestLine readFrom: aSwazooStream .
	self octetDataFrom: aSwazooStream.! !

!HTTPPut methodsFor: 'reading' stamp: ' 14/4/07 23:10'!
octetDataFrom: aStream 
	self headers fieldOfClass: HTTPContentLengthField
		ifNone: [^SwazooHTTPPutError raiseSignal: 'Missing Content-Length'].
	self putData: (aStream nextBytes: self contentLength)! !


!HTTPPut methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isPut
	^true! !


!HTTPPut methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
putData
	^putData! !


!HTTPPut methodsFor: 'private' stamp: ' 14/4/07 23:10'!
putData: aString
	putData := aString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPPut class
	instanceVariableNames: ''!

!HTTPPut class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
methodName
	^'PUT'! !


Object subclass: #HTTPRequestLine
	instanceVariableNames: 'method requestURI httpVersion'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

!HTTPRequestLine methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
httpVersion
	^httpVersion! !

!HTTPRequestLine methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
method
	^method! !

!HTTPRequestLine methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
requestURI
	^requestURI! !


!HTTPRequestLine methodsFor: 'private' stamp: ' 14/4/07 23:10'!
httpVersion: anArray 
	httpVersion := anArray.
	^self! !

!HTTPRequestLine methodsFor: 'private' stamp: ' 14/4/07 23:10'!
method: aString
"For development testing only"
	method := aString.
	^self! !

!HTTPRequestLine methodsFor: 'private' stamp: ' 14/4/07 23:10'!
requestURI: aString 
	"Development testing only!!"

	requestURI := aString.
	^self! !

!HTTPRequestLine methodsFor: 'private' stamp: ' 10/7/07 17:21'!
skipLeadingBlankLinesIn: aSwazooStream 
	"^self
RFC 2616:
In the interest of robustness, servers SHOULD ignore any empty
line(s) received where a Request-Line is expected. In other words, if
the server is reading the protocol stream at the beginning of a
message and receives a CRLF first, it should ignore the CRLF."

	[aSwazooStream peek == Character cr asInteger] whileTrue: 
			[(((aSwazooStream next: 2) at: 2) == Character lf asInteger) 
				ifFalse: [SwazooHTTPParseError raiseSignal: 'CR without LF']].
	^self! !

!HTTPRequestLine methodsFor: 'private' stamp: 'mivsek 7/26/2007 13:27'!
skipSpacesIn: aSwazooStream 
	[aSwazooStream peek = Character space] 
		whileTrue: [aSwazooStream next].
	^self! !


!HTTPRequestLine methodsFor: 'testing' stamp: 'mivsek 12/31/2007 15:48'!
isHttp10
	^self httpVersion last = 0! !

!HTTPRequestLine methodsFor: 'testing' stamp: 'mivsek 12/31/2007 15:48'!
isHttp11
	^self httpVersion last = 1! !


!HTTPRequestLine methodsFor: 'parsing' stamp: 'mivsek 7/26/2007 13:07'!
parseHTTPVersionFrom: aSwazooStream 
	| major minor |
	self skipSpacesIn: aSwazooStream.
	aSwazooStream upTo: $/ asInteger.
	major := (aSwazooStream upTo: $. asInteger) asString asNumber.
	minor := (aSwazooStream upTo: Character cr asInteger) asString asNumber.
	self httpVersion: (Array with: major with: minor).
	aSwazooStream next.
	^self! !

!HTTPRequestLine methodsFor: 'parsing' stamp: 'mivsek 7/26/2007 13:06'!
parseURIFrom: aSwazooStream 
	"^self
	Really, we should parse the URI directly out of the stream."

	self skipSpacesIn: aSwazooStream.
	requestURI := SwazooURI fromString: 
		(aSwazooStream upTo: Character space asInteger) asString.
	^self! !

!HTTPRequestLine methodsFor: 'parsing' stamp: 'mivsek 7/10/2007 18:52'!
readFrom: aSwazooStream 
	"^self
I initialize myself to represents a request line read from aStream.  If no valid request line can be found, I throw an exception."

	self skipLeadingBlankLinesIn: aSwazooStream.
	method := (aSwazooStream upTo: Character space asInteger) asString.
	self parseURIFrom: aSwazooStream.
	self parseHTTPVersionFrom: aSwazooStream.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPRequestLine class
	instanceVariableNames: ''!

!HTTPRequestLine class methodsFor: 'instance creation' stamp: 'janko 7/26/2008 18:42'!
readFrom: aSwazooStream 
	^self new readFrom: aSwazooStream! !


HTTPMessage subclass: #HTTPResponse
	instanceVariableNames: 'statusCode statusText'
	classVariableNames: 'StatusCodes'
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

!HTTPResponse methodsFor: 'initialize-release' stamp: ' 14/4/07 23:10'!
addDateHeader
	"^self
Note that the server must have it's clock set to GMT"

	self headers addField: (HTTPDateField new date: SpTimestamp now).
	^self! !

!HTTPResponse methodsFor: 'initialize-release'!
addDefaultBody
	self entity: '<HTML>
<HEAD><TITLE>', self statusLine, '</TITLE></HEAD>
  <BODY>
   <H2>', self statusLine, '</H2>
   <P>The server experienced an error while processing this request. <BR>
   If this problem persists, please contact the webmaster.</P>
  <P>Swazoo Smalltalk Web Server</P>
  </BODY>
</HTML>'! !

!HTTPResponse methodsFor: 'initialize-release' stamp: ' 14/4/07 23:10'!
addInitialHeaders
	self addServerHeader.
	self addDateHeader! !

!HTTPResponse methodsFor: 'initialize-release' stamp: 'mivsek 12/31/2007 16:49'!
addServerHeader
	^self headers 
		addField: (HTTPServerField new productTokens: SwazooServer swazooVersion)! !


!HTTPResponse methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
addHeaderName: aNameString value: aValueString
	^self headers 
		addField: (GenericHeaderField newForFieldName: aNameString withValueFrom: aValueString)! !

!HTTPResponse methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
cacheControl: aString
	"example: 'no-store, no-cache, must-revalidate'"
	self headers addField: (HTTPCacheControlField new directives: aString).! !

!HTTPResponse methodsFor: 'accessing-headers' stamp: 'mivsek 12/31/2007 15:50'!
contentLength: anInteger
	self headers addField: (HTTPContentLengthField new contentLength: anInteger).
	^self! !

!HTTPResponse methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
contentType
	"^a String
Return the media type from my Content-Type header field."

	^self headers 
		fieldOfClass: ContentTypeField
		ifPresent: [:field | field mediaType]
		ifAbsent: ['application/octet-stream']! !

!HTTPResponse methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
contentType: aString 
	self headers addField: (ContentTypeField new mediaType: aString).
	^self! !

!HTTPResponse methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
cookie: aString 
	| newField |
	newField := HTTPSetCookieField new.
	newField addCookie: aString.
	self headers addField: newField.
	^self! !

!HTTPResponse methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
expires: aSpTimestamp  "from SPort "
	self headers addField: (HTTPExpiresField new timestamp: aSpTimestamp ).
	^self! !

!HTTPResponse methodsFor: 'accessing-headers'!
gzipEncoded
	"Content will be compressed with gzip before sending to the client"
	"Currently compression must be done manually before sending to the response. Use class methods for that"
	"http://en.wikipedia.org/wiki/HTTP_compression"
	self addHeaderName: 'Content-Encoding' value: 'gzip'! !

!HTTPResponse methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
lastModified: aSpTimestamp "from SPort "
	self headers addField: (HTTPLastModifiedField new timestamp: aSpTimestamp).
	^self! !

!HTTPResponse methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
location: aString 
	self headers addField: (HTTPLocationField new uriString: aString).
	^self! !


!HTTPResponse methodsFor: 'private-obsolete' stamp: 'jm 2/15/2011 11:17'!
code
	^self statusCode! !

!HTTPResponse methodsFor: 'private-obsolete' stamp: 'jm 2/15/2011 11:17'!
code: anInteger
	^self statusCode: anInteger! !


!HTTPResponse methodsFor: 'accessing' stamp: 'janko 7/13/2008 11:32'!
contentSize
	^self entity notNil 
		ifTrue: [self entity size] 
		ifFalse: [0]! !

!HTTPResponse methodsFor: 'accessing'!
entity
	^self body! !

!HTTPResponse methodsFor: 'accessing'!
entity: anEntity 
	self body: anEntity asByteArray "if not already"! !

!HTTPResponse methodsFor: 'accessing'!
statusCode
	^statusCode! !

!HTTPResponse methodsFor: 'accessing'!
statusLine
	^self statusCode printString, ' ', self statusText! !

!HTTPResponse methodsFor: 'accessing'!
statusText
	statusText isNil ifTrue: [^''].
	^statusText! !


!HTTPResponse methodsFor: 'private-sending' stamp: ' 14/4/07 23:10'!
crlfOn: aStream 
	aStream
		nextPut: Character cr;
		nextPut: Character lf! !

!HTTPResponse methodsFor: 'private-sending' stamp: ' 14/4/07 23:10'!
endHeaderOn: aStream 
	self crlfOn: aStream! !

!HTTPResponse methodsFor: 'private-sending' stamp: ' 14/8/07 21:49'!
printChunkedTransferEncodingOn: aStream 
	aStream nextPutAll: 'Transfer-Encoding: chunked'.
	self crlfOn: aStream! !

!HTTPResponse methodsFor: 'private-sending' stamp: 'mivsek 12/31/2007 15:52'!
printContentLengthOn: aSwazooStream 
	"it is also added to headers. It is added so late because to be printed last, 
	just before body starts"
	self contentLength: self contentSize.
	(self headers fieldNamed: 'Content-length') printOn: aSwazooStream.
	self crlfOn: aSwazooStream! !

!HTTPResponse methodsFor: 'private-sending' stamp: ' 14/4/07 23:10'!
printEntityOn: aStream 
	self entity isNil ifFalse: [aStream nextPutBytes: self entity]! !

!HTTPResponse methodsFor: 'private-sending' stamp: 'mivsek 7/22/2007 19:18'!
printHeadersOn: aSwazooStream 
	"^self
Write the headers (key-value pairs) to aStream.  The key
must be a String."

	self headers fields do: 
			[:aField | 
			aField printOn: aSwazooStream.
			self crlfOn: aSwazooStream]! !

!HTTPResponse methodsFor: 'private-sending'!
printStatusOn: aSwazooStream 
	| version |
	StatusCodes at: self statusCode ifAbsent: [self class initialize]. "if some new status codes was added           													with #postInitialize method later"
	version := (self task isNil or: [self task request isNil or: [self task request isHttp11]]) 
		ifTrue: ['HTTP/1.1 '] ifFalse: ['HTTP/1.0 '].
	aSwazooStream
		nextPutAll: version;
		nextPutAll: self statusLine.
	self crlfOn: aSwazooStream! !

!HTTPResponse methodsFor: 'private-sending' stamp: 'mivsek 12/31/2007 15:54'!
writeHeaderTo: aSwazooStream 
	self printStatusOn: aSwazooStream.
	self printHeadersOn: aSwazooStream.
	(self isStreamed and: [self shouldBeChunked])
		ifTrue: [self printChunkedTransferEncodingOn: aSwazooStream]
		ifFalse: [self printContentLengthOn: aSwazooStream].
	self endHeaderOn: aSwazooStream! !


!HTTPResponse methodsFor: 'private' stamp: ' 14/4/07 23:10'!
informConnectionClose
	self headers 
		fieldOfClass: HTTPConnectionField
		ifPresent: [:field | field setToClose]
		ifAbsent: [self headers addField: HTTPConnectionField new setToClose].
	^self! !

!HTTPResponse methodsFor: 'private'!
informConnectionKeepAlive
	self headers addField: HTTPConnectionField new setToKeepAlive.! !

!HTTPResponse methodsFor: 'private'!
setStatusText
	^self statusText: (self class statusTextForCode: self statusCode)! !

!HTTPResponse methodsFor: 'private'!
statusCode: anInteger 
	statusCode := anInteger.
	(#(200) includes: statusCode) ifFalse: [self addDefaultBody].! !

!HTTPResponse methodsFor: 'private'!
statusText: aString
	"test in status line of response"
	statusText := aString! !


!HTTPResponse methodsFor: 'testing'!
isBadRequest
	^self statusCode = 400! !

!HTTPResponse methodsFor: 'testing'!
isFound
	^self statusCode = 302! !

!HTTPResponse methodsFor: 'testing'!
isGzipEncoded
	| value |
	value := self headerValueAt: 'Content-Encoding'.
	^value notNil and: [value = 'gzip']! !

!HTTPResponse methodsFor: 'testing' stamp: 'mivsek 12/31/2007 15:51'!
isHttp10
	"we are responding by old HTTP/1.0 protocol"
	^self task request isHttp10! !

!HTTPResponse methodsFor: 'testing' stamp: 'mivsek 12/31/2007 15:51'!
isHttp11
	"we are responding by HTTP/1.1 protocol"
	^self task request isHttp11! !

!HTTPResponse methodsFor: 'testing'!
isInternalServerError
	^self statusCode = 500! !

!HTTPResponse methodsFor: 'testing'!
isMovedPermanently
	^self statusCode = 301! !

!HTTPResponse methodsFor: 'testing'!
isNotFound
	^self statusCode = 404! !

!HTTPResponse methodsFor: 'testing'!
isNotImplemented
	^self statusCode = 501! !

!HTTPResponse methodsFor: 'testing'!
isNotModified
	^self statusCode = 304! !

!HTTPResponse methodsFor: 'testing'!
isOk
	^self statusCode = 200! !

!HTTPResponse methodsFor: 'testing'!
isRedirectLink
	^self statusCode = 302! !

!HTTPResponse methodsFor: 'testing'!
isSeeOther
	^self statusCode = 303! !

!HTTPResponse methodsFor: 'testing' stamp: ' 14/8/07 21:49'!
isStreamed
	^false! !

!HTTPResponse methodsFor: 'testing'!
isUnauthorized
	^self statusCode = 401! !

!HTTPResponse methodsFor: 'testing'!
isWebSocketHandshake
	^self statusCode = 101 
		and: [self statusText = 'WebSocket Protocol Handshake'] "because default 101 is different!!"! !


!HTTPResponse methodsFor: 'sending' stamp: 'janko 7/26/2008 13:49'!
writeTo: aSwazooStream 
	self writeTo: aSwazooStream inResponseTo: nil! !

!HTTPResponse methodsFor: 'sending'!
writeTo: aSwazooStream inResponseTo: aRequest
	aSwazooStream isNil ifTrue: [ ^self ].
	[self writeHeaderTo: aSwazooStream.
	(aRequest isNil or: [ aRequest isHead not ])
		ifTrue: [ self printEntityOn: aSwazooStream ].
	aSwazooStream closeResponse]
		on: Error
		do: [:ex | "ignore" ]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPResponse class
	instanceVariableNames: ''!

!HTTPResponse class methodsFor: 'response types'!
badRequest
	^super new statusCode: 400; setStatusText! !

!HTTPResponse class methodsFor: 'response types'!
forbidden
	^super new
		statusCode: 403; setStatusText;
		entity: '<HTML>
<HEAD><TITLE>Forbidden</TITLE></HEAD>
<BODY>
<H1>403 Forbidden</H1>
<P>Access to the requested resource is forbidden.</P>
</BODY></HTML>'! !

!HTTPResponse class methodsFor: 'response types'!
found
	^super new statusCode: 302; setStatusText! !

!HTTPResponse class methodsFor: 'response types'!
internalServerError
	^super new
		statusCode: 500; setStatusText;
		entity: '<HTML>
<HEAD><TITLE>Not Found</TITLE></HEAD>
<BODY>
<H1>500 Internal Server Error</H1>
<P>The server experienced an error while processing this request.  If this problem persists, please contact the webmaster.</P>
</BODY></HTML>'! !

!HTTPResponse class methodsFor: 'response types'!
methodNotAllowed
"c.f. RFC 2616  10.4.6
   The method specified in the Request-Line is not allowed for the
   resource identified by the Request-URI. The response MUST include an
   Allow header containing a list of valid methods for the requested
   resource. "
	^super new statusCode: 405; setStatusText! !

!HTTPResponse class methodsFor: 'response types'!
movedPermanently
	^super new statusCode: 301; setStatusText! !

!HTTPResponse class methodsFor: 'response types'!
notFound
	^super new
		statusCode: 404; setStatusText;
		entity: '<HTML>
<HEAD><TITLE>Not Found</TITLE></HEAD>
<BODY>
<H1>404 Not Found</H1>
<P>The requested resource was not found on this server.</P>
</BODY></HTML>'! !

!HTTPResponse class methodsFor: 'response types'!
notImplemented
	^super new statusCode: 501; setStatusText! !

!HTTPResponse class methodsFor: 'response types'!
notModified
	^super new statusCode: 304; setStatusText! !

!HTTPResponse class methodsFor: 'response types'!
ok
	^super new statusCode: 200; setStatusText! !

!HTTPResponse class methodsFor: 'response types'!
redirectLink
	"^an HTTPResponse
Note that 302 is really the 'found' response.  This code should really be 303 (>>seeOther).  However, because many clients take 302 & 303 to be the same and because older clients don't understand 303, 302 is commonly used in this case.  See RFC 2616 10.3.4."

	^super new statusCode: 302; setStatusText! !

!HTTPResponse class methodsFor: 'response types'!
seeOther
	"^an HTTPResponse
The response to the request can be found under a different URI and SHOULD be retrieved using a GET method on that resource. This method exists primarily to allow the output of a POST-activated script to redirect the user agent to a selected resource.
See RFC 2616 10.3.4."

	^super new statusCode: 303; setStatusText! !

!HTTPResponse class methodsFor: 'response types'!
unauthorized
	^super new statusCode: 401; setStatusText! !

!HTTPResponse class methodsFor: 'response types'!
webSocketHandshake
	^super new 
		statusCode: 101;
		statusText: 'WebSocket Protocol Handshake'! !


!HTTPResponse class methodsFor: 'private-compression'!
gzipCompress: aByteStringOrArray
	| output |
	output := WriteStream on: ByteArray new.
	(self newGzipStreamOn: output)
		nextPutAll: aByteStringOrArray asByteArray;
		close.
	^output contents

"HTTPResponse gzipCompress: 'div div div' "! !

!HTTPResponse class methodsFor: 'private-compression' stamp: 'janko 8/26/2013 17:57'!
isGzipSupported
	"Does Gzip suport exists in this image?"
	"Squeak specific"
	^GZipWriteStream! !

!HTTPResponse class methodsFor: 'private-compression' stamp: 'janko 8/26/2013 17:53'!
newGzipStreamOn: anOutputStream
	"Squeak specific"
	^GZipWriteStream on: anOutputStream! !


!HTTPResponse class methodsFor: 'class initialization' stamp: ' 14/4/07 23:10'!
initialize
	"self initialize"

	StatusCodes := (Dictionary new)
				add: 100 -> 'Continue';
				add: 101 -> 'Switching Protocols';
				add: 200 -> 'OK';
				add: 201 -> 'Created';
				add: 202 -> 'Accepted';
				add: 203 -> 'Non-Authoritative Information';
				add: 204 -> 'No Content';
				add: 205 -> 'Reset Content';
				add: 206 -> 'Partial Content';
				add: 300 -> 'Multiple Choices';
				add: 301 -> 'Moved Permanently';
				add: 302 -> 'Found';
				add: 303 -> 'See Other';
				add: 304 -> 'Not Modified';
				add: 305 -> 'Use Proxy';
				add: 307 -> 'Temporary Redirect';
				add: 400 -> 'Bad Request';
				add: 401 -> 'Unauthorized';
				add: 402 -> 'Payment Required';
				add: 403 -> 'Forbidden';
				add: 404 -> 'Not Found';
				add: 405 -> 'Method Not Allowed';
				add: 406 -> 'Not Acceptable';
				add: 407 -> 'Proxy Authentication Required';
				add: 408 -> 'Request Time-out';
				add: 409 -> 'Conflict';
				add: 410 -> 'Gone';
				add: 411 -> 'Length Required';
				add: 412 -> 'Precondition Failed';
				add: 413 -> 'Request Entity Too Large';
				add: 414 -> 'Request-URI Too Large';
				add: 415 -> 'Unsupported Media Type';
				add: 416 -> 'Requested range not satisfiable';
				add: 417 -> 'Expectation Failed';
				add: 500 -> 'Internal Server Error';
				add: 501 -> 'Not Implemented';
				add: 502 -> 'Bad Gateway';
				add: 503 -> 'Service Unavailable';
				add: 504 -> 'Gateway Time-out';
				add: 505 -> 'HTTP Version not supported';
				yourself.
	self postInitialize.! !

!HTTPResponse class methodsFor: 'class initialization' stamp: ' 14/4/07 23:10'!
postInitialize
	"extend it with your own codes"! !


!HTTPResponse class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
statusTextForCode: aNumber
	^StatusCodes at: aNumber ifAbsent: ['']! !


HTTPResponse subclass: #HTTPAuthenticationChallenge
	instanceVariableNames: 'resource'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPAuthenticationChallenge class
	instanceVariableNames: ''!

!HTTPAuthenticationChallenge class methodsFor: 'instance creation'!
newForResource: aResource
	^aResource authenticationScheme = #Basic 
		ifTrue: [HTTPAuthenticationBasicChallenge newForResource: aResource]
		ifFalse: [aResource authenticationScheme = #Digest
			ifTrue: [HTTPAuthenticationDigestChallenge newForResource: aResource]
			ifFalse: [HTTPResponse unauthorized] ]! !


HTTPAuthenticationChallenge subclass: #HTTPAuthenticationBasicChallenge
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPAuthenticationBasicChallenge class
	instanceVariableNames: ''!

!HTTPAuthenticationBasicChallenge class methodsFor: 'instance creation'!
newForResource: aResource
	^self unauthorized 
		resource: aResource;
		entity: aResource unauthorizedResponsePage;
		prepareAuthenticationChallenge! !


HTTPAuthenticationChallenge subclass: #HTTPAuthenticationDigestChallenge
	instanceVariableNames: 'nonce opaque'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPAuthenticationDigestChallenge class
	instanceVariableNames: ''!

!HTTPAuthenticationDigestChallenge class methodsFor: 'instance creation'!
newForResource: aResource
	^self unauthorized 
		resource: aResource;
		entity: aResource unauthorizedResponsePage;
		prepareAuthenticationChallenge! !


HTTPResponse subclass: #HTTPStreamedResponse
	instanceVariableNames: 'stream count length state semaphore compressed gzStream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!
!HTTPStreamedResponse commentStamp: 'mivsek 12/31/2007 15:41' prior: 0!
HTTPStreamedResponse 

HTTP/1.1 	no length   	chunked
HTTP/1.1	length		streamed directly, with contentLength
HTTP/1.0	no length   	simulated streaming: into entity first, then sent as normal response (not yet impl.)
HTTP/1.0  	length 		streamed directly, with content length

Instance Variables:
	stream		<SwazooStream> where to stream a response
	count		<Integer> 		how many bytes already streamed
	length		<Integer>		announced length of response, optional
	state		<Symbol>		#header #streaming #closed			
	semaphore	<Semaphore>	to signal end of response

!


!HTTPStreamedResponse methodsFor: 'initialize-release'!
close
	"mandatory!! It signals that streaming is finished and response can end"
	(self isCompressed and: [self gzStream notNil]) ifTrue: 
		[self gzStream flush]. 
	self testForUnderflow. "if streamed but not chunked: all data sent?"
	self stream ifNotNil: 
		[self stream closeResponse].
	(self isCompressed and: [self gzStream notNil]) ifTrue: 
		[self gzStream close. 
		self nilGzStream].
	self setClosed.
	self stream: nil. "to avoid unintential writing"
	self task: nil.
	self semaphore signal. "to signal close to all waiting processes"! !

!HTTPStreamedResponse methodsFor: 'initialize-release' stamp: 'mivsek 12/31/2007 15:34'!
initSemaphore
	semaphore := Semaphore new! !

!HTTPStreamedResponse methodsFor: 'initialize-release' stamp: ' 14/8/07 21:49'!
initialize
	self setHeader! !


!HTTPStreamedResponse methodsFor: 'accessing' stamp: 'mivsek 12/31/2007 15:35'!
contentSize
	self length notNil ifTrue: [^self length].
	self entity notNil ifTrue: [self entity size].
	^nil! !

!HTTPStreamedResponse methodsFor: 'accessing' stamp: 'mivsek 12/31/2007 15:35'!
count
	"how many bytes already streamed"
	count isNil ifTrue: [self count: 0].
	^count! !

!HTTPStreamedResponse methodsFor: 'accessing' stamp: 'mivsek 12/31/2007 15:36'!
length
	"how many bytes response is expected to have. 
	This is optional, if set before streaming begin, then we stream without chunking (and 
	therefore we can stream on HTTP 1.0 !!)"
	^length! !

!HTTPStreamedResponse methodsFor: 'accessing' stamp: 'mivsek 12/31/2007 15:36'!
length: aNumber
	length := aNumber! !


!HTTPStreamedResponse methodsFor: 'private' stamp: 'mivsek 12/31/2007 15:38'!
count: aNumber
	count := aNumber! !

!HTTPStreamedResponse methodsFor: 'private' stamp: 'mivsek 12/31/2007 15:39'!
semaphore
	"semahore to signal end of streaming = all data sent"
	semaphore isNil ifTrue: [self initSemaphore].
	^semaphore! !

!HTTPStreamedResponse methodsFor: 'private' stamp: 'mivsek 12/31/2007 15:39'!
sendHeaderAndStartStreaming
	self shouldSimulateStreaming 
		ifTrue: [self error: 'simulated streaming not yet implemented!!'].
	self writeHeaderTo: self stream.
	self stream flush. "to push sending of header immediately"
	self shouldBeChunked ifTrue: [self stream setChunked]. 
	self setStreaming.! !

!HTTPStreamedResponse methodsFor: 'private' stamp: ' 14/8/07 21:49'!
stream
	^stream! !

!HTTPStreamedResponse methodsFor: 'private' stamp: ' 14/8/07 21:49'!
stream: aSwazooStream
	stream := aSwazooStream! !

!HTTPStreamedResponse methodsFor: 'private' stamp: 'mivsek 12/31/2007 15:40'!
testForOverflow
	"if streaming but not chunking, then count must never be larger than announced length"
	(self length notNil and: [self count > self length]) 
		ifTrue: [self error: 'streaming overflow']! !

!HTTPStreamedResponse methodsFor: 'private' stamp: 'mivsek 12/31/2007 15:40'!
testForUnderflow
	"if streaming but not chunking, then count must be exactly the announced 
	length at the end"
	(self length notNil and: [self count ~= self length]) 
		ifTrue: [self error: 'not enough data streamed ']! !


!HTTPStreamedResponse methodsFor: 'private-compression'!
dontCompress
	"disable gzip compressing the stream"
	compressed := false! !

!HTTPStreamedResponse methodsFor: 'private-compression'!
enableCompression
	"enable gzip compressing the stream"
	compressed := true! !

!HTTPStreamedResponse methodsFor: 'private-compression'!
gzStream
	"GZipWriteStream for gzip compressing"
	^gzStream! !

!HTTPStreamedResponse methodsFor: 'private-compression'!
gzipEncoded
	"Stream will be compressed with gzip before sending to the client"
	"http://en.wikipedia.org/wiki/HTTP_compression"
	super gzipEncoded.
	self enableCompression! !

!HTTPStreamedResponse methodsFor: 'private-compression'!
initGzipStream
	"GZipWriteStream for gzip compressing"
	gzStream := HTTPResponse newGzipStreamOn: self stream.! !

!HTTPStreamedResponse methodsFor: 'private-compression'!
nilGzStream
	gzStream := nil! !


!HTTPStreamedResponse methodsFor: 'accessing-stream'!
flush
	"force sending to a TCP socket"
"	self isCompressed ifTrue: [self gzStream flush]. "
	self stream flush! !

!HTTPStreamedResponse methodsFor: 'accessing-stream'!
nextPut: aCharacterOrByte
	self isHeader ifTrue: [self sendHeaderAndStartStreaming].
	self count: self count + 1.
	self testForOverflow.
	self isCompressed
		ifTrue: 
			[gzStream ifNil: [self initGzipStream]. 
			self gzStream nextPut: aCharacterOrByte asInteger]
		ifFalse: 
			[self stream nextPut: aCharacterOrByte].
	^aCharacterOrByte! !

!HTTPStreamedResponse methodsFor: 'accessing-stream'!
nextPutAll: aByteStringOrArray
	self isHeader ifTrue: [self sendHeaderAndStartStreaming].
	self count: self count + aByteStringOrArray size.
	self testForOverflow.
	self isCompressed
		ifTrue: 
			[gzStream ifNil: [self initGzipStream].  
			self gzStream nextPutAll: aByteStringOrArray asByteArray]
		ifFalse: 
			[self stream nextPutAll: aByteStringOrArray].
	^aByteStringOrArray! !


!HTTPStreamedResponse methodsFor: 'private-state' stamp: ' 14/8/07 21:49'!
isClosed
	"is response closed?. No streaming or anything else possible anymore"
	^state = #closed! !

!HTTPStreamedResponse methodsFor: 'private-state' stamp: ' 14/8/07 21:49'!
isHeader
	"is response in header state?. this is initial one"
	^state = #header! !

!HTTPStreamedResponse methodsFor: 'private-state' stamp: ' 14/8/07 21:49'!
isStreaming
	"is response in streaming state? All nextPut to stream is sent in chunked format to browser"
	^state = #streaming! !

!HTTPStreamedResponse methodsFor: 'private-state' stamp: ' 14/8/07 21:49'!
setClosed
	"response is closed. No streaming or anything else possible anymore"
	state := #closed! !

!HTTPStreamedResponse methodsFor: 'private-state' stamp: ' 14/8/07 21:49'!
setHeader
	"response in header state. this is initial one"
	state := #header! !

!HTTPStreamedResponse methodsFor: 'private-state' stamp: ' 14/8/07 21:49'!
setStreaming
	"response in streaming state. All nextPut to stream is sent in chunked format to browser"
	state := #streaming! !


!HTTPStreamedResponse methodsFor: 'testing'!
isCompressed
	"gzip compressing the stream. Every nextPut: or nextPutAll: goes through gzipWriteStream, then to the client"
	^compressed notNil and: [compressed]! !

!HTTPStreamedResponse methodsFor: 'testing' stamp: ' 14/8/07 21:49'!
isStreamed
	^true! !

!HTTPStreamedResponse methodsFor: 'testing' stamp: 'mivsek 12/31/2007 15:37'!
shouldBeChunked
	^self isHttp11 and: [self length isNil]! !

!HTTPStreamedResponse methodsFor: 'testing' stamp: 'mivsek 12/31/2007 15:37'!
shouldSimulateStreaming
	"stream to entity first then send all at once (because only now we 
	know the length of response)"
	^self isHttp10 and: [self length isNil]! !


!HTTPStreamedResponse methodsFor: 'waiting' stamp: 'mivsek 12/31/2007 15:38'!
waitClose
	"wait until all data is sent-streamed out and response is closed"
	^self semaphore wait! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPStreamedResponse class
	instanceVariableNames: ''!

!HTTPStreamedResponse class methodsFor: 'instance creation' stamp: 'janko 3/16/2008 14:19'!
on: aSwazooTask stream: aSwazooStream
	^super ok
		task: aSwazooTask;
		stream: aSwazooStream;
		initialize! !


HTTPRequest subclass: #HTTPTrace
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!
!HTTPTrace commentStamp: '<historical>' prior: 0!
HTTPTrace 

rfc26216 section 9.8

   The TRACE method is used to invoke a remote, application-layer loop-
   back of the request message. The final recipient of the request
   SHOULD reflect the message received back to the client as the
   entity-body of a 200 (OK) response
!


!HTTPTrace methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isTrace
	^true! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPTrace class
	instanceVariableNames: ''!

!HTTPTrace class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
methodName
	^'TRACE'! !


Object subclass: #MimeObject
	instanceVariableNames: 'contentType value'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

!MimeObject methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
contentType
	^contentType isNil ifTrue: [self defaultContentType] ifFalse: [contentType]! !

!MimeObject methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
contentType: anObject
	contentType := anObject! !

!MimeObject methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
value
	^value! !

!MimeObject methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
value: anObject
	value := anObject! !


!MimeObject methodsFor: 'private-accessing' stamp: ' 14/4/07 23:10'!
defaultContentType
	^'application/octet-stream'! !


MimeObject subclass: #HTTPPostDatum
	instanceVariableNames: 'filename writeStream writeBlock'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

!HTTPPostDatum methodsFor: 'private-accessing' stamp: ' 14/4/07 23:10'!
defaultContentType
	^'text/plain'! !


!HTTPPostDatum methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
filename
	^filename! !

!HTTPPostDatum methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
filename: aString
	filename := aString! !

!HTTPPostDatum methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
filenameWithoutPath
	"M$ Internet Explorer includes full path in filename of uploaded file!! "
	self filename isNil ifTrue: [^nil].
	^(self filename includes: $\ ) 
		ifTrue: [self filename copyFrom: (self filename lastIndexOf: $\ )+1 to: self filename size]
		ifFalse: [self filename]! !

!HTTPPostDatum methodsFor: 'accessing' stamp: 'mivsek 7/24/2007 21:03'!
writeBlock
	^writeBlock! !

!HTTPPostDatum methodsFor: 'accessing' stamp: 'mivsek 7/24/2007 21:03'!
writeBlock: aBlockClosure
	"this block will be called just before start of streaming to writeStream. It can be used to 
	open the writeStream, because on that time we already know the filename of uploaded file. 
	As a parameter this postDatum is sent"
	writeBlock := aBlockClosure! !

!HTTPPostDatum methodsFor: 'accessing' stamp: 'mivsek 7/20/2007 23:44'!
writeStream
	^writeStream! !

!HTTPPostDatum methodsFor: 'accessing' stamp: 'mivsek 7/20/2007 23:44'!
writeStream: aWriteStream
	"a binary stream where to put directly a post data"
	writeStream := aWriteStream! !


!HTTPPostDatum methodsFor: 'testing' stamp: 'mivsek 7/24/2007 21:04'!
isStreamed
	"this postDatum is streamed - it has an output stream to receive data into or a block 
	which will set it"
	^self writeStream notNil or: [self writeBlock notNil]! !


Object subclass: #SwazooAuthNonce
	instanceVariableNames: 'timestamp secret'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooAuthNonce class
	instanceVariableNames: ''!

!SwazooAuthNonce class methodsFor: 'instance creation'!
new
	^super new initialize! !


Object subclass: #SwazooMD5Digest
	instanceVariableNames: 'timestamp secret'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooMD5Digest class
	instanceVariableNames: ''!

!SwazooMD5Digest class methodsFor: 'hashing for rfc2617'!
a1FromUsername: aUsername realm: aRealm password: aPassword
	"rfc2617 3.2.2.2 , algorithm directive unspecified	
	A1= unq(username-value) : unq(realm-value) : passwd"
	^aUsername trimSeparators, ':', aRealm trimSeparators, ':', aPassword trimSeparators! !

!SwazooMD5Digest class methodsFor: 'hashing for rfc2617'!
a2FromMethod: aMethod digestUri: anUri
	"rfc2617 3.2.2.3 , qop directive unspecified	
	A2  = Method : digest-uri-value"
	^aMethod trimSeparators, ':', anUri trimSeparators! !

!SwazooMD5Digest class methodsFor: 'hashing for rfc2617'!
requestDigestFromMethod: aMethod uri: anUri nonce: aNonce username: aUsername realm: aRealm password: aPassword
	"rfc2617 3.2.2.1 , qop directive not present	
	request-digest  =  KD ( H(A1), unq(nonce-value) : H(A2) )"
	| a1 a2 |
	a1 := self a1FromUsername: aUsername realm: aRealm password: aPassword.
	a2 := self a2FromMethod: aMethod digestUri: anUri.
 	^self hash: ((self hash: a1), ':', aNonce trimSeparators, ':', (self hash: a2))

"MD5Digest requestDigestFromMethod: 'Digest'
	uri: 'http://www.nowhere.org/dir/index.html' nonce: 'dcd98b7102dd2f0e8b11d0f600bfb0c093'
	username: 'Musafa' realm: 'testrealm@host.com' password: 'Circle Of Life'
"! !


!SwazooMD5Digest class methodsFor: 'hashing-md5'!
hash: aString
	"return a 128bit digest as 32 char hex string, see rfc2617 3.1.3 "
	"MD5Digest hash: '1234' "
	| hash |
	hash := Security.MD5 hash: aString asByteArray.
	^hash asHexString asLowercase.! !


Object subclass: #SwazooTask
	instanceVariableNames: 'connection request response'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Messages'!
!SwazooTask commentStamp: '<historical>' prior: 0!
A SwazooTask is simply a request-response pair.  This class just makes the task (ha!!) of dealing with requests and responses a bit easier.!


!SwazooTask methodsFor: 'accessing' stamp: 'mivsek 12/31/2007 15:31'!
connection
	^connection! !

!SwazooTask methodsFor: 'accessing' stamp: 'mivsek 12/31/2007 15:31'!
connection: aHTTPConnection
	connection := aHTTPConnection! !

!SwazooTask methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
request
	^request! !

!SwazooTask methodsFor: 'accessing'!
request: aHTTPRequest
	aHTTPRequest ifNil: [^request := nil].
	request := aHTTPRequest.
	aHTTPRequest task: self.! !

!SwazooTask methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
response
	^response! !

!SwazooTask methodsFor: 'accessing' stamp: 'janko 7/26/2008 13:50'!
response: aHTTPResponse
	response := aHTTPResponse.
	aHTTPResponse notNil ifTrue: [aHTTPResponse task: self].! !


!SwazooTask methodsFor: 'initialize-release' stamp: 'jmivsek 4/26/2020 18:54'!
nilInstvars
	"for faster GC"
	self connection: nil.
	self request notNil ifTrue:
		[self request task: nil.
		self request: nil].
	self response notNil ifTrue:
		[self response task: nil.
		self response: nil].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooTask class
	instanceVariableNames: ''!

!SwazooTask class methodsFor: 'instance creation' stamp: 'mivsek 12/31/2007 15:31'!
newOn: aHTTPConnection
	^super new connection: aHTTPConnection! !

HTTPResponse initialize!