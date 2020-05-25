SwazooSite subclass: #AIDASite
	instanceVariableNames: 'style settings systemServices userServices timestamps counters other'
	classVariableNames: 'Default Dialect HourlySnapshot LastPreSnapshot LastSnapshot RandomGen SloveneCharacters'
	poolDictionaries: ''
	category: 'Aida-Core'!
!AIDASite commentStamp: '<historical>' prior: 0!
AIDASite as the most important class is an Aida/Web website with its system and user services, session and security managent, url resolving and many more. AIDASite>>answerTo: is the main entry point of requests comming to that website.!


!AIDASite methodsFor: 'private-serving' stamp: ' 21/4/07 22:07'!
addAllowHeaderTo: aHTTPResponse
	| methods |
	methods := 'OPTIONS,GET,HEAD,POST,DELETE,TRACE,'.
	methods := methods, 'PROPFIND,PROPPATCH,MKCOL,PUT,COPY,MOVE,LOCK,UNLOCK'.
	aHTTPResponse addHeaderName: 'Allow' value: methods! !

!AIDASite methodsFor: 'private-serving'!
addDontCacheHeaderTo: aHTTPResponse forPage: aWebAppOrOther
	"page won't be cached (will always reload) if requested by App or domain object"
	"also if anApp neverCache flag is set - for SPA and realtime apps etc."
	| dont |
	aWebAppOrOther isWebApplication 
		ifTrue: 
			[dont :=  aWebAppOrOther aidaDontCache or: [aWebAppOrOther neverCache].  "neverCache flag set - for realtime apps etc"
			dont ifFalse: [dont := aWebAppOrOther observee aidaDontCache] ]
		ifFalse: 
			[dont := aWebAppOrOther aidaDontCache]. 

	dont ifTrue: 
		["Transcript cr; show: '*** site adding dont cache header'."
		aHTTPResponse cacheControl: 'no-store, no-cache, must-revalidate'].! !

!AIDASite methodsFor: 'private-serving' stamp: ' 21/8/07 09:38'!
addExpiresHeaderTo: aHTTPResponse forPage: aWebPage
	| object value |
	object := aWebPage isWebApplication ifTrue: [aWebPage observee] ifFalse: [aWebPage].
	value := object expiresTimestamp.
	value isNil ifTrue: [value := aWebPage expiresTimestamp]. "WebApp subclass can set it too!! "
	value notNil ifTrue: [aHTTPResponse expires: value asSpTimestamp].! !

!AIDASite methodsFor: 'private-serving' stamp: ' 21/8/07 09:38'!
addModifiedHeaderTo: aHTTPResponse forPage: aWebPage
	| object value |
	object := aWebPage isWebApplication ifTrue: [aWebPage observee] ifFalse: [aWebPage].
	value := object modifiedTimestamp.
	value isNil ifTrue: [value := aWebPage modifiedTimestamp]. "WebApp subclass can set it too!! "
	value notNil ifTrue: [aHTTPResponse lastModified: value asSpTimestamp].! !

!AIDASite methodsFor: 'private-serving'!
addResponseHeadersTo: aHTTPResponse forPage: aWebAppOrOther on: aWebSession
	"use observee in app to find timestamps, because observee points 
	to right version of an object!! "
	| object |
	object := aWebAppOrOther isWebApplication 
		ifTrue: [aWebAppOrOther observee] 
		ifFalse: [aWebAppOrOther].
	aHTTPResponse contentType: object aidaContentType.
	(self mimeMap isTextType: object aidaContentType) ifTrue:
		[(aHTTPResponse  headerAt: #'Content-Type' ifAbsent: []) charset: 'utf-8'].
	self addModifiedHeaderTo: aHTTPResponse forPage: aWebAppOrOther.
	self addExpiresHeaderTo: aHTTPResponse forPage: aWebAppOrOther.
	self addDontCacheHeaderTo: aHTTPResponse forPage: aWebAppOrOther. "if don't cache page is requested"
"	self addUACompatibleHeaderTo: aHTTPResponse." "for stupid IE8 to avoid manual checking Compatibility view"
	aWebSession cookie ifFalse: 
		[aHTTPResponse cookie: (self cookieHeaderFor: aWebSession)].! !

!AIDASite methodsFor: 'private-serving'!
addUACompatibleHeaderTo: aHTTPResponse
	"For stupid Microsoft's IE8 to avoid users manually check Page->Compatibility view"
	aHTTPResponse addHeaderName: 'X-UA-Compatible' value: 'IE=EmulateIE7'! !

!AIDASite methodsFor: 'private-serving' stamp: ' 21/4/07 22:07'!
addressTextFor: anIPAddress

	^((anIPAddress hostAddress at: 1) printString, '.',
	(anIPAddress hostAddress at: 2) printString, '.',
	(anIPAddress hostAddress at: 3) printString, '.',
	(anIPAddress hostAddress at: 4) printString)! !

!AIDASite methodsFor: 'private-serving'!
cookieHeaderFor: aSession 
	"set a permanent cookie on client (up to year 2040, enough?) "
	^(WriteStream on: String new)
		nextPutAll: self cookieName;
		nextPutAll: '=';
		nextPutAll: aSession id printString;
		nextPutAll: '; path=/; expires=Friday, 01-Jan-2040 01:00:00 GMT; HttpOnly'; 
			"HttpOnly to prevent session hijacking by malicious JS scripts like in XSS attacs"
		contents! !

!AIDASite methodsFor: 'private-serving' stamp: ' 21/4/07 22:07'!
cookieName
	"this is the name for our cookie. It shold be unique, so it is a bit strange"
	^'aida9357'! !

!AIDASite methodsFor: 'private-serving'!
finalizeExecutingRequest: aRequest
	"do all necessary cleanup in execution context"
	aRequest context isNil ifTrue: [^nil].
	aRequest context finalizeExecutionOf: aRequest! !

!AIDASite methodsFor: 'private-serving' stamp: ' 21/4/07 22:07'!
helpResolve: aResolution 
	(self canAnswer and: [aResolution siteMatch: self]) ifFalse: [^nil].
	^self answerTo: aResolution request! !

!AIDASite methodsFor: 'private-serving'!
httpResponseOnException: anException
	| response |
	response := HTTPResponse internalServerError.
	response entity: '
<HTML>
<HEAD><TITLE>', response statusText, '</TITLE></HEAD>
  <BODY>
   <H2>', response statusLine, '</H2>
   <P>The server experienced an error while processing this request. <BR>
   If this problem persists, please contact the webmaster.</P>
  <P>Error description:</P>
  <P>', anException messageText, '</P>
  <P>Stack:</P>
  <P>', 
	((DebuggerService shortStackFor: anException initialContext ofSize: 30
		"on: Error do: [:ex | ex messageText]")
			copyReplaceAll: (String with: Character cr) with: '<BR>')
, '</P>
  </BODY>
</HTML>'.
	^response! !

!AIDASite methodsFor: 'private-serving'!
lastAnnouncementTimestamp
	"time and date of last announcement"
	^self timestamps 
		at: #LastAnnouncement
		ifAbsentPut: [SpTimestamp now]! !

!AIDASite methodsFor: 'private-serving'!
log: aString
	self diagnostics ifTrue: [Transcript show: aString].! !

!AIDASite methodsFor: 'private-serving'!
logRequest: aRequest
	| text |
	self diagnostics ifFalse: [^nil].
	text := self name, ' ',
 		Date today dayOfMonth printString, '.',
		Date today monthIndex printString, ' ',
		Time now hours printString, ':', 
		Time now minutes printString,
		' from ', aRequest realPeerIp, ' ',
		aRequest methodName, ' ',
		aRequest uri printString.
	self log: self cr, text, self cr, text, '              s'.! !

!AIDASite methodsFor: 'private-serving' stamp: ' 21/4/07 22:07'!
logStringFor: aRequest
	^self name, ' ',
 		Date today dayOfMonth printString, '.',
		Date today monthIndex printString, ' ',
		Time now hours printString, ':', 
		Time now minutes printString,
		' from ', (aRequest peer notNil ifTrue: [aRequest peer] ifFalse: ['']), ' url: ',
		aRequest urlString! !

!AIDASite methodsFor: 'private-serving' stamp: ' 21/8/07 09:38'!
properString: aString 
	"if two byte string, convert it to one byte, cut twobyte characters, make them $? "
	| stream |
	aString class == ByteString ifTrue: [^aString].
	stream := WriteStream on: String new.
	aString 
		do: [:char | stream nextPut: (char asInteger < 256 ifTrue: [char] ifFalse: [$?])].
	^stream contents! !

!AIDASite methodsFor: 'private-serving' stamp: 'jm 8/2/2010 16:18'!
redirectOn: aSession
	"Squeak specific!! "
	| location response |
	location := aSession redirectLink composeURLOn: aSession.
	location := AIDASite convert: location toCodepage: aSession codePage.
	location := location notNil 
		ifTrue: [location copyReplaceAll: '&amp;' with: '&'] "well, why exactly?"
		ifFalse: [''].
	response := HTTPResponse redirectLink "Squeak specific!! "
		location: location.
	aSession cookie ifFalse: [response cookie: (self cookieHeaderFor: aSession)].
	aSession redirectLink: nil.
	^response.! !

!AIDASite methodsFor: 'private-serving'!
redirectToOtherHost: aRequest on: aSession
	| response |
	response := HTTPResponse redirectLink 
		location: self redirectToHost.
	aSession cookie ifFalse:  "if immediate redirect on a new session"
		[response cookie: (self cookieHeaderFor: aSession)].
	^response.! !

!AIDASite methodsFor: 'private-serving'!
setLastAnnouncementTimestamp
	"time and date of last announcement"
	self timestamps 
		at: #LastAnnouncement
		put: SpTimestamp now! !

!AIDASite methodsFor: 'private-serving' stamp: ' 21/4/07 22:07'!
shouldRedirect
	^self redirectToHost notNil! !


!AIDASite methodsFor: 'system services' stamp: 'np 3/16/2009 12:30'!
addSystemService: aServiceObject named: aSymbol 
	"add a new system service (e.g URLResolver) to the dictionary of services"
	^self systemServices
		at: aSymbol asSymbol put: aServiceObject! !

!AIDASite methodsFor: 'system services'!
admin
	^self systemServices 
		at: #Admin
		ifAbsent: 
			[self addSystemService: (WebAdmin new) named: #Admin.
			self register: self admin onUrl: '/admin'.
			^self admin].! !

!AIDASite methodsFor: 'system services'!
authenticator
	"a plugable authentication of users during login"
	^self systemServices 
		at: #Authenticator
		ifAbsent: [self setDefaultAuthenticator].! !

!AIDASite methodsFor: 'system services'!
cache
	"a global cache of presentations of domain objects, if they are cached"
	^self systemServices 
		at: #Cache
		ifAbsent: 
			[self 
				addSystemService: (WebCache newOn: self) 
				named: #Cache.
			^self cache].! !

!AIDASite methodsFor: 'system services'!
dependencies
	"to announce change of domain objects to web elements presenting it"
	^self systemServices 
		at: #Dependencies
		ifAbsent: 
			[self 
				addSystemService: (AidaDependencies newOn: self) 
				named: #Dependencies.
			^self dependencies].! !

!AIDASite methodsFor: 'system services' stamp: 'janko 4/20/2012 17:13'!
federatedAuthenticator
	"a federated plugable authentication (OpenID) of users during login. It can be used in 
	parallel with #authenticator"
	^self systemServices 
		at: #FederatedAuthenticator
		ifAbsent: [self setDefaultFederatedAuthenticator]. "OpenID"! !

!AIDASite methodsFor: 'system services'!
federatedAuthorizator
	"a federated plugable authorization support (OAuth)r"
	^self systemServices 
		at: #FederatedAuthorizator
		ifAbsent: [self setDefaultFederatedAuthorizator]. "OAuth, including in URLResolver on /authorizator"! !

!AIDASite methodsFor: 'system services'!
frameApp
	"a FrameApp standdalone App for framing external content into IFRAME"
	^self systemServices 
		at: #FrameApp
		ifAbsent: 
			[self addSystemService: FrameApp named: #FrameApp.
			self register: self frameApp onUrl: '/frame'.
			^self frameApp].! !

!AIDASite methodsFor: 'system services'!
group
	"group of AIDASites for cross authentication and cross access"
	^self systemServices 
		at: #AidaGroup
		ifAbsent: 
			[self addSystemService: (AidaGroup newOn: self) named: #AidaGroup.
			^self group].! !

!AIDASite methodsFor: 'system services'!
messenger
	"for sending and receiving emails"
	^self systemServices 
		at: #Messenger
		ifAbsentPut: [EMailMessenger newOn: self].! !

!AIDASite methodsFor: 'system services' stamp: ' 21/4/07 22:07'!
mimeMap
	^self systemServices 
		at: #MimeMap
		ifAbsent: 
			[self addSystemService: MIMEMap new named: #MimeMap.
			^self mimeMap].! !

!AIDASite methodsFor: 'system services'!
registration
	"a registration app for new users to register"
	^self systemServices 
		at: #Registration
		ifAbsent: 
			[self addSystemService: WebRegistrationApp "as class!!" named: #Registration.
			self register: self registration onUrl: '/registration'.
			^self registration].! !

!AIDASite methodsFor: 'system services'!
router
	"for routing the web requests to the appropriate request handler depending on url pattern"
	^self systemServices 
		at: #Router
		ifAbsent: [self addSystemService: (WebRouter newOn: self) named: #Router].! !

!AIDASite methodsFor: 'system services' stamp: 'jm 2/7/2011 13:23'!
scheduler
	"AIDASite allInstances do: [:each | each migrateSchedulerInSystemServices] "
	self migrateSchedulerInSystemServices. "if not already"
	^self systemServices
		at: #Scheduler
		ifAbsent:
			[self
				addSystemService: (WebScheduler newOn: self)
				named: #Scheduler]! !

!AIDASite methodsFor: 'system services'!
securityManager
	^self systemServices 
		at: #SecurityManager
		ifAbsent: 
			[self 
				addSystemService: (WebSecurityManager newOn: self)
				named: #SecurityManager.
			self register: self securityManager onUrl: '/security'.
			self securityManager initialize.
			^self securityManager].! !

!AIDASite methodsFor: 'system services' stamp: ' 21/4/07 22:07'!
sessionManager
	^self systemServices 
		at: #SessionManager
		ifAbsent: 
			[self 
				addSystemService: (WebSessionManager newOn: self)
				named: #SessionManager.
			^self sessionManager].! !

!AIDASite methodsFor: 'system services'!
staticServer
	"serving static content from files"
	^self systemServices 
		at: #StaticServer
		ifAbsent: 
			[self addSystemService: (WebStaticServer newOn: self) named: #StaticServer.
			self staticServer initialize. "to add it to router and cleanup urlResolver of files"
			self staticServer]! !

!AIDASite methodsFor: 'system services'!
statistics
	^self systemServices 
		at: #Statistics
		ifAbsent: 
			[self 
				addSystemService: (WebStatistics newOn: self)
				named: #Statistics.
			self register: self statistics onUrl: '/stats'.
			^self statistics].! !

!AIDASite methodsFor: 'system services'!
systemServiceNamed: aSymbol
	"return a system service object with a specified name"
	^self systemServices at: aSymbol asSymbol ifAbsent: [^nil]! !

!AIDASite methodsFor: 'system services' stamp: 'np 3/25/2009 15:36'!
translator
	"translation support for Apps"
	^self systemServices 
		at: #Translator
		ifAbsent: [self addSystemService: (WebTranslator newOn: self) named: #Translator].! !

!AIDASite methodsFor: 'system services' stamp: ' 21/4/07 22:07'!
urlResolver
	^self systemServices 
		at: #URLResolver
		ifAbsent: 
			[self 
				addSystemService: (URLResolver newOn: self) 
				named: #URLResolver.
			^self urlResolver].! !


!AIDASite methodsFor: 'private' stamp: ' 21/4/07 22:07'!
addToRunningHistoryCrashed: aBoolean
	"Call it at server startup (in setStartedTimestamp). It reads old timestamps (started and
	last alive) and add it to the history" 
	| array |
	array := Array new: 3.
	array
		at: 1 put: self startedTimestamp asSeconds;
		at: 2 put: self lastTimeAliveTimestamp asSeconds;
		at: 3 put: aBoolean.  "true if server crashed"
	self runningHistoryCollection add: array.! !

!AIDASite methodsFor: 'private' stamp: ' 21/4/07 22:07'!
authenticationScheme
	"#Basic or #Digest, see rfc2617. Digest is recomended because password
	goes encrypted to server"
	self securityManager hasHttpBasicAuthenticationScheme ifTrue: [^#Basic].
	self securityManager hasHttpDigestAuthenticationScheme ifTrue: [^#Digest].
	^#None! !

!AIDASite methodsFor: 'private' stamp: ' 21/4/07 22:07'!
cr
	^String with: Character cr! !

!AIDASite methodsFor: 'private' stamp: 'jm 2/7/2011 13:22'!
migrateSchedulerInSystemServices
	| scheduler |
	(self systemServices includesKey: #WebScheduler) ifTrue:
		[scheduler := self systemServices at: #WebScheduler.
		self systemServices at: #Scheduler put: scheduler.
		self systemServices removeKey: #WebScheduler].
! !

!AIDASite methodsFor: 'private'!
printString

	^'anAIDASite named: ', self name! !

!AIDASite methodsFor: 'private' stamp: ' 21/4/07 22:07'!
runningHistoryCollection
	^self timestamps at: #RunningHistory ifAbsentPut: [OrderedCollection new].! !

!AIDASite methodsFor: 'private' stamp: 'JM 4/25/2007 20:47'!
setCreatedTimestamp
	"set the server creation timestamp to current date and time."
	self timestamps 
		at: #Created put: SpTimestamp now asSeconds.! !

!AIDASite methodsFor: 'private' stamp: 'jm 8/3/2010 10:10'!
setLastCommitTimestamp
	"set the last commit timestamp to current date and time"
	self critical: [
		self timestamps 
			at: #LastCommit 
			put: SpTimestamp now asSeconds].! !

!AIDASite methodsFor: 'private' stamp: 'jm 8/3/2010 10:10'!
setLastRequestTimestamp
	"set the last web request timestamp to current date and time"
	self critical: [
		self timestamps at: #LastRequest put: SpTimestamp now asSeconds].! !

!AIDASite methodsFor: 'private'!
setLastTimeAliveTimestamp
	"A lastTimeAliveThread sets this timestamp every minute"
	self timestamps at: #LastTimeAlive put: SpTimestamp now asSeconds.! !

!AIDASite methodsFor: 'private' stamp: 'JM 4/25/2007 21:09'!
setStartedTimestampCrashed: aBoolean
	"set the last server startup timestamp to current date and time.  
	Before that records old created and last alive timestamp to a running history.
	Argument shows if server was running, therefore crashed, or was stoped normaly"
	self addToRunningHistoryCrashed: aBoolean.
	self timestamps 
		at: #Started put: SpTimestamp now asSeconds.! !

!AIDASite methodsFor: 'private'!
settings
	settings isNil ifTrue: 
		[settings := Dictionary new. 
		self initDefaultSettings].
	^settings

"WebServer default settings"! !

!AIDASite methodsFor: 'private' stamp: ' 21/4/07 22:07'!
startServices
	self systemServices values do: [:service | (service class canUnderstand: #start) ifTrue: [service start] ].
	self userServices values do: [:service | (service class canUnderstand: #start) ifTrue: [service start] ].! !

!AIDASite methodsFor: 'private' stamp: ' 21/4/07 22:07'!
stopServices
	self systemServices values do: [:service | (service class canUnderstand: #stop) ifTrue: [service stop] ].
	self userServices values do: [:service | (service class canUnderstand: #stop) ifTrue: [service stop] ].! !

!AIDASite methodsFor: 'private' stamp: ' 21/4/07 22:07'!
stopWatchdog
	self watchdog notNil ifTrue: 
		[self watchdog terminate.
		self watchdog: nil].! !

!AIDASite methodsFor: 'private'!
style: aWebStyle
	(aWebStyle isNil or: [aWebStyle isKindOf: WebStyle]) 
		ifFalse: [self error: 'Set the style with method #styleClass: instead!!'].
	style := aWebStyle.! !

!AIDASite methodsFor: 'private' stamp: ' 21/4/07 22:07'!
systemServices
	"return a dictionary of system services (e.g. URLResolver, ImageManager etc.)"
	systemServices isNil 
		ifTrue: [systemServices := Dictionary new].
	^systemServices! !

!AIDASite methodsFor: 'private' stamp: ' 21/4/07 22:07'!
timestamps
	timestamps isNil ifTrue: [self initTimestamps].
	^timestamps! !

!AIDASite methodsFor: 'private' stamp: ' 21/4/07 22:07'!
userServices
	"return a dictionary of user services (e.g. WebIndex, WebNews etc.)"
	userServices isNil ifTrue: [userServices := Dictionary new. ].
	^userServices! !

!AIDASite methodsFor: 'private' stamp: 'janko 8/2/2008 15:02'!
watchdogAction
	self setLastTimeAliveTimestamp! !


!AIDASite methodsFor: 'user services'!
addUserService: aServiceObject named: aSymbol 
	"add a new user service (e.g WebIndex) to the dictionary of services"
	self userServices
		at: aSymbol asSymbol put: aServiceObject! !

!AIDASite methodsFor: 'user services'!
demo
	^self userServices at: #WebDemo
		ifAbsent: 
			[self addUserService: WebDemo new named: #WebDemo.
			self register: self demo onUrl: '/demos'.
			^self demo]! !

!AIDASite methodsFor: 'user services'!
index
	^self userServices 
		at: #WebIndex
		ifAbsent: 
			[self addUserService: WebIndex new named: #WebIndex.
			self register: self index onUrl: '/search'.
			^self index].! !

!AIDASite methodsFor: 'user services'!
register: anObjectOrApp onUrl: anUrlString
	"for easier registration of root domain objects or Apps"
	^self urlResolver defaultUrl: anUrlString for: anObjectOrApp! !

!AIDASite methodsFor: 'user services'!
userServiceNamed: aSymbol
	"return a user service object with a specified name"
	^self userServices at: aSymbol asSymbol ifAbsent: [^nil]! !


!AIDASite methodsFor: 'settings' stamp: 'mivsek 6/13/2007 15:54'!
afterLogin
	"url of a page to jump after login or #lastPage to back to last page before logout"

	^self settings at: #afterLogin ifAbsentPut: [#lastPage]. "back to last page before logout"! !

!AIDASite methodsFor: 'settings'!
afterLogin: aStringOrSymbol
	"(AIDASite named: 'demo') afterLogin: #myPage "
	"1. url of page to jump"
	"2. #lastPage - back to a page before logout"
	"3. #myPage - to user's personal page, if exists"
	((aStringOrSymbol isKindOf: String) not and: 
		[(#(#lastPage #myPage) includes: aStringOrSymbol) not])
			ifTrue: [self error: 'wrong login argument'].
	self settings  at: #afterLogin put: aStringOrSymbol! !

!AIDASite methodsFor: 'settings' stamp: 'mivsek 1/10/2008 18:48'!
autoLogout
	"logout after 15min of inactivity. default is NO!! "
	^self settings at: #AutoLogout ifAbsent: [false]! !

!AIDASite methodsFor: 'settings'!
autoLogout: aBoolean
	"logout after 15min of inactivity"
	(aBoolean isKindOf: Boolean) ifFalse: [self error: 'wrong argument'].
	^self settings at: #AutoLogout put: aBoolean! !

!AIDASite methodsFor: 'settings'!
behindProxy
	"is this site running behind proxy, like Apache webserver, or load balancer? By default no"
	^self settings at: #BehindProxy ifAbsent: [false]! !

!AIDASite methodsFor: 'settings'!
behindProxy: aBoolean
	"is this site running behind proxy, like Apache webserver, or load balancer? By default no"
	^self settings at: #BehindProxy put: aBoolean! !

!AIDASite methodsFor: 'settings'!
cometEnabled
	"Is long-polling Comet enabled? By default no"
	^self settings at: #CometEnabled ifAbsent: [false]! !

!AIDASite methodsFor: 'settings'!
cometEnabled: aBoolean
	"Is long-polling Comet enabled? By default no"
	^self settings at: #CometEnabled put: aBoolean! !

!AIDASite methodsFor: 'settings'!
contextProcesses
	"if true, web contexts execute POSTs and Ajax requests in a separate process, to enable tree-like control flow"
	^self settings at: #contextProcesses ifAbsentPut: [false].! !

!AIDASite methodsFor: 'settings'!
contextProcesses: aBoolean
	"if true, web contexts execute POSTs and Ajax requests in a separate process, to enable tree-like control flow"
	(aBoolean isKindOf: Boolean) ifFalse: [self error: 'wrong argument'].
	self settings  at: #contextProcesses put: aBoolean.! !

!AIDASite methodsFor: 'settings' stamp: 'mivsek 1/10/2008 18:50'!
defaultLanguage
	"ISO 639 2-letter language code symbol for default language of that site"
	^self settings at: #defaultLanguage ifAbsentPut: [#en].! !

!AIDASite methodsFor: 'settings' stamp: 'mivsek 1/10/2008 18:50'!
defaultLanguage: aLanguageCodeSymbol
	"ISO 639 2-letter language code symbol for default language of that site"
	^self settings at: #defaultLanguage put: aLanguageCodeSymbol! !

!AIDASite methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
disableWebDAVSupport
	"Web Distributed Authoring and Versioning (WebDAV, www.webdav.org) is disabled on this site"
	"AIDASite default disableWebDAVSupport"
	self settings at: #WebDAVEnabled put: false! !

!AIDASite methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
enableWebDAVSupport
	"Web Distributed Authoring and Versioning (WebDAV, www.webdav.org) is enabled on this site"
	"AIDASite default enableWebDAVSupport"
	self settings at: #WebDAVEnabled put: true! !

!AIDASite methodsFor: 'settings'!
hourlySnapshotEnabled
	"Is snapshot of image every hour enabled? By default not"
	"Note that all sites on that image must have snapshot disabled so that image snapshot will be really disabled!!"
	^self settings at: #HourlySnaphotEnabled ifAbsent: [false]! !

!AIDASite methodsFor: 'settings'!
hourlySnapshotEnabled: aBoolean
	"Is snapshot of image every hour enabled? By default not"
	"Note that all sites on that image must have snapshot disabled so that image snapshot will be really disabled!!"
	^self settings at: #HourlySnaphotEnabled put: aBoolean! !

!AIDASite methodsFor: 'settings'!
internalIPs
	"A collection of public IP ranges from which requests are regarded as internal (because are NATed 
	from networks of internal IPs"
	"(AIDASite named: 'aidademo') internalIIPs add: #('193.2.253.0' '193.2.253.255')"
	^self settings at: #InternalIPs ifAbsentPut: [OrderedCollection new]! !

!AIDASite methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
isWebDAVEnabled
	"Is Web Distributed Authoring and Versioning (WebDAV, www.webdav.org) ienabled on this site"
		^(self settings includesKey: #WebDAVEnabled)
			 and: [self settings includesKey: #WebDAVEnabled]! !

!AIDASite methodsFor: 'settings' stamp: 'janko 11/24/2008 21:59'!
keywords
	"global keywords, added to all webpages generated on this site"
	^self settings  at: #keywords ifAbsent: ''
! !

!AIDASite methodsFor: 'settings' stamp: 'janko 11/24/2008 21:25'!
keywords: aString
	"global keywords, added to all webpages generated on this site"
	self settings  at: #keywords put: aString.
! !

!AIDASite methodsFor: 'settings'!
localIPs
	"A collection of IP addresses of a machine where this server runs. For easier determining a local 
       access"
	"(AIDASite named: 'aidademo') localIPs addAll: #('5.9.11.170') "
	^self settings at: #localIPs ifAbsentPut: [OrderedCollection new]! !

!AIDASite methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
redirectToHost
	"if set, all requests are redirected to that hostname!!"
	| host |
	host := self settings  at: #redirectToHost ifAbsent: [^nil].
	(host isNil or: [host isEmpty]) ifTrue: [^nil].
	^host! !

!AIDASite methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
redirectToHost: aHostnameString
	"if set, all requests are redirected to that hostname!!"
	self settings  at: #redirectToHost put: aHostnameString! !

!AIDASite methodsFor: 'settings'!
registrationAllowed
	"is registration allowed on this site? By default no"
	^self settings at: #RegistrationAllowed ifAbsent: [false]! !

!AIDASite methodsFor: 'settings'!
registrationAllowed: aBoolean
	"is registration allowed on this site? By default no"
	^self settings at: #RegistrationAllowed put: aBoolean! !

!AIDASite methodsFor: 'settings'!
securedExternally
	"is this site SSL secured by external frontend server or proxy?"
	^self settings 
		at: #SecuredExternally 
		ifAbsent: [false]! !

!AIDASite methodsFor: 'settings'!
securedExternally: aBoolean
	"is this site SSL secured by external frontend server or proxy?"
	^self 
		settings at: #SecuredExternally 
		put: aBoolean! !

!AIDASite methodsFor: 'settings'!
securedExternallySet
	"was set to true or false explicttly?"
	^self settings 
		includesKey: #SecuredExternally! !

!AIDASite methodsFor: 'settings'!
setDefaultAuthenticator
	"DefaultAuthenticator authentificates the user during login by username and password, which 
	are stored locally in site's security manager"
	^self addSystemService: (DefaultAuthenticator newOn: self) named: #Authenticator! !

!AIDASite methodsFor: 'settings' stamp: 'janko 4/20/2012 17:14'!
setDefaultFederatedAuthenticator
	"OpenID is a default federated authentificator"
	^self 
		addSystemService: (OpenIDAuthenticator newOn: self) 
		named: #FederatedAuthenticator! !

!AIDASite methodsFor: 'settings'!
setDefaultFederatedAuthorizator
	"OAuth is a default federated authorizator, accessible on /authorizator as well"
	| auth |
	auth := self 
		addSystemService: (OAuthAuthorizator newOn: self) 
		named: #FederatedAuthorizator.
	self register: auth onUrl: '/authorizator'.
	^auth! !

!AIDASite methodsFor: 'settings' stamp: 'mivsek 1/10/2008 18:55'!
smtpServer
	"an address of email server for outgoing mails (notifications, mailing lists etc.)"
	^self settings  at: #smtpServer ifAbsentPut: [self host].
! !

!AIDASite methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
smtpServer: anAddressString
	"an address of email server for outgoing mails (notifications, mailing lists etc.)"
	self settings  at: #smtpServer put: anAddressString.! !

!AIDASite methodsFor: 'settings' stamp: 'np 4/2/2008 23:36'!
styleClass
	(self settings includesKey: #styleClass) ifFalse: 
		[self styleClass: 'DefaultWebStyle' ].
	^(self settings  at: #styleClass) asString! !

!AIDASite methodsFor: 'settings'!
styleClass: aClassOrString
	"name of a class to provide a style support for this site. Default is WebStyle"
	| nme |
	nme := (aClassOrString isKindOf: String)
		ifTrue: [aClassOrString] ifFalse: [aClassOrString name asString].
	self settings  at: #styleClass put: nme.
	self style: nil.  "to initialize new style immediatelly, if possible"
	[self style] 
		on: Error do: [:ex | "nothing"].
	self router setMethodRouteStyle: self style.  "to redirect correctly requests for method images etc."! !

!AIDASite methodsFor: 'settings' stamp: 'mivsek 1/10/2008 18:56'!
supportedLanguages
	"Which languages are supported on this site. Content may be in all those languages. 
	Default language is always among supported."
	^(self settings at: #supportedLanguages ifAbsent: [Set new])
		add: self defaultLanguage; yourself! !

!AIDASite methodsFor: 'settings' stamp: 'mivsek 1/10/2008 18:57'!
supportedLanguages: aSetOfLangCodes
	"Which languages are supported on this site. Content may be in all those languages. 
	Default language is always among supported."
	^self settings at: #supportedLanguages put: aSetOfLangCodes asSet! !

!AIDASite methodsFor: 'settings' stamp: 'np 10/18/2008 13:17'!
tempDirectory
	" a directory for temporary files, usually ./temp. This directory is also created if not exist yet "
	^self settings  at: #tempDirectory ifAbsent: 
		[^self tempDirectory: self homeDirectory, 'temp']! !

!AIDASite methodsFor: 'settings' stamp: 'np 10/18/2008 13:17'!
tempDirectory: aString
	" a directory for temporary files, usually ./temp. This directory is also created if not exist yet "
	| dir |
	self settings at: #tempDirectory put: aString.
	dir := SpFilename named: self tempDirectory.
	dir exists ifFalse: [dir makeDirectory].
	^self tempDirectory! !

!AIDASite methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
urgentNotificationEMail

	"an email address or addresses (separated by comma) of all recipients of urgent server notifications "

	^self settings  at: #urgentNotificationEMail ifAbsentPut: ['janko.mivsek@eranova.si'].! !

!AIDASite methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
urgentNotificationEMail: anEMailAddressString
	"an email address or addresses (separated by comma) of all recipients of urgent server notifications "
	self settings  at: #urgentNotificationEMail put: anEMailAddressString.! !

!AIDASite methodsFor: 'settings' stamp: 'np 5/6/2008 17:18'!
urlsWithSessionId
	"is session id added to urls when browser cookie support is disabled?"
	^self settings at: #urlsWithSessionId ifAbsentPut: false! !

!AIDASite methodsFor: 'settings'!
urlsWithSessionId: aBoolean
	"is session id added to urls when browser cookie support is disabled?"
	(aBoolean isKindOf: Boolean) ifFalse: [self error: 'wrong argument'].
	^self settings at: #urlsWithSessionId put: aBoolean! !

!AIDASite methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
webServerEMail

	"an email address of this web server "

	^self settings  at: #webServerEMail ifAbsentPut: ['aida-web@eranova.si'].! !

!AIDASite methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
webServerEMail: anEMailString
	"an email address of this web server "
	self settings  at: #webServerEMail put: anEMailString.! !

!AIDASite methodsFor: 'settings'!
webSocketsEnabled
	"is site-wide WebSockets protocol for realtime web enabled? By default not"
	"Per page realtime enabling is also possible, call 'self page enableRealtime' from your web apps"
	^self settings at: #WebSocketsEnabled ifAbsent: [false]! !

!AIDASite methodsFor: 'settings'!
webSocketsEnabled: aBoolean
	"is site-wide WebSockets protocol for realtime web enabled? By default not"
	"Per page realtime enabling is also possible, call 'self page enableRealtime' from your web apps"
	^self settings at: #WebSocketsEnabled put: aBoolean! !

!AIDASite methodsFor: 'settings'!
webUserClass
	"set if other class than WebUser is used for creating/registering users"
	^self settings at: #WebUserClass ifAbsent: [WebUser]! !

!AIDASite methodsFor: 'settings'!
webUserClass: aClass
	"set if other class than WebUser is used for creating/registering users"
	^self settings at: #WebUserClass put: aClass! !


!AIDASite methodsFor: 'statistics-counters'!
allPages
	"all page requests from the server creation until now"
	^self pagesCounter total! !

!AIDASite methodsFor: 'statistics-counters'!
allPagesThisMonth
	"all page requests in current month"
	^self pagesCounter countsOnMonth: SpDate today monthIndex year: SpDate today year! !

!AIDASite methodsFor: 'statistics-counters'!
allPagesThisWeek
	"all page requests in current week"
	^self pagesCounter currentWeekCounts
		inject: 0 into: [:sum :each | sum + each]! !

!AIDASite methodsFor: 'statistics-counters'!
allPagesToday
	^self pagesCounter countsOnDate: SpDate today! !

!AIDASite methodsFor: 'statistics-counters'!
allPagesYesterday
	^self pagesCounter countsOnDate: (SpDate today subtractDays: 1)! !

!AIDASite methodsFor: 'statistics-counters' stamp: ' 21/4/07 22:07'!
hourlyStatsProcess

	"hourly report to transcript"
	"WebServer default hourlyStatsProcess"
	| hits pages new returning afterHits afterPages afterNew afterReturning |
	[
		hits := self totalCounter total.
		pages := self pagesCounter total.
		new :=	self newVisitorsCounter total.
		returning := self returningVisitorsCounter total.
		(Delay forSeconds: self secondsToHour) wait.
		[self isServing] whileTrue: 
			[afterHits := self totalCounter total.
			afterPages := self pagesCounter total.
			afterNew := self newVisitorsCounter total.
			afterReturning := self returningVisitorsCounter total.
			Transcript cr; show: '***'; cr; show:
				'***  ',  self name, ' ', 
				Time now hours printString, ':', Time now minutes printString, ' ',
				'    last hour hits: ', (afterHits - hits) printDotString, 
				'    pages: ', (afterPages - pages) printDotString, 
				'    visitors new: ', (afterNew - new) printDotString, 
				'    returning: ', (afterReturning - returning) printDotString;
				cr; show: '***'.
			self registerTopHourHits: (afterHits - hits) pages: (afterPages - pages).
			hits := afterHits. pages := afterPages.
			new := afterNew. returning := afterReturning.
			(Delay forSeconds: self secondsToHour) wait].
	] fork.! !

!AIDASite methodsFor: 'statistics-counters' stamp: ' 21/4/07 22:07'!
minuteStatsProcess

	"every minute report to transcript"
	"WebServer default minuteStatsProcess"
	| hits pages new returning afterHits afterPages afterNew afterReturning |
	[
		hits := self totalCounter total.
		pages := self pagesCounter total.
		new :=	self newVisitorsCounter total.
		returning := self returningVisitorsCounter total.
		(Delay forSeconds: self secondsToMinute) wait.
		[self isServing] whileTrue: 
			[afterHits := self totalCounter total.
			afterPages := self pagesCounter total.
			afterNew := self newVisitorsCounter total.
			afterReturning := self returningVisitorsCounter total.
			Transcript cr; show: 
				self name, ' ', 
				Time now hours printString, ':', Time now minutes printString, ' ',
				'    last minute hits: ', (afterHits - hits) printDotString, 
				'    pages: ', (afterPages - pages) printDotString, 
				'    visitors new: ', (afterNew - new) printDotString, 
				'    returning: ', (afterReturning - returning) printDotString.
			self registerTopMinuteHits: (afterHits - hits) pages: (afterPages - pages).
			hits := afterHits. pages := afterPages.
			new := afterNew. returning := afterReturning.
			(Delay forSeconds: self secondsToMinute) wait].
	] fork.! !

!AIDASite methodsFor: 'statistics-counters' stamp: ' 21/4/07 22:07'!
registerTopHourHits: aHitNumber pages: aPageNumber
	(self topHour at: 2) < aHitNumber ifTrue: 
		[self topHour
			at: 1 put: Timestamp now;
			at: 2 put: aHitNumber;
			at: 3 put: aPageNumber].! !

!AIDASite methodsFor: 'statistics-counters' stamp: ' 21/4/07 22:07'!
registerTopMinuteHits: aHitNumber pages: aPageNumber
	(self topMinute at: 2) < aHitNumber ifTrue: 
		[self topMinute
			at: 1 put: Timestamp now;
			at: 2 put: aHitNumber;
			at: 3 put: aPageNumber].! !

!AIDASite methodsFor: 'statistics-counters' stamp: ' 21/4/07 22:07'!
requestsInYear: aYearNumber
	"return a number of requests on specified year"

	| count |
	count := 0.
	((self counters at: #Daily) at: aYearNumber ifAbsent: [^0]) do: [:dayCount |
		count := count + dayCount].
	^count! !

!AIDASite methodsFor: 'statistics-counters' stamp: ' 21/4/07 22:07'!
requestsOnDate: aDate
	"return a number of requests on specified date"

	^self totalCounter countsOnDate: aDate! !

!AIDASite methodsFor: 'statistics-counters' stamp: ' 21/4/07 22:07'!
secondsToHour

	| now | 
	now := Time now asSeconds.
	^(3600 - (now - (now // 3600 * 3600))) max: 0

"WebServer default secondsToHour"! !

!AIDASite methodsFor: 'statistics-counters' stamp: ' 21/4/07 22:07'!
secondsToMinute

	| now | 
	now := Time now asSeconds.
	^(60 - (now - (now // 60 * 60))) max: 0

"WebServer default secondsToMinute"! !

!AIDASite methodsFor: 'statistics-counters' stamp: ' 21/4/07 22:07'!
totalRequests
	"return a number of requests from server creation"

	^self totalCounter total.! !


!AIDASite methodsFor: 'serving' stamp: 'mivsek 8/22/2007 11:08'!
answer: anObject to: aRequest on: aWebSession
	aRequest isGet | aRequest isPost | aRequest isHead
		ifTrue: [^self answer: anObject toGetOrPost: aRequest on: aWebSession].
	aRequest isOptions ifTrue: [^self answer: anObject toOptions: aRequest on: aWebSession].
	aRequest isPropFind ifTrue: [^self answer: anObject toPropFind: aRequest on: aWebSession].
	aRequest isLock ifTrue: [^self answer: anObject toLock: aRequest on: aWebSession].
	aRequest isUnlock ifTrue: [^self answer: anObject toUnlock: aRequest on: aWebSession].
	aRequest isPut ifTrue: [^self answer: anObject toPut: aRequest on: aWebSession].
	^HTTPException notImplemented! !

!AIDASite methodsFor: 'serving'!
answer: anObject toGetOrPost: aRequest on: aWebSession
	| presenter stream response properContent |
	(self cache isCached: anObject to: aRequest on: aWebSession)
		ifTrue: [^self cache respond: anObject to: aRequest on: aWebSession].
	[presenter := anObject aidaPresenterFor: aRequest on: aWebSession]
		ifCurtailed: [self finalizeExecutingRequest: aRequest].
	presenter isNil ifTrue:   "not found"
		[aWebSession removeIfNewGuest. ^HTTPException notFound].
	aWebSession isHttpAuthenticationNeeded "because of logout" ifTrue:  [^self unauthorizedResponse].
	(aWebSession shouldRedirect and: [aRequest isAjaxRequest not])
		ifTrue: [^self redirectOn: aWebSession].
	self log: 'h'.
	presenter aidaIsRespondingStreamed
		ifTrue: 
			[ [presenter streamHtmlTo: nil "not needed" for: aRequest on: aWebSession]
				ensure: 
					[aRequest streamedResponse close.
					self finalizeExecutingRequest: aRequest].
			self log: ' done'.
			^aRequest streamedResponse]
		ifFalse: [(false "presenter aidaIsRespondingNeverStreamed not"
					and: [aRequest isHttp11  "also stream chunked to start sending to client ASAP "
						and: [aRequest isWebSocketRequest not]])
			ifTrue: [
				response := aRequest streamedResponse.
				self addResponseHeadersTo: response forPage: presenter on: aWebSession.
				(self mimeMap isTextType: response contentType) "just set gzip encoding in header"
					ifTrue: [ " response gzipEncoded; dontCompress" "yet"].  
				response sendHeaderAndStartStreaming.
				(self mimeMap isTextType: response contentType) "now start gzip compressing into response"
					ifTrue: [ "response enableCompression" ].  
				[[presenter streamHtmlTo: response for: aRequest on: aWebSession]
					ensure: [self finalizeExecutingRequest: aRequest].
				(self cache shouldCache: anObject to: aRequest on: aWebSession)
					ifTrue: [self notYetImplemented. 
						self cache store: nil "properContent" for: anObject to: aRequest on: aWebSession].
				response close]
					on: SpSocketError
					do: [:ex | "ignore" ].
				self log: ' done'.
				^aRequest streamedResponse
				]
			ifFalse: 	"no streaming (chunking) on HTTP 1.0 or if explicitly requested not to stream "
				[response := HTTPResponse ok.
				aRequest task response: response.
				self addResponseHeadersTo: response forPage: presenter on: aWebSession.
				stream := WriteStream on: (String new: 10000).
				[presenter streamHtmlTo: stream for: aRequest on: aWebSession]
					ensure: [self finalizeExecutingRequest: aRequest].
				properContent := (AIDASite properArray: stream contents). "in case of TwoByteString"
				response entity: properContent. 
				(self cache shouldCache: anObject to: aRequest on: aWebSession)
					ifTrue: [self cache store: properContent for: anObject to: aRequest on: aWebSession].
				self log: ' done'.
				^response] ]! !

!AIDASite methodsFor: 'serving' stamp: ' 21/4/07 22:07'!
answer: anObject toLock: aRequest on: aWebSession
	"WebDAV lock request for that object"
	|  rsp |
	"Temporary!!!! just return a fake lock!!"
	rsp := Swazoo.HTTPLockResponse new.
	rsp start.
	rsp addTagName: 'locktype' value: #write.
	rsp addTagName: 'lockscope' value: #exclusive.
	rsp addTagName: 'depth' value: '0'.
	rsp addLockOwner: 'Administrator'.
	rsp addTagName: 'timeout' value: 'Second-604800'.  "one week, temporary!!"
	rsp addLockToken: 'opaquelocktoken:89001c0a-23f2-0310-b37d-c58bc335a1ff'.
	^rsp! !

!AIDASite methodsFor: 'serving' stamp: ' 21/4/07 22:07'!
answer: anObject toOptions: aRequest on: aWebSession
	| response |
	response := Swazoo.HTTPResponse ok.
	self isWebDAVEnabled ifTrue: 
	 	[response addHeaderName: 'DAV' value: '1,2'.
		"without following header Windows refuse to add new Web folder!! "
		response addHeaderName: 'MS-Author-Via' value: 'DAV'].
	self addAllowHeaderTo: response.
	^response! !

!AIDASite methodsFor: 'serving' stamp: ' 21/4/07 22:07'!
answer: anObject toPropFind: aRequest on: aWebSession
	"WebDAV properties request from object"
	|  multiResponse |
	"Temporary!!!! Now it just return empty collection, which is enough for MS web folders to add new!! "
	multiResponse := Swazoo.HTTPPropFindResponse new.
	multiResponse multiStart.
	multiResponse startResponseFor: aRequest uri value.
	multiResponse addPropertyName: 'getlastmodified' value: 'Mon, 21 Feb 2005 14:11:01 GMT'.
	aRequest uri value last = $/ ifTrue: "directory"
		[multiResponse addPropertyName: 'resourcetype' value: #collection].
	multiResponse endResponseWithStatusCode: 200.
	multiResponse multiEnd.
	^multiResponse! !

!AIDASite methodsFor: 'serving' stamp: ' 21/4/07 22:07'!
answer: anObject toPut: aRequest on: aWebSession
	"WebDAV: try to PUT content into that object"
	(anObject isKindOf: FileProxy) ifFalse: [^HTTPException forbidden].
	anObject put: aRequest putData.
	^HTTPResponse ok! !

!AIDASite methodsFor: 'serving' stamp: 'JM 4/21/2007 22:20'!
answer: anObject toUnlock: aRequest on: aWebSession
	"WebDAV unlock request for that object"
	^HTTPResponse noContent. "204"! !

!AIDASite methodsFor: 'serving' stamp: 'jmivsek 4/27/2020 21:49'!
answerTo: aRequest 
	"Squeak specific!! "
	| session object errorResponse |
	[self logRequest: aRequest.
	self ddosPreventionCheckFor: aRequest. "DDos attack? Check nr. of requests per day"
	aRequest isPing ifTrue: [^HTTPResponse ok].  "/ping.html for monitoring the site"
	session := self sessionManager findOrCreateSessionFor: aRequest.
	aRequest session: session.
	session isHttpAuthenticationNeeded ifTrue: [session authenticateFrom: aRequest].
	session isHttpAuthenticationNeeded "still" ifTrue: [^self unauthorizedResponse].
	self shouldRedirect ifTrue: [^self redirectToOtherHost: aRequest on: session].
	self log: 'p'.
	object := self router resourceFor: aRequest.  "routes to a resource able to handle this request"
	self countRequest: aRequest onObject: object.
	object isNil 
		ifTrue: [session removeIfNewGuest. ^HTTPResponse notFound].
	^self answer: object to: aRequest on: session] 
		on: Error, Exception
		do: [:exception |                      
			exception class == HTTPException ifTrue: [^exception response].
			exception class == SpSocketError 
				ifTrue: [self reportSocketError: exception request: aRequest] "temporary"
				ifFalse:
					["self reportException: exception. " "temporary off, no gain to report to Transcript!!"
 		 			self halt.
					exception defaultAction]. 
			errorResponse := self httpResponseOnException: exception.
			HTTPException raiseResponse: errorResponse.
			^errorResponse].! !

!AIDASite methodsFor: 'serving'!
ddosPreventionCheckFor: aWebRequest
	| maxRequestsPerDay |
	maxRequestsPerDay := 100000. "100K, enough?"
	((self  totalCounter dailyCounts at: aWebRequest timestamp asDate day)
		 > maxRequestsPerDay)
			ifTrue: 
				[ [self error: 'Too many requests today, DoS attack? Site ', self name, ' stopped']
					fork.
				self stop] "stop this site"! !

!AIDASite methodsFor: 'serving' stamp: 'mivsek 1/10/2008 18:46'!
reportException: anException
	 | report |
	Transcript cr; show: '*** error in web app code: ', anException errorString.
"	report := DebuggerService shortStackFor: anException initialContext ofSize: 10.
	(report  tokensBasedOn: Character cr) do: [:each |
		Transcript cr; show: '     ', each].
"! !

!AIDASite methodsFor: 'serving' stamp: 'mivsek 1/10/2008 18:47'!
reportSocketError: anException request: aRequest
	"some hard to find error while streaming, i'm trying to debug it with that report"
	Transcript cr; show: '**SpSocketError on ', self name, ': ', 
		anException parameter messageText; cr.
	Transcript show:  aRequest printString; cr.! !


!AIDASite methodsFor: 'statistics' stamp: 'JM 4/26/2007 19:58'!
availability
	"return server availability from first run in %"
	"AIDASite default availability"
	| uptime downtime |
	uptime := self totalUptime.
	downtime := self totalDowntime.
	^((uptime / ((uptime + downtime) max: 1)) * 100) asScaledDecimal: 2! !

!AIDASite methodsFor: 'statistics'!
createdDate
	"date of  server creation"
	^self createdTimestamp notNil 
		ifTrue: [self createdTimestamp asDate] 
		ifFalse: [nil]! !

!AIDASite methodsFor: 'statistics'!
createdDateText
	"date of  server creation"
	^self createdDate notNil 
		ifTrue: [self createdDate shorterPrintSloString] 
		ifFalse: ['']! !

!AIDASite methodsFor: 'statistics' stamp: 'JM 4/26/2007 19:44'!
createdTimestamp
	"time and date of  server creation"
	^SpTimestamp fromSeconds:
		(self timestamps at: #Created ifAbsentPut: [SpTimestamp now asSeconds])! !

!AIDASite methodsFor: 'statistics'!
isActive
	"there was some activity (requests served) on this site in last hour"
	self lastRequestTimestamp isNil ifTrue: [^false].
	^self lastRequestTimestamp asSeconds > (SpTimestamp now asSeconds - 3600)! !

!AIDASite methodsFor: 'statistics' stamp: 'jm 8/3/2010 10:06'!
lastCommitTimestamp
	"time and date of last commit to the database. If noone yet, return nil"
	^SpTimestamp fromSeconds: (self timestamps at: #LastCommit ifAbsent: [^nil])! !

!AIDASite methodsFor: 'statistics' stamp: 'jm 8/3/2010 10:06'!
lastRequestTimestamp
	"time and date of last web request. If noone yet, return nil"
	^SpTimestamp fromSeconds: (self timestamps at: #LastRequest ifAbsent: [^nil])! !

!AIDASite methodsFor: 'statistics'!
lastRequestTimestampText
	"time and date of last web request"
	^self lastRequestTimestamp notNil 
		ifTrue: [self lastRequestTimestamp asDate shorterPrintSloString, ' ',
			self lastRequestTimestamp asTime printSloString] 
		ifFalse: ['']! !

!AIDASite methodsFor: 'statistics' stamp: 'JM 4/25/2007 21:09'!
lastTimeAliveTimestamp
	"lastTimeAliveThread writes to timestamps every minute and commit. 
	Used in case of crash to determine, when a server was last time alive 
	and worked properly"
	^SpTimestamp fromSeconds: 
		(self timestamps at: #LastTimeAlive ifAbsentPut: [SpTimestamp now asSeconds])! !

!AIDASite methodsFor: 'statistics'!
onActivityDo: aBlock on: aWebElement app: aWebApplication
	"register a block to be executed on activity on this site. With 1s period if very frequent"
	(self activityAnnouncers 
		at: aWebApplication 
		ifAbsentPut: Dictionary new)
			at: aWebElement
			put: aBlock

" AIDASite allInstances do: [:site | site initActivityAnnouncers] "! !

!AIDASite methodsFor: 'statistics' stamp: 'JM 4/26/2007 19:57'!
runningHistory
	"return a collection of server runs as array of:
		started timestamp,
		last alive = stopped (more or less) timestamp,
		uptime in seconds,
		downtime from previous run in seconds,
		crashed or not.
	Used to determine history 
	of server runnings and to calculate server avaiability. Last entry in collection is current run
	with last alive no more than minute before current time"
	"AIDASite default runningHistory"
	| collection newArray  arry |
	collection := OrderedCollection new.
	self runningHistoryCollection do: [:array |
		newArray := Array new: 5.
		newArray 
			at: 1 put: (SpTimestamp fromSeconds: (array at: 1));
			at: 2 put: (SpTimestamp fromSeconds: (array at: 2));
			at: 3 put: (((array at: 2) - (array at: 1)) max: 0);
			at: 4 put: 0;  "we will calculate later"
			at: 5 put: ((array size < 3) ifTrue: [true] ifFalse: [array at:3]).
		collection add: newArray copy].
	newArray := Array new: 5.
	newArray
		at: 1 put: self startedTimestamp;
		at: 2 put: self lastTimeAliveTimestamp;
		at: 3 put: (self lastTimeAliveTimestamp asSeconds - 
			self startedTimestamp asSeconds);
		at: 4 put: 0;  "we will calculate later"
		at: 5 put: false. "current run not crashed"
	collection add: newArray copy.
	2 to: collection size do: [:inx |
		arry := collection at: inx.
		arry at: 4 put:   "this started - previous last alived"
			((arry at: 1) asSeconds - ((collection at: inx-1) at: 2) asSeconds)
		].
	^collection! !

!AIDASite methodsFor: 'statistics'!
startedDate
	"date of last server startup"
	^self startedTimestamp notNil 
		ifTrue: [self startedTimestamp asDate] 
		ifFalse: [nil]! !

!AIDASite methodsFor: 'statistics' stamp: 'JM 4/25/2007 21:08'!
startedTimestamp
	"time and date of last server startup"
	^SpTimestamp fromSeconds:
		(self timestamps at: #Started ifAbsentPut: [SpTimestamp now asSeconds])! !

!AIDASite methodsFor: 'statistics' stamp: ' 21/4/07 22:07'!
totalDowntime
	"return downtime between all server runs in seconds"
	"AIDASite default totalDowntime"
	| history downtime |
	history := self runningHistory.
	downtime := 0.
	history do: [:array | downtime := downtime + (array at: 4)].
	^downtime! !

!AIDASite methodsFor: 'statistics' stamp: ' 21/4/07 22:07'!
totalUptime
	"return uptime of all server runs in seconds"
	"AIDASite default totalUptime"
	| history uptime |
	history := self runningHistory.
	uptime := 0.
	history do: [:array | uptime := uptime + (array at: 3)].
	^uptime! !

!AIDASite methodsFor: 'statistics' stamp: ' 21/4/07 22:07'!
uptime
	"return uptime of current server run in seconds (with 60s precision)"
	"AIDASite default uptime"
	^self lastTimeAliveTimestamp asSeconds - self startedTimestamp asSeconds! !


!AIDASite methodsFor: 'private-backup/restore' stamp: 'np 1/15/2008 20:48'!
backupToFile
	"file out all object tree to file aidasite-<sitename>.obj"
	"(AIDASite named: 'biart') backupToFile"
	"(AIDASite named: 'biart') deepSearchOfClass: 'ObsoleteIntranet'"
	"(AIDASite named: 'biart') deepSearchOfObsoleteClasses"
	| filename fileDir |
	filename := 'aidasite-', self name, '.obj'.
	fileDir := FileDirectory forFileName: filename.
	(fileDir fileExists: filename) ifTrue: 
		[fileDir copyFileWithoutOverwriteConfirmationNamed: filename toFileNamed: ('aidasite-', self name, '-old.obj')].
	(FileStream fileNamed: filename)
		fileOutClass: nil andObject: self! !

!AIDASite methodsFor: 'private-backup/restore' stamp: 'np 1/15/2008 20:49'!
restoreSiteNamed: aString
	"boss in from file aidasite-<sitename>.obj"
	"AIDASite new restoreSiteNamed: 'test' "
	| filename site |
	filename := 'aidasite-', aString, '.obj'.
	site := (FileStream fileNamed: filename) fileInObjectAndCode.
	^site! !


!AIDASite methodsFor: 'private-counters'!
countRequest: aRequest  onObject: anObject
	self setLastRequestTimestamp.
	aRequest session shouldCountRequests ifFalse: [^nil].    "to skip admin requests etc."
	anObject class == WebSession ifTrue: [^nil]. "don't count ajax and websocket requests"
	self statistics aidaAnnounceChange. "to update live stats pages etc."
	anObject notNil 
		ifTrue: 
			[self urlResolver incCounterFor: anObject.
			self incRequestCounterFor: anObject]
		ifFalse: 
			[self incNotFoundCounter.
			self log: ' not found: ', aRequest uriString, ' '.
			^nil ].
	self statistics collectStatsFrom: aRequest.
	^anObject! !

!AIDASite methodsFor: 'private-counters' stamp: ' 21/4/07 22:07'!
counters

	counters isNil ifTrue: [self initCounters].
	^counters

"WebServer default counters"! !

!AIDASite methodsFor: 'private-counters' stamp: ' 21/4/07 22:07'!
incNotFoundCounter

	"call this after each request is processed"


	self critical:
		[self notFoundCounter incCounter].! !

!AIDASite methodsFor: 'private-counters'!
incRequestCounterFor: anObject
	"call this after each request is processed"
	self critical:
		[self totalCounter incCounter.
		(anObject aidaContentType = 'text/html') 
			ifTrue: [self pagesCounter incCounter] ].! !

!AIDASite methodsFor: 'private-counters' stamp: ' 21/4/07 22:07'!
initCounters
	"counters of web requests: total and by year/day of year"
	self critical: 
		[counters := IdentityDictionary new.
		self pagesCounter.
		self totalCounter.
		self newVisitorsCounter.
		self returningVisitorsCounter.
		self notFoundCounter].

"WebServer default initCounters"! !

!AIDASite methodsFor: 'private-counters' stamp: ' 21/4/07 22:07'!
newVisitorsCounter
	"counter of new sessions"
	(self counters includesKey: #NewVisitors) ifFalse: 
 		["self error: 'newVisitorsCounter ??'."
		self counters at: #NewVisitors put: WebCounter new].
	^self counters at: #NewVisitors

"WebServer default newVisitorsCounter"! !

!AIDASite methodsFor: 'private-counters' stamp: ' 21/4/07 22:07'!
notFoundCounter
	"counter of not found errors"
	(self counters includesKey: #NotFound) ifFalse: 
 		[self counters at: #NotFound put: WebCounter new].
	^self counters at: #NotFound

"WebServer default notFoundCounter"! !

!AIDASite methodsFor: 'private-counters' stamp: ' 21/4/07 22:07'!
pagesCounter
	"counter of only text/html pages"
	(self counters includesKey: #Pages) ifFalse: 
 		["self error: 'pagesCounter ??'."
		self counters 	at: #Pages put: WebCounter new].
	^self counters at: #Pages

"WebServer default pagesCounter"! !

!AIDASite methodsFor: 'private-counters' stamp: ' 21/4/07 22:07'!
returningVisitorsCounter
	"counter of returning sessions"
	(self counters includesKey: #ReturningVisitors) ifFalse: 
 		["self error: 'returningVisitorsCounter ??'."
		self counters
			at: #ReturningVisitors put: WebCounter new].
	^self counters at: #ReturningVisitors

"WebServer default returningVisitorsCounter"! !

!AIDASite methodsFor: 'private-counters' stamp: ' 21/4/07 22:07'!
topHour
	"a hour of most hits, an array with timestamp, hits and pages"
	(self counters includesKey: #TopHour) ifFalse: 
 		[self counters at: #TopHour put: (Array with: Timestamp now with: 0 with: 0)].
	^self counters at: #TopHour

"WebServer default topHour"! !

!AIDASite methodsFor: 'private-counters' stamp: ' 21/4/07 22:07'!
topMinute
	"a minute of most hits, an array with timestamp, hits and pages"
	(self counters includesKey: #TopMinute) ifFalse: 
 		[self counters at: #TopMinute put:  (Array with: Timestamp now with: 0 with: 0)].
	^self counters at: #TopMinute

"WebServer default topMinute"! !

!AIDASite methodsFor: 'private-counters' stamp: ' 21/4/07 22:07'!
totalCounter
	"counter of all web requests"
	(self counters includesKey: #Total) ifFalse: 
 		["self error: 'totalCounter ??'."
		self counters at: #Total put: WebCounter new].
	^self counters at: #Total

"WebServer default totalCounter"! !


!AIDASite methodsFor: 'settings-logging'!
countingPolicy
	^self settings at: #countingPolicy ifAbsentPut: [#all].! !

!AIDASite methodsFor: 'settings-logging'!
countingPolicy: aSymbol
	"from who to count requests with WebCounters: #all, #excludeAdmins, #onlyGuests, #none"
	(#(#all, #excludeAdmins, #onlyGuests, #none) includes: aSymbol) 
		ifFalse: [self error: 'unknown policy'].
	self settings  at: #countingPolicy put: aSymbol! !

!AIDASite methodsFor: 'settings-logging'!
diagnostics

	"if true, diagnostic messages are written on transcript for every web request"
	^self settings  at: #diagnostics ifAbsentPut: [true].! !

!AIDASite methodsFor: 'settings-logging'!
diagnostics: aBoolean
	"if true, diagnostic messages are written on transcript for every web request"
	(aBoolean isKindOf: Boolean) ifFalse: [self error: 'wrong argument'].
	self settings  at: #diagnostics put: aBoolean.! !

!AIDASite methodsFor: 'settings-logging'!
logging

	"if true, all requests are logged into a database"
	^self settings  at: #logging ifAbsentPut: [false].! !

!AIDASite methodsFor: 'settings-logging'!
loggingPolicy
	^self settings at: #loggingPolicy ifAbsentPut: [#none].! !

!AIDASite methodsFor: 'settings-logging'!
loggingPolicy: aSymbol
	"from who to log requests with WebCounters: #all, #excludeAdmins, #onlyGuests, #none"
	(#(#all, #excludeAdmins, #onlyGuests, #none) includes: aSymbol) 
		ifFalse: [self error: 'unknown policy'].
	self settings  at: #loggingPolicy put: aSymbol! !


!AIDASite methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
critical: aBlock

	"For protecting critical sections in parallel execution of web requests. Use it always
	when you do things, which cannot be disturbed by another request. Exmaple:
		aServer critical: [<a block with critical section>]. "

	^WebTransactionMonitor critical: aBlock! !

!AIDASite methodsFor: 'accessing' stamp: 'JM 4/25/2007 21:07'!
style
	style isNil ifTrue: 
		[self style: ((Smalltalk at: self styleClass asSymbol) value newOnSite: self)].
	^style! !


!AIDASite methodsFor: 'settings-directories'!
defaultHomeDirectory
	" ./static directory from where the image started, but depending on Unix or Win style"
	^(SpEnvironment onWindows ifTrue: ['.\static'] ifFalse: ['./static'])! !

!AIDASite methodsFor: 'settings-directories'!
homeDirectory

	^self settings  at: #homeDirectory ifAbsentPut: [self defaultHomeDirectory]! !

!AIDASite methodsFor: 'settings-directories'!
homeDirectory: aString
	" a directory, which is the root for static content like static html documents"
	self settings  at: #homeDirectory put: aString.! !


!AIDASite methodsFor: 'start/stop'!
disable
	"this site is disabled and stopped, if not yet before. This site won't be started with SwazooServer start"
	self stop.
	self sessionManager
		removeGuestSessions;
		releaseApplicationState.
	^super disable! !

!AIDASite methodsFor: 'start/stop'!
enable
	"this site is enabled and can be started. Only enabled sites are started with SwazooServer start"
	^super enable! !

!AIDASite methodsFor: 'start/stop' stamp: ' 21/4/07 22:07'!
restart
	self stop.
	self start.! !

!AIDASite methodsFor: 'start/stop'!
start
	self isEnabled ifFalse: [^nil].
	self setStartedTimestampCrashed: self isServing.
	self setLastTimeAliveTimestamp.
	super start.
	self startServices.! !

!AIDASite methodsFor: 'start/stop' stamp: ' 21/4/07 22:07'!
stop
	super stop.
	self stopServices.
	self setLastTimeAliveTimestamp.! !


!AIDASite methodsFor: 'initialize-release' stamp: 'jmivsek 5/24/2020 20:48'!
initDefaultSettings

	self host: 'newsite' ip: '127.0.0.1'  port: 8888.  "this is usable for tests only"
"	self homeDirectory: self defaultHomeDirectory. " "rather lazy init, because of platform issues"
	self styleClass: 'DefaultWebStyle'.
	self diagnostics: false.
	self loggingPolicy: #none.
	self countingPolicy: #all.
	self smtpServer: self ip.
	self urgentNotificationEMail: 'info@eranova.si'.! !

!AIDASite methodsFor: 'initialize-release'!
initDemoOnRootUrl
	"(AIDASite named: 'aidademo') initDemoOnRootUrl."
	self register: self demo onUrl: '/'.! !

!AIDASite methodsFor: 'initialize-release'!
initFavicon
	"/favicon.ico, a small icon shown in browser near url address"
	"(AIDASite named: 'biart') initFavicon."
	| icon |
	icon := WebMethodImage
		fromMethod: #favicon on: self style contentType: 'image/x-icon' site: self.
	self register: icon onUrl: '/favicon.ico'.! !

!AIDASite methodsFor: 'initialize-release'!
initHourlySnapshot
	"For default image based persistency"
	(self scheduler isScheduledBlock: [AIDASite preImageSnapshot; imageSnapshot]) "schedule only once!!"
		ifTrue: [^nil]. 
	self scheduler
		everyHourAt: 0 
		runBlock: [AIDASite preImageSnapshot; imageSnapshot]! !

!AIDASite methodsFor: 'initialize-release'!
initNightlyCleanup
	"releasing session application state and other cleanup every night at 4:00"
	(self scheduler isScheduledBlock: [self nightlyCleanup]) ifTrue: [^nil]. "schedule only once!!"
	self scheduler
		everyDayAt: self nightlyCleanupTime hours
		runBlock:  [self nightlyCleanup]! !

!AIDASite methodsFor: 'initialize-release'!
initOther
	other := Dictionary new! !

!AIDASite methodsFor: 'initialize-release'!
initScheduledTasks
	self initHourlySnapshot.
	self initNightlyCleanup.! !

!AIDASite methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initTimestamps
	timestamps := IdentityDictionary new.
	self setLastTimeAliveTimestamp.
	self setCreatedTimestamp.

"WebServer default initTimestamps"! !

!AIDASite methodsFor: 'initialize-release'!
initUpdateQueue
	^self
		otherAt: #UpdateQueue
		put: SharedQueue new! !

!AIDASite methodsFor: 'initialize-release'!
initialize
	super initialize.
	WebTransactionMonitor addServer: self.
	self initDefaultSettings.
	self initDemoOnRootUrl. 
	self initFavicon.
	self initScheduledTasks.
	WebTransactionMonitor commit.! !

!AIDASite methodsFor: 'initialize-release'!
releaseApplicationState
	"release application state (appsForObjects) of all sessions"
	^self sessionManager releaseApplicationState! !


!AIDASite methodsFor: 'nightly-cleanup'!
nightlyCleanup
	"releasing session application state and other cleanup"
	"AIDASite allInstances do: [:each | each nightlyCleanup] "
	self isEnabled ifFalse: [^nil]. "no need to cleanup disabled sites"
	Transcript cr; show: '*** Aida site ', self name, ' nightly cleanup'.
	HTTPConnection allInstances do: [:each | each close].  "to GC all streams and buffers"
	self sessionManager removeGuestSessions.
	self sessionManager releaseApplicationState.
	self dependencies clear.
	self statistics removeReferersJustOneHit.
	self initUpdateQueue. "if stalled for some reason"
	self updater: nil.! !

!AIDASite methodsFor: 'nightly-cleanup'!
nightlyCleanupTime
	"when cleanup with releasing application state occurs"
	^Time fromSeconds: 4 * 3600 "at 4 in the morning"! !


!AIDASite methodsFor: 'private-updates'!
notifyQueueAddition
	self updater 
		ifNotNil: [^nil]. "updater is already there to wait a bit then updates from a queue"
	self updater: 
		[self updaterProcess] "this process wil wait a bit then update all elements from a queue at once"
			fork! !

!AIDASite methodsFor: 'private-updates'!
queueUpdateOf: aWebElement with: anArgumentOrNil
	"An update request of specified web element is put into a queue"
	"AidaDependency adds to a queue an Associations with web element as a key and object which 
	changed as a value"
	| assoc |
	assoc := aWebElement -> anArgumentOrNil.
	self updateQueue
		nextPut: assoc.
	self 
		notifyQueueAddition "to start updating elements"! !

!AIDASite methodsFor: 'private-updates'!
removeReplicateUpdatesFrom: anUpdateAssocs
	"if more than one update of the same element is requested, keep only the last, most fresh update"
	| fresh already |
	fresh := OrderedCollection new.
	already := Set new.
	anUpdateAssocs reverseDo: [:assoc |
		(already includes: assoc key) "web element"
			ifTrue: ["a duplicate, skip it"]
			ifFalse: 
				[fresh add: assoc.
				already add: assoc key. "web element"] ].
	^fresh reverse! !

!AIDASite methodsFor: 'private-updates'!
updateElementsFrom: anUpdateAssocs
	anUpdateAssocs do: [:assoc || e |
		e := assoc key.
		e isActive ifTrue:   "element can be already old in time from domain obj change to actual update"
			[e creationArgument isNil
				ifTrue: [e update]
				ifFalse: [e updateWith: assoc value] ] ] "update argument"! !

!AIDASite methodsFor: 'private-updates'!
updateElementsFromQueue
	"Optimize updating by removing duplicates and select only upper web elements to update."
	"It can be called from updaterProcess or WebSession streamAjaxResponse..."
	| updates |
	updates := OrderedCollection new.
	[self updateQueue isEmpty not] " get all content at once"
		whileTrue: [updates add: self updateQueue next].
	updates := self removeReplicateUpdatesFrom: updates. "updates of the same element"
	updates := self upperElementsOnlyFrom: updates. "remove elements contained in other elements"
	self updateElementsFrom: updates! !

!AIDASite methodsFor: 'private-updates'!
updateQueue
	"to decouple actions from object change announcements and other web element update requests"
	"AidaDependency adds to a queue an Associations with web element as a key and object which 
	changed as a value"
	^self
		otherAt: #UpdateQueue
		ifAbsent: [^self initUpdateQueue]! !

!AIDASite methodsFor: 'private-updates'!
updater
	"a temporary process to update all elements from an update queue"
	^self
		otherAt: #Updater
		ifAbsent: [nil]! !

!AIDASite methodsFor: 'private-updates'!
updater: aProcess
	^self
		otherAt: #Updater
		put: aProcess! !

!AIDASite methodsFor: 'private-updates'!
updaterProcess
	"First wait a bit to collect all updates in a potential change announcement  burst, then update all at once"
	(Delay forMilliseconds: 10) wait.
	[self updateElementsFromQueue]
		ensure: 
			[self updater: nil]! !

!AIDASite methodsFor: 'private-updates'!
upperElementsOnlyFrom: anUpdateAssocs
	"to optimize by updating only necessary elements, remove updates of elements contained in other, 
	upper elements to update"
	| elements |
	elements := (anUpdateAssocs collect: [:assoc | assoc key]) asSet.
	^anUpdateAssocs 
		reject: [:assoc |
			assoc key "element" allParents
				contains: [:prnt | elements includes: prnt] ].! !


!AIDASite methodsFor: 'private-other'!
other
	^other! !

!AIDASite methodsFor: 'private-other'!
otherAt: aSymbol
	"other values"
	^self otherAt: aSymbol ifAbsent: [nil]! !

!AIDASite methodsFor: 'private-other'!
otherAt: aSymbol ifAbsent: aBlock
	"other values"
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!AIDASite methodsFor: 'private-other'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!AIDASite methodsFor: 'private-other'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AIDASite class
	instanceVariableNames: ''!

!AIDASite class methodsFor: 'slovenian characters' stamp: 'JM 4/26/2007 20:02'!
charC
	"return internal  unicode code for slovene character: uppercase c"
	^16r010C asCharacter! !

!AIDASite class methodsFor: 'slovenian characters' stamp: ' 21/4/07 22:07'!
charCszSet
	^Set new
		add: self charc; add: self charC;
		add: self chars; add: self charS;
		add: self charz; add: self charZ;
		yourself! !

!AIDASite class methodsFor: 'slovenian characters' stamp: 'JM 4/26/2007 20:06'!
charS
	"return internal  unicode code for slovene character: uppercase s"
	^16r0160 asCharacter! !

!AIDASite class methodsFor: 'slovenian characters' stamp: ' 21/4/07 22:07'!
charZ
	"return internal unicode code for slovene character: uppercase z"
	^16r017D asCharacter! !

!AIDASite class methodsFor: 'slovenian characters' stamp: ' 21/4/07 22:07'!
charc
	"return internal  unicode code for slovene character: lowercase c"
	^16r010D asCharacter! !

!AIDASite class methodsFor: 'slovenian characters' stamp: ' 21/4/07 22:07'!
chars
	"return internal  unicode code for slovene character: lowercase s"
	^16r0161 asCharacter! !

!AIDASite class methodsFor: 'slovenian characters' stamp: 'JM 4/26/2007 20:07'!
charz
	"return internal unicode code for slovene character: lowercase z"
	^16r017E asCharacter! !

!AIDASite class methodsFor: 'slovenian characters' stamp: 'JM 4/26/2007 20:07'!
initSloveneCharacters
	"AIDASite initSloveneCharacters"
	SloveneCharacters := Set new: 6.
	^SloveneCharacters 
		add: self charC;
		add: self charc;
		add: self charS;
		add: self chars;
		add: self charZ;
		add: self charz;
		yourself! !

!AIDASite class methodsFor: 'slovenian characters' stamp: 'JM 4/26/2007 20:07'!
isSloveneCharacter: aCharacter
	"return true if character is slovene"
	SloveneCharacters isNil ifTrue: [self initSloveneCharacters].
	^SloveneCharacters includes: aCharacter

"AIDASite isSloveneCharacter: AIDASite charC"! !

!AIDASite class methodsFor: 'slovenian characters' stamp: 'JM 4/26/2007 20:07'!
sloveneLowercase: aString
	^aString collect: [:chr | 
		(AIDASite isSloveneCharacter: chr)
			ifTrue: 	[(chr = AIDASite charC) ifTrue: [AIDASite charc]
				ifFalse: [(chr = AIDASite charS) ifTrue: [AIDASite chars]
					ifFalse: [(chr = AIDASite charZ) ifTrue: [AIDASite charz]
						ifFalse: [chr] ]]]
			ifFalse: [chr asLowercase]
		].! !

!AIDASite class methodsFor: 'slovenian characters' stamp: 'JM 4/26/2007 20:08'!
sloveneUppercase: aString
	^aString collect: [:chr | 
		(AIDASite isSloveneCharacter: chr)
			ifTrue: 	[(chr = AIDASite charc) ifTrue: [AIDASite charC]
				ifFalse: [(chr = AIDASite chars) ifTrue: [AIDASite charS]
					ifFalse: [(chr = AIDASite charz) ifTrue: [AIDASite charZ]
						ifFalse: [chr] ]]]
			ifFalse: [chr asUppercase]
		].! !


!AIDASite class methodsFor: 'codepage converting' stamp: 'mu 3/7/2008 20:21'!
convert: aString fromCodepage: aSymbol
	"convert aString to internal unicode"
	| encoding |
	(#(#'win-1250' #'win1250' #'Windows-1250' cp1250) includes: aSymbol) 
		ifTrue: [encoding := #'cp-1250'].
	(#(#'iso-8859-2' #'iso8859-2' #'ISO-8859-2' iso2) includes: aSymbol) 
		ifTrue: [encoding := #'iso-8859-2'].
	(#(#utf8 #'utf-8' #'utf_8' #UTF8 #'UTF-8' #'UTF_8') includes: aSymbol) 
		ifTrue: [encoding := #utf8].
	encoding isNil ifTrue: [^aString].

	^[aString convertFromEncoding: encoding] on: Error do: [:ex | aString ].

	
"AIDASite convert: (String with: 16rC4 asCharacter with: 16r8D asCharacter) fromCodepage: #utf8 "! !

!AIDASite class methodsFor: 'codepage converting' stamp: 'mu 3/8/2008 16:34'!
convert: aString toCodepage: aSymbol
	"convert internal unicode aString to codepage. "
	| encoding converter in out |
	(#(#'win-1250' #'win1250' #'Windows-1250' cp1250) includes: aSymbol) 
		ifTrue: [encoding := #'cp-1250'].
	(#(#'iso-8859-2' #'iso8859-2' #'ISO-8859-2' iso2) includes: aSymbol) 
		ifTrue: [encoding := #'iso-8859-2'].
	(#(#utf8 #'utf-8' #'utf_8' #UTF8 #'UTF-8' #'UTF_8') includes: aSymbol) 
		ifTrue: [encoding := #'utf8'].
	encoding isNil ifTrue: [^aString].

	converter := (TextConverter newForEncoding: encoding) ifNil: [UTF8TextConverter new].
	in := aString readStream.
	out := WriteStream on: ''.
	[in atEnd] whileFalse: [converter nextPut: in next toStream: out].
	^out contents

"AIDASite convert: (String with: 16r010D asCharacter) toCodepage: #utf8 "! !

!AIDASite class methodsFor: 'codepage converting' stamp: ' 21/4/07 22:07'!
convertFromWeb: aString on: aSession
	"convert aString, which is in code page, defined in aSession to an internal unicode "
	^self convert: aString fromCodepage: aSession codePage! !

!AIDASite class methodsFor: 'codepage converting' stamp: ' 21/4/07 22:07'!
convertToWeb: aString on: aSession
	"rconver internal unicode aString to a proper code page, defined in aSession"
	^self convert: aString toCodepage: aSession codePage! !

!AIDASite class methodsFor: 'codepage converting'!
properArray: aStringOrByteArray
	"if two byte (or wide) string, convert it to one byte, cut twobyte characters, make them $? "
	| stream |
	aStringOrByteArray class == ByteString ifTrue: [^aStringOrByteArray].
	aStringOrByteArray class == ByteArray ifTrue: [^aStringOrByteArray].
	aStringOrByteArray class == Array ifTrue: [^aStringOrByteArray asByteArray].
	stream := WriteStream on: (String new: aStringOrByteArray size *2).
	aStringOrByteArray "TwoByteArray or WideArray"
		do: [:char | stream nextPut: (char asInteger < 256 ifTrue: [char] ifFalse: [$?])].
	^stream contents! !


!AIDASite class methodsFor: 'http encoding'!
convertFromWebString: aString
	"converts special chars in http stream: 
		'+' as ' '
		%xx as appropriate ASCII char
	"
	| newString |
	newString := HTTPString decodedHTTPFrom: aString.
	newString := AIDASite convert:newString fromCodepage: #'utf-8'.
	^newString

"AIDASite convertFromWebString: (AIDASite convertToWebString: '+-% test one') "! !

!AIDASite class methodsFor: 'http encoding' stamp: 'np 9/26/2008 12:50'!
convertIRItoURL: aString
	| stream aByteString |
	stream _ WriteStream on: ''.
	aByteString _ self convert: aString toCodepage: #utf8.
	aByteString do: [ :char |
	('abcdefghijklmnopqrstuvwxyz0123456789./-+:~?#@=' includes: char asLowercase)
		ifTrue: [ stream nextPut: char. ]
		ifFalse: [ stream nextPut: $%; nextPutAll: (char codePoint radix: 16). ]. ].
	^ stream contents.! !

!AIDASite class methodsFor: 'http encoding'!
convertToWebString: aString
	"converts some special chars in http stream: 
		' ' as '+'
		%xx as appropriate ASCII char
	"
	^HTTPString encodedHTTPFrom: aString 

"AIDASite convertToWebString: '+-% test one' "! !

!AIDASite class methodsFor: 'http encoding'!
decodeCharEntitiesIn: aString
	"  '&lt;tag&gt; = '<tag>'  "
	"Character entitty references, see http://www.w3.org/TR/html401/charset.html#h-5.3.2"
	| charDict in out |
	charDict := Dictionary new
		at: 'lt' put: $<; at: 'gt' put: $>;
		at: 'amp' put: $&; at: 'quot' put: $"; yourself.
	in := aString readStream. out := WriteStream on: String new.
	[in atEnd] whileFalse: 
		[| ch entity | 
		ch := in next.
		ch = $& 
			ifTrue: 
				[entity := in upTo: $; .
				out nextPut: (charDict at: entity)]
			ifFalse: [out nextPut: ch]  ].
	^out contents! !

!AIDASite class methodsFor: 'http encoding'!
encodeCharEntitiesIn: aString
	"  '<tag>' = '&lt;tag&gt;' "
	"Character entitty references,  see http://www.w3.org/TR/html401/charset.html#h-5.3.2"
	| charEntities charDict in out |
	charEntities := #($< $> $& $").
	(aString contains: [:ch | charEntities includes: ch ]) ifFalse: [^aString]. "quick test"
	charDict := Dictionary new
		at: $< put: '&lt;'; at: $> put: '&gt;';
		at: $& put: '&amp;'; at: $" put: '&quot;'; yourself.
	in := aString readStream. out := WriteStream on: String new.
	[in atEnd] whileFalse: 
		[| ch | ch := in next.
		(charEntities includes: ch)
			ifTrue: [out nextPutAll: (charDict at: ch)]
			ifFalse: [out nextPut: ch]  ].
	^out contents! !

!AIDASite class methodsFor: 'http encoding'!
encodeQuoteEntitiesIn: aString
	" Just double quotes '' to &quot;  "
	"Character entitty references,  see http://www.w3.org/TR/html401/charset.html#h-5.3.2"
	| in out |
	(aString contains: [:ch | ch = $" ]) ifFalse: [^aString]. "quick test"
	in := aString readStream. out := WriteStream on: String new.
	[in atEnd] whileFalse: 
		[| ch | ch := in next.
		ch = $"
			ifTrue: [out nextPutAll: '&quot;']
			ifFalse: [out nextPut: ch]  ].
	^out contents! !

!AIDASite class methodsFor: 'http encoding' stamp: ' 21/4/07 22:07'!
fromHexValue: aCharacter
	aCharacter isDigit 
		ifTrue: [^aCharacter asInteger - $0 asInteger]
		ifFalse: [
			(aCharacter asLowercase between: $a and: $f)
				ifTrue: [^aCharacter asLowercase asInteger - $a asInteger+10]
				ifFalse: [^nil]].! !

!AIDASite class methodsFor: 'http encoding' stamp: ' 21/4/07 22:07'!
hexCharFrom: aNumber
	^aNumber < 10 
		ifTrue: [($0 asInteger + aNumber) asCharacter]
		ifFalse: [($A asInteger + aNumber - 10) asCharacter]! !


!AIDASite class methodsFor: 'accessing' stamp: 'mu 2/3/2008 16:44'!
default
	"just return default instance set by default:"
	^Default! !

!AIDASite class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
default: aString
	"make a site with that name a default one"
	| site |
	site := SwazooServer singleton siteNamed: aString.
	site isNil ifTrue: [^self error: 'site with that name does not exist!!'].
	Default := site.
	^site! !

!AIDASite class methodsFor: 'accessing'!
version
	^'6.8'! !


!AIDASite class methodsFor: 'image snapshot' stamp: 'janko 10/31/2012 11:23'!
imageSnapshot
	"Save an image and show elapsed time on transcript"
	"Snapshoting is coordinated so that only one snapshot occurs out of many calls"
	"AIDASite imageSnapshot"
	"Squeak specific"
	| elapsed |
	self isHourlySnapshotEnabled ifFalse: [^nil].
	(self isHourlySnapshot and: [self shallSnapshot]) ifFalse: [^nil]. "to allow only one snapshot per hour"
	self setLastSnapshot.
	self reportImageState. "for debugging"
	WebSessionManager allInstances do: [:each | each removeNonactiveGuestSessions].	"this really belongs here?"
	Processor activeProcess priority: Processor userInterruptPriority. "to avoid image block bug"
	elapsed := Time millisecondsToRun: [SmalltalkImage current saveSession]. "Squeak specific"
	Transcript show: ' in ', (elapsed // 1000) printString, 's '.  "reports elapsed time to Transcript"! !

!AIDASite class methodsFor: 'image snapshot'!
isHourlySnapshotEnabled
	"at least one site must have settings #hourlySnapshotEnabled true"
	^AIDASite allInstances contains: [:site | site hourlySnapshotEnabled]! !

!AIDASite class methodsFor: 'image snapshot' stamp: 'jmivsek 4/27/2020 11:29'!
preImageSnapshot! !

!AIDASite class methodsFor: 'image snapshot' stamp: 'janko 8/25/2012 19:05'!
reportImageState
	"AIDASite reportImageState"
"	Transcript cr; show: '** image state: '.
	Transcript cr; show: '   ', HTTPConnection allInstances size printString, ' HTTPCommections'.
	Transcript cr; show: '   ', Socket allInstances size printString, ' Sockets'.
	Transcript cr; show: '   ', Process allInstances size printString, ' Processes'.
	Transcript cr; show: '   ', Semaphore allInstances size printString, ' Semaphores'.
	Transcript cr; show: '   ', Socket registry size printString, ' Socket registry'.
	Transcript cr; show: '   ', StandardFileStream registry size printString, ' StandardFileStream registry'.
	Transcript cr; show: '   ', (ExternalSemaphoreTable unprotectedExternalObjects reject: #isNil) size 
		printString, ' ExternalSemaphoreTable'.
"
! !

!AIDASite class methodsFor: 'image snapshot'!
resetHourlySnapshot
	"Don't snapshot image every hour"
	"AIDASite resetHourlySnapshot"
	HourlySnapshot := false! !

!AIDASite class methodsFor: 'image snapshot'!
setHourlySnapshot
	"Snapshot image every hour"
	"AIDASite setHourlySnapshot"
	HourlySnapshot := true! !


!AIDASite class methodsFor: 'initialize' stamp: 'jm 2/4/2011 19:56'!
initialize
	"AIDASite initialize"
	"prepare a demo site, if not already, and start it"
	self initializeDemoSite ! !

!AIDASite class methodsFor: 'initialize'!
initializeDemoSite
	"prepare and start a demo site, if not already"
	"put that in Aida/Web bundle postLoad action!!"
	SwazooServer singleton aidaSites isEmpty ifTrue:
		[SwazooServer singleton 
			aidaDemoSite;
			start.
		Transcript 
			cr; cr; 
			show: '*** Aida/Web demo site started, open http://localhost:8888'; 
			cr; cr].! !


!AIDASite class methodsFor: 'private'!
isHourlySnapshot
	"Shall snapshot image every hour? Yes by default"
	HourlySnapshot isNil ifTrue: [self setHourlySnapshot].
	^HourlySnapshot! !

!AIDASite class methodsFor: 'private'!
lastPreSnapshot
	"a timestamp of last pre snapshoot activity"
	LastPreSnapshot isNil ifTrue: [LastPreSnapshot := 
		(SpTimestamp fromSeconds: SpTimestamp now asSeconds - (24*3600))]. "something older than 5min!!"
	^LastPreSnapshot! !

!AIDASite class methodsFor: 'private'!
lastSnapshot
	"a timestamp of last image snapshot"
	LastSnapshot isNil ifTrue: [LastSnapshot := 
		(SpTimestamp fromSeconds: SpTimestamp now asSeconds - (24*3600))]. "something older than 5min!!"
	^LastSnapshot! !

!AIDASite class methodsFor: 'private'!
resetLastSnapshot
	"in preImageSnapshot to indicate that it is finished and imageSnapshot can continue"
	LastSnapshot := nil! !

!AIDASite class methodsFor: 'private' stamp: 'jm 2/1/2011 21:32'!
setDialect
	"for now only Squeak or Pharo"
	"Squeak specific" "Pharo specific"
	Dialect := (('Pharo*' match: SystemVersion current version)
		ifTrue: [#Pharo]
		ifFalse: [#Squeak])
	! !

!AIDASite class methodsFor: 'private'!
setLastPreSnapshot
	"a timestamp of last pre snapshot activity"
	LastPreSnapshot := SpTimestamp now! !

!AIDASite class methodsFor: 'private'!
setLastSnapshot
	"a timestamp of last image snapshot"
	LastSnapshot := SpTimestamp now! !

!AIDASite class methodsFor: 'private'!
shallPreSnapshot
	"yes, if allowed and if there were no presnapshot last 5 minutes"
	self isHourlySnapshot ifFalse: [^false].
	^(SpTimestamp now asSeconds - self lastPreSnapshot asSeconds) > (5*60)! !

!AIDASite class methodsFor: 'private'!
shallSnapshot
	"yes, if allowed and if there were no snapshot last 5 minutes"
	self isHourlySnapshot ifFalse: [^false].
	^(SpTimestamp now asSeconds - self lastSnapshot asSeconds) > (5*60)! !


!AIDASite class methodsFor: 'testing' stamp: 'jm 8/26/2009 16:21'!
onPharo
	"Squeak specific" "Pharo specific"
	Dialect isNil ifTrue: [self setDialect].
	^Dialect = #Pharo! !

!AIDASite class methodsFor: 'testing' stamp: 'jm 8/26/2009 16:22'!
onSqueak
	"Squeak specific" "Pharo specific"
	Dialect isNil ifTrue: [self setDialect].
	^Dialect = #Squeak! !


!AIDASite class methodsFor: 'utilities' stamp: 'jmivsek 5/24/2020 12:29'!
random
	"a random generator, always seeded and therefore ready to geenrate numbers which are really 
       random"
	RandomGen ifNil: 
		[RandomGen := Random new].
	^RandomGen! !


Object subclass: #URLResolver
	instanceVariableNames: 'site allWebPages allURLLinks counters totalCounter randomGen'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Core'!
!URLResolver commentStamp: '<historical>' prior: 0!
URLResolver is a two way Url to object mapper, first way is for finding a reference to domain object the Url in web request is pointing on, reverse way is to get an Url for a domain object, when you add link to it on a web page.

URLResolver holds also counters of web requests per domain objects.
!


!URLResolver methodsFor: 'request counting'!
addCountsFromDictionary: aCountDictionary

| object origCounter stopUrls |
	stopUrls := Col collect: [:assoc | assoc notNil ifTrue: [assoc key] ].
	aCountDictionary keysAndValuesDo: [:url :counter |
	(stopUrls includes: url asLowercase) ifFalse:
		[object := self objectOnUrl: url.
		object notNil ifTrue: 
			[origCounter := self counterFor: object.
			origCounter addCounter: counter ] ]
		ifTrue: ["self halt"] ]

"URLResolver default addCountsFromDictionary: Janko"
"
| boss |
boss := (BinaryObjectStorage onOld: '..\images\janko\LogDict.boss' asFilename readStream).
Janko := boss next.
boss close
"! !

!URLResolver methodsFor: 'request counting' stamp: ' 21/4/07 22:07'!
allPagesAndCounts

	"return total counts for all objects that have counters, most counted first"

	| collection |
	collection := OrderedCollection new.
	self counters keysAndValuesDo: [:object :counter |
		collection add: (Array
			with: object
			with: counter total)].
	^SortedCollection
		withAll: collection
		sortBlock: [:a :b | (a at: 2) > (b at: 2)]

"URLResolver default allPagesAndCounts"! !

!URLResolver methodsFor: 'request counting' stamp: 'np 10/17/2008 17:43'!
allUrlsAndCounters
	"return copies of all counters as dictionary with url as key"
	| dictionary |
	dictionary := Dictionary new.
	self counters keysAndValuesDo: [:object :counter |
		dictionary 
			at: (self halfUrlFor: object)
			put: counter aidaDeepCopy].
	^dictionary

"URLResolver default allUrlsAndCounters"
"
(BinaryObjectStorage onNew: 'counters.boss' asFilename writeStream)
	nextPut: URLResolver default allUrlsAndCounters;
	close
"! !

!URLResolver methodsFor: 'request counting' stamp: ' 21/4/07 22:07'!
counterFor: anObject
	anObject isNil ifTrue: [^nil].
	(self counters includesKey: anObject)
		ifFalse: [self resetCounterFor: anObject].
	^self counters at: anObject! !

!URLResolver methodsFor: 'request counting'!
counterForUrl: anUrlString

	"return a counter for object with specified url. Nil if not exist"

	| object  |
	object := self objectOnUrl: anUrlString.
	object isNil ifTrue: [^nil].
	^self counterFor: object.

"URLResolver default counterForUrl: '/osn/g_l-vse.htm'"
"WebServer default totalCounter"
"WebServer default pagesCounter"! !

!URLResolver methodsFor: 'request counting'!
incCounterFor: anObject
	"increment a web counter for that object. Only text/html object are counted
	Don't count temporary objects"
	(anObject aidaContentType = 'text/html') ifFalse: [^nil].
	self site critical: 
		[(self counters includesKey: anObject) ifFalse: [self resetCounterFor: anObject].
		(self counters at: anObject) incCounter.
		"self totalCounter incCounter   **aWebServer already counts!! "]! !

!URLResolver methodsFor: 'request counting' stamp: ' 21/4/07 22:07'!
removeCounterFor: anObject


	(self counters includesKey: anObject)
		ifTrue: [self counters removeKey: anObject]! !

!URLResolver methodsFor: 'request counting'!
removeNonHtmlCounters
	self counters keys do: [:object |
		object aidaContentType ~= 'text/html' ifTrue:
			[self removeCounterFor: object] ]

"URLResolver default removeNonHTMLCounters"! !

!URLResolver methodsFor: 'request counting' stamp: ' 21/4/07 22:07'!
resetAllCounters

	self counters values do: [:each | each reset].

"URLResolver default resetAllCounters"! !

!URLResolver methodsFor: 'request counting' stamp: ' 21/4/07 22:07'!
resetCounterFor: anObject
	"reset counters for specified object. If not yet exist, initialize it first"
	anObject isNil ifTrue: [^nil].
	self site critical:
		[(self counters includesKey: anObject) ifFalse: 
			[self counters at: anObject put: WebCounter new].
		(self counters at: anObject) reset]! !


!URLResolver methodsFor: 'adding-removing'!
addObject: anObject withUrl: aString
	"add an object if not already exist and add url to the collection of urls for that object.
	If aString url point to some other object already, then remove url from that other object"
	"warning, if web elements (such as web apps) will be registered"
"	self isWebElement: anObject." "do we still need this warning?"
	| lowercaseUrl |
	anObject isNil ifTrue: [^nil]. "do not add nil objects!!"
	lowercaseUrl := self lowercaseUrl: aString.
	self site critical: 
		[(self allWebPages at: anObject ifAbsentPut: [OrderedCollection new])
				add: lowercaseUrl.
		(self allUrlLinks includesKey: lowercaseUrl) ifTrue:
			[(self allWebPages at: (self allUrlLinks at: lowercaseUrl)	
				ifAbsentPut: [OrderedCollection new])
					remove: lowercaseUrl ifAbsent: [] ].
		self allUrlLinks at: lowercaseUrl put: anObject ].
	^anObject! !

!URLResolver methodsFor: 'adding-removing'!
changeToPreferredUrl: anObject
 	"remove all existing urls and make this as only one"
	"BEWARE, all old urls will be erased, url references can be breaked!! "
	| url |
	url := anObject preferredUrl.
	url isNil ifTrue: [^nil].
	(url size > 1 and: [url first = $/]) ifFalse: [self error: 'preferredUrl must start with / '].
	self removeObject: anObject.
	self defaultUrl: url for: anObject.! !

!URLResolver methodsFor: 'adding-removing' stamp: ' 21/4/07 22:07'!
changeToURL: aString forObject: anObject
 	"remove all existing urls and make this as only one"
	"BEWARE, all ols urls will be erased, url references can be breaked!! "
	self removeObject: anObject.
	self defaultURL: aString forObject: anObject.! !

!URLResolver methodsFor: 'adding-removing'!
changeToUrl: aString for: anObject
 	"remove all existing urls and make this as only one"
	"BEWARE, all ols urls will be erased, url references can be breaked!! "
	self removeObject: anObject.
	self defaultUrl: aString for: anObject.! !

!URLResolver methodsFor: 'adding-removing'!
defaultToPreferredUrl: anObject
	"Default URL of that object is set to one suggested by its #prefferedUrl method."
	"Existing URLs are preserved, but just default URL used for automatic URL management"
	| url |
	url := anObject preferredUrl.
	url isNil ifTrue: [^nil].
	(url size > 1 and: [url first = $/]) ifFalse: [self error: 'preferredUrl must start with / '].
	self defaultUrl: url for: anObject.! !

!URLResolver methodsFor: 'adding-removing'!
defaultUrl: aString for: anObject
	"set url as default url for that object. This url is then used in dynamic url creation. If an object 
	does not already exist, then create a new entry first"
	| urls first defInx |
	self addObject: anObject withUrl: aString.  "just in case object is new one"
	"swap old default with new default url on a first place in collection"
	self site critical: 
		[urls := allWebPages at: anObject.
		first := urls first.
		defInx := urls indexOf: (self lowercaseUrl: aString).
		urls at: 1 put: (urls at: defInx).
		urls at: defInx put: first].! !

!URLResolver methodsFor: 'adding-removing'!
removeObject: anObject
	"remove object and all its URLs. Returns true if object existed and false if not. 
	Remove also its web counter"
	| urls |
	self site critical:
		[urls := (self allWebPages at: anObject ifAbsent: [^nil]).
		self allWebPages removeKey: anObject.
		urls notNil ifTrue: [urls do: [: each | self allUrlLinks removeKey: each ifAbsent: [] ] ].
		self counters removeKey: anObject ifAbsent: [] ].
	^true! !

!URLResolver methodsFor: 'adding-removing'!
removeObjectWithUrl: aString

"remove object and all its URLs. Returns true if object existed and false if not"

	| object |
	object := allURLLinks at: (self lowercaseUrl: aString) ifAbsent: [^false].
	^self removeObject: object.! !

!URLResolver methodsFor: 'adding-removing'!
removeObjectsOfClass: aClass
	"fast removal even if dictionaries are really big"
	| toRemove newWebPages newURLLinks newCounters |
	toRemove := (self objectsOfClass: aClass) asSet.
	newWebPages := Dictionary aidaWithAll:
		(self allWebPages associations reject: [:assoc | toRemove includes: assoc key]).
	newURLLinks := Dictionary aidaWithAll:
		(self allUrlLinks associations reject: [:assoc | toRemove includes: assoc value]).
	newCounters := Dictionary aidaWithAll:
		(self counters associations reject: [:assoc | toRemove includes: assoc key]).
	self site critical:
		[allWebPages := newWebPages.
		allURLLinks := newURLLinks.
		counters := newCounters]


"URLResolver default removeObjectsOfClass: WebMethodImage "
"URLResolver default allWebPages size  38 45"! !

!URLResolver methodsFor: 'adding-removing' stamp: 'janko 12/6/2008 18:38'!
removeObjectsOfClassNamed: aString
	"good for removing Obsolete classes!!"
	self site critical:
		[self allWebPages keys do: [:object | 
			object class name= aString ifTrue: [self removeObject: object]] ].

"URLResolver default removeObjectsOfClassNamed: WebMethodImage"
"URLResolver default allWebPages size 10934"! !

!URLResolver methodsFor: 'adding-removing'!
removeObjectsOfObsoleteClass
	self site critical:
		[self allWebPages keys do: [:object | 
			object class isObsolete ifTrue: [self removeObject: object]] ].

"URLResolver default removeObjectsOfObsoleteClass"! !

!URLResolver methodsFor: 'adding-removing'!
removeUrl: aString
	"remove this URL and also object, if this url was the last one pointed to object Returns 
	true if url existed and false if not. Also remove web counter"
	| object lowercaseUrl |
	lowercaseUrl := self lowercaseUrl: aString.
	self site critical:
		[object := (self allUrlLinks at: lowercaseUrl ifAbsent: [^nil]).
		(self allWebPages at: object) remove: lowercaseUrl ifAbsent: [].
		(self allWebPages at: object) isEmpty ifTrue: [self allWebPages removeKey: object]. 
		self allUrlLinks removeKey: lowercaseUrl.
		self counters removeKey: object ifAbsent: [] ].
	^true! !


!URLResolver methodsFor: 'static pages' stamp: 'janko 3/19/2012 15:15'!
allHTMLPagesSize
	"sums sizes of all static pages"

	| fname sum |
	sum := 0.
	self allHtmlPageUrls do: [:url | 
		fname := self site homeDirectory, url.
		fname := fname copyReplaceAll: '/' with: '\'.
		fname asFilename exists 
			ifTrue: [sum := sum + fname asFilename fileSize] ].
	^sum

"URLResolver default allHTMLPagesSize"! !

!URLResolver methodsFor: 'static pages'!
allHtmlPageUrls
	"find all .htm and .html pages in directory hierarchy starting at aWebServer homeDirectory.
	return as collection of relative url links"

	^self allHtmlPageUrlsIn: self site homeDirectory.

"URLResolver default allHTMLPageUrls"! !

!URLResolver methodsFor: 'static pages'!
allHtmlPageUrlsIn: aDirectoryString
	"find all .htm and .html pages in directory hierarchy starting at a specified directory and all 	subdirectories.	Return as collection of relative url links"

	| collection dir |
	dir := aDirectoryString.
	dir last ~= $\ ifTrue: [dir := dir, '\'].
	dir asFilename exists ifFalse: [^#()].
	collection := OrderedCollection new.
	aDirectoryString asFilename directoryContents do: [:each | 
		(dir, each) asFilename isDirectory
			ifTrue: [collection addAll: (self allHtmlPageUrlsIn: (dir, each))]
			ifFalse: 
				[('.htm' match: each asFilename extension) ifTrue:
					[collection add: (self urlForFile: each asString directory: aDirectoryString)] ]
		].
	^collection.

"URLResolver default allHTMLPageUrlsIn: 'h:\wwwroot\planid' "! !

!URLResolver methodsFor: 'static pages'!
allHtmlPagesSize
	"sums sizes of all static pages"

	| fname sum |
	sum := 0.
	self allHtmlPageUrls do: [:url | 
		fname := self site homeDirectory, url.
		fname := fname copyReplaceAll: '/' with: '\'.
		fname asFilename exists 
			ifTrue: [sum := sum + fname asFilename fileSize] ].
	^sum

"URLResolver default allHTMLPagesSize"! !

!URLResolver methodsFor: 'static pages'!
refreshAllHtmlPages
	""

	| count |
	count := 1.
	self allWebPages keys do: [:object |
		(object isKindOf: FileProxy) ifTrue:	 
			[count \\ 10 = 0 ifTrue: [Transcript cr; show: count printString].
			object refreshContent.
			count := count + 1] ].

"URLResolver default refreshAllHTMLPages"! !

!URLResolver methodsFor: 'static pages'!
registerAllHtmlPages
	"if not already, then register all static html pages in directory hierarchy starting
	at aWebServer homeDirectory. Opan also counters for them"

	| count proxy |
	count := 1.
	self allHtmlPageUrls do: [:url | 
		count \\ 10 = 0 ifTrue: [Transcript cr; show: count printString].
		proxy := self objectOnUrl: url.
		self counterFor: proxy.
		count := count + 1].

"URLResolver default registerAllHTMLPages"! !

!URLResolver methodsFor: 'static pages' stamp: ' 21/4/07 22:07'!
releaseAllHTMLPages

	self allWebPages keys do: [:obj |
		(obj isKindOf: FileProxy) ifTrue:
	 		[obj releaseContent] ]

"URLResolver default releaseAllHTMLPages"! !

!URLResolver methodsFor: 'static pages'!
releaseAllHtmlPages

	self allWebPages keys do: [:obj |
		(obj isKindOf: FileProxy) ifTrue:
	 		[obj releaseContent] ]

"URLResolver default releaseAllHTMLPages"! !

!URLResolver methodsFor: 'static pages'!
releaseAllImages
	self allWebPages keys do: [:obj |
		((obj isKindOf: FileProxy) and: ['*image*' match: obj aidaContentType])
			ifTrue: [obj releaseContent] ]

"URLResolver default releaseAllImages"! !

!URLResolver methodsFor: 'static pages' stamp: ' 21/4/07 22:07'!
releaseAllStaticPages

	self allWebPages keysDo: [:object | 
		(object isKindOf: FileProxy) ifTrue: [object releaseContent] ]

"URLResolver default releaseAllStaticPages"! !

!URLResolver methodsFor: 'static pages' stamp: ' 21/4/07 22:07'!
urlForFile: aFilenameString directory: aDirectoryString

	| path dir |
	dir := aDirectoryString.
	dir last ~= $\ ifTrue: [dir := dir, '\'].
	path := dir, aFilenameString.
	path := path copyReplaceAll: self site homeDirectory with: ''.
	^path copyReplaceAll: '\' with: '/'

"URLResolver default urlForFile: 'index.htm' directory: 'h:\wwwroot\planid\osn' "! !


!URLResolver methodsFor: 'private'!
allUrlLinks
	"return a dictionary with url as key and reference to an object with that url as value"
	^allURLLinks! !

!URLResolver methodsFor: 'private' stamp: ' 21/4/07 22:07'!
allWebPages
	" return a dictionary with object reference as key and one on more urls for that object as value.
	first  is default one, when urls are dinamicaly generated"
	^allWebPages! !

!URLResolver methodsFor: 'private' stamp: 'janko 4/20/2012 17:17'!
autoUrlFor: anObject
	"use preferred url if possible. If that url already exist, add -a, -b, ... to url and repeat"
	| url extension lastPoint |
	url := anObject preferredUrl. url isNil ifTrue: [^self randomUrlFor: anObject].
	(url size >= 1 and: [url first = $/]) ifFalse: [self error: 'preferredUrl must start with / '].
	[(self objectOnUrl: url) notNil] whileTrue: "already exist"
		[lastPoint := url lastIndexOf: $. . lastPoint = 0 ifTrue: [lastPoint := url size+1].
		extension := url copyFrom: lastPoint to: url size.
		url := url copyReplaceAll: extension with: ''. 
		url isEmpty ifTrue:  [^self randomUrlFor: anObject].
		(url size > 1 and: [(url at: url size-1) = $-]) "already have an extension char!!"
			ifTrue: 
				[url last = $z ifTrue: [^self randomUrlFor: anObject]. "only to $z, then back to random!!"
				url := (url copyFrom: 1 to: url size-1), (String with: (url last asInteger + 1) asCharacter)]
			ifFalse: [url := url, '-a'].
		url := url, extension].
	^url

"URLResolver default halfUrlFor: (Document new id: 'SOP-0111-02').
URLResolver default autoUrlFor: (Document new id: 'SOP-0111-02')"! !

!URLResolver methodsFor: 'private'!
correctUrlEncoding
	"make sure all urls are decodedHTTP, without %20 etc"
	self allUrlLinks keys do: [:key | (key decodedHTTP ~= key) 
		ifTrue: [self allUrlLinks at: key decodedHTTP put: (self allUrlLinks at: key). 
			self allUrlLinks removeKey: key] ].
	self allWebPages values do: [:coll |
	coll copy do: [:each | (each decodedHTTP ~= each) 
		ifTrue: [coll at: (coll indexOf: each) put: each decodedHTTP] ] ].

"
self allURLLinks keys select: [:key | (key decodedHTTP ~= key)].
self allWebPages associations select: [:assoc |
	assoc value contains: [:each | (each decodedHTTP ~= each)] ].
"! !

!URLResolver methodsFor: 'private' stamp: ' 21/4/07 22:07'!
counters

	"dictionary of web counters for every object, registered in URLResolver"

	counters isNil ifTrue: [self initCounters].
	^counters.! !

!URLResolver methodsFor: 'private'!
findHostPortOn: aSession
	"finds hostname and port for complete url. Returns association host->port"
	| host session|
	(self site host ~= '*') ifTrue:  "host ant port clearly defined in site's url identifier"
		[^self site host-> self site port]. 
	session := aSession notNil ifTrue: [aSession] ifFalse: [self firstSessionFromStack].
	session ifNil: 
		[session := self site sessionManager sessions values asOrderedCollection 
			detect: [:each | each lastRequest notNil] ifNone: [nil] ]. "good enough?" 
	session ifNil: [^'localhost'->self site port].
	host := (session lastRequest 
		headerAt: 'x-forwarded-host'   "find host from request"
		ifAbsent: [[session lastRequest host ]]) value. 
	^host->self site port! !

!URLResolver methodsFor: 'private' stamp: ' 21/4/07 22:07'!
isWebElement: anObject


	" test if anObject is a web element, such as web app and write warning to the transcript"
	
	(anObject isKindOf: WebElement) ifTrue:
		[Transcript cr; show: '*** WARNING: URLResolver detected a ', 
		anObject class printString, '  will be registered ***'; cr.

		"to detect from where this request comes"
		"self halt"
		].! !

!URLResolver methodsFor: 'private'!
lowercaseUrl: aString
	"prepare url to be lowercase, trim blanks, without spaces in beetween"
	| url |
	url := aString trimBlanks asLowercase.
	url := url copyWithout: $ .
	url := url copyWithout: Character tab.
	^url

"URLResolver default lowercaseUrl: ' /doc/     yep  Yap YUP ' "! !

!URLResolver methodsFor: 'private' stamp: ' 21/4/07 22:07'!
randomGen
	randomGen isNil ifTrue: [self randomGen: Random new].
	^randomGen! !

!URLResolver methodsFor: 'private' stamp: ' 21/4/07 22:07'!
randomGen: anObject
	randomGen := anObject! !

!URLResolver methodsFor: 'private'!
randomUrlFor: anObject
	| number ext url |
	number := (self site class random next * 10000000) asInteger.
	ext := self site mimeMap extensionForType: anObject aidaContentType.
	ext := ext isNil ifTrue: [''] ifFalse: ['.', ext].
	url := '/object/o', number printString, ext.
	^(self objectOnUrl: url) isNil  "avoid duplicates!!"
		ifTrue: [url]
		ifFalse: [self randomUrlFor: anObject]! !

!URLResolver methodsFor: 'private'!
regenerateAllUrlLinks
	"from urls in allWebPages"
	"AIDASite default urlResolver regenerateAllUrlLinks"
	self allWebPages keysAndValuesDo: [:object :urls |
		urls do: [:url | self allUrlLinks at: url put: object] ].! !

!URLResolver methodsFor: 'private' stamp: ' 21/4/07 22:07'!
site
	"a parent site with this url resolver"
	^site! !

!URLResolver methodsFor: 'private' stamp: ' 21/4/07 22:07'!
site: anAIDASite
	site := anAIDASite.! !


!URLResolver methodsFor: 'private-obsolete'!
changeToPreferedURL: aString
	"OBSOLETE!!"
	^self changeToPreferredUrl: aString! !

!URLResolver methodsFor: 'private-obsolete'!
defaultURL: aString forObject: anObject
	"OBSOLETE!!"
	^self defaultUrl: aString for: anObject! !

!URLResolver methodsFor: 'private-obsolete'!
existURL: aString
	"OBSOLETE!!"
	^self existUrl: aString! !

!URLResolver methodsFor: 'private-obsolete'!
ooRefFromURL: aString
	"OBSOLETE!!"
	^self objectOnUrl: aString! !


!URLResolver methodsFor: 'testing'!
existObject: anObject
	"true if this object is registered on son Url"
	^self allWebPages includesKey: anObject! !

!URLResolver methodsFor: 'testing'!
existUrl: aString
	"return true if URL has connection to some object"
	^self allUrlLinks includesKey: aString asLowercase! !


!URLResolver methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
fullUrlEncodedSpacesFor: anObject on: aSession
	"change spaces to %20"
	^(self fullUrlFor: anObject on: aSession) copyReplaceAll: ' ' with: '%20'! !

!URLResolver methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
fullUrlFor: anObject on: aSession
	"find or make a path for anObject and compose full url together with server address and 
	query string, eg: http://www.eranova.si/welcome.html?view=brief"
	^self 
		fullUrlFromPath: (self halfUrlFor: anObject)
		andParms: (aSession notNil ifTrue: [aSession parms] ifFalse: [#()])
		on: aSession! !

!URLResolver methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
fullUrlFromPath: aPathString andParms: aParmsDictionary on: aSession
	"compose full url: server address, document path and additional parameters in query string, 
	for instance: http://www.eranova.si/welcome.html?view=brief"
	| url |
	url := self urlFromHalfUrl: aPathString on: aSession.
	^self halfUrlFromPath: url andParms: aParmsDictionary on: aSession. "not very nice, i know ..."
	
"
| parms |
parms := Dictionary new.
parms at: 'view' put: 'brief'. parms at: 'id' put: '12345'. 
URLResolver default fullUrlFromPath: '/dzs/panorama.html' andParms: parms on: WebSession new
"! !

!URLResolver methodsFor: 'accessing'!
halfUrlFor: anObject
	"finds or composes an URL reference to that object . If the URL is new one, then it is written to both dictionaries for later lookup. If resolution is unsuccessfull then returns nil. If anObject dont have an url yet, url part for them is automatically generated, for example:  /objecto1638948.html"
	| newUrl urls |
	urls := (self allWebPages at: anObject ifAbsent: [
	      newUrl := ((anObject isKindOf: WebPage)  and: [anObject title notNil] )
			ifTrue: ['/', anObject title asLowercase,'.html']			
			ifFalse: [self autoUrlFor: anObject].
		self addObject: anObject withUrl: newUrl.
		OrderedCollection with: newUrl]).
	"just in case object has an empty collection of urls"
	(urls isNil or: [urls isEmpty]) ifTrue: 
		[self removeObject: anObject. ^self halfUrlFor: anObject].
	^urls at: 1.! !

!URLResolver methodsFor: 'accessing' stamp: 'janko 3/21/2008 16:51'!
halfUrlFromPath: aPathString andParms: aParmsDictionary on: aSession
	"compose half url: /document path and additional parameters in query string, for instance: 	/welcome.html?view=brief"
	| url parmsString newValue |
	url := aPathString.
	aParmsDictionary size > 0 ifTrue:
		[parmsString := ''.
		aParmsDictionary keysAndValuesDo: [:name :value |
			(value isKindOf: Set) ifTrue:[newValue := value asArray at: 1]ifFalse:[newValue := value].
			parmsString := parmsString, 
				(AIDASite convertToWebString: name asString), '=', 
				(AIDASite convertToWebString: newValue asString), '&'].  "value"
		url := url, '?', (parmsString copyFrom: 1 to: (parmsString size - 1))].
	^url

"
| parms |
parms := Dictionary new.
parms at: 'view' put: 'brief'. parms at: 'id' put: '12345'. 
URLResolver default halfUrlFromPath: '/dzs/panorama.html' andParms: parms on: WebSession new
"! !

!URLResolver methodsFor: 'accessing'!
objectOnDifferentPresentationUrl: aString
	"check if different representation (like .json or .xml) is requested and 
       returns its object by skipping the extension in URL"
	| url |
	url := aString asLowercase.
	url := ('*.json' match: url)
		ifTrue: [url copyReplaceAll: '.json' with: '']
		ifFalse: [	('*.xml' match: url)
			ifTrue: [url copyReplaceAll: '.xml' with: '']
			ifFalse: [url "later for more"] ].
	^self allUrlLinks at: url ifAbsent: [nil]! !

!URLResolver methodsFor: 'accessing'!
objectOnUrl: aString
	" finds a reference to an object, specified by that URL string. If not yet known, try to 
	find it as a html file. If not found, check if different representation (like .json or .xml) is requested"
	| object |
	^self allUrlLinks at: aString asLowercase ifAbsent: 
		["object := self fileProxyForURL: aString." "moved to router and staticServer"
		self site staticServer. "just to create it od not yet = lazy migration"
		object := self objectOnDifferentPresentationUrl: aString. "like .json or .xml"
		^object]. "or nil"

"URLResolver default objectOnURL: '/osn/g_l-vse.htm' "! !

!URLResolver methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
objectsOfClass: aClass
	^self allWebPages keys select: [:object | object class = aClass ]

"URLResolver default objectsOfClass: WebMethodImage"! !

!URLResolver methodsFor: 'accessing'!
resourceFor: aRequest
	"returns a resource (domain object) to respond to that request"
	| url | 
	url := AIDASite convertFromWeb: aRequest uriString on: aRequest session.  "for international Urls"
	^self objectOnUrl: url! !

!URLResolver methodsFor: 'accessing'!
scanForUrlsFrom: aWebPage

"start looking for all WebLinks in pages starting from aWebPage and converting them to the URL links in instance variables allWebPages and allURLLinks."! !

!URLResolver methodsFor: 'accessing'!
urlFromHalfUrl: aString on: aSession
	| host port hostPort portString protocolString |
	hostPort := self findHostPortOn: aSession.
	host := hostPort key. port := hostPort value.
	portString := self site behindProxy "like Apache reverse proxy"
		ifTrue: ['']  "assume that proxy always run on 80 or 443"
		ifFalse:
			[(aSession notNil and: [aSession isEncrypted]) 
				ifFalse: 
					[(port = 80) 
						ifTrue: [''] 
						ifFalse: [':', port printString] ]
				ifTrue: 
					[(self site sslPort = 443) 
						ifTrue: [''] 
						ifFalse: [':', self site sslPort printString] ] ].
	protocolString := (aSession notNil and: [aSession isEncrypted])  
		ifFalse: ['http://'] 
		ifTrue: ['https://'].
	^protocolString, host asLowercase, portString, aString.! !


!URLResolver methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initCounters
	"init a counters dictionary and open a new counter for each already registered object"
	counters := Dictionary new. 
	self allWebPages keys do: [:object | self resetCounterFor: object].! !

!URLResolver methodsFor: 'initialize-release'!
initUrlLinks
	allURLLinks := Dictionary new.! !

!URLResolver methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initWebPages
	allWebPages := IdentityDictionary new.! !

!URLResolver methodsFor: 'initialize-release'!
initialize
	self initWebPages.
	self initUrlLinks.
	self initCounters.! !


!URLResolver methodsFor: 'indexing'!
reindexAllObjects
	"all text/html objects are reindexed"
	self allWebPages keysDo: [:object |
		(object aidaContentType = 'text/html') ifTrue:
			[self site index indexObject: object] ]

"URLResolver default reindexAllObjects"! !

!URLResolver methodsFor: 'indexing'!
reindexNonIndexedObjects
	"all text/html objects are reindexed"
	self allWebPages keysDo: [:object |
		(object aidaContentType = 'text/html') ifTrue:
			[(self site index indexedObjects includesKey: object) ifFalse:
				[self site index indexObject: object] ] ]

"URLResolver default reindexNonIndexedObjects"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

URLResolver class
	instanceVariableNames: ''!

!URLResolver class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
default
	^AIDASite default urlResolver! !


!URLResolver class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newOn: anAIDASite
	^super new 
		initialize; 
		site: anAIDASite! !


Object subclass: #WebIndex
	instanceVariableNames: 'index indexedObjects popularWords workQueue indexer'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Core'!
!WebIndex commentStamp: '<historical>' prior: 0!
WebIndex is a search engine, which index words in a domain object, weightinh their importance (words in header more important etc.), then search for domain objects containing searched keywords (see also WebIndexApp).!


!WebIndex methodsFor: 'searching'!
addFreshnessRelevance: aDictionary
	"objects with newer modified date are more relevant"
	| weight |
	aDictionary keysDo: [:object |
		(object class selectors includes: #modified) ifTrue:
			[weight := 1000 - (SpDate today asDays - object modified asDays) max: 0.
			aDictionary at: object put:  (aDictionary at: object) + weight] ]! !

!WebIndex methodsFor: 'searching'!
addVisitsRelevance: aDictionary
	"objects with more visits are more relevant"
	| weight |
	aDictionary keysDo: [:object |
		(object class selectors includes: #modified) ifTrue:
			[weight := 1000 - (SpDate today asDays - object modified asDays) max: 0.
			aDictionary at: object put:  (aDictionary at: object) + weight] ]! !

!WebIndex methodsFor: 'searching'!
objectsForWord: aString
	"find all objects, which include this word. Return a dictionary with objects as 
       keys and weights as values" 
	"only current versions of versioned object like documents!!"
	| objDict |
	objDict := self privObjectsForWord: aString.
	objDict := objDict keysDo: [:object | 
		((object isKindOf: VersionedObject) and: [object isCurrentVersion not])
			ifTrue: [objDict removeKey: object] ].
	^objDict

"(WebIndex default objectsForWord: 'knjiga') keys "! !

!WebIndex methodsFor: 'searching' stamp: ' 21/8/07 09:38'!
objectsForWords: aString
	"find all objects, which include one or more specified words. return a sorted collection 
	of associations with found objects as keys an relevance of them as values. Most relevant 
	objects are first. Relevance means: 
		nr. of words found * 1000 + occurences of each word"
	| words hits newHits foundWords |
	Transcript show: ' search.'.
	words := (self wordsInText: aString) keys.
	words := words select: [:word | self isValidWord: word].
	hits := IdentityDictionary new.
	foundWords := OrderedCollection new. 
	words do: [:word | 
		newHits := self objectsForWord: word.
		newHits notEmpty ifTrue: [foundWords add: word].
		newHits keysAndValuesDo: [:key :value |
			(hits includesKey: key)
				ifTrue: [hits at: key put: (hits at: key)+1000]
				ifFalse: [hits at: key put: 1000+value] ] ].
	self countPopularWords: foundWords.  "count as popular only words, which exist in objects"
	self addFreshnessRelevance: hits.
	Transcript show: '.ok '.
	^SortedCollection withAll: hits associations sortBlock: [:first : second | first value > second value].

"
WebIndex instance objectsForWords: 'ljub'
"! !


!WebIndex methodsFor: 'popular words' stamp: ' 21/8/07 09:38'!
allPopularWordsAndCounts
	"return a collection of words and their total counts, most popular first"
	| collection |
	collection := OrderedCollection new.
	self popularWords keysAndValuesDo: [:word :counter |  
		collection add: (Array with: word with: counter total)].
	^SortedCollection
		withAll: collection
		sortBlock: [:a :b | (a at: 2) > (b at: 2)].! !

!WebIndex methodsFor: 'popular words' stamp: ' 21/8/07 09:38'!
countPopularWords: anArray
	anArray do: [:word |
		(self popularWords includesKey: word) ifFalse: [self openPopularWord: word].
		(self popularWords at: word) incCounter].! !

!WebIndex methodsFor: 'popular words' stamp: ' 21/4/07 22:07'!
openPopularWord: aString
	self popularWords at: aString put: WebCounter new.! !


!WebIndex methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
allWordsAndWeights
	"return sorted collection of all words and sum of weights, biggeest weight first"
	| collection weight |
	collection := OrderedCollection new.
	self index keysDo: [:halfWord |
		(self index at: halfWord) keysDo: [:restWord |
			weight := ((self index at: halfWord) at: restWord) inject: 0 into: 
				[:sum :thirdDictWeight | sum + (thirdDictWeight)].
			collection add: (Array with: halfWord, restWord with: weight) ] ].
	^SortedCollection 
		withAll: collection
		sortBlock: [:a :b | (a at: 2) > (b at: 2)].

" WebIndex default allWordsAndWeights "! !

!WebIndex methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
index
	"index is a dictionary with first three lowercase letters of each indexed world as key and
	another dictionary for remaining letters as value. The second dictionary has remaining letters for key
      and dictionary with objects, where this word occured, as key and number of occurences as value"
	index isNil ifTrue: [self initIndex].
	^index! !

!WebIndex methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
indexText
	^'Search engine iskanje rezultati iskanja iskalnik'! !

!WebIndex methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
indexTitle
	^'Iskalnik'! !

!WebIndex methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
indexedObjects
	"return a dictionary with objects which worlds are in index as keys and a set of pointers to third 
       level dictionary in index as values"
	indexedObjects isNil ifTrue: [self initIndexedObjects].
	^indexedObjects! !

!WebIndex methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
popularWords
	"return a dictionary of words as keys and aWebCounters as values"
	popularWords isNil ifTrue: [self initPopularWords].
	^popularWords! !


!WebIndex methodsFor: 'private' stamp: ' 21/8/07 09:38'!
halfWordFrom: aString
	"prepare first three letters, lowercase (also slovene chars)"
	^AIDASite sloveneLowercase: (aString copyFrom: 1 to: 3).! !

!WebIndex methodsFor: 'private' stamp: 'mivsek 6/13/2007 16:25'!
indexer
	"indexing process"
	^indexer! !

!WebIndex methodsFor: 'private' stamp: 'mivsek 6/13/2007 16:26'!
indexerProcess
	"this background process wait for objects to be indexed in workQueue and
	index them without disturbing others."
	| object |
	[true] whileTrue: 
		[object := self workQueue next.
		self privIndexObject: object.
		self reportIndexingOf: object].! !

!WebIndex methodsFor: 'private' stamp: 'mivsek 6/13/2007 16:31'!
workQueue
	"all object to be indexed goes in this queue. An indexer process (which is started first time
	someone requests indexing) then index an object in background"

	workQueue isNil ifTrue: 
		[workQueue := SharedQueue new.
		self indexer isNil ifTrue: [self start] ].
	^workQueue.! !


!WebIndex methodsFor: 'indexing' stamp: ' 21/8/07 09:38'!
indexObject: anObject
	"if anObject responds to a message indexText, then index all its world in index.
	 However, first 	remove indexing for that object if already exist (so, for reindexing  
	objects, use this method also). For performance reasons indexing is done in background"
	self workQueue nextPut: anObject.

"WebIndex default indexObject: WebIndex default"! !

!WebIndex methodsFor: 'indexing' stamp: ' 21/4/07 22:07'!
indexObjects: aCollection
	aCollection do: [:each | self indexObject: each].! !

!WebIndex methodsFor: 'indexing' stamp: ' 21/8/07 09:38'!
indexWord: aString inObject: anObject
	"put a word in that object in index if word is valid one for indexing"
	self indexWord: aString occurences: 1 inObject: anObject! !

!WebIndex methodsFor: 'indexing' stamp: ' 21/8/07 09:38'!
removeObject: anObject
	"remove object from all word pointers in index"
	(self indexedObjects at: anObject ifAbsent: [^nil]) do:
		[:each | each removeKey: anObject ifAbsent: [] ].
	self indexedObjects removeKey: anObject.! !

!WebIndex methodsFor: 'indexing'!
wordsInText: aString
	"return a dictionary with all words as keys and number of occurences as values"
	| lastInx currInx word words |
	lastInx := 1. currInx := 1. words := Dictionary new. 
	aString do: [:chr | 
		(chr isAlphaNumeric or: [AIDASite isSloveneCharacter: chr]) ifFalse: 
			[word := aString copyFrom: lastInx to: currInx-1.
			lastInx := currInx+1.
			word := AIDASite sloveneLowercase: word.
			word notEmpty ifTrue: 
				[(words includesKey: word) ifFalse: [words at: word put: 0].
				words at: word put: (words at: word) + 1] ].
		currInx := currInx + 1].
	word := aString copyFrom: lastInx to: currInx-1.
	word := AIDASite sloveneLowercase: word.
	word notEmpty ifTrue: 
		[(words includesKey: word) ifFalse: [words at: word put: 0].
		words at: word put: (words at: word) + 1].
	^words

"
WebIndex default wordsInText: 'erot ljub'
"! !


!WebIndex methodsFor: 'private-indexing'!
indexWord: aString occurences: aNumber inObject: anObject
	"put a aNumber occurences of a word in that object in index if word is valid one for indexing"
	| halfWord restWord secDic thirdDic num |
	(self isValidWord: aString) ifFalse: [^self].
	"put an object in indexed object, if not already exist"
	(self indexedObjects includesKey: anObject) ifFalse:
		[self indexedObjects at: anObject put: IdentitySet new].
	"prepare two parts of a words, first three letters and rest"
	halfWord := self halfWordFrom: aString.
	restWord := self restWordFrom: aString.
	"find or create a second level dictionary from first level one"
	secDic := self index at: halfWord 
		ifAbsent: [self index at: halfWord put: Dictionary new].
	"find or create last level dictionary from second level one"
	thirdDic := secDic at: restWord 
		ifAbsent: [secDic at: restWord put: Dictionary new].
	"put an object to third level dictionary and increment nr of worlds if not already exist"
	num := thirdDic at: anObject ifAbsent: [thirdDic at: anObject put: 0].
	thirdDic at: anObject put: num + aNumber.
	"make reference to the third level dictionary for a indexed word"
	(self indexedObjects at: anObject) add: thirdDic.! !

!WebIndex methodsFor: 'private-indexing'!
indexWords: aWordDictionary inObject: anObject
	self removeObject: anObject.  "if exist"
	aWordDictionary keysAndValuesDo: [:key :value | 
		self indexWord: key occurences: value inObject: anObject].! !

!WebIndex methodsFor: 'private-indexing'!
prepareWord: aString
	"cut last char if vowel. Used for simple declension of slovene words"
	aString last isVowel 
		ifTrue: [aString size > 3
			ifTrue: [^aString copyFrom: 1 to: (aString size - 1)] ].
	^aString.

"
WebIndex new prepareWord: 'knjiga'
"! !

!WebIndex methodsFor: 'private-indexing'!
privIndexObject: anObject
	"index all words in text. Index title with weight 100 as well"
	| textDict titleDict |
	(anObject class canUnderstand: #indexText) ifTrue:
		[textDict := self wordsInText: anObject indexText.
	(anObject class canUnderstand: #indexTitle) ifTrue:
		[titleDict := self wordsInText: anObject indexTitle].
		titleDict keysDo: [:word | titleDict at: word put: (titleDict at: word)*100]. "weight words in title 100x"	
		titleDict keysDo: [:word | 
			(textDict includesKey: word) 
				ifFalse: [textDict at: word put: (titleDict at: word)]
				ifTrue: [textDict at: word put: (textDict at: word) + (titleDict at: word)] ] ].	
	self indexWords: textDict inObject: anObject! !

!WebIndex methodsFor: 'private-indexing'!
reportIndexingOf: anObject
	| text site |
	[text := anObject class name.
	site := [anObject repository site name] on: Error do: [:ex | ''].
	(anObject isKindOf: Document) ifTrue: 
		[text := text, ' "', anObject title asSloveneWithoutCircumflexes,  '" on ', site.
		anObject modifiedBy notNil ifTrue:
			[text := text, ' by ', anObject modifiedBy nameSurname asSloveneWithoutCircumflexes] ].
	(anObject isKindOf: FileProxy) ifTrue: 
		[text := text, ' "', anObject filename asString, '" on ', anObject site name].
	Transcript cr; show: '(indexing  ', text, ')']
		fork. "to prevent stoping indexer in case of error"! !

!WebIndex methodsFor: 'private-indexing'!
restWordFrom: aString
	"preparerest of the word, lowercase (also slovene chars)"
	^AIDASite sloveneLowercase: (aString copyFrom: 4 to: aString size)! !


!WebIndex methodsFor: 'initialize-release' stamp: ' 21/8/07 09:38'!
initIndex
	index := Dictionary new.! !

!WebIndex methodsFor: 'initialize-release' stamp: ' 21/8/07 09:38'!
initIndexedObjects
	indexedObjects := IdentityDictionary new.! !

!WebIndex methodsFor: 'initialize-release' stamp: ' 21/8/07 09:38'!
initPopularWords
	popularWords := Dictionary new.! !

!WebIndex methodsFor: 'initialize-release' stamp: 'mivsek 6/13/2007 16:26'!
initialize
	self initIndex.
	self initIndexedObjects.
	self initPopularWords.
	workQueue := nil.
	self start.

"WebIndex default initialize"! !


!WebIndex methodsFor: 'testing'!
isValidWord: aString
	"a valid word for indexing has three or more letters, can have also numbers "
	(aString size >= 3) ifFalse: [^false].
"	aString do:[:chr | chr isDigit ifTrue: [^false] ]. " "no more!!"
	^true! !


!WebIndex methodsFor: 'private-searching'!
privObjectsForWord: aString
	"find all objects, which include this word. Return more important objects first (more 
	occurences of worlds etc.)"
	| hits secDic searchWord keys word |
	(self isValidWord: aString) ifTrue:
		[hits := IdentityDictionary new.
		word := self prepareWord: aString.
		searchWord := (self restWordFrom: word), '*'.
		secDic := self index at: (self halfWordFrom: word) ifAbsent: [^hits].
		keys := secDic keys select: [:fkey | searchWord match: fkey].
		keys do: [:skey | 
       		(secDic at: skey) keysAndValuesDo: [:tkey :tvalue | 
				(hits includesKey: tkey) ifFalse: [hits at: tkey put: 0].
				hits at: tkey put: (hits at: tkey)+tvalue] ].
		^hits.
		] ifFalse: [^nil].

"(WebIndex default objectsForWord: 'knjiga') keys "! !


!WebIndex methodsFor: 'start/stop'!
start
	self stop.
	indexer := [self indexerProcess] 
		forkAt: Processor userBackgroundPriority.! !

!WebIndex methodsFor: 'start/stop'!
stop
	self indexer notNil ifTrue: 
		[self indexer terminate. 
		indexer := nil].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebIndex class
	instanceVariableNames: ''!

!WebIndex class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
default
	^AIDASite default index! !


!WebIndex class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
instVarMap
	"Gemstone"

	^super instVarMap,
		#( 	(workQueue nil) )! !

!WebIndex class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
replicationSpec

	^super replicationSpec, 
		#(  	(index forwarder)
			(indexedObjects forwarder) 
			(popularWords forwarder)  	)! !


!WebIndex class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize.

"WebIndex new"! !


Object subclass: #WebScheduler
	instanceVariableNames: 'site queue loop mutex resolution priority'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Core'!
!WebScheduler commentStamp: 'jmivsek 4/26/2020 21:57' prior: 0!
WebScheduler is a service for running scheduled events. Events can be single or periodic (daily, hourly, ...).
When event is triggered, its block is executed in a separate low priority process. Scheduler time resolution can be set, minimal 1ms, by default 1 second. 

Example of periodic event:
	self site scheduler everyHourAt: 30 "minutes" runBlock: [Trascript show: 'half a hour!!].

Instance Variables:
	site		<anAIDASite>	
	queue	<OrderedCollection>	queue of events, waiting for execution
	loop	<Process>		loop process, every second looks into queue to run an event
	mutex	<AidaMutex>   to protect queue operations
	resolution <anInteger> period of checking for events, min 1ms, default 1s	

!


!WebScheduler methodsFor: 'events-single'!
at: aSpTimestamp callMethod: aSymbol of: anObject
	| event |
	event := WebScheduledEvent newOn: self.
	event 
		at: aSpTimestamp asSpTimestamp
		callMethod: aSymbol 
		of: anObject.
	event start.
	^event! !

!WebScheduler methodsFor: 'events-single'!
at: aSpTimestamp runBlock: aBlock
	| event |
	event := WebScheduledEvent newOn: self.
	event 
		at: aSpTimestamp asSpTimestamp 
		runBlock: aBlock.
	event start.
	^event! !

!WebScheduler methodsFor: 'events-single'!
removeEvent: anEvent
	"stop running  this single or periodic event"
	self 
		removeEvent: anEvent
		ifAbsent: [self error: 'Scheduler: this event does not exist']! !

!WebScheduler methodsFor: 'events-single'!
removeEvent: anEvent ifAbsent: aBlock
	"stop running  this single or periodic event"
	self critical: 
		[self queue 
			remove: anEvent
			ifAbsent: aBlock]! !


!WebScheduler methodsFor: 'private-queuing'!
considerMissedEvents
	"events which we miss to run, eg. if scheduler didn't run for a while"
	self removeMissedEvents "and nothing more, for now"! !

!WebScheduler methodsFor: 'private-queuing'!
delayExactPeriodFromNowMs: anInteger
	"Ensure that delay is long exactly to a rounded resolution. If resolution is a second then wait until the next second"
	| nowMs nowMsTruncated delayMs |
	nowMs := anInteger.
      nowMsTruncated := nowMs - (nowMs \\ self resolution).	"truncated according to a resolution"
	delayMs := self resolution - (nowMs - nowMsTruncated).
	(Delay forMilliseconds: delayMs) wait.

"AIDASite new scheduler delayForExactPeriodFromNowMs: SpTimestamp now asMilliseconds"! !

!WebScheduler methodsFor: 'private-queuing'!
insertToQueueEvent: aScheduledEvent
	self critical:
		[self queue isEmpty 
			ifTrue: [^self queue add: aScheduledEvent].
		aScheduledEvent timestamp >= self queue last timestamp
			ifTrue: [^self queue add: aScheduledEvent].
		aScheduledEvent timestamp < self queue first timestamp 
			ifTrue: [^self queue addFirst: aScheduledEvent].
		self queue size to: 1 by: -1 do: [:inx |
			aScheduledEvent timestamp >= (queue at: inx) timestamp ifTrue: 
				[^self queue add: aScheduledEvent beforeIndex: inx+1] ].
		self error: 'rescheduling error!!'.  "in case any of above conditions don't satisfy"
		]! !

!WebScheduler methodsFor: 'private-queuing'!
queue
	"queue of events next one to run on first place"
	queue isNil ifTrue: [self initQueue].
	^queue! !

!WebScheduler methodsFor: 'private-queuing'!
queueProcessingLoop
	"to check every second (or some other resolution) if some event is to be run"
	[true] whileTrue: 
		[| event nowMs |
		nowMs := SpTimestamp now asMilliseconds.
		self critical: 
			[ [self queue notEmpty and: 
			 	[(event := self queue first) timestamp asMilliseconds  "get oldest event"
					between: nowMs - (self resolution/2) rounded
					and: nowMs + (self resolution/2) rounded]]
						whileTrue: "run all events to be run"
							[event run].  "also remove or reschedule if periodic event"
				(self queue notEmpty 
					and: [nowMs > self queue first timestamp asMilliseconds]) "still old events in queue"
						ifTrue: [self removeMissedEvents].
			 ] "critical".
		self delayExactPeriodFromNowMs: nowMs. "wait until next check"
		] "whileTrue"! !

!WebScheduler methodsFor: 'private-queuing'!
removeMissedEvents
	"remove but also reschedule if missed event was periodic"
	"Missed event because of too long running event's task?"
	| nowMs event |
	self critical:
		[self queue isEmpty ifTrue: [^nil].
		nowMs := SpTimestamp now asMilliseconds.
		[nowMs > self queue first timestamp asMilliseconds] 
			whileTrue:
				[event := self queue first.
				self queue removeFirst.
				event isPeriodic ifTrue: [event reschedule].
				self queue isEmpty ifTrue: [^nil] ]
		]! !

!WebScheduler methodsFor: 'private-queuing'!
reportState
	"list all scheduled events, for debugging"
	Transcript cr; show: '--scheduler queue at ', SpTimestamp now printString.
	self queue do: [:event |
		Transcript cr; show: '---scheduled event ', event period printString, 
			' at ', event timestamp printString]! !

!WebScheduler methodsFor: 'private-queuing'!
scheduleEvent: aScheduledEvent
	self insertToQueueEvent: aScheduledEvent.! !

!WebScheduler methodsFor: 'private-queuing'!
schedulerPriority
	^Processor userInterruptPriority! !

!WebScheduler methodsFor: 'private-queuing'!
startLoop
	"to check every second if some event is to be run"
	self isRunning ifTrue: [self stopLoop].
	self loop: 
		([self queueProcessingLoop]
			forkAt: self schedulerPriority)! !

!WebScheduler methodsFor: 'private-queuing'!
stopLoop
	self loop ifNotNil: 
		[self loop terminate. 
		self loop: nil].! !


!WebScheduler methodsFor: 'private'!
critical: aBlock
	"run a block in a critical section (only one block at once!!)"
	^self mutex critical: aBlock! !

!WebScheduler methodsFor: 'private' stamp: ' 21/4/07 22:07'!
loop
	^loop! !

!WebScheduler methodsFor: 'private' stamp: ' 21/4/07 22:07'!
loop: aProcess
	loop := aProcess! !

!WebScheduler methodsFor: 'private'!
mutex
	"for protecting critical sections"
	mutex isNil ifTrue: [self initMutex].
	^mutex! !

!WebScheduler methodsFor: 'private'!
mutex: anAidaMutex
	mutex := anAidaMutex! !

!WebScheduler methodsFor: 'private' stamp: ' 21/4/07 22:07'!
printString
	^'aScheduler on site: ', (self site notNil ifTrue: [self site name] ifFalse: [''])! !

!WebScheduler methodsFor: 'private'!
priority
	"at which priority a main loop process is running"
	^priority! !

!WebScheduler methodsFor: 'private'!
priority: aNumber
	"at which priority a main loop process is running"
	^priority := aNumber! !

!WebScheduler methodsFor: 'private'!
resolution
	"period of checking for events, minimun 1ms, default 1s"
	resolution ifNil: [resolution := 1000]. "1s"
	^resolution! !

!WebScheduler methodsFor: 'private'!
resolution: milliseconds
	resolution := milliseconds! !

!WebScheduler methodsFor: 'private' stamp: ' 21/4/07 22:07'!
site
	^site! !

!WebScheduler methodsFor: 'private' stamp: ' 21/4/07 22:07'!
site: anAIDASite
	site := anAIDASite! !


!WebScheduler methodsFor: 'events-periodic'!
everyDayAt: aTimeOrHour runBlock: aBlock
	| event |
	event := WebScheduledEvent newOn: self.
	event 
		everyDayAt: aTimeOrHour 
		runBlock: aBlock.
	event start.
	^event! !

!WebScheduler methodsFor: 'events-periodic'!
everyHourAt: aMinuteNumber  runBlock: aBlock
	| event |
	event := WebScheduledEvent newOn: self.
	event 
		everyHourAt: aMinuteNumber  
		runBlock: aBlock.
	event start.
	^event! !

!WebScheduler methodsFor: 'events-periodic'!
everyMinuteAt: aSecondNumber callMethod: aSymbol of: anObject
	| event |
	event := WebScheduledEvent newOn: self.
	event 
		everyMinuteAt: aSecondNumber 
		callMethod: aSymbol 
		of: anObject.
	event start.
	^event! !

!WebScheduler methodsFor: 'events-periodic'!
everyMinuteAt: aSecondNumber  runBlock: aBlock
	| event |
	event := WebScheduledEvent newOn: self.
	event 
		everyMinuteAt: aSecondNumber  
		runBlock: aBlock.
	event start.
	^event! !

!WebScheduler methodsFor: 'events-periodic' stamp: ' 21/4/07 22:07'!
everyMonthday: aDayNumber at: aTime  runBlock: aBlock! !

!WebScheduler methodsFor: 'events-periodic'!
everySecondAt: aMillisecondNumber  runBlock: aBlock
	| event |
	event := WebScheduledEvent newOn: self.
	event 
		everySecondAt: aMillisecondNumber  
		runBlock: aBlock.
	event start.
	^event! !

!WebScheduler methodsFor: 'events-periodic' stamp: ' 21/4/07 22:07'!
everyWeekday: aDaySymbol at: aTime  runBlock: aBlock! !


!WebScheduler methodsFor: 'initialize-release'!
initMutex
	mutex := AidaMutex new! !

!WebScheduler methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initQueue
	queue := OrderedCollection new.! !


!WebScheduler methodsFor: 'testing'!
isRunning
	^self loop notNil! !

!WebScheduler methodsFor: 'testing'!
isScheduledBlock: aBlock
	"is this block aready scheduled in some event?"
	^self queue contains: [:event | event block = aBlock]! !

!WebScheduler methodsFor: 'testing'!
isScheduledEvent: aScheduledEvent
	"is event scheduled?"
	^self queue 
		includes: aScheduledEvent! !


!WebScheduler methodsFor: 'start/stop' stamp: ' 21/4/07 22:07'!
start
	self considerMissedEvents.
	self startLoop! !

!WebScheduler methodsFor: 'start/stop'!
stop
	self stopLoop.
	self mutex: nil! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebScheduler class
	instanceVariableNames: ''!

!WebScheduler class methodsFor: 'instance creation'!
newOn: anAIDASite
	^super new site: anAIDASite! !


Object subclass: #WebSecurityManager
	instanceVariableNames: 'site users groups authenticationScheme accessByObject settings'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Core'!
!WebSecurityManager commentStamp: '<historical>' prior: 0!
WebSecurityManager for user and group management, authentication and access control in web Apps. See WebSecurityManagerApp for setup security on the site.!


!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
accessByObject 
	"this is a dictionary of user - access level pairs for access to the object, 
	which reference is a key in dictionary"
	accessByObject isNil ifTrue: [self initAccessByObject].
	^accessByObject! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
accessRightsArray: anAccessSymbols for: aWebUserOrGroup on: anObject
	| objectRights rigthsArray |
	self site critical:
		[objectRights := self accessByObject at: anObject 
			ifAbsent: 
				[self accessByObject at: anObject put: (Dictionary new).
				self accessByObject at: anObject].
		rigthsArray := objectRights at: aWebUserOrGroup 
			ifAbsent:
				[objectRights at: aWebUserOrGroup put: IdentitySet new.
				objectRights at: aWebUserOrGroup].
		rigthsArray addAll: anAccessSymbols].! !

!WebSecurityManager methodsFor: 'private'!
addGroup: aWebUserGroup ifExist: aBlock
	"add new group. If already exist ( as object or as group with the same name) do aBlock"
 	(aWebUserGroup isKindOf: WebUserGroup) ifFalse: [^self error: 'This is not aWebUserGroup'].
	(self existGroupNamed: aWebUserGroup name) ifTrue: [aBlock value].
	^self groups add: aWebUserGroup! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
authenticationScheme: aSymbol
	authenticationScheme := aSymbol! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
copyAccessByObject
 
|dict|
Janko := Dictionary new.
WebSecurityManager default accessByObject 
keysAndValuesDo:
	[:key :value | 
		dict := Dictionary new.
		value keysAndValuesDo: [:key1 :value1 |
			dict at: key1 put: (IdentitySet withAll: (value1 collect: [:el | el asString asSymbol] )) ].
		Janko at: key put: dict].! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
defaultAccessRights
	
	^#()! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
groups 
	groups isNil ifTrue: [self initGroups].
	^groups! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
has: aWebUserOrGroup rightTo: anAccessSymbol on: anObject 
	"test the access right for that object and that user or group "
	| usersAndGroups |
	usersAndGroups := self accessByObject at: anObject ifAbsent: [^false].
	(usersAndGroups includesKey: aWebUserOrGroup)	ifTrue:
		[((usersAndGroups at: aWebUserOrGroup) includes: anAccessSymbol) ifTrue: [^true] ].
	^false! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
isDefaultAllowedTo: anAccessSymbol 
	"default access right for all objects and all users"
	^self defaultAccessRights includes: anAccessSymbol! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
migrateAppClassessToSymbols
	"do not use app classes but their names as symbols"

	self accessByObject keys do: [:obj |
		((obj isKindOf: Behavior) and: [obj includesBehavior: WebApplication]) ifTrue: [
			self accessByObject 
				at: obj name 
				put: (self accessByObject at: obj).
			self accessByObject removeKey: obj] ].

"WebSecurityManager default migrateAppClassessToSymbols"! !

!WebSecurityManager methodsFor: 'private' stamp: 'mivsek 3/7/2008 23:03'!
migrateToEncryptedPasswords
	"if not already"
	self allUsers do: [:each | each password size ~= 48 ifTrue: [each password: each password] ]

"WebSecurityManager allInstances do: [:each | each migrateToEncryptedPasswords] "
"WebSecurityManager hashPassword: 'aaaaaaaaa' "! !

!WebSecurityManager methodsFor: 'private'!
migrateToLockedReservedUsers
	"to preserve them by not allowing changes"
	"WebSecurityManager allInstances do: [:each | each migrateToLockedReservedUsers] "	
	| user |
	user := self adminUser.
	user isNil ifTrue: [self initAdminUser. user := self adminUser].
	user setLocked.
	user := self guestUser.
	user isNil ifTrue: [self initGuestUser. user := self guestUser].
	user setLocked.
	user := self extranetUser.
	user isNil ifTrue: [self initExtranetUser. user := self extranetUser].
	user setLocked.! !

!WebSecurityManager methodsFor: 'private'!
migrateUrlsForUsersAndGroups
	"WebSecurityManager allInstances do: [:each | each migrateUrlsForUsersAndGroups] "
	self site isNil ifTrue: [^nil].	
	self users do: [:each | self site urlResolver changeToPreferredUrl: each].
	self groups do: [:each | self site urlResolver changeToPreferredUrl: each].! !

!WebSecurityManager methodsFor: 'private'!
preferredUrl
	^'/security'! !

!WebSecurityManager methodsFor: 'private'!
printString
	^'WebSecurityManager on: ', self site name! !

!WebSecurityManager methodsFor: 'private'!
reconnectUsersToGroups
	"if user groups don't match group users"
	"AIDASite default securityManager reconnectUsersToGroups"
	self users do: [:user |
		user groups do: [:group | (group includes: user) ifFalse: [group addUser: user] ] ].
	self groups do: [:group |
		group users do: [:user | (self users includes: user) ifFalse: [self addUser: user] ] ]! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
removeAccessRightArray: anAccessSymbols for: aWebUserOrGroup and: anObject 
	"remove all specified access rigths for specified user or group on specified object"
	self site critical:
		[((self accessByObject at: anObject ifAbsent: [^self])
			at: aWebUserOrGroup ifAbsent: [^self])	removeAll: anAccessSymbols].! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
removeAccessRightArray: anAccessSymbols for: aWebUserOrGroup on: anObject 
	"remove all specified access rigths for specified user or group on specified object"
	| usrGrps rights |
	self site critical:
		[usrGrps := self accessByObject at: anObject ifAbsent: [^self].
		rights := usrGrps at: aWebUserOrGroup ifAbsent: [^self].
		anAccessSymbols do: [:each | rights remove: each ifAbsent: [] ] ].! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
removeGroup: aWebUserGroup ifAbsent: aBlock
	"remove group, if exist. If not exist do aBlock. You cannot remove group AllUsers!!" 
	aWebUserGroup isAllUsersGroup ifTrue: [^self error: 'group AllUsers cannot be removed!!'].
	(self groups includes: aWebUserGroup) ifFalse: [^aBlock value].
	self groups remove: aWebUserGroup.
	aWebUserGroup allUsers do: [:each | aWebUserGroup removeUser: each].
	self removeAllAccessRightsFor: aWebUserGroup! !

!WebSecurityManager methodsFor: 'private'!
settings
	settings isNil ifTrue: 
		[settings := Dictionary new. 
		self initDefaultSettings].
	^settings

"WebServer default settings"! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
site: anAIDASite
	site := anAIDASite.! !

!WebSecurityManager methodsFor: 'private' stamp: ' 21/4/07 22:07'!
users 
	users isNil ifTrue: [self initUsers].
	^users! !


!WebSecurityManager methodsFor: 'access control' stamp: ' 21/4/07 22:07'!
accessRightsFor: aWebUserOrGroup on: anObject
	"get the access rights for specified user or group on object  as literal array of 
	rights (e.g. #(#read #write). " 
	^(self accessByObject at: anObject 
		ifAbsent: [^self defaultAccessRights])
			at: aWebUserOrGroup ifAbsent:  [^self defaultAccessRights]! !

!WebSecurityManager methodsFor: 'access control'!
allowViews: viewSymbols andUpdates: updateSymbols for: aWebUserOrGroup on: anAppClass
	"those views and updates(actions) are allowed for that user or group on that App class"
	| viewRightSymbols updateRightSymbols |
	viewRightSymbols := viewSymbols collect: [:each | anAppClass viewRightSymbolFor: each].
	self setAccessRights: viewRightSymbols for: aWebUserOrGroup on: anAppClass name.
	updateRightSymbols := updateSymbols collect: [:each | anAppClass updateRightSymbolFor: each].
	self setAccessRights: updateRightSymbols for: aWebUserOrGroup on: anAppClass name.! !

!WebSecurityManager methodsFor: 'access control' stamp: ' 21/4/07 22:07'!
hasUser: aWebUser rightInAnyGroupTo: anAccessSymbol on: anObject 
	"test the access right for that object and in groups for that user"
	aWebUser groups do: [:group |
		(self has: group rightTo: anAccessSymbol on: anObject) ifTrue: [^true] ].
	^(self has: self allUsersGroup rightTo: anAccessSymbol on: anObject)! !

!WebSecurityManager methodsFor: 'access control'!
isAclSetFor: aUserOrGroup on: anAppClass
	| aclDict aclSet |
	aclDict := self accessByObject at: anAppClass name ifAbsent: [^false].
	aclSet := aclDict at: aUserOrGroup ifAbsent: [^false].
	^aclSet notEmpty! !

!WebSecurityManager methodsFor: 'access control' stamp: ' 21/4/07 22:07'!
isUser: aWebUser allowedTo: anAccessSymbol on: anObject 
	"test the access right for that object and that user or groups for that user"
	(self has: aWebUser rightTo: anAccessSymbol on: anObject) ifTrue: [^true].
	^(self hasUser: aWebUser rightInAnyGroupTo: anAccessSymbol on: anObject)! !

!WebSecurityManager methodsFor: 'access control' stamp: ' 21/4/07 22:07'!
removeAccessRights: anAccessSymbol for: aWebUserOrGroup on: anObject 
	"remove all specified access rigths for specified user or group on specified object"
	| access |
	(anAccessSymbol isKindOf: Array)
		ifTrue: [access := anAccessSymbol ]
		ifFalse: [access := Array with: anAccessSymbol].
	self removeAccessRightArray: access for: aWebUserOrGroup on: anObject! !

!WebSecurityManager methodsFor: 'access control' stamp: ' 21/4/07 22:07'!
removeAllAccessRightsFor: aWebUserOrGroup 
	self accessByObject keys do: [:object |
		self 
			removeAllAccessRightsFor: aWebUserOrGroup 
			on: object]! !

!WebSecurityManager methodsFor: 'access control' stamp: ' 21/4/07 22:07'!
removeAllAccessRightsFor: aWebUserOrGroup on: anObject 
	self site critical:
		[(self accessByObject at: anObject ifAbsent: [^self])
			removeKey: aWebUserOrGroup ifAbsent: [^self] ].! !

!WebSecurityManager methodsFor: 'access control' stamp: ' 21/4/07 22:07'!
removeAllAccessRightsForObject: anObject 
	self site critical:
		[self accessByObject removeKey: anObject ifAbsent: []	].! !

!WebSecurityManager methodsFor: 'access control' stamp: ' 21/4/07 22:07'!
setAccessRights: anAccessSymbols for: aWebUserOrGroup on: anObject
	"set the access rights for specified user or group on object. it can be only one right 
	or an literal array of rights (e.g.#(#read #write) ) " 
	| access |
	aWebUserOrGroup isNil ifTrue: [^self error: 'User is nil'].
	access := (anAccessSymbols isKindOf: Array) 
		ifTrue: [anAccessSymbols ] 
		ifFalse: [Array with: anAccessSymbols].
	self accessRightsArray: access for: aWebUserOrGroup on: anObject.! !


!WebSecurityManager methodsFor: 'group management' stamp: ' 21/4/07 22:07'!
activatingGroup
	"group for users to confirm registration"
	^self groups detect: [:each | each isActivatingGroup] ifNone: [nil].! !

!WebSecurityManager methodsFor: 'group management'!
addGroup: aWebUserGroup
	^self addGroup: aWebUserGroup ifExist: [^nil].! !

!WebSecurityManager methodsFor: 'group management' stamp: ' 21/4/07 22:07'!
addGroupNamed: aString
 	"add new group with a specified name. If already exist, error"
	self addGroup: (WebUserGroup new name: aString).! !

!WebSecurityManager methodsFor: 'group management' stamp: ' 21/4/07 22:07'!
adminGroup
	"group for admins, those who have all acess rights !! "
	^self groups detect: [:each | each isAdminGroup] ifNone: [nil].! !

!WebSecurityManager methodsFor: 'group management' stamp: ' 21/4/07 22:07'!
allUsersGroup
	"group for all users in system"
	^self groups detect: [:each | each isAllUsersGroup] ifNone: [nil].! !

!WebSecurityManager methodsFor: 'group management' stamp: ' 21/4/07 22:07'!
existGroupNamed: aString
	^(self groupNamed: aString) notNil! !

!WebSecurityManager methodsFor: 'group management' stamp: ' 21/4/07 22:07'!
groupNamed: aString
	aString isEmpty ifTrue: [^nil].
	^self groups detect: [:group | group name =  aString] ifNone: [nil]! !

!WebSecurityManager methodsFor: 'group management' stamp: ' 21/4/07 22:07'!
groupWithUuid: aString
	" find and return a group with specified uuid. Return nil if not found" 
	^self groups detect: [:each | each uuid = aString] ifNone: [nil]! !

!WebSecurityManager methodsFor: 'group management' stamp: ' 21/4/07 22:07'!
registeredGroup
	"group for registered users"
	^self groups detect: [:each | each isRegisteredGroup] ifNone: [nil].! !

!WebSecurityManager methodsFor: 'group management' stamp: ' 21/4/07 22:07'!
removeGroup: aWebUserGroup
	"remove group, if exist. If not exist do nothing" 
	self removeGroup: aWebUserGroup ifAbsent: [].! !

!WebSecurityManager methodsFor: 'group management' stamp: ' 21/4/07 22:07'!
removeGroupNamed:  aString 
	| group |
	group := self groupNamed: aString.
	group notNil ifTrue: [self removeGroup: group]! !


!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
addActivatingUser: aWebUser
	"add this user also to group waiting for confirmation"
	self addUser: aWebUser.
	self activatingGroup addUser: aWebUser.! !

!WebSecurityManager methodsFor: 'user management'!
addPerson: aPerson
	"make parallel WebUser, cross-connect both and put into Registered group"
	"by default username and password are aPerson surname!!"
	| user |
	aPerson asWebUser notNil ifTrue: [^self error: 'already added!!'].
	user := self site webUserClass new.
	user username: aPerson surname.
	user password: aPerson surname.
	(self addRegisteredUser: user) notNil "no duplicates in username"
		ifTrue: [ aPerson webUser: user. user person: aPerson]
		ifFalse: [^nil].
	^aPerson! !

!WebSecurityManager methodsFor: 'user management'!
addRegisteredUser: aWebUser
	"add this user also to registered users group. Remove him from activating group"
	self addUser: aWebUser.
	self registeredGroup addUser: aWebUser.
	self activatingGroup removeUser: aWebUser.
	aWebUser setRegisteredTimestamp.! !

!WebSecurityManager methodsFor: 'user management'!
addUser: aWebUser
	"add new user also in All Users group"
	(aWebUser isKindOf: WebUser) ifFalse: [^self error: 'This is not aWebUser'].
	(self users includes: aWebUser) ifTrue: [^nil].
	(self existUserNamed: aWebUser username withPassword: aWebUser password) ifTrue: [^nil]. 
	self users add: aWebUser.
	self allUsersGroup addUser: aWebUser.
	aWebUser parent: self.
	^aWebUser! !

!WebSecurityManager methodsFor: 'user management'!
adminUser
	"first admin user, initialy it is with username 'admin'"
	^self users 
		detect: [:each | each isAdminUser] 
		ifNone: [self error: 'Admin user missing?']! !

!WebSecurityManager methodsFor: 'user management'!
existUserNamed: anUsernameString 
	^(self userNamed: anUsernameString) notNil! !

!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
existUserNamed: anUsernameString withPassword: aPasswordString
	^(self userNamed: anUsernameString withPassword: aPasswordString) notNil! !

!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
existUserWithId: aNumber
	^self users contains: [:each | each id = aNumber].! !

!WebSecurityManager methodsFor: 'user management'!
extranetUser
	"a common extranet user, for easier setup of access rights"
	^self users detect: [:each | each isExtranetUser] ifNone: [nil]! !

!WebSecurityManager methodsFor: 'user management'!
guestUser
	"actually only one is guest user"
	^self users 
		detect: [:each | each isGuest] 
		ifNone: [self error: 'Guest user missing?']! !

!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
isUser: aWebUser inGroup: aWebGroup
	"test if user is member of this group"
	^aWebGroup includes: aWebUser! !

!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
isUser: aWebUser inGroupNamed: aString
	| group |
	group := self groupNamed: aString.
	group isNil ifTrue: [^false].
	^group includes: aWebUser! !

!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
removeUser: aWebUser
	"remove user, if exist" 
	(self users includes: aWebUser) ifFalse: [^nil].
	self users remove: aWebUser.
	self allGroups do: [:group | group removeUser: aWebUser].
	self removeAllAccessRightsFor: aWebUser! !

!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
removeUserNamed:  anUsername withPassword: aPassword
	| user |
	user := self userNamed: anUsername withPassword: aPassword.
	self removeUser: user! !

!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
userNamed: anUsernameString
	" find and return a WebUser with username . Return nil if not found"
	"WebSecurityManager default userNamed: 'mivsek'"
 	(anUsernameString ~= '') ifFalse: [^nil].
	^self users 
		detect: [:user | (user username asLowercase = anUsernameString asLowercase)] ifNone: [nil]! !

!WebSecurityManager methodsFor: 'user management' stamp: 'janko 10/28/2011 11:52'!
userNamed: anUsernameString withPassword: aPasswordString
	" find and return a WebUser with username and password. Return nil if not found"
 	(anUsernameString isNil  | aPasswordString isNil) ifTrue: [^nil].
 	((anUsernameString = '') | (aPasswordString = '')) ifTrue: [^nil].
	^self users detect: [:user | 
		(user username asLowercase = anUsernameString asLowercase) and: 
			[user password = (WebSecurityManager hashPassword: aPasswordString)]] 
				ifNone: [nil]
! !

!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
userWithEMail: aString
	" find and return a WebUser with specified email. Return nil if not found" 
	(aString ~= '') ifFalse: [^nil]. 
	^self users detect: [:user | user email asLowercase = aString asLowercase ] ifNone: [^nil]! !

!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
userWithId: aNumber
	^self users detect: [:each | each id = aNumber] ifNone: [nil]! !

!WebSecurityManager methodsFor: 'user management' stamp: 'np 3/16/2009 13:04'!
userWithName: aNameString surname: aSurnameString
	" find and return a WebUser with name and surname. Return nil if not found"
 	(aNameString ~= '') | (aNameString ~= '') ifFalse: [^nil].
	^self users detect: [:user | 
		(user name asLowercase = aNameString asLowercase) and: 
			[user surname asLowercase = aSurnameString asLowercase]] 
				ifNone: [nil]! !

!WebSecurityManager methodsFor: 'user management' stamp: ' 21/4/07 22:07'!
userWithUuid: aString
	" find and return a WebUser with specified uuid. Return nil if not found" 
	^self users detect: [:each | each uuid = aString] ifNone: [nil]! !


!WebSecurityManager methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allGroups
	^self groups copy! !

!WebSecurityManager methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allUsers
	^self users copy! !

!WebSecurityManager methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
site
	"a parent site using that security manager"
	^site! !


!WebSecurityManager methodsFor: 'settings'!
allowedIPs
	"whitelist: a collection of IP addresses, from which login is allowed. Star can be used, like 12.234.*  "
	^self settings at: #AllowedIPs ifAbsentPut: [OrderedCollection new]! !

!WebSecurityManager methodsFor: 'settings'!
allowedIPs: aCollectionOfStrings
	"whitelist: a collection of IP addresses, from which login is allowed. Star can be used, like 12.234.*  "
	^self settings at: #AllowedIPs put: aCollectionOfStrings! !

!WebSecurityManager methodsFor: 'settings'!
ipFilterPolicy
	"what to do if IP is on blacklist or whitelist"
	^self settings at: #ipFilterPolicy ifAbsentPut: [#warn]! !

!WebSecurityManager methodsFor: 'settings'!
ipFilterPolicy: aSymbol
	"what to do if IP is on blacklist or whitelist"
	"(AIDASite named: 'aidademo') securityManager ipFilterPolicy: #deny "
	(#(#none #warn #deny) includes: aSymbol) ifFalse: [self error: 'unkown IP filter policy'].
	^self settings at: #ipFilterPolicy put: aSymbol! !


!WebSecurityManager methodsFor: 'authentication' stamp: ' 21/4/07 22:07'!
authenticationScheme
	"#Form - with WebAdminApp login form - default!!
	#HttpBasic - rfc2617 Basic authentication - passwords NOT encrypted!!
	#HttpDigest - rfc2617 Digest authentication - encrypted passwords
	#SSLClientCertificate - most secure, user needs a valid PKI certificate"
	authenticationScheme isNil ifTrue: [self setFormAuthenticationScheme].
	^authenticationScheme! !

!WebSecurityManager methodsFor: 'authentication' stamp: ' 21/4/07 22:07'!
hasFormAuthenticationScheme
	^self authenticationScheme = #Form! !

!WebSecurityManager methodsFor: 'authentication' stamp: ' 21/4/07 22:07'!
hasHttpAuthenticationScheme
	^self hasHttpBasicAuthenticationScheme | self hasHttpDigestAuthenticationScheme! !

!WebSecurityManager methodsFor: 'authentication' stamp: ' 21/4/07 22:07'!
hasHttpBasicAuthenticationScheme
	^self authenticationScheme = #HttpBasic! !

!WebSecurityManager methodsFor: 'authentication' stamp: ' 21/4/07 22:07'!
hasHttpDigestAuthenticationScheme
	^self authenticationScheme = #HttpDigest! !

!WebSecurityManager methodsFor: 'authentication' stamp: ' 21/4/07 22:07'!
hasSSLClientCertificateAuthenticationScheme
	^self authenticationScheme = #SSLClientCertificate! !

!WebSecurityManager methodsFor: 'authentication'!
isAllowedToLoginIP: anIPString
	self allowedIPs isEmpty ifTrue: [^true].
	self isIpFilterPolicyNone ifTrue: [^true].
	^self allowedIPs contains: [:ip | ip trimBlanks notEmpty and: [ip match: anIPString] ]! !

!WebSecurityManager methodsFor: 'authentication' stamp: ' 21/4/07 22:07'!
setFormAuthenticationScheme
	"AIDASite default securityManager setFormAuthenticationScheme"
	self authenticationScheme: #Form! !

!WebSecurityManager methodsFor: 'authentication' stamp: ' 21/4/07 22:07'!
setHttpBasicAuthenticationScheme
	"AIDASite default securityManager setHttpBasicAuthenticationScheme"
	self authenticationScheme: #HttpBasic! !

!WebSecurityManager methodsFor: 'authentication' stamp: ' 21/4/07 22:07'!
setHttpDigestAuthenticationScheme
	"AIDASite default securityManager setHttpDigestAuthenticationScheme"
	self authenticationScheme: #HttpDigest! !

!WebSecurityManager methodsFor: 'authentication' stamp: ' 21/4/07 22:07'!
setSSLClientCertificateAuthenticationScheme
	"AIDASite default securityManager setSSLClientCertificateAuthenticationScheme"
	self authenticationScheme: #SSLClientCertificate! !


!WebSecurityManager methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initAccessByObject
	accessByObject := Dictionary new.! !

!WebSecurityManager methodsFor: 'initialize-release'!
initAdminUser
	"add default admin user"
	| user |
	(self users detect: [:each | each isAdminUser] ifNone: [nil] )
		notNil ifTrue: [^nil].
	user := WebUser newAdmin.
	user setLocked. "to avoid name/username changes"
	self addUser: user.
	self adminGroup addUser: user.! !

!WebSecurityManager methodsFor: 'initialize-release'!
initDefaultAccessRights
	"to allow login, registering new user etc"
	"AIDASite allInstances do: [:each | each securityManager initDefaultAccessRights]"
	self allowViews: #(login logout forgoten registration passwordSent waitingConfirmation activation 
						wakeupScriptaculous wakeupRichEditor
						loginGoogle loginGoogle2 loginGoogle3 logoutGoogle) "OpenID login" 
		andUpdates: #(login registration passwordSent)
		for: self allUsersGroup on: WebAdminApp.
	self allowViews: #(main activationRequest activate) andUpdates:  #(main) 
		for: self allUsersGroup on: WebRegistrationApp.! !

!WebSecurityManager methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initDefaultGroups
	self addGroup: WebUserGroup newAllUsers.
	self users do: [:user | 	self allUsersGroup addUser: user].
	self addGroup: WebUserGroup newAdmin.
	self addGroup: WebUserGroup newRegistered.
	self addGroup: WebUserGroup newActivating.
	self postInitDefaultGroups.  "override this method for your own default groups"! !

!WebSecurityManager methodsFor: 'initialize-release'!
initDefaultSettings! !

!WebSecurityManager methodsFor: 'initialize-release'!
initDemoAccessRights
	"access to all for demos in WebDemoApp"
	"AIDASite allInstances do: [:each | each securityManager initDemoAccessRights]"
	self allowViews: WebDemoApp allViews asArray 
		andUpdates:  WebDemoApp allViews asArray
		for: self allUsersGroup on: WebDemoApp.! !

!WebSecurityManager methodsFor: 'initialize-release'!
initExtranetAccessRights
	"for extranet user"! !

!WebSecurityManager methodsFor: 'initialize-release'!
initExtranetUser
	"add default extranet user"
	| user |
	(self users detect: [:each | each isExtranetUser and: [each name = WebUser extranetName]] 
		ifNone: [nil] )
			notNil ifTrue: [^nil].
	user := WebUser newExtranet.
	user setLocked. "to avoid name/username changes"
	self addUser: user.
	self registeredGroup addUser: user.! !

!WebSecurityManager methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initGroups
	groups := Set new.! !

!WebSecurityManager methodsFor: 'initialize-release' stamp: 'mivsek 1/10/2008 19:22'!
initGuestAccessRights
	"for guest user"! !

!WebSecurityManager methodsFor: 'initialize-release'!
initGuestUser
	"add new user,with name 'Guest'"
	| user |
	(self users detect: [:each | each isGuest] ifNone: [nil] ) notNil ifTrue: [^nil].
	user := WebUser newGuest.
	user setLocked. "to avoid name/username changes"
	self addUser: user.
	self allUsersGroup addUser: user.! !

!WebSecurityManager methodsFor: 'initialize-release'!
initUsers
	users := Set new. 
	self groups do: [:each | each initUsers]. "to delete all potential users in those groups!!"! !

!WebSecurityManager methodsFor: 'initialize-release'!
initialize
	self initUsers.
	self initGroups.
	self initAccessByObject.
	self initDefaultGroups; lockDefaultGroups.
	self initAdminUser. self initGuestUser. self initExtranetUser.
	self initDefaultAccessRights. 
	self initDemoAccessRights.
	self initGuestAccessRights. self initExtranetAccessRights.! !

!WebSecurityManager methodsFor: 'initialize-release'!
lockDefaultGroups
	"to avoid name change or delete of default groups"
	"AIDASite allInstances do: [:each | each securityManager lockDefaultGroups]"
	self allUsersGroup setLocked.
	self adminGroup setLocked.
	self registeredGroup setLocked.
	self activatingGroup setLocked.
	self allUsersGroup setLocked.! !

!WebSecurityManager methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
postInitDefaultGroups
	"override this method for your own default groups"! !

!WebSecurityManager methodsFor: 'initialize-release'!
removeAdminAccess
	"remove admin group access and update rights. If user is in admin group and is escalated to admin, 
	he has access by default"
	"AIDASite allInstances do: [:each | each securityManager removeAdminAccess]"
	WebApplication disallowAllViewsFor: self adminGroup on: self site.
	WebApplication disallowAllUpdatesFor: self adminGroup  on: self site.! !


!WebSecurityManager methodsFor: 'filtering'!
isIpFilterPolicyDeny
	"what to do if IP is on blacklist or whitelist"
	^self ipFilterPolicy = #deny! !

!WebSecurityManager methodsFor: 'filtering'!
isIpFilterPolicyNone
	"what to do if IP is on blacklist or whitelist"
	^self ipFilterPolicy = #none! !

!WebSecurityManager methodsFor: 'filtering'!
isIpFilterPolicyWarn
	"what to do if IP is on blacklist or whitelist"
	^self ipFilterPolicy = #warn! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebSecurityManager class
	instanceVariableNames: ''!

!WebSecurityManager class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
default 
	^AIDASite default securityManager! !


!WebSecurityManager class methodsFor: 'hashing' stamp: 'jm 12/14/2010 23:32'!
hashPassword: aString
	"Squeak specific"
	"Returns a hashed string, used to store and compare passwords in a secure way"
	^(SecureHashAlgorithm new 
			hashMessage: (AIDASite convert: aString toCodepage: #UTF8) )
				asString! !


!WebSecurityManager class methodsFor: 'instance creation' stamp: 'mivsek 1/10/2008 19:01'!
newOn: anAIDASite
	^super basicNew 
		site: anAIDASite.
		"initialize"  "do that separately, otherwise it drops in indefinitive recursion"! !


Object subclass: #WebSession
	instanceVariableNames: 'ids created cookies parent user appsForObjects realtime userValues other'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Core'!
!WebSession commentStamp: '<historical>' prior: 0!
WebSession hold user's session with all appropriate data on this website. It also hold an application state (instances of App classes) which belong to that session. Session can be anonymous (of special user Guest) or logged-in. !


!WebSession methodsFor: 'private-app state'!
addApp: anApplication for: anObject type: aSymbol
	"web or wap apps, type can be #web or #wap "
	| objDict |
	objDict := self appsForObjects at: anObject ifAbsentPut: [Dictionary new].
	^objDict at: aSymbol put: anApplication! !

!WebSession methodsFor: 'private-app state' stamp: ' 21/4/07 22:07'!
addWebApp: aWebApplication for: anObject
	^self addApp: aWebApplication for: anObject type: #web! !

!WebSession methodsFor: 'private-app state'!
allContexts
	"all contexts in all apps registred in this session"
	| ctxs |
	ctxs := OrderedCollection new: 100.
	self appsForObjects keysDo: [:type |
		(self appsForObjects at: type) keysAndValuesDo: 
			[:id :app | ctxs addAll: app contexts values] ].
	^ctxs! !

!WebSession methodsFor: 'private-app state' stamp: ' 21/4/07 22:07'!
appFor: anObject type: aSymbol 
	^(self appsForObjects at: anObject ifAbsent: [^nil]) 
		at: aSymbol ifAbsent: [^nil]! !

!WebSession methodsFor: 'private-app state' stamp: ' 21/4/07 22:07'!
appsForObjects
	
	appsForObjects isNil ifTrue: [self initAppsForObjects].
	^appsForObjects! !

!WebSession methodsFor: 'private-app state' stamp: ' 21/4/07 22:07'!
removeApp: anApplication for: anObject type: aSymbol
	(self appsForObjects at: anObject ifAbsent: [^nil])
		removeKey: aSymbol ifAbsent: [^nil]! !

!WebSession methodsFor: 'private-app state' stamp: ' 21/4/07 22:07'!
webAppFor: anObject
	^self appFor: anObject type: #web! !


!WebSession methodsFor: 'private'!
addSessionID
	"add session id to  parms dictionary. Url with session id looks like: 	http://www.tris-a.si/welcome.html?id=523453. This should be done for every automaticaly 
	generated url (WebLink printHTMLPage) to distinguish sesions among themselves."
	self parms 
		at: 'id' 
		put: self id printString.! !

!WebSession methodsFor: 'private'!
cookie: aBoolean
	self cookies 	at: 1 put: aBoolean! !

!WebSession methodsFor: 'private' stamp: ' 21/4/07 22:07'!
cookies
	cookies isNil ifTrue: [self initCookies].
	^cookies! !

!WebSession methodsFor: 'private'!
fullUrlForCurrentPage
	"composes and returns a full url for a curent requested page. If parms dictionary is changed, 
	then a query string with changed parameters is generated. Usefull for presenting the same 
	page in a different way by parameteres in query string"
	^self lastRequest urlString! !

!WebSession methodsFor: 'private'!
geolocation: aWebGeolocation
	"Geolocation of user's browser"
	^self otherAt: #geolocation put: aWebGeolocation! !

!WebSession methodsFor: 'private'!
id: aNumber
	"return the unique identification of a nonsecure session. This is a random generated number 
	at session generation. It can be used for session tracking in URLs, forms, etc."
	self ids 
		at: 1 
		put: aNumber.! !

!WebSession methodsFor: 'private' stamp: ' 21/4/07 22:07'!
ids
	ids isNil ifTrue: [self initIds].
	^ids! !

!WebSession methodsFor: 'private'!
is: anIpString inIpRange: aRangeArray
	"like '193.2.253.126' in range #('193.2.253.0' '193.2.253.255') "
	| ipParts lowerIpParts upperIpParts |
	ipParts := (anIpString tokensBasedOn: $. ) collect: [:each | each asInteger].
	lowerIpParts := (aRangeArray first tokensBasedOn: $. ) collect: [:each | each asInteger].
	upperIpParts := (aRangeArray last tokensBasedOn: $. ) collect: [:each | each asInteger].
	1 to: 4 do: [:inx |
		(ipParts at: inx) < (lowerIpParts at: inx) ifTrue: [^false].
		(ipParts at: inx) > (upperIpParts at: inx) ifTrue: [^false] ].
	^true.

"WebSession new is: '193.2.253.126' inIpRange: #('193.2.253.0' '193.2.253.255') "! !

!WebSession methodsFor: 'private'!
isFromInternalIP
	"session from internal IP"
	^('192.168.*' match: self lastIP)
		or: ['10.*' match: self lastIP] 
			"or 172.16 - 172.31, but rarery used"! !

!WebSession methodsFor: 'private' stamp: 'jm 9/8/2010 21:09'!
logLoginOf: aWebUser
	self loginHistory
		add: (Array with: #login with: aWebUser with: SpTimestamp now)
		onDate: SpDate today! !

!WebSession methodsFor: 'private' stamp: 'jm 9/8/2010 21:10'!
logLogoutOf: aWebUser
	self loginHistory 
		add: (Array with: #logout with: aWebUser with: SpTimestamp now)
		onDate: SpDate today! !

!WebSession methodsFor: 'private' stamp: ' 21/4/07 22:07'!
parent: aWebSessionManager
	parent := aWebSessionManager.! !

!WebSession methodsFor: 'private'!
printRealtimeStatus
^'realtime: ', 
	(self isRealtimeOpen
		ifTrue: [self realtimeHandler connections size printString, ' connections']
		ifFalse: ['no'])! !

!WebSession methodsFor: 'private'!
printString
^'aWebSession
	user: ', self user username, ' (', self user nameSurname, ')
	site: ', self site name, '
	created: ', self created printSloString, '
	lastIP: ', self lastIP, '
	lastActivity: ', self lastActivityText, '
	', self printRealtimeStatus! !

!WebSession methodsFor: 'private'!
realtimeHandler
	"to handle realtime (WebSocket and Comet) channels on that session"
	realtime 
		ifNil: [realtime := WebRealtimeHandler newOn: self].
	^realtime! !

!WebSession methodsFor: 'private'!
registerIP
	"add IP address of user's computer to the list, if not there already. Consider a possible proxy server"	
	| ip |
	self lastRequest isNil ifTrue: [^nil].
	ip := self lastRequest realPeerIp. "also if behind a proxy"
	self lastIP = ip ifFalse:   "new session or session from new IP (like mobile user)"
		[self sessionIPs remove: ip ifAbsent: []. "remove potential duplicate from before"
		self sessionIPs add: ip.
		self otherAt: #LastIP put: ip]! !

!WebSession methodsFor: 'private'!
secureCookie
	"true if web request in this secure session uses cookies, false otherwise"
	"OBSOLETE!!"
	^self cookies at: 2! !

!WebSession methodsFor: 'private'!
secureCookie: aBoolean
	"OBSOLETE"
	self cookies at: 2 put: aBoolean! !

!WebSession methodsFor: 'private'!
secureId
	"return the unique identification of a secure session to browser. This is a random generated number at session generation. It can be used for session tracking in URLs, forms, etc."
	"OBSOLETE!!"
	^self ids at: 2! !

!WebSession methodsFor: 'private'!
secureId: aNumber
	"return the unique identification of a secure session. This is a random generated number 
	at session generation. It can be used for session tracking in URLs, forms, etc."
	self ids at: 2 put: aNumber.! !

!WebSession methodsFor: 'private'!
setLastActivity
	"set the last activity (request) timestamp"
	^self otherAt: #lastActivityTimestamp put: SpTimestamp now! !

!WebSession methodsFor: 'private'!
setLastIP
	"Peer IP from last request. If behind a proxy, use #realPeerIp instead"
	^self 
		otherAt: #LastIP 
		put: self lastRequest peer! !

!WebSession methodsFor: 'private'!
user: aWebUser
	"set a reference to aWebUser, who is logged into this session"
	user := aWebUser.! !

!WebSession methodsFor: 'private'!
userValues
	"return a dictionary with user defined values, which scope is this session. Usr can use it for such 
	things as global navigation, remembering views etc."
	userValues isNil ifTrue: [self initUserValues].
	^userValues! !


!WebSession methodsFor: 'private-serving'!
aidaIsRespondingNeverStreamed
	^false! !

!WebSession methodsFor: 'private-serving' stamp: 'janko 4/25/2012 10:59'!
aidaIsRespondingStreamed
	"to simulate WebPAge, see AIDASite answer:toGetoOrPost:on:"
	^false! !

!WebSession methodsFor: 'private-serving'!
aidaPresenterFor: aRequest on: aSession
	| json event |
	aRequest isWebSocketRequest ifTrue: 
		["Transcript cr; show: '** session: new WebSocket on ', self site name ,' from ', aRequest realPeerIp. "
		^self]. "upgrade to WebSocket request on /aidasession/websocket, see streamHtmlTo:.."
	 '/aidasession/comet' = aRequest uriString ifTrue: 
		[^self realtimeHandler respondToCometRequest: aRequest].
	 '/aidasession/geolocation' = aRequest uriString ifTrue: 
		[^self]. "see streamHtmlTo... "
	('/aidasession/element-*' match: aRequest uriString) ifTrue: 
		[^self respondToElementDirectRequest: aRequest].  "direct Ajax request to some element of a webpage"
"	aRequest uriString = '/aidasession/ajax' ifFalse: 
		[(Delay forSeconds: 1) wait. ^self]. "  "WebSocket over Squid proxy troubles!!"
	aRequest isPost not ifTrue: [^WebPage new]. "JSON msg must be in body of POST request"
	json := aRequest ensureFullRead; entityBody.
	event := WebEvent newFromJSON: json.
	event := event reconnectOn: aSession. "find a right element and a context (at start we have only their ids)"
	event ifNil: 
		["Transcript cr; show: '*** session: unknown event: ', 
			(json ifNotNil: [json] ifNil: ['(request''s body is empty) '])."
		^WebPage new addText: '*** unknown event'].
	(event context isNil or: [(event context isKindOf: WebContext) not]) ifTrue: 
		["Transcript cr; show: '*** session: unknown context in event: ', 
			(json ifNotNil: [json] ifNil: ['(request''s body is empty) '])."
		^self].
	event element notNil 
		ifTrue: [event app respondToEvent: event]
		ifFalse: ["Transcript cr; show: '*** session: unknown element in event ', aRequest entityBody"].
	"next, streaming step occurs in printHTMLPageOnfor:to: "! !

!WebSession methodsFor: 'private-serving'!
packToJSONMessages: aCollection "of WebCommands"
	"convert commands to an array of JSON"
	^'[', (aCollection 
		inject: ''
		into: [:jsonString :command || separator |
			separator := command = aCollection last ifFalse: [','] ifTrue: [''].
			jsonString, command asJSON, separator]),
	  ']'! !

!WebSession methodsFor: 'private-serving'!
respondToElementDirectRequest: aRequest
	"Direct a request to the specified element of a webpage. Element context id and is 
	found in request's Url, like /aidasession/element-id345-ctx35234"
	| stream id ctxId context element |
	stream := aRequest uriString readStream.
	id := (stream upTo: $-;  upToAll: '-ctx') asSymbol.
	ctxId := stream next; upTo: $? "if exists, otherwise upToEnd" .
	ctxId := (ctxId copyReplaceAll: 'ctx' with: '') asInteger.
	self lastApp 
		ifNil: [^HTTPException notFound].
	context := self lastApp contexts 
		at: ctxId 
		ifAbsent: [self allContexts 
			detect: [:each | each id = ctxId]
			ifNone: [^HTTPException notFound] ].
	element := context elementId: id.
	^element aidaPresenterFor: aRequest on: self! !

!WebSession methodsFor: 'private-serving'!
setGeolocationFrom: aRequest
	| location |
	location := WebGeolocation newFromJSON: (aRequest ensureFullRead; entityBody).
	location notNil ifTrue: [self geolocation: location].! !

!WebSession methodsFor: 'private-serving'!
streamAjaxResponseOn: aStream for: aRequest on: aWebSession
	| ctxses msgs jsonString |
	"stream all messages made by element updates from all active context queues at once. Before that run also
	all updates requested by dependency mechanism and caused by domain object change announcements"
	self site
		updateElementsFromQueue.
	ctxses := aWebSession allContexts
		select: [:ctx | ctx isFirst and: [ctx isActive] ].
	msgs := ctxses 
		inject: (OrderedCollection new: 100)
		into: [:col :ctx | 
			col addAll: ctx queue. 
			ctx initQueue.
			col].
	jsonString := self packToJSONMessages: msgs.
	aStream nextPutAll:  jsonString.! !

!WebSession methodsFor: 'private-serving'!
streamEmptyResponseOn: aStream for: aRequest on: aWebSession
	"respond only 200 ok"! !

!WebSession methodsFor: 'private-serving'!
streamHtmlTo: aStream for: aRequest on: aWebSession
	| url |
	url := aRequest urlString readStream upTo: $? .
	url = '/aidasession/ajax' ifTrue:    "Ajax response with JSON commands"
		[^self streamAjaxResponseOn: aStream for: aRequest on: aWebSession]. 
	url = '/aidasession/websocket/' ifTrue:   "upgrade to WebSocket request"
		[^self realtimeHandler streamWebSocketOn: aStream for: aRequest on: aWebSession]. 
	url = '/aidasession/comet' ifTrue:   "long polling Ajax Comet"
		[^self realtimeHandler streamCometOn: aStream for: aRequest on: aWebSession]. 
	url = '/aidasession/geolocation' ifTrue:   "geolocation of browser received"
		[self setGeolocationFrom: aRequest.
		^self streamEmptyResponseOn: aStream for: aRequest on: aWebSession]. 
	^self error: 'unknown request'.! !


!WebSession methodsFor: 'security-login'!
authenticateFrom: aRequest
	"try to login with username and password from request (rfc2617)"
	| usr |
	aRequest username isNil ifTrue: [^nil].
	usr := self site securityManager userNamed: aRequest username.
	usr isNil ifTrue: [^nil].
	(aRequest matchUserWithPassword: usr password) 
		ifTrue: [self loginUser: usr] ifFalse: [self logout].! !

!WebSession methodsFor: 'security-login'!
checkExpirationAndPossiblyLogoutFor: aRequest
	"don't logout if request is POST on the same object (eg. after long editing)"
	self isLoggedIn ifFalse: [^self].
	(self site autoLogout or: [self user autoLogout]) ifFalse: [^self].
	(self isExpired and: [aRequest isPost not]) ifTrue: 
		[self logout.
		(self site admin aidaWebAppFor: self) 
			showError: self site style sessionTimeoutText].! !

!WebSession methodsFor: 'security-login'!
loginUser: aWebUser
"	(self site securityManager isAllowedToLoginIP: self lastRequest peer) 
		ifFalse: [^self error: 'From this IP not allowed to login!!'].
"	self user: aWebUser.
	self logLoginOf: aWebUser.
	aWebUser inAdminGroup ifTrue: [aWebUser escalateToAdmin]. "temporary, otherwise rather unescalate!!"
	aWebUser logLogin.! !

!WebSession methodsFor: 'security-login'!
loginUserNamed: aUsernameString withPassword: aPasswordString 
	"will fail if username or password wrong!!"
	| usr |
	usr := self site securityManager userNamed: aUsernameString withPassword: aPasswordString.
	usr isNil ifTrue: [self error: 'User withat username/password combination does not exist'].
	self loginUser: usr! !

!WebSession methodsFor: 'security-login'!
loginUserWithName: aNameString surname: aSurnameString 
	| usr |
	usr := self site securityManager userWithName: aNameString surname: aSurnameString.
	usr notNil ifTrue: [self loginUser: usr]! !

!WebSession methodsFor: 'security-login'!
logout
	"Replace logged user with Guest. Remember last page to return after login again"
	| origin usr |
	self redirectLink: nil. 	self redirectOrigin: nil.
	self isLoggedIn 
		ifTrue: 
			[usr := self user. self initUser. 
			usr isEscalatedToAdmin ifTrue: [usr unEscalateFromAdmin].
			self logLogoutOf: usr. usr logLogout] 
		ifFalse: [^nil].
	origin := usr lastAppUrl. 
	(origin isNil or: [self lastRequest notNil and: [origin = self lastRequest uriString]]) ifTrue: [^nil].
	('*/admin?view=login*' match: origin) ifTrue: [^nil]. "to return to login is confusing users"
      usr logoutFromUrl: origin. "to jump back after login"! !


!WebSession methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
browser
	
	"try to find out, which browser a web request originator is using. It can be #Netscape, #IBM, #Microsoft, #lynx, #Mosaic.  Returns #Unknown if not possible to find out the browser type"

	| partOfString |
	self browserString = '' ifTrue: [^#Unknown].
	partOfString := self browserString copyFrom: 1 to: 6.
	partOfString = 'Mozill' ifTrue: [^#Netscape].
	partOfString = '' ifTrue: [^#Microsoft].
	partOfString = 'IBM-We' ifTrue: [^#IBM].
	partOfString = '' ifTrue: [^#Lynx].
	partOfString = '' ifTrue: [^#Mosaic].! !

!WebSession methodsFor: 'accessing'!
browserString
	"return the string, whick browser sends as identification in a web request"
	self lastRequest isNil ifTrue: [^''].
	^self lastRequest userAgent.! !

!WebSession methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
cookie
	"true if web request in this nonsecure session uses cookies, false otherwise"
	^self cookies at: 1.! !

!WebSession methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
created

	"return the timestamp of a session creation."

	^created! !

!WebSession methodsFor: 'accessing'!
createdTimestampText
	^self created printSloString! !

!WebSession methodsFor: 'accessing'!
id
	"return the unique identification of a nonsecure session to browser. This is a random generated 
	number at session generation. It can be used for session tracking in URLs, forms, etc."
	^self ids at: 1! !

!WebSession methodsFor: 'accessing'!
lastRequestTimeText
	self lastRequest ifNil: [^''].
	^self lastRequest timestamp asTime printString! !

!WebSession methodsFor: 'accessing'!
lastUser
	"User who was last logged-in on that session, if any. If session is logged-in, it returns logged user"
	(self isGuest and: [self neverLoggedIn]) ifTrue: [^nil].
	self isLoggedIn ifTrue: [^self user].
	^self loginHistory all first at: 2! !

!WebSession methodsFor: 'accessing'!
lastUserText
	"user logged now or in a past"
	| usr |
	usr := self lastUser. 
	usr isNil ifTrue: [^''].
	^usr nameSurname! !

!WebSession methodsFor: 'accessing'!
loginStateText
	"login, logout, guest"
	(self isGuest and: [self neverLoggedIn]) ifTrue: [^'guest'].
	self isLoggedIn ifTrue: [^'login'].
	^'logout'! !

!WebSession methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
newView

	"return a value of a 'view' parameter in query part of a URL to be generated. Also used for changing views in a state machine for web applications (in method actionFormForm (here is set) and method printWebPage (here is used to genererate appropriate page))"

	^self parms at: 'view' ifAbsent: [^''].! !

!WebSession methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
newView: aString
	"set a value of a 'view' parameter in query part of a URL to be generated. Also used for changing 
	views in a state machine for web applications (in method actionFormForm (here is set) and method 	printWebPage (here is used to genererate appropriate page))"
	((aString = '') or: [aString isNil]) ifFalse: [self parms at: 'view' put: aString ].! !

!WebSession methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
parent
	"a session manager !! "
	^parent! !

!WebSession methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
site
	"a session manager !! "
	^self parent site! !

!WebSession methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
user
	user isNil ifTrue: [self initUser].
	^user! !


!WebSession methodsFor: 'accessing-other'!
clipboard
	"for cut/copy/paste references to web pages to easier hyperlink them"
	^self otherAt: #clipboard ifAbsent: [self initClipboard].! !

!WebSession methodsFor: 'accessing-other'!
geolocation
	"Geolocation of user's browser, if any"
	^self otherAt: #geolocation ifAbsent: [nil]! !

!WebSession methodsFor: 'accessing-other'!
initialIP
	"from which user came when session was created. It can change later for mobile users!!"
	^self sessionIPs notEmpty 
		ifTrue: [self sessionIPs first]
		ifFalse: ['']! !

!WebSession methodsFor: 'accessing-other'!
lastActivity
	"the last activity (request) timestamp"
	^self otherAt: #lastActivityTimestamp ifAbsent: [nil]! !

!WebSession methodsFor: 'accessing-other'!
lastActivityText
	"the last activity (request) timestamp"
	^self lastActivity notNil
		ifTrue: [self lastActivity printSloString]
		ifFalse: ['']! !

!WebSession methodsFor: 'accessing-other'!
lastApp
	"return WebApplication subclass which was called with last request"
	^self otherAt: #lastApp! !

!WebSession methodsFor: 'accessing-other'!
lastApp: anApplication
	self otherAt: #lastApp put: anApplication! !

!WebSession methodsFor: 'accessing-other'!
lastIP
	"IP of the last request. While last request is cleared during nightly cleanup, this IP stays"
	^self otherAt: #LastIP ifAbsentPut: [self sessionIPs last]! !

!WebSession methodsFor: 'accessing-other'!
lastRequest
	"the last, actualy current request pending. also add request to the history in a request 
	if logging is on."
	"BE CAREFULL!! more than one request can be processed concurrently, so don't count 
	that last reques is actually a current one too!! It mostly is, but not always!!"
	^self otherAt: #lastRequest! !

!WebSession methodsFor: 'accessing-other'!
lastRequest: aRequest
	"remember the last, actualy current request pending. also add request to the history of last 50 requests.
	If first request then also try to find country, language and codePage 
	of the originator"
	self otherAt: #lastRequest put: aRequest.  
	self initParms.				      "clear old parameters"
	self newView: (aRequest queryAt: #view ifAbsent: ['']).  "default new view is view from last request"
	self requests add: aRequest.
	self requests size  > 50 ifTrue: [self requests removeFirst].
	self setLastIP.! !

!WebSession methodsFor: 'accessing-other'!
lastView
	"return a view of WebApllication, which is created in response to last request"
	^self otherAt: #lastView! !

!WebSession methodsFor: 'accessing-other'!
lastView: aSymbol
	self otherAt: #lastView put: aSymbol! !

!WebSession methodsFor: 'accessing-other'!
loginHistory
	"occurences of user logged it/out. As DailyCollection of Array #login/logout, WebUser, timestamp"
	^self otherAt: #LoginHistory ifAbsent: [self initLoginHistory]! !

!WebSession methodsFor: 'accessing-other'!
parms
	"This is a dictionary of parameters in query part of url. When web request arrives, parameters 
 	from query string are written here. When any url is dynamically generated, those parms are 
	appended to it as a query string. You can add, change or delete any parameter to better 
	suit your needs (eg. view=brief to instruct brief view of an object) "
	^self otherAt: #parms! !

!WebSession methodsFor: 'accessing-other'!
requestNum
	"return number of all requests up to now on this session"
	^self requests size! !

!WebSession methodsFor: 'accessing-other'!
requests
	"return the history of all requests on this session as ordered collection with the oldest as 
	first and newest as last"
	^self otherAt: #requests ifAbsent: [self initRequests].! !

!WebSession methodsFor: 'accessing-other'!
sessionIPs
	"all IP addresses of this session. Usually one, except for mobile/roaming users and those with dynamic IP"
	^self otherAt: #SessionIPs ifAbsentPut: [OrderedCollection new]! !


!WebSession methodsFor: 'locale support' stamp: ' 21/4/07 22:07'!
codePage
	^#'UTF_8' "always!!"! !

!WebSession methodsFor: 'locale support'!
country
	^self otherAt: #Country ifAbsent: [nil]! !

!WebSession methodsFor: 'locale support'!
country: aSymbol
	"set the country of a web request originator in ISO 2letter format"
	^self otherAt: #Country put: aSymbol! !

!WebSession methodsFor: 'locale support'!
language
	"preferred language of a web user. Initialy set from the last request (lazily, when first needed)"
	^self otherAt: #Language ifAbsent:
		[self lastRequest notNil 
			ifTrue: [self language: (self originatorLanguageFrom: self lastRequest)]
			ifFalse: [nil] ]! !

!WebSession methodsFor: 'locale support'!
language: aLanguageCodeSymbol
	"preferred language of a web user. Initialy set from the last request (lazily, when first needed)"
	^self otherAt: #Language put: aLanguageCodeSymbol! !

!WebSession methodsFor: 'locale support'!
languageBasic
	" if a combined code (like 'en-us'), return only basic lanuage (like 'en' for 'en-us')"
	^(self language asString includes: $- )
		ifTrue: [self language asString readStream upTo: $- ]
		ifFalse: [self language]! !

!WebSession methodsFor: 'locale support' stamp: ' 21/4/07 22:07'!
originatorCountryFrom: aRequest
	"find an ISO country code from a web request"
	"not yet implemented!!"! !

!WebSession methodsFor: 'locale support' stamp: 'mu 4/6/2008 10:55'!
originatorLanguageFrom: aRequest
	"find a language from a web request"
	| defaultLang header |
	defaultLang := self site defaultLanguage.
	header := aRequest headerAt: 'Accept-Language' ifAbsent:[^defaultLang].
	header values isEmpty ifFalse: [^(header values at: 1) asSymbol].
	^defaultLang! !


!WebSession methodsFor: 'session modes'!
inAdminMode
	"is session in admin mode?"
	^(self otherAt: #sessionMode) = #admin! !

!WebSession methodsFor: 'session modes'!
inDevMode
	"is session in developers mode?"
	^(self otherAt: #sessionMode) = #dev! !

!WebSession methodsFor: 'session modes'!
inNormalMode
	"is session in normal users mode?"
	^(self otherAt: #sessionMode) = #normal! !

!WebSession methodsFor: 'session modes'!
inTranslationMode
	"should text in your Apps be in-place edited for translation?"
	^self inAdminMode or: [self inDevMode]! !

!WebSession methodsFor: 'session modes'!
setAdminMode
	"set session to admin mode"
	self user inAdminGroup ifFalse: [^self error: 'user not in Admininistrators group'].
	self otherAt: #sessionMode put: #admin! !

!WebSession methodsFor: 'session modes'!
setDevMode
	"set session to developers mode"
	self user inAdminGroup ifFalse: [^self error: 'user not Admin!!'].
	self otherAt: #sessionMode put: #dev! !

!WebSession methodsFor: 'session modes'!
setNormalMode
	"set session to normal users mode"
	self otherAt: #sessionMode put: #normal! !


!WebSession methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initAppsForObjects
	appsForObjects := IdentityDictionary new.! !

!WebSession methodsFor: 'initialize-release'!
initClipboard
	^self otherAt: #clipboard put: WebClipboard new! !

!WebSession methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initCookies
	cookies := Array with: false with: false.! !

!WebSession methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initIds
	ids := Array new: 2.! !

!WebSession methodsFor: 'initialize-release'!
initLoginHistory
	^self otherAt: #LoginHistory put: DailyCollection new! !

!WebSession methodsFor: 'initialize-release'!
initOther
	other := Dictionary new! !

!WebSession methodsFor: 'initialize-release'!
initParms
	^self otherAt: #parms put: Dictionary new.! !

!WebSession methodsFor: 'initialize-release'!
initRequests
	^self otherAt: #requests put: OrderedCollection new.! !

!WebSession methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initUser
	self user: self site securityManager guestUser! !

!WebSession methodsFor: 'initialize-release'!
initUserValues
	userValues := Dictionary new! !

!WebSession methodsFor: 'initialize-release'!
initialize
	self setRandomIds.
	self setCreatedTimestamp.
	self initCookies.
	self initParms.
	self initRequests.
	self initUser.
	self setNormalMode. 
	self initAppsForObjects.! !

!WebSession methodsFor: 'initialize-release'!
nilLastApp
	self other notNil ifTrue: [self other removeKey: #lastApp ifAbsent: [nil] ]! !

!WebSession methodsFor: 'initialize-release'!
nilLastRequest
	self other notNil ifTrue: [self other removeKey: #lastRequest ifAbsent: [nil] ]! !

!WebSession methodsFor: 'initialize-release' stamp: 'JM 4/25/2007 21:10'!
setCreatedTimestamp
	created := SpTimestamp now.! !

!WebSession methodsFor: 'initialize-release'!
setRandomIds
	"check uniqueness, try to set a short number if not many sessions yet"
	| max |
	max := (self parent "securityManager" sessions size < 1000)
		ifTrue: [10000]
		ifFalse: [10000000000].
	self id: 
		(AIDASite random next * max) asInteger.
	(self parent existsSessionId: self id)
		ifTrue: [self setRandomIds] "repeat until unique"! !


!WebSession methodsFor: 'testing'!
isActive
	"active if at least one request received last hour or some realtime connection is open"
	self isRealtimeOpen ifTrue: [^true].
	self lastRequest ifNil: [^false].
	^(SpTimestamp now asSeconds - self lastRequest timestamp asSeconds) < 3600! !

!WebSession methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isEncrypted
	^self lastRequest isEncrypted "for now!! "! !

!WebSession methodsFor: 'testing' stamp: 'np 9/4/2008 16:21'!
isExpired
	"more than 15min of inactivity"
	self lastRequest isNil ifTrue: [^false].
	^(SpTimestamp now asSeconds - self lastRequest timestamp asSeconds) > (15*60)! !

!WebSession methodsFor: 'testing'!
isGuest
	"user is Guest - anonymous, not logged in"
	^self user isNil or: [self user isGuest]! !

!WebSession methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isHttpAuthenticationNeeded
	"Usually we authenticate by WebAdminApp logon form. But if site is configured for HTTP 	authentication (to open a separate username/password dialog window to user), and 
	a session is not yet logged in, this method will return true"
	^self isLoggedIn not and: [self site securityManager hasHttpAuthenticationScheme]! !

!WebSession methodsFor: 'testing'!
isInternal
	"session from internal IP or from external IPs of NAT firewals"
	"Set ranges of external IPs in AIDASite internalPs (settings)"
	^self isFromInternalIP or:
		[self site internalIPs contains: [:range | self is: self lastIP inIpRange: range] ]! !

!WebSession methodsFor: 'testing'!
isInternalGuest
	"session from internal IP, which is guest"
	^self isGuest and: [self isInternal]! !

!WebSession methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isLoggedIn
	^self user notNil and: [self user isGuest not]! !

!WebSession methodsFor: 'testing'!
isNew
	"this is first request and cookie not set on the browser yet"
	^self cookie not "enough?"! !

!WebSession methodsFor: 'testing'!
isPublicGuest
	"guest session from public IP"
	^self isGuest and: [self isInternal not]! !

!WebSession methodsFor: 'testing'!
isRealtimeOpen
	"is any realtime connection open on this session?"
	^self realtimeHandler
		isRealtimeOpen! !

!WebSession methodsFor: 'testing'!
isRemoteGuest
	"access from outside via Proxy, not yet logged in"
	^self user isGuest
		and: [self lastRequest isForwarded ]! !

!WebSession methodsFor: 'testing'!
neverLoggedIn
	^self loginHistory isEmpty! !

!WebSession methodsFor: 'testing'!
shouldCountRequests
	| policy |
	policy := self site countingPolicy.
	policy = #all ifTrue: [^true].
	policy = #none ifTrue: [^false].
	policy = #onlyGuests ifTrue: [^self user isGuest].
	policy = #excludeAdmins ifTrue: [^self user inAdminGroup not].
	^true! !

!WebSession methodsFor: 'testing'!
shouldLogRequests
	| policy |
	policy := self site loggingPolicy.
	policy = #all ifTrue: [^true].
	policy = #none ifTrue: [^false].
	policy = #onlyGuests ifTrue: [^self user isGuest].
	policy = #excludeAdmins ifTrue: [^self user inAdminGroup not].
	^true! !

!WebSession methodsFor: 'testing'!
wasLoggedInUser: aWebUser
	"or still is"
	self user = aWebUser ifTrue: [^true].
	^self loginHistory all contains: [:record | (record at: 2) = aWebUser]! !


!WebSession methodsFor: 'testing-user agent'!
isFromLinux
	^self lastRequest isFromLinux! !

!WebSession methodsFor: 'testing-user agent'!
isFromMSIE
	^self lastRequest isFromMSIE! !

!WebSession methodsFor: 'testing-user agent'!
isFromNetscape
	".. or Moziila or Firefox"
	^self lastRequest isFromNetscape! !

!WebSession methodsFor: 'testing-user agent'!
isFromWindows
	^self lastRequest isFromWindows! !

!WebSession methodsFor: 'testing-user agent'!
isMobile
	"a session from mobile device: phone, tablet, .."
	| request userAgent |
	request := self lastRequest. request isNil ifTrue: [^false].
	userAgent := request userAgent.  userAgent isNil ifTrue: [^false].
	( '*Android*' match: userAgent) ifTrue: [^true]. "Android device"
	( '*Symbian*' match: userAgent) ifTrue: [^true]. "Symbian device"
	( 'BlackBerry*' match: userAgent) ifTrue: [^true]. "BlackBerry device"
	('*iPhone*' match: userAgent) ifTrue: [^true].  "iPhone"
	('*iPad*' match: userAgent) ifTrue: [^true].  "iPad"
	^false! !

!WebSession methodsFor: 'testing-user agent'!
isMobilePhone
	"a session from mobile phone"
	^self isMobileTablet not and: [self isMobile]! !

!WebSession methodsFor: 'testing-user agent'!
isMobileTablet
	"a session from mobile tablet (bigger screen than phone)"
	self lastRequest isNil ifTrue: [^false].
	( '*Android*SPH*Mobile*' match: self lastRequest userAgent) ifTrue: [^true]. "Galaxy Tab"
	('*iPad*' match: self lastRequest userAgent) ifTrue: [^true].  "iPad"
	^false! !


!WebSession methodsFor: 'private-other'!
other
	^other! !

!WebSession methodsFor: 'private-other'!
otherAt: aSymbol
	"other values"
	^self otherAt: aSymbol ifAbsent: [nil]! !

!WebSession methodsFor: 'private-other'!
otherAt: aSymbol ifAbsent: aBlock
	"other values"
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!WebSession methodsFor: 'private-other'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!WebSession methodsFor: 'private-other'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !


!WebSession methodsFor: 'redirection'!
redirectLink
	"if this aWebLink is set, then web browser will recreate another request with url from that link. Used, if you like, after form action in one page to show page for some other object, e.g. if you have search field in page in one object, and search result is exactly one, then you want to show result page immediately. You can do this with this method.
Atribute redirectLink is reset to nil immediately after printWebPage and before printHTMLPage in WebMediator method dicpatchClient (see WebMediator sendResponseHeaderOn:)"
	^self otherAt: #redirectLink! !

!WebSession methodsFor: 'redirection'!
redirectLink: aWebLink
	(aWebLink isKindOf: WebLink) | aWebLink isNil ifFalse: [^nil].
	self otherAt: #redirectLink put: aWebLink.! !

!WebSession methodsFor: 'redirection'!
redirectOrigin
	"this is an URL from where the redirection request originates. Used for returning back from
	exception page, for example when you want to see page without access rights, then you are
	redirected to login page. after successfull login, you are redirected back to intended page.
	Redirect origin is set up automatically by redirectLink: request."
	^self otherAt: #redirectOrigin! !

!WebSession methodsFor: 'redirection'!
redirectOrigin: anUrlString
	self otherAt: #redirectOrigin put: anUrlString.! !

!WebSession methodsFor: 'redirection'!
redirectToOrigin
	"Used for returning back from
	exception page, for example when you want to see page without access rights, then you are
      redirected to login page. after successfull login, you are redirected back to intended page.
	Redirect origin is set up automatically by redirectLink: request."
	self redirectOrigin notNil ifTrue:
		[self redirectLink: (WebLink text: '' linkTo: self redirectOrigin).
		self redirectOrigin: nil].! !

!WebSession methodsFor: 'redirection'!
shouldRedirect
	^self redirectLink notNil! !


!WebSession methodsFor: 'releasing state'!
releaseApplicationState
	self removeAppsForObjects.
	self nilLastRequest.
	self nilLastApp.
	self initRequests.
	self initClipboard.
	self redirectLink: nil; redirectOrigin: nil.
	self realtimeHandler removeAll! !

!WebSession methodsFor: 'releasing state'!
removeAppsForObjects
	self appsForObjects keysAndValuesDo: [:object :dict |
		(dict includesKey: #web) ifTrue: [(dict at: #web) removeYourself] ].
	self initAppsForObjects! !

!WebSession methodsFor: 'releasing state'!
removeIfNewGuest
	"remove yourself if completelly fresh Guest session. Used for DOS attack countermeasures"
	self isGuest ifFalse: [^nil].
	self requests size > 1 ifTrue: [^nil]. "a lot of requests, probably just something is missing"
	(SpTimestamp now asSeconds - self created asSeconds) < 1 "if session is not old already"
		ifTrue: [self removeYourself]! !

!WebSession methodsFor: 'releasing state'!
removeYourself
	" .. from session manager"
	self parent notNil ifTrue: [self parent removeSession: self].
	self releaseApplicationState.
	self parent: nil.! !


!WebSession methodsFor: 'user values' stamp: ' 21/4/07 22:07'!
userValueAt: aSymbol
	"anything you need to share among Apps in that seesion, like last selected stuff, etc."
	^self userValueAt: aSymbol ifAbsent: [nil]! !

!WebSession methodsFor: 'user values' stamp: ' 21/4/07 22:07'!
userValueAt: aSymbol ifAbsent: aBlock
	^self userValues at: aSymbol ifAbsent: aBlock! !

!WebSession methodsFor: 'user values' stamp: ' 21/4/07 22:07'!
userValueAt: aSymbol put: anObject
	^self userValues at: aSymbol put: anObject! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebSession class
	instanceVariableNames: ''!

!WebSession class methodsFor: 'instance creation' stamp: 'mivsek 8/22/2007 21:17'!
new
	^super basicNew.
! !

!WebSession class methodsFor: 'instance creation' stamp: 'JM 4/25/2007 21:21'!
newOn: aWebSessionManager
	"new web session on a specified session manager"
	| session |
	session := super basicNew.
	session parent: aWebSessionManager.
	session initialize.
	^session! !


Object subclass: #WebSessionManager
	instanceVariableNames: 'site sessions'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Core'!
!WebSessionManager commentStamp: '<historical>' prior: 0!
WebSessionManager manages all sessions on this website. It creates a new session if needed or finds existing one from a web request. There are also methods for releasing nonactive (more that an hour without activity) or guest sessions, and to release session application state (instances of App classes)
!


!WebSessionManager methodsFor: 'accessing'!
activeSessionsForUsername: aString
	"find active sessions for a user with that username"
	"(AIDASite named: 'wikib') sessionManager activeSessionsForUsername: 'mivsek' "
	^self allActiveSessions 
		select: [:each | each user username = aString]! !

!WebSessionManager methodsFor: 'accessing'!
allActiveSessions
	^self allSessions 
		select: [:each | each isActive].! !

!WebSessionManager methodsFor: 'accessing'!
allGuestSessions
	"guest and never logged in"
	^self allSessions select: [:each | 
		(each user isNil or: [each user isGuest]) and: [each neverLoggedIn] ].! !

!WebSessionManager methodsFor: 'accessing'!
allLoggedInSessions
	^self allSessions 
		select: [:each | each isLoggedIn]! !

!WebSessionManager methodsFor: 'accessing'!
allMobileSessions
	^self allSessions 
		select: [:each | each isMobile].! !

!WebSessionManager methodsFor: 'accessing'!
allNonactiveGuestSessions
	"guest sessions nonactive more that one hour"
	^self allGuestSessions 
		select: [:each | each isActive not].! !

!WebSessionManager methodsFor: 'accessing'!
allRealtimeSessions
	"sessions with at least one realtime (WebSocket etc.) connection active"
	^self allSessions 
		select: [:each | each isRealtimeOpen].! !

!WebSessionManager methodsFor: 'accessing' stamp: ' 7/6/08 18:41'!
allSessions
	^self sessions values asSet  "to remove duplicates because the session id can be double, 
							     one for ssl too!!"! !

!WebSessionManager methodsFor: 'accessing'!
allSessionsForUser: aWebUser
	"all sessions (logged-in or not) for that user"
	^self allSessions select: [:each | 
		each user = aWebUser or: 
			[each isLoggedIn not and: [each wasLoggedInUser: aWebUser] ] ]! !

!WebSessionManager methodsFor: 'accessing'!
allWereLoggedSessions
	"all sessions which were or still are logged in"
	^self allSessions select: [:each |
		each isLoggedIn or: [each neverLoggedIn not] ] "was or still is logged in"! !

!WebSessionManager methodsFor: 'accessing'!
findAllSessionsWithUsername: aString
	^self sessions values 
		select: [:each | each user username = aString]! !

!WebSessionManager methodsFor: 'accessing'!
findSessionId: anIdNumber
	^self sessions 
		at: anIdNumber 
		ifAbsent: [nil].! !

!WebSessionManager methodsFor: 'accessing'!
findSessionWithUsername: aString
	^self sessions 
		detect: [:each | each user username = aString] 
		ifNone: [nil].! !

!WebSessionManager methodsFor: 'accessing' stamp: ' 7/6/08 18:41'!
site
	^site! !


!WebSessionManager methodsFor: 'adding-removing'!
addSession: aWebSession
"	Transcript cr; show: 'session manager: adding new session with id ', aWebSession id printString,
	' from ', self firstRequestFromStack realPeerIp.
"	(self sessions includesKey:  aWebSession id) 
		ifTrue: [self error: 'session with that id already exists!!'].
	self sessions 
		at: aWebSession id 
		put: aWebSession.! !

!WebSessionManager methodsFor: 'adding-removing'!
findOrCreateSessionFor: aRequest
	"Try to find a session among currently live sessions. It helps with a session id in a query 
	part of url. If not found, or id not in query string, then make a new session"
	| session id new hasCookie |
	self site critical:

		[(aRequest hasCookie and: [aRequest idFromCookie notNil])
			ifTrue: 
				[id := aRequest idFromCookie. 
				hasCookie := true. self site log: ' cookie ' ]
			ifFalse: 
				[hasCookie := false. 
				id := (aRequest queryAt: 'id') isNil 
					ifTrue:    "no session id in query part of URL"
						[new := self newSessionCookie: false.
						new id]
					ifFalse: [aRequest queryAt: 'id' ] ].

		session := (self existsSessionId: id asInteger)
			ifTrue: [self findSessionId: id asInteger] 
			ifFalse: [self newSessionCookie: hasCookie id: id asInteger].

		session cookie: hasCookie. 
		(hasCookie not and: [self site urlsWithSessionId]) 
			ifTrue: [session addSessionID].

		session checkExpirationAndPossiblyLogoutFor: aRequest.

		session requests size = 1 
			ifTrue: [self countNewVisitor] 
			ifFalse: [self checkAndCountReturningVisitor: session].
		session lastRequest: aRequest.  "also into history, reset view, init parms"
		session
			registerIP; 
			setLastActivity.

		(aRequest includesQuery:  'setLanguage') ifTrue:
			[session language: (aRequest queryAt: 'setLanguage') asSymbol].
		^session
	]! !

!WebSessionManager methodsFor: 'adding-removing' stamp: ' 7/6/08 18:41'!
newSessionCookie: aBoolean
	"open and return a fresh new session"
	^self newSessionCookie: aBoolean id: nil! !

!WebSessionManager methodsFor: 'adding-removing'!
newSessionCookie: aBoolean id: aSessionID
	"open, add to sessions and return a fresh new session"
	| session |
	session := WebSession newOn: self.
	aSessionID notNil 
		ifTrue: [session id: aSessionID].
	self site log: ' new session '.
	self addSession: session.
	session cookie: aBoolean.
	^session! !

!WebSessionManager methodsFor: 'adding-removing'!
releaseApplicationState
	"release all application state of sessions"
	^self allSessions do: [:each | each releaseApplicationState].! !

!WebSessionManager methodsFor: 'adding-removing'!
removeGuestSessions
	"all guest (never logged in) sessions"
	^self allGuestSessions do: [:each | 
		each parent == self 
			ifTrue: [each removeYourself] 
			ifFalse: [self removeSession: each] ]. "in which case?"! !

!WebSessionManager methodsFor: 'adding-removing'!
removeNonactiveGuestSessions
	"all guest (never logged in) sessions inactive more than one hour"
	^self allNonactiveGuestSessions do: [:each | 
		each parent == self 
			ifTrue: [each removeYourself] 
			ifFalse: [self removeSession: each] ]. "in which case?"! !

!WebSessionManager methodsFor: 'adding-removing'!
removeSession: aWebSession
	"remove from sessions"
	self site critical:
		[self sessions 
			removeKey: aWebSession id ifAbsent: [] ].! !


!WebSessionManager methodsFor: 'private' stamp: ' 7/6/08 18:41'!
checkAndCountReturningVisitor: aSession
	"returning visitor is those who is not active more than 1h"
	(aSession isActive not and: [aSession requests size > 1]) ifTrue:
		[self site critical: [self site returningVisitorsCounter incCounter] ]! !

!WebSessionManager methodsFor: 'private' stamp: ' 7/6/08 18:41'!
countNewVisitor
	self site critical:
		[self site newVisitorsCounter incCounter]! !

!WebSessionManager methodsFor: 'private' stamp: 'janko 3/19/2012 13:21'!
preferredUrl
	^'/sessions'! !

!WebSessionManager methodsFor: 'private'!
printString
	^'WebSessionManager on: ', self site name, '
	sessions: ', self allSessions size printString, '
	logged-in: ', self allLoggedInSessions size printString, '
	guest: ', self allGuestSessions size printString, '
	mobile: ', self allMobileSessions size printString, '
	active: ', self allActiveSessions size printString, '
	realtime: ', self allRealtimeSessions size printString, '
	queued: ', self queuedMsgCount printString! !

!WebSessionManager methodsFor: 'private'!
queuedMsgCount
	"count queues on all contexts on all apps. It should be low otherwise something is wrong"
	| count |
	count := 0.
	self sessions do: [:session |
		session appsForObjects values do: [:assoc |
			(assoc value at: #web) "app" contexts values do: [:ctx |
				ctx isFirst ifTrue:
					[count := count + ctx queue size] ] ] ].
	^count! !

!WebSessionManager methodsFor: 'private' stamp: ' 7/6/08 18:41'!
sessions
	"dictionary of sessions by session id as the key. Not that session can have two ids, for ssl too!!"
	sessions isNil ifTrue: [self initSessions].
	^sessions! !

!WebSessionManager methodsFor: 'private' stamp: ' 7/6/08 18:41'!
site: anAIDASite
	site := anAIDASite.! !


!WebSessionManager methodsFor: 'testing'!
existsSessionId: anIdNumber
	^self sessions
		includesKey: anIdNumber.! !


!WebSessionManager methodsFor: 'initialize-release' stamp: ' 7/6/08 18:41'!
initSessions
	sessions := Dictionary new.! !

!WebSessionManager methodsFor: 'initialize-release' stamp: ' 7/6/08 18:41'!
initialize
	self initSessions.

"WebSessionManager default initialize"! !


!WebSessionManager methodsFor: 'private-serving'!
resourceFor: aRequest
	"from router to know, where to route a request. Route it to request's session"
	^aRequest session! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebSessionManager class
	instanceVariableNames: ''!

!WebSessionManager class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
default
	^AIDASite default sessionManager! !


!WebSessionManager class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newOn: aSite
	^super new 
		initialize; 
		site: aSite! !


Object subclass: #WebStatistics
	instanceVariableNames: 'site referers refererStopList'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Core'!
!WebStatistics commentStamp: '<historical>' prior: 0!
WebStatistics to collect few statistical data (like referers). This is in addition to counters in URLResolver.  See also WebStatisticsApp for reporting the stats with numbers and graphs.

!


!WebStatistics methodsFor: 'private-referers' stamp: ' 21/8/07 09:38'!
addNewReferer: anUrlString

	"add new counter to referers dictionary"

	self referers 
		at: anUrlString
		put: WebCounter new.! !

!WebStatistics methodsFor: 'private-referers' stamp: ' 21/8/07 09:38'!
countReferer: anUrlString
	| url |
	url := self prepareReferer: anUrlString.
	url isEmpty ifTrue: [^self].
	(self refererOnStopList: url) ifTrue: [^self].
	(self referers includesKey: url)
		ifFalse: [self addNewReferer: url].
	(self referers at: url) incCounter! !

!WebStatistics methodsFor: 'private-referers' stamp: ' 21/8/07 09:38'!
prepareReferer: anUrlString

	"ingnore all parameters in url"

	^(anUrlString copyUpTo: $?)! !

!WebStatistics methodsFor: 'private-referers' stamp: ' 21/8/07 09:38'!
refererCounterFor: anUrlString

	^self referers at: anUrlString ifAbsent: [^nil]! !

!WebStatistics methodsFor: 'private-referers' stamp: ' 21/8/07 09:38'!
refererOnStopList: anUrlString

	| |
	^self refererStopList includes: anUrlString! !

!WebStatistics methodsFor: 'private-referers' stamp: ' 21/8/07 09:38'!
removeReferer: anUrlString

	self referers removeKey: anUrlString ifAbsent: [^self].! !

!WebStatistics methodsFor: 'private-referers' stamp: ' 21/8/07 09:38'!
removeReferersOnStopList

	self refererStopList do: [:referer |
		self removeReferer: referer]

"WebStatistics default  removeReferersOnStopList"! !


!WebStatistics methodsFor: 'referers' stamp: 'janko 10/31/2008 16:11'!
allRefererCounts
	"return a collection of all referers and their total counts, most counted first"
	| collection |
	collection := OrderedCollection new.
	self referers keysAndValuesDo: [:referer :counter |  
		collection add: (Array 
			with: referer
			with: counter total)].
	^SortedCollection
		withAll: collection
		sortBlock: [:a :b | (a at: 2) > (b at: 2)].

"WebStatistics default allRefererCounts size"! !

!WebStatistics methodsFor: 'referers' stamp: ' 21/8/07 09:38'!
allRefererCountsToday
	"return a collection of today referers and their total counts, most counted first"
	| collection |
	collection := OrderedCollection new.
	self referers keysAndValuesDo: [:referer :counter |  
		collection add: (Array 
			with: referer
			with: counter today)].
	^SortedCollection
		withAll: (collection select: [:each | each value last > 0])
		sortBlock: [:a :b | (a at: 2) > (b at: 2)].

"WebStatistics default allReferersAndCounts"! !

!WebStatistics methodsFor: 'referers' stamp: ' 21/8/07 09:38'!
allRefererCountsWeekly
	"return a collection of current week referers and their total counts, most counted first"
	| collection |
	collection := OrderedCollection new.
	self referers keysAndValuesDo: [:referer :counter |  
		collection add: (Array 
			with: referer
			with: counter weekly)].
	^SortedCollection
		withAll: (collection select: [:each | each value last > 0])
		sortBlock: [:a :b | (a at: 2) > (b at: 2)].

"WebStatistics default allReferersAndCounts"! !

!WebStatistics methodsFor: 'referers' stamp: ' 21/8/07 09:38'!
allRefererCountsYesterday
	"return a collection of yesterday referers and their total counts, most counted first"
	| collection |
	collection := OrderedCollection new.
	self referers keysAndValuesDo: [:referer :counter |  
		collection add: (Array 
			with: referer
			with: counter yesterday)].
	^SortedCollection
		withAll: (collection select: [:each | each value last > 0])
		sortBlock: [:a :b | (a at: 2) > (b at: 2)].

"WebStatistics default allReferersAndCounts"! !

!WebStatistics methodsFor: 'referers' stamp: 'janko 10/31/2008 16:05'!
allReferersJustOneHit
	"return a collection of all referers with just one hit and older that one week"
	| collection secBefore7days |
	secBefore7days := SpTimestamp now asSeconds - (7 * 3600 * 24).
	collection := OrderedCollection new.
	self referers keysAndValuesDo: [:referer :counter |
		(counter total = 1 and: [secBefore7days >= counter started asSeconds ]) ifTrue:
			[collection add: referer] ].
	^collection

"WebStatistics default allReferersJustOneHit size"! !

!WebStatistics methodsFor: 'referers' stamp: ' 21/4/07 22:07'!
refererStopList
	refererStopList isNil ifTrue: [self initRefererStopList].
	^refererStopList! !

!WebStatistics methodsFor: 'referers' stamp: 'janko 10/31/2008 16:07'!
referers
	referers isNil ifTrue: [self initReferers].
	^referers! !

!WebStatistics methodsFor: 'referers' stamp: 'janko 10/31/2008 16:11'!
removeReferersJustOneHit
	"..and older that 7 days"
	self allReferersJustOneHit do: [:each | self referers removeKey: each]
	
"WebStatistics default removeReferersJustOneHit"! !


!WebStatistics methodsFor: 'collecting' stamp: 'mu 4/6/2008 10:16'!
collectStatsFrom: aWebRequest
	| referer |
	referer := AIDASite convert: aWebRequest referer fromCodepage: #UTF8.
	(referer notNil and: [(self isLocalUrl: referer) not]) 
		ifTrue: [self countReferer: referer]! !


!WebStatistics methodsFor: 'initialize-release' stamp: ' 21/8/07 09:38'!
initRefererStopList
	refererStopList := Set new.
	refererStopList
		add: '[unknown origin]';
		add: 'bookmarks';
		add: 'http://lw2fd.hotmail.msn.com/cgi-bin/getmsg';
		add: 'http://mobitel.sux.nu/cgi-bin/tabla/showpost.pl'.
"AIDASite default statistics initRefererStopList"! !

!WebStatistics methodsFor: 'initialize-release' stamp: ' 21/8/07 09:38'!
initReferers
	referers := Dictionary new.

"AIDASite default statistics initReferers"! !


!WebStatistics methodsFor: 'private'!
isLocalUrl: anUrlString
	"true, if this url points to page from this server"
	^self site uriPattern contains: [:siteIdentifier | 
		siteIdentifier host = '*'
			ifTrue: [('http://',  '*') match: anUrlString] "to avoid double '**' "
			ifFalse: [('http://', siteIdentifier host, '*') match: anUrlString]].! !

!WebStatistics methodsFor: 'private' stamp: 'np 10/24/2008 12:52'!
isNewReferer: anUrlString onDate: aDate
	"this referer is new if it occurs for a first time in last 7 days"
	| counter |
	counter := self refererCounterFor: anUrlString.
	^counter isFirstOnDate: aDate sinceDays: 7! !

!WebStatistics methodsFor: 'private' stamp: ' 21/8/07 09:38'!
site: anAIDASite
	site := anAIDASite.! !


!WebStatistics methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
site
	^site! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebStatistics class
	instanceVariableNames: ''!

!WebStatistics class methodsFor: 'log analysis' stamp: ' 21/4/07 22:07'!
analyzeAndStoreLine: aLineAsArray into: aDictionary forDate:aDate

	| datum |
	((aLineAsArray at: 2) > ' ' ) ifTrue:
		[(aLineAsArray at: 2) = '#Date:'
			ifTrue: [datum := self parseDatum: (aLineAsArray at: 3).]
			ifFalse: [datum:=aDate.].
		((aLineAsArray at: 2) copyFrom: 1 to: 1) = '#' ifFalse: 
			[aLineAsArray at: 2 put: 
				(Time readFrom: (ReadStream on: (aLineAsArray at: 2))).
			aLineAsArray at: 1 put: 
				(Timestamp new fromDate: datum andTime: (aLineAsArray at: 2)).
			(aDictionary at:  (aLineAsArray at: 3) ifAbsentPut: [WebCounter new  ] )
				 incCounterOnTimestamp: (aLineAsArray at: 1).
			].
		].
	^datum! !

!WebStatistics class methodsFor: 'log analysis' stamp: ' 21/4/07 22:07'!
bossCountersFromIISLogsIn: aDirectoryString

	" WebStatistics bossCountersFromIISLogsIn: 'h:\winnt\system32\logfiles\w3svc3\temp'  "
	| file boss |
	file := 'LogDict.boss'.
	boss := BinaryObjectStorage onNew: file asFilename writeStream.
	boss nextPut: 
		(self countersFromIISLogsIn: aDirectoryString).
	boss close.! !

!WebStatistics class methodsFor: 'log analysis' stamp: ' 21/4/07 22:07'!
convertFromGMT: aTimestamp

	"IIS logs have time in GMT timezone. Return local time"
	TimeZone reference
		convertGMT: aTimestamp asSeconds
		do: [:date :sec | 	^Timestamp fromDate: date andTime: (Time fromSeconds: sec)]! !

!WebStatistics class methodsFor: 'log analysis' stamp: ' 21/4/07 22:07'!
countUrlsIn: aFileString to: anUrlDictionary

self parseFile: aFileString into: anUrlDictionary.! !

!WebStatistics class methodsFor: 'log analysis' stamp: ' 21/4/07 22:07'!
countersFromIISLogsIn: aDirectoryString

	"return a dictionary (url as key) of counters for urls in all IIS log files in specified directory"
	" WebStatistics countersFromIISLogsIn: 'h:\winnt\system32\logfiles\w3svc8'  "

	| logFiles urlCounters |
	logFiles := aDirectoryString asFilename directoryContents.
	logFiles := SortedCollection
		withAll: logFiles 	sortBlock: [:a :b | a < b].
	urlCounters := Dictionary new.
	logFiles do: [:logFile | 
		" self halt. "
		self countUrlsIn: (aDirectoryString, '\', logFile) to: urlCounters].
	^urlCounters! !

!WebStatistics class methodsFor: 'log analysis' stamp: 'JM 4/26/2007 21:34'!
dateFromFilename: aFilename

	^SpDate 
		newDay: (aFilename tail copyFrom: 7 to: 8) asInteger
		month:(aFilename tail copyFrom: 5 to: 6) asInteger
		year: ((aFilename tail copyFrom: 3 to: 4) asInteger + 2000)! !

!WebStatistics class methodsFor: 'log analysis' stamp: 'JM 4/26/2007 21:35'!
parseDatum: stringDatum 
	"pretvorimo datum iz formata LLLL-MM-DD v date format
	| tmp | 
	 tmp := DelimitedFile new. 
	Transcript show: (tmp parseDatum: '1999-12-11') printString ; cr  
	"

	| datumStream leto mesec dan |
	datumStream := (stringDatum copyReplaceAll: '-' with: ' ') readStream.
	leto := (self  parseWords: datumStream) asNumber.
	mesec := (self  parseWords: datumStream) asNumber.
	dan := (self  parseWords: datumStream) asNumber.
	^SpDate newDay: dan
		month: mesec
		year: leto! !

!WebStatistics class methodsFor: 'log analysis' stamp: ' 21/4/07 22:07'!
parseFile: aFile 
	"
 	Trenutno opusceno, osnova za parseFile: into:
	WebStatistics parseFile: 'h:\winnt\system32\logfiles\w3svc8\ex990506.log' 
	"

	| logFile stream cr besedeVrstice vrstica stevecBesed |
	cr := Character cr.	" self halt. "
	logFile := aFile asFilename.
	stream := logFile readStream.
	[stream atEnd] whileFalse: 
			[besedeVrstice := Array new: 15.
			stevecBesed := 1.
			vrstica := (stream throughAll: (String with: cr)) readStream.
			[vrstica atEnd] whileFalse: 
					[besedeVrstice at: stevecBesed put: vrstica parseWordsIntoArray.
					stevecBesed := stevecBesed + 1].
			vrstica close].
	stream close! !

!WebStatistics class methodsFor: 'log analysis' stamp: ' 21/4/07 22:07'!
parseFile: aFile into: URLCountDictionary 
	| stream besedeVrstice vrstica stevecBesed datum |
	datum := Date today.
	stream := aFile asFilename readStream.
	[stream atEnd] whileFalse: 
		[besedeVrstice := Array new: 15.
		stevecBesed := 2.
		vrstica := (stream throughAll: (String with: Character cr)) readStream.
		[vrstica atEnd] whileFalse: 
			[besedeVrstice at: stevecBesed put: (self parseWords: vrstica) .
			stevecBesed := stevecBesed + 1].
 		datum:= self analyzeAndStoreLine: besedeVrstice 
			into: URLCountDictionary forDate:datum.
		vrstica close.].
	stream close

	" test lines : 
	Xx := Dictionary new.
	WebStatistics parseFile: 'h:\winnt\system32\logfiles\w3svc8\ex990506.log' into: Xx.
	Transcript show: Xx printString
	"! !

!WebStatistics class methodsFor: 'log analysis' stamp: ' 21/4/07 22:07'!
parseWords: inputStream 
	"Answer the contents of the receiver, up to the next separator  character."

	| aStream |
	aStream := (String new: 200) writeStream.
	inputStream skipSeparators.
	inputStream class endOfStreamSignal handle: [:ex | ex return]
		do: 
			[
			[| char |
			char := inputStream next.
			char isSeparator ifTrue: [^aStream contents] ifFalse: [aStream nextPut: char]]
					repeat].
	^aStream contents! !


!WebStatistics class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
default

	^AIDASite default statistics! !


!WebStatistics class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newOn: anAIDASite
	^super new site: anAIDASite! !


Object subclass: #WebUser
	instanceVariableNames: 'parent id username password name surname company address city zip country website email phone fax other'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Core'!
!WebUser commentStamp: '<historical>' prior: 0!
WebUser is the user on our website. This class holds basic user data, address, login history, etc. It can also have user specific data in #otherValues instvar. There are few predefined users like Guest (anymone not logged in), Admin (have access to everything, kind of 'root' user) and Extranet (not used much yet).!


!WebUser methodsFor: 'groups' stamp: ' 21/4/07 22:07'!
addToActivatingGroup
	self parent addActivatingUser: self! !

!WebUser methodsFor: 'groups' stamp: ' 21/4/07 22:07'!
addToRegisteredGroup
	self parent addRegisteredUser: self! !

!WebUser methodsFor: 'groups' stamp: ' 21/4/07 22:07'!
becomeAdmin
	self parent adminGroup addUser: self! !

!WebUser methodsFor: 'groups'!
groups 
	"where this user is a member"
	^self parent groups select: [:group | group users includes: self]! !


!WebUser methodsFor: 'accessing-address'!
address
	address isNil ifTrue: [^'']. 
	^address! !

!WebUser methodsFor: 'accessing-address'!
address: aString
	address := aString.! !

!WebUser methodsFor: 'accessing-address'!
city
	city isNil ifTrue: [^'']. 
	^city! !

!WebUser methodsFor: 'accessing-address'!
city: aString
	city := aString.! !

!WebUser methodsFor: 'accessing-address'!
company
	company isNil ifTrue: [^'']. 
	^company! !

!WebUser methodsFor: 'accessing-address'!
company: aString 
	company := aString.! !

!WebUser methodsFor: 'accessing-address'!
country
	country isNil ifTrue: [^'']. 
	^country! !

!WebUser methodsFor: 'accessing-address'!
country: aString
	country := aString.! !

!WebUser methodsFor: 'accessing-address'!
email 
	email isNil ifTrue: [^''].
	^email! !

!WebUser methodsFor: 'accessing-address'!
email: aString
	email := aString.! !

!WebUser methodsFor: 'accessing-address'!
fax
	fax isNil ifTrue: [^''].
	^fax! !

!WebUser methodsFor: 'accessing-address'!
fax: aString 
	fax := aString.! !

!WebUser methodsFor: 'accessing-address'!
phone 
	phone isNil ifTrue: [^''].
	^phone! !

!WebUser methodsFor: 'accessing-address'!
phone: aString 
	phone := aString.! !

!WebUser methodsFor: 'accessing-address'!
website
	website isNil ifTrue: [^''].
	^website! !

!WebUser methodsFor: 'accessing-address'!
website: aString
	website := aString! !

!WebUser methodsFor: 'accessing-address'!
zip
	zip isNil ifTrue: [^'']. 
	^zip! !

!WebUser methodsFor: 'accessing-address'!
zip: aString
	zip := aString.! !


!WebUser methodsFor: 'accessing' stamp: 'janko 8/6/2011 19:42'!
asPerson
	"parallel Person object (from Party framework if present, otherwise nil)"
	^self otherAt: #Person ifAbsent: [^self initPerson]! !

!WebUser methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
asWebUser
	^self! !

!WebUser methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
id
	"unique id of that user"
	^id! !

!WebUser methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
id: aNumber
	id := aNumber.! !

!WebUser methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
menuName
	"in dropdown menus"
	^self surnameName! !

!WebUser methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
name
	name isNil ifTrue: [self asPerson notNil ifTrue: [^self asPerson name] ifFalse: [^''] ].
	^name! !

!WebUser methodsFor: 'accessing'!
name: aString 
	self isLocked ifTrue: [^self error: 'user locked, changes not allowed!! '].
	self asPerson notNil ifTrue: [^self asPerson name: aString].
	name := aString trimBlanks.! !

!WebUser methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
nameSurname 
	^self name, ' ', self surname! !

!WebUser methodsFor: 'accessing' stamp: 'jm 4/22/2009 22:23'!
password
	"returns SHA1 encrypted password!! "
	password isNil ifTrue: [^''].
	^password! !

!WebUser methodsFor: 'accessing' stamp: 'np 4/6/2008 15:53'!
password: aString	
	"Store hashed string"
	aString notEmpty ifTrue: [
		password := WebSecurityManager hashPassword: aString]! !

!WebUser methodsFor: 'accessing' stamp: 'jm 4/22/2009 19:56'!
passwordAsHex
	"leading zero in each byte ommited!! 0F = just F !!"
	"Squeak specific!!"
	^(self password
		inject: (WriteStream on: String new)
		into:
			[:stream :byte | 
			stream nextPutAll: 
				((byte printStringRadix: 16) copyReplaceAll: '16r' with: ''). "Squeak specific!!"
			stream]) contents! !

!WebUser methodsFor: 'accessing' stamp: 'np 10/20/2008 16:43'!
passwordText
	"password is encripted/invisible anway, so return just empty string"
	^''! !

!WebUser methodsFor: 'accessing' stamp: 'np 10/20/2008 16:43'!
passwordText: aString
	aString = self passwordText "all *****, this means that password was not changed"
		ifTrue: [^nil]. 
	aString trimBlanks isEmpty ifTrue: [^nil].
	^self password: aString! !

!WebUser methodsFor: 'accessing'!
site
	^self parent site! !

!WebUser methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
someId
	"just return some text, possibly surnameName"
	self surnameName trimBlanks notEmpty ifTrue: [^self surnameName].
	self email notEmpty ifTrue: [^self email].
	^'----'! !

!WebUser methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
surname
	surname isNil ifTrue: [self asPerson notNil ifTrue: [^self asPerson surname] ifFalse: [^''] ].
	^surname! !

!WebUser methodsFor: 'accessing'!
surname: aString 
	self isLocked ifTrue: [^self error: 'user locked, changes not allowed!! '].
	self asPerson notNil ifTrue: [^self asPerson surname: aString].
	surname := aString trimBlanks.! !

!WebUser methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
surnameName
	^self surname, ' ', self name! !

!WebUser methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
username
 
	username isNil ifTrue: [^''].
	^username.! !

!WebUser methodsFor: 'accessing'!
username: aString 
	self isLocked ifTrue: [^self error: 'user locked, changes not allowed!! '].
	username := aString asLowercase trimBlanks.! !

!WebUser methodsFor: 'accessing' stamp: 'janko 8/6/2011 19:43'!
uuid
	"unique identifier "
	^self otherAt: #uuid ifAbsentPut: [(AIDASite random next * 1000000000) rounded printString]! !


!WebUser methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:42'!
autoLogout
	"logout after 15min of inactivity. default is NO!! "
	^self otherAt: #AutoLogout ifAbsent: [false]! !

!WebUser methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:44'!
autoLogout: aBoolean
	"logout after 15min of inactivity"
	^self otherAt: #AutoLogout put: aBoolean! !

!WebUser methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:42'!
lastAppUrl
	"an url which last WebApplication was called. "
	^self otherAt: #LastAppUrl ifAbsent: [nil].! !

!WebUser methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:44'!
lastAppUrl: aString
	"an url which last WebApplication was called. It is set AFTER the app view is generated!!"
	^self otherAt: #LastAppUrl put: aString! !

!WebUser methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:42'!
loginHistory
	"occurences of user logged it/out. As DailyCollection of Array #login/logout, WebUser, timestamp"
	^self otherAt: #LoginHistory ifAbsent: [self initLoginHistory]! !

!WebUser methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:42'!
logoutFromUrl
	"From which page user logout. To be redirected back after login"
	^self otherAt: #LogoutFromUrl ifAbsent: [nil].! !

!WebUser methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:44'!
logoutFromUrl: aString
	"From which page user logout. To be redirected back after login"
	^self otherAt: #LogoutFromUrl put: aString! !

!WebUser methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:44'!
resetLocked
	"changes of user data allowed again"
	^self otherAt: #Locked put: false! !

!WebUser methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:44'!
setLocked
	"changes of user data not allowed"
	^self otherAt: #Locked put: true! !


!WebUser methodsFor: 'private' stamp: 'janko 4/20/2012 17:09'!
copy
	| new |
	new := super copy.
	new 
		parent: nil;
		initOtherValues;
		name: self name;
		surname: self surname. "because it can be on his aPerson"
	self copyOtherTo: new.
	^new! !

!WebUser methodsFor: 'private'!
copyOtherTo: aWebUser
	"override in subclasses for specifics here"! !

!WebUser methodsFor: 'private' stamp: 'jm 9/8/2010 21:11'!
logLogin
	self loginHistory
		add: (Array with: #login with: SpTimestamp now)
		onDate: SpDate today! !

!WebUser methodsFor: 'private' stamp: 'jm 9/8/2010 21:11'!
logLogout
	self loginHistory 
		add: (Array with: #logout with: SpTimestamp now)
		onDate: SpDate today! !

!WebUser methodsFor: 'private' stamp: ' 21/4/07 22:07'!
migrateToUnicode
	"from iso8859-2"
	"WebUser allInstances do: [:each | each migrateToUnicode]"
	username notNil ifTrue: [username := username ensureUnicodeSloveneChars].
	password notNil ifTrue: [password := password ensureUnicodeSloveneChars].
	name notNil ifTrue: [name := name ensureUnicodeSloveneChars].
	surname notNil ifTrue: [surname := surname ensureUnicodeSloveneChars].
	company notNil ifTrue: [company := company ensureUnicodeSloveneChars].
	city notNil ifTrue: [city := city ensureUnicodeSloveneChars].
	country notNil ifTrue: [country := country ensureUnicodeSloveneChars].! !

!WebUser methodsFor: 'private' stamp: 'janko 8/6/2011 19:49'!
other
	^other! !

!WebUser methodsFor: 'private' stamp: 'janko 8/6/2011 19:43'!
otherAt: aString
	^self otherAt: aString ifAbsent: [nil]! !

!WebUser methodsFor: 'private' stamp: 'janko 8/6/2011 19:44'!
otherAt: aString ifAbsent: aBlock
	self other isNil ifTrue: [^aBlock value].
	^self other at: aString ifAbsent: [aBlock value]! !

!WebUser methodsFor: 'private' stamp: 'janko 8/6/2011 19:44'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOtherValues].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!WebUser methodsFor: 'private' stamp: 'janko 8/6/2011 19:44'!
otherAt: aString put: anObject
	self other isNil ifTrue: [self initOtherValues].
	^self other at: aString put: anObject! !

!WebUser methodsFor: 'private' stamp: ' 21/4/07 22:07'!
parent
	^parent! !

!WebUser methodsFor: 'private' stamp: ' 21/4/07 22:07'!
parent: aWebSecurityManager
	parent := aWebSecurityManager! !

!WebUser methodsFor: 'private' stamp: 'janko 8/6/2011 19:44'!
person: aPerson
	"connect to parrallel Person from Party framework"
	self otherAt: #Person put: aPerson.
	aPerson asWebUser ~= self ifTrue: [aPerson webUser: self].! !

!WebUser methodsFor: 'private'!
preferredUrl
	| nme |
	nme := self nameSurname trimBlanks asSloveneWithoutCircumflexes asHttpFriendly.
	^'/user/', nme! !

!WebUser methodsFor: 'private'!
printString 
	^'a', self class name, ' named ', self surname, ', ', self name, ' (', self username, ') '! !

!WebUser methodsFor: 'private' stamp: 'janko 8/6/2011 19:44'!
setRegisteredTimestamp
	"when this user was registered (personally or by someone else)"
	^self otherAt: #RegisteredTimestamp put: SpTimestamp now! !


!WebUser methodsFor: 'security' stamp: 'janko 4/25/2012 12:38'!
escalateToAdmin
	"escalate access rights of that use to admin rights, if user is in Administrators group"
	"WebSecurityManager default adminGroup users do: [:each | each escalateToAdmin] "
	self inAdminGroup ifFalse: [self error: 'User to escalate must be in Admin group'].
	self otherAt: #EscalatedToAdmin put: true.! !

!WebUser methodsFor: 'security'!
hasAdminRights
	"Admin is every member of Administrators group which rights are escalated to admin rights. 
	Default Admin user is always regarded as 'escalated to admin' and is therefore admin by default "
	self isAdminUser ifTrue: [^true].
	^self inAdminGroup 
		and: [self isEscalatedToAdmin]! !

!WebUser methodsFor: 'security' stamp: 'janko 4/25/2012 13:09'!
isEscalatedToAdmin
	"escalate access rights of that use to admin rights, if user is in Admin group"
	^self otherAt: #EscalatedToAdmin ifAbsent: [false]! !

!WebUser methodsFor: 'security' stamp: 'janko 4/25/2012 13:10'!
unEscalateFromAdmin
	"cancel escalation of that user from admin rights"
	self isEscalatedToAdmin ifTrue:
		[self otherAt: #EscalatedToAdmin put: false].! !


!WebUser methodsFor: 'testing'!
hasEMail 
	^self email ~= ''! !

!WebUser methodsFor: 'testing'!
hasValidEMail 
	^self hasEMail and: [self email isValidEMailAddress]! !

!WebUser methodsFor: 'testing'!
inActivatingGroup
	"user needs to confirm registration"
	^self groups contains: [:each | each isActivatingGroup]! !

!WebUser methodsFor: 'testing'!
inAdminGroup
	"all from Administrators group are admins, also default Admin user"
	^self groups contains: [:each | each isAdminGroup]! !

!WebUser methodsFor: 'testing'!
inRegisteredGroup
	^self groups contains: [:each | each isRegisteredGroup]! !

!WebUser methodsFor: 'testing'!
isAdminUser
	"special user with name Admin"
	^self username = 'admin' and: [self name= 'Admin'].! !

!WebUser methodsFor: 'testing'!
isExtranetUser
	"a general user for extranets"
	^self name = 'Extranet' or: [(self username = 'extranet') & (self password = 'password')]! !

!WebUser methodsFor: 'testing' stamp: 'mivsek 3/7/2008 22:57'!
isGuest
	"all non registered visitors have the same user: a Guest"
	^self name = 'Guest' and: 
		[(self username = 'guest') 
			"& (self password = (WebSecurityManager hashPassword: 'guest'))"]! !

!WebUser methodsFor: 'testing' stamp: 'janko 8/6/2011 19:42'!
isLocked
	"change or delete of this user data not allowed"
	^self otherAt: #Locked ifAbsent: [false]! !

!WebUser methodsFor: 'testing' stamp: 'janko 8/8/2011 11:03'!
isLoggedIn
	^self loginHistory isEmpty not
		and: [(self loginHistory last at: 1) = #login]! !

!WebUser methodsFor: 'testing' stamp: 'np 1/18/2008 11:23'!
isPerson
	^false! !

!WebUser methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebUser
	^true! !

!WebUser methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebUserGroup
	^false! !


!WebUser methodsFor: 'initialize-release'!
initId
	self id: (AIDASite random next * 1000000000) rounded printString.! !

!WebUser methodsFor: 'initialize-release' stamp: 'janko 8/6/2011 19:44'!
initLoginHistory
	^self otherAt: #LoginHistory put: DailyCollection new! !

!WebUser methodsFor: 'initialize-release' stamp: 'janko 8/6/2011 19:49'!
initOtherValues
	other := Dictionary new.! !

!WebUser methodsFor: 'initialize-release' stamp: 'janko 8/6/2011 19:44'!
initPerson
	^self otherAt: #Person put: (Person new webUser: self)! !

!WebUser methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	self initId! !


!WebUser methodsFor: 'private-obsolete'!
isAdmin
	"if from Administrators group and escalated to Admin. Default Admin user has always Admin rights"
	"DEPRECIATED!!, use #hasAdminRights, #inAdminGroup or #isAdminUser instead!! "
	^self hasAdminRights! !


!WebUser methodsFor: 'accessing-timestamps'!
lastLoginTimestamp
	self loginHistory isEmpty ifTrue: [^nil].
	^(self loginHistory all detect: [:array | (array at: 1) = #login] ifNone: [^nil])
		at: 2.                 	"what if he is logged in in more than one session?"! !

!WebUser methodsFor: 'accessing-timestamps'!
lastLogoutTimestamp
	self loginHistory isEmpty ifTrue: [^nil].
	^(self loginHistory all detect: [:array | (array at: 1) = #logout] ifNone: [^nil])
		at: 2.                 	"what if he is logged in in more than one session?"! !

!WebUser methodsFor: 'accessing-timestamps' stamp: 'janko 8/6/2011 19:42'!
registeredTimestamp
	"when this user was registered (personally or by someone else)"
	^self otherAt: #RegisteredTimestamp ifAbsent: [nil]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebUser class
	instanceVariableNames: ''!

!WebUser class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
adminEMail
	^'admin'! !

!WebUser class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
adminName
	^'Admin'! !

!WebUser class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
adminPassword
	^'password'! !

!WebUser class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
adminSurname
	^''! !

!WebUser class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
adminUsername
	^'admin'! !

!WebUser class methodsFor: 'defaults' stamp: 'mivsek 1/10/2008 19:04'!
extranetEMail
	^'extranet'! !

!WebUser class methodsFor: 'defaults' stamp: 'mivsek 1/10/2008 19:04'!
extranetName
	^'Extranet'! !

!WebUser class methodsFor: 'defaults' stamp: 'mivsek 1/10/2008 19:04'!
extranetPassword
	^'password'! !

!WebUser class methodsFor: 'defaults' stamp: 'mivsek 1/10/2008 19:04'!
extranetSurname
	^''! !

!WebUser class methodsFor: 'defaults' stamp: 'mivsek 1/10/2008 19:05'!
extranetUsername
	^'extranet'! !

!WebUser class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
guestEMail
	^'guest'! !

!WebUser class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
guestName
	^'Guest'! !

!WebUser class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
guestPassword
	^'guest'! !

!WebUser class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
guestSurname
	^''! !

!WebUser class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
guestUsername
	^'guest'! !


!WebUser class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !

!WebUser class methodsFor: 'instance creation' stamp: 'janko 3/16/2008 13:30'!
newAdmin
	^self new
		name: self adminName;
		surname: self adminSurname;
		email: self adminEMail;
		username: self adminUsername;
		password: self adminPassword! !

!WebUser class methodsFor: 'instance creation' stamp: 'janko 3/16/2008 13:30'!
newExtranet
	"a common extranet user, for easier setup of access rights"
	^self new
		name: self extranetName;
		surname: self extranetSurname;
		email: self extranetEMail;
		username: self extranetUsername;
		password: self extranetPassword! !

!WebUser class methodsFor: 'instance creation' stamp: 'np 3/17/2008 21:43'!
newGuest
	^self new
		name: self guestName;
		surname: self guestSurname;
		email: self guestEMail;
		username: self guestUsername;
		password: self guestPassword! !


Object subclass: #WebUserGroup
	instanceVariableNames: 'name users other'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Core'!
!WebUserGroup commentStamp: '<historical>' prior: 0!
WebUserGroup is a part of user and group management. Groups are then used for security management like access control. There are predefined groups All Users, Administrators, Registered Users, Users waiting activation. To manage groups and their membership see WebSecurityManagerApp!


!WebUserGroup methodsFor: 'adding-removing'!
addUser: aWebUser
 	self users add: aWebUser.! !

!WebUserGroup methodsFor: 'adding-removing'!
removeUser: aWebUser
 	self users remove: aWebUser ifAbsent: [].! !


!WebUserGroup methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allUsers
	^self users copy! !

!WebUserGroup methodsFor: 'accessing'!
allUsersSorted
	"..by name and surname"
	^self allUsers asSortedCollection: [:a :b | a nameSurname < b nameSurname]! !

!WebUserGroup methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
menuName
	"in dropdown menus"
	^name! !

!WebUserGroup methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
name
	name isNil ifTrue: [self name: '']. 
	^name! !

!WebUserGroup methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
name: aString
	name := aString.! !

!WebUserGroup methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
uuid
	"some unique identifier. Hash for now, probably unique enough!! "
	^self hash printString! !


!WebUserGroup methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
includes: aWebUser
	^self users includes: aWebUser! !

!WebUserGroup methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isActivatingGroup
	"group of users waiting to confirm registration"
	^self name = self class activatingGroupName! !

!WebUserGroup methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isAdminGroup
	^self name = self class adminGroupName! !

!WebUserGroup methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isAllUsersGroup
	^self name = self class allUsersGroupName! !

!WebUserGroup methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isGuestGroup
	^self name = self class guestGroupName! !

!WebUserGroup methodsFor: 'testing'!
isLocked
	"change or delete this group not allowed"
	^self otherAt: #Locked ifAbsent: [false]! !

!WebUserGroup methodsFor: 'testing' stamp: 'np 1/18/2008 11:23'!
isPerson
	^false! !

!WebUserGroup methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isRegisteredGroup
	^self name = self class registeredGroupName! !

!WebUserGroup methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebUser
	^false! !

!WebUserGroup methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebUserGroup
	^true! !


!WebUserGroup methodsFor: 'initialize-release'!
initOther
	other := Dictionary new.! !


!WebUserGroup methodsFor: 'private' stamp: ' 21/4/07 22:07'!
initUsers 
	users  := Set new.! !

!WebUserGroup methodsFor: 'private' stamp: ' 21/4/07 22:07'!
migrateToUnicode
	"from iso8859-2"
	"WebUserGroup allInstances do: [:each | each migrateToUnicode]"
	name notNil ifTrue: [name := name ensureUnicodeSloveneChars].! !

!WebUserGroup methodsFor: 'private'!
preferredUrl
	| nme |
	nme := self name trimBlanks asHttpFriendly.
	^'/group/', nme! !

!WebUserGroup methodsFor: 'private'!
printString
	^'aWebUserGroup: ', self name! !

!WebUserGroup methodsFor: 'private' stamp: ' 21/4/07 22:07'!
users
	users isNil ifTrue: [self initUsers]. 
	^users! !


!WebUserGroup methodsFor: 'private-other'!
other
	^other! !

!WebUserGroup methodsFor: 'private-other'!
otherAt: aSymbol
	^self otherAt: aSymbol ifAbsent: [nil]! !

!WebUserGroup methodsFor: 'private-other'!
otherAt: aSymbol ifAbsent: aBlock
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!WebUserGroup methodsFor: 'private-other'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!WebUserGroup methodsFor: 'private-other'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !


!WebUserGroup methodsFor: 'accessing-other'!
resetLocked
	"change or delete this group allowed again"
	^self otherAt: #Locked put: false! !

!WebUserGroup methodsFor: 'accessing-other'!
setLocked
	"change or delete this group not allowed"
	^self otherAt: #Locked put: true! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebUserGroup class
	instanceVariableNames: ''!

!WebUserGroup class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
activatingGroupName
	"group of users waiting to confirm registration"
	^'Users waiting activation'! !

!WebUserGroup class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
adminGroupName
	"return a name of group for administrators" 
	^'Administrators'! !

!WebUserGroup class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
allUsersGroupName
	"return a name of group, where all users are there by default" 
	^'AllUsers'! !

!WebUserGroup class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
guestGroupName
	"return a name of group for guests" 
	^self allUsersGroupName! !

!WebUserGroup class methodsFor: 'defaults' stamp: ' 21/4/07 22:07'!
registeredGroupName
	"return a name of group of registered users" 
	^'Registered Users'! !


!WebUserGroup class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newActivating
	^super new name: self activatingGroupName! !

!WebUserGroup class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newAdmin
	^super new name: self adminGroupName! !

!WebUserGroup class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newAllUsers
	^super new name: self allUsersGroupName! !

!WebUserGroup class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newRegistered
	^super new name: self registeredGroupName! !

AIDASite initialize!