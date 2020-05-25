Object subclass: #AidaGroup
	instanceVariableNames: 'site members authorizator'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!

!AidaGroup methodsFor: 'adding-removing'!
addMember: anAIDAGroupMember
	(self members contains: [:each | each siteName = anAIDAGroupMember siteName])
		ifFalse: 
			[self members add: anAIDAGroupMember.
			anAIDAGroupMember group: self].
	^anAIDAGroupMember! !

!AidaGroup methodsFor: 'adding-removing'!
addSiteNamed: aString
	(self includesSiteNamed: aString) ifTrue: [^nil].
	self addMember: 
		(AidaGroupMember new siteName: aString)! !

!AidaGroup methodsFor: 'adding-removing'!
removeMember: anAIDAGroupMember
	^self members 
		remove: anAIDAGroupMember 
		ifAbsent: []! !

!AidaGroup methodsFor: 'adding-removing'!
removeSiteNamed: aString! !


!AidaGroup methodsFor: 'accessing'!
authorizator
	"for cross-site authorization and replication of user credentials"
	^authorizator! !

!AidaGroup methodsFor: 'accessing'!
authorizator: anObject

	authorizator := anObject! !

!AidaGroup methodsFor: 'accessing'!
members
	members ifNil: [self initMembers].
	^members! !

!AidaGroup methodsFor: 'accessing'!
site
	^site! !

!AidaGroup methodsFor: 'accessing'!
urlForSite: aSiteName
	^(self members
		detect: [:each | each siteName = aSiteName]
		ifNone: [^nil])
			url! !


!AidaGroup methodsFor: 'testing'!
includesSiteNamed: aString
	^self members contains: [:each | each siteName = aString]! !


!AidaGroup methodsFor: 'initialize-release'!
initMembers
	members := OrderedCollection new.! !


!AidaGroup methodsFor: 'private'!
site: anAIDASite
	site := anAIDASite! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AidaGroup class
	instanceVariableNames: ''!

!AidaGroup class methodsFor: 'instance creation'!
newOn: anAIDASite
	^super new
		site: anAIDASite! !


Object subclass: #AidaGroupAuthorizator
	instanceVariableNames: 'parent'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!

!AidaGroupAuthorizator methodsFor: 'accessing'!
parent
	^parent! !


!AidaGroupAuthorizator methodsFor: 'private'!
parent: anAidaGroup
	parent := anAidaGroup! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AidaGroupAuthorizator class
	instanceVariableNames: ''!

!AidaGroupAuthorizator class methodsFor: 'instance creation'!
newFor: anAidaGroup
	^self new
		parent: anAidaGroup! !


Object subclass: #AidaGroupMember
	instanceVariableNames: 'group siteName url'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!

!AidaGroupMember methodsFor: 'accessing'!
group

	^group! !

!AidaGroupMember methodsFor: 'accessing'!
siteName
	siteName ifNil: [^''].
	^siteName! !

!AidaGroupMember methodsFor: 'accessing'!
siteName: aString
	siteName := aString! !

!AidaGroupMember methodsFor: 'accessing'!
url
	"member site address part of url, like http://www.aidaweb.si "
	url ifNil: [^''].
	^url! !

!AidaGroupMember methodsFor: 'accessing'!
url: aString
	"member site address part of url, like http://www.aidaweb.si "
	url := aString trimBlanks.
	url last = $/ ifTrue: 
		[url := url copyFrom: 1 to: url size-1]. "without last / in url"
	^url! !


!AidaGroupMember methodsFor: 'private'!
group: anAIDAGroup
	group := anAIDAGroup! !


Object subclass: #WebAdmin
	instanceVariableNames: 'host ip port'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!
!WebAdmin commentStamp: '<historical>' prior: 0!
WebAdmin is domain model part for WebAdminApp
!


!WebAdmin methodsFor: 'accessing' stamp: 'np 3/16/2009 12:57'!
aidaCacheView: aSymbol on: aWebSession
	^false
	"^aSymbol = #login"  "use only for standard throughput benchmark!!"! !

!WebAdmin methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
host
	^host! !

!WebAdmin methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
host: aString
	host := aString! !

!WebAdmin methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
ip
	^ip! !

!WebAdmin methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
ip: aString
	ip := aString! !

!WebAdmin methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
port
	^port! !

!WebAdmin methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
port: aNumber
	port := aNumber! !


WebApplication subclass: #WebAdminApp
	instanceVariableNames: 'username password newUser newSite'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!
!WebAdminApp commentStamp: '<historical>' prior: 0!
WebAdminApp for login/logout, basic website setup, server runs etc.!


!WebAdminApp methodsFor: 'actions' stamp: 'mivsek 6/13/2007 16:33'!
actionAddSite
	SwazooServer singleton addSite: self newSite.
	self newSite start.
	self redirectToView: #sites.! !

!WebAdminApp methodsFor: 'actions' stamp: ' 21/4/07 22:07'!
actionForgoten
	self redirectTo: self site admin view: #passwordSent.! !

!WebAdminApp methodsFor: 'actions'!
actionLogin
	| user |
	(self site securityManager isAllowedToLoginIP: self session lastRequest peer) ifFalse:
		[self reportLoginWarning: 'not allowed from this IP'.
		self site securityManager ipFilterPolicy = #deny 
			ifTrue: [self session logout. ^self] ]. "don't allow to login from this IP"
	[self site authenticator startAuthentication.
	(self site authenticator existUserNamed: self username) ifFalse: 
		[self delay; reportLoginError: 'This user does not exist!!' "see #viewLogin inError...". self session logout. ^self].
	(self site authenticator authenticateUserNamed: self username withPassword: self password) ifFalse: 
		[self delay; reportLoginError: 'Password wrong!!'  "see #viewLogin inError...". self session logout. ^self].
	user := self site authenticator userNamed: self username.
	] ensure: [self site authenticator endAuthentication].

	self session loginUser: user. 
	self reportLogin. 	self password: ''.

	(self site afterLogin = #myPage and: [self site autoLogout not])
		ifTrue: [^self redirectTo: self user asPerson].
	self site afterLogin = #lastPage ifFalse: [^self redirectTo: self site afterLogin]. 
	(user logoutFromUrl notNil and: [self site urlResolver existUrl: user logoutFromUrl])
		ifTrue: [self redirectTo: user logoutFromUrl] "back from where we were logout"
		ifFalse: [self redirectTo: '/']
"		ifFalse: [self redirectTo: (user asPerson notNil ifTrue: [user asPerson] ifFalse: ['/']) ] "! !

!WebAdminApp methodsFor: 'actions' stamp: ' 21/4/07 22:07'!
actionRegistration
	self isRegistrationValid 
		ifTrue: 
			[self site securityManager addActivatingUser: self newUser.
			self newView: #waitingConfirmation]
		ifFalse: ["just reload registration form again"]! !

!WebAdminApp methodsFor: 'actions' stamp: 'mivsek 6/13/2007 16:34'!
actionSites
	self newSite: AIDASite new.
	self newSite uriPattern first 
		ip: self observee ip;
		port: self observee port.
	self redirectToView: #addSite.! !

!WebAdminApp methodsFor: 'actions' stamp: ' 21/4/07 22:07'!
actionUpdateSettings
	[(Delay forMilliseconds: 500) wait.
	self site stop.
	self updateSettings.
	self site start] fork.
	self redirectToView: #redirect! !

!WebAdminApp methodsFor: 'actions'!
delay
	"after failed login delay for 1 second to avoid brute force login attacks"
	(Delay forSeconds: 1) wait! !

!WebAdminApp methodsFor: 'actions' stamp: ' 21/4/07 22:07'!
prepareSettings
	self observee host: self site host.
	self observee ip: self site ip.
	self observee port: self site port.! !

!WebAdminApp methodsFor: 'actions' stamp: ' 21/4/07 22:07'!
updateSettings
	self site host: self observee host.
	self site ip: self observee ip.
	self site port: self observee port.! !


!WebAdminApp methodsFor: 'views-elements' stamp: 'mivsek 6/13/2007 16:36'!
addSiteElement
	| e |
	e := WebElement new.
	e cell addText: 'Site name: '. 
	e newCell addInputFieldAspect: #name for: self newSite. e newRow.
	e cell colspan: 2; addRulerSize: 1. e newRow.
	e cell addText: 'Hostname: '. 
	e newCell addInputFieldAspect: #host for: self newSite uriPattern first. e newRow.
	e cell addText: 'IP: '. 
	e newCell addInputFieldAspect: #ip for: self newSite uriPattern first. e newRow.
	e cell addText: 'Port: '. 
	e newCell addInputFieldAspect: #port for: self newSite uriPattern first. e newRow.
	e cell colspan: 2; addRulerSize: 1. e newRow.
	e cell addText: 'Style class: '. 
	e newCell addInputFieldAspect: #styleClass for: self newSite. e newRow.
	e cell colspan: 2; addRulerSize: 1. e newRow.
	e cell addButtonText: 'Add and start a new site'.
	e cell colspan: 2; addRulerSize: 1. e newRow.
	^e.! !

!WebAdminApp methodsFor: 'views-elements'!
settingsElement
	| e |
	e := WebElement new.
	e table width: 500.
      e cell color: #yellow; addText: self title header: 3. e newRow.
	e cell add: (self settingsElementForm: false). e newRow.
	e cell addLinkTo: self observee text: '<b>Update settings</b>' view: #updateSettings.
	^e! !

!WebAdminApp methodsFor: 'views-elements'!
settingsElementForm: aBoolean
	| e |
	self prepareSettings.
	e := WebElement new. e table width: 500. e newRow.
	e cell addText: 'hostname: '. 
	e newCell addAspect: #host for: self observee input: aBoolean size: 30. e newRow.
	e cell addText: 'ip: '.
	e newCell addAspect: #ip for: self observee input: aBoolean size: 30. e newRow.
	e cell addText: 'port: '.
	e newCell addAspect: #port for: self observee input: aBoolean size: 5. e newRow.
	e cell addText: 'home directory: '.
	e newCell addAspect: #homeDirectory for: self site input: aBoolean size: 30. e newRow.
	e cell colspan: 2; addRulerSize: 1.
	^e.! !

!WebAdminApp methodsFor: 'views-elements'!
tabsSettingsElement
	| tabs |
	tabs := ViewTabs new.
	tabs
		addView: #settings description: 'Main settings';
		addView: #sites description: 'Sites'.
	^tabs! !


!WebAdminApp methodsFor: 'private' stamp: ' 21/4/07 22:07'!
aidaDontCache
	^true! !

!WebAdminApp methodsFor: 'private'!
printSeconds: aNumber
	^(aNumber // 3600) printString, ':',
	(self twoDigits: aNumber \\ 3600 // 60), ':',
	(self twoDigits: aNumber \\ 60)! !

!WebAdminApp methodsFor: 'private'!
reportLogin
	Transcript cr; show: 'login: ', self session user nameSurname asSloveneWithoutCircumflexes, 
	' on ', self site name,
	' at ', 
 	Date today dayOfMonth printString, '.',
	Date today monthIndex printString, ' ',
	Time now hours printString, ':', 
	Time now minutes printString,
	' from ', self session lastRequest realPeerIp! !

!WebAdminApp methodsFor: 'private'!
reportLoginError: aString
	self showError: aString. "to show in red on the page"
	Transcript cr; show: '*** login error: ', self username, ' ', aString, 
	' on ', self site name,
	' at ', 
 	Date today dayOfMonth printString, '.',
	Date today monthIndex printString, ' ',
	Time now hours printString, ':', 
	Time now minutes printString,
	' from ', self session lastRequest realPeerIp! !

!WebAdminApp methodsFor: 'private'!
reportLoginWarning: aString
	"just on transcript, not to the user!!"
	Transcript cr; show: '*** login warning: ', self username, ' ', aString, 
	' on ', self site name,
	' at ', 
 	Date today dayOfMonth printString, '.',
	Date today monthIndex printString, ' ',
	Time now hours printString, ':', 
	Time now minutes printString,
	' from ', self session lastRequest realPeerIp! !

!WebAdminApp methodsFor: 'private'!
reportLogout
	Transcript cr; show: 'logout: ', self session user nameSurname asSloveneWithoutCircumflexes, 
	' on ', self site name,
	' at ', 
 	Date today dayOfMonth printString, '.',
	Date today monthIndex printString, ' ',
	Time now hours printString, ':', 
	Time now minutes printString,
	' from ', self session lastRequest realPeerIp! !

!WebAdminApp methodsFor: 'private'!
twoDigits: aNumber
	aNumber < 10
		ifTrue: [^'0',aNumber printString]
		ifFalse: [^aNumber printString]! !


!WebAdminApp methodsFor: 'accessing' stamp: 'np 10/18/2008 16:09'!
dummy
	"aspect, just for nothing"
	^''! !

!WebAdminApp methodsFor: 'accessing' stamp: 'np 10/18/2008 16:09'!
dummy: aString
	"aspect, just for nothing"! !

!WebAdminApp methodsFor: 'accessing' stamp: 'mivsek 6/13/2007 16:35'!
newSite
	^newSite! !

!WebAdminApp methodsFor: 'accessing' stamp: 'mivsek 6/13/2007 16:35'!
newSite: anObject
	newSite := anObject! !

!WebAdminApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
newUser
	^newUser! !

!WebAdminApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
newUser: anUser
	newUser := anUser! !

!WebAdminApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
password
	password isNil ifTrue: [self password: ''].
	^password! !

!WebAdminApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
password: aString
	password := aString.! !

!WebAdminApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
username
	username isNil ifTrue: [self username: ''].
	^username! !

!WebAdminApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
username: aString
	username := aString.! !


!WebAdminApp methodsFor: 'views-sites'!
enabledStartedElementFor: aSite
	"Ajax toggle enable/disable and start/stop in sitesElement "
	| e  |
	e := WebElement newSpan. e table width: 1.
	(e cell addNilLinkText: (aSite isEnabled ifTrue: ['enabled'] ifFalse: ['disabled']) )
		title: (aSite isEnabled ifTrue: ['Click to disable this site'] ifFalse: ['Click to enable this site']);
		onClickDo: [(aSite isEnabled ifTrue: [aSite disable] ifFalse: [aSite enable]) ];
		onClickUpdate: e with: aSite.
	aSite isEnabled ifTrue:
		[(e newCell addNilLinkText: (aSite isServing ifTrue: ['running'] ifFalse: ['stopped']) )
			title: (aSite isServing ifTrue: ['Click to stop this site'] ifFalse: ['Click to start this site']);
			onClickDo: [(aSite isServing ifTrue: [aSite stop] ifFalse: [aSite start]) ];
			onClickUpdate: e with: aSite].
	^e! !

!WebAdminApp methodsFor: 'views-sites'!
green: anElement ifActive: aSite
	"flash for a while then stay green for one hour"
	| script age |
	aSite isActive "last hour" ifFalse: [^nil].
	script := 'var e = document.getElementById("', anElement id asString, '");'.
	age := SpTimestamp now asSeconds - aSite lastRequestTimestamp asSeconds.
	age > 2
		ifTrue: [script := script, 'e.style.backgroundColor="green";']  "flash a bit"
		ifFalse: [script := script, 'e.style.backgroundColor="lightgreen";']. 
	script := script, '
if (e.greenId) { clearTimeout(e.greenId); }; if (e.green2Id) { clearTimeout(e.green2Id); };
e.greeId=setTimeout(function() { e.style.backgroundColor="lightGreen"; } , 500);
e.green2Id=setTimeout(function(){e.style.backgroundColor=null;},', (((3600 - age) max: 0)*1000) printString, ');
'.
	anElement scriptAfter: script! !

!WebAdminApp methodsFor: 'views-sites'!
lastActivityElementFor: aWebStatistics
	"real-time display of last activity timestamp"
	| e  |
	e := WebElement newDiv. 
	e addText: aWebStatistics site lastRequestTimestampText.
	e updateWhenChanged: aWebStatistics.
	^e! !

!WebAdminApp methodsFor: 'views-sites'!
pagesAllElementFor: aWebStatistics
	"real-time display of last activity timestamp"
	| e  |
	e := WebElement newDiv.
	e addText: aWebStatistics site allPages printDotString.
	e updateWhenChanged: aWebStatistics.
	^e! !

!WebAdminApp methodsFor: 'views-sites'!
pagesMonthlyElementFor: aWebStatistics 
	"real-time display of last activity timestamp"
	| e  |
	e := WebElement newDiv.
	e addText: aWebStatistics site 
		allPagesThisMonth printDotString.
	e updateWhenChanged: aWebStatistics.
	^e! !

!WebAdminApp methodsFor: 'views-sites'!
pagesTodayElementFor: aWebStatistics
	"real-time display of last activity timestamp"
	| e  |
	e := WebElement newDiv.
	e addText: aWebStatistics site allPagesToday printDotString.
	self 
		green: e 
		ifActive: aWebStatistics site. "flash for a while then stay green for one hour"
	e updateWhenChanged: aWebStatistics.
	^e! !

!WebAdminApp methodsFor: 'views-sites'!
pagesWeeklyElementFor: aWebStatistics
	"real-time display of last activity timestamp"
	| e  |
	e := WebElement newDiv.
	e addText: aWebStatistics site allPagesThisWeek printDotString.
	e updateWhenChanged: aWebStatistics.
	^e! !

!WebAdminApp methodsFor: 'views-sites'!
sitesElement
	| e sites |
	sites := SortedCollection  "enabled sites on top of the list"
		withAll: (SwazooServer singleton sites select: [:each | each isEnabled])
		sortBlock: [:a :b | a name < b name].
	sites := sites asOrderedCollection 
		addAll: (SortedCollection 
			withAll: (SwazooServer singleton sites select: [:each | each isEnabled not])
			sortBlock: [:a :b | a name < b name]) asOrderedCollection; yourself.
	e := (WebGrid new
		columnFilters: #(nil 5 nil 10 );
		columnWidth: #(0.03 0.10 0.03 0.10);
		columnNames: #(nil 'name' '' 'enabled/started' 'created' 'last request' 'pages today'
			 'this week' 'this month' 'all');
		columnAspects: #(nil name nil nil createdDate nil nil nil nil nil );
		columnAlign: #(nil nil nil nil center center right right right right);
		rowGrayIfTrue: [:site | site isEnabled not];
		column: 3 addBlock: [:site | 
			[WebLink text: 'link' linkTo: (site urlResolver fullUrlFor: site admin on: nil)]
				on: Error do: [:ex | WebText text: 'nolink'] ];
		column: 4 addBlock: [:site | self enabledStartedElementFor: site];
		column: 6 addBlock: [:site | self lastActivityElementFor: site statistics];
		column: 7 addBlock: [:site | self pagesTodayElementFor: site statistics];
		column: 8 addBlock: [:site | self pagesWeeklyElementFor: site statistics];
		column: 9 addBlock: [:site | self pagesMonthlyElementFor: site statistics];
		column: 10 addBlock: [:site | self pagesAllElementFor: site statistics];
		collection: sites;
		setNumbering; 
		yourself).
	^e.! !


!WebAdminApp methodsFor: 'testing'!
isRegistrationValid
	"check entry fields and set error report if not"
	| text |
	text := ''.
	(self site securityManager 
		existUserNamed: self newUser username withPassword: self newUser username)
			ifTrue: [text := text, ' User with that username and password already exist!! ' ].
	text isEmpty ifTrue: 
		[self newUser username isEmpty ifTrue: [text := text, ' Username missing, '].
		self password isEmpty ifTrue: [text := text, ' Password missing, '].
		self newUser password isEmpty ifTrue: [text := text, ' Confirm password missing, '].
		((WebSecurityManager hashPassword: self password) = self newUser password)
			ifFalse: [text := text, ' Passwords not equal!! '] ].
	text notEmpty ifTrue: 
		[self showError: 'Registration failed!! ', text, ' Please correct errors and try again!!'. ^false].
	^true! !

!WebAdminApp methodsFor: 'testing' stamp: 'mivsek 1/10/2008 22:48'!
preloginCheck
	"this is called at the start of login page. Override if you want to redirect for some reason
	to another login page (#viewLoginSecondary)"
	^true! !


!WebAdminApp methodsFor: 'views'!
viewActivation
	| e id user |
	(self session lastRequest includesQuery: 'userid') ifTrue:
		[id := (self session lastRequest queryAt: 'userid') asInteger.
		(self site securityManager existUserWithId: id) ifTrue:
			[user := self site securityManager userWithId: id.
			 self site securityManager addRegisteredUser: user.
			self session loginUser: user.
			self title: 'Activation successfull!!'.
			e := WebElement new.
			e addTextH1: 'Activation successfull!!'.
			e addText: 'Congratulations!! You are now a registered user of our portal. You are 
			already logged in and your name is shown on the page'. 
 			^self style pageFrameWith: e title: self title] ].

	self title: 'Activation failed!!'.
	e := WebElement new.
	e addTextH1: 'Activation failed!!'.
	e addText: ' You tried to activate an user account but activation failed. Please send an email to '. 
	e addLinkTo: 'info@eranova.si' text: 'Portal Administrator'.
 	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewAddSite
	| e |
	self	title: 'Web sites'.
	e := WebElement new.
	e addTextH1: 'Adding a new web site'. e addBreak. 
	e add: self addSiteElement.
	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewForgoten
	| e f |
	self title: 'Lost Password'.
	e := WebElement new.
	e addTextH1: 'Lost Password'.
	e addText: ' Enter your username below, click Send me my password, and your password 
	will be mailed to you if you gave a valid email address when you registered. If this will not 
	work for you (for example, if you forgot your member name or didn''t enter your email address) 
	send an email to '. 
	e addLinkTo: 'info@eranova.si' text: 'Portal Administrator'.
	f := WebFieldSet newLegend: 'User details'.
	f cell addText: 'My username is: '.
	f newCell add: (WebInputField new aspect: #username for: self).
	f newRow. f newCell addButtonText: 'Send me my password'. 
	e add: f.
 	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewLogin
	| e l |
	self preloginCheck ifFalse: [^self viewLoginSecondary].  "if some error etc."
	self title: self style loginTitle.
	e := WebElement new.
"	e scriptBefore: 'Element.hide(''', self searchButton id, ''')'." "remove search button on navbar!!"
	e addText: self style loginWelcomeMessage. 
	l := (WebFieldSet newId: #login) legend: #en->'Login'.
	self inError ifTrue: 
		[l cell colspan: 2; addText: self style loginErrorText. self showError: nil.
		l newRow. l cell addNbSp. l newRow].
	l cell addText: #en->'Username: '. 
	(l newCell add: (WebInputField new aspect: #username for: self))
		focus; "let text cursor be there at the start!! "
		autocomplete: false. "do not autocmplete username and password"
	l newRow. l cell addText: #en->'Password: '. 
	(l newCell add: (WebInputField new type: #password; aspect: #password for: self))
		autocomplete: false.
	l newRow. l newCell addButtonText: #en->'Login'.
	e add: l.
	e addText: self style loginBelowMessage.
" 
	e newRow. e newCell addGif: #bulletSquareLeftWhiteGif ; 
		addLinkTo: self observee text: ' Forgot your password ?' view: 'forgoten'.
	e newRow. e newCell addGif: #bulletSquareLeftWhiteGif ; 
		addLinkTo: self observee text: ' New user ?' view: 'registration'.
"
 	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewLoginSecondary
	"this one is called if preloginCheck returns false. Usefull for prelogin error reporting etc.
	Byy thefault it returns error report in red. Override that by your wishes"
	| e |
	self title: self style loginTitle.
	e := WebElement new.
	self showError: self style loginErrorTextSecondary.
	e add: self errorReport.
 	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewLogout
	self session isLoggedIn ifTrue: 
		[self reportLogout.
		self session logout.
		self username: ''. self password: ''].
	self site securityManager hasFormAuthenticationScheme ifTrue: [^self redirectToView: #login].
	self site securityManager hasHttpAuthenticationScheme ifTrue: [^self redirectTo: '/'].! !

!WebAdminApp methodsFor: 'views' stamp: 'janko 9/12/2011 14:58'!
viewMain
	| element |
	self	title: #en->'Admin'.
	element := WebElement new.
	^self style pageFrameWith: element title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewPasswordSent
	| e |
	self title: 'Lost Password sent'.
	e := WebElement new.
	e addTextH1: 'Password sent'.
	e addText: ' Your password was sent to email address from your user profile. If you have 
      any more troble, please send an email to '. 
	e addLinkTo: 'info@eranova.si' text: 'Portal Administrator'.
 	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewRedirect
	| e url |
	self title: 'Restarting a site'.
	e := WebElement new.
	e addText: 'Restarting a site with new settings ...'.
	url := 'http://', self observee host, ':', self observee port printString, '/admin.html?view=settings'.
" this don't work on mozilla!!
	self redirectAfter: 2 toUrl: url.
"
self script: ('<SCRIPT LANGUAGE="JavaScript">
<!!-- Begin
redirTime = "2000";
redirURL = "', url, '";
function redirTimer() { self.setTimeout("self.location.href = redirURL;",redirTime); }
//  End -->
</script>').

	self attributesAt: #onLoad put: 'redirTimer()'.
	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewRegistration
	| e f |
	self inError ifFalse: [self newUser: self site webUserClass new. self password: ''].
	self title: 'Registration Form'.
	e := WebElement new.
	e addTextH1: 'Registration Form'.
	e addErrorReport.
	f := WebFieldSet newLegend: 'Personal details'.
	f cell addText: 'Name: '. f newCell addInputFieldAspect: #name for: self newUser. f newRow.
	f cell addText: 'Surname: '. f newCell addInputFieldAspect: #surname for: self newUser. f newRow.
	f cell addText: 'E-mail: '. f newCell addInputFieldAspect: #email for: self newUser. f newRow.
	f cell addText: 'Username: '. f newCell addInputFieldAspect: #username for: self newUser.
	f newRow.
	f cell addText: 'Password: '. f newCell addPasswordFieldAspect: #password for: self. f newRow.
	f cell addText: 'Confirm Password: '. f newCell addPasswordFieldAspect: #password for: self newUser.
	f newRow. f newCell addButtonText: 'Register'. 
	e add: f.
 	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewServerRuns
	| e inx runs |
	self site setLastTimeAliveTimestamp.
	self	title: 'Runs for site: ', self site name.
	e := WebElement new.
	e table width: self style pageContentWidth. e cell color: #yellow.
	e cell colspan: 6; addText: self title header: 3. e newRow color: #thistle.
	e cell align: #center; addText: 'nr '.
	e newCell align: #center; addText: 'started '. e newCell align: #center; addText: 'last time alive '.
	e newCell align: #center; addText: 'uptime'. e newCell align: #center; addText: 'downtime'.
	e newCell align: #center; addText: 'termination'. e newRow.
	inx := 1. runs := self site runningHistory.
	runs do: [:array |
		inx even ifTrue: [e row color: #silver].
		e cell align: #center; addText: inx printString.
		e newCell align: #right; addText: (array at: 1) printSloString.
		e newCell align: #right; addText: (array at: 2) printSloString.
		e newCell align: #right; addText: (self printSeconds: (array at: 3) ).
		e newCell align: #right; addText: (self printSeconds: (array at: 4) ).
		e newCell align: #center; addText: 
			(array == runs last ifTrue: ['running'] ifFalse: [(array at: 5) ifTrue: ['crashed'] ifFalse: ['normal']]).
		inx := inx + 1. e newRow].
	e cell colspan: 6; addRulerSize: 1.
	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewServerStatistics
	| e |
	self site setLastTimeAliveTimestamp.
	self title: 'Statistics for site: ' , self site name.
	e := WebElement new.
	e table width: self style pageContentWidth.
	e cell color: #yellow.
	e cell colspan: 3; addText: self title header: 3. e newRow.
	e cell addText: 'created: '.
	e newCell align: #right; addText: self session site createdTimestamp printSloString. e newRow.
	e cell addText: 'started: '.
	e newCell align: #right; addText: self session site startedTimestamp printSloString.
	e newCell align: #right; addLinkTo: self observee text: 'History of runs' view: 'serverRuns'. e newRow.
	e cell colspan: 3; addRulerSize: 1. e newRow.
	e cell addText: 'uptime: '.
	e newCell align: #right; addText: (self printSeconds: self session site uptime) , ' h:m:s'. e newRow.
	e cell addText: 'total uptime: '.
	e newCell align: #right; addText: (self printSeconds: self session site totalUptime) , ' h:m:s'. 	e newRow.
	e cell addText: 'total downtime: '.
	e newCell align: #right; addText: (self printSeconds: self session site totalDowntime), ' h:m:s'. e newRow.
	e cell addText: 'availability [%]: '.
	e newCell align: #right; addText: self session site availability printDotString. e newRow.
	e cell colspan: 3; addRulerSize: 1. e newRow.
	e cell addText: 'today requests: '.
	e newCell align: #right; addText: (self session site requestsOnDate: SpDate today) printDotString. e newRow.
	e cell addText: 'yesterday requests: '.
	e newCell align: #right; addText: (self session site requestsOnDate: (SpDate today subtractDays: 1)) printDotString.
	e newRow. e cell addText: 'all requests: '.
	e newCell align: #right; addText: self session site totalRequests printDotString. e newRow.
	e cell colspan: 3; addRulerSize: 1.
	^self style pageFrameWith: e title: self title! !

!WebAdminApp methodsFor: 'views'!
viewSettings
	| e |
	self	title: 'Settings for site: ', self site name.
	e := WebElement new.
	e addTextH1: self title. e addBreak. 
	e add: self tabsSettingsElement. e addBreak.
	e add: self settingsElement.
	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewSites
	| e |
	self	title: 'Websites on this Aida/Web server, showing activity in realtime'.
	self enableRealtime.
	e := WebElement new.
	e addTextH1: self title. e addBreak. 
	e add: self tabsSettingsElement. e addBreak.
	e addButtonText: 'Add new web site'. e addBreak.
	e add: self sitesElement.
	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewTests
	"VW specific"
	| e inx bundle testClasses versionId |
	self title: 'Test results'.
	e := WebElement new. inx := 1.
	bundle := Store.BundleModel allInstances detect: [:each | each name = 'BiArt'].
	testClasses := bundle definedClasses
		 select: [:each | each inheritsFrom: XProgramming.SUnit.TestCase].
	testClasses := SortedCollection withAll: testClasses sortBlock: [:a :b | a name < b name].
	e addTextH2: 'Unit testing report'. 
	e table width: 1. e cell colspan: 3; addRulerSize: 1. e newRow.
	e cell addText: 'Bundle: '. e newCell addTextBold: bundle name. e newCell width: 0.7. 
	e newRow.
	e cell addText: 'Version:'. e newCell addText: bundle traceVersionString. e newRow.
	e cell addText: 'Testing date: '. e newCell addText: Date today shortPrintSloString.  e newRow.
	e cell addText: 'Time: '. e newCell addText: Time now printSloString.  e newRow.
	e cell colspan: 3; addText: 'Testing environment: ', 'Cincom VisualWorks Smalltalk v'.  
	versionId := SystemUtils version readStream upTo: $ ; upTo: $ ; upTo: $ .
	e cell addText: versionId. e newRow.
	e cell colspan: 3; addRulerSize: 1. e newRow.
	e newTable width: 1.
	e newCell width: 0.05; addText: 'Test class/method'. e newCell width: 0.4; align: #right; addText: 'Result'. 
	e newCell width: 0.3. e newRow.
	e cell colspan: 4; addRulerSize: 1. e newRow.
	testClasses do: [:cls || suite result |
		e cell addText: inx printString, '.'.  e newCell addText: cls name.
		suite := TestSuite new. 
		cls allTestSelectors do: [:each | suite addTest: (cls selector: each)]. 
		result := [suite run] ifCurtailed: []. 
		e newCell align: #right; addTextSmall: result runCount printString, ' tests '.
		result hasPassed 
			ifTrue: [(e cell addText: 'Passed') color: #green] 
			ifFalse: [(e cell addText: '<b>Failed</b>') color: #red].
		cls allTestSelectors asSortedCollection do: [:each |
			e newRow. e newCell addNbSp: 4; addTextSmall: each asString. 
			e newCell align: #right. (e cell addText: '<small>Passed</small>') color: #green].
		e newCell.
		e newRow. inx := inx + 1].
	e cell colspan: 4; addRulerSize: 1. e newRow.
	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewUpdateSettings
	| e |
	self	title: 'Update Settings for site: ', self site name.
	e := WebElement new.
	e table width: 500.
      e cell color: #yellow;  addText: self title header: 3. e newRow.
	e cell add: (self settingsElementForm: true). e newRow.
	e cell addButtonText: 'Update'.
	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views'!
viewWaitingConfirmation
	| e |
	self title: 'Waiting Confirmation'.
	e := WebElement new.
	e addTextH1: 'Waiting Confirmation'.
	e addText: 'And e-mail was sent to address you entered in a registration form. Please read it
	and click to the activation link to confirm that your e-mail is valid.
	If you have any problems send an email to '. 
	e addLinkTo: 'info@eranova.si' text: 'Portal Administrator'.
 	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views' stamp: 'jm 8/25/2009 20:55'!
viewWakeupRichEditor
	"to prefetch all JS libraries"
	"call that from background Ajax call"
	self context form addText: 'Just to prefetch all TinyMCE JavaScript libraries'; addBreak.
	self context form addRichEditorAspect: #dummy for: self! !


!WebAdminApp methodsFor: 'views-federated login'!
viewLoginGoogle
	"Google federated login with OpenID"
	| e l |
	self preloginCheck ifFalse: [^self viewLoginSecondary].  "if some error etc."
	self site federatedAuthenticator 
		ifNil: [self page addText: 'OpenID authentication is off'. ^self].
	self title: self style loginTitle.
	e := WebElement new.
	e addText: self style loginWelcomeMessage. 
	l := (WebFieldSet newId: #login) legend: #en->'Click to Login with Google Account'.
	self inError ifTrue: 
		[l cell colspan: 2; addText: self style loginErrorText. self showError: nil.
		l newRow. l cell addNbSp. l newRow].
	(l addLinkTo: self observee text: '' view: #loginGoogle2)
		add: (WebImage image: self site federatedAuthenticator providerGoogle imgUrl)
		yourself.
	e add: l.
	e addText: self style loginBelowMessage.
" 
	e newRow. e newCell addGif: #bulletSquareLeftWhiteGif ; 
		addLinkTo: self observee text: ' Forgot your password ?' view: 'forgoten'.
	e newRow. e newCell addGif: #bulletSquareLeftWhiteGif ; 
		addLinkTo: self observee text: ' New user ?' view: 'registration'.
"
 	^self style pageFrameWith: e title: self title .! !

!WebAdminApp methodsFor: 'views-federated login'!
viewLoginGoogle2
	"Google federated login with OpenID"
	| authUrl |
	self site federatedAuthenticator 
		ifNil: [self page addText: 'OpenID authentication is off'. ^self].
	authUrl := self site federatedAuthenticator authenticationUrlForGoogle.
 	^self redirectTo: authUrl! !

!WebAdminApp methodsFor: 'views-federated login' stamp: 'janko 4/20/2012 17:43'!
viewLoginGoogle3
	"Google federated login with OpenID"
	| authenticator success registration |
	authenticator := self site federatedAuthenticator.
	success := authenticator authenticateAndLoginFromProviderRedirect: self session lastRequest.
	success ifTrue: 
		[self reportLogin.
		^self redirectTo: '/']. "existing user was logged-in successfully"
	registration := WebRegistrationApp aidaWebAppFor: self session.
	authenticator fillUser: registration newUser fromProviderRedirect: self session lastRequest.
	self redirectTo: WebRegistrationApp view: #mainGoogle! !

!WebAdminApp methodsFor: 'views-federated login' stamp: 'janko 4/20/2012 17:43'!
viewLogoutGoogle
	self session isLoggedIn ifTrue: 
		[self reportLogout.
		self session logout.
		self username: ''. self password: ''].
	^self redirectToView: #loginGoogle.! !


WebApplication subclass: #WebIndexApp
	instanceVariableNames: 'searchString results page'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!
!WebIndexApp commentStamp: '<historical>' prior: 0!
WebIndexApp for search form and viewing results from the search engine in website's WebIndex.
!


!WebIndexApp methodsFor: 'views-elements'!
abstractTextSize

	^400! !

!WebIndexApp methodsFor: 'views-elements'!
chopText: aString toSize: aNumber 
	| inStream outStream |
	inStream := aString readStream.
	outStream := WriteStream on: String new.
	1 to: aString size
		do: 
			[:count | 
			inStream atEnd ifTrue: [^outStream contents].
			(count >= aNumber and: [inStream peek = $ ]) 
				ifTrue: [^outStream contents , ' ...'].
			outStream nextPut: inStream next].
	^outStream contents

	"WebIndexApp new chopText: 'hojladri hojladra' toSize: 5"! !

!WebIndexApp methodsFor: 'views-elements'!
pageSelectionElement

	| element pages |
	element := WebElement new.
	pages := self results size = 0
		ifTrue: [0]
		ifFalse: [(self results size // self resultsOnPage) + 1].
	pages = 1 ifTrue: [^element].
	element addText: '<font face="helvetica, arial" size="-1">'.
	1 to: pages do: [:index |
		index = self page
			ifTrue: [element addTextBold: index printString]
			ifFalse: 
				[element add: 
					((WebLink text: index printString linkTo: self observee )
						view: #results;
						parameter: 'page' value: index printString)].
		element addNbSp ].
	element addText: '</font>'.
	^element! !

!WebIndexApp methodsFor: 'views-elements'!
resultNumberElement
	| e start end |
	e := WebElement new.
	(self results size = 0) ifTrue: [e addTextSmall: '<b>0 hits</b>'. ^e].
	(self results size = 1) ifTrue: [e addTextSmall: '<b>1 hit</b>'. ^e].
	start := (self page-1)*self resultsOnPage+1.
	(start+self resultsOnPage > self results size)
		ifTrue: [end := self results size]
		ifFalse: [end := start+self resultsOnPage-1].
	e cell addTextSmall: ('<b>', start printString, ' - ', end printString, ' from ', self results size printString, ' hits</b>').
	^e! !

!WebIndexApp methodsFor: 'views-elements'!
resultsElement
	"return a web element for search results"
	| e abstract objTitle modifiedText modifiedDate first last assoc |
	first := (self page - 1) * self resultsOnPage + 1.
	last := (first + self resultsOnPage - 1) min: self results size.
	e := WebList  newDefinition id: #searchRslts.
	first to: last do: [:index |
		assoc := self results at: index.
		objTitle := (assoc key class canUnderstand: #indexTitle) 
			ifTrue: [self boldify: assoc key indexTitle] ifFalse: [self chopText: assoc key indexText toSize: 50].
		abstract := (assoc key class canUnderstand: #indexAbstract) 
			ifTrue: [assoc key indexAbstract]
			ifFalse: [self chopText: assoc key indexText "trimNewlines" toSize: self abstractTextSize].
		modifiedText := ''.
		(assoc key class canUnderstand: #modified) ifTrue: 
			[modifiedDate := assoc key modified. modifiedDate notNil ifTrue: 
				[modifiedText := 'changed: <b> ', modifiedDate shortPrintSloString, '</b>,  '] ].
		e addDefinitionTerm: (WebElement new addText: (index printDotString, '.  ');
			addLinkTo: assoc key text: objTitle;
"			addLinkTo: self observee gif: #copyIconGif title: 'Copy to web clipboard' 
				view: #copyToClipboard parameter: 'uuid' value: assoc key hash asString; "yourself).
		e addDefinition: (WebElement new addText: abstract).
"
		e newCell color: self tableRowColor; addText: 
			('modifiedText, 'visits: <b>', 
			(self site urlResolver counterFor: assoc key) total printDotString, '</b>')
"
		].
	^e! !

!WebIndexApp methodsFor: 'views-elements'!
resultsOnPage
	^10! !


!WebIndexApp methodsFor: 'actions' stamp: ' 21/4/07 22:07'!
actionMain
	"search default web index for objects containing words from searchString, store results
   	in attribute results and st the next view as 'results' in order to print result web page"
	self results: (self observee objectsForWords: self searchString).
	self page: 1.
	self newView: #results! !

!WebIndexApp methodsFor: 'actions' stamp: ' 21/4/07 22:07'!
actionResults
	self actionMain! !

!WebIndexApp methodsFor: 'actions'!
actionResultsSearch
	"when page-wide search button is clicked"
	self searchString: self search. "copy from WebApplciation search in other"
	self actionMain! !


!WebIndexApp methodsFor: 'private'!
boldify: aString
	| bolded |
	bolded := aString.
	(self observee wordsInText: self searchString) keys do: [:word |
		bolded := self boldify: bolded withWord: word].
	^bolded

"WebIndexApp new 
	observee: WebIndex new;
	searchString: 'aida valid this'; 
	boldify: 'This is Aidalized world, validated' "! !

!WebIndexApp methodsFor: 'private'!
boldify: aString withWord: aWordString
	"make appearance of this word bold"
	| matchString in out wstream btag unbtag |
	matchString := aWordString, '*'.
	btag := '<b>'. unbtag := '</b>'.
	in := aString readStream. out := WriteStream on: String new.
	[in atEnd] whileFalse:
		[ [in atEnd not and: [in peek isSeparator]] whileTrue: [out nextPut: in next]. 
		wstream := in upToSeparator readStream. "next word as stream"
		(matchString match: wstream contents)
			ifTrue: [out nextPutAll: btag, (wstream next: aWordString size), unbtag, 
				(wstream next: wstream size - aWordString size) ] 
			ifFalse: [out nextPutAll: wstream contents].
		in atEnd ifFalse: [out space].
		].
	^out contents

"WebIndexApp new boldify: 'This is Aidalized world, validated' withWord: 'aida' "! !


!WebIndexApp methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initResults
	results := OrderedCollection new.! !


!WebIndexApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
page
	"return current result page number to show. Each page shows 10 hits"
	page isNil ifTrue: [self page: 1].
	^page! !

!WebIndexApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
page: aNumber

	page := aNumber.! !

!WebIndexApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
resultWithHash: aString
	"find an object in results with that hash value"
	^(self results detect: [:each | each key hash asString = aString] ifNone: [Association new]) key! !

!WebIndexApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
results
	"here the results of a search are stored."
	results isNil ifTrue: [self initResults].
	^results! !

!WebIndexApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
results: aCollection
	results := aCollection! !

!WebIndexApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
searchString
	searchString isNil ifTrue: [self searchString: ''].
	^searchString! !

!WebIndexApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
searchString: aString

	searchString := aString.! !


!WebIndexApp methodsFor: 'views'!
viewCopyToClipboard
	"put this refrence to web clipboard"
	| result |
	result := self resultWithHash: (self session lastRequest queryAt: 'uuid').
	result notNil ifTrue: [(result aidaWebAppFor: self session) copyToClipboard].
	^self redirectToView: #results "to have an url without view=paste"! !

!WebIndexApp methodsFor: 'views'!
viewMain
	"search directly then redirect to results"
	"Because Ajax redrection in WebPage does not support views"
	self results: (self observee objectsForWords: self searchString).
	self page: 1.
	self redirectToView: #results! !

!WebIndexApp methodsFor: 'views'!
viewResults
	| e |
	self page: (self session lastRequest queryAt: 'page' ifAbsent: [self page]) asInteger.
	self title: 'Search results'.
	e := WebElement new.
      e table width: 1. "100%"
	e cell addTextH1: self title. e newRow.
	e cell color: #thistle;
		addInputFieldAspect: #searchString for: self size: 40.
	(e cell addButtonText: 'Search')
		focus.
	e newRow. e cell add: self resultNumberElement.
	e newRow. e add: self resultsElement.
	e newRow.
	e cell align: #center; add: self pageSelectionElement.
	^self style pageFrameWith: e title: self title.! !


WebApplication subclass: #WebRegistrationApp
	instanceVariableNames: 'newUser password'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!
!WebRegistrationApp commentStamp: '<historical>' prior: 0!
WebRegistrationApp is a standalone app (without link to domain model) for the registration process of a new user!


!WebRegistrationApp methodsFor: 'actions' stamp: 'janko 4/20/2012 18:21'!
actionActivate
	"goto user's profile"
	self user setRegisteredTimestamp.
	self sendRegistrationReport. "to the admin of website"
	self reportRegistration. "to transcript"
	self redirectTo: self user view: #main "user profile"! !

!WebRegistrationApp methodsFor: 'actions' stamp: 'janko 4/20/2012 18:21'!
actionActivateGoogleMentor
	self actionActivateMentor! !

!WebRegistrationApp methodsFor: 'actions' stamp: 'janko 4/20/2012 18:21'!
actionActivateGoogleStudent
	self actionActivateStudent! !

!WebRegistrationApp methodsFor: 'actions'!
actionActivateMentor
	"GSoC: put user to Mentors group"
	self site securityManager mentorsGroup addUser: self user.
	self actionActivate! !

!WebRegistrationApp methodsFor: 'actions'!
actionActivateStudent
	"GSoC: put user to Students group"
	self site securityManager studentsGroup addUser: self user.
	self actionActivate! !

!WebRegistrationApp methodsFor: 'actions'!
actionMain
	self context form isValid ifFalse: 
		[self showError: self context form collectErrorTexts. 
		^self redirectToView: #main].
	self site securityManager addActivatingUser: self newUser.
	self sendActivationRequest.
	self redirectToView: #activationRequest.! !

!WebRegistrationApp methodsFor: 'actions'!
checkActivateAndLoginFromRequest
	"return true if succefull. Also login if not already"
	| uuid user |
	uuid := self context request queryAt: 'uuid' ifAbsent: [^false].
	user := self site securityManager userWithUuid: uuid.
	(user isNil or: [user inActivatingGroup not]) ifTrue: [^false].
	self site securityManager addRegisteredUser: user.
	self site securityManager activatingGroup removeUser: user.
	self session isLoggedIn ifFalse: [self session loginUser: user].
	^true! !


!WebRegistrationApp methodsFor: 'actions-federated reg.' stamp: 'janko 4/20/2012 18:19'!
actionMainGoogle
	self context form isValid ifFalse: 
		[self showError: self context form collectErrorTexts. 
		^self redirectToView: #mainGoogle].
	self site securityManager addActivatingUser: self newUser.
	self redirectToView: #activateGoogle.! !

!WebRegistrationApp methodsFor: 'actions-federated reg.' stamp: 'janko 4/20/2012 18:19'!
checkActivateAndLoginFederated
	"return true if succefull. Also login if not already"
	self newUser inActivatingGroup ifFalse: [^false].
	self site securityManager addRegisteredUser: self newUser.
	self site securityManager activatingGroup removeUser: self newUser.
	self session isLoggedIn ifFalse: [self session loginUser: self newUser].
	^true! !


!WebRegistrationApp methodsFor: 'emailing'!
activationRequestMessage
	| text |
	text := 'Please click on the link below to activate your account on http://', self site host, '

', (self site urlResolver fullUrlFor: self class on: nil), '?view=activate&uuid=', self newUser uuid.
	^text! !

!WebRegistrationApp methodsFor: 'emailing'!
registrationReportMessage
	| text |
	text := 'New user just registered on http://', self site host, ':

	name:       ', self user nameSurname, '
	username:   ', self user username, '
	country:    ', self user country, '
	email:      ', self user email, '
	profile:    ', (self site urlResolver fullUrlFor: self user on: nil).
	^text! !

!WebRegistrationApp methodsFor: 'emailing'!
sendActivationRequest
	self site messenger 
		sendSubject: ('Activation request on ', self site host)
		body: self activationRequestMessage
		from: self site webServerEMail to: self newUser email! !

!WebRegistrationApp methodsFor: 'emailing'!
sendRegistrationReport
	self site messenger 
		sendSubject: ('New user registered: ', self user nameSurname)
		body: self registrationReportMessage
		from: self site webServerEMail to: self site webServerEMail! !


!WebRegistrationApp methodsFor: 'private'!
aidaDontCache
	^true "to properly handle back button"! !

!WebRegistrationApp methodsFor: 'private'!
newUser: aWebUser
	newUser := aWebUser! !

!WebRegistrationApp methodsFor: 'private'!
reportRegistration
	"to transcript only"
	Transcript cr; show: 'registered: ', self session user nameSurname asSloveneWithoutCircumflexes, 
	' on ', self site name,
	' at ', 
 	Date today dayOfMonth printString, '.',
	Date today monthIndex printString, ' ',
	Time now hours printString, ':', 
	Time now minutes printString,
	' from ', self session lastRequest realPeerIp! !


!WebRegistrationApp methodsFor: 'views'!
alreadyLoggedIn
	| e |
	e := WebElement new.
	self title: 'Registration form, step 1/', self nrOfSteps printString.
	e cell addTextH1: self title. e newRow.
	e cell addText: 'You are already registered and logged in!!'.
	self style pageFrameWith: e title: self title! !

!WebRegistrationApp methodsFor: 'views'!
registrationNotAllowed
	| e |
	e := WebElement new.
	self title: 'Registration form, step 1/', self nrOfSteps printString.
	e cell addTextH1: self title. e newRow.
	e cell addText: 'Registration is currently not allowed on this site!!'.
	self style pageFrameWith: e title: self title! !

!WebRegistrationApp methodsFor: 'views'!
viewActivate
	| e |
	e := WebElement new.
	self title: 'Activation confirmation, step 3/', self nrOfSteps printString.
	e cell addTextH1: self title. e newRow.
	self checkActivateAndLoginFromRequest
		ifFalse: [e cell addText: 'Activation unsuccesfull!! Did you already activate your account?']
		ifTrue: 
			[e cell addText: self style registrationActivatedMessage. e newRow.
			e cell addRuler. e newRow.
"			e cell addButtonText: 'Next'.  "
			e cell addButtonText: 'I''m a Student' action: #student. e cell addSpace. "GSoC"
			e cell addButtonText: 'I''m a Mentor' action: #mentor. e cell addSpace.
			e cell addRuler. e newRow].
	self style pageFrameWith: e title: self title! !

!WebRegistrationApp methodsFor: 'views'!
viewActivationRequest
	| e |
	e := WebElement new.
	self title: 'Activation request, step 2/', self nrOfSteps printString.
	e cell addTextH1: self title. e newRow.
	e cell addText: self style registrationActivationRequestMessage.
	self style pageFrameWith: e title: self title.
	self initNewUser! !

!WebRegistrationApp methodsFor: 'views' stamp: 'janko 4/20/2012 18:24'!
viewMain
	| e field |
	self site registrationAllowed ifFalse: [^self registrationNotAllowed].
	self session isLoggedIn ifTrue: [^self alreadyLoggedIn].
	e := WebElement new.
	self title: 'Registration form, step 1/', self nrOfSteps printString.
	e cell colspan: 3; addTextH1: self title. e newRow.
	self style registrationIntroductionMessage notEmpty ifTrue:
		[e cell colspan: 3; addText: self style registrationIntroductionMessage. e newRow.
		e cell colspan: 3; addRuler. e newRow].
	self inError ifTrue: [e cell colspan:3; add: self errorReport. e newRow].
	e cell addText: 'First name: '.
	field := e newCell addInputFieldAspect: #name for: self newUser. e newRow.
	field 
		validIfTrue: [:value | value trimBlanks notEmpty];
		errorText: 'First name is needed'.
	e cell addText: 'Second name: '.
	field := e newCell addInputFieldAspect: #surname for: self newUser. e newRow.
	field 
		validIfTrue: [:value | value trimBlanks notEmpty];
		errorText: 'Second name is needed'.
	e cell addText: 'Country: '.
	e newCell addInputFieldAspect: #country for: self newUser. e newRow.
	e cell addText: 'Valid email: '.
	field := e newCell addInputFieldAspect: #email for: self newUser.
	field
		validIfTrue: [:value | self isValidEMail: value];
		errorText: 'Email not valid!!'.
	e newRow.
	e cell colspan: 3; addRuler. e newRow.
	e cell addText: 'Username: '.
	field := e newCell addInputFieldAspect: #username for: self newUser. e newRow.
	field
		validIfTrue: [:value | self isUniqueUsername: value];
		errorText: 'User with that username already exist!!'.
	e cell addText: 'Password: '.
	(e newCell addPasswordFieldAspect: #password for: self newUser) onChangePost. e newRow.
	e cell addText: 'Confirm password: '.
	field := e newCell addPasswordFieldAspect: #password for: self.
	field
		validIfTrue: [:value | self isSamePassword: value];
		errorText: 'Passwords not equal!!'.
	e newRow.
	e cell colspan: 3; addRuler. e newRow.
	e cell addButtonText: 'Next'.
	e cell colspan: 3; addRuler.
	self style pageFrameWith: e title: self title! !


!WebRegistrationApp methodsFor: 'initialize-release'!
initNewUser
	"a fresh new user for a registration"
	newUser := self site webUserClass new.
	self password: ''! !

!WebRegistrationApp methodsFor: 'initialize-release'!
initialize
	self initNewUser! !


!WebRegistrationApp methodsFor: 'validation'!
isSamePassword: aString
	^(self context form bufferedValueAspect: #password for: self newUser) = aString! !

!WebRegistrationApp methodsFor: 'validation'!
isUniqueUsername: aString
	^(self site securityManager userNamed: aString) isNil! !

!WebRegistrationApp methodsFor: 'validation'!
isValidEMail: aString
	(aString includes: $@) ifFalse: [^false].
	^true! !


!WebRegistrationApp methodsFor: 'accessing'!
newUser
	^newUser! !

!WebRegistrationApp methodsFor: 'accessing'!
nrOfSteps
	^4! !

!WebRegistrationApp methodsFor: 'accessing'!
password
	"confirm password"
	password isNil ifTrue: [^''].
	^password! !

!WebRegistrationApp methodsFor: 'accessing'!
password: aString
	password := aString! !


!WebRegistrationApp methodsFor: 'views-federated reg.' stamp: 'janko 4/20/2012 18:20'!
viewActivateGoogle
	| e |
	e := WebElement new.
	self title: 'Registereing as Student or Mentor?, step 2/2'.
	e cell addTextH1: self title. e newRow.
	self checkActivateAndLoginFederated
		ifFalse: [e cell addText: 'Activation unsuccesfull!! Did you already activate your account?']
		ifTrue: 
			[e cell addText: self style registrationActivatedMessage. e newRow.
			e cell addRuler. e newRow.
"			e cell addButtonText: 'Next'.  "
			e cell addButtonText: 'I''m a Student' action: #student. e cell addSpace. "GSoC"
			e cell addButtonText: 'I''m a Mentor' action: #mentor. e cell addSpace.
			e cell addRuler. e newRow].
	self style pageFrameWith: e title: self title! !

!WebRegistrationApp methodsFor: 'views-federated reg.' stamp: 'janko 4/20/2012 18:20'!
viewMainGoogle
	| e field |
	self site registrationAllowed ifFalse: [^self registrationNotAllowed].
	self session isLoggedIn ifTrue: [^self alreadyLoggedIn].
	e := WebElement new.
	self title: 'Registration form, step 1/2'.
	e cell colspan: 3; addTextH1: self title. e newRow.
	self style registrationIntroductionMessage notEmpty ifTrue:
		[e cell colspan: 3; addText: self style registrationIntroductionMessage. e newRow.
		e cell colspan: 3; addRuler. e newRow].
	self inError ifTrue: [e cell colspan:3; add: self errorReport. e newRow].
	e cell addText: 'First name: '.
	field := e newCell addInputFieldAspect: #name for: self newUser. e newRow.
	field 
		validIfTrue: [:value | value trimBlanks notEmpty];
		errorText: 'First name is needed'.
	e cell addText: 'Second name: '.
	field := e newCell addInputFieldAspect: #surname for: self newUser. e newRow.
	field 
		validIfTrue: [:value | value trimBlanks notEmpty];
		errorText: 'Second name is needed'.
	e cell addText: 'Country: '.
	e newCell addInputFieldAspect: #country for: self newUser. e newRow.
	e cell addText: 'Email: '.
	field := e newCell addInputFieldAspect: #email for: self newUser.
	field
		validIfTrue: [:value | self isValidEMail: value];
		errorText: 'Email not valid!!'.
	e newRow.
	e cell colspan: 3; addRuler. e newRow.
	e cell addButtonText: 'Next'.
	e cell colspan: 3; addRuler.
	self style pageFrameWith: e title: self title! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebRegistrationApp class
	instanceVariableNames: ''!

!WebRegistrationApp class methodsFor: 'instance creation'!
new
	^super new initialize! !


WebApplication subclass: #WebSecurityManagerApp
	instanceVariableNames: 'users usersToRemove groups groupsToRemove usr group aclObject aclForWho object grid'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!
!WebSecurityManagerApp commentStamp: '<historical>' prior: 0!
WebSecurityManagerApp for security setup - users and groups and their access rights. See also WebSecurityManager.
!


!WebSecurityManagerApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
aclForWho
	^aclForWho! !

!WebSecurityManagerApp methodsFor: 'accessing' stamp: 'np 3/25/2009 15:20'!
aclForWho: anUserOrGroup
	aclForWho := anUserOrGroup! !

!WebSecurityManagerApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
aclObject
	^aclObject! !

!WebSecurityManagerApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
aclObject: anObject
	aclObject := anObject! !

!WebSecurityManagerApp methodsFor: 'accessing'!
aidaDontCache
	"always refresh pages, to deal with back button correctly"
	^true! !

!WebSecurityManagerApp methodsFor: 'accessing'!
allowedIPs
	"converted to string of addresses, each in new line, no comma needed"
	^self observee allowedIPs inject: '' into: [:text :ipString || separator | 
		separator := (ipString = self observee allowedIPs last)
			ifTrue: [''] ifFalse: [(String with: Character cr)].
		text, ipString, separator].! !

!WebSecurityManagerApp methodsFor: 'accessing'!
allowedIPs: aString
	"converted to string of addresses, each in new line, no comma needed"
	| col stream ipString |
	col := OrderedCollection new.
	stream := aString readStream.
	[stream atEnd] whileFalse:
		[ipString := (stream upTo: Character lf) trimBlanks.
		ipString notEmpty ifTrue: [col add: ipString] ].
	self observee allowedIPs: col! !

!WebSecurityManagerApp methodsFor: 'accessing'!
grid
    "an element (grid etc.) to update"
	^grid! !

!WebSecurityManagerApp methodsFor: 'accessing'!
grid: aWebElement
	grid := aWebElement! !

!WebSecurityManagerApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
group
	^group! !

!WebSecurityManagerApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
group: anObject
	group := anObject! !

!WebSecurityManagerApp methodsFor: 'accessing'!
groups
	"initial collection of groups before starting to remove them"
	^groups! !

!WebSecurityManagerApp methodsFor: 'accessing'!
groups: aCollection
	groups := aCollection! !

!WebSecurityManagerApp methodsFor: 'accessing'!
groupsToRemove
	groupsToRemove isNil ifTrue: [groupsToRemove := Set new].
	^groupsToRemove! !

!WebSecurityManagerApp methodsFor: 'accessing'!
object
	"object to edit"
	^object! !

!WebSecurityManagerApp methodsFor: 'accessing'!
object: anObject
	"object to edit"
	object := anObject! !

!WebSecurityManagerApp methodsFor: 'accessing'!
users
	"initial collection of users before starting to remove them"
	^users! !

!WebSecurityManagerApp methodsFor: 'accessing'!
users: aCollection
	users := aCollection! !

!WebSecurityManagerApp methodsFor: 'accessing'!
usersToRemove
	usersToRemove isNil ifTrue: [usersToRemove := Set new].
	^usersToRemove! !

!WebSecurityManagerApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
usr
	"temporary user"
	^usr! !

!WebSecurityManagerApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
usr: aWebUser
	usr := aWebUser! !


!WebSecurityManagerApp methodsFor: 'printing-users groups'!
aclForWhoElement
	| e aclObjects ident |
	e := WebElement new.
	(self aclForWho isKindOf: WebUser)
		ifTrue: [e addTextH2: 'User: ', self aclForWho someId]
		ifFalse: [e addTextH2: 'Group: ', self aclForWho name].
	aclObjects := WebApplication allWebAppClasses.
	aclObjects do: [:app || bold |
		ident := WebElement new.
		app appClassLevel timesRepeat: [ident addNbSp: 4].
		e add: ident.
		app allViews notEmpty 
			ifTrue:
				[bold := (self observee isAclSetFor: self aclForWho on: app)   "emphasise those with Acl set"
					ifTrue: ['<b>'] ifFalse: ['']. 
				e add: ((WebLink  text: bold, app name asString, '</b>' linkTo: self observee)
					view: #aclObject; parameter: 'index' value: (aclObjects indexOf: app) printString)]
			ifFalse: [e addText: app name asString].
		e addBreak].
	^e! !

!WebSecurityManagerApp methodsFor: 'printing-users groups'!
groupsGridElement
	^ (WebGrid new width: self style pageContentWidth)
		columnNames: #(nil 'Group name' nil 'Members');
		columnAspects: #(nil name nil nil );
		columnLinkViews: #(nil main nil);
		collection: (self observee allGroups asSortedCollection: [:g1 :g2 | g1 name < g2 name]);
		column: 3 addBlock: [:each | each isLocked 
			ifTrue: [self lockIconTitled: 'Group locked for name change and delete'] ifFalse: [WebElement new] ];
		column: 4 addBlock: [:each | self usersInGroupElementFor: each];
		columnFilters: #(nil true nil);
		setNumbering;
		rowsOnPage: 20;
		yourself! !

!WebSecurityManagerApp methodsFor: 'printing-users groups'!
groupsOfUserElementFor: anUser
	| e |
	e := WebElement new.
	(anUser groups asSortedCollection: [:g1 :g2 | g1 name < g2 name]) 
		do: [:each | e addLinkTo: each text: each name]
		separatedBy: [e addText: ', '].
	^e! !

!WebSecurityManagerApp methodsFor: 'printing-users groups'!
groupsRemovalElement
	self groups: self observee allGroups.  "initial collection, needed in #removeOrUndoGroups too"
	^ (WebGrid new width: self style pageContentWidth)
		columnNames: #(nil nil 'Group name');
		columnAspects: #(nil nil name);
		columnLinkViews: #(nil nil main);
		columnFilters: #(nil nil true);
		column: 2 addBlock: [:grp | grp isLocked not
			ifTrue: [(WebCheckBox newForObject: grp from: self groupsToRemove) 
					onChangePostAndDo: [ self removeOrUndoGroup] ]
			ifFalse: [self lockIconTitled: 'This group is locked for changes and delete'] ]; 
		collection: (self groups asSortedCollection: [:g1 :g2 | g1 name < g2 name]);
		setNumbering;
		rowsOnPage: 20;
		yourself! !

!WebSecurityManagerApp methodsFor: 'printing-users groups'!
usersGridElement
	^ (WebGrid new width: self style pageContentWidth)
		columnNames: #(nil 'Name' 'Username' nil 'Groups');
		columnAspects: #(nil nameSurname username nil nil);
		columnLinkViews: #(nil main main nil nil);
		collection: (self observee users asSortedCollection: [:u1 :u2 | u1 nameSurname < u2 nameSurname]);
		column: 4 addBlock: [:each | each isLocked 
			ifTrue: [self lockIconTitled: 'User locked for change and delete'] ifFalse: [WebElement new] ];
		column: 5 addBlock: [:each | self groupsOfUserElementFor: each];
		columnFilters: #(nil true true nil);
		setNumbering;
		rowsOnPage: 20;
		yourself! !

!WebSecurityManagerApp methodsFor: 'printing-users groups'!
usersInGroupElementFor: aGroup
	| e |
	e := WebElement new.
	(aGroup allUsers asSortedCollection: [:u1 :u2 | u1 nameSurname < u2 nameSurname]) 
		do: [:each | e addLinkTo: each text: each nameSurname]
		separatedBy: [e addText: ', '].
	^e! !

!WebSecurityManagerApp methodsFor: 'printing-users groups'!
usersRemovalElement
	self users: self observee allUsers.  "initial collection, needed in #removeOrUndoUsers too"
	^ (WebGrid new width: self style pageContentWidth)
		columnNames: #(nil nil 'Username' 'Name');
		columnAspects: #(nil nil username nameSurname);
		columnLinkViews: #(nil nil main main);
		columnFilters: #(nil nil true true);
		column: 2 addBlock: [:useer | useer isLocked not
			ifTrue: [(WebCheckBox newForObject: useer from: self usersToRemove) 
					onChangePostAndDo: [ self removeOrUndoUser] ]
			ifFalse: [self lockIconTitled: 'This user is locked for changes and delete'] ]; 
		collection: (self users asSortedCollection: [:u1 :u2 | u1 username < u2 username]);
		setNumbering;
		rowsOnPage: 20;
		yourself! !


!WebSecurityManagerApp methodsFor: 'actions' stamp: 'mivsek 6/12/2007 23:20'!
actionAddGroup
	self group ~= '' ifTrue: [self observee addGroup: self group].
	self newView: #groups.! !

!WebSecurityManagerApp methodsFor: 'actions' stamp: 'mivsek 3/7/2008 19:22'!
actionAddUser
	self usr ~= '' ifTrue: [self observee addUser: self usr].
	self newView: #users.! !

!WebSecurityManagerApp methodsFor: 'actions'!
removeOrUndoGroup
	"remove checked, undo/add back unchecked again"
	| currentGroups toRemove toUndo |
	currentGroups := self observee allGroups asSet.
	toRemove := currentGroups select: [:each | groupsToRemove includes: each].
	toUndo := (self "inital" groups reject: [:each | currentGroups includes: each]) "already removed"
				reject: [:each | groupsToRemove includes: each]. "to get unchecked ones"
	toRemove do: [:each | observee removeGroup: each].
	toUndo do: [:each | self observee addGroup: each].! !

!WebSecurityManagerApp methodsFor: 'actions' stamp: 'janko 8/6/2011 19:44'!
removeOrUndoUser
	"remove checked, undo/add back unchecked again"
	| currentUsers toRemove toUndo |
	currentUsers := self observee allUsers asSet.
	toRemove := currentUsers select: [:each | usersToRemove includes: each].
	toUndo := (self "inital" users reject: [:each | currentUsers includes: each]) "already removed"
				reject: [:each | usersToRemove includes: each]. "to get unchecked ones"
	toRemove do: [:each | 
		each otherAt: #WasInGroups put: each groups.
		self observee removeUser: each].
	toUndo do: [:each | 
		self observee addUser: each.
		(each otherAt: #WasInGroups) do: [:grp | grp addUser: each] ]. "reconstruct group membership"! !


!WebSecurityManagerApp methodsFor: 'views-aidaGroup'!
actionsForMember: anAidaGroupMember
	| e |
	e := WebElement new.
	self object: anAidaGroupMember.
	(e addNilLinkText: #en->'<small>edit</small>')	
		onClickPopup: self editAidaGroupMemberPopup thenUpdate: self grid. 
	e addTextSmall: ' | '.
	(e addNilLinkText: #en->'<small>delete</small>')	
		onClickPopup: (WebDialog newConfirm
			text: #en->('Really delete member site <b>', 
					anAidaGroupMember siteName, 
					'</b>  from AidaGroup?');
			ifTrue: [self observee site group members remove: anAidaGroupMember])
		thenUpdate: self grid.
	^e! !

!WebSecurityManagerApp methodsFor: 'views-aidaGroup'!
addAidaGroupMemberPopup
	| e field1 new field2 |
	e := WebElement newDiv.
	new := AidaGroupMember new.
	e cell addText: #en->'Site name: '. 
	field1 := e newCell align: #left;  addInputFieldAspect: #siteName for: new size: 20.
	field1 focus; onChangePost.
	e newRow.
	e cell addText: #en->'Site URL: '. 
	field2 := e newCell addInputFieldAspect: #url for: new size: 40.
	field2 onChangePost.
	e newRow.
	(e cell  addButtonText: #en->'Add group member')
		class: #'dialog-button';
		onClickDo: [self observee site group addMember: new ];
		onClickClose.
	(e cell  addButtonText: #en->'Cancel')
		class: #'dialog-button';
		onClickClose.
	^e! !

!WebSecurityManagerApp methodsFor: 'views-aidaGroup'!
aidaGroupElement
	self grid: ((WebGrid new width: self style pageContentWidth)
		columnNames: #(nil 'site name' 'site url');
		columnAspects: #(nil siteName url);
		columnLinkViews: #(nil nil nil);
		collection: self observee site group members;
		column: 4 addBlock: [:member | self actionsForMember: member ];
		setNumbering;
		yourself).
	^self grid! !

!WebSecurityManagerApp methodsFor: 'views-aidaGroup'!
editAidaGroupMemberPopup
	| e field1 field2 |
	e := WebElement newDiv.
	e cell addText: #en->'Site name: '. 
	field1 := e newCell align: #left; addInputFieldAspect: #siteName for: self object size: 20.
	field1 focus; onChangePost.
	e newRow.
	e cell addText: #en->'Site URL: '. 
	field2 := e newCell addInputFieldAspect: #url for: self object size: 40.
	field2 onChangePost.
	e newRow.
	(e cell  addButtonText: #en->'Close')
		class: #'dialog-button';
		onClickClose.
	^e! !


!WebSecurityManagerApp methodsFor: 'printing-access control'!
allYesNoLinks
	| e |
	e := WebElement new.
	e
		addText: 'all views: ';
		addLinkTo: self observee text: ' YES ' view: #aclObject parameter: 'allViews' value: 'YES';
		add: ((WebLink text: ' NO ' linkTo: self observee)
			view: #aclObject;
			parameter: 'allViews' value: 'NO');
		addText: 'all updates: ';
		add: ((WebLink text: ' YES ' linkTo: self observee)
			view: #aclObject;
			parameter: 'allUpdates' value: 'YES');
		add: ((WebLink text: ' NO ' linkTo: self observee)
			view: #aclObject;
			parameter: 'allUpdates' value: 'NO');
		addText: 'all encrypted: ';
		add: ((WebLink text: ' YES ' linkTo: self observee)
			view: #aclObject;
			parameter: 'allEncrypted' value: 'YES');
		add: ((WebLink text: ' NO ' linkTo: self observee)
			view:  #aclObject;
			parameter: 'allEncrypted' value: 'NO').
	^e! !

!WebSecurityManagerApp methodsFor: 'printing-access control'!
checkAccessRight: aSymbol
	"if YES or NO is pressed for a #view or #update method in aclObjectPage, then set or reset a view
	access rights for current user or group, web app and view symbol"
	| right command |
	(self session lastRequest includesQuery: 'right') 
		ifTrue: [right := (self session lastRequest queryAt: 'right')].
	aSymbol = #view
		ifTrue:
			[(self session lastRequest includesQuery: 'viewRight') 
				ifTrue: [command := (self session lastRequest queryAt: 'viewRight')] ]
		ifFalse:
			[(self session lastRequest includesQuery: 'updateRight') 
				ifTrue: [command := (self session lastRequest queryAt: 'updateRight')] ].
	
	command = 'YES' ifTrue: 
		[self observee 
			setAccessRights: 
				(aSymbol = #view
					ifTrue: [aclObject viewRightSymbolFor: right asSymbol]
					ifFalse:  [aclObject updateRightSymbolFor: right asSymbol])
			for: aclForWho 
			on: self aclObject name].
	command = 'NO' ifTrue: 
		[self observee 
			removeAccessRights: 
				(aSymbol = #view
					ifTrue: [aclObject viewRightSymbolFor: right asSymbol]
					ifFalse:  [aclObject updateRightSymbolFor: right asSymbol])
			for: aclForWho 
			on: self aclObject name].! !

!WebSecurityManagerApp methodsFor: 'printing-access control' stamp: 'np 10/22/2008 16:56'!
checkAllYesNo
	"if YES or NO is pressed for a #view or #update method in aclObjectPage, then set or reset a view
	access rights for current user or group, web app and view symbol"
	| yesNo |
	(self session lastRequest includesQuery: 'allViews') 
		ifTrue: 
			[yesNo := (self session lastRequest queryAt: 'allViews').
			self aclObject allViews do: [:each |
				yesNo = 'YES'
					ifTrue: 
						[self observee
							setAccessRights: (aclObject viewRightSymbolFor: each)
							for: aclForWho 
							on: self aclObject name]
					ifFalse: 
						[self observee
							removeAccessRights: (aclObject viewRightSymbolFor: each)
							for: aclForWho 
							on: self aclObject name] ] ].
	(self session lastRequest includesQuery: 'allUpdates') 
		ifTrue: 
			[yesNo := (self session lastRequest queryAt: 'allUpdates').
			self aclObject allViews do: [:each |
				(aclObject actionMethodForView: each) notNil ifTrue: 
					[yesNo = 'YES'
						ifTrue: 
							[self observee
								setAccessRights: (aclObject updateRightSymbolFor: each)
								for: aclForWho 
								on: self aclObject name]
						ifFalse: 
							[self observee
								removeAccessRights: (aclObject updateRightSymbolFor: each)
								for: aclForWho 
								on: self aclObject name] ] ] ].
	(self session lastRequest includesQuery: 'allEncrypted') 
		ifTrue: 
			[yesNo := (self session lastRequest queryAt: 'allEncrypted').
			self aclObject allViews do: [:each |
				yesNo = 'YES'
					ifTrue: [self observee
						setAccessRights: (aclObject encryptSymbolFor: each)
						for: aclForWho 
						on: self aclObject name]
					ifFalse: 	[self observee
						removeAccessRights: (aclObject encryptSymbolFor: each)
						for: aclForWho 
						on: self aclObject name]  ] ].! !

!WebSecurityManagerApp methodsFor: 'printing-access control' stamp: 'np 10/22/2008 16:56'!
checkIfEncrypted
	| right  command |
	(self session lastRequest includesQuery: 'right') 
		ifTrue: [right := (self session lastRequest queryAt: 'right')].
	(self session lastRequest includesQuery: 'encrypt') 
 		ifTrue: [command := (self session lastRequest queryAt: 'encrypt')].
	command = 'YES' ifTrue: 
		[self observee 
			setAccessRights: (aclObject encryptSymbolFor: right)
			for: aclForWho 
			on: self aclObject name].
	command = 'NO' ifTrue: 
		[self observee 
			removeAccessRights: (aclObject encryptSymbolFor: right)
			for: aclForWho 
			on: self aclObject name].! !

!WebSecurityManagerApp methodsFor: 'printing-access control' stamp: 'np 10/22/2008 16:50'!
needsEncryption: aViewSymbol
	^self observee 
		has: self aclForWho
		rightTo: (aclObject encryptSymbolFor: aViewSymbol)
		on: self aclObject name! !

!WebSecurityManagerApp methodsFor: 'printing-access control' stamp: ' 21/4/07 22:07'!
negate: yesNoString

		yesNoString = 'YES' ifTrue: [^'NO'] ifFalse: [^'YES'].! !

!WebSecurityManagerApp methodsFor: 'printing-access control' stamp: 'np 10/22/2008 16:50'!
updateAllowedFor: aViewSymbol
	^self observee 
		has: self aclForWho
		rightTo: (aclObject updateRightSymbolFor: aViewSymbol)
		on: self aclObject name! !

!WebSecurityManagerApp methodsFor: 'printing-access control'!
updateInOneGroupAllowedFor: aViewSymbol
	^self observee 
		hasUser: self aclForWho
		rightInAnyGroupTo: (aclObject class updateRightSymbolFor: aViewSymbol)
		on: self aclObject name! !

!WebSecurityManagerApp methodsFor: 'printing-access control' stamp: 'np 10/22/2008 16:50'!
viewAllowedFor: aViewSymbol
	^self observee 
		has: self aclForWho
		rightTo: (aclObject viewRightSymbolFor: aViewSymbol)
		on: self aclObject name! !

!WebSecurityManagerApp methodsFor: 'printing-access control' stamp: 'np 10/22/2008 16:50'!
viewInOneGroupAllowedFor: aViewSymbol
	^self observee 
		hasUser: self aclForWho
		rightInAnyGroupTo: (aclObject viewRightSymbolFor: aViewSymbol)
		on: self aclObject name! !


!WebSecurityManagerApp methodsFor: 'printing-elements'!
filtersElement
	| e |
	e := WebElement new. e table width: 1.
	e cell colspan: 2; addText: 'Only user Admin allowed to change filters!!'. e newRow.
	e newRow. e newRow.
	e cell width: 0.3; valign: #top; addText: 'IP addresses, allowed to login: <br> <small>(one IP per line, no commas, patterns with * allowed, like 188.45.34.* )</small>'.
	(e newCell addTextAreaAspect: #allowedIPs for: self size: 20@4)
		onChangePost.
	^e! !

!WebSecurityManagerApp methodsFor: 'printing-elements'!
hierarchyLinksElement
	| e ttext |
	e := WebElement new.
	e addText: self site name, ' / '.
	e addLinkTo: self observee text: #en->'Security'.
	e addText: ' / '.
	(#(users addUser removeUsers) includes: self view) ifTrue: [ttext := #en->'<b>Users</b>'].
	(#(groups addGroup removeGroup) includes: self view) ifTrue: [ttext := #en->'<b>Groups</b>'].
	(#(filters) includes: self view) ifTrue: [ttext := #en->'<b>Filters</b>'].
	e addLinkTo: self observee text: ttext view: self view.
	^e! !

!WebSecurityManagerApp methodsFor: 'printing-elements'!
lockIconTitled: aString
	| e |
	e := WebElement new.
	e addNbSp; add:
		((WebImage png: #lockSmallPng) title: aString).
	^e! !


!WebSecurityManagerApp methodsFor: 'printing' stamp: 'np 3/25/2009 15:20'!
setAclForWhoFromRequest
	"who can be user or group"
	| uuid user |
	uuid := self session lastRequest queryAt: 'who'.
	user := self observee userWithUuid: uuid.
	self aclForWho: (user notNil 
		ifTrue: [user] 
		ifFalse: [self observee groupWithUuid: uuid]).! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewAclObject
	| e index aclRights actionMethod yesNo |
	(self session lastRequest includesQuery: 'index') 
		ifTrue: 
			[index := (self session lastRequest queryAt: 'index').
			self aclObject: (WebApplication allWebAppClasses at: index asInteger)].
	self checkAccessRight: #view.
	self checkAccessRight: #update.
	self checkIfEncrypted.
	self checkAllYesNo.
	self title: 'Access Rigths for: ', self aclObject name asString.
	e := WebElement new.
	e addTextH1: self title.
	(self aclForWho isKindOf: WebUser)
		ifTrue: [e addTextH2: 'User: ', self aclForWho someId]
		ifFalse: [e addTextH2: 'Group: ', self aclForWho name].
	e add: self allYesNoLinks.
	aclRights := SortedCollection withAll: self aclObject allViews sortBlock: [:a : b | a < b]. 
	e table border: 1.
	e cell addText: 'view'.
	e newCell colspan: 2; addText: 'view right'.
	e newCell colspan: 2; addText: 'update right'.
	e newCell addText: 'encrypt'. e newRow.
	aclRights do: [:right |
		e cell addText: right asString attributes: #bold.
		e newCell addText: (self aclObject viewMethodForView: right asSymbol) asString.
		(self viewAllowedFor: right) ifTrue: [yesNo := 'YES'] ifFalse: [yesNo := 'NO'].
		e newCell
			add: ((WebLink  text: ('<b>', yesNo) linkTo: self observee)
				view: #aclObject;
				parameter: 'right' value: right asString;
				parameter: 'viewRight' value: (self negate: yesNo)).
		(self aclForWho = 'user') ifTrue: 
			[(self viewInOneGroupAllowedFor: right) ifTrue: [yesNo := 'YES'] ifFalse: [yesNo := 'NO'].
			e newCell addText: ('<font size=-1>', yesNo)].

		actionMethod := (self aclObject actionMethodForView: right asSymbol).
		e newCell
			addText: (actionMethod notNil ifTrue: [actionMethod asString] ifFalse: ['<br>']).
		(self updateAllowedFor: right) ifTrue: [yesNo := 'YES'] ifFalse: [yesNo := 'NO'].
		actionMethod notNil
			ifTrue: 
				[e newCell
					add: ((WebLink  text: ('<b>', yesNo) linkTo: self observee)
						view:  #aclObject;
						parameter: 'right' value: right asString;
						parameter: 'updateRight' value: (self negate: yesNo)).
				(self aclForWho = 'user') ifTrue: 
					[(self viewInOneGroupAllowedFor: right) 
						ifTrue: [yesNo := 'YES'] ifFalse: [yesNo := 'NO'].
					e newCell addText: ('<font size=-1>', yesNo)] ]
			ifFalse:
				[e newCell addText: '<br>'].
			(self needsEncryption: right) ifTrue: [yesNo := 'YES'] ifFalse: [yesNo := 'NO'].
		e newCell align: #center;
			add: ((WebLink  text: ('<b>', yesNo) linkTo: self observee)
				view: #aclObject;
				parameter: 'right' value: right asString;
				parameter: 'encrypt' value: (self negate: yesNo)).
		e newRow].

	self style pageFrameWith: e title: self title! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewAclObjects
	| e |
	(self session lastRequest includesQuery: 'who') ifFalse: [^self redirectToView: #main].
	self setAclForWhoFromRequest.
	self aclForWho isNil ifTrue: [^self redirectToView: #main].
	self title: 'Access Rigths'.
	e := WebElement new.
	e addTextH1: self title.
	e add: self aclForWhoElement.
	self style pageFrameWith: e title: self title! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewAddGroup
	| e |
	self group: WebUserGroup new.
	self title: 'Adding a new group on site: ', self site name.
	e := WebElement new.
	e add: self hierarchyLinksElement; addBreak.
	e addTextH1: self title;
		addText: 'New group name: ';
		add: (WebInputField new aspect: #name for: self group);
		addBreak;
		addButtonText: 'Add'.
	self style pageFrameWith: e title: self title! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewAddUser
	| newUser |
	newUser := self site webUserClass new.
	self redirectTo: newUser view: #add! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewFilters
	| e |
	self title: #en->'Access filters'.
	e := WebElement new.
	e add: self hierarchyLinksElement.
	e addTextH1: self title. e addBreak.
	e add: self tabsElement; addBreak.
	e add: self filtersElement.
	self style pageFrameWith: e title: self title! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewGroups
	| e |
	self title: #en->'Groups of users'.
	e := WebElement new.
	e add: self hierarchyLinksElement.
	e addTextH1: self title. e addBreak.
	e add: self tabsElement; addBreak.
	e addLinkTo: self observee text: #en->' Add group ' view: #addGroup;
		addLinkTo: self observee text: #en->' Remove groups ' view: #removeGroups.
	e add: self groupsGridElement.
	self style pageFrameWith: e title: self title! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewMain
	self redirectToView: #users
"
	| e |
	self title: #en-> 'Security management'.
	e := WebElement new.
	e add: self hierarchyLinksElement; addBreak.
	e addTextH1: self title;
		addBreak;
		addLinkTo: self observee text: #en-> ' Users ' view: 'users';
		addText: ' (',self observee allUsers size printDotString,')';
		addBreak;
		addLinkTo: self observee text: #en-> ' Groups ' view: 'groups';
		addText: ' (',self observee allGroups size printDotString,')'.
	self style pageFrameWith: e title: self title
"! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewRemoveGroups
	| e |
	self title: 'Removing groups'.
	e := WebElement new.
	e add: self hierarchyLinksElement; addBreak.
	e addTextH1: self title.
	e addText: 'Note: groups are immediatelly removed after they are checked!! Until you are on this page, groups can be un-removed by uncheck the checkbox.'.
	e add: self groupsRemovalElement.
	self style pageFrameWith: e title: self title! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewRemoveUsers
	| e |
	self title: 'Removing users'.
	e := WebElement new.
	e add: self hierarchyLinksElement; addBreak.
	e addTextH1: self title.
	e addText: 'Note: members are immediatelly removed after they are checked!! Until you are on this page, users can be un-removed by uncheck the checkbox.'.
	e add: self usersRemovalElement.
	self style pageFrameWith: e title: self title! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewSessions
	self redirectTo: self site sessionManager! !

!WebSecurityManagerApp methodsFor: 'printing'!
viewUsers
	| e |
	self title: #en->'Users'.
	e := WebElement new.
	e add: self hierarchyLinksElement.
	e addTextH1: self title. e addBreak.
	e add: self tabsElement; addBreak.
	e addLinkTo: self observee text: #en->' Add user ' view: #addUser;
		addLinkTo: self observee text: #en->' Remove users ' view: #removeUsers.
	e add: self usersGridElement.
	self style pageFrameWith: e title: self title! !


!WebSecurityManagerApp methodsFor: 'views-elements'!
tabsElement
	| tabs |
	tabs := ViewTabs new.
	tabs
		addView: #users description: 'Users';
		addView: #groups description: 'Groups'.
	(self user hasAdminRights and: [self user name = 'Admin']) ifTrue: "only user Admin allowed to change filters!!"
		[tabs addView: #filters description: 'Filters'].
	tabs addView: #sessions description: 'Sessions'.
	tabs addView: #aidaGroup description: 'AidaGroup'.
	^tabs! !


!WebSecurityManagerApp methodsFor: 'views'!
viewAidaGroup
	| e |
	self title: #en-> 'Group of AIDASites'.
	e := WebElement new.
	e add: self hierarchyLinksElement.
	e addTextH1: self title.
	e addText: 'Group of sites for cross-authentication and cross-access'. e addBreak.
	e add: self tabsElement; addBreak.
	self grid: self aidaGroupElement.
	(e addButtonText: #en->' Add group member ')
		noSubmit;
		onClickPopup: self addAidaGroupMemberPopup
		thenUpdate: self grid.
	e add: self grid.
	self style pageFrameWith: e title: self title! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebSecurityManagerApp class
	instanceVariableNames: ''!

!WebSecurityManagerApp class methodsFor: 'translations'!
enHierarchyLinksElement
	^#(
	('<b>Security</b>'->'<b>Security</b>')
	('Security'->'Security')
	('<b>Users</b>'->'<b>Users</b>')
	('<b>Groups</b>'->'<b>Groups</b>')
	('<b>Filters</b>'->'<b>Filters</b>')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations'!
enViewFilters
	^#(
	('Access filters'->'Access filters')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations' stamp: 'jm 9/8/2010 21:20'!
enViewGroups
	^#(
	('Groups of users'->'Groups of users')
	(' Add group '->' Add group ')
	(' Remove groups '->' Remove groups ')
	)
! !

!WebSecurityManagerApp class methodsFor: 'translations'!
enViewMain
	^#(
	(' Users '->' Users ')
	(' Groups '->' Groups ')
	('Security management'->'Security management')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations'!
enViewUsers
	^#(
	('Users'->'Users')
	(' Add user '->' Add user ')
	(' Remove users '->' Remove users ')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations'!
frHierarchyLinksElement
	^#(
	('<b>Security</b>'->'<b>S√É¬©curit√É¬©</b>')
	('Security'->'S√É¬©curit√É¬©')
	('<b>Users</b>'->'<b>Utilisateurs</b>')
	('<b>Groups</b>'->'<b>Groups</b>')
	('<b>Filters</b>'->'<b>Filters</b>')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations'!
frViewFilters
	^#(
	('Access filters'->'Access filters')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations'!
frViewGroups
	^#(
	('Groups of users'->'Groups of users')
	(' Add group '->' Add group ')
	(' Remove groups '->' Remove groups ')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations' stamp: 'jm 9/8/2010 21:19'!
frViewMain
	^#(
	('Security management'->'Gestion de la sÃ©curitÃ©')
	(' Users '->'Utilisateurs')
	(' Groups '->'Groupes')
	)
! !

!WebSecurityManagerApp class methodsFor: 'translations'!
frViewUsers
	^#(
	('Users'->'Utilisateurs')
	(' Add user '->'Ajouter un utilisateur')
	(' Remove users '->' Supprimer un utilisateur')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations'!
slHierarchyLinksElement
	^#(
	('<b>Security</b>'->'<b>Varnostne nastavitve</b>')
	('Security'->'Varnostne nastavitve')
	('<b>Users</b>'->'<b>Uporabniki</b>')
	('<b>Groups</b>'->'<b>Skupine</b>')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations'!
slViewGroups
	^#(
	('Groups of users'->'Skupine uporabnikov')
	(' Add group '->'Dodaj skupino')
	(' Remove groups '->' Bri√Ö¬°i skupino')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations'!
slViewMain
	^#(
	(' Users '->'Uporabniki')
	(' Groups '->'Skupine')
	('Security management'->'Varnostne nastavitve')
	)! !

!WebSecurityManagerApp class methodsFor: 'translations'!
slViewUsers
	^#(
	('Users'->'Uporabniki')
	(' Add user '->'Dodaj uporabnika')
	(' Remove users '->' Bri√Ö¬°i uporabnika')
	)! !


WebApplication subclass: #WebSessionManagerApp
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!

!WebSessionManagerApp methodsFor: 'views-elements'!
activeSessionsElement
	| e grid |
	e := WebElement new. e table width: 1.
	e cell addText: 'All currently active sesions on the site. Active = any request in last hour.'. e newRow.
	grid := (WebGrid new width: self style pageContentWidth)
		columnNames: #(nil 'state' 'user' 'Initial IP' 'created' 'last request');
		columnFilters: #(nil 3 10 6 true);
		columnWidth: #(0.01 0.05 0.2  0.1 0.2);
		columnAlign: #(nil center center center center);
		columnAspects: #(nil loginStateText lastUserText initialIP createdTimestampText lastRequestTimeText);
		columnLinkViews: #(nil nil nil);
		collection: ((self site sessionManager allActiveSessions) 
"			asSortedCollection: [:u1 :u2 | u1 username < u2 username]");
		setNumbering;
		rowsOnPage: 50;
		yourself.
	e cell add: grid.	
	^e! !

!WebSessionManagerApp methodsFor: 'views-elements'!
hierarchyLinksElement
	| e |
	e := WebElement new.
	^e! !

!WebSessionManagerApp methodsFor: 'views-elements'!
lastActivityAndLocationElementFor: aSession
	| e loc |
	e := WebElement new.
	e addText: aSession lastActivityText.
	aSession geolocation notNil ifTrue:
		[loc := (aSession geolocation latitude printString copyWithout: $d ), ',', 
			(aSession geolocation longitude printString copyWithout: $d ).
		e addBreak.
		e addLinkTo: 'http://maps.google.com/maps?q=', loc, '(user''s position)' text: 'position on the map'].
	^e! !

!WebSessionManagerApp methodsFor: 'views-elements'!
loggedSessionsElement
	| e grid |
	e := WebElement new. e table width: 1.
	e cell addText: 'All sessions, logged in now or in past. Bold if active in last hour.'. e newRow.
	grid := (WebGrid new width: self style pageContentWidth)
		columnNames: #(nil 'state' 'user' 'Initial IP' 'created' 'last activity' 'login' 'logout');
		columnFilters: #(nil 3 10 6 true true );
		columnWidth: #(0.01 0.05 0.2  0.1 0.2 0.2);
		columnAlign: #(nil center center center center center);
		columnAspects: #(nil nil lastUserText initialIP createdTimestampText nil);
		columnLinkViews: #(nil nil nil nil);
		column: 2 addBlock: 
			[:ssion | self stateElementFor: ssion];
		column: 6 addBlock: 
			[:ssion | self lastActivityAndLocationElementFor: ssion];
		collection: ((self site sessionManager allWereLoggedSessions) "were or still are!!"
"			asSortedCollection: [:u1 :u2 | u1 username < u2 username]");
		rowBoldIfTrue: [:s | s isActive];
		setNumbering;
		rowsOnPage: 50;
		yourself.
	e cell add: grid.	
	^e! !

!WebSessionManagerApp methodsFor: 'views-elements'!
stateElementFor: aSession
	| e stateText |
	e := WebElement newSpan.
	stateText := aSession loginStateText.
	stateText = 'login' ifFalse: 
		[e addText: stateText. 
		^e].
	(e addNilLinkText: 'login')
		title: 'Click to logout';
		onClickDo: [aSession logout];
		onClickUpdate: e with: aSession.
	^e! !

!WebSessionManagerApp methodsFor: 'views-elements'!
tabsElement
	^ViewTabs new
		addView: #back description: 'Back';
		addView: #main description: 'Active';
		addView: #logged description: 'Logged in';
		yourself! !


!WebSessionManagerApp methodsFor: 'views'!
viewBack
	"back to security settings"
	self redirectTo: self site securityManager! !

!WebSessionManagerApp methodsFor: 'views'!
viewLogged
	| e |
	self title: #en->'Sessions, logged-in now or in past'.
	e := WebElement new.
	e add: self hierarchyLinksElement.
	e addTextH1: self title. e addBreak.
	e add: self tabsElement. e addBreak.
	e add: self loggedSessionsElement.
	self style pageFrameWith: e title: self title! !

!WebSessionManagerApp methodsFor: 'views'!
viewMain
	| e |
	self title: #en->'Active sessions'.
	e := WebElement new.
	e add: self hierarchyLinksElement.
	e addTextH1: self title. e addBreak.
	e add: self tabsElement. e addBreak.
	e add: self activeSessionsElement.
	self style pageFrameWith: e title: self title! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebSessionManagerApp class
	instanceVariableNames: ''!

!WebSessionManagerApp class methodsFor: 'translations'!
enViewLogged
	^#(
	('Sessions, logged-in now or in past'->'Sessions, logged-in now or in past')
	)! !

!WebSessionManagerApp class methodsFor: 'translations'!
enViewMain
	^#(
	('Active sessions'->'Active sessions')
	)! !

!WebSessionManagerApp class methodsFor: 'translations'!
frViewLogged
	^#(
	('Sessions, logged-in now or in past'->'Sessions, logged-in now or in past')
	)! !

!WebSessionManagerApp class methodsFor: 'translations'!
frViewMain
	^#(
	('Active sessions'->'Active sessions')
	)! !

!WebSessionManagerApp class methodsFor: 'translations'!
slViewLogged
	^#(
	('Sessions, logged-in now or in past'->'Sessions, logged-in now or in past')
	)! !

!WebSessionManagerApp class methodsFor: 'translations'!
slViewMain
	^#(
	('Active sessions'->'Active sessions')
	)! !


WebApplication subclass: #WebStatisticsApp
	instanceVariableNames: 'date domainObject'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!
!WebStatisticsApp commentStamp: '<historical>' prior: 0!
WebStatisticsApp for showing statistics like visits of first page, per page, referers and more. Statistics are collected from counters in AIDASite and URLResolver, and from referers in WebStatistics!


!WebStatisticsApp methodsFor: 'accessing'!
adjustViewingDate
	"read url parameters and adjust a viewing date accordingly"
	| adjusted m |
	adjusted := false.
	(self session lastRequest includesQuery: 'day') ifTrue: 
		[self date: (SpDate 
			newDay: (self session lastRequest queryAt: 'day') asInteger
			month: self date monthIndex
			year: self date year). adjusted := true].
	(self session lastRequest includesQuery: 'month') ifTrue: 
		[m := (self session lastRequest queryAt: 'month') asInteger.
		(m between: 1 and: 12) ifTrue: 
			[self date: (SpDate newDay: 1 month: m year: self date year). adjusted := true] ].
	(self session lastRequest includesQuery: 'year') ifTrue: 
		[self date: (SpDate 
			newDay: 1
			month: self date monthIndex
			year: (self session lastRequest queryAt: 'year') asInteger).
			adjusted := true].
	adjusted ifFalse: [date := SpDate today].! !

!WebStatisticsApp methodsFor: 'accessing'!
counterForUrlOrFirstPage
	"if url query part contains and url for target domain object to show counter, return that
  	otherwise first page counter only"
	"Also sets instvar domainObject!!"
	| url |
	url := (self session lastRequest includesQuery: 'url')
		ifTrue: [self session lastRequest queryAt: 'url'] ifFalse: [nil].
	self domainObject: (url notNil 
			ifTrue: [self site urlResolver objectOnUrl: url]
			ifFalse: [self firstPageObject notNil ifTrue: [self firstPageObject] ifFalse: [nil] ]).
	^self domainObject notNil 
		ifTrue: [self site urlResolver counterFor: self domainObject]
		ifFalse: [nil]! !

!WebStatisticsApp methodsFor: 'accessing' stamp: 'np 10/22/2008 23:42'!
date
	date isNil ifTrue: [date := SpDate today].
	^date! !

!WebStatisticsApp methodsFor: 'accessing' stamp: 'np 10/22/2008 23:52'!
date: aDate
	date := aDate! !

!WebStatisticsApp methodsFor: 'accessing' stamp: 'mivsek 1/10/2008 22:52'!
domainObject
	"for which we show statistics"
	^domainObject! !

!WebStatisticsApp methodsFor: 'accessing' stamp: 'mivsek 1/10/2008 22:52'!
domainObject: anObject
	domainObject := anObject! !

!WebStatisticsApp methodsFor: 'accessing'!
firstPageObject
	^self site urlResolver objectOnUrl: '/'! !

!WebStatisticsApp methodsFor: 'accessing'!
pageWidth
	^self style pageWidth - 150 "actually from WebStyle"! !

!WebStatisticsApp methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
refererLinesOnPage
	^50! !

!WebStatisticsApp methodsFor: 'accessing' stamp: 'JM 4/26/2007 21:35'!
statsStartingDate
	^SpDate newDay: 1 month: 1 year: 2005.! !


!WebStatisticsApp methodsFor: 'views-elements' stamp: 'JM 4/21/2007 22:35'!
currentWeekStats
	| firstDay collection |
	firstDay := Date today - Date today weekdayIndex + 1.
	collection := OrderedCollection new.
	firstDay to: firstDay + 6 do: [:dte |
		collection add: (self site requestsOnDate: dte)].
	^collection! !

!WebStatisticsApp methodsFor: 'views-elements' stamp: ' 21/4/07 22:07'!
firstPageCountOnDate: aDate
	| countedObject |
	countedObject := self firstPageObject.
	countedObject isNil ifTrue: [^0].
	^(self site urlResolver counterFor: countedObject) countsOnDate: aDate.! !

!WebStatisticsApp methodsFor: 'views-elements' stamp: ' 21/4/07 22:07'!
firstPageCountTotal
	| countedObject |
	countedObject := self firstPageObject.
	countedObject isNil ifTrue: [^0].
	^(self site urlResolver counterFor: countedObject) total.! !

!WebStatisticsApp methodsFor: 'views-elements'!
mainStatsElement
	| e |
	self title: 'Site  access statistics'.
	e := WebElement new.
	e table width: self pageWidth; cellSpacing: 0; cellPadding: 0.
      e cell color: #thistle.
	e cell colspan: 4; addText: self title header: 3. e newRow.
	e cell colspan: 4; addRulerSize: 1.e newRow.
	self style statsIntroduction notEmpty ifTrue: [e cell colspan: 4; addText: self style statsIntroduction].
	e cell colspan: 4;
		addBreak; addTextSmall: 'Statistics from: ';
		addTextSmall: ('<b>', session site createdTimestamp printSloString, '</b>'); addTextSmall: ' to: ';
		addTextSmall: ('<b>', SpTimestamp now printSloString, '</b>'); addBreak; addNbSp.
	e newRow. e cell colspan: 4; addRulerSize: 1.
	e newRow color: #thistle.
	e cell addBreak.
	e newCell align: #right; addTextSmall: 'today'.
	e newCell align: #right; addTextSmall: 'yesterday'.
	e newCell align: #right; addTextSmall: 'until now'. e newRow.
	e cell addTextSmall: 'first page'.
	e newCell align: #right; addTextSmall:  (self firstPageCountOnDate: SpDate today) printDotString.
	e newCell align: #right; addTextSmall: (self firstPageCountOnDate: (SpDate today subtractDays: 1)) printDotString.
	e newCell align: #right; addTextSmall: (self firstPageCountTotal) printDotString.
	e newRow color: #fffbf0.
	e cell addTextSmall: 'all pages'. 
	e newCell align: #right; addTextSmall: self site allPagesToday printDotString.
	e newCell align: #right; addTextSmall: self site allPagesYesterday printDotString.
	e newCell align: #right; addTextSmall: self site allPages printDotString. e newRow.
	e cell addTextSmall: 'all pages+images'.
	e newCell align: #right; addTextSmall: (self site totalCounter countsOnDate: SpDate today) printDotString.
	e newCell align: #right; addTextSmall: (self site totalCounter countsOnDate: (SpDate today subtractDays: 1)) printDotString.
	e newCell align: #right; addTextSmall: (self site totalCounter total ) printDotString. e newRow.
	e cell colspan: 4; addRulerSize: 1.
	^e! !

!WebStatisticsApp methodsFor: 'views-elements' stamp: 'np 10/22/2008 23:57'!
nextMonthLink
	self date currentMonth ifTrue: [^WebText text: '<font face="helvetica">></font>' ].
	^(WebLink text: '<font face="helvetica">></font>' linkTo: self observee)
		parameter: 'view' value: self view;
		parameter: 'month' value: self date firstDayInNextMonth monthIndex printString;
		parameter: 'year' value: self date firstDayInNextMonth year printString.! !

!WebStatisticsApp methodsFor: 'views-elements' stamp: 'mivsek 1/10/2008 22:55'!
pageDescription
	| e url |
	e := WebElement new.
	url := self site urlResolver halfUrlFor: self domainObject.
	e addText: 'For page: '; addLinkTo: url text: url.
	^e! !

!WebStatisticsApp methodsFor: 'views-elements' stamp: 'np 10/22/2008 23:57'!
previousMonthLink
	^(WebLink text: '<font face="helvetica"><</font>' linkTo: self observee)
		parameter: 'view' value: self view;
		parameter: 'month' value: self date firstDayInPreviousMonth monthIndex printString;
		parameter: 'year' value: self date firstDayInPreviousMonth year printString.! !

!WebStatisticsApp methodsFor: 'views-elements'!
printCounter
	| e count |
	e := WebElement new.
	count := self firstPageCountTotal.
	e addText: '<font face="arial, helvetica"> <b>'; 	addText: count printDotString; addText: '</b></font>'.
	^e.! !

!WebStatisticsApp methodsFor: 'views-elements'!
referersElementFor: aCollection date: aDate
	| e referers nr max new |
	e := WebElement new.
	e table width: self pageWidth; cellSpacing: 0; cellPadding: 0.
	referers := aCollection copyFrom: 1 to: (self refererLinesOnPage min: aCollection size).
	max := referers inject: 0 into: [:maxi :each | maxi max: (each at: 2)].
	nr := 1.
	referers do: [:array |
		new := aDate notNil and: [self observee isNewReferer: (array first) onDate: aDate].
		e cell align: #right; addTextSmall: nr printString, '. '.
		e newCell add: 
			(WebLink new 
				text: '<font size=-1>', (new ifTrue: ['<b>'] ifFalse: ['']), (array first), '</b></font>';
				urlReference: (array first)).
		e newCell add: (self graphLineCount: (array at: 2) max: max "length: 80").
		e newCell align: #right; addTextSmall: ' ', (array at: 2) printDotString. 	e newRow.
		nr even ifTrue: [e row color: #fffbf0].
		nr := nr + 1].
	e cell colspan: 4; addRulerSize: 1.
	^e! !

!WebStatisticsApp methodsFor: 'views-elements' stamp: 'mivsek 1/10/2008 22:55'!
tabsElement
	^ViewTabs new
		addView: #main description: 
			(self isFirstPage ifTrue: ['First page'] ifFalse: ['Selected page']);
"		addView: #hits description: 'All hits';"
		addView: #referers description: 'Referers';
		yourself! !

!WebStatisticsApp methodsFor: 'views-elements' stamp: 'np 10/20/2008 13:43'!
tabsReferersElement
	^ViewTabs new
		addView: #referers description: 'Today';
		addView: #referersYesterday description: 'Yesterday';
		addView: #referersWeekly description: 'This week';
		addView: #referersAll description: 'All';
		yourself! !


!WebStatisticsApp methodsFor: 'views-graphs' stamp: ' 21/8/07 09:38'!
graphElementCounter: aFirstCounter and: aSecondCounter
	| e |
	e := WebElement new. e table width: self pageWidth.
	(self session lastRequest includesQuery: 'yearly') 
		ifTrue: [e cell valign: #top; add: (self yearlyStatsCounter: aFirstCounter and: aSecondCounter)]
		ifFalse: 
			[e cell valign: #top; add: (self monthlyStatsCounter: aFirstCounter and: aSecondCounter).
			e newCell addNbSp.
			e newCell valign: #top; add: (self hourlyStatsCounter: aFirstCounter and: aSecondCounter)].
	^e! !

!WebStatisticsApp methodsFor: 'views-graphs' stamp: ' 21/8/07 09:38'!
graphElementCounter: aFirstCounter total: aTotalCounter
	| e |
	e := WebElement new.
	e table width: self pageWidth.
	e cell valign: #top; add: (self monthlyStatsCounter: aFirstCounter total: aTotalCounter).
	e newCell addNbSp.
	e newCell valign: #top; add: (self hourlyStatsCounter: aFirstCounter total: aTotalCounter).
	^e! !

!WebStatisticsApp methodsFor: 'views-graphs' stamp: ' 21/8/07 09:38'!
graphLineCount: firstCount and: secondCount max: maxCount
	| e width maxLength |
	width := 6. maxLength := 148.
	e := WebElement new.
	e addGif: #redPixelGif size: ((maxLength * firstCount // (maxCount max: 1)) max: 2)@width.
	(secondCount notNil and: [secondCount > 0]) ifTrue:
		[e addGif: #bluePixelGif size: ((maxLength * secondCount // maxCount) max: 2)@width].
	^e! !

!WebStatisticsApp methodsFor: 'views-graphs' stamp: ' 21/4/07 22:07'!
graphLineCount: count max: maxCount

	^self graphLineCount: count and: nil max: maxCount! !

!WebStatisticsApp methodsFor: 'views-graphs'!
hourlyStatsCounter: aFirstCounter and: aTotalCounter
	| firstArray secondArray |
	firstArray := aFirstCounter allHourlyCounts.
	secondArray := aTotalCounter notNil
		ifTrue: [aTotalCounter allHourlyCounts]
		ifFalse: [Array new: firstArray size withAll: 0].
	^self hourlyStatsFrom: firstArray and: secondArray! !

!WebStatisticsApp methodsFor: 'views-graphs'!
hourlyStatsCounter: aFirstCounter total: aTotalCounter
	| firstArray secondArray |
	firstArray := aFirstCounter allHourlyCounts.
	secondArray := self subtractArray: firstArray
		from: aTotalCounter allHourlyCounts.
	^self hourlyStatsFrom: firstArray and: secondArray! !

!WebStatisticsApp methodsFor: 'views-graphs'!
hourlyStatsFrom: aFirstArray and: aSecondArray
	| e maxCount turn sumArray |
	sumArray := aSecondArray notNil 
		ifTrue: [self sumArray: aFirstArray and: aSecondArray]
		ifFalse: [aFirstArray].
	maxCount := sumArray inject: 0 into: [:max :each | each max: max].
	e := WebElement new.
	e table width: 250; cellSpacing: 0; cellPadding: 0. e newRow color: #thistle.
	e cell width: 50; addTextSmall: 'hour'. e newCell width: 150; addBreak. 
	e newCell width: 50; align: #right; addTextSmall: 'hits'. e newRow.
	turn := true.
	1 to: 24 do: [:hour |
		e newRow.
		(hour-1) \\ 6 = 0 ifTrue: [turn := turn not].
		turn ifTrue: [e row color: #fffbf0].
		e cell addTextSmall: ( (hour-1) printString, ' - ', (hour) printString).
		e newCell add: (self graphLineCount: (aFirstArray at: hour) and: (aSecondArray at: hour) max: maxCount).
		e newCell align: #right; addTextSmall: (sumArray at: hour) printDotString].
	^e! !

!WebStatisticsApp methodsFor: 'views-graphs'!
monthlyStatsCounter: aFirstCounter and: aSecondCounter
	| firstArray secondArray |
	firstArray := aFirstCounter
		countsFrom: self date firstDayInMonth to: self date lastDayInMonth.
	secondArray := aSecondCounter notNil 
		ifTrue: [aSecondCounter countsFrom: self date firstDayInMonth to: self date lastDayInMonth]
		ifFalse: [Array new: firstArray size withAll: 0].
	^self monthlyStatsDate: self date firstDayInMonth from: firstArray and: secondArray! !

!WebStatisticsApp methodsFor: 'views-graphs'!
monthlyStatsCounter: aFirstCounter total: aTotalCounter
	| firstArray secondArray |
	firstArray := aFirstCounter
		countsFrom: self date firstDayInMonth to: self date lastDayInMonth.
	secondArray := self subtractArray: firstArray
		from: (aTotalCounter 
			countsFrom: self date firstDayInMonth to: self date lastDayInMonth).
	^self monthlyStatsDate: self date firstDayInMonth from: firstArray and: secondArray! !

!WebStatisticsApp methodsFor: 'views-graphs'!
monthlyStatsDate: aDate from: aFirstArray and: aSecondArray
	| e maxCount turn sumArray cDate weekday monthText yearLink |
	sumArray := aSecondArray notNil 
		ifTrue: [self sumArray: aFirstArray and: aSecondArray]
		ifFalse: [aFirstArray].
	maxCount := sumArray inject: 0 into: [:max :each | each max: max].
	e := WebElement new.
	e table width: 300; cellSpacing: 0; cellPadding: 0. e newRow color: #thistle.
	monthText := (Date nameOfMonth: aDate monthIndex), ' ', aDate year printString.
	yearLink := (WebLink text: '<font face="helvetica">yearly</font>' linkTo: self observee)
		parameter: 'view' value: self view; parameter: 'yearly' value: 'true'.
	e cell  colspan: 3;
		add: self previousMonthLink; 	addTextSmall: ' ', monthText, ' ';
		add: self nextMonthLink; addNbSp: 3; add: yearLink.
	e newCell width: 50; align: #right; addTextSmall: 'hits'. e newRow.
	turn := false.
	1 to: aFirstArray size do: [:day |
		e newRow.
		cDate := aDate addDays: day - 1.
		weekday := cDate weekdayIndex. weekday = 1 ifTrue: [turn := turn not]. 
		turn ifTrue: [e row color: #fffbf0].
		e cell addTextSmall: ((Date nameOfDay: weekday) copyFrom: 1 to: 3).
		e newCell align: #right; addTextSmall: (day printString, '.', aDate monthIndex printString, ' ' ).
		e newCell add: (self graphLineCount: (aFirstArray at: day) and: (aSecondArray at: day) max: maxCount).
		e newCell align: #right; addTextSmall: (sumArray at: day) printDotString.
		].
	^e! !

!WebStatisticsApp methodsFor: 'views-graphs'!
monthlyStatsFor: aFirstCounter total: aTotalCounter
	| firstArray secondArray |
	firstArray := aFirstCounter
		countsFrom: self date firstDayInMonth to: self date lastDayInMonth.
	secondArray := self subtractArray: firstArray
		from: (aTotalCounter 
			countsFrom: self date firstDayInMonth to: self date lastDayInMonth).
	^self monthlyStatsDate: self date firstDayInMonth from: firstArray and: secondArray! !

!WebStatisticsApp methodsFor: 'views-graphs'!
subtractArray: aFirstArray from: aSecondArray
	| result |
	result := OrderedCollection new.
	aFirstArray with: aSecondArray do: [:first :second | result add: second - first].
	^result.

"WebStatisticsApp new subtractArray: #(1 2 3 4) from: #(1 2 3 4)"! !

!WebStatisticsApp methodsFor: 'views-graphs'!
sumArray: aFirstArray and: aSecondArray
	| result |
	result := OrderedCollection new.
	aFirstArray with: aSecondArray do: [:first :second | result add: first + second].
	^result.

"WebStatisticsApp new sumArray: #(1 2 3 4) and: #(1 2 3 4)"! !

!WebStatisticsApp methodsFor: 'views-graphs'!
weeklyStatsElement
	| firstArray secondArray |
	firstArray := self site pagesCounter currentWeekCounts.
	secondArray := self subtractArray: firstArray
		from: self site totalCounter currentWeekCounts.
	^self weeklyStatsFrom: firstArray and: secondArray! !

!WebStatisticsApp methodsFor: 'views-graphs'!
weeklyStatsFrom: aFirstArray and: aSecondArray
	| e maxCount turn sumArray |
	sumArray := aSecondArray notNil 
		ifTrue: [self sumArray: aFirstArray and: aSecondArray]
		ifFalse: [aFirstArray].
	maxCount := sumArray inject: 0 into: [:max :each | each max: max].
	e := WebElement new.
	e table width: 400; cellSpacing: 0; cellPadding: 0. e newRow color: #thistle.
	e cell width: 50; addTextSmall: 'this week'. e newCell width: 300; addBreak.
	e newCell width: 50; align: #right; addTextSmall: 'hits'. e newRow.
	turn := false.
	1 to: 7 do: [:day |
		e newRow.
		turn ifTrue: [e row color: #fffbf0].
		e cell addTextSmall: ((Date nameOfDay: day) copyFrom: 1 to: 3).
		e newCell add: (self graphLineCount: (aFirstArray at: day) and: (aSecondArray at: day) max: maxCount).
		e newCell align: #right; addTextSmall: (sumArray at: day) printDotString.
		turn := turn not].
	^e! !

!WebStatisticsApp methodsFor: 'views-graphs'!
yearlyStatsCounter: aFirstCounter and: aSecondCounter
	| firstArray secondArray |
	firstArray := aFirstCounter countsMonthlyFromDate: self statsStartingDate.
	secondArray := aSecondCounter notNil 
		ifTrue: [aSecondCounter  countsMonthlyFromDate: self statsStartingDate.]
		ifFalse: [Array new: firstArray size withAll: 0].
	^self yearlyStatsStarting: self statsStartingDate from: firstArray and: secondArray! !

!WebStatisticsApp methodsFor: 'views-graphs'!
yearlyStatsCounter: aFirstCounter total: aTotalCounter
	| firstArray secondArray |
	firstArray := aFirstCounter countsMonthlyFromDate: self statsStartingDate.
	secondArray := self subtractArray: firstArray
		from: (aTotalCounter  countsMonthlyFromDate: self statsStartingDate).
	^self yearlyStatsStarting: self statsStartingDate from: firstArray and: secondArray! !

!WebStatisticsApp methodsFor: 'views-graphs'!
yearlyStatsFor: aFirstCounter total: aTotalCounter
	| firstArray secondArray |
	firstArray := aFirstCounter countsMonthlyFromDate: self statsStartingDate.
	secondArray := self subtractArray: firstArray
		from: (aTotalCounter  countsMonthlyFromDate: self statsStartingDate).
	^self yearlyStatsStarting: self statsStartingDate from: firstArray and: secondArray! !

!WebStatisticsApp methodsFor: 'views-graphs'!
yearlyStatsStarting: aDate from: aFirstArray and: aSecondArray
	| e maxCount turn sumArray cdate |
	sumArray := aSecondArray notNil 
		ifTrue: [self sumArray: aFirstArray and: aSecondArray]
		ifFalse: [aFirstArray].
	maxCount := sumArray inject: 0 into: [:max :each | each max: max].
	e := WebElement new.
	e table width: 300; cellSpacing: 0; cellPadding: 0. e newRow color: #thistle.
	e cell addNbSp. 	e newCell addNbSp. e newCell width: 150; addBreak.
	e newCell width: 50; align: #right; addTextSmall: 'hits'. e newRow.
	turn := false.
	cdate := SpDate newDay: 1 month: aDate monthIndex year: aDate year.
	1 to: aFirstArray size do: [:inx |
		e newRow.
		cdate monthIndex \\ 3 = 1 ifTrue: [turn := turn not].
		turn ifTrue: [e row color: #fffbf0].
		e cell addTextSmall: ((Date nameOfMonth: cdate monthIndex) asString copyFrom: 1 to: 3).
		e newCell addTextSmall: cdate year printString.
		e newCell add: (self graphLineCount: (aFirstArray at: inx) and: (aSecondArray at: inx) max: maxCount).
		e newCell align: #right; addTextSmall: (sumArray at: inx) printDotString.
		cdate := SpDate 	newDay: 1 month: (cdate addDays: 31) monthIndex year: (cdate addDays: 31) year].
	^e! !


!WebStatisticsApp methodsFor: 'testing' stamp: 'mivsek 1/10/2008 22:54'!
isFirstPage
	^self domainObject == self firstPageObject! !


!WebStatisticsApp methodsFor: 'views'!
viewHits
	| e |
	self title: 'Site  access statistics'.
	self adjustViewingDate.
	e := WebElement new.
	e cell add: self mainStatsElement. e newRow.
	e cell add: self tabsElement. e newRow.
	e cell add: (self graphElementCounter: self site pagesCounter total: self site totalCounter).
	^self style pageFrameWith: e title: self title .! !

!WebStatisticsApp methodsFor: 'views'!
viewMain
	| e counter |
	self title: 'Site statistics - page'.
	self adjustViewingDate.
	counter := self counterForUrlOrFirstPage. "from query part of url, otherwise first page"
	e := WebElement new.
	e cell add: self mainStatsElement. e newRow.
	e cell add: self tabsElement. e newRow.
	self isFirstPage ifFalse: [e cell add: self pageDescription. e newRow].
	counter notNil ifTrue: 
		[e cell add: (self graphElementCounter: counter and:nil)].
	^self style pageFrameWith: e title: self title .! !

!WebStatisticsApp methodsFor: 'views'!
viewReferers "Today"
	| e |
	self title: 'Site statistics - referers'.
	self adjustViewingDate.
	e := WebElement new.
	e cell add: self mainStatsElement. e newRow.
	e cell add: self tabsElement. e newRow.
	e cell add: self tabsReferersElement. e newRow.
	e cell addNbSp: 4; addText: '<small><b>bold</b> = new in last 7 days</small>'. e newRow.
	e cell addTextH1: 'Today referers - visitors comming from: '. e newRow.
	e cell add: (self 
		referersElementFor: self observee allRefererCountsToday 
		date: SpDate today).
	^self style pageFrameWith: e title: self title .! !

!WebStatisticsApp methodsFor: 'views'!
viewReferersAll
	| e |
	self title: 'Site statistics - referers'.
	self adjustViewingDate.
	e := WebElement new.
	e cell add: self mainStatsElement. e newRow.
	e cell add: self tabsElement. e newRow.
	e cell add: self tabsReferersElement. e newRow.
	e cell addTextH1: 'Referers - visitors comming mostly from: '. e newRow.
	e cell add: (self referersElementFor: self observee allRefererCounts date: nil).
	^self style pageFrameWith: e title: self title .! !

!WebStatisticsApp methodsFor: 'views'!
viewReferersWeekly
	| e |
	self title: 'Site statistics - referers'.
	self adjustViewingDate.
	e := WebElement new.
	e cell add: self mainStatsElement. e newRow.
	e cell add: self tabsElement. e newRow.
	e cell add: self tabsReferersElement. e newRow.
	e cell addTextH1: 'That week referers - visitors comming from: '. e newRow.
	e cell add: (self referersElementFor: self observee allRefererCountsWeekly date: nil).
	^self style pageFrameWith: e title: self title .! !

!WebStatisticsApp methodsFor: 'views'!
viewReferersYesterday
	| e |
	self title: 'Site statistics - referers'.
	self adjustViewingDate.
	e := WebElement new.
	e cell add: self mainStatsElement. e newRow.
	e cell add: self tabsElement. e newRow.
	e cell add: self tabsReferersElement. e newRow.
	e cell addTextH1: 'Yesterday referers - visitors comming from: '. e newRow.
	e cell addNbSp: 4; addText: '<small><b>bold</b> = new in last 7 days</small>'. e newRow.
	e cell add: (self 
		referersElementFor: self observee allRefererCountsYesterday 
		date: (SpDate today subtractDays: 1)).
	^self style pageFrameWith: e title: self title .! !

!WebStatisticsApp methodsFor: 'views'!
viewVisitors
	| e |
	self adjustViewingDate.
	self title: 'Site statistics - returning visitors'.
	e := WebElement new.
	e cell add: self mainStatsElement. e newRow.
	e cell add: (self graphSelectionForView: self view). e newRow.
	e cell add: (self graphElementCounter: self site returningVisitorsCounter 
		and: self site newVisitorsCounter).
	^self style pageFrameWith: e title: self title .! !


WebApplication subclass: #WebUserApp
	instanceVariableNames: 'newPassword newPasswordConfirmation groups'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!
!WebUserApp commentStamp: '<historical>' prior: 0!
WebUserApp for viewing and editing user information
!


!WebUserApp methodsFor: 'actions'!
actionAdd
	self newPassword trimBlanks isEmpty ifTrue: [self showError: 'Password is empty!!'].
	self observee username trimBlanks isEmpty ifTrue: [self showError: 'Username is empty!!'].
	self newPassword = self newPasswordConfirmation ifFalse: [	self showError: 'Passwords do not match!!'].
	self inError ifTrue: [^self redirectToView: #add].
	self observee passwordText: self newPassword.
	self site securityManager addRegisteredUser: self observee.
	self observee changeToPreferredUrl.
	self redirectTo: self observee! !

!WebUserApp methodsFor: 'actions'!
actionEdit
	self newPassword = self newPasswordConfirmation ifFalse: [
		self showError: 'Passwords do not match!!'].
	self inError ifTrue: [^self redirectToView: #edit].
	self observee passwordText: self newPassword.
	self redirectTo: self observee! !

!WebUserApp methodsFor: 'actions'!
actionMainChangeGroups
	self observee groups do: [:group | group removeUser: self observee].
	self groups do: [:group | group addUser: self observee].! !


!WebUserApp methodsFor: 'views-elements'!
actionsLineElement
	| e |
	e := WebElement new.
	self observee isGuest not
		ifTrue: [e addLinkTo: self observee text: 'Update information ' view: #edit]
		ifFalse: [e addText: 'User locked, changes not allowed '].
	e addLinkTo: self site securityManager text: ' Access rights '
		view: #aclObjects
		parameter: 'who' value: self observee uuid.
	^e! !

!WebUserApp methodsFor: 'views-elements'!
activityElement
	| e |
	e := WebElement new. e table width: 1.
	self observee registeredTimestamp notNil ifTrue:
		[e cell addText: 'Registered at ', self observee registeredTimestamp printSloString].
	self observee isLoggedIn
		ifTrue: 
			[e cell addTextBold: 'Logged in'.  
			self observee lastLoginTimestamp notNil ifTrue: 
				[e cell addText:  ' at ', self observee lastLoginTimestamp printSloString] ]
		ifFalse: 
			[e cell addText: 'Logged out'.  
			self observee lastLogoutTimestamp notNil ifTrue: 
				[e cell addText:  ' at ', self observee lastLogoutTimestamp printSloString] ].
	^e! !

!WebUserApp methodsFor: 'views-elements'!
basicInfoElement
	| e |
	e := WebFieldSet new legend: 'Basic information'.
	e cell addText: 'Username:'.
	e newCell addTextBold: self observee username.
	e newRow.
	e cell addText: 'Name:'.
	e newCell addTextBold: self observee name.
	e newRow.
	e cell addText: 'Surname:'.
	e newCell addTextBold: self observee surname.
	^e! !

!WebUserApp methodsFor: 'views-elements'!
contactInfoElement
	| e |
	e := WebFieldSet new legend: 'Contact information'.
	e cell addText: 'Company:'.
	e newCell addTextBold: self observee company.
	e newRow.
	e cell addText: 'Address:'.
	e newCell addTextBold: self observee address.
	e newRow.
	e cell addText: 'City:'.
	e newCell addTextBold: self observee city.
	e newRow.
	e cell addText: 'Zip:'.
	e newCell addTextBold: self observee zip.
	e newRow.
	e cell addText: 'Phone:'.
	e newCell addTextBold: self observee phone.
	e newRow.
	e cell addText: 'Fax:'.
	e newCell addTextBold: self observee fax.
	e newRow.
	e cell addText: 'E-mail:'.
	e newCell addTextBold: self observee email.
	e newRow.
	e cell addText: 'Website:'.
	e newCell addTextBold: self observee website. 
	^e! !

!WebUserApp methodsFor: 'views-elements'!
groupsAndActivityElement
	| e fs |
	e := WebElement new.
	fs := WebFieldSet new legend: 'Groups, activity'.
	fs table width: 1.
	fs cell width: 300; valign: #top; add: self groupsElement. 
	fs newCell width: 500; valign: #top; add: self activityElement.
	fs newCell valign: #top; addLinkTo: self observee text: 'Sessions' view: #sessions.
	^e add: fs; yourself! !

!WebUserApp methodsFor: 'views-elements'!
groupsElement
	| e |
	e := WebElement newDiv. e table width: 1.
	e cell valign: #top; width: 100; addText: 'Groups:'. e cell addBreak.
	(e cell addNilLinkText: 'edit')
		onClickPopup: self editGroupsPopup thenUpdate: e.
	e newCell.
	(self observee groups asSortedCollection: [:a :b | a name < b name]) do: [:each |
		e cell addLinkTo: each text: each name. e cell addBreak].
	^e! !

!WebUserApp methodsFor: 'views-elements'!
hierarchyLinksElement
	| e |
	e := WebElement new.
	e addText: self site name, ' / '.
	e addLinkTo: self site securityManager text: 'Security'.
	e addText: ' / '.
	e addLinkTo: self site securityManager text: 'Users' view: #users.
	e addText: ' / '.
	e addLinkTo: self observee text: '<b>', self observee nameSurname, '</b>' view: self view.
	^e! !

!WebUserApp methodsFor: 'views-elements'!
sessionsElement
	| e grid |
	e := WebElement new.
	grid := (WebGrid new width: self style pageContentWidth)
		columnNames: #(nil nil 'Initial IP' 'created' 'login' 'logout');
		columnAspects: #(nil nil initialIP created);
		columnLinkViews: #(nil nil nil nil);
		columnFilters: #(nil nil true true);
		collection: ((self site sessionManager allSessionsForUser: self observee) 
"			asSortedCollection: [:u1 :u2 | u1 username < u2 username]");
		setNumbering;
		rowsOnPage: 20;
		yourself.
	e add: grid.	
	^e! !


!WebUserApp methodsFor: 'private'!
aidaDontCache
	"always refresh pages, to deal with back button correctly"
	^true! !


!WebUserApp methodsFor: 'access-rights'!
canBeViewed
	^self user hasAdminRights or: [self user == self observee]! !


!WebUserApp methodsFor: 'views-edit'!
editElement
	| e |
	self newPassword: ''.
	self newPasswordConfirmation:  ''.
	e := WebElement new.
	self observee isLocked 
		ifTrue: [e cell addTextBold: 'User is locked!!'. e newRow]
		ifFalse:
			[e cell addText: 'Name:'.
			e newCell addInputFieldAspect: #name for: self observee. e newRow.
			e cell addText: 'Surname:'. 
			e newCell addInputFieldAspect: #surname for: self observee. e newRow.
			e cell addText: 'Company:'.
			e newCell addInputFieldAspect: #company for: self observee. e newRow.
			e cell addText: 'Address:'.
			e newCell addInputFieldAspect: #address for: self observee. e newRow.
			e cell addText: 'City:'.
			e newCell addInputFieldAspect: #city for: self observee. e newRow.
			e cell addText: 'Zip:'.
			e newCell addInputFieldAspect: #zip for: self observee. e newRow.
			e cell addText: 'Phone:'.
			e newCell addInputFieldAspect: #phone for: self observee. e newRow.
			e cell addText: 'Fax:'.
			e newCell addInputFieldAspect: #fax for: self observee. e newRow.
			e cell addText: 'E-mail:'.
			e newCell addInputFieldAspect: #email for: self observee. e newRow.
			e cell addText: 'Website:'.
			e newCell addInputFieldAspect: #website for: self observee. e newRow; newRow.
			e cell addText: 'Username:'.
			e newCell addInputFieldAspect: #username for: self observee. e newRow].
	e cell addText: ' New password:'.
	e newCell addPasswordFieldAspect: #newPassword for: self.
	e newRow.
	e cell addText: 'Confirm password:'.
	e newCell addPasswordFieldAspect: #newPasswordConfirmation for: self.
	e newRow.
	e cell addButtonText: 'Save'.
	^e! !

!WebUserApp methodsFor: 'views-edit' stamp: 'janko 11/1/2011 20:03'!
editGroupsPopup
	| e |
	e := WebElement new. e table width: 1.
	e cell colspan:2; addRuler. e newRow.
	e cell add: ((WebGrid new width: 250)
		columnNames: #(nil nil 'Name'); columnAlign: #(nil nil left);
		columnAspects: #(nil nil name);
		columnLinkViews: #(nil nil main);
		column: 2 addBlock: [:grp | WebCheckBox newForObject: grp from: self groups ];
		collection: (self site securityManager allGroups asSortedCollection: [:a :b | a  name < b name]);
		setNumbering;
		yourself).
	(e cell addButtonText: 'Save' action: #changeGroups)
		onSubmitDo: [self actionMainChangeGroups];
		onSubmitClose.
	e cell addSpace. e cell addCloseLinkText: '<small>Cancel without saving<small>'.
	^e! !


!WebUserApp methodsFor: 'accessing'!
groups
	groups isNil ifTrue: [self  initialGroups].
	^groups! !

!WebUserApp methodsFor: 'accessing'!
initialGroups
	groups := self observee groups! !

!WebUserApp methodsFor: 'accessing' stamp: 'np 10/21/2008 22:44'!
newPassword
	^ newPassword! !

!WebUserApp methodsFor: 'accessing' stamp: 'np 10/21/2008 22:47'!
newPassword: aString
	newPassword := aString! !

!WebUserApp methodsFor: 'accessing' stamp: 'np 10/21/2008 22:44'!
newPasswordConfirmation
	^ newPasswordConfirmation! !

!WebUserApp methodsFor: 'accessing' stamp: 'np 10/21/2008 22:47'!
newPasswordConfirmation: aString
	newPasswordConfirmation := aString! !


!WebUserApp methodsFor: 'views'!
viewAdd
	^self viewEdit! !

!WebUserApp methodsFor: 'views'!
viewEdit
	| e |
	self canBeViewed ifFalse: [^self redirectTo: self site admin view: #login].
	self title: 'Edit user ', self observee nameSurname.
	e := WebElement new.
	e add: self hierarchyLinksElement; addBreak.
	e addTextH1: self title;
		addBreak;
		addErrorReport;
		add: self editElement.
	self style pageFrameWith: e title: self title! !

!WebUserApp methodsFor: 'views'!
viewMain
	| e |
	self canBeViewed ifFalse: [^self redirectTo: self site admin view: #login].
	self title: 'Profile for ', self observee nameSurname.
	e := WebElement new.
	e add: self hierarchyLinksElement; addBreak.
	e addTextH1: self title;
		addText: self style profileIntroMessage;
		add: self basicInfoElement;
		add: self contactInfoElement;
		add: self groupsAndActivityElement;
		add: self actionsLineElement.
	self style pageFrameWith: e title: self title! !

!WebUserApp methodsFor: 'views'!
viewSessions
	| e |
	self canBeViewed ifFalse: [^self redirectTo: self site admin view: #login].
	self title: 'Sessions for ', self observee nameSurname.
	e := WebElement new.
	e add: self hierarchyLinksElement; addBreak.
	e addTextH1: self title;
		addText: self style profileIntroMessage;
		add: self sessionsElement.
	self style pageFrameWith: e title: self title! !


WebApplication subclass: #WebUserGroupApp
	instanceVariableNames: 'usersInGroup'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Admin'!
!WebUserGroupApp commentStamp: '<historical>' prior: 0!
WebUserGroupApp for viewing and editing group information

!


!WebUserGroupApp methodsFor: 'views-elements'!
adminElement
	| e |
	e := WebElement new.
	e addLinkTo: self observee text: ' Select users ' view: #selectUsers;
		add: ((WebLink text: ' Access rights ' linkTo: self site securityManager)
			view: #aclObjects;
			parameter: 'who' value: self observee uuid).
	^e! !

!WebUserGroupApp methodsFor: 'views-elements'!
hierarchyLinksElement
	| e |
	e := WebElement new.
	e addText: self site name, ' / '.
	e addLinkTo: self site securityManager text: 'Security'.
	e addText: ' / '.
	e addLinkTo: self site securityManager text: 'Groups' view: #groups.
	e addText: ' / '.
	e addLinkTo: self observee text: '<b>', self observee name, '</b>'.
	^e! !

!WebUserGroupApp methodsFor: 'views-elements'!
lockIconTitled: aString
	| e |
	e := WebElement new.
	e addNbSp; add:
		((WebImage png: #lockSmallPng) title: aString).
	^e! !

!WebUserGroupApp methodsFor: 'views-elements'!
userSelectionElement
	^ (WebGrid new width: self style pageContentWidth)
		columnNames: #(nil nil 'Username' 'Name');
		columnAspects: #(nil nil username nameSurname);
		columnLinkViews: #(nil nil main main);
		columnFilters: #(nil nil true true);
		column: 2 addBlock: [:usr | usr isLocked not
			ifTrue: [(WebCheckBox newForObject: usr from: self observee users) onChangePost]
			ifFalse: [self lockIconTitled: 'user locked for change and delete'] ];
		collection: (self site securityManager allUsers 
			asSortedCollection: [:u1 :u2 | u1 username < u2 username]);
		setNumbering;
		rowsOnPage: 20;
		yourself! !

!WebUserGroupApp methodsFor: 'views-elements'!
usersGridElement
	^ (WebGrid new width: self style pageContentWidth)
		columnNames: #(nil 'Username' 'Name');
		columnAspects: #(nil username nameSurname);
		columnLinkViews: #(nil main main);
		collection: (self observee allUsers asSortedCollection: [:u1 :u2 | u1 username < u2 username]);
		columnFilters: #(nil true true);
		setNumbering;
		rowsOnPage: 20;
		yourself! !


!WebUserGroupApp methodsFor: 'accessing'!
aidaDontCache
	"always refresh pages, to deal with back button correctly"
	^true! !

!WebUserGroupApp methodsFor: 'accessing' stamp: 'np 10/22/2008 15:37'!
usersInGroup
	^ usersInGroup! !

!WebUserGroupApp methodsFor: 'accessing' stamp: 'np 10/22/2008 15:37'!
usersInGroup: anObject
	usersInGroup := anObject! !


!WebUserGroupApp methodsFor: 'views'!
viewMain
	| e  |
	self title: 'Group ', self observee name.
	e := WebElement new.
	e add: self hierarchyLinksElement; addBreak.
	e addTextH1: self title; addBreak.
	e add: self adminElement. e addBreak.
	e add: self usersGridElement.
	self style pageFrameWith: e title: self title! !

!WebUserGroupApp methodsFor: 'views'!
viewSelectUsers
	| e  |
	self title: 'Select members of group ', self observee name.
	e := WebElement new.
	e add: self hierarchyLinksElement; addBreak.
	e addTextH1: self title; addBreak.
	e add: self errorReport. "if any"
	e addText: 'Note: members are immediatelly added or removed from group after they are checked/unchecked!!'.
	e add: self userSelectionElement.
	self style pageFrameWith: e title: self title! !
