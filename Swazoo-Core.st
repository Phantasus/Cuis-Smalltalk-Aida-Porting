Object subclass: #SwazooResource
	instanceVariableNames: 'enabled uriPattern parent'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Core'!
!SwazooResource commentStamp: 'JM 6/6/2007 13:49' prior: 0!
Resource is an abstract class for all so called web resources. Such resource has its url address and can serve with responding to web requests. Every resource need to #answerTo: aHTTPRequest with aHTTPResponse. Site is a subclass of a Resource. You can subclass it with your own implementation. There is also a CompositeResource, which can hold many subresources. Site is also aCopmpositeResource and therefore you can add your own resources to your site.!


!SwazooResource methodsFor: 'serving' stamp: ' 14/4/07 23:09'!
answerTo: aRequest
	"override in your Resource and return a HTTPResponse"
	^nil! !


!SwazooResource methodsFor: 'authentication' stamp: ' 14/4/07 23:09'!
authenticationRealm
	"rfc2617 3.2.1: A string to be displayed to users so they know which username and
     password to use. This string should contain at least the name of
     the host performing the authentication and might additionally
     indicate the collection of users who might have access. An example
     might be 'registered_users@gotham.news.com' "
	^'Swazoo server'! !

!SwazooResource methodsFor: 'authentication' stamp: ' 14/4/07 23:09'!
authenticationScheme
	"#Basic or #Digest, see rfc2617. Digest is recomended because password
	goes encrypted to server"
	^#Digest! !

!SwazooResource methodsFor: 'authentication' stamp: 'JM 4/14/2007 23:25'!
unauthorizedResponse
	"Resource should call this method and return its result immediately, if request is not authorized 
	to access that resource and a HTTP authorization is needed"
"	^HTTPAuthenticationChallenge newForResource: self " ! !

!SwazooResource methodsFor: 'authentication' stamp: ' 14/4/07 23:09'!
unauthorizedResponsePage
	"Resource should override this method with it's own html message"
	^'<HTML>
  <HEAD>
    <TITLE>Authentication error</TITLE>
  </HEAD>
  <BODY>
    <H1>401 Authentication error</H1>
    <P>Bad username or password</P>
  </BODY>
</HTML>'! !


!SwazooResource methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
canAnswer
	^self isEnabled and: [self isValidlyConfigured]! !

!SwazooResource methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
isEnabled
	^enabled! !

!SwazooResource methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
isValidlyConfigured
	^self uriPattern ~= ''! !


!SwazooResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
currentUrl
	| stream |
	stream := WriteStream on: String new.
	self printUrlOn: stream.
	^stream contents! !

!SwazooResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
helpResolve: aResolution 
	^aResolution resolveLeafResource: self! !

!SwazooResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
parent
	^parent! !

!SwazooResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
printUrlOn: aWriteStream 
	self parent printUrlOn: aWriteStream.
	aWriteStream nextPutAll: self uriPattern! !

!SwazooResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
root
	^self parent isNil
		ifTrue: [self]
		ifFalse: [self parent root]! !

!SwazooResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
uriPattern
	^uriPattern! !

!SwazooResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
uriPattern: anIdentifier 
	anIdentifier notNil ifTrue: [uriPattern := anIdentifier]! !


!SwazooResource methodsFor: 'start/stop' stamp: ' 14/4/07 23:09'!
disable
	enabled := false! !

!SwazooResource methodsFor: 'start/stop' stamp: ' 14/4/07 23:09'!
enable
	enabled := true! !

!SwazooResource methodsFor: 'start/stop' stamp: ' 14/4/07 23:09'!
start! !

!SwazooResource methodsFor: 'start/stop' stamp: ' 14/4/07 23:09'!
stop! !


!SwazooResource methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
initUriPattern
	self uriPattern: ''! !

!SwazooResource methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
initialize
	self enable.
	self initUriPattern! !

!SwazooResource methodsFor: 'private-initialize' stamp: ' 14/4/07 23:09'!
onResourceCreated
	"Received after the resource has been added to its parent resource. Opportunity to perform initialization that depends on knowledge of the resource tree structure"! !


!SwazooResource methodsFor: 'private' stamp: ' 14/4/07 23:09'!
match: anIdentifier 
	^self uriPattern match: anIdentifier! !

!SwazooResource methodsFor: 'private' stamp: ' 14/4/07 23:09'!
parent: aResource
	parent := aResource! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooResource class
	instanceVariableNames: ''!

!SwazooResource class methodsFor: 'instance creation' stamp: ' 14/4/07 23:09'!
new
	^super new initialize! !

!SwazooResource class methodsFor: 'instance creation' stamp: ' 14/4/07 23:09'!
uriPattern: aString 
	^self new uriPattern: aString! !


SwazooResource subclass: #CompositeResource
	instanceVariableNames: 'children'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Core'!

!CompositeResource methodsFor: 'adding/removing' stamp: ' 14/4/07 23:09'!
addResource: aResource
	self children add: aResource.
	aResource parent: self.
	aResource onResourceCreated.
	^aResource! !

!CompositeResource methodsFor: 'adding/removing' stamp: ' 14/4/07 23:09'!
addResources: anOrderedCollection
	anOrderedCollection do: [ :each |
		self addResource: each].
	^anOrderedCollection! !

!CompositeResource methodsFor: 'adding/removing' stamp: ' 14/4/07 23:09'!
removeResource: aResource
	self children remove: aResource ifAbsent: [nil]! !


!CompositeResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
children
	children isNil ifTrue: [self initChildren].
	^children! !

!CompositeResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
currentUrl
	| string |
	string := super currentUrl.
	^string last = $/
		ifTrue: [string]
		ifFalse: [string , '/']! !

!CompositeResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
helpResolve: aResolution 
	^aResolution resolveCompositeResource: self! !

!CompositeResource methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
printUrlOn: aWriteStream 
	super printUrlOn: aWriteStream.
	self isRootPath ifFalse: [aWriteStream nextPut: $/]! !


!CompositeResource methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
hasNoResources
	^self children isEmpty! !

!CompositeResource methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
includesResource: aResource
	^self children includes: aResource.! !

!CompositeResource methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
isRootPath
	^self uriPattern = '/'! !


!CompositeResource methodsFor: 'initialize-release' stamp: ' 14/4/07 23:09'!
initChildren
	children := OrderedCollection new.! !

!CompositeResource methodsFor: 'initialize-release' stamp: ' 14/4/07 23:09'!
initialize
	super initialize.
	self initChildren! !


Object subclass: #SwazooServer
	instanceVariableNames: 'sites servers other'
	classVariableNames: 'Singleton'
	poolDictionaries: ''
	category: 'Swazoo-Core'!
!SwazooServer commentStamp: 'mivsek 12/31/2007 16:37' prior: 0!
SwazooServer is where all begins in Swazoo!!
SwazooServer singleton : return one and only one server which holds the Sites. Also used to start and stop all sites ato once, to add new sited etc. When running, a collection of HTTPServers is also stored in SwazooServer singleton.

SwazooServer demoStart  will create and run a demo site on http://localhost:8888 which 
                              returns a web page with 'Hello World!!'!


!SwazooServer methodsFor: 'private-servers' stamp: 'jm 2/8/2009 21:36'!
addServer: aHTTPServer
	^self servers add: aHTTPServer! !

!SwazooServer methodsFor: 'private-servers' stamp: ' 14/4/07 23:09'!
newServerFor: aSiteIdentifier
	^ aSiteIdentifier newServer.! !

!SwazooServer methodsFor: 'private-servers' stamp: 'jm 2/8/2009 21:35'!
removeServer: aHTTPServer
	 ^self servers remove: aHTTPServer! !

!SwazooServer methodsFor: 'private-servers' stamp: 'mivsek 9/5/2007 23:06'!
restartServers
	"do that after image restart, because TCP sockets are probably not valid anymore"
	self servers do: [:each | each restart].! !

!SwazooServer methodsFor: 'private-servers' stamp: 'jm 2/8/2009 21:35'!
serverFor: aSiteIdentifier
	| httpServer |
	aSiteIdentifier isEmpty ifTrue: [^nil]. "in case of new one  initializing"
	^self servers 
		detect: [:each | (each ip = aSiteIdentifier ip) & (each port = aSiteIdentifier port)]
		ifNone: [
			httpServer := self newServerFor: aSiteIdentifier.
			self addServer: httpServer.
			httpServer start.
			^httpServer]! !


!SwazooServer methodsFor: 'adding/removing' stamp: 'mivsek 12/31/2007 16:22'!
addSite: aSite
	(self siteNamed: aSite name) notNil 
		ifTrue: [^SwazooSiteError error: 'Site with that name already exist!!'].
	(self siteHostnamed: aSite host) notNil 
		ifTrue: [^SwazooSiteError error: 'Site host name must be unique!!'].
	(self hasSiteHostnamed: aSite host ip: aSite ip port: aSite port) 
		ifTrue: [^SwazooSiteError error: 'Site with that host:ip:port combination already exist!!'].
	(self allowedHostIPPortFor: aSite) 
		ifFalse: [^SwazooSiteError error: 'Site with such host:ip:port combination not allowed!!'].
	self sites add: aSite! !

!SwazooServer methodsFor: 'adding/removing' stamp: ' 14/4/07 23:09'!
removeSite: aSite 
	aSite stop.
	self sites remove: aSite! !


!SwazooServer methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
allSites
	^self sites copy! !

!SwazooServer methodsFor: 'accessing' stamp: 'mivsek 12/31/2007 16:23'!
siteHostnamed: aString
	"find a site with that host name"
	| string |
	aString = '*' ifTrue: [^nil]. "what else should we return?"
	string := aString isNil ifTrue: [''] ifFalse: [aString asLowercase].
	^self sites detect: [:each | 
		each host notNil and: [each host asLowercase = string]] ifNone: [nil].! !

!SwazooServer methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
siteNamed: aString
	"find a site with that short name"
	| string |
	string := aString isNil ifTrue: [''] ifFalse: [aString asLowercase].
	^self sites detect: [:each | each name asLowercase = string] ifNone: [nil].! !


!SwazooServer methodsFor: 'private' stamp: 'mivsek 12/31/2007 16:28'!
allowedHostIPPortFor: aSite
	"is host:ip:port combination of aSite allowed regarding to existing sites?"
	"rules:
		1. host name must be unique, except if it is * (anyHost)  
		2. only one site per port can run on any host and all IP interfaces (ip = * or 0.0.0.0)
		3. if there is a site runing on all IPs, then no one can run on specific ip, per port
		4. 3 vice versa
		5. there is no site with the same host ip port combination
	"
	(self siteHostnamed: aSite host) notNil ifTrue: [^false]. 
	(aSite onAllInterfaces and: [self hasSiteOnPort: aSite port]) ifTrue: [^false].
	(aSite onAllInterfaces not and: [self hasSiteOnAllInterfacesOnPort: aSite port]) 
		ifTrue: [^false]. 
	(self hasSiteHostnamed: aSite host ip: aSite ip port: aSite port) ifTrue: [^false].
	^true! !

!SwazooServer methodsFor: 'private' stamp: 'mivsek 12/31/2007 16:28'!
hasSiteHostnamed: aHostname ip: ipString port: aNumber
	^self sites contains: [:each | 
		each host = aHostname and: [each ip = ipString and: [each port = aNumber ] ] ]! !

!SwazooServer methodsFor: 'private' stamp: 'mivsek 12/31/2007 16:28'!
hasSiteOnAllInterfacesOnPort: aNumber
	"only one site per port is allowed when listening to all interfaces"
	^self sites contains: [:each | each onAllInterfaces and: [each port = aNumber] ]! !

!SwazooServer methodsFor: 'private' stamp: 'mivsek 12/31/2007 16:30'!
hasSiteOnPort: aNumber
	^self sites contains: [:each | each port = aNumber ]! !

!SwazooServer methodsFor: 'private'!
prepareDemoSite
	"on http://localhost:8888 to return 'Hello Word' "
	"on http://localhost:8888/websocket to upgrade to WebSocket bidirectional 
	messaging (echo by default)"
	| site |
	site := SwazooDemoSite newNamed: 'swazoodemo'. "which is now also added to SwazoServer"
	site host: '*' ip: '*' port: 8888.
	^site! !

!SwazooServer methodsFor: 'private'!
prepareDemoSiteOnPort: aNumber
	"this site will run on all IP interfaces on that port, returning 'Hello Word' "
	| name site |
	name := 'port', aNumber printString.
	site := SwazooDemoSite newNamed: name. "which is now also added to SwazoServer"
	site host: '*' ip: '*' port: aNumber.
	^site! !

!SwazooServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
removeAllSites
	self sites copy do: [:each | self removeSite: each]! !

!SwazooServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
servers
	servers isNil ifTrue: [self initServers].
	^servers! !

!SwazooServer methodsFor: 'private' stamp: 'mivsek 12/31/2007 16:51'!
siteAnyHostAllInterfacesOnPort: aNumber
	"for host: * ip: * sites"
	^self sites 
		detect: [:each | each onAnyHost and: [each onAllInterfaces and: [each port = aNumber]]]
		ifNone: [nil]! !

!SwazooServer methodsFor: 'private' stamp: ' 14/4/07 23:09'!
sites
	sites isNil ifTrue: [self initSites].
	^sites! !


!SwazooServer methodsFor: 'initialize-release'!
initOther
	other := Dictionary new.! !

!SwazooServer methodsFor: 'initialize-release' stamp: ' 14/4/07 23:09'!
initServers
	servers := Set new.! !

!SwazooServer methodsFor: 'initialize-release' stamp: ' 14/4/07 23:09'!
initSites
	sites := OrderedCollection new.! !

!SwazooServer methodsFor: 'initialize-release' stamp: ' 14/4/07 23:09'!
initialize
	self initSites.
	self initServers.! !


!SwazooServer methodsFor: 'filtering'!
ipAllowedList
	"A list of IP address patterns from where access is always allowed, not to mix with ipWhitelist!! "
	"these IP patterns have kind of  'root' access, they overpass all other filters"
	^self otherAt: #ipAllowedList ifAbsentPut: [OrderedCollection new]! !

!SwazooServer methodsFor: 'filtering'!
ipBlacklist
	"A list of IP addresses to deny opening a connection"
	"A collection of strings,  also with * pattern like: '89.112.*' "
	^self otherAt: #IPBlacklist ifAbsentPut: [OrderedCollection new]! !

!SwazooServer methodsFor: 'filtering'!
ipWhitelist
	"A list of IP addresses to allow opening a connection. Other are denied"
	"A collection of strings, also with * pattern like: '89.112.*' "
	^self otherAt: #IPWhitelist ifAbsentPut: [OrderedCollection new]! !

!SwazooServer methodsFor: 'filtering'!
urlBlacklist
	"A list of absolute Url patterns (host included) to deny access - close connection immediatelly"
	"Example: 'http://www.swazoo.org/admin*' "
	^self otherAt: #UrlBlacklist ifAbsentPut: [OrderedCollection new]! !


!SwazooServer methodsFor: 'testing' stamp: 'janko 11/30/2008 22:56'!
isServing
	"any site running currently?"
	^self servers notEmpty! !


!SwazooServer methodsFor: 'private-watchdog' stamp: 'mivsek 1/10/2008 23:42'!
isWatchdogRunning
	^self watchdog notNil "and: [self watchdog is not].  ?!!?"! !

!SwazooServer methodsFor: 'private-watchdog' stamp: 'jm 2/9/2009 12:00'!
startWatchdog
	"SwazooServer singleton startWatchdog"
	self isWatchdogRunning ifTrue: [self stopWatchdog].
	self watchdog: ([ [true] whileTrue:
		[(self respondsTo: #watchdogSites) ifTrue: [self watchdogSites].
		(self respondsTo: #watchdogOther) ifTrue: [self watchdogOther]. "if any"
		(Delay forSeconds: self watchdogPeriod) wait. ]
	] forkAt: Processor lowIOPriority)! !

!SwazooServer methodsFor: 'private-watchdog' stamp: 'mivsek 1/10/2008 23:40'!
stopWatchdog
	self watchdog notNil ifTrue: 
		[self watchdog terminate.
		self watchdog: nil].! !

!SwazooServer methodsFor: 'private-watchdog'!
watchdog
	^self otherAt: #Watchdog! !

!SwazooServer methodsFor: 'private-watchdog'!
watchdog: aProcess
	^self otherAt: #Watchdog put: aProcess! !

!SwazooServer methodsFor: 'private-watchdog' stamp: 'mivsek 1/10/2008 23:41'!
watchdogPeriod
	^10  "seconds"! !

!SwazooServer methodsFor: 'private-watchdog' stamp: 'janko 8/2/2008 15:03'!
watchdogSites
	self sites do: [:each | 
		each isServing ifTrue: [each watchdogAction] ]! !


!SwazooServer methodsFor: 'private-other'!
other
	^other! !

!SwazooServer methodsFor: 'private-other'!
otherAt: aSymbol
	"other values"
	^self otherAt: aSymbol ifAbsent: [nil]! !

!SwazooServer methodsFor: 'private-other'!
otherAt: aSymbol ifAbsent: aBlock
	"other values"
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!SwazooServer methodsFor: 'private-other'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!SwazooServer methodsFor: 'private-other'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !


!SwazooServer methodsFor: 'start/stop' stamp: 'jm 2/8/2009 21:30'!
restart
	self stop; start.! !

!SwazooServer methodsFor: 'start/stop' stamp: 'janko 5/21/2008 17:55'!
start
	self sites do: [:site | site start].
	self startWatchdog.! !

!SwazooServer methodsFor: 'start/stop' stamp: 'mivsek 12/31/2007 16:24'!
startOn: aPortNumber
	"start a site on that port, on all ip interfaces and accepting all hosts.
	It also created a site if there is any site on that port yet"
	"opening http://localhost:portNumber will return a simple 'Hello world' "
	| site |
	site := self siteAnyHostAllInterfacesOnPort: aPortNumber.
	site isNil ifTrue: [site := self prepareDemoSiteOnPort: aPortNumber].
	site start.
	^site! !

!SwazooServer methodsFor: 'start/stop' stamp: 'janko 5/21/2008 18:03'!
startSite: aString
	"start site with that name"
	| site |
	site := self siteNamed: aString.
	^site notNil 
		ifTrue: [site start. self isWatchdogRunning ifFalse: [self startWatchdog]. site] 
		ifFalse: [nil]! !

!SwazooServer methodsFor: 'start/stop'!
stop
	self sites do: [:site | site stop].
	self servers do: [:server | server stop].
	self initServers.
	self stopWatchdog.
	HTTPServer allInstances do: [:each | each stop; initSites] "to be sure"! !

!SwazooServer methodsFor: 'start/stop' stamp: 'mivsek 12/31/2007 16:25'!
stopOn: aPortNumber
	"stop a site on that port, if any running on all ip interfaces and accepting all hosts"
	| site |
	site := self siteAnyHostAllInterfacesOnPort: aPortNumber.
	^site notNil ifTrue: [site stop. site] ifFalse: [nil].! !

!SwazooServer methodsFor: 'start/stop' stamp: 'mivsek 12/31/2007 16:25'!
stopSite: aString
	"stop site with that name"
	| site |
	site := self siteNamed: aString.
	^site notNil ifTrue: [site stop. site] ifFalse: [nil].! !


!SwazooServer methodsFor: '*Aida'!
aidaDemoSite
	"return aidademo site. Create and make it default, if it not yet there"
	| siteName |
	siteName := 'aidademo'.
	(self siteNamed: siteName) isNil ifTrue:
		[AIDASite newNamed: siteName.
		AIDASite default: siteName.
		(AIDASite named: siteName) host: '*' ip: '*'  port: 8888].
	^self siteNamed: siteName! !

!SwazooServer methodsFor: '*Aida'!
aidaDemoStart
	self aidaDemoSite start.! !

!SwazooServer methodsFor: '*Aida'!
aidaDemoStop
	self aidaDemoSite stop.! !

!SwazooServer methodsFor: '*Aida'!
aidaSites
	^self sites select: [:each | each isKindOf: AIDASite]! !

!SwazooServer methodsFor: '*Aida' stamp: 'mivsek 1/10/2008 22:06'!
aidaStartOn: aPortNumber
	| site |
	site := self siteAnyHostAllInterfacesOnPort: aPortNumber.
	site isNil ifTrue: [site := self prepareAidaDemoSiteOnPort: aPortNumber].
	site start.
	^site! !

!SwazooServer methodsFor: '*Aida' stamp: 'mivsek 1/10/2008 22:07'!
prepareAidaDemoSiteOnPort: aNumber
	"this site will run on all IP interfaces on that port"
	| name site |
	name := 'aidaOn', aNumber printString.
	site := AIDASite newNamed: name. "which is now also added to SwazoServer"
	site host: '*' ip: '*' port: aNumber.
	^site! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooServer class
	instanceVariableNames: ''!

!SwazooServer class methodsFor: 'config-from-file' stamp: ' 14/4/07 23:09'!
configureFrom: aFilenameString 
	| sites stream |
	self singleton removeAllSites.
	stream := aFilenameString asFilename readStream.
	[sites := self readSitesFrom: stream] ensure: [stream close].
	sites do: [:each | 
		self singleton addSite: each.
		each start]! !

!SwazooServer class methodsFor: 'config-from-file' stamp: 'JM 4/17/2007 16:33'!
exampleConfigurationFile
	"example sites.cnf, which will serve static files from current directory and respond with
	'Hello Worlrd' from url http://localhost:8888/foo/Howdy"

"<Site>
 	<SiteIdentifier ip: '127.0.0.1' port: 8888 host: 'localhost' >
 	<CompositeResource uriPattern: '/'>
  		<CompositeResource uriPattern: 'foo'>
   			<HelloWorldResource uriPattern: 'Howdy'>
  		</CompositeResource>
 	</CompositeResource>
 	<FileResource uriPattern: '/' filePath: '.'>
</Site>
"! !


!SwazooServer class methodsFor: 'start/stop' stamp: 'mivsek 12/31/2007 17:11'!
demoStart
	"on http://localhost:8888/ will return simple 'Hello World'"
	| site |
	site := self singleton siteNamed: 'swazoodemo'.
	site isNil ifTrue: [site := self singleton prepareDemoSite].
	site start! !

!SwazooServer class methodsFor: 'start/stop' stamp: 'mivsek 9/6/2007 14:04'!
demoStop
	self stopSite: 'swazoodemo'! !

!SwazooServer class methodsFor: 'start/stop' stamp: 'jm 2/8/2009 21:32'!
restart
	self stop; start! !

!SwazooServer class methodsFor: 'start/stop' stamp: ' 14/4/07 23:09'!
start
	"start all sites"
	self singleton start! !

!SwazooServer class methodsFor: 'start/stop' stamp: 'mivsek 12/31/2007 17:13'!
startOn: aPortNumber
	"start a site on that port, on all ip interfaces and accepting all hosts.
	It also created a site if there is any site on that port yet"
	^self singleton startOn: aPortNumber! !

!SwazooServer class methodsFor: 'start/stop' stamp: ' 14/4/07 23:09'!
startSite: aString
	"start site with that name"
	self singleton startSite: aString! !

!SwazooServer class methodsFor: 'start/stop' stamp: ' 14/4/07 23:09'!
stop
	"stop all sites"
	self singleton stop! !

!SwazooServer class methodsFor: 'start/stop' stamp: 'mivsek 12/31/2007 17:13'!
stopOn: aPortNumber
	"stop a site on that port, if any runingon all ip interfaces and accepting all hosts."
	^self singleton stopOn: aPortNumber! !

!SwazooServer class methodsFor: 'start/stop' stamp: ' 14/4/07 23:09'!
stopSite: aString
	"stop site with that name"
	self singleton stopSite: aString! !


!SwazooServer class methodsFor: 'private' stamp: 'JM 11/15/2007 19:15'!
initSingleton
	Singleton := super new! !

!SwazooServer class methodsFor: 'private' stamp: ' 14/4/07 23:09'!
new
	^self shouldNotImplement! !

!SwazooServer class methodsFor: 'private' stamp: 'jm 2/8/2009 13:57'!
readSitesFrom: aStream 
	| sites instance |
	sites := OrderedCollection new.
	[instance := SwazooSite new readFrom: aStream.
	instance notNil] whileTrue: [sites add: instance].
	^sites! !


!SwazooServer class methodsFor: 'initialize' stamp: 'mivsek 9/5/2007 23:06'!
initialize
	"self initialize"
	SpEnvironment addImageStartupTask: [self singleton restartServers] for: self singleton.! !


!SwazooServer class methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
singleton
	Singleton isNil ifTrue: [self initSingleton].
	^Singleton! !

!SwazooServer class methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
siteHostnamed: aString
	^self singleton siteHostnamed: aString! !

!SwazooServer class methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
siteNamed: aString
	^self singleton siteNamed: aString! !

!SwazooServer class methodsFor: 'accessing' stamp: 'jm 2/15/2011 11:16'!
swazooVersion
	^'Swazoo 2.3 Smalltalk Web Server'! !


!SwazooServer class methodsFor: '*Aida' stamp: 'np 3/15/2009 15:54'!
aidaDemoStart
	"SwazooServer aidaStart"
	"will start an Aida demo site on http://localhost:8888 "
	self singleton aidaDemoStart! !

!SwazooServer class methodsFor: '*Aida' stamp: 'np 3/15/2009 15:55'!
aidaDemoStop
	"SwazooServer aidaStop"
	self singleton aidaDemoStop! !

!SwazooServer class methodsFor: '*Aida' stamp: 'mivsek 1/10/2008 18:10'!
aidaStartOn: aPortNumber
	"will start an Aida site on all ip interfaces, ignoring host"
	"if there is no Aida site yet, it created one named 'aidademo''"
	"be sure that it is only site!!"
	"SwazooServer aidaStartOn: 8765"
	self singleton aidaStartOn: aPortNumber! !


CompositeResource subclass: #SwazooSite
	instanceVariableNames: 'name serving'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Core'!
!SwazooSite commentStamp: 'JM 6/6/2007 13:49' prior: 0!
Site : Swazoo can serve many sites at once (virtual sites). Class Site is therefore a main class to start configuring your server. It holds an IP, port and hostname of your site.!


!SwazooSite methodsFor: 'accessing' stamp: ' 10/7/07 17:21'!
addAlias: anAlias 
	self ip isNil "initial uriPattern not yet setup"
		ifTrue: [self host: anAlias host ip: anAlias ip port: anAlias port]
		ifFalse: [self uriPattern add: anAlias]! !

!SwazooSite methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
aliases
	^self uriPattern! !

!SwazooSite methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
host
	"hostname of this site. Example: www.ibm.com. 
	hostname must be unique on that server.
	Don't mix with ip, which also can be something like www.ibm.com. 
	There can be many sites with different hostnames on the same ip !! "
	self uriPattern isEmpty ifTrue: [^''].
	^self uriPattern first host! !

!SwazooSite methodsFor: 'accessing'!
host: aHostString ip: anIPString port: aNumber 
	"see comments in methods host and ip !! "
	"hostname must be unique!! "
	| site |
	site := SwazooServer singleton siteHostnamed: aHostString.
	(site notNil and: [site ~= self])
		ifTrue: [^SwazooSiteError error: 'Site with that hostname already exist!!'].
	self uriPattern isEmpty ifTrue: [self uriPattern add: SiteIdentifier new].
	self uriPattern first 
		host: aHostString ip: anIPString port: aNumber! !

!SwazooSite methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
host: aHostString port: aNumber 
	"run on all ip interfaces on specified port"
	"hostname must be unique!! "
	self host: aHostString ip: '*' port: aNumber! !

!SwazooSite methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
ip
	"IP address of this site. Swazoo can have virtual sites, that is, more than one 
	site can share the same ip and port!!
	IP can be a number or full DNS name. For example: server.ibm.com or 234.12.45.66"
	^self uriPattern first ip! !

!SwazooSite methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
name
	"a short name of that site. Example: for host www.ibm.com, name it ibm"
	name isNil ifTrue: [^''].
	^name! !

!SwazooSite methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
name: aString
	"a short name of that site. Example: for host www.ibm.com, name it ibm"
	"name must be unique"
	(SwazooServer singleton siteNamed: aString) notNil 
		ifTrue: [^SwazooSiteError error: 'Site with that name already exist!!'].
	name := aString! !

!SwazooSite methodsFor: 'accessing' stamp: ' 14/4/07 23:09'!
port
	^self uriPattern first port! !


!SwazooSite methodsFor: 'config-from-file' stamp: ' 14/4/07 23:09'!
compile: tag 
	^SwazooCompiler evaluate: tag! !

!SwazooSite methodsFor: 'config-from-file' stamp: ' 14/4/07 23:09'!
nextTagFrom: aStream 
	aStream upTo: $<.
	^aStream atEnd ifTrue: [nil] ifFalse: [aStream upTo: $>]! !

!SwazooSite methodsFor: 'config-from-file' stamp: ' 14/4/07 23:09'!
readCompositeFrom: aStream storingInto: aComposite 
	| tag |
	
	[tag := self nextTagFrom: aStream.
	tag = '/CompositeResource']
		whileFalse: 
			[| thingy |
			thingy := self compile: tag.
			aComposite addResource: thingy.
			(thingy isKindOf: CompositeResource)
				ifTrue: [self readCompositeFrom: aStream storingInto: thingy]]! !

!SwazooSite methodsFor: 'config-from-file' stamp: ' 14/4/07 23:09'!
readFrom: aStream 
	"read configuration from an XML file, see sites.cnf"
	| tag |
	tag := self nextTagFrom: aStream.
	tag isNil ifTrue: [^nil].
	tag = 'Site' ifFalse: [^SwazooSiteError error: 'invalid site specification!!'].
	[tag := self nextTagFrom: aStream.
	tag = '/Site'] 	whileFalse: 
			[| thingy |
			thingy := self compile: tag.
			(thingy isKindOf: SiteIdentifier)
				ifTrue: [self addAlias: thingy]
				ifFalse: 
					[self addResource: thingy.
					(thingy isKindOf: CompositeResource) 
						ifTrue: [self readCompositeFrom: aStream storingInto: thingy]]]! !


!SwazooSite methodsFor: 'private' stamp: ' 14/4/07 23:09'!
helpResolve: aResolution 
	^aResolution resolveSite: self! !

!SwazooSite methodsFor: 'private' stamp: ' 14/4/07 23:09'!
host: aString
	self uriPattern first host: aString! !

!SwazooSite methodsFor: 'private' stamp: ' 14/4/07 23:09'!
ip: aString
	self uriPattern first  ip: aString! !

!SwazooSite methodsFor: 'private' stamp: ' 14/4/07 23:09'!
match: aSiteIdentifier 
	self uriPattern detect: [:each | each match: aSiteIdentifier]
		ifNone: [^false].
	^true! !

!SwazooSite methodsFor: 'private' stamp: ' 14/4/07 23:09'!
port: aNumber
	self uriPattern first port: aNumber! !

!SwazooSite methodsFor: 'private' stamp: ' 14/4/07 23:09'!
printUrlOn: aWriteStream 
	self uriPattern first printUrlOn: aWriteStream! !

!SwazooSite methodsFor: 'private' stamp: ' 14/4/07 23:09'!
serving: aBoolean
	serving := aBoolean! !

!SwazooSite methodsFor: 'private' stamp: ' 14/4/07 23:09'!
uriPattern
	uriPattern isNil ifTrue: [self initUriPattern].
	^uriPattern! !

!SwazooSite methodsFor: 'private' stamp: 'janko 8/2/2008 15:01'!
watchdogAction
	"override in your subclass"! !


!SwazooSite methodsFor: 'initialize-release' stamp: 'JM 6/6/2007 11:56'!
initUriPattern
	self uriPattern: OrderedCollection new.
	self uriPattern add: SiteIdentifier new.! !

!SwazooSite methodsFor: 'initialize-release' stamp: ' 14/4/07 23:09'!
initialize
	super initialize.
	self stop. "in case you initialize working site"
	self initUriPattern! !


!SwazooSite methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
isRootPath
	^false! !

!SwazooSite methodsFor: 'testing' stamp: ' 14/4/07 23:09'!
isServing
	"is this site on-line?"
	^serving notNil and: [serving]! !

!SwazooSite methodsFor: 'testing' stamp: 'mivsek 12/31/2007 16:08'!
onAllInterfaces
	"site is running on all machine's IP interfaces"
	^self ip = '*' or: [self ip = '0.0.0.0']! !

!SwazooSite methodsFor: 'testing' stamp: 'mivsek 12/31/2007 16:08'!
onAnyHost
	"site don't care about host name during url resolution"
	^self host = '*'! !


!SwazooSite methodsFor: 'start/stop' stamp: 'jm 2/8/2009 21:44'!
start
	| swazoo |
	swazoo := SwazooServer singleton.
	[self aliases do: [:each | | httpServer |
		httpServer := swazoo serverFor: each. "it will also create and start it if needed"
		httpServer addSite: self]
	] ifCurtailed: [self stop].
	self serving: true.! !

!SwazooSite methodsFor: 'start/stop'!
stop
	| swazoo |
	self isEnabled ifFalse: [^nil].
	swazoo := SwazooServer singleton.
	self aliases do: [:each | | httpServer |
		httpServer := swazoo serverFor: each.
		(swazoo servers includes: httpServer) 
			ifTrue: 
				[httpServer removeSite: self.
				httpServer hasNoSites ifTrue: 
					[swazoo removeServer: httpServer.
					httpServer stop]]].
		self serving: false.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooSite class
	instanceVariableNames: ''!

!SwazooSite class methodsFor: 'accessing' stamp: 'JM 4/17/2007 16:38'!
named: aString
	"return a website with that name"
	^SwazooServer singleton siteNamed: aString! !


!SwazooSite class methodsFor: 'instance creation' stamp: 'JM 4/17/2007 16:38'!
newNamed: aString
	| site |
	site := self new name: aString.
	SwazooServer singleton addSite: site.
	site initialize.
	^site! !

SwazooServer initialize!