Object subclass: #WebApplication
	instanceVariableNames: 'session observee contexts other'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Applications'!
!WebApplication commentStamp: '<historical>' prior: 0!
WebApplication is a superclass of all App subclasses for presentations (VC in MVC pattern) of domain objects on the web. By convention the App class is named DomainClass+App, for example PersonApp for Person domain class!


!WebApplication methodsFor: 'private-form posting'!
acceptInputsAndActionFrom: aRequest
	|  form |
	form := self formPostedFrom: aRequest.
	form acceptInputsFrom: aRequest.
	self callActionFrom: aRequest. "if any"! !

!WebApplication methodsFor: 'private-form posting'!
callActionFrom: aRequest
	"Calls an action method if any"
	| form |
	form := aRequest context form.
	aRequest isAjaxPostWithSingleInput ifFalse:     "ajax posts of single form elements doesn't trigger actions!!"
		[self callActionMethodForButton: (form buttonFrom: aRequest) on: aRequest context].
	(aRequest session shouldRedirect not and: [aRequest isAjaxRequest not]) ifTrue:
		[self redirectToView: aRequest view]   " after post always redirect to avoid aidaCtx in Urls!! "! !

!WebApplication methodsFor: 'private-form posting'!
callActionMethodForButton: aButton on: aContext
	"name of button pressed is in argument"
	| methd |
	methd := self class actionMethodForView: aContext view button: aButton. 
	methd notNil 
		ifTrue: [self perform: methd asSymbol]
		ifFalse: [self reportMissingActionMethodIfNeeded].
	self announceAction: aButton action onView: aContext view! !

!WebApplication methodsFor: 'private-form posting'!
formPostedFrom: aRequest
	"get a form from which input is posted by this request"
	| elementToUpdate |
	aRequest isAjaxRequest ifFalse: [^aRequest context form].
	aRequest isAjaxPostWithSingleInput ifTrue: 
		[^(aRequest context form fieldNamed: aRequest ajaxSingleInputName) form].
	elementToUpdate := aRequest context elementId: aRequest ajaxElementId.
	elementToUpdate isNil ifTrue: [^aRequest context form]. "always?"
	elementToUpdate isStubElement ifTrue: [^aRequest context form]. 
	^elementToUpdate creationObject isWebWidget
			ifTrue: [elementToUpdate creationObject form]
			ifFalse: [aRequest context form]. "form of currently shown window/page"! !

!WebApplication methodsFor: 'private-form posting'!
reportMissingActionMethodIfNeeded
	self error: 'Action method missing or with wrong name. Name must be composed as ''action''+viewname+action(optional), like #actionMainSave, if you put button with action: #save in viewMain'! !


!WebApplication methodsFor: 'private-obsolete' stamp: ' 21/4/07 22:07'!
actionMainSearch
	self actionSearch! !

!WebApplication methodsFor: 'private-obsolete'!
actionSearch
	"a generic action when search button is pressed. It can be in almost every page."
	| indexApp |
	indexApp := self site index aidaWebAppFor: self session.
	indexApp searchString: self search. self search: ''.
	indexApp actionMain.
	self redirectTo: self site index view: #results! !

!WebApplication methodsFor: 'private-obsolete'!
ajaxUpdate: anOldElement from: anElementToRecreate on: aRequest
	"prepare to update (recreate or refresh) that element by returning a recreated one"
	| new different |
	anOldElement isNil ifTrue:  [^WebElement new]. "only arguments/command was sent. Process it before!! "
	anElementToRecreate isNil ifTrue: [^WebElement new]. "can happen after window/context closing"
	anElementToRecreate creationMethod isNil ifTrue: [^anOldElement]. "in form elements it will return new value!!"
	aRequest context afterCloseUpdate:  anElementToRecreate afterCloseUpdate "element to update, if any".
	different := (anOldElement == anElementToRecreate) not.  "content will be from element different that old one"
	different not ifTrue:     "only when content will be from the old element. "
		[aRequest context announceReplacementWith: anOldElement]. "for reset see WebElement class>>new"
	new := anOldElement isWebWidget
		ifTrue: [self ajaxUpdateWidget: anOldElement from: anElementToRecreate on: aRequest]
		ifFalse: [(anElementToRecreate creationObject notNil 
				and: [anElementToRecreate creationObject isWebWidget]) 
			ifTrue: [self ajaxUpdateWidgetElement: anOldElement from: anElementToRecreate on: aRequest] 
			ifFalse: [self ajaxUpdateAppElement: anOldElement from: anElementToRecreate on: aRequest] ].
	aRequest context cancelReplacement. "if any"
	^new! !

!WebApplication methodsFor: 'private-obsolete'!
ajaxUpdateAppElement: anOldElement from: anElementToRecreate on: aRequest
	"prepare to update (recreate or refresh) some element in current App by returning a recreated one"
	| argument new |
	argument := aRequest postDataStringAt: 'parm'.   "element creation method with an argument (parm) "
	('view*' match: anElementToRecreate creationMethod asString) ifTrue: 
		[^self error: 'Cannot Ajax update views!! View in question: #', anElementToRecreate method].
	new := (self class canUnderstand: anElementToRecreate creationMethod) 
		ifTrue: [(anElementToRecreate creationMethod asString last = $: )
			ifTrue: [self perform: anElementToRecreate creationMethod with: argument ] "object method: parm"
			ifFalse: [argument notNil  "try to call the method with that argument"
				ifTrue: [self perform: (anElementToRecreate creationMethod, ':') asSymbol with: argument]
				ifFalse: [self perform: anElementToRecreate creationMethod] ] ]
		ifFalse: [self error: 'App does not  understand this update method!!' " WebElement new method: nil"].
	^new! !

!WebApplication methodsFor: 'private-obsolete'!
ajaxUpdateWidget: anOldElement from: anElementToRecreate "widget" on: aRequest
	"prepare to update (recreate or refresh) that widget by returning a recreated one"
	| argument creationObject superform new |
	argument := aRequest postDataStringAt: 'parm'.   "element creation method with an argument (parm) "
	creationObject := anElementToRecreate creationObject.
	superform := anElementToRecreate form superform.
	superform removeSubform: anElementToRecreate form.
	aRequest context cancelReplacement. "widget is rebuilt, not replaced with new instance!!"
	new := (creationObject class canUnderstand: anElementToRecreate creationMethod) 
		ifTrue: [(anElementToRecreate creationMethod asString last = $: )
			ifTrue: [creationObject perform: anElementToRecreate creationMethod with: argument ] 
			ifFalse: [argument notNil  "try to call the method with that argument"
				ifTrue: [creationObject perform: (anElementToRecreate creationMethod, ':') asSymbol with: argument]
				ifFalse: [creationObject perform: anElementToRecreate creationMethod] ] ]
		ifFalse: [self error: 'App does not  understand this update method!!' " WebElement new method: nil"].
	superform addSubform: new form.
	^new! !

!WebApplication methodsFor: 'private-obsolete'!
ajaxUpdateWidgetElement: anOldElement from: anElementToRecreate "widget" on: aRequest
	"prepare to update (recreate or refresh) some element in that widget by returning a recreated one"
	| argument creationObject new |
	argument := aRequest postDataStringAt: 'parm'.   "element creation method with an argument (parm) "
	creationObject := anElementToRecreate creationObject.
	new := (creationObject class canUnderstand: anElementToRecreate creationMethod) 
		ifTrue: [(anElementToRecreate creationMethod asString last = $: )
			ifTrue: [creationObject perform: anElementToRecreate creationMethod with: argument ] 
			ifFalse: [argument notNil  "try to call the method with that argument"
				ifTrue: [creationObject perform: (anElementToRecreate creationMethod, ':') asSymbol with: argument]
				ifFalse: [creationObject perform: anElementToRecreate creationMethod] ] ]
		ifFalse: [self error: 'Widget does not  understand this update method!!' " WebElement new method: nil"].
	^new! !

!WebApplication methodsFor: 'private-obsolete'!
ask: aWebElement
	"ask for something, like delete confirmation dialog. Stop execution here until the result is returned. Return 
	that result. See WebDemoApp control flow for examples"
	self show: aWebElement.
	^self context answer! !

!WebApplication methodsFor: 'private-obsolete' stamp: ' 21/4/07 22:07'!
indexObservee
	"index or reindex observee of that app"
	^self site index indexObject: self observee! !

!WebApplication methodsFor: 'private-obsolete'!
respondToAjaxAutocomplete: aRequest
	|  form fieldName fieldValue field choices e |
	form := self formPostedFrom: aRequest.
	fieldName := aRequest ajaxSingleInputName.
	fieldValue := (aRequest "context request" postDataAt: fieldName) value.
	fieldValue := AIDASite convert: fieldValue fromCodepage: #utf8.
	field := form fields at: fieldName. 
	choices := field getChoicesForEntry: fieldValue.
	e := WebList newUnordered.
	choices do: [:each || string |
		string := each convertToSloveneChars.
		e add: (WebRawText text: (AIDASite convert: string toCodepage: #utf8))].
	^e! !

!WebApplication methodsFor: 'private-obsolete'!
respondToAjaxCloseWindow: aRequest
	"OBSOLETE"
	| ctx |
	ctx := aRequest context.
	ctx result: WebElement basicNew.
	ctx parent result: ctx result. "just in case"
	ctx first mainSemaphore signal. " to ensure continuing main thread"
	ctx parent isFirst ifTrue: [ctx parent stopProcess].  "we don't need it anymore"
	ctx close. "finaly the time to safely close our context"! !

!WebApplication methodsFor: 'private-obsolete'!
respondToAjaxInPlaceEditing: aRequest
	"field is immediatelly posted/saved!! "
	| fieldValue field response |
	field := aRequest context elementId: aRequest ajaxElementId.
	field isFormated & aRequest isAjaxWikiFormatedRequest not  ifFalse:
		[fieldValue := (aRequest postDataAt: 'value') value.
		fieldValue := AIDASite convert: fieldValue fromCodepage: #utf8.
		field value: fieldValue.
		field save].
	response := field value.
	aRequest isAjaxWikiFormatedRequest ifTrue: [response := response asWikiHtml].
	response := AIDASite convert: response toCodepage: #utf8.
	^WebElement new add: (WebRawText text: response); yourself! !

!WebApplication methodsFor: 'private-obsolete'!
respondToAjaxRequest: aRequest
	| oldElement elementToRecreate e result ctx |
	oldElement := aRequest context elementId: aRequest ajaxElementId. "should be here, its context stil alive"
	elementToRecreate := aRequest context elementId: aRequest ajaxElementToRecreateId.
	aRequest isAjaxInPlaceEditingRequest ifTrue: [^self respondToAjaxInPlaceEditing: aRequest].
	aRequest isAjaxAutocompleteRequest ifTrue: [^self respondToAjaxAutocomplete: aRequest].
	aRequest isAjaxPostWithInput ifTrue: [self acceptInputsAndActionFrom: aRequest].
	aRequest isAjaxCloseWindowRequest ifTrue: [self respondToAjaxCloseWindow: aRequest]. "then continue here!!"
	aRequest isAjaxPopupWindowRequest 
		ifTrue: 
			[ctx := aRequest context createNewContext. "is also added to context chain and also to this app"
			ctx event: aRequest.
			aRequest context: ctx. "switch to a new context during th rest of execution"
			e := self ajaxUpdate: oldElement from: elementToRecreate on: aRequest. 
			e := self wrap: e intoPopupWindow: ctx window] "e is now window with wrapped element"
		ifFalse: 
			[e := self ajaxUpdate: oldElement from: elementToRecreate on: aRequest]. 
	e registerFormElements.
	e prepareToHtmlStreamingOn: self session. "to prepare again"
	result := e copy.
	result nilAttributes. "to be just plain element, no div,  to send inner html of original element only"
	aRequest context result: result.
	^result! !

!WebApplication methodsFor: 'private-obsolete'!
show: aWebElement
	"show something like info dialog. Stop execution here until the dialog is closed. 
	See WebDemoApp control flow for examples"
	| ourCtx popupCtx |
	ourCtx := self context.
	popupCtx := ourCtx request context createNewContext. "is also added to context chain and also to this app"
	popupCtx request: ourCtx request.
	ourCtx request context: popupCtx. "switch to a new context during the rest of execution"
	popupCtx result:
		(self wrap: aWebElement intoPopupWindow: popupCtx window). "e is now window with wrapped element"
	popupCtx result changeContextFrom: ourCtx to: popupCtx. "scan for all references to contexts and change them"
	aWebElement registerFormElementsTo: popupCtx form.  "probably already, but just to be sure"
	ourCtx first mainSemaphore signal. "to return that popup"
	ourCtx wait.
	"now the execution of our process is interrupted until the popup window and therefore its context is closed"! !

!WebApplication methodsFor: 'private-obsolete'!
visitsCount
	"returns number of visits of this page"
     ^(self site urlResolver counterFor: self observee)
		total! !


!WebApplication methodsFor: 'private-window delegation'!
add: aWebElement
	"add to a form of currently executing context"
	^self context form add: aWebElement! !

!WebApplication methodsFor: 'private-window delegation'!
cell
	"delegate to the form of currently executing context"
	^self context form cell! !

!WebApplication methodsFor: 'private-window delegation'!
clear
	"delegate to the form of currently executing context"
	super clear. "overall app stuff"
	^self context form clear "view specific stuff"! !

!WebApplication methodsFor: 'private-window delegation'!
newCell
	"delegate to the form of currently executing context"
	^self context form newCell! !

!WebApplication methodsFor: 'private-window delegation'!
newRow
	"delegate to the form of currently executing context"
	^self context form newRow! !

!WebApplication methodsFor: 'private-window delegation'!
newTable
	"delegate to the form of currently executing context"
	^self context form newTable! !

!WebApplication methodsFor: 'private-window delegation'!
row
	"delegate to the form of currently executing context"
	^self context form row! !

!WebApplication methodsFor: 'private-window delegation'!
table
	"delegate to the form of currently executing context"
	^self context form table! !

!WebApplication methodsFor: 'private-window delegation'!
title
	"delegate to the window of currently executing context"
	^self context page title! !

!WebApplication methodsFor: 'private-window delegation'!
title: aStringOrMultilangAssociation
	"delegate to the window of currently executing context"
	^self context page title: aStringOrMultilangAssociation! !


!WebApplication methodsFor: 'private-contexts'!
addContext: aContext
"	Transcript cr; show: '*** application add ', (aContext isFirst ifTrue: ['first'] ifFalse: ['']), ' context ', 
		aContext id printString, ' on ', self class printString, 
		(aContext isFirst ifTrue: [' view #', aContext view] ifFalse: ['']).
"	self contexts 
		at: aContext id 
		put: aContext! !

!WebApplication methodsFor: 'private-contexts'!
contextForView: aSymbol
	^self contexts values 
		detect: [:ctx | ctx isFirst and: [ctx view = aSymbol] ] 
		ifNone: [nil]! !

!WebApplication methodsFor: 'private-contexts'!
contexts
	"a dictionary of context by context id (a unique number)"
	contexts isNil ifTrue: [self initContexts].
	^contexts! !

!WebApplication methodsFor: 'private-contexts'!
findContextFor: aRequest
	"POSTs, Ajax and realtime requests must always have context ids!!"
	| id |
	id := aRequest contextId.
	(id isNil or: [(self contexts includesKey: id) not]) 
		ifTrue: [^nil].
	^self contexts 
		at: id! !

!WebApplication methodsFor: 'private-contexts'!
findContextSameViewFor: aRequest
	"if a context for the requested view already exist, use it"
	"OBSOLETE 6.8 may20"
	| requestedView |
	requestedView := aRequest view. 
	requestedView isNil ifTrue: [requestedView := #main].
	^self contextForView: requestedView! !

!WebApplication methodsFor: 'private-contexts'!
findCreateOrSerializeContextFor: aRequest
	"and set the current context and view"
	"for posts and ajax request the context id must always be present in request!!"
	"Since Aida6.8 may20 a new context is always created for GET requests" 
	"Serialize execution if some other request is already executing"
	| ctx |
	ctx := self findContextFor: aRequest. "if request include context id"
	(ctx isNil and: [aRequest isPost or: [aRequest isAjaxRequest]]) ifTrue: [^nil]. "this should not happen!!"
"	ctx isNil ifTrue: [ctx := self findContextSameViewFor: aRequest]." "obsolete, always new ctx for GET!!"
	ctx isNil ifTrue: 
		[ctx := (WebContextFirst newOn: self) view: aRequest view.
		self addContext: ctx].
	ctx event: aRequest.
	aRequest context: ctx.
	^ctx! !

!WebApplication methodsFor: 'private-contexts'!
removeContext: aContext
"	Transcript cr; show: '*** application remove ', (aContext isFirst ifTrue: ['first'] ifFalse: ['']), ' context ', 
		aContext id printString, ' on ', self class printString,
		(aContext isFirst ifTrue: [' view #', aContext view] ifFalse: ['']).
"	self contexts 
		removeKey: aContext id 
		ifAbsent: []! !


!WebApplication methodsFor: 'accessing'!
aidaDontCache
	"set to true in your Apps if views/pages must be always reloaded, never cached"
	^false! !

!WebApplication methodsFor: 'accessing'!
app
	^self! !

!WebApplication methodsFor: 'accessing'!
context
	"a currently executing context, from a web request or realtime event"
	| ctx |
	ctx := self firstContextFromStack.
	ctx ifNotNil: [^ctx].
 	self contexts values    "for tests to work, otherwise this is invalid!! "
		detect: [:each | each isFirst and: [each view = #main] ] 
		ifNone: [nil]! !

!WebApplication methodsFor: 'accessing'!
defaultView
	" #main "
	^self class defaultView! !

!WebApplication methodsFor: 'accessing'!
enableRealtime
	"Enable realtime (WebSocket) support for a current view"
	"set also site #websocketsEnabled setting to actually work"
	self page 
		enableRealtime! !

!WebApplication methodsFor: 'accessing'!
inDefaultView
	"#main or not defined"
	^(self view = self defaultView) | (self view = #'')! !

!WebApplication methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
observee
	"return reference to an object, for which this app acts as an observer - to make an user interface
	of them"
	^observee! !

!WebApplication methodsFor: 'accessing'!
page
	"a webpage on which currently built view is shown"
	^self context page! !

!WebApplication methodsFor: 'accessing'!
session
	"on which this App represent the observed domain object"
	^session! !

!WebApplication methodsFor: 'accessing'!
site
	"reference to a site on which this app shows some object. "
	self session ifNil: [^nil].
	^self session site! !

!WebApplication methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
style
	^self site style! !

!WebApplication methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
user
	"reference to a user of current session "
	^self session user! !

!WebApplication methodsFor: 'accessing'!
view
	"view of currently executing web context"
	"use sparingly, slow!! "
	^self context view! !

!WebApplication methodsFor: 'accessing'!
window
	"window in of currently executing web context"
	"use sparingly, slow!! "
	^self context window! !


!WebApplication methodsFor: 'private-composing'!
aidaIsRespondingNeverStreamed
	^false! !

!WebApplication methodsFor: 'private-composing'!
aidaIsRespondingStreamed
	^self context page aidaIsRespondingStreamed! !

!WebApplication methodsFor: 'private-composing'!
composeWebPageFor: aRequest 
	| ctx |
	ctx := self findCreateOrSerializeContextFor: aRequest. "for posts and ajax just find, never create. 
														Request's context is also set"
	ctx  isNil ifTrue: 
		[^WebPage new addText: 'request for unknown or nonexistent context!!'; yourself].
	self resetNeverCache. 
	(aRequest isPost and: [aRequest isAjaxRequest not]) "be sure to call that before any post data is accessed!! "
		ifTrue: [ctx form registerStreamedFieldsInto: aRequest]. 
	(aRequest isPost and: [self site contextProcesses])
		ifTrue: [ctx startProcess]. "if not already. Always for posts and Ajax"
	^self composeWebPageStepTwoFor: aRequest.! !

!WebApplication methodsFor: 'private-composing'!
composeWebPageStepTwoFor: aRequest 
	| toLogin |
	self observee isMultilingual 
		ifTrue: [self checkObserveeLanguageFor: aRequest ].  "and change observee if needed"
	self isObserveeVersioned 
		ifTrue: [self checkObserveeVersionFor: aRequest ]. "and change observee if needed"
	toLogin := false. "self isEncryptionSatisfied ifTrue: [toLogin := true]."
	(aRequest  isPost and: [aRequest  isAjaxRequest not]) ifTrue: 
		[(self updateAllowed: aRequest context view) 
			ifTrue: [self acceptInputsAndActionFrom: aRequest] 
			ifFalse: [toLogin := true. self reportSecurityViolationType: #update] ].
	toLogin ifTrue:
		[(self observee == self site admin and: [self session newView = 'login']) 
			ifFalse: [self redirectTo: self site admin view: #login].
		^WebPage new].
	self session lastApp: self. "!!!!!!"
 	aRequest isAjaxRequest ifTrue: [^self respondToAjaxRequest: aRequest].
	self session shouldRedirect ifTrue: [^WebPage new].
	self setProcessFromTaskId. "for BPM engine, if present"
	^self composeWebView: aRequest context view for: aRequest.! !

!WebApplication methodsFor: 'private-composing'!
composeWebView: aViewSymbol for: aRequest
 	"build a web page for that view"
	| method page form |
	aRequest context page clear; clearAttributesExceptId; setRandomId;
		initPageHeaderLinks.
	aRequest context form initFields.
	method := self class viewMethodForView: aViewSymbol. 
	method ifNil: 
		[^WebElement new addTextH3: 'ERROR: view named ', aViewSymbol printString, ' does not exist'; yourself].
	^(self viewAllowed: aViewSymbol)
		ifTrue:
			["self site frameApp instance initialize."  "for potential external content in IFRAME" 
			self debugAfter: 10 "s".   "to find endless loops etc. "
			page := self perform: method. "like #viewMain etc. "
			page isWebApplication ifTrue: 
				[form := aRequest context form.
				self session inTranslationMode ifTrue: [form prepareForTranslation]. "in-line edit"
				aRequest context window registerFormElements]. "must be after above transl.preparation!!"
			self storeThisUrl.
			aRequest context setLoaded.
			aRequest context mustNeverCache ifTrue: [self setNeverCache].
			self announceView: aViewSymbol.
			self stopDebugEvent. "if started"
			page]
		ifFalse: 
			["self reportSecurityViolationType: #view."
			self redirectTo: self site admin view: #login.
			WebPage new].! !

!WebApplication methodsFor: 'private-composing'!
storeThisUrl
	"to a User. It is helpull for return after logon, for instance"
	self user lastAppUrl: self session lastRequest uriString! !

!WebApplication methodsFor: 'private-composing'!
streamHtmlTo: aStream for: aRequest on: aSession
	"For apps we print a window of currently executing context"
	^aRequest context page 
		streamHtmlTo: aStream 
		for: aRequest 
		on: aSession.! !


!WebApplication methodsFor: 'private' stamp: 'jm 8/25/2009 20:53'!
announceAction: anActionSymbol onView: aSymbol
	"Squeak specific"
	"When Squeak will have Announcements by default ..."
"	self announce: 
		(AppActionTrigered for: self observee on: self session view: aSymbol action: anActionSymbol)
"! !

!WebApplication methodsFor: 'private' stamp: 'jm 8/25/2009 20:52'!
announceView: aSymbol
	"Squeak specific"
	"When Squeak will have Announcements by default ..."
"	self  announce: 
		(AppViewShowed for: self observee on: self session view: aSymbol)
"! !

!WebApplication methodsFor: 'private' stamp: ' 21/4/07 22:07'!
mode: aSymbol
	"portlet modes #view #edit "
	self otherAt: #Mode put: aSymbol! !

!WebApplication methodsFor: 'private'!
neverCache
	"temporary flag to avoid caching=always reload a page"
	^self 
		otherAt: #NeverCache
		ifAbsent: [false]! !

!WebApplication methodsFor: 'private' stamp: ' 21/4/07 22:07'!
observee: anObject
	"set the reference to an object, for which this app acts as an observer - to make an user interface
	of them"
	observee := anObject! !

!WebApplication methodsFor: 'private'!
pageContentWidth
	"obsolete, rather use direct: self  style... !! "
	^self style pageContentWidth! !

!WebApplication methodsFor: 'private'!
removeYourself
	"called during session application state cleanup"
	self session isNil ifTrue: [^nil].
	self observee notNil ifTrue:
		[self session removeApp: self for: self observee type: #web].
	self session: nil.
	self observee: nil.! !

!WebApplication methodsFor: 'private'!
resetNeverCache
	"temporary flag to avoid caching=always reload a page"
	self 
		otherAt: #NeverCache
		put: false.! !

!WebApplication methodsFor: 'private'!
session: aWebSession
	"on which this App represent the observed domain object"
	session := aWebSession! !

!WebApplication methodsFor: 'private'!
setCreatedTimestamp
	^self 
		otherAt: #CreatedTimestamp 
		put: SpTimestamp now! !

!WebApplication methodsFor: 'private'!
setNeverCache
	"temporary flag to avoid caching=always reload a page"
	self 
		otherAt: #NeverCache
		put: true.! !

!WebApplication methodsFor: 'private'!
setStandaloneApp
	"it is not a representation of some domain object in MVC fashion"
	self otherAt: #StandaloneApp put: true! !

!WebApplication methodsFor: 'private'!
stopDebugEvent
	"if started then stop an event which raise debuger of request processing tekes too long"
	"see #debugAfter:"
	| event |
	event := self otherAt: #DebugAfterEvent.
	event ifNotNil: 
		[event stop.
		self other removeKey: #DebugAfterEvent].
	self other 
		removeKey: #CurrentProcess ifAbsent: [].! !


!WebApplication methodsFor: 'private-versions' stamp: 'janko 7/18/2008 22:22'!
changeObserveeToVersionFor: aRequest
	| object |
	object := self observee versionWithNumber: (self versionFromRequest: aRequest).
	object notNil ifTrue: [self observee: object]! !

!WebApplication methodsFor: 'private-versions' stamp: 'janko 7/18/2008 22:25'!
checkObserveeVersionFor: aRequest
	"change observee to point to correct version if necessary"
	(self isVersionRequest: aRequest) ifTrue: [^self changeObserveeToVersionFor: aRequest].
	self observee isCurrentVersion ifFalse: [self observee: self observee currentVersion].! !

!WebApplication methodsFor: 'private-versions' stamp: ' 21/4/07 22:07'!
isObserveeVersioned
	^self observee isVersionedObject! !

!WebApplication methodsFor: 'private-versions' stamp: 'janko 7/18/2008 22:26'!
isVersionRequest: aRequest
	^(self versionFromRequest: aRequest) notNil! !

!WebApplication methodsFor: 'private-versions' stamp: 'np 10/20/2008 16:39'!
versionFromRequest: aRequest
	"for Ajax requests too!!"
	| version |
	version := aRequest queryAt: 'version'.
	version isNil ifTrue:
		[aRequest isAjaxRequest ifFalse: [^nil].
		version := aRequest isPost
			ifTrue: [(aRequest postDataAt: 'version') value]
			ifFalse: [aRequest queryAt: 'version'] ].
	^version! !


!WebApplication methodsFor: 'private-multilingual' stamp: 'janko 11/12/2008 20:08'!
checkObserveeLanguageFor: aRequest
	"change observee to point to domain object in right language if necessary 
	(from session language or explicit language request in query part of Url)"
	| language new |
	(self isLanguageRequest: aRequest) "language= in query part of url"
		ifTrue: [self session language: (aRequest queryAt: 'language') asSymbol].
	language := self session language.
	new := self observee forLanguage: language.
	new notNil ifTrue: [self observee: new]! !

!WebApplication methodsFor: 'private-multilingual' stamp: 'janko 7/18/2008 22:26'!
isLanguageRequest: aRequest
	^(aRequest queryAt: 'language') notNil! !


!WebApplication methodsFor: 'clipboard' stamp: ' 21/4/07 22:07'!
clipboard
	^self session clipboard! !

!WebApplication methodsFor: 'clipboard'!
copyToClipboard
	"copy an url and title of current view of observee object to web clipboard"
	| object titlee|
	object := self observee isVersionedObject
		ifTrue: [self observee currentVersion] "so that link will be aways same regardles of version!!"
		ifFalse: [self observee].
	titlee := (object class canUnderstand: #id) ifTrue: [object id, ' '] ifFalse: [''].
	titlee := (object class canUnderstand: #title) ifTrue: [titlee, object title] ifFalse: [nil].
	titlee isNil ifTrue: 
		[titlee := (object class canUnderstand: #indexTitle) ifTrue: [object indexTitle] ].
	titlee isNil ifTrue: [titlee := self title].
	self clipboard 
		title: titlee;
		url: (self site urlResolver halfUrlFor: object);
		object: object! !

!WebApplication methodsFor: 'clipboard' stamp: ' 21/4/07 22:07'!
pasteFromClipboard
	"get a DocLink with title and url. Nil if clipboard empty"
	self clipboard isEmpty ifTrue: [^nil].
	^self clipboard asDocLink! !


!WebApplication methodsFor: 'accessing-other'!
createdTimestamp
	^self otherAt: #CreatedTimestamp ifAbsent: [nil]! !

!WebApplication methodsFor: 'accessing-other' stamp: ' 21/4/07 22:07'!
search
	^self otherAt: #Search! !

!WebApplication methodsFor: 'accessing-other' stamp: ' 21/4/07 22:07'!
search: aString
	"search input field"
	self otherAt: #Search put: aString! !


!WebApplication methodsFor: 'support'!
debugAfter: aSeconds
	"open debugger if processing of current request takes too long, longer than aSeconds"
	"for finding endless loops in user code"
	"add this call at the start of view methods"
	| event process |
	event := self otherAt: #DebugAfterEvent ifAbsent: [nil].
	event ifNotNil: [event stop].
	self otherAt: #CurrentProcess put: Processor activeProcess.
	event := self 
		otherAt: #DebugAfterEvent
		put: (self site scheduler 
			at: (SpTimestamp fromSeconds: SpTimestamp now asSeconds + aSeconds)
			runBlock: 
				[process := self otherAt: #CurrentProcess.
				process suspend.
				process openDebugger]).
	event 
		priority: Processor userInterruptPriority "should be higher than that in Swazoo request process"! !


!WebApplication methodsFor: 'error reporting' stamp: 'janko 9/30/2011 11:38'!
errorReport
	"element with report of errors, if any"
	| e |
	e := WebElement newId: #error.  "see WebStyle css42ErrorReport for style definition!! "
	self showError notNil ifTrue: 
		[(e addText: self showError) style: '{color: red}'].
	self showError: nil.
	^e! !

!WebApplication methodsFor: 'error reporting'!
inError
	^self showError notNil and: [self showError notEmpty]! !

!WebApplication methodsFor: 'error reporting'!
showError
	^self otherAt: #Error! !

!WebApplication methodsFor: 'error reporting'!
showError: aString
	"error message to be written on web page. "
	self otherAt: #Error put: aString! !


!WebApplication methodsFor: 'accessing-modes' stamp: ' 21/4/07 22:07'!
inEditMode
	^self mode = #edit! !

!WebApplication methodsFor: 'accessing-modes' stamp: ' 21/4/07 22:07'!
inViewMode
	^self mode = #view! !

!WebApplication methodsFor: 'accessing-modes' stamp: ' 21/4/07 22:07'!
mode
	| mode |
	mode := self otherAt: #Mode.
	^mode isNil 
		ifTrue: [self setViewMode. self mode] 
		ifFalse: [mode]! !

!WebApplication methodsFor: 'accessing-modes' stamp: ' 21/4/07 22:07'!
setEditMode
	self mode: #edit! !

!WebApplication methodsFor: 'accessing-modes' stamp: ' 21/4/07 22:07'!
setViewMode
	self mode: #view! !


!WebApplication methodsFor: 'private-security'!
initAdminAccess
	"admin group has rights to all views and updates in all Apps!! "
	self site securityManager initAdminAccess.! !

!WebApplication methodsFor: 'private-security'!
isEncryptionSatisfied
	^(self mustBeEncrypted: self session newView) and: [self session lastRequest isEncrypted not]! !

!WebApplication methodsFor: 'private-security'!
mustBeEncrypted: aViewSymbol
	"check  if this view must be sent encrypted"
	| right |
"	(self observee = self site admin) & (aViewSymbol = #login) ifTrue: [^true]." "!!!!!!"
	 right := self site securityManager 
		isUser: self user
		allowedTo: (self class encryptSymbolFor: aViewSymbol)
		on: self class name.
	^right! !

!WebApplication methodsFor: 'private-security'!
reportSecurityViolationType: anAccessType "#view or #update"
	Transcript cr; show: '*** ',
		(anAccessType = #view ifTrue: ['access'] ifFalse: ['update']),
		' violation ', self class name asString, 
		' #', self view asString, 
		' by ', self user username,
		' on ', self site name! !

!WebApplication methodsFor: 'private-security'!
updateAllowed: aViewSymbol
	"check if update is allowed to this observee object with specified view"
	"update for admin login page is always allowed"
	"check too if update of observee is allowed at all to the current user"
	"reregister rights for admin if denial is encountered "
	| right |
	(self observee = self site admin) & (aViewSymbol = #login) ifTrue: [^true].
	(self observee aidaIsUpdateAllowedFor: self user) ifFalse: [^false].
	 right := self site securityManager 
		isUser: self user allowedTo: (self class updateRightSymbolFor:aViewSymbol)
		on: self class name.
	(right not and: [self user hasAdminRights]) ifTrue: [^true].
	^right! !

!WebApplication methodsFor: 'private-security'!
viewAllowed: aViewSymbol
	"check if page view is allowed to this observee object with specified view"
	"check too if access to observee is allowed at all to the current user"
	"admin logon page always allowed"
	"reregister rights for admin if denial is encountered "
	| right |
	(self observee = self site admin) & (aViewSymbol = #login) ifTrue: [^true].
	(self observee aidaIsAccessAllowedFor: self user) ifFalse: [^false].
	 right := self site securityManager 
		isUser: self user allowedTo: (self class viewRightSymbolFor: aViewSymbol)
		on: self class name.
	(right not and: [self user hasAdminRights]) ifTrue: [^true].
	^right! !


!WebApplication methodsFor: 'initialize-release'!
initContexts
	contexts := Dictionary new.! !

!WebApplication methodsFor: 'initialize-release'!
initOther
	other := Dictionary new.! !

!WebApplication methodsFor: 'initialize-release'!
initialize
	"override in subclasses if needed"! !


!WebApplication methodsFor: 'testing'!
isActive
	"at least one view is loaded and shown in a browser tab or window"
	self session ifNil: [^false].  "app is already cleaned up"
	self  contexts.
	^true! !

!WebApplication methodsFor: 'testing'!
isRealtime
	"realtime updating of current view is enabled and active"
	^self page isRealtimeEnabled
		and: [self session]! !

!WebApplication methodsFor: 'testing'!
isStandaloneApp
	"it is not a representation of some domain object in MVC fashion"
	^self otherAt: #StandaloneApp ifAbsent: [false]! !

!WebApplication methodsFor: 'testing'!
isWebApplication
	^true! !

!WebApplication methodsFor: 'testing'!
isWebWidget
	^false! !


!WebApplication methodsFor: 'private-bpm' stamp: ' 21/4/07 22:07'!
isControledByBPMProcess
	"by a BPM process instance, which control a workflow of this app too"
	^self process notNil! !

!WebApplication methodsFor: 'private-bpm' stamp: ' 21/4/07 22:07'!
setProcessFromTaskId
	"set a reference to a BPM process instance, which control a workflow of this app too"
	| uuid workitem |
	uuid := self session lastRequest queryAt: 'taskId' ifAbsent: [^nil].
	workitem := self site repository bpm worklist itemWithTaskUuid: uuid for: self user.
	workitem isNil ifTrue: [^nil].
	self process: workitem task process.
	workitem subscribeToApp: self.! !


!WebApplication methodsFor: 'redirection' stamp: ' 21/4/07 22:07'!
newView: aSymbol
	"in action methods, to direct to a specified view after button pressed"
	self session newView: aSymbol! !

!WebApplication methodsFor: 'redirection'!
redirectTo: anObjectOrUrlString
	"redirect browser to a default view for specified object or url link"
	anObjectOrUrlString isNil ifTrue: [^self error: 'redirection target is nil!!'].
	self session redirectLink: (WebLink text:'' linkTo: anObjectOrUrlString).! !

!WebApplication methodsFor: 'redirection' stamp: 'jm 6/27/2009 20:43'!
redirectTo: anObjectOrUrlString view: aSymbol
	"redirect browser to a specified view for specified object or url link"
	anObjectOrUrlString isNil ifTrue: [^self error: 'redirection target is nil!!'].
	self session redirectLink: (WebLink text:'' linkTo: anObjectOrUrlString view: aSymbol).! !

!WebApplication methodsFor: 'redirection' stamp: 'jm 6/27/2009 20:43'!
redirectTo: anObjectOrUrlString view: aSymbol parameter: aParmString value: aValueString
	"redirect browser to a specified view for specified object or url link"
	anObjectOrUrlString isNil ifTrue: [^self error: 'redirection target is nil!!'].
	self session redirectLink: ((WebLink text:'' linkTo: anObjectOrUrlString view: aSymbol)
		 parameter: aParmString value: aValueString).! !

!WebApplication methodsFor: 'redirection'!
redirectToView: aSymbol
	"redirect browser to a different view for same observee"
	| target |
	target := self observee notNil 
		ifTrue: [self observee] 
		ifFalse: [self class].  "standalone App without link to domain model. Class!! "
	self session redirectLink: (WebLink text:'' linkTo: target view: aSymbol).! !


!WebApplication methodsFor: 'private-other'!
other
	^other! !

!WebApplication methodsFor: 'private-other'!
otherAt: aSymbol
	^self otherAt: aSymbol ifAbsent: [nil]! !

!WebApplication methodsFor: 'private-other'!
otherAt: aSymbol ifAbsent: aBlock
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!WebApplication methodsFor: 'private-other'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!WebApplication methodsFor: 'private-other'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !


!WebApplication methodsFor: 'private-ajax'!
respondToEvent: aWebEvent
	"this method is here just to have an App in the stack, because 'climbing of the stack' methods"
	| popupCtx elementOrWidget window |
	aWebEvent element isWindowPopupRequested
		ifTrue: 
			[popupCtx := aWebEvent context createNewContext. "is also added to context chain and also to this app"
			aWebEvent context: popupCtx. "switch to a new popup context during the rest of execution"
			popupCtx event: aWebEvent.
			elementOrWidget := aWebEvent element handleEvent: aWebEvent. 
			window := self  "returns a window with wrapped new element and a popup script"
				wrap: elementOrWidget 
				intoPopupWindow: popupCtx window. 
			popupCtx first 
				queueUpdateElement: window. "this will popup immediatelly"
			elementOrWidget setShallQueue] "for the next update, specially for widget"
		ifFalse: 
			[aWebEvent element handleEvent: aWebEvent]! !

!WebApplication methodsFor: 'private-ajax'!
wrap: anElement intoPopupWindow: aWebWindow
	"put the element into a WebWindow and add popup JS and style"
	| popupCtx o l |
	popupCtx := aWebWindow creationContext. "this window is already created on popup context"
	aWebWindow addText: '<style>', aWebWindow popupStyle, '</style>'.
	o := WebElement newId: 'overlay', popupCtx level printString.
	l := (WebElement newId: 'lightbox', popupCtx level printString) style: 'display: none;'.
	l add: anElement.
	aWebWindow add: o; add: l.
	aWebWindow scriptAfter: 
		'updateLightboxLevel(', popupCtx level printString,')'. "from WebStyle>>js30Lightbox"
	aWebWindow afterCloseUpdate: anElement afterCloseUpdate. "if any"
	^aWebWindow! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebApplication class
	instanceVariableNames: ''!

!WebApplication class methodsFor: 'view, action methods'!
actionMethodForView: aViewSymbol
	"obsolete, only for WebSecurityManagerApp !!"
	| method viewSymbol |
	viewSymbol := aViewSymbol isEmpty 
		ifTrue: [self defaultView] ifFalse: [aViewSymbol asSymbol].
	method := self composedActionMethodNameForView: viewSymbol.
	(self canUnderstand: method) ifFalse: [^nil].
	^method! !

!WebApplication class methodsFor: 'view, action methods'!
actionMethodForView: aViewSymbol button: aButton
	"if no method for that button name, return nil"
	| method viewSymbol |
	viewSymbol := aViewSymbol asString isEmpty 
		ifTrue: [self defaultView] ifFalse: [aViewSymbol asSymbol].
	method := self composedActionMethodNameForView: viewSymbol action: aButton action.
	(self canUnderstand: method) ifTrue: [^method].
	'search' = aButton action ifTrue: [^#actionSearch].
	^nil
"
	method := self composedActionMethodNameForView: viewSymbol.
	(self canUnderstand: method) ifTrue: [^method].
	^nil
"! !

!WebApplication class methodsFor: 'view, action methods'!
viewMethodForView: aViewSymbol
	| method viewSymbol |
	viewSymbol := aViewSymbol isEmpty 
		ifTrue: [self defaultView] ifFalse: [aViewSymbol].
	method := self composedMethodNameForView: viewSymbol.
	(self canUnderstand: method) ifFalse: [^nil].
	^method

"WebDemoApp new class viewMethodForView: #imageGallery"! !


!WebApplication class methodsFor: 'private'!
allComposedViewMethods
	| methods |
	methods := self selectors asSet select: [:each | 'view*' match:each asString].
	methods := methods reject: [:each | 
		#(view viewAllowed: viewMethodForView: ) includes: each].
	^self superclass isWebApplication 
		ifTrue: [methods addAll: self superclass allComposedViewMethods; yourself]
		ifFalse: [methods]

"WebDemoApp new class allComposedViewMethods"! !

!WebApplication class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
allComposedViews
	"remove 'view' and lowercase start of remining part of method to get a view name from method"
	^self allComposedViewMethods collect: [:each | 
		((String with: (each at: 5) asLowercase), 
			(each copyReplaceFrom: 1 to: 5 with: String new)) asSymbol].

"WebDemoApp new class allComposedViews"! !

!WebApplication class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
allWebAppClassesTo: aCollection 
	"return an ordered collection with a WebApplication class all their subclasses ordered
	by levels of inheritance and by class name on the same level"
	| subcls |
	aCollection add: self.
	subcls := SortedCollection withAll: self subclasses
				sortBlock: [:a :b | a name < b name].
	subcls do: [:subclass | subclass allWebAppClassesTo: aCollection]! !

!WebApplication class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
appClassLevel
	"return the level of inheritance of a class, relative to a WebApplication class"
	| level cls |
	level := 1.
	cls := self.
	[cls == WebApplication] whileFalse: 
			[level := level + 1.
			cls := cls superclass].
	^level! !

!WebApplication class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
capitalizeName: aString
	"make first char uppercase"
	aString isEmpty ifTrue: [^''].
	^(String with: aString first asUppercase), (aString copyFrom: 2 to: aString size)

"WebApplication capitalizeName: 'main' "! !

!WebApplication class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
composedActionMethodNameForView: aViewName
	^('action', (self capitalizeName: aViewName asString)) asSymbol

"WebApplication composedActionMethodNameForView: 'main'"! !

!WebApplication class methodsFor: 'private'!
composedActionMethodNameForView: aViewName action: aSymbol
	| mtname |
	mtname := (self composedActionMethodNameForView: aViewName) asString.
	aSymbol notNil ifTrue:
		[mtname := mtname, (self capitalizeName: aSymbol asString)].
	^mtname asSymbol

"WebApplication composedActionMethodNameForView: 'main' action: 'addFolder'"! !

!WebApplication class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
composedMethodNameForView: aViewName
	^('view', (self capitalizeName: aViewName asString)) asSymbol

"WebApplication new class composedMethodNameForView: 'main'"! !

!WebApplication class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
isWebApplication
	^true! !

!WebApplication class methodsFor: 'private' stamp: 'jm 8/21/2009 18:15'!
newFromNameFor: anObject on: aSession
	"Try to create of AnObjectApp instance if that class exist."
	"Squeak specific!!"
	| className class |
	className := (anObject class name asString, 'App') asSymbol.
	class := [Smalltalk at: className] on: Error do: [:ex | ^nil].  "Squeak specific!!"
	(class allSuperclasses includes: WebApplication) ifFalse: [^nil].
	^class basicNew 
		observee: anObject; 
		session: aSession; 
		initialize.
! !


!WebApplication class methodsFor: 'accessing' stamp: 'JM 4/26/2007 17:06'!
allViews
	^self allComposedViews! !

!WebApplication class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allWebAppClasses
	"return an ordered collection with a WebApplication class all their subclasses ordered
	by levels of inheritance and by class name on the same level"
	| classes |
	classes := OrderedCollection new.
	self allWebAppClassesTo: classes.
	^classes

"WebApplication allWebAppClasses"! !

!WebApplication class methodsFor: 'accessing'!
defaultView
	^#main! !

!WebApplication class methodsFor: 'accessing'!
instance
	"find or create an instance of this standalone App in current session"
	| session |
	session := self firstSessionFromStack.
	^session notNil
		ifTrue: [self instanceFor: session]
		ifFalse: [nil]! !

!WebApplication class methodsFor: 'accessing'!
instanceFor: aWebSession
	"find or create an instance of this standalone App in specified session"
	| instance |
	instance := self aidaWebAppFor: aWebSession.
	instance isStandaloneApp 
		ifFalse: [self error: 'not a standalone App'].
	^instance! !


!WebApplication class methodsFor: 'security' stamp: ' 21/4/07 22:07'!
allowAllUpdatesFor: aWebUserOrGroup on: anAIDASite
	"set access rigths to allow all updates on that web app for specified user or group 
	on specified server"
	self allWebAppClasses do: [:appClass |
		appClass allViews do: [:appView |
			anAIDASite securityManager
				setAccessRights: (appClass updateRightSymbolFor: appView)
				for: aWebUserOrGroup
				on: appClass name] ].

"
WebSecurityManagerApp allowAllUpdatesFor: 
	(WebSecurityManager default adminUser)
		on: AIDASite default
"! !

!WebApplication class methodsFor: 'security' stamp: ' 21/4/07 22:07'!
allowAllViewsFor: aWebUserOrGroup on: anAIDASite
	"set access rigths to allow all views on all web apps for specified user or group on specified site"
	self allWebAppClasses do: [:appClass |
		appClass allViews do: [:appView |
			anAIDASite securityManager
				setAccessRights: (appClass viewRightSymbolFor: appView)
				for: aWebUserOrGroup
				on: appClass name] ].
"
WebApplication allowAllViewsFor: 
	(WebSecurityManager default adminUser)
	on: AIDASite default
"! !

!WebApplication class methodsFor: 'security'!
disallowAllUpdatesFor: aWebUserOrGroup on: anAIDASite
	"remove all update access rigths on that web app for specified user or group 
	on specified server"
	self allWebAppClasses do: [:appClass |
		appClass allViews do: [:appView |
			anAIDASite securityManager
				removeAccessRights: (appClass updateRightSymbolFor: appView)
				for: aWebUserOrGroup
				on: appClass name] ].

"
WebSecurityManagerApp disallowAllUpdatesFor: 
	(WebSecurityManager default adminUser)
		on: AIDASite default
"! !

!WebApplication class methodsFor: 'security'!
disallowAllViewsFor: aWebUserOrGroup on: anAIDASite
	"remove all view access rigths on all web apps for specified user or group on specified site"
	self allWebAppClasses do: [:appClass |
		appClass allViews do: [:appView |
			anAIDASite securityManager
				removeAccessRights: (appClass viewRightSymbolFor: appView)
				for: aWebUserOrGroup
				on: appClass name] ].
"
WebApplication disallowAllViewsFor: 
	(WebSecurityManager default adminUser)
	on: AIDASite default
"! !

!WebApplication class methodsFor: 'security'!
encryptSymbolFor: aViewSymbol
	"if view does not exist, then use a default (first) view. Be sure to use a
	sublclass of WebApplication when calling that method to find the right default view"
	| view allViews|
	allViews := self allViews.
	allViews isEmpty ifTrue: [^nil].
	view := (allViews includes: aViewSymbol)
		ifTrue: [aViewSymbol]
		ifFalse: [self defaultView].
	view := (String with: view asString first asUppercase), 
		(view asString copyFrom: 2 to: view asString size).
	^('encrypt', view asString) asSymbol! !

!WebApplication class methodsFor: 'security'!
updateRightSymbolFor: aViewSymbol
	"return a right symbol, used for setting/testing rights to update a page with specified view.
	A symbol is composed as follows: '#upd',<aViewSymbol> for expample for view #brief
	result is #updbrief"
	"if view does not exist, then use a default (first) view. Be sure to use a
	sublclass of WebApplication when calling that method to find the right defult view"
	| view allViews|
	allViews := self allViews.
	allViews isEmpty ifTrue: [^nil].
	view := (allViews includes: aViewSymbol)
		ifTrue: [aViewSymbol]
		ifFalse: [self defaultView].
	view := (String with: view asString first asUppercase), 
		(view asString copyFrom: 2 to: view asString size).
	^('upd', view) asSymbol! !

!WebApplication class methodsFor: 'security'!
viewRightSymbolFor: aViewSymbol
	"return a right symbol, used for setting/testing rights to view a page with specified view.
	a symbol is composed as follows: '#view',<aViewSymbol> for expample for view #brief
	result is #viewbrief"
	"if view does not exist, then use a default (first) view. Be sure to use a
	sublclass of WebApplication when calling that method to find the right defult view"
	| view allViews|
	allViews := self allViews. allViews isEmpty ifTrue: [^nil].
	view := (allViews includes: aViewSymbol)
		ifTrue: [aViewSymbol]
		ifFalse: [self defaultView].
	view := (String with: view asString first asUppercase), 
		(view asString copyFrom: 2 to: view asString size).
	^('view', view) asSymbol! !


!WebApplication class methodsFor: 'instance creation'!
newFor: anObject on: aSession
	"guess a class from anObject class name (class name + 'App') and create instance of it"
	| instance |
	instance := self newFromNameFor: anObject on: aSession.
	instance isNil ifTrue: [^nil].
	^instance session: aSession! !


WebApplication subclass: #FrameApp
	instanceVariableNames: 'externalLinks'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Applications'!

!FrameApp methodsFor: 'external links'!
externalLinks
	"unique relative url -> OtherAidaLink"
	externalLinks ifNil: [self initExternalLinks].
	^externalLinks! !

!FrameApp methodsFor: 'external links'!
linkForUrl: anUrlString
	"unique relative url -> OtherAidaLink"
	^self externalLinks 
		at: anUrlString
		ifAbsent: [nil]! !

!FrameApp methodsFor: 'external links'!
registerExternalLink: aWebLink "like OtherAidaLink"
	"unique relative url -> OtherAidaLink"
	| url |
	url := aWebLink pureUrlOn: self session. "without queries and anchor"
	self externalLinks
		at: url
		put: aWebLink! !

!FrameApp methodsFor: 'external links'!
urlForLink: aWebLink "like OtherAidaLink"
	"unique relative url -> OtherAidaLink"
	^(self externalLinks associations
		detect: [:elink | elink value = aWebLink]
		ifNone: [^nil])
			key "url"! !


!FrameApp methodsFor: 'initialize-release'!
initExternalLinks
	externalLinks := Dictionary new.! !

!FrameApp methodsFor: 'initialize-release'!
initialize
	self initExternalLinks! !


!FrameApp methodsFor: 'views'!
otherSiteAddress
	| otherSiteName |
	otherSiteName := self session lastRequest queryAt: 'fromAidaSite'.
	otherSiteName ifNil: [^nil].
	^self site group 
		urlForSite: otherSiteName.! !

!FrameApp methodsFor: 'views'!
otherSiteUrl
	"relative url with queries (if any) to the external content"
	| pureUrl link |
	pureUrl := self session lastRequest queryAt: 'url'.
	pureUrl ifNil: [^nil].
	link := self linkForUrl: pureUrl.
	link
		parameter: 'originUserAuth'
		value: 'abcdefghijk'.
	^link 
		composeURLOn: self session! !

!FrameApp methodsFor: 'views'!
viewMain
	| iframe absUrl |
	absUrl := self otherSiteAddress, self otherSiteUrl.
	iframe := WebIFrame new.
	iframe 
		size: 800@800; frameBorder: 1; scrolling: #yes;
		src: absUrl.
	self style pageFrameWith: iframe title: ''! !


WebApplication subclass: #WebMobileApplication
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Applications'!
!WebMobileApplication commentStamp: 'janko 8/25/2012 12:26' prior: 0!
WebMobileApplication to have a web app for the same domain object but tailored for mobile phones and tablets. 

Use a classical WebApplication and responsive design with a mobile CSS if your app is just a bit different (like bigger buttons etc.) on a mobile device. 

Use WebMobileApplication if mobile app is very different and tightly designed just for a mobile device, like a mobile phone.

!


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebMobileApplication class
	instanceVariableNames: ''!

!WebMobileApplication class methodsFor: 'private' stamp: 'janko 8/25/2012 12:52'!
newFromNameFor: anObject on: aSession
	"Try to create of anObjectMobileApp instance if that class exists."
	"Squeak specific!!"
	| className class |
	className := (anObject class name asString, 'MobileApp') asSymbol.
	class := [Smalltalk at: className] on: Error do: [:ex | ^nil].  "Squeak specific!!"
	(class allSuperclasses includes: WebApplication) ifFalse: [^nil].
	^class basicNew 
		observee: anObject; 
		session: aSession; 
		initialize.
													
													! !


WebElement subclass: #WebWidget
	instanceVariableNames: 'state'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Applications'!
!WebWidget commentStamp: '<historical>' prior: 0!
WebWidget is an abstract class for statefull Aida components - standalone parts of web page, many times also long living, that is, they live longer than just one page view. 
!


!WebWidget methodsFor: 'private'!
add: anElement
	"all adding delegated to the form"
	anElement = self 
		ifTrue: [^self error: 'adding itself to Widget, missing ^e somewhere?'].
	self form add: anElement.
	anElement postAddAction.
	^anElement! !

!WebWidget methodsFor: 'private'!
canUpdate
	"Widgets are updatable elements of a web page"
	^true! !

!WebWidget methodsFor: 'private'!
postAddAction
	| c superform |
	superform := (self parent notNil and: [self parent creationObject notNil])
		ifTrue: [self parent form]
		ifFalse: 
			[c := (self widgetsAndAppsFromStack at: 2). "skip first because it is this widget"
			c isWebWidget 
				ifTrue: [c form] 
				ifFalse: [self creationContext form] ].
	superform 
		addSubform: self form.! !

!WebWidget methodsFor: 'private'!
printString
	| text |
	text := super printString, '
	buildImmediatelly: ', self buildImmediatelly printString, ' 
	buildWhenStreaming: ', self buildWhileStreaming printString.  
	self isStubForPopup ifTrue: [text := text, '
	stubForPopup: true'].
	text := text, '
	shallQueue: ', self shallQueue printString.
	^text.! !

!WebWidget methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession 
	(self buildWhileStreaming
		and: [self isStubForPopup not]) "don't build yet, not yet visible, waiting for a click to popup"
			ifTrue: [self build].
	self registerFormElementsTo: self form.	
	self setStateStreaming.
	super streamHtmlTo: aStream for: aRequest on: aSession.
	self setStateFinished.! !

!WebWidget methodsFor: 'private'!
widget
	^self! !


!WebWidget methodsFor: 'building-views'!
ajaxUpdate
	"update a widget from the Ajax call"
	"override if you want to update a widget differently"
	self 
		resetBuildWhileStreaming; "we will buld immediatelly from Ajax update or popup"
		rebuild.! !

!WebWidget methodsFor: 'building-views'!
build
	"Build your widget by overriding this method. 
	Note that by default #build is called not in composing but streaming phase. It is built immediatelly
	while updating or after popup.
	You can control that by overriding or setting #buildImmediatelly or #buildWhileStreaming"! !

!WebWidget methodsFor: 'building-views'!
clear
	self form "from a form to not unregister itself"
		unregisterIdsFromCtx: self creationContext. 
	self initElements.
	self clearTableInfo.
	self initScripts.
	self initForm.
	(self parent notNil and: [self parent form notNil]) ifTrue:
		[self parent form addSubform: self form]! !

!WebWidget methodsFor: 'building-views'!
rebuild
	"It first clears then builds this widget again. Used mostly to update a widget 
	by Ajax or realtime update call"
	self clear.
	self build.! !


!WebWidget methodsFor: 'building-when'!
buildImmediatelly
	"shall we build a widget immediatelly when a widget is created? By default no.
	It can be bult later: in streaming phase or when updated via Ajax or realtime event"
	^self
		otherAt: #BuildImmediatelly
		ifAbsentPut: false! !

!WebWidget methodsFor: 'building-when'!
buildWhileStreaming
	"shall we build a widget in a streaming phase, just before starting to stream to the browser?"
	"By default yes"
	^self
		otherAt: #BuildWhileStreaming
		ifAbsentPut: true! !

!WebWidget methodsFor: 'building-when'!
resetBuildImmediatelly
	"shall we build a widget immediatelly when a widget is created?"
	^self
		otherAt: #BuildImmediatelly
		put: false! !

!WebWidget methodsFor: 'building-when'!
resetBuildWhileStreaming
	"shall we build a widget in a streaming phase, just before starting to stream to the browser?"
	^self
		otherAt: #BuildWhileStreaming
		ifAbsent: [false]! !

!WebWidget methodsFor: 'building-when'!
setBuildImmediatelly
	"shall we build a widget immediatelly when a widget is created?"
	^self
		otherAt: #BuildImmediatelly
		put: true! !

!WebWidget methodsFor: 'building-when'!
setBuildWhileStreaming
	"shall we build a widget in a streaming phase, just before starting to stream to the browser?"
	^self
		otherAt: #BuildWhileStreaming
		ifAbsent: [true]! !


!WebWidget methodsFor: 'accessing'!
form
	"WebForm is first and only subelement of the widget, all element addings go to it and not direclty to widget!!"
	self elements isEmpty 
		ifTrue: [self initForm].
	^self elements first! !

!WebWidget methodsFor: 'accessing'!
page
	"a webpage on which this widget resides"
	^self creationContext
		page! !

!WebWidget methodsFor: 'accessing'!
session
	"a session on which this widget is built"
	^self app session! !

!WebWidget methodsFor: 'accessing'!
site
	"a website on which this widget is built"
	^super site! !

!WebWidget methodsFor: 'accessing'!
user
	"a currently logged-in user on the session on which this widget is built"
	^self session user! !


!WebWidget methodsFor: 'events-actions'!
ifFalse: aBlock
	"run a block if answer is set to false when this widget is closed"
	self onCloseDo:
		[self context answer = false ifTrue: [aBlock value] ]! !

!WebWidget methodsFor: 'events-actions'!
ifTrue: aBlock
	"run a block if answer is set to true when this widget is closed"
	self onCloseDo:
		[self context answer = true ifTrue: [aBlock value] ]! !

!WebWidget methodsFor: 'events-actions'!
ifTrue: aTrueBlock ifFalse: aFalseBlock
	"run appropriate block if result is set to true or false when this widget is closed"
	self ifTrue: [aTrueBlock value].
	self ifFalse: [aFalseBlock value].! !

!WebWidget methodsFor: 'events-actions'!
onAnswerDo: aBlock
	"if widget returns some answer on close, run that block with answer as an argument"
	self onCloseDo:
		[self context answer notNil ifTrue: 
			[aBlock value: self context answer] ]! !

!WebWidget methodsFor: 'events-actions'!
onCloseDo: aBlock
	"execute that block when this widget is closed"
	"Triggered in WebEventHandler addCloseWindow block"
	(self eventHandlerFor: #close)  "close is pseudo event, not browser native"
		addActionBlock: aBlock.! !

!WebWidget methodsFor: 'events-actions'!
update
	"Update (recreate or refresh) that same widget while preserving potential instvas.
	Not replacing it with a new as in case of element update!! "
	"Note that widget can be updated on a new popup context"
	"Also building can be deferred to streaming phase, so that update doesn't produce a new widget yet!!"
	| superform |
	superform := self form superform.
	superform removeSubform: self form. "old form removed, we will recreate it from scratch"
	self form "and all hierarchy of subelements"
		unregisterIds; "unregister on creation context"
		releaseFully.

	(self creationMethod asString last = $: )
		ifTrue: [self creationObject perform: self creationMethod with: self updateArgument ]  
		ifFalse: [self updateArgument notNil  "try to call the method with that argument anyway"
			ifTrue: [self creationObject perform: 
						(self creationMethod, ':') asSymbol with: self updateArgument]
			ifFalse: [self creationObject perform: self creationMethod] ].
	self basicCreationContext: self firstContextFromStack.  "currently executng context"
	superform isTopForm "on the window" ifTrue: 
		[superform := self creationContext window form]. "in case of new popup context!!"
	superform addSubform: self form.
	self shallQueue ifTrue:  "if not, defer queuing until widget is wrapped into window for popup"
		[self context first
			queueUpdateElement: self]. "to be sent immediatelly via WebSocket if open, or in Ajax response"
	^self! !


!WebWidget methodsFor: 'initialize-release'!
initForm
	"WebForm is a first element in a widget  and all adds go to this form and not direclty to the widget!! "
	"Also temporary set its superform to a one found up in the current element hierarchy"
	(self elements add: (WebForm new parent: self))
		registerId.! !

!WebWidget methodsFor: 'initialize-release'!
initFormAndSubformOn: aWebContext
	"WebForm is a first element in a widget  and all adds go to this form and not direclty to the widget!! "
	"Also temporary set its superform to a one found up in the current element hierarchy. It will be set
	permamently when adding the widget to some element (see #add)"
	| widgets superform |
	self initForm.
	widgets := self widgetsAndAppsFromStack
		select: [:wa | wa isWebWidget].
	superform := widgets size > 1 
		ifTrue: [widgets second form]
		ifFalse: [aWebContext window form].
	self form 
		superform: superform! !

!WebWidget methodsFor: 'initialize-release'!
initialize
	super initialize.
	self isStubForPopup "don't build yet, not yet visible, waiting for a click to popup"
		ifTrue: [^self].
	self buildImmediatelly 
		ifTrue: [self build]! !


!WebWidget methodsFor: 'state'!
isComposing
	"widget (or window or page) is in building state, composing from web elements"
	^state = #composing! !

!WebWidget methodsFor: 'state'!
isFinished
	"composing and streaming finished"
	^state = #finished! !

!WebWidget methodsFor: 'state'!
isStreaming
	"printing, that is streaming to the tcp socket"
	^state = #streaming! !

!WebWidget methodsFor: 'state'!
setComposing
	state := #composing! !

!WebWidget methodsFor: 'state'!
setFinished
	state := #finished! !

!WebWidget methodsFor: 'state'!
setStateComposing
	state := #composing! !

!WebWidget methodsFor: 'state'!
setStateFinished
	state := #finished! !

!WebWidget methodsFor: 'state'!
setStateStreaming
	state := #streaming! !


!WebWidget methodsFor: 'testing'!
isUpdatable
	"widget can always be Ajax or realtime updated"
	^true! !

!WebWidget methodsFor: 'testing'!
isWebWidget
	^true! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebWidget class
	instanceVariableNames: ''!

!WebWidget class methodsFor: 'instance creation'!
new
	"Implement also  #new in every subclass of WebWidget and call #initialize there to build 
	it immediatelly if needed!! "
	| ctx instance |
	ctx := self firstContextFromStack. "currently executing context"
	instance := super basicNew.
	instance
		creationObject: instance;
		creationMethod: #ajaxUpdate; "be sure to change it accordingly in subclasses if needed!! "
		basicCreationContext: ctx;
		setDiv; registerId; "Widgets must always have a web element id!! "
		attributesAt: #comment put: self name; "unofficial attribute, just for easier debuging in browser"
		initFormAndSubformOn: ctx; "will also temporary set a superform to first found up in hierarchy"
		setStateComposing.
"		initialize. "  "call #initialize in your subclass #new method!! "
	^instance! !


WebElement subclass: #WebWindow
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Applications'!
!WebWindow commentStamp: '<historical>' prior: 0!
WebWindow is a window (a web page or window inside a page).
!


!WebWindow methodsFor: 'private-subelements'!
add: anElement
	"all adding delegated to the form"
	anElement = self "loop prevention"
		ifTrue: [^self error: 'adding itself to a window/page, missing ^e somewhere?'].
	self form 
		add: anElement.
	anElement 
		postAddAction. "if any"
	^anElement! !


!WebWindow methodsFor: 'initialize-release'!
clear
	^self form clear! !

!WebWindow methodsFor: 'initialize-release'!
initForm
	"WebForm is a first element on a widnow, being top page or popup window"
	"All adds go to this form and not direclty to the window/page!!"
	(self elements add: 
		(WebForm new parent: self))
			registerId! !

!WebWindow methodsFor: 'initialize-release'!
initPopupStub
	| stub |
	stub := WebStubElement newOn: self firstContextFromStack.
	self elements 
		addFirst: stub. "to be sure on the first place"
	stub parent: self! !


!WebWindow methodsFor: 'accessing'!
close
	"close that window and also currently executing context. Call this method from Ajax closing link 
	on the window"
	"only the subwindow can be closed that way, not a main page"
	self context close.! !

!WebWindow methodsFor: 'accessing'!
creationContext
	^self parent! !

!WebWindow methodsFor: 'accessing'!
form
	"form is a second, not first element in Window, first is popup stub"
	^self elements 
		at: 2! !

!WebWindow methodsFor: 'accessing'!
popupStub
	"empty stub element for eventual popup window"
	self elements first isStubElement ifFalse: [^self error: 'not a popup stub!! '].
	^self elements first! !

!WebWindow methodsFor: 'accessing'!
webPage
	"on which page this window resides"
	self parent class == WebPage 
		ifTrue: [^self parent].
	^self parent page  "parent is popup context"! !


!WebWindow methodsFor: 'private-streaming'!
isStreaming
	"streaming phase to the tcp socket"
	^self
		otherAt: #Streaming
		ifAbsent: [false]! !

!WebWindow methodsFor: 'private-streaming'!
resetStreaming
	"end of streaming to the tcp socket"
	^self
		otherAt: #Streaming
		put: false! !

!WebWindow methodsFor: 'private-streaming'!
setStreaming
	"printing, that is streaming to the tcp socket"
	^self
		otherAt: #Streaming
		put: true! !

!WebWindow methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession 
	self setStreaming.
	super streamHtmlTo: aStream for: aRequest on: aSession.
	self resetStreaming! !


!WebWindow methodsFor: 'testing'!
isWebWindow
	^true! !


!WebWindow methodsFor: 'private'!
popupStyle
	"for popup windows. Because they are stackable, we need to consider a level in the stack too"
	| level lvl |
	level :=self context level. lvl := level printString.
	^ '
form {width: 100%}
div#overlay', lvl ,' {
	position: fixed;
	width: 100%;
	height: 100%;
	z-index: ', (9000+(level*2)) printString, ';
	background-color: black;
	filter: alpha(opacity=10);
	-moz-opacity: 0.1;
	opacity: 0.1;
}
div#lightbox', lvl, ' { 
	background: #ffffff;
	z-index: ', (9001+(level*2)) printString, ';
	padding: 10px;
	border: 5px solid #888888;
	border-radius: 10px;
	box-shadow: 0 0 10px #333333;
}'! !

!WebWindow methodsFor: 'private'!
shouldIdent
	^true! !


!WebWindow methodsFor: 'subelements'!
registerFormElementsTo: aWebForm
	self form 
		initSubforms. "to avoid accumulating subforms during posting on the same page"
	^super 
		registerFormElementsTo: aWebForm! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebWindow class
	instanceVariableNames: ''!

!WebWindow class methodsFor: 'instance creation'!
new
	^self newOnCtx: self firstContextFromStack! !

!WebWindow class methodsFor: 'instance creation'!
newOnCtx: aWebContext
	^super new
		basicCreationContext: aWebContext;
		initPopupStub;
		initForm! !

!WebWindow class methodsFor: 'instance creation'!
newOnPopupCtx: aWebContext
	"set this new window to the same id as a stub element in parent context, to be prepared for swaping them 
	to achieve a popup"
	^(self newOnCtx: aWebContext)
		id: aWebContext parent window popupStub id! !


WebWindow subclass: #WebPage
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Applications'!
!WebPage commentStamp: '<historical>' prior: 0!
WebWidget is an abstract class for statefull Aida components - standalone parts of web page, many times also long living, that is, they live longer than just one page view. 
!


!WebPage methodsFor: 'private-scripts'!
addCometLoadScript
	"long polling Ajax call"
	self site cometEnabled ifTrue:
		[self onLoad: 'aidaOpenComet()' ] "will also check that WebSocket is not already open"! !

!WebPage methodsFor: 'private-scripts'!
addFocusBlurReportScriptAndHandler
	"report focus and blur(unfocus) the page"
	self onFocus: 'aidaFocusReport()'.
	self onBlur: 'aidaBlurReport()'.
	(self eventHandlerFor: #focus)
		addPageFocus.
	(self eventHandlerFor: #blur)
		addPageBlur.! !

!WebPage methodsFor: 'private-scripts'!
addGeolocationScript
	self onLoad: 'aidaLocationReport()'! !

!WebPage methodsFor: 'private-scripts'!
addLoadUnloadReportScriptAndHandler
	"report loading and unloading (closing, going to another) the page"
	self onLoad: 'aidaLoadReport()'.
	self onUnload: 'aidaUnloadReport()'.
	(self eventHandlerFor: #load)
		addPageLoad.
	(self eventHandlerFor: #unload)
		addPageUnload! !

!WebPage methodsFor: 'private-scripts'!
addWebSocketLoadScript
	"script is in WebStyle #js141WebSocket method"
	self onLoad: 'aidaOpenWebSocket()'! !

!WebPage methodsFor: 'private-scripts'!
checkAndAlertOnSSLSetup
	"write alert to transcript if behind server/proxy with SSL support and securityExternally was not 
	yet explicitly set to true or false"
	| app |
	app := self app.
	app site securedExternallySet ifTrue: [^nil].
	app session lastRequest isForwarded ifTrue: "by external server or proxy"
		[Transcript cr; show: '*** ', app site name, 
			': set site #securedExternally explicitly to true or false'].! !

!WebPage methodsFor: 'private-scripts'!
setBrowserSessionContext
	"to differentiate between tabs in browser window"
	self onLoad: 
		'sessionStorage.aidaCtx = ', self creationContext id asString.! !


!WebPage methodsFor: 'header elements' stamp: 'janko 11/24/2008 21:56'!
addGlobalKeywords
	"global keywords to all pages on this website"
	| app |
	app := self firstAppFromStack.
	(app isNil or: [app site keywords isEmpty]) ifTrue: [^nil].
	self addMetaKeywords: app site keywords! !

!WebPage methodsFor: 'header elements'!
addJavascript: aScriptString
	self addScriptWithParms: '' script: aScriptString! !

!WebPage methodsFor: 'header elements'!
addLinkToAlternateScreenStyleSheet: aMethodResourceOrUrl
	| url |
	url := aMethodResourceOrUrl isString
		ifTrue: [aMethodResourceOrUrl]
		ifFalse: [aMethodResourceOrUrl preferredUrl].
	self addHeader: 'link' value: 'rel="alternate stylesheet" type="text/css" media="screen" href="', url, '" '! !

!WebPage methodsFor: 'header elements'!
addLinkToDefaultFavicon
	"WebStyle favicon (favorites icon). So far only in .ico format!!"
	self addLinkToFavicon: '/favicon.ico'! !

!WebPage methodsFor: 'header elements'!
addLinkToFavicon: aFaviconImageOrUrl
	"favicon (favorites icon). So far only in .ico format!!"
	| url |
	url := aFaviconImageOrUrl isString
		ifTrue: [aFaviconImageOrUrl]
		ifFalse: [self site urlResolver fullUrlFor: aFaviconImageOrUrl on: nil].
	self addHeader: 'link' value: 'rel="icon" type="image/x-icon" href="', url, '" '! !

!WebPage methodsFor: 'header elements'!
addLinkToJavascript: aMethodResourceOrUrl
	| url |
	url := aMethodResourceOrUrl isString
		ifTrue: [aMethodResourceOrUrl]
		ifFalse: [aMethodResourceOrUrl preferredUrl].
	self addScriptWithParms: ' src="', url, '" type="text/javascript"' script: ''.! !

!WebPage methodsFor: 'header elements'!
addLinkToMobileStyleSheet: aMethodResourceOrUrl
	| url |
	url := aMethodResourceOrUrl isString
		ifTrue: [aMethodResourceOrUrl]
		ifFalse: [aMethodResourceOrUrl preferredUrl].
	self addHeader: 'link' value: 'rel="stylesheet" type="text/css" media="screen" href="', url, '" '! !

!WebPage methodsFor: 'header elements'!
addLinkToPrintStyleSheet: aMethodResourceOrUrl
	| url |
	url := aMethodResourceOrUrl isString
		ifTrue: [aMethodResourceOrUrl]
		ifFalse: [aMethodResourceOrUrl preferredUrl].
	self addHeader: 'link' value: 'rel="stylesheet" type="text/css" media="print" href="', url, '" '! !

!WebPage methodsFor: 'header elements'!
addLinkToScreenStyleSheet: aMethodResourceOrUrl
	| url |
	url := aMethodResourceOrUrl isString
		ifTrue: [aMethodResourceOrUrl]
		ifFalse: [aMethodResourceOrUrl preferredUrl].
	self addHeader: 'link' value: 'rel="stylesheet" type="text/css" media="screen" href="', url, '" '! !

!WebPage methodsFor: 'header elements' stamp: ' 21/4/07 22:07'!
addMetaContentType: aString
	"example: 'text/html; charset=iso8859-2'"
	self addHeader: 'meta' value: 'http-equiv="Content-Type"  content="', aString, '" '! !

!WebPage methodsFor: 'header elements'!
addMetaDescription: aString
	self addMetaName: 'description' content: aString! !

!WebPage methodsFor: 'header elements'!
addMetaKeywords: aString
	"keywords separated with , "
	self addMetaName: 'keywords' content: aString! !

!WebPage methodsFor: 'header elements'!
addMetaName: aNameString content: aContentString
	self addHeader: 'meta'
		value: 'name="' , aNameString , '" 
		content="' , aContentString convertToSloveneChars , '"'! !

!WebPage methodsFor: 'header elements'!
addRefreshAfterNightlyCleanup
	"if page stays open through the night, if will be reloaded to preserve Ajax functionality 
	lost during nightly application state release"
	| seconds |
	seconds := Time now asSeconds - self site nightlyCleanupTime asSeconds.
	seconds := seconds > 0 "now is after 4 at the morning"
		ifTrue: [(24*3600) - seconds]
		ifFalse: [seconds negated].
	seconds := seconds + (5*60). "reload 5 minutes after niglty cleanup"
	self addHeader: 'meta' value: 'http-equiv="Refresh" content="', seconds printString, '" '! !

!WebPage methodsFor: 'header elements' stamp: 'janko 8/25/2012 19:03'!
addStyle: aString
	"inline CSS to header of a page. It will be always the last in the header, after /screen.css, to allow overriding it"
	self isStreaming ifTrue: [self errorAlreadyInStreamingState]. "too late to add headers in streaming state!!"
	self firstContextFromStack event isClassicalRequest 
		ifFalse: [self errorCannotSetHeadersFromAjax]. "because page headers are already sent to browser"
	self headers add: ('style' -> (Array with: 'type="text/css"' with: aString) ).
	"see also #rearrangeHeaders called from #streamHtmlTo:..  "! !

!WebPage methodsFor: 'header elements'!
addTitle: aString
	self addHeader: 'title' value:  aString.! !


!WebPage methodsFor: 'private'!
addHeader: aTagString value: aString
	| event |
	self isStreaming ifTrue: 
		[self errorAlreadyInStreamingState]. "too late to add headers in streaming state!!"
	event := self firstEventFromStack.
	(event notNil and: [event isClassicalRequest not])  "check if Ajax or realtime"
		ifTrue: [self errorCannotSetHeadersFromAjax]. "because page headers are already sent to browser"
	self headers 
		add: (aTagString -> aString)! !

!WebPage methodsFor: 'private' stamp: 'janko 8/25/2012 19:02'!
addScriptWithParms: aString script: aScriptString
	self isStreaming ifTrue: [self errorAlreadyInStreamingState]. "too late to add headers in streaming state!!"
	self firstContextFromStack event isClassicalRequest 
		ifFalse: [self errorCannotSetHeadersFromAjax]. "because page headers are already sent to browser"
	self headers add: ('script' -> (Array with: aString with: aScriptString) )! !

!WebPage methodsFor: 'private'!
errorAlreadyInStreamingState
	self error: 'Too late to add page headers, page is already streaming to response!!'! !

!WebPage methodsFor: 'private'!
errorCannotSetHeadersFromAjax
	self error: 'Cannot set page headers from Ajax request!!'  "because page headers are already sent to browser"! !

!WebPage methodsFor: 'private'!
hasTag
	^false "well..."! !

!WebPage methodsFor: 'private' stamp: 'janko 8/25/2012 18:58'!
headers
	^self otherAt: #pageHeaders ifAbsent: [self initHeaders]! !

!WebPage methodsFor: 'private'!
htmlDocType: aString
	^self otherAt: #HTMLDocType put: aString! !

!WebPage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
identDepth
	^self otherAt: #identDepth ifAbsent: [0]! !

!WebPage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
identDepth: aNumber
	"current depth of identation. If 0, the we are at the start of the line"
	self otherAt: #identDepth put: aNumber! !

!WebPage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
isNewline
	^self identDepth = 0! !

!WebPage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
session: aSession
	session := aSession! !

!WebPage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
setNewline
	self identDepth: 0! !


!WebPage methodsFor: 'accessing' stamp: 'jm 7/29/2010 12:28'!
aidaContentType
	"return 'text/html' as content type for web pages"
	^'text/html'! !

!WebPage methodsFor: 'accessing'!
close
	"only the subwindow can be closed that way, not a main page"
	self error: 'only the subwindows can be closed!!'! !

!WebPage methodsFor: 'accessing'!
disableRealtime
	self 
		otherAt: #RealtimeEnabled 
		put: false! !

!WebPage methodsFor: 'accessing'!
enableRealtime
	"enable realtime (WebSocket) support on this page"
	"it will be disabled after this page will be streamed so you need to enable it again each time!! "
	"set also site #websocketsEnabled setting to actually work"
	self 
		otherAt: #RealtimeEnabled 
		put: true! !

!WebPage methodsFor: 'accessing'!
htmlDocType
	^'<!!DOCTYPE html>'! !

!WebPage methodsFor: 'accessing'!
script: aString
	"add this JavaScript  to scripts executed at the opening of page"
	self scriptBefore: aString.! !

!WebPage methodsFor: 'accessing'!
session
	"return a session on which we are composing this web page"
	^self parent notNil 
		ifTrue: [self parent "context" session]
		ifFalse: [self firstSessionFromStack]! !

!WebPage methodsFor: 'accessing'!
title
	^self 
		otherAt: #pageTitle 
		ifAbsent: ['']! !

!WebPage methodsFor: 'accessing'!
title: aStringOrMultilangAssociation
	self 
		otherAt: #pageTitle 
		put: aStringOrMultilangAssociation! !

!WebPage methodsFor: 'accessing'!
warningMessage
	"if set, this warning will be shown on top of that page in red. Usefull for 
	'Browser not supported' warnings etc"
	^self 
		otherAt: #PageWarningMessage 
		ifAbsent: [nil]! !

!WebPage methodsFor: 'accessing'!
warningMessage: aString
	"if set, this warning will be shown on top of that page in red. Usefull for
	'Browser not supported' warnings etc"
	self 
		otherAt: #PageWarningMessage 
		put: aString! !

!WebPage methodsFor: 'accessing'!
webPage
	^self! !


!WebPage methodsFor: 'testing' stamp: 'janko 4/25/2012 10:59'!
aidaIsRespondingStreamed
	"is this page able to stream HTML directly into response?"
	^false! !

!WebPage methodsFor: 'testing'!
isActive
	"this page is (probably) still displayed on the browser"
	^self parent notNil! !

!WebPage methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isComposite

	"a WebPage is a composite element"
	^true! !

!WebPage methodsFor: 'testing'!
isRealtimeEnabled
	"realtime (WebSocket) support enabled on this page?"
	^self otherAt: #RealtimeEnabled ifAbsent: [false]! !

!WebPage methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebApplication
	^false! !

!WebPage methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebPage
	^true! !

!WebPage methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
shouldIdent
	^false! !


!WebPage methodsFor: 'private-streaming'!
aidaPresenterFor: aRequest on: aSession 
	^self! !

!WebPage methodsFor: 'private-streaming'!
ensureTitleInHeader
	| app htitle |
	app := self app. app ifNil: [^nil].
	htitle := self headers detect: [:assoc | assoc key = 'title'] ifNone: [nil].
	(app title aidaIsAssociation or:  [app title isEmpty]) ifTrue: [^nil].
	htitle isNil
		ifTrue: [self addTitle: app title]
		ifFalse: [htitle value: app title]! !

!WebPage methodsFor: 'private-streaming'!
rearangeHeaders
	"put inline CSS style at the end to allow overriding /screen.css and CSS from libraries"
	| hdrs |
	hdrs := self headers copy.
	1 to: self headers size do: [:inx || header |
		header := hdrs at: inx. "header = aTagString -> aString "
		header key = 'style' ifTrue:
			[self headers removeIndex: inx.
			self headers add: header] ]! !

!WebPage methodsFor: 'private-streaming'!
releasePartially
 	^super releasePartially! !

!WebPage methodsFor: 'private-streaming'!
streamHeaderElementsTo: aStream on: aSession
	| value |
	self headers do: [:assoc | 
		value := assoc value class == Array
			ifFalse: [AIDASite convertToWeb: (self translateIfNeeded: assoc value) on: aSession]
			ifTrue: [assoc value].
		aStream nextPutAll: '  <', assoc key, ' '.
		((assoc key = 'script') | (assoc key = 'style')) 
			ifTrue: [| array | 
				array := assoc value class == Array 
					ifTrue: [value] 
					ifFalse: [Array with: value with: ''].
				aStream nextPutAll: (array at: 1), '>', (array at: 2), '</', assoc key, '>']
			ifFalse: [(assoc key = 'title')
				ifTrue: [aStream nextPutAll: '>',  
						value, '</title>']
				ifFalse: [aStream nextPutAll: value, self tagClosing] ].
		aStream nextPutAll: self eol].! !

!WebPage methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	self 
		ensureTitleInHeader;
		lateInitPageHeaderLinks;
		rearangeHeaders;
		initPageScripts.
	self setStreaming.
	aStream 
		nextPutAll: self htmlDocType, self eol.
	aStream 
		nextPutAll: '<html', (self htmlTagAttributes notNil ifTrue: [' ', self htmlTagAttributes] ifFalse: ['']), '>';
		nextPutAll: self eol, ' <head>', self eol;
		nextPutAll: '  <meta name="generator" content="Aida/Web v', 
			AIDASite version, 
			', Smalltalk Web Application Server (www.aidaweb.si)"', self tagClosing, self eol.
	self streamHeaderElementsTo: aStream on: aSession. "including title"
	aStream nextPutAll: ' </head>', self eol.

	aStream flush.   "to send header to the client so it can start fetching css and js files ASAP"

	aStream nextPutAll: ' <body'. self streamAttributesTo: aStream for: aSession. 
	aStream nextPutAll: '>', self eol.
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	self streamWarningMessageTo: aStream. "if any"

	elements notNil ifTrue: [elements do: [:element | 
		element notNil ifTrue: [element streamHtmlTo: aStream for: aRequest on: aSession] ] ].

	aStream nextPutAll:  self ident, ' </body>', self eol.
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].
	aStream nextPutAll:  '</html>', self eol.
	self resetStreaming.
	self disableRealtime. "eable it everytime a page is refreshed!!"

	self releasePartially. "to preserve memory, but rebuild a simplifed hierarchy if elements with registered id only"! !

!WebPage methodsFor: 'private-streaming'!
streamWarningMessageTo: aStream
	self warningMessage isNil ifTrue: [^nil].
	aStream nextPutAll: '
<div align="center" style="background-color: red">
  <br>
  ', self warningMessage, '
  <br>
  <hr>
</div>
'! !

!WebPage methodsFor: 'private-streaming'!
translateIfNeeded: aStringOrMultilangAssociation
	^aStringOrMultilangAssociation aidaIsAssociation
		ifTrue: [aStringOrMultilangAssociation value] "no translation for now, TEMPORARY!!"
		ifFalse: [aStringOrMultilangAssociation convertToSloveneChars]! !


!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
alink: aSymbol
	"set the color of active link text. It can be in hex format (for example #00FF00) 
	or name of color (for example #White)"
	self attributesAt: #alink put: (self colorValue: aSymbol)! !

!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
alinkColor: aSymbol
	self alink: aSymbol.! !

!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
background: anImageOrURL
	"set the URL for the background image"
	self attributesAt: #background put:
		(anImageOrURL isString 
			ifTrue: [anImageOrURL]
			ifFalse: [self site urlResolver halfUrlFor: anImageOrURL]).! !

!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
bgColor: aSymbol
	"set the color of page background)"
	self attributesAt: #bgcolor put: (self colorValue: aSymbol)! !

!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
bgImage: anImageOrURL
	self background: anImageOrURL.! !

!WebPage methodsFor: 'attributes'!
htmlTagAttributes
	"attributes of HTML tag"
	^self otherAt: #HTMLTagAttributes ifAbsent: [nil].! !

!WebPage methodsFor: 'attributes'!
htmlTagAttributes: aString
	"attributes of HTML tag"
	^self otherAt: #HTMLTagAttributes put: aString.! !

!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
link: aSymbol
	"set the color of link text."
	self attributesAt: #link put: (self colorValue: aSymbol).! !

!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
linkColor: aSymbol
	self vlink: aSymbol.! !

!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
text: aSymbol
	"set the color of page text."
	self attributesAt: #text put: (self colorValue: aSymbol).! !

!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
textColor: aSymbol
	self text: aSymbol.! !

!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
vlink: aSymbol
	"set the color of visited link text."
	self attributesAt: #vlink put: (self colorValue: aSymbol).! !

!WebPage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
vlinkColor: aSymbol
	self vlink: aSymbol.! !


!WebPage methodsFor: 'initialize-release'!
clear
	super clear.
	self initHeaders.! !

!WebPage methodsFor: 'initialize-release'!
initHeaders
	^self 
		otherAt: #pageHeaders 
		put: OrderedCollection new.! !

!WebPage methodsFor: 'initialize-release'!
initPageHeaderLinks
	self app isNil ifTrue: [^nil].
	self addMetaContentType: 'text/html; charset=UTF-8'.    "UTF8 also in HTTP response header"
	self addTitle: self title. "should be after charset definition!! See also #ensureTitleInHeader"
	self addLinkToDefaultFavicon. "that from WebStyle favicon in imgs"
	self addGlobalKeywords. "if any"
	self addRefreshAfterNightlyCleanup.

" moved to #lateInitPageHeaderLinks to put them at the end, after app specific libraries are also put in header
	self addLinkToScreenStyleSheet: self site style screenCssResource.
	self addLinkToPrintStyleSheet: self site style printCssResource.
	self session isMobile ifTrue: 
		[self addLinkToMobileStyleSheet: self site style mobileCssResource].
	self addLinkToJavascript: self site style javascriptResource.
"! !

!WebPage methodsFor: 'initialize-release'!
initPageScripts
	"page body onLoad, onUnload, etc. scripts. Called just before streaming phase begins"
	self basicCreationContext ifNil: "probably just ^WebPage new somewhere"
		[^self].
	self setBrowserSessionContext. "to differentiate between tabs in the same browser window"
	(self isRealtimeEnabled or: [self site webSocketsEnabled "site-wide"]) ifTrue:
		[self checkAndAlertOnSSLSetup.  "if behind server/proxy with SSL support"
		self addWebSocketLoadScript]. "if WebSocket supported in browser then WebSocket channel will open"
	self 
		addLoadUnloadReportScriptAndHandler. "report opening and closing the page or going to another one"
"		addFocusBlurReportScriptAndHandler." "report focus and unfocus/blur the page"! !

!WebPage methodsFor: 'initialize-release'!
lateInitPageHeaderLinks
	"To put them at the end, after app specific libraries are also put in header, they are put in header just
	 before streaming phase begins"
	self app isNil ifTrue: [^nil].
	self addLinkToScreenStyleSheet: self site style screenCssResource.
	self addLinkToPrintStyleSheet: self site style printCssResource.
	self session isMobile ifTrue:  "as cascaded extension of screen CSS!!"
		[self addLinkToMobileStyleSheet: self site style mobileCssResource].
	self addLinkToJavascript: self site style javascriptResource.! !

!WebPage methodsFor: 'initialize-release'!
setRandomId
	"set a random id of that page to have some unique identifier for page load/unload events"
	self basicId: 
		('p', (AIDASite random next * 10000) rounded printString) asSymbol! !


!WebPage methodsFor: 'events'!
onBlur: aJavascriptCode
	self 
		attributesAt: #onBlur 
		add: aJavascriptCode! !

!WebPage methodsFor: 'events'!
onFocus: aJavascriptCode
	self 
		attributesAt: #onFocus 
		add: aJavascriptCode! !

!WebPage methodsFor: 'events'!
onLoad: aJavascriptCode
	self 
		attributesAt: #onLoad 
		add: aJavascriptCode! !

!WebPage methodsFor: 'events'!
onUnload: aJavascriptCode
	self 
		attributesAt: #onUnload 
		add: aJavascriptCode! !


!WebPage methodsFor: 'redirects'!
redirectAfter: aSecondsNumber toUrl: aString
	"redirection or refresh of specified url, does not work on Mozilla!! "
	self addHeader: 'meta' value: 'http-equiv="REFRESH"  content="', 
		aSecondsNumber printString, '; url=', aString, '" '! !

!WebPage methodsFor: 'redirects'!
redirectTo: anObjectOrUrlString
	"send to browser a command to reload current page with this object or Url"
	| link cmd |
	link := WebLink text:'' linkTo: anObjectOrUrlString.
	cmd := WebCommand newLoadUrl: (link composeURLOn: self session).
	self context first
		queueCommand: cmd! !

!WebPage methodsFor: 'redirects'!
redirectTo: anObject view: aViewSymbol
	"send to browser a command to reload current page with this object and view"
	| link cmd |
	link := WebLink text:'' linkTo: anObject view: aViewSymbol.
	cmd := WebCommand newLoadUrl: (link composeURLOn: self session).
	self context first
		queueCommand: cmd! !

!WebPage methodsFor: 'redirects'!
redirectTo: anObject view: aViewSymbol parameter: aParmString value: aValueString
	"send to browser a command to reload current page with this object and view"
	| link cmd |
	link := WebLink text:'' linkTo: anObject view: aViewSymbol.
	link parameter: aParmString value: aValueString.
	cmd := WebCommand newLoadUrl: (link composeURLOn: self session).
	self context first
		queueCommand: cmd! !

!WebPage methodsFor: 'redirects'!
redirectToView: aViewSymbol
	"send to browser a command to reload current page with this view on same object"
	| app object |
	app := self app.
	object := app observee notNil 
		ifTrue: [app observee] 
		ifFalse: [app].
	self 
		redirectTo: object 
		view: aViewSymbol! !
