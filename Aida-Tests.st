TestCase subclass: #AIDAModelAdaptorTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!AIDAModelAdaptorTest methodsFor: 'testing'!
testSanitizer
	| adaptor |
	adaptor := AidaModelAdaptor new.
	adaptor buffer: '< script id="id15">'.
	self assert: (adaptor sanitize; buffer) = '<  id="id15">'.
	adaptor buffer: '<img src=""/a.jpg<script type=text/javascript src="http://1.2.3.4/xss.js">" /></script>'.
	self assert: (adaptor sanitize; buffer) = '<img src=""/a.jpg< type=text/java src="http://1.2.3.4/xss.js">" /></>'.
	adaptor buffer: 'script for javascript<script>'.
	self assert: (adaptor sanitize; buffer) = 'script for javascript<>'.
	adaptor buffer: 'a < b. /* in script */ '.
	self assert: (adaptor sanitize; buffer) = 'a < b. /* in  */ '. " this is not ok!! "! !


TestCase subclass: #AIDASiteTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!AIDASiteTest methodsFor: 'testing'!
testEncodeCharEntitites
	self assert: ((AIDASite encodeCharEntitiesIn: '<tag>') = '&lt;tag&gt;').
	self assert: ((AIDASite decodeCharEntitiesIn: '&lt;tag&gt;') = '<tag>').
	self assert: ((AIDASite encodeCharEntitiesIn: '<>&"') = '&lt;&gt;&amp;&quot;').
	self assert: ((AIDASite decodeCharEntitiesIn: '&lt;&gt;&amp;&quot;') = '<>&"').! !


Object subclass: #AidaProfiling
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!AidaProfiling methodsFor: 'profiling-gs'!
areadmeGemstone
	"a short description of how to profile, interpret results, why to profile etc."! !

!AidaProfiling methodsFor: 'profiling-gs'!
areadmeResultsGS
	"results, history of, short explanations"

"Gemstone64 2.2.5 Profiling of Aida/Web 5.6, 11.2.08, Janko Mivsek
[1000 timesRepeat: [site answerTo: req]]

elapsed CPU time:    23662 ms,  monitoring interval: 10 ms
24ms/req, 40 req/s"! !

!AidaProfiling methodsFor: 'profiling-gs'!
profileAnswerToGS
	"AIDASite>>answerTo: profile"
	"AidaProfiling new profileAnswerToVW"

	| site  req |
	site := AIDASite new initialize.
	req := self sampleRequest.
	site answerTo: req. site answerTo: req.
	Smalltalk.ProfMonitor monitorBlock: 
		[1000 timesRepeat: [site answerTo: req]]! !


!AidaProfiling methodsFor: 'profiling-vw'!
areadmeResultsVW
	"results, history of, short explanations"

"VW 7.6 Profiling of Aida/Web 5.6, 11.2.08, Janko Mivsek
[1000 timesRepeat: [site answerTo: req]]

707 samples, 20.03 average ms/sample, 1780 scavenges, 28 incGCs,
11.75s active, 2.35s other processes,
14.16s real time, 0.06s profiling overhead
12ms/req, 83 req/s"! !

!AidaProfiling methodsFor: 'profiling-vw'!
areadmeVW
	"a short description of how to profile, interpret results, why to profile etc."! !

!AidaProfiling methodsFor: 'profiling-vw'!
profileAnswerToVW
	"AIDASite>>answerTo: profile"
	"AidaProfiling new profileAnswerToVW"
	| site req resp |
	site := AIDASite new initialize. site admin. "to init its URL"
	req := self sampleRequest.  "/admin?view=login  with cookie set"
	resp := site answerTo: req. 
	TimeProfiler new 
		samplingInterval: 10; 
		profile: [1000 timesRepeat: [site answerTo: req]].
	^resp "to check if it is actually as expected"! !

!AidaProfiling methodsFor: 'profiling-vw'!
profilePingToVW
	"AIDASite>>answerTo: profile"
	"AidaProfiling new profilePingToVW"
	| site req resp |
	site := AIDASite new initialize.
	req := self pingRequest.  "/ping.html"
	resp := site answerTo: req. 
	TimeProfiler new 
		samplingInterval: 10; 
		profile: [10000000 timesRepeat: [site answerTo: req]].
	^resp "to check if it is actually as expected"! !

!AidaProfiling methodsFor: 'profiling-vw'!
profileStatic100KBVW
	"static 100KB file serving"
	"AidaProfiling new profileStatic100KBVW"
	| site req resp |
	self ensure100KBFile.
	site := AIDASite new initialize.
	req := self static100KBRequest.  "/test100K.jpg?id=123456"
	resp := site answerTo: req. req task response: nil. "streaming!!"
	TimeProfiler new 
		samplingInterval: 10; 
		profile: [1 timesRepeat: [site answerTo: req.  req task response: nil] ].
	^resp "to check if it is actually as expected"! !


!AidaProfiling methodsFor: 'profiling-squeak'!
areadmeSqueak
	"a short description of how to profile, interpret results, why to profile etc."! !


!AidaProfiling methodsFor: 'support'!
ensure100KBFile
	"dummy .jpg file"
	| fname stream |
	fname := SpFilename named: 'test100K.jpg'.
	fname exists ifFalse:
		[[stream := fname writeStream binary.
		100000 timesRepeat: [stream nextPut: 16rCE] "just something"]
			ensure: [stream close] ].! !

!AidaProfiling methodsFor: 'support'!
pingRequest
	| requestStream req |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET /ping.html HTTP/1.1';
		crlf.
	req := HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents).
	req task: SwazooTask new.  req task request: req.
	req task connection: (HTTPConnection new stream: (SwazooStream on: String new)).
	^req! !

!AidaProfiling methodsFor: 'support'!
sampleRequest
	| requestStream req |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET /admin?view=login HTTP/1.1';
		nextPutLine: 'Cookie: aida9357=123456';
		crlf.
	req := HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents).
	req task: SwazooTask new.  req task request: req.
	req task connection: (HTTPConnection new stream: (SwazooStream on: String new)).
	^req! !

!AidaProfiling methodsFor: 'support'!
static100KBRequest
	| requestStream req |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET /test100K.jpg HTTP/1.1';
		crlf;
		nextPutLine: 'Cookie: aida9357=123456';
		crlf.
	req := HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents).
	req task: SwazooTask new.  req task request: req.
	req task connection: (HTTPConnection new stream: (SwazooStream on: String new)).
	^req! !


TestCase subclass: #PartiesTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testAddress! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testCompany! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testCompanyEmployees! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testEvents! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testOrgUnitJobRoles! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testOrganizationUnit! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testPerson! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testPersonDocumentsToKnow! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testPersonRecordFlows! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testPersonResponsibilities! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testPersonRoles! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testRoleGroups! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testRoles! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testRolesBasic! !

!PartiesTest methodsFor: 'testing' stamp: ' 10/1/08 23:12'!
testRolesSpecific! !


TestCase subclass: #SchedulerTest
	instanceVariableNames: 'scheduler'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!SchedulerTest methodsFor: 'running' stamp: 'jm 4/26/2009 15:40'!
setUp
	scheduler := WebScheduler newOn: nil.
	scheduler start.! !

!SchedulerTest methodsFor: 'running' stamp: ' 21/4/07 22:08'!
tearDown
	scheduler stop.! !


!SchedulerTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 20:54'!
testAddingSingleEvent
"	scheduler at: SpTimestamp now callMethod: #transcript of: self. "! !

!SchedulerTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 20:54'!
testAddingSingleEvent2
	"look at Transcript!! "
	| time |
	time := SpTimestamp fromSeconds: (SpTimestamp now asSeconds + 1).
	scheduler at: time runBlock: [self transcript].
	(Delay forSeconds: 2) wait.! !

!SchedulerTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testMinutePeriodicEvent
	"it should write twice to transcript in 2 minutes!! "
	scheduler everyMinuteAt: 30 runBlock: [self transcript].
"	(Delay forSeconds: 120) wait "! !

!SchedulerTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 20:58'!
testMoreMinutePeriodicEvents
	"it should write to transcript in 2 minutes!! "
"	scheduler everyMinuteAt: 30 runBlock: [self transcript1].
	scheduler everyMinuteAt: 15 runBlock: [self transcript2].
	scheduler everyMinuteAt: 45 runBlock: [self transcript3].
	scheduler everyMinuteAt: 20 runBlock: [self transcript4].
""	(Delay forSeconds: 120) wait"! !

!SchedulerTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testSetup! !


!SchedulerTest methodsFor: 'testing-queue order' stamp: 'mivsek 8/22/2007 20:57'!
testOrderOf2AscEvents
	scheduler stop. "just testing order in queue!!"
"	scheduler everyMinuteAt: 15 runBlock: [self transcript1].
	scheduler everyMinuteAt: 30 runBlock: [self transcript2].
	self assert: (scheduler queue at: 1) period value = 15.
	self assert: (scheduler queue at: 2) period value = 30.
"! !

!SchedulerTest methodsFor: 'testing-queue order' stamp: 'mivsek 8/22/2007 20:57'!
testOrderOf2DescEvents
	scheduler stop. "just testing order in queue!!"
"	scheduler everyMinuteAt: 30 runBlock: [self transcript1].
	scheduler everyMinuteAt: 15 runBlock: [self transcript2].
	self assert: (scheduler queue at: 1) period value = 15.
	self assert: (scheduler queue at: 2) period value = 30.
"! !

!SchedulerTest methodsFor: 'testing-queue order' stamp: 'mivsek 8/22/2007 20:57'!
testOrderOf3AscEvents
	scheduler stop. "just testing order in queue!!"
"	scheduler everyMinuteAt: 15 runBlock: [self transcript1].
	scheduler everyMinuteAt: 30 runBlock: [self transcript2].
	scheduler everyMinuteAt: 45 runBlock: [self transcript3].
	self assert: (scheduler queue at: 1) period value = 15.
	self assert: (scheduler queue at: 2) period value = 30.
	self assert: (scheduler queue at: 3) period value = 45.
"! !

!SchedulerTest methodsFor: 'testing-queue order' stamp: 'mivsek 8/22/2007 20:58'!
testOrderOf3DescEvents
	scheduler stop. "just testing order in queue!!"
"	scheduler everyMinuteAt: 45 runBlock: [self transcript1].
	scheduler everyMinuteAt: 30 runBlock: [self transcript2].
	scheduler everyMinuteAt: 15 runBlock: [self transcript3].
	self assert: (scheduler queue at: 1) period value = 15.
	self assert: (scheduler queue at: 2) period value = 30.
	self assert: (scheduler queue at: 3) period value = 45.
"! !

!SchedulerTest methodsFor: 'testing-queue order' stamp: 'mivsek 8/22/2007 20:58'!
testOrderOf3MixedEvents
	scheduler stop. "just testing order in queue!!"
"	scheduler everyMinuteAt: 15 runBlock: [self transcript1].
	scheduler everyMinuteAt: 45 runBlock: [self transcript2].
	scheduler everyMinuteAt: 30 runBlock: [self transcript3].
	self assert: (scheduler queue at: 1) period value = 15.
	self assert: (scheduler queue at: 2) period value = 30.
	self assert: (scheduler queue at: 3) period value = 45.
"! !


!SchedulerTest methodsFor: 'private' stamp: ' 21/4/07 22:08'!
transcript
	Transcript cr; show: 'scheduled event'! !

!SchedulerTest methodsFor: 'private' stamp: ' 21/4/07 22:08'!
transcript1
	Transcript cr; show: 'scheduled event 1'! !

!SchedulerTest methodsFor: 'private' stamp: ' 21/4/07 22:08'!
transcript2
	Transcript cr; show: 'scheduled event 2'! !

!SchedulerTest methodsFor: 'private' stamp: ' 21/4/07 22:08'!
transcript3
	Transcript cr; show: 'scheduled event 3'! !

!SchedulerTest methodsFor: 'private' stamp: ' 21/4/07 22:08'!
transcript4
	Transcript cr; show: 'scheduled event 4'! !

!SchedulerTest methodsFor: 'private' stamp: ' 21/4/07 22:08'!
transcript5
	Transcript cr; show: 'scheduled event 5'! !


TestCase subclass: #SwazooIntegrationTest
	instanceVariableNames: 'server site'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!
!SwazooIntegrationTest commentStamp: '<historical>' prior: 0!
All tests are commented out because they are DANGEROUS to live Swazoo systems!!

Instance Variables:
	server	<SwazooServer>	description of server
	site	<Object | Proxy>	description of site

!


!SwazooIntegrationTest methodsFor: 'private' stamp: ' 21/4/07 22:08'!
localSendUrl: aString
	"sends request with that RELATIVE url to the site localy - it simulates a real network request. "
	| request httpServer |
	request := Swazoo.HTTPRequest request: aString from: self siteHost at: self siteIP.
	request uri port: self sitePort.
	httpServer := server servers asOrderedCollection first.
	^httpServer answerTo: request! !

!SwazooIntegrationTest methodsFor: 'private' stamp: ' 21/4/07 22:08'!
sendUrl: aString
	"sends a real network request with that RELATIVE url to the site with parameters from defaults. 
	Returns a Net.HttpResponse"
	| client request |
	client := Net.HttpClient new.
	request := Net.HttpRequest get: 'http://', self siteHost, ':', self sitePort printString, aString.
	^client executeRequest: request.! !


!SwazooIntegrationTest methodsFor: 'running' stamp: ' 21/4/07 22:08'!
setUp
	server := Swazoo.SwazooServer singleton.
	"server initialize." "DANGEROUS!! "  "to remove all stuff and stop it"
	"site := AIDASite newNamed: self siteName.
	site 
		host: self siteHost;
		ip: self siteIP;
		port: self sitePort;
		sslPort: self siteSSLPort. "! !

!SwazooIntegrationTest methodsFor: 'running' stamp: ' 21/4/07 22:08'!
tearDown
	"site := server siteNamed: self siteName.
	site stop.
	server removeSite: site.
	server := nil.
	site := nil."! !


!SwazooIntegrationTest methodsFor: 'defaults' stamp: ' 21/4/07 22:08'!
siteHost
	^'localhost'! !

!SwazooIntegrationTest methodsFor: 'defaults' stamp: ' 21/4/07 22:08'!
siteIP
	^'localhost'! !

!SwazooIntegrationTest methodsFor: 'defaults' stamp: ' 21/4/07 22:08'!
siteName
	^'test'! !

!SwazooIntegrationTest methodsFor: 'defaults' stamp: ' 21/4/07 22:08'!
sitePort
	^8765! !

!SwazooIntegrationTest methodsFor: 'defaults' stamp: ' 21/4/07 22:08'!
siteRootUri
	^'/'! !

!SwazooIntegrationTest methodsFor: 'defaults' stamp: ' 21/4/07 22:08'!
siteSSLPort
	^8766! !


!SwazooIntegrationTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testAccessingByName
"
	self assert: (Swazoo.SwazooServer siteNamed: self siteName) notNil.
	self assert: (Swazoo.SwazooServer siteHostnamed: self siteHost) notNil
"! !

!SwazooIntegrationTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testAdminPage
"
	| |
	server startSite: self siteName.
	self shouldnt: [self sendUrl: '/admin.html'] raise: Error.
	self shouldnt: [self sendUrl: '/admin.html?view=login'] raise: Error.
	server stopSite: self siteName.
"! !

!SwazooIntegrationTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testDummyRequest
"
	server startSite: self siteName.
	self should: [self sendUrl: '/dummycompletelydummy.html'] raise: Net.HttpObjectNotFound.
	server stopSite: self siteName.
"! !

!SwazooIntegrationTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testLocalAdminPage
"
	| response |
	server startSite: self siteName.
	response := self localSendUrl: '/admin.html'.
	self assert: response isRedirectLink.
	response := self localSendUrl: '/admin.html?view=login'.
	self assert: response isOk.
	server stopSite: self siteName.
"! !

!SwazooIntegrationTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testLocalDummyRequest
"
	| response |
	server startSite: self siteName.
	response := self localSendUrl: '/dummycompletelydummy.html'.
	self assert: response isNotFound.
	server stopSite: self siteName.
"! !

!SwazooIntegrationTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testSetUp
"
	self assert: (server sites size = 1).
	self assert: (site ip = self siteIP).
	self assert: (site host = self siteHost).
	self assert: (site port = self sitePort).
	self assert: site isServing not.
"! !

!SwazooIntegrationTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 21:00'!
testStarting
"	server startSite: self siteName.
	self assert: (server siteNamed: self siteName) isServing.
	self assert: (server servers asOrderedCollection first isServing).
	server stopSite: self siteName.
	self deny: (server siteNamed: self siteName) isServing.
"! !


TestCase subclass: #URLResolverTest
	instanceVariableNames: 'server site'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!URLResolverTest methodsFor: 'running' stamp: 'mivsek 8/22/2007 21:08'!
setUp
"DANGEROUS!!
	server := Swazoo.SwazooServer singleton.
	server initialize.  ""to remove all stuff and stop it""
	site := AIDASite newNamed: 'test'.
"! !

!URLResolverTest methodsFor: 'running' stamp: 'mivsek 8/22/2007 21:09'!
tearDown
"	site := server siteNamed: 'test'.
	site stop.
	server removeSite: site.
	server := nil. site := nil.
"! !


!URLResolverTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testSetUp! !


TestCase subclass: #VersionSpecTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!VersionSpecTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testFirstCreation
	| spec |
	spec := VersionSpec firstFor: ''.
	self assert: spec number = '1'.
	self assert:  spec isCurrent.
	self assert:  spec isOldest.
	self assert:  spec isNewest.! !

!VersionSpecTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testSearchByNumber
	| o spec |
	o := VersionedObject new.
	spec := VersionSpec newFromParent: o for: VersionedObject new.
	self assert: ((spec versionSpecWithNumber: '2') number = '2').
	self assert: ((spec versionSpecWithNumber: '1') number = '1').
	self assert: (spec versionSpecWithNumber: '3') isNil.! !

!VersionSpecTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testSecondCreation
	| o spec |
	o := VersionedObject new.
	spec := VersionSpec newFromParent: o for: VersionedObject new.
	self assert: spec number = '2'.
	self deny:  spec isCurrent.
	self deny:  spec isOldest.
	self assert:  spec isNewest.
	self assert: spec parent == o.
	spec setCurrent.
	self assert:  spec isCurrent.
	self deny: spec parent version isCurrent.! !

!VersionSpecTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testSetCurrent
	| o spec |
	o := VersionedObject new.
	spec := VersionSpec newFromParent: o for: VersionedObject new.
	self assert:  o isCurrentVersion.
	self deny:  spec isCurrent.
	spec setCurrent.
	self assert:  spec isCurrent.
	self deny: o isCurrentVersion.! !


VersionedObject subclass: #VersionedExample
	instanceVariableNames: 'title body'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!VersionedExample methodsFor: 'accessing' stamp: ' 21/4/07 22:08'!
body
	^body! !

!VersionedExample methodsFor: 'accessing' stamp: ' 21/4/07 22:08'!
body: anObject
	body := anObject! !

!VersionedExample methodsFor: 'accessing' stamp: ' 21/4/07 22:08'!
title
	^title! !

!VersionedExample methodsFor: 'accessing' stamp: ' 21/4/07 22:08'!
title: anObject
	title := anObject! !


!VersionedExample methodsFor: 'copying' stamp: ' 21/4/07 22:08'!
copyContentsTo: anObject
	anObject title: self title copy.
	anObject body: self body copy.! !


!VersionedExample methodsFor: 'printing' stamp: ' 21/4/07 22:08'!
printString
	^'aVersionedExample ', 
		(self title notNil ifTrue: [self title] ifFalse: ['']), ' ', 
		(self body notNil ifTrue: [self body] ifFalse: [''])! !


WebApplication subclass: #VersionedExampleApp
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!


TestCase subclass: #VersionedObjectTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!VersionedObjectTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testFirstCreation
	| o |
	o := VersionedObject new.
	self assert: o versionNumber = '1'.
	self assert:  o isCurrentVersion.
	self assert:  o isOldestVersion.
	self assert:  o isNewestVersion.
	self assert:  o parentVersion isNil.
	self assert:  o nextVersion isNil.! !

!VersionedObjectTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testNewVersion
	| o o2 |
	o := VersionedObject new.
	o2 := o asNewVersion.
	self assert: o2 versionNumber = '2'.
	self deny:  o2 isCurrentVersion.
	self deny:  o2 isOldestVersion.
	self assert:  o2 isNewestVersion.
	self assert: o2 parentVersion == o.! !

!VersionedObjectTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testNewVersionOfExample
	| o o2 |
	o := VersionedExample new. o title: 'test'; body: 'this is test'.
	o2 := o asNewVersion.
	self assert: o2 title = o title.
	self assert: o2 body = o body.! !

!VersionedObjectTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testSearchByNumber
	| o1 o2 o3 |
	o1 := VersionedExample new. o1 title: 'first'. o2 := o1 asNewVersion. o2 title: 'second'. 
	o3 := o2 asNewVersion. o3 title: 'third'. 
	self assert: ((o2 versionWithNumber: '1') versionNumber = '1').
	self assert: ((o2 versionWithNumber: '2') versionNumber = '2').
	self assert: ((o2 versionWithNumber: '3') versionNumber = '3').
	self assert: ((o2 versionWithNumber: '4') isNil).! !

!VersionedObjectTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testVersionIncrement
	| o o2 |
	o := VersionedObject new. o versionNumber: '1234'.
	o2 := o asNewVersion.
	self assert: o2 versionNumber = '1235'.! !


!VersionedObjectTest methodsFor: 'testing-identity swap' stamp: ' 21/4/07 22:08'!
testIdentityPreservation
	| o1 o2 c |
	o1 := VersionedExample new. o1 title: 'test'.
	o2 := o1 asNewVersion.  o2 title: 'sectest'.
	c := o1 currentVersion.
	self assert: c == o1.
	o2 setCurrentVersion.
	self assert: c == o1 currentVersion. "identity must be preserved!! "! !

!VersionedObjectTest methodsFor: 'testing-identity swap' stamp: ' 21/4/07 22:08'!
testSetCurrent
	| o1 o2 |
	o1 := VersionedObject new. o2 := o1 asNewVersion.
	self assert:  o1 isCurrentVersion.
	self deny:  o2 isCurrentVersion.
	o2 setCurrentVersion.
	self assert:  o1 isCurrentVersion. "o1 and o2 identities are swapped!! "
	self deny:  o2 isCurrentVersion.! !

!VersionedObjectTest methodsFor: 'testing-identity swap' stamp: ' 21/4/07 22:08'!
testSwap3Objects
	| o1 o2 o3 |
	o1 := VersionedExample new. o1 title: 'first'. o2 := o1 asNewVersion. o2 title: 'second'. 
	o3 := o2 asNewVersion. o3 title: 'third'. o3 version setCurrent. "to debug more easily"
	self assert: o1 version next == o2. 
	self assert: o2 version parent == o1. self assert: o2 version next == o3.
	self assert: o3 version parent == o2.
	o1 setCurrentVersion.
	self assert: o3 version next == o2. "test chain integrity"
	self assert: o2 version parent == o3. self assert: o2 version next == o1.
	self assert: o1 version parent == o2.
	self assert: o1 title = 'third'. self assert: o2 title = 'second'. self assert: o3 title = 'first'.! !

!VersionedObjectTest methodsFor: 'testing-identity swap' stamp: ' 21/4/07 22:08'!
testSwap3Objects2
	| o1 o2 o3 |
	o1 := VersionedExample new. o1 title: 'first'. o2 := o1 asNewVersion. o2 title: 'second'. 
	o3 := o2 asNewVersion. o3 title: 'third'. 
	self assert: o1 version next == o2. 
	self assert: o2 version parent == o1. self assert: o2 version next == o3.
	self assert: o3 version parent == o2.
	o3 setCurrentVersion.
	self assert: o3 version next == o2. "test chain integrity"
	self assert: o2 version parent == o3. self assert: o2 version next == o1.
	self assert: o1 version parent == o2.
	self assert: o1 title = 'third'. self assert: o2 title = 'second'. self assert: o3 title = 'first'.! !

!VersionedObjectTest methodsFor: 'testing-identity swap' stamp: ' 21/4/07 22:08'!
testSwapIdentity
	| o1 o2 |
	o1 := VersionedExample new. o1 title: 'first'.
	o2 := o1 asNewVersion. o2 title: 'second'.
	self assert: o1 isCurrentVersion.
	self assert: o1 title = 'first'. self assert: o2 title = 'second'.
	o2 setCurrentVersion.
	self assert: o1 isCurrentVersion. "because of identity swap!! "
	self assert: o1 title = 'second'. self assert: o2 title = 'first'.! !

!VersionedObjectTest methodsFor: 'testing-identity swap' stamp: ' 21/4/07 22:08'!
testSwapIdentity2
	| o1 o2 s1 s2 |
	o1 := VersionedExample new. o1 title: 'first'.
	o2 := o1 asNewVersion. o2 title: 'second'.
	s1 := o1 version. s2 := o2 version.
	self assert: s1 object title = 'first'. self assert: s2 object title = 'second'.
	o2 setCurrentVersion.
	"version chain order must be preserved!!"
	self assert: s1 object title = 'first'. self assert: s2 object title = 'second'.! !

!VersionedObjectTest methodsFor: 'testing-identity swap' stamp: ' 21/4/07 22:08'!
testSwapIdentity3
	| o1 o2 |
	o1 := VersionedExample new. o1 title: 'first'.
	o2 := o1 asNewVersion. o2 title: 'second'. o2 version setCurrent. "to debug more easily"
	o1 setCurrentVersion. 
	self assert: o1 version object == o1. "check references to spec and back"
	self assert: o2 version object == o2.
	self assert: o1 version parent == o2. "test chain integrity"
	self assert: o2 version next == o1.! !

!VersionedObjectTest methodsFor: 'testing-identity swap' stamp: ' 21/4/07 22:08'!
testSwapIdentity4
	| o1 o2 |
	o1 := VersionedExample new. o1 title: 'first'.
	o2 := o1 asNewVersion. o2 title: 'second'. 
	o2 setCurrentVersion.  "to test other part of VersionedObject swapIdentity"
	self assert: o1 version object == o1. "check references to spec and back"
	self assert: o2 version object == o2.
	self assert: o1 version parent == o2. "test chain integrity"
	self assert: o2 version next == o1.! !


!VersionedObjectTest methodsFor: 'testing-url links' stamp: ' 21/4/07 22:08'!
testWebLink
	| o1 o2 link |
	o1 := VersionedExample new. o1 title: 'first'.
	o2 := o1 asNewVersion. o2 title: 'second'.
	link := WebLink linkTo: o1.
	self assert: link ooReference == o1.
	self deny: (link parms includesKey: 'version').
	link := WebLink linkTo: o2.
	self assert: link ooReference == o1.  "o1 is current version!! "
	self assert: (link parms at: 'version') = '2'.! !


TestCase subclass: #WebApplicationTest
	instanceVariableNames: 'server site session app request'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!WebApplicationTest methodsFor: 'running' stamp: ' 21/4/07 22:08'!
setRequest
	request := HTTPGet new.
	request parseURI: 'http://www.eranova.si/demo.html'.
	session lastRequest: request! !

!WebApplicationTest methodsFor: 'running' stamp: 'mivsek 8/22/2007 21:12'!
setUp
"TOO DANGEROUS!!!!!!
	server := Swazoo.SwazooServer singleton.
	server initialize.  ""to remove all stuff and stop it""
	site := AIDASite newNamed: 'test'.
	session := WebSession newOn: site sessionManager.
	app := site admin webAppFor: session.
	self setRequest.
"! !

!WebApplicationTest methodsFor: 'running' stamp: 'mivsek 8/22/2007 21:12'!
tearDown
"	site := server siteNamed: 'test'.
	site stop.
	server removeSite: site.
	server := nil. site := nil. session := nil. app := nil.
"! !


!WebApplicationTest methodsFor: 'testing-versions' stamp: 'mivsek 8/22/2007 21:13'!
testChangeObserveeVersion
"	| o1 |
	o1 := VersionedExample new. o1 asNewVersion.
	app := o1 webAppFor: session.
	self assert: app observee versionNumber = '1'.
	request uri queries: (request uri queries, '&version=2').
	app checkObserveeVersion.
	self assert: app observee versionNumber = '2'.
	self deny: app observee isCurrentVersion
"! !

!WebApplicationTest methodsFor: 'testing-versions' stamp: 'mivsek 8/22/2007 21:13'!
testChangeObserveeVersionBack
"	| o1 |
	o1 := VersionedExample new. o1 asNewVersion.  app := o1 webAppFor: session.
	request uri queries: (request uri queries, '&version=2').
	app checkObserveeVersion.
	self assert: app observee versionNumber = '2'.
	self setRequest. ""to be without version again""
	app checkObserveeVersion.
	self assert: app observee versionNumber = '1'.
	self assert: app observee isCurrentVersion
"! !

!WebApplicationTest methodsFor: 'testing-versions' stamp: 'mivsek 8/22/2007 21:13'!
testCurrentVersionChange
"	| o1 o2 |
	o1 := VersionedExample new. o2 := o1 asNewVersion.
	app := o1 webAppFor: session.
	self assert: app observee isCurrentVersion.
	self assert: app observee versionNumber = '1'.
	o2 setCurrentVersion.
	self assert: app observee isCurrentVersion. ""because of identity change!! ""
	self assert: app observee versionNumber = '2'.
"! !

!WebApplicationTest methodsFor: 'testing-versions' stamp: 'mivsek 8/22/2007 21:14'!
testVersionRequest
"	| o1 |
	o1 := VersionedExample new. 
	app := o1 webAppFor: session.
	self deny: app isVersionRequest.
	self assert: app versionFromRequest isNil.
	request uri queries: (request uri queries, '&version=2').
	self assert: app isVersionRequest.
	self assert: app versionFromRequest = '2'.
"! !

!WebApplicationTest methodsFor: 'testing-versions' stamp: 'mivsek 8/22/2007 21:14'!
testVersionedObject
"	| o1 o2 |
	o1 := VersionedExample new. o2 := o1 asNewVersion.
	app := o1 webAppFor: session.
	self assert: app observee isVersionedObject.
	self assert: app observee isCurrentVersion.
"! !


!WebApplicationTest methodsFor: 'testing' stamp: ' 21/4/07 22:08'!
testSecurity! !

!WebApplicationTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 21:13'!
testSetUp
"	self assert: app notNil.
	self assert: app observee == site admin.
	self assert: app session == session.
	self assert: (session webAppFor: site admin) == app
"! !


TestCase subclass: #WebFileInputTest
	instanceVariableNames: 'file filename'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!WebFileInputTest methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
file
	^file! !

!WebFileInputTest methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
file: anObject
	file := anObject! !

!WebFileInputTest methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
filename
	^filename! !

!WebFileInputTest methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
filename: anObject
	filename := anObject! !


!WebFileInputTest methodsFor: 'testing' stamp: 'janko 7/24/2011 21:13'!
offtestFileUpload
	"this test temporarly off"
	| request session app |
	request := self postFileRequest.
	session := WebSession new. session lastRequest: request. request session: session.
	app := WebApplication new session: session.
	app ensureContextForView: #main for: request.
	app add: 
		((WebFileInputField aspect: #file filenameAspect: #filename forObject: self) name: 'field7').
	app window registerFormElements.
	"simulate receiving a request"
	app acceptInputsAndActionFrom: request.
	self assert: self filename = 'event.ical'.
	self assert: (self file readStream upTo: Character cr) = 'BEGIN:VCALENDAR'.! !

!WebFileInputTest methodsFor: 'testing' stamp: 'janko 7/24/2011 21:13'!
offtestStreamedFileUpload
	"this test temporarly off"
	| request session app stream |
	request := self postFileRequest.
	session := WebSession new. session lastRequest: request. request session: session.
	app := WebApplication new session: session.
	app ensureContextForView: #main for: request.
	stream := WriteStream on: ByteArray new.
	app add: 
		((WebFileInputField toStream: stream filenameAspect: #filename forObject: self) name: 'field7').
	app window registerFormElements.
	"simulate receiving a request"
	app context form registerStreamedFieldsInto: request. "announce where to stream uploaded file"
	app acceptInputsAndActionFrom: request. "this will trigger defered parsing of postdata and stream it to stream"
	self file: stream contents asString.
	self assert: self filename = 'event.ical'.
	self assert: (self file readStream upTo: Character cr) = 'BEGIN:VCALENDAR'.! !


!WebFileInputTest methodsFor: 'setup' stamp: ' 21/8/07 09:38'!
postFileRequest
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'POST  /document/aab.html HTTP/1.1';
		nextPutLine: 'Connection: Keep-Alive';
		nextPutLine: 'User-Agent: Mozilla/4.72 [en] (X11; I; Linux 2.3.51 i686)';
		nextPutLine: 'Host: biart.eranova.si';
		nextPutLine: 'Referer: http://www.bar.com/takeMeThere.html';
		nextPutLine: 'Content-Type: multipart/form-data; boundary= -----------------20752836116568320241700153999';
		nextPutLine: 'Content-Length: 845';
            crlf;
		nextPutLine: '-------------------20752836116568320241700153999';
		nextPutLine: 'Content-Disposition: form-data; name="id5273"';
		crlf; 
		nextPutLine: 'main';
		nextPutLine: '-------------------20752836116568320241700153999';
		nextPutLine: 'Content-Disposition: form-data; name="field2"';
		crlf; crlf;
		nextPutLine: '-------------------20752836116568320241700153999';
		nextPutLine: 'Content-Disposition: form-data; name="field7"; filename="event.ical"';
		nextPutLine: 'Content-Type: application/octet-stream';
		crlf; 
		nextPutLine: 'BEGIN:VCALENDAR';
		nextPutLine: 'PRODID:-//Squeak-iCalendar//-';
		nextPutLine: 'VERSION:2.0';
		nextPutLine: 'X-WR-CALNAME:test';
		nextPutLine: 'METHOD:PUBLISH';
		nextPutLine: 'BEGIN:VEVENT';
		nextPutLine: 'UID:an event with a start date and not date and time';
		nextPutLine: 'CATEGORIES:category1,category2';
		nextPutLine: 'CREATED:20050501T110231Z';
		nextPutLine: 'SEQUENCE:0';
		nextPutLine: 'SUMMARY:aTitle';
		nextPutLine: 'PRIORITY:5';
		nextPutLine: 'DTSTART;VALUE=DATE:20050425';
		nextPutLine: 'END:VEVENT';
		nextPutLine: 'END:VCALENDAR';
		crlf;
		nextPutLine: '-------------------20752836116568320241700153999';
		nextPutLine: 'Content-Disposition: form-data; name="attach"';
		crlf;
		nextPutLine: 'Attach';
		nextPutLine: '-------------------20752836116568320241700153999--'.

	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !


TestCase subclass: #WebJSONTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!WebJSONTest methodsFor: 'support'!
json: aString parseTo: aValue
	"parse string and check if equal to value"
	| parsedValue |
	parsedValue := WebJSON parse: aString.
	self assert: parsedValue = aValue.! !

!WebJSONTest methodsFor: 'support'!
json: aString parseToDict: aValue
	"parse string and check if equal to value"
	| parsedValue |
	parsedValue := WebJSON parse: aString.
	self assert: parsedValue class == Dictionary.
	self assert: parsedValue keys size = aValue keys size.
	parsedValue keysAndValuesDo: [:key :value |
		self assert: (aValue at: key) = value]! !

!WebJSONTest methodsFor: 'support' stamp: 'janko 8/30/2013 15:17'!
json: aString parseToObject: aValue
	"parse string and check if equal to value"
	| parsedValue |
	parsedValue := WebJSON parse: aString.
	self assert: parsedValue class == WebJSONObject.
	self assert: parsedValue attributes size = aValue attributes size.
	parsedValue attributes do: [:attr |
		self assert: (aValue at: attr key) = attr value]! !

!WebJSONTest methodsFor: 'support'!
json: aString stringifyFrom: aValue
	"serialize value and check if equal to json string"
	| jsonString |
	jsonString := WebJSON stringify: aValue.
	self assert: jsonString = aString.! !

!WebJSONTest methodsFor: 'support' stamp: 'jm 12/15/2010 00:16'!
json: andArrayOfStrings stringifyFromDict: aValue
	"serialize value and check if equal to one of json strings"
	| jsonString |
	jsonString := WebJSON stringify: aValue.
	self assert: (andArrayOfStrings includes: (jsonString copyWithout: $ ))! !


!WebJSONTest methodsFor: 'testing-parsing'!
testParseArray
	self json: '[]' parseTo: #().
	self json: '[[]]' parseTo: #(#()).
	self json: '[[], []]' parseTo: #(#() #()).
	self json: '["hi", "there"]' parseTo: #('hi' 'there').
	self json: '[["a", "b", null]]' parseTo: #(('a' 'b' nil)).! !

!WebJSONTest methodsFor: 'testing-parsing'!
testParseFalse
	self json: 'false' parseTo: false.
	self json: '  false' parseTo: false.
	self json: 'false  ' parseTo: false.
	self json: '  false  ' parseTo: false.! !

!WebJSONTest methodsFor: 'testing-parsing'!
testParseNull
	self json: 'null' parseTo: nil.
	self json: '  null' parseTo: nil.
	self json: 'null  ' parseTo: nil.
	self json: '  null  ' parseTo: nil.! !

!WebJSONTest methodsFor: 'testing-parsing' stamp: 'janko 7/13/2011 22:01'!
testParseNumber
	self json: '1' parseTo: 1.
	self json: '0123' parseTo: 123.
"	self json: '1.23e2' parseTo: 123. "
	self json: '-1' parseTo: -1.
	self json: '-0' parseTo: 0.
"	self json: '[-1.2]' parseTo: #(-1.2). "! !

!WebJSONTest methodsFor: 'testing-parsing'!
testParseString
	self json: '"hi"' parseTo: 'hi'.
	self json: '"\""' parseTo: '"'.
	self json: '"\\"' parseTo: '\'.
	self json: '""' parseTo: ''.! !

!WebJSONTest methodsFor: 'testing-parsing'!
testParseTrue
	self json: 'true' parseTo: true.
	self json: '  true' parseTo: true.
	self json: 'true  ' parseTo: true.
	self json: '  true  ' parseTo: true.! !


!WebJSONTest methodsFor: 'testing-serializing'!
testStringifyArray
	self json: '[]' stringifyFrom: #().
	self json: '[[]]' stringifyFrom: #(#()).
	self json: '[[], []]' stringifyFrom: #(#() #()).
	self json: '["hi", "there"]' stringifyFrom: #('hi' 'there').
	self json: '[["a", "b", null]]' stringifyFrom: #(('a' 'b' nil)).! !

!WebJSONTest methodsFor: 'testing-serializing' stamp: 'jm 12/15/2010 00:17'!
testStringifyDictionary
	self json: '{}' stringifyFrom: (Dictionary new).
	self json: '{"a": "a"}' stringifyFrom: (Dictionary new at: 'a' put: 'a'; yourself).
	self json: '{"a": [[]]}' stringifyFrom: (Dictionary new at: 'a' put: #(#()); yourself).
	self json: #('{"a":"b","b":"a"}' '{"b":"a","a":"b"}') 
		stringifyFromDict: (Dictionary new add: 'a'->'b'; add: 'b'->'a'; yourself).! !

!WebJSONTest methodsFor: 'testing-serializing'!
testStringifyFalse
	self json: 'false' stringifyFrom: false! !

!WebJSONTest methodsFor: 'testing-serializing'!
testStringifyNil
	self json: 'null' stringifyFrom: nil! !

!WebJSONTest methodsFor: 'testing-serializing'!
testStringifyNumber
	self json: '1' stringifyFrom: 1.
	self json: '123' stringifyFrom: 123.
	self json: '-1' stringifyFrom: -1.
	self json: '[-1.2]' stringifyFrom: #(-1.2).! !

!WebJSONTest methodsFor: 'testing-serializing'!
testStringifyString
	self json: '"hi"' stringifyFrom: 'hi'.
	self json: '"\""' stringifyFrom: '"'.
	self json: '"\\"' stringifyFrom: '\'.
	self json: '""' stringifyFrom: ''.! !

!WebJSONTest methodsFor: 'testing-serializing'!
testStringifyTrue
	self json: 'true' stringifyFrom: true! !


TestCase subclass: #WebSecurityTest
	instanceVariableNames: 'server site mgr'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!WebSecurityTest methodsFor: 'running' stamp: 'mivsek 8/22/2007 21:20'!
setUp
"TOO DANGEROUS!!!!!!
	server := Swazoo.SwazooServer singleton.
	server initialize.  ""to remove all stuff and stop it""
	site := AIDASite newNamed: 'test'.
	mgr := site securityManager.
"! !

!WebSecurityTest methodsFor: 'running' stamp: 'mivsek 8/22/2007 21:20'!
tearDown
"	site := server siteNamed: 'test'.
	site stop.
	server removeSite: site.
	server := nil. site := nil. mgr := nil.
"! !


!WebSecurityTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 21:21'!
testGroups
"	| group |
	self assert: (mgr groups size = 2). ""AllUsers and Admins""
	group := WebUserGroup new name: 'test'.
	self deny: (mgr existGroupNamed: 'test').
	mgr addGroup: group.
	self assert: (mgr existGroupNamed: 'test').
	self assert: (mgr groups size = 3). 
	mgr addGroupNamed: 'test'. ""duplicate test""
	self assert: (mgr groups size = 3).
	mgr removeGroupNamed: 'test'.
	self assert: (mgr groups size = 2).
"! !

!WebSecurityTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 21:21'!
testInitialize
"	self assert: mgr users size = 1.
	self assert: mgr groups size = 2.  ""Admininstrators and AllUsers""
	self assert: (mgr existUserNamed: 'admin' withPassword: 'password').
	self assert: (mgr existGroupNamed: 'Administrators').
	self assert: (mgr existGroupNamed: 'AllUsers').
"! !

!WebSecurityTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 21:22'!
testMultipleAccessRights
"	| object right1 right2 user |
	right1 := #AllowThat. right2 := #AllowThatToo.
	object := #JustSomething.
	user := mgr adminUser.
	self deny: (mgr has: user rightTo: right1 on: object).
	self deny: (mgr has: user rightTo: right2 on: object).
	mgr setAccessRights: (Array with: right1 with: right2) for: mgr adminUser on: object.
	self assert: (mgr has:user rightTo: right1 on: object).
	self assert: (mgr has: user rightTo: right2 on: object).
	mgr removeAccessRights: (Array with: right1 with: right2) for: mgr adminUser on: object.
	self deny: (mgr has: user rightTo: right1 on: object).
	self deny: (mgr has: user rightTo: right2 on: object).
"! !

!WebSecurityTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 21:22'!
testSimpleAccessRight
"	| right object user |
	right := #AllowThat.
	object := #JustSomething.
	user := mgr adminUser.
	self deny: (mgr has: user rightTo: right on: object).
	mgr setAccessRights: right for: mgr adminUser on: object.
	self assert: (mgr has:user rightTo: right on: object).
	mgr removeAccessRights: right for: mgr adminUser on: object.
	self deny: (mgr has: user rightTo: right on: object).
"! !

!WebSecurityTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 21:23'!
testUsers
"	| user |
	self assert: (mgr users size = 1). ""only admin user""
	user := WebUser new username: 'test'; password: 'test'; email: 'a@a.si'.
	self deny: (mgr existUserNamed: 'test' withPassword: 'test').
	mgr addUser: user.
	self assert: (mgr existUserNamed: 'test' withPassword: 'test').
	self assert: (mgr users size = 2). 
	mgr addUser: user. ""duplicate test""
	self assert: (mgr users size = 2).
	mgr removeUserNamed: 'test' withPassword: 'test'.
	self assert: (mgr users size = 1).
"! !


TestCase subclass: #WebSessionMgmtTest
	instanceVariableNames: 'server site session'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Tests'!

!WebSessionMgmtTest methodsFor: 'running' stamp: 'mivsek 8/22/2007 21:24'!
setUp
"TOO DANGEROUS!!!!!!
	server := Swazoo.SwazooServer singleton.
	server initialize.  ""to remove all stuff and stop it""
	site := AIDASite newNamed: 'test'.
	session := WebSession newOn: site sessionManager.
"! !

!WebSessionMgmtTest methodsFor: 'running' stamp: 'mivsek 8/22/2007 21:24'!
tearDown
"	site := server siteNamed: 'test'.
	site stop.
	server removeSite: site.
	server := nil. site := nil. session := nil.
"! !


!WebSessionMgmtTest methodsFor: 'testing' stamp: 'mivsek 8/22/2007 21:24'!
testSetUp
"	self assert: session notNil "! !
