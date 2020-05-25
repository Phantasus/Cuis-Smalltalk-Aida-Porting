WebList subclass: #DoTabs
	instanceVariableNames: 'blocks'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!

!DoTabs methodsFor: 'adding tabs'!
addTabText: aTabString onClickDo: aBlock 
	(self blocks contains: [:each | each key = aTabString]) 
		ifTrue: [^nil].
	self blocks 
		add: (Association 
				key: aTabString 
				value: (Array with: aBlock with: #()))! !

!DoTabs methodsFor: 'adding tabs'!
addTabText: aTabString onClickDo: aBlock also: aTabStringArray
	(self blocks contains: [:each | each key == aTabString]) 
		ifTrue: [^nil].
	self blocks 
		add: (Association 
				key: aTabString 
				value: (Array with: aBlock with: aTabStringArray))! !


!DoTabs methodsFor: 'private'!
blocks
	^blocks! !

!DoTabs methodsFor: 'private'!
prepareTabsList
	self initElements.
	self blocks do: [:each | 
		(self addNilLinkText: each key)
			onClickDo: 
				[self selected: (self blocks indexOf: each).
				each value first value. "evaulate a block"
				] ]! !

!DoTabs methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareTabsList.
	^super streamHtmlTo: aStream for: aRequest on: aSession! !


!DoTabs methodsFor: 'initialize-release'!
initBlocks
	blocks := OrderedCollection new.! !

!DoTabs methodsFor: 'initialize-release'!
initialize
	super initialize.
	self initBlocks.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

DoTabs class
	instanceVariableNames: ''!

!DoTabs class methodsFor: 'instance creation'!
new
	^super new initialize! !


WebInputField subclass: #WebAutocomplete2Field
	instanceVariableNames: 'choicesAspect choicesObject choiceAspect elementToUpdate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebAutocomplete2Field commentStamp: 'janko 8/25/2012 14:59' prior: 0!
WebAutocompleteField for choosing value from a dropdown choices, which are filtered while writing characters in the field. See WebDemoApp>>ajaxAutocompleteExample.

!


!WebAutocomplete2Field methodsFor: 'private'!
acceptInputFromValue: aValueString
	| vlue choices |
	vlue :=  AIDASite convertFromWeb: aValueString on: self session. "ensure unicode!!"
	vlue := (WebFormElement autoConvertString:  vlue toObject: self value).
	self choicesObject notNil & self choiceAspect notNil ifTrue: "save real object, not only text!! "
		[choices := self choicesObject perform: self choicesAspect.
		vlue := choices detect: [:each | (each perform: self choiceAspect) = vlue] ifNone: [nil] ].
	self value: vlue.! !

!WebAutocomplete2Field methodsFor: 'private'!
choicesAspect
	^choicesAspect! !

!WebAutocomplete2Field methodsFor: 'private'!
choicesAspect: aSymbol
	choicesAspect := aSymbol! !

!WebAutocomplete2Field methodsFor: 'private'!
choicesAspect: aSymbol for: anObject
	"this method is called with our field as argument on that object. It must return a collection of strings"
	"example: myObject searchFor: aString (choicesAspect is #searchFor: )"
	self choicesAspect: aSymbol.
	self choicesObject: anObject! !

!WebAutocomplete2Field methodsFor: 'private'!
choicesObject
	^choicesObject! !

!WebAutocomplete2Field methodsFor: 'private'!
choicesObject: anObject
	choicesObject := anObject! !

!WebAutocomplete2Field methodsFor: 'private'!
getChoicesForEntry: aString
	"return list of choices, selected already entered characters in  aString. "
	"always return text strings, not choice objects!!"
	| choices matchString |
	self choiceAspect isNil "one possiblity, direct question to choicesObject"
		ifTrue: [^self choicesObject perform: self choicesAspect with: aString].
	"other possibility, we select internaly from all choices"
	choices := self choicesObject perform: self choicesAspect.
	matchString := aString, '*'.
	choices := choices select: [:each | matchString match: (each perform: self choiceAspect)].
	^choices collect: [:each | each perform: self choiceAspect].! !


!WebAutocomplete2Field methodsFor: 'private-streaming'!
addSetupScript
	"jQuery specific"
	"Adapted to support mouse selects by help from
       http://jeremydorn.blogspot.com/2010/04/fixing-jquery-ui-autocomplete.html"
	" warning, global variable autocomplete_search_option !!"
self scriptAfter: '
var autocomplete_search_option = false;
$("#', self id, '").autocomplete({
	source : function (request, callback) {
		$.ajax ({
			url : "/aidasession/element-', self id asString, '-ctx', self context id printString, '",
			data : { term : request.term },
			complete : function (xhr, result) {
				if (result !!= "success") return;
				callback (JSON.parse(xhr.responseText));
			}
		});
	},
	change : function(event, ui) {
				aidaEvent(''', 'change' , ''',''', 
				(self ensureId; id) asString, ''',''', 
				self context id asString, ''',',
				'document.getElementById(''', self id asString, ''').value);
	},
	select : function(event, ui) {
				aidaEvent(''', 'change' , ''',''', 
				(self ensureId; id) asString, ''',''', 
				self context id asString, ''',',
				'document.getElementById(''', self id asString, ''').value);
	},  
	focus : function(event, ui) {
				autocomplete_search_option = ui.item;
	},  
});
//bind the select event to mousedown
$("#', self id, '").autocomplete(''widget'').bind(''mousedown.choose_option'',function() {
	//immediately closes autocomplete when option is selected
	$("#', self id, '").autocomplete(''close'');
	//perform desired action
	document.getElementById(''', self id asString, ''').value = autocomplete_search_option.value;
	aidaEvent(''', 'change' , ''',''', 
		(self ensureId; id) asString, ''',''', 
		self context id asString, ''',',
		'autocomplete_search_option.value);
});
'.! !

!WebAutocomplete2Field methodsFor: 'private-streaming'!
aidaPresenterFor: aRequest on: aSession
	"Ajax call via session from jQuery Autocomplete to return matched choices"
	| presenter criteria |
	presenter := WebJSONPresenter new.
	criteria := aRequest queryAt: 'term'. "characters entered so far in Autocomplete field"
	criteria ifNil: [criteria := ''].
	presenter presenterBlock: 
		[self choicesAsJsonForEntry: criteria ].
	^presenter! !

!WebAutocomplete2Field methodsFor: 'private-streaming'!
choicesAsJsonForEntry: aString
	| criteria choices |
	criteria := AIDASite convert: aString fromCodepage: #utf8.
	choices := self getChoicesForEntry: criteria.
	choices := choices collect: [:each | 
		(Dictionary new
			at: #label put: (AIDASite convert: (self empasizeStarting: aString in: each) toCodepage: #utf8);
			at: #value put: (AIDASite convert: each toCodepage: #utf8);
			yourself)].
	^WebJSON stringify: choices.! !

!WebAutocomplete2Field methodsFor: 'private-streaming'!
empasizeStarting: aCriteria in: aString
	"put in bold starting part of text to emphasize the criteria part. Ignore case"
	| in out |
	aCriteria trimBlanks isEmpty ifTrue: [^aString].
	(aCriteria trimBlanks, '*' match: aString) ifFalse: [^aString].
	in := aString readStream.
	out := WriteStream on: String new.
	out nextPutAll: '<b>'.
	aCriteria trimBlanks size timesRepeat: [out nextPut: in next].
	out nextPutAll: '</b>'.
	[in atEnd] whileFalse: [out nextPut: in next].
	^out contents! !

!WebAutocomplete2Field methodsFor: 'private-streaming'!
prepareAttributesToStreamOn: aSession
	"if choiceAspect is set, use it!! "
	super prepareAttributesToStreamOn: aSession.
	self choiceAspect isNil ifTrue: [^super prepareAttributesToStreamOn: aSession].
	self value isNil ifTrue: [^nil].
	(self value class canUnderstand: self choiceAspect) ifFalse: [^nil].
	self attributesAt: #value put: 
		(WebFormElement autoConvertAndEncodeValue: (self value perform: self choiceAspect))! !

!WebAutocomplete2Field methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	self ensureId. 
	self addSetupScript.
	super streamHtmlTo: aStream for: aRequest on: aSession.! !


!WebAutocomplete2Field methodsFor: 'events-ajax'!
afterPostAndUpdate: aWebElement
	"after the selection the field is immediatelly Ajax posted and the specified element is updated"
	self error: 'Deprecated!! Use onChangePostAndUpdate instead'.
	self elementToUpdate: aWebElement! !


!WebAutocomplete2Field methodsFor: 'accessing'!
choiceAspect
	"this method is called on each choice to display choice's text"
	^choiceAspect! !

!WebAutocomplete2Field methodsFor: 'accessing'!
choiceAspect: aSymbol
	choiceAspect := aSymbol! !

!WebAutocomplete2Field methodsFor: 'accessing'!
elementToUpdate
	^elementToUpdate! !

!WebAutocomplete2Field methodsFor: 'accessing'!
elementToUpdate: aWebElement
	elementToUpdate := aWebElement! !


!WebAutocomplete2Field methodsFor: 'initialize-release'!
initialize
	"jQuery specific"
	super initialize.
	JQueryLibrary ensureUI.! !


!WebAutocomplete2Field methodsFor: 'testing'!
isAutocompleteField
	^true! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebAutocomplete2Field class
	instanceVariableNames: ''!

!WebAutocomplete2Field class methodsFor: 'instance creation'!
aspect: aSymbol for: anObject choicesAspect: aChoicesSymbol for: aChoicesObject
	"choicesAspect method is called with our field as argument on aChoicesObject. 
	It must return a collection of strings"
	"example: myObject searchFor: aString (choicesAspect is #searchFor: )"
	^self new 
		aspect: aSymbol for: anObject;
		choicesAspect: aChoicesSymbol for: aChoicesObject! !

!WebAutocomplete2Field class methodsFor: 'instance creation'!
aspect: aSymbol for: anObject choicesAspect: aChoicesSymbol for: aChoicesObject choiceAspect: aTextSymbol
	"choicesAspect method is called with our field as argument on aChoicesObject. 
	It returs a collection of objects, an choice's text 
	is retrieved with a call of choiceAspect method on each"
	^self new 
		aspect: aSymbol for: anObject;
		choicesAspect: aChoicesSymbol for: aChoicesObject;
		choiceAspect: aTextSymbol! !


WebInputField subclass: #WebAutocompleteField
	instanceVariableNames: 'choicesAspect choicesObject choicesCollection choiceAspect elementToUpdate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebAutocompleteField commentStamp: '<historical>' prior: 0!
WebAutocompleteField for choosing value from a dropdown choices, which are filtered while writing characters in the field. See WebDemoApp>>ajaxAutocompleteExample.

!


!WebAutocompleteField methodsFor: 'private-search'!
acceptInputFromValue: aValueString
	| vlue choices |
	vlue :=  AIDASite convertFromWeb: aValueString on: self session. "ensure unicode!!"
	vlue := (WebFormElement autoConvertString:  vlue toObject: self value).
	self choiceAspect notNil ifTrue: "save real object, not only text!! "
		[choices := self choicesCollection isNil
			ifTrue: [self choicesObject perform: self choicesAspect]
			ifFalse: [self choicesCollection].
		vlue := choices detect: [:each | (each perform: self choiceAspect) = vlue] ifNone: [nil] ].
	self value: vlue.! !

!WebAutocompleteField methodsFor: 'private-search'!
getChoicesForEntry: aString
	"return list of choices, selected already entered characters in  aString. "
	"always return text strings, not choice objects!!"
	| choices matchString |
	(self choicesCollection isNil and: [self choiceAspect isNil]) "one possiblity, direct question to  "
		ifTrue: [^self choicesObject perform: self choicesAspect with: aString].   		" choicesObject"
	"other possibility, we select internaly from all choices"
	choices := self choicesCollection isNil 
		ifTrue: [self choicesObject perform: self choicesAspect]
		ifFalse: [self choicesCollection].
	matchString := aString, '*'.
	choices := choices select: [:each | matchString match: (each perform: self choiceAspect)].
	^choices collect: [:each | each perform: self choiceAspect].! !


!WebAutocompleteField methodsFor: 'private-streaming'!
addSetupScriptOn: aStream choicesElement: aChoicesElement
	"Scriptaculous specific"
	| contextParm url afterUpdateElement updateUrl parms |
	contextParm := WebContext contextIdName "aidaCtx", '=', self app context id printString.
	url := self ajaxCallUrlExtended, '&ajaxAutocompleteField&', contextParm.
	afterUpdateElement := self elementToUpdate isNil 
		ifTrue: [''] 
		ifFalse:
			[self elementToUpdate ensureId. 
			updateUrl := self ajaxCallUrl. 
			parms := self ajaxCallUrlParametersFor: self elementToUpdate context: self app context. "is this needed"
 			parms := parms, '&ajaxElementToRecreateId=', self elementToUpdate id asString.
			'afterUpdateElement: function(element, selectedElement){var field = Form.Element.serialize(''',
			self id asString, '''); var name = $(''',
			self id asString, ''').name; new Ajax.Updater(''', self elementToUpdate id asString, ''', ''', updateUrl, 
			''', {method: ''post'', postBody: field + ''', ('&', parms), 
			'&ajaxSingleField='' + name, evalScripts: true})} '].

	aStream nextPutAll: '<script type="text/javascript">new Ajax.Autocompleter(''', 
		self id asString, ''', ''', aChoicesElement id asString, ''', ''', url, 
		''', {', afterUpdateElement, '});</script>', self eol.! !

!WebAutocompleteField methodsFor: 'private-streaming' stamp: 'janko 9/19/2011 14:31'!
prepareAttributesToPrintOn: aSession
	"if choiceAspect is set, use it!! "
	super prepareAttributesToPrintOn: aSession.
	self choiceAspect isNil ifTrue: [^super prepareAttributesToPrintOn: aSession].
	self value isNil ifTrue: [^nil].
	(self value class canUnderstand: self choiceAspect) ifFalse: [^nil].
	self attributesAt: #value put: 
		(WebFormElement autoConvertAndEncodeValue: (self value perform: self choiceAspect))! !

!WebAutocompleteField methodsFor: 'private-streaming'!
prepareAttributesToStreamOn: aSession
	"if choiceAspect is set, use it!! "
	super prepareAttributesToStreamOn: aSession.
	self choiceAspect isNil ifTrue: [^super prepareAttributesToStreamOn: aSession].
	self value isNil ifTrue: [^nil].
	(self value class canUnderstand: self choiceAspect) ifFalse: [^nil].
	self attributesAt: #value put: 
		(WebFormElement autoConvertAndEncodeValue: (self value perform: self choiceAspect))! !

!WebAutocompleteField methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	| choicesElement |
	choicesElement := (WebElement newClass: #'auto_complete') parent: self.
	self ensureId. choicesElement ensureId.
	super streamHtmlTo: aStream for: aRequest on: aSession.
	choicesElement streamHtmlTo: aStream for: aRequest on: aSession.
	self addSetupScriptOn: aStream choicesElement: choicesElement.! !


!WebAutocompleteField methodsFor: 'events-ajax'!
afterPostAndUpdate: aWebElement
	"after the selection the field is immediatelly Ajax posted and the specified element is updated"
	self elementToUpdate: aWebElement! !


!WebAutocompleteField methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
choiceAspect
	"this method is called on each choice to display choice's text"
	^choiceAspect! !

!WebAutocompleteField methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
choiceAspect: aSymbol
	choiceAspect := aSymbol! !

!WebAutocompleteField methodsFor: 'accessing'!
elementToUpdate
	^elementToUpdate! !

!WebAutocompleteField methodsFor: 'accessing'!
elementToUpdate: aWebElement
	elementToUpdate := aWebElement! !


!WebAutocompleteField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
choicesAspect
	^choicesAspect! !

!WebAutocompleteField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
choicesAspect: aSymbol
	choicesAspect := aSymbol! !

!WebAutocompleteField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
choicesAspect: aSymbol for: anObject
	"this method is called with our field as argument on that object. It must return a collection of strings"
	"example: myObject searchFor: aString (choicesAspect is #searchFor: )"
	self choicesAspect: aSymbol.
	self choicesObject: anObject! !

!WebAutocompleteField methodsFor: 'private'!
choicesCollection
	^choicesCollection! !

!WebAutocompleteField methodsFor: 'private'!
choicesCollection: aCollection
	choicesCollection := aCollection! !

!WebAutocompleteField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
choicesObject
	^choicesObject! !

!WebAutocompleteField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
choicesObject: anObject
	choicesObject := anObject! !


!WebAutocompleteField methodsFor: 'initialize-release'!
initialize
	"Scriptaculous specific"
	super initialize.
	ScriptaculousLibrary ensureScriptaculous.! !


!WebAutocompleteField methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isAutocompleteField
	^true! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebAutocompleteField class
	instanceVariableNames: ''!

!WebAutocompleteField class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject choicesAspect: aChoicesSymbol for: aChoicesObject
	"choicesAspect method is called with our field as argument on aChoicesObject. 
	It must return a collection of strings"
	"example: myObject searchFor: aString (choicesAspect is #searchFor: )"
	^self new 
		aspect: aSymbol for: anObject;
		choicesAspect: aChoicesSymbol for: aChoicesObject! !

!WebAutocompleteField class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject choicesAspect: aChoicesSymbol for: aChoicesObject choiceAspect: aTextSymbol
	"choicesAspect method is called with our field as argument on aChoicesObject. 
	It returs a collection of objects, an choice's text 
	is retrieved with a call of choiceAspect method on each"
	^self new 
		aspect: aSymbol for: anObject;
		choicesAspect: aChoicesSymbol for: aChoicesObject;
		choiceAspect: aTextSymbol! !


WebInputField subclass: #WebDateInputField
	instanceVariableNames: 'button'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebDateInputField commentStamp: '<historical>' prior: 0!
WebDateInputField is used for entry of dates with help od JavaScript calendar (http://www.dynarch.com/projects/calendar/), from Romanian author Mihai Bazon. 
See also WebStyle calendar* methods, specially calendarCSS and calendarLang*

Usage is similar as usual input field. Example: 
	element addDateInputFieldAspect: #methodName for: self observee
 
Instance Variables:
	button	<WebImage>	
!


!WebDateInputField methodsFor: 'private'!
addCalendarSetupScriptOn: aStream
	aStream nextPutAll: '<script type="text/javascript">Calendar.setup({ inputField : "', self inputFieldId, 		'", ifFormat : "', self inputFieldFormat, 
		'", button : "', self buttonId, '"});</script>', self eol! !

!WebDateInputField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
button
	^button! !

!WebDateInputField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
button: aWebButton
	button := aWebButton! !

!WebDateInputField methodsFor: 'private'!
buttonId
	^self button id! !

!WebDateInputField methodsFor: 'private'!
buttonImage
	"from WebStyle calendarButtonGif !! "
	| methodImage |
	methodImage := WebMethodImage
		fromMethod: #calendarButtonGif
		on: self style 
		contentType: 'image/gif' 
		site: self style site.
	^(WebImage image: methodImage)
		title: 'Choose date';
		imageAlign: #middle;
		onMouseOver: 'this.style.cursor=''pointer'' ';
		onMouseOut: 'this.style.cursor=''default'' '! !

!WebDateInputField methodsFor: 'private'!
inputFieldFormat
	"the date format"
	^'%e.%m.%Y'  "17.01.1965"! !

!WebDateInputField methodsFor: 'private'!
inputFieldId
	^self id! !

!WebDateInputField methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self ensureId.
	self button: self buttonImage. self button registerId.
	super streamHtmlTo: aStream for: aRequest on: aSession.
	self button streamHtmlTo: aStream for: aRequest on: aSession.
	self addCalendarSetupScriptOn: aStream.! !


!WebDateInputField methodsFor: 'initialize-release'!
initialize
	super initialize.
	self size: 11. 
	self app style ensureJsAndCssForCalendarInHeader.
	self app style ensureJsResourceForCalendarSetup.! !


!WebDateInputField methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isDateInputField
	^true! !


WebInputField subclass: #WebDelayedField
	instanceVariableNames: 'delay'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebDelayedField commentStamp: '<historical>' prior: 0!
WebDelayedField is used to delayed Ajax posting to server. It waits for delay after last key input, before it posts its contents. Ideal for live-search fields.

Use it as a normal input field, sending it #onClickPost, #onClickPostAndUdate: etc.
!


!WebDelayedField methodsFor: 'accessing' stamp: 'mivsek 6/13/2007 16:16'!
defaultDelay
	"delay before posting, in seconds"
	^1! !

!WebDelayedField methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
delay
	"delay before posting, in seconds"
	delay isNil ifTrue: [self delay: self defaultDelay].
	^delay! !

!WebDelayedField methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
delay: aNumber
	"delay before posting, in seconds"
	delay := aNumber! !


!WebDelayedField methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isDelayedField
	^true! !


!WebDelayedField methodsFor: 'events-ajax'!
onChangePost
	"on key up, not on change we send a #change event with a delay after last event!! "
	self setSingleFieldPost.   "so that field will actually be saved, otherwise change will be just announced"
	self onKeyUp: 
		(self scriptForEvent: #change context: self context). "script with delayed post!!"
	(self eventHandlerFor: #change)
		addAcceptPostedInput! !

!WebDelayedField methodsFor: 'events-ajax'!
onChangePostAndUpdate: anElement with: anArgObject
	"on key up, not on change we send a #change event with a delay after last event!! "
	anElement isNil ifTrue: [self error: 'no element to update!!'].
	anElement ensureId. 
	self onChangePost.
	(self eventHandlerFor: #change)
		addUpdate: anElement with: anArgObject.! !


!WebDelayedField methodsFor: 'private'!
scriptForEvent: anEventSymbol context: aWebContext
	"send current value of this form element, but with delay after last event"
	^'aidaDelayedEvent(''', anEventSymbol asString, ''',''', 
		(self ensureId; id) asString, ''',''', 
		aWebContext id asString, ''',',
		'this.value,', (self delay*1000) printString, ');'

"	^'aidaEvent(''', anEventSymbol asString, ''',''', 
		(self ensureId; id) asString, ''',''', 
		aWebContext id asString, ''',',
		'this.value);'
"! !


WebWidget subclass: #WebDialog
	instanceVariableNames: 'type text'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebDialog commentStamp: '<historical>' prior: 0!
WebDialog for different dialgos with a user, like delete confirmation ans similar. See class creation methods to create specific dialogs:

- WebDialog class>>newConfirm 
      for simple yes/no answers to a stated question. Used mainly for confirmations of actions like delete in action methods.

For styling see and override CSS rules from DefaultWebStyle css28Dialog
!


!WebDialog methodsFor: 'views'!
build
	self clear.
	self class: #dialog.
	self isConfirmation ifTrue: 
		[self buildConfirmation].
	self isInfo ifTrue: 
		[self buildInfo].! !

!WebDialog methodsFor: 'views'!
buildConfirmation
	self addText: self text.
	self addBreak; addBreak.
	(self addButtonText: self style yesText asUppercase)
		class: #'dialog-button';
		onSubmitAnswer: true;
		onSubmitClose.
	self addSpace.
	(self addButtonText: self style noText asUppercase)
		class: #'dialog-button';
		onSubmitAnswer: false;
		onSubmitClose.! !

!WebDialog methodsFor: 'views'!
buildInfo
	self addText: self text.
	self addBreak; addBreak.
	(self addButtonText: 'Close')
		onSubmitClose.! !


!WebDialog methodsFor: 'testing'!
isConfirmation
	^self type = #confirmation! !

!WebDialog methodsFor: 'testing'!
isInfo
	^self type = #information! !


!WebDialog methodsFor: 'accessing'!
text
	"text to be written on a dialog, like a confirmation question"
	text isNil ifTrue: [^''].
	^text! !

!WebDialog methodsFor: 'accessing'!
text: aString
	"text to be written on a dialog, like a confirmation question"
	text := aString.! !


!WebDialog methodsFor: 'private'!
type
	"#confirmation, #information, etc."
	^type! !

!WebDialog methodsFor: 'private'!
type: aSymbol
	type := aSymbol! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebDialog class
	instanceVariableNames: ''!

!WebDialog class methodsFor: 'instance creation'!
newConfirm
	"confirm something with YES or NO button"
	^super new
		type: #confirmation;
		initialize! !

!WebDialog class methodsFor: 'instance creation'!
newInfo
	"just show some information and close button"
	^super new
		type: #information;
		initialize! !


WebWidget subclass: #WebGrid
	instanceVariableNames: 'collection aspect object filtered columns page settings'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebGrid commentStamp: '<historical>' prior: 0!
WebGrid is a powerfull widget to show tabular data, with filters, sorting, paginations and many more. See WebDemoApp>>viewGrid for examples

!


!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
addNewColumn
	self columns add: ((WebGridColumn newOn: self) id: (self columns size + 1))! !

!WebGrid methodsFor: 'private' stamp: 'np 10/17/2008 17:40'!
aidaDeepCopyNotIn: aDict 
	^ nil! !

!WebGrid methodsFor: 'private'!
aspect
	^aspect! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
checkboxes
	"nil or column"
	^self settingsAt: #checkboxesColumn ifAbsent: [nil]! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
checkboxes: aColumnId
	^self settingsAt: #checkboxesColumn put: aColumnId! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
checkboxesCollection
	"collection of checked row objects"
	^self settingsAt: #checkboxesCollection ifAbsent: [nil]! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
checkboxesCollection: aCollection
	^self settingsAt: #checkboxesCollection put: aCollection! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
columns
	columns isNil ifTrue: [self initColumns].
	^columns! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
cssClass
	^self settingsAt: #cssClass ifAbsent: [self defaultCssClass]! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
filtered
	"objects which pass filter criteria. if nil, filters are not set"
	filtered isNil ifTrue: [self initFiltered].
	^filtered! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
filtered: aCollection
	filtered := aCollection! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
lastColumn
	^self columns notEmpty ifTrue: [self columns last] ifFalse: [nil].! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
numbering
	"false or column"
	^self settingsAt: #numberingColumn ifAbsent: [nil]! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
numbering: aColumnId
	"false or column"
	^self settingsAt: #numberingColumn put: aColumnId! !

!WebGrid methodsFor: 'private'!
object
	^object! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
page
	"number of a page currently shown"
	page isNil ifTrue: [self page: 1].
	^page! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
page: aNumber
	page := aNumber! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
parent: aWebElement
	"self buildTable." "build just before rendering!!"
	^super parent: aWebElement! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
removeLastColumn
	self columns notEmpty ifTrue: [self columns remove: self lastColumn].! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
representBinaryOn: writer
	^0! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
rowsOnPage
	^self settingsAt: #rowsOnPage! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
settings
	settings isNil ifTrue: [self initSettings].
	^settings! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
settingsAt: aSymbol
	^self settingsAt: aSymbol ifAbsent: [nil]! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
settingsAt: aSymbol ifAbsent: aBlock
	^self settings at: aSymbol ifAbsent: aBlock! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
settingsAt: aSymbol put: aValue
	self settings at: aSymbol put: aValue! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
sortColumn
	"false or column"
	^self settingsAt: #sortColumn ifAbsent: [nil]! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
sortColumn: aColumnId
	"false or column"
	^self settingsAt: #sortColumn put: aColumnId! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
sortOrder
	^self settingsAt: #sortOrder ifAbsent: [#ascending]! !

!WebGrid methodsFor: 'private' stamp: ' 21/4/07 22:07'!
sortOrder: aSymbol
	"#ascending or #descending"
	^self settingsAt: #sortOrder put: aSymbol! !


!WebGrid methodsFor: 'private-building'!
ajaxUpdateWith: aParmString
	"set sorting and paging commands if any"
	| parm |
	(aParmString notNil and: ['sort-*' match: aParmString]) ifTrue: 
		[parm := aParmString readStream upTo: $-; upToEnd.
		(self columnWithId: parm asInteger) sort. "or toogle sort order"
		self page: 1]. "always back to first page after sort change"
	(aParmString notNil and: ['page-*' match: aParmString]) ifTrue: 
		[parm := aParmString readStream upTo: $-; upToEnd.
		self page: parm asInteger]. 
	^self  "actuall update happens in second, streaming phase"! !

!WebGrid methodsFor: 'private-building'!
buildPageSelectionRow
	| fullLength |
	self newRow. self row class: #tablePageSelection.
	self cell colspan: self columns size; align: #center.
	fullLength := self filtered size.
	(self settingsAt: #noPageNumbers) notNil ifTrue: "just show number of rows"
		[self cell addText: fullLength printString. 
		^self].
	1 to: (fullLength // self rowsOnPage) + 1 do: [:inx |
		inx = self page 
			ifTrue: [self cell addTextBold: inx printString]
			ifFalse: [self cell add: (self linkForPage: inx)].
		self cell addText: ' | '].! !

!WebGrid methodsFor: 'private-building'!
buildTable
	self form initElements. 
	self initTable. "here, not in form!! But it will be added to form too"
	self table class: self cssClass. 
	self width notNil ifTrue: [self table width: self width].
	self buildTableHeader.
	self setCollectionFromAspect. "if aspect set instead of collection directly"
	self sortColumnsIfNessesary.
	self hasFilters 
		ifTrue: [self buildTableFilterRow. self filterRows]
		ifFalse: [self filtered removeAll; addAll: self collection]. "filtered is what is shown, not collection!!"
	self buildTableRows.
	self needsSummary ifTrue: [self buildTableSummaryRow].
	self hasPages ifTrue: [self buildPageSelectionRow].
	self registerFormElements.  "registrations of grid form elements"! !

!WebGrid methodsFor: 'private-building'!
buildTableFilterRow
	| field |
	self newRow.
	self filterCssClass ifNotNil: [self row class: self filterCssClass].
	self columns do: [:each | 
		each align notNil 
			ifTrue: [self cell align: each align].
		each filter notNil ifTrue: 
			[field := WebDelayedField aspect: #filter for: each size: 10.
			each filterWidth notNil ifTrue: [field size: each filterWidth].
			(self wasFilterChangedFor: each on: field) ifTrue: [field focus].
			field onChangePostAndUpdate: self.
			field blockEnterKey.
			self cell add: field].
		each shouldAddColumnSpace 
			ifTrue: [self newCell width: 0.001].
		each ~= self columns last 
			ifTrue: [self newCell] ].! !

!WebGrid methodsFor: 'private-building'!
buildTableHeader
	self columns do: [:each | 
		self cell setHeader.
		each align notNil ifTrue: [self cell align: each align].
		each name notNil ifTrue: [self cell add: (self sortLinkColumn: each)].
		each isSortedAscending ifTrue: [self cell addGif: #arrowOrangeUpGif].
		each isSortedDescending ifTrue: [self cell addGif: #arrowOrangeDownGif].
		each shouldAddColumnSpace ifTrue: [self newCell "setHeader;" width: 0.008; addNbSp].
		each ~= self columns last 
			ifTrue: [self newCell] ].! !

!WebGrid methodsFor: 'private-building'!
buildTableRowFor: anObject
	"this is an updatable row"
	| row rowNr cell |
	row := WebTableRow new.
	rowNr := self currentRowNrFor: anObject. "by counting rows so far in grid's table or from row object"
	row 
		otherAt: #rowObject put: anObject;
		otherAt: #rowNr put: rowNr.
	self setRowAttributesFor: row object: anObject.
	cell := WebTableCell new.
	self columns do: [:column |
		(rowNr = 1 and: [column width notNil ])
			ifTrue: [cell width: column width].
		self 
			printColumn: column 
			index: rowNr 
			object: anObject 
			in: cell.
		row add: cell.
		column shouldAddColumnSpace 
			ifTrue: [row add: (WebTableCell new width: 0.001)].
		column ~= self columns last 
			ifTrue: [cell := WebTableCell new] ].
		self rowUpdateWhenChangedEnabled
			ifTrue: [row updateWhenChanged: anObject].  "add this row to dependency registry in site"
	^row! !

!WebGrid methodsFor: 'private-building'!
buildTableRows
	| objects inx pageLength |
	objects := self filtered.
	self resetSummary. 
	inx := 0. 
	objects do: [:obj | 
		inx := inx + 1. "summary in advance!!"
		self columns do: [:column | 
			self summaryForColumn: column index: inx object: obj]].
	pageLength := self hasPages 
		ifTrue: [self rowsOnPage] 
		ifFalse: [objects size]. 
	(self page-1) * pageLength > objects size 
		ifTrue: [self page: 1]. 
	objects := objects 
		copyFrom: ((self page-1) * pageLength)+1 
		to: (self page * pageLength min: objects size).
	self rowsStart: self elements size + 1.  "to signal in #buildTableRow: where to start counting rows"
	objects do: [:obj || row |
		row := self buildTableRowFor: obj.
		self table add: row]! !

!WebGrid methodsFor: 'private-building' stamp: ' 21/4/07 22:07'!
buildTableSummaryRow
	self newRow. self row class: #summary.
	self columns do: [:each | 
		each align notNil ifTrue: [self cell align: each align].
		each name notNil ifTrue: [self cell addText: each summaryValue].
		each ~= self columns last ifTrue: [self newCell] ].! !

!WebGrid methodsFor: 'private-building'!
currentRowNrFor: anObject
	"which row we are building right now, it is one more than current rows in table"
	"in case of update find index of that row in a table"
	| existing |
	existing := self allElements
		detect: [:row | (row otherAt: #rowObject) = anObject]
		ifNone: [nil].
	^existing isNil
		ifTrue: [self table elements size - self rowsStart + 1] "when we are building a new grid"
		ifFalse: [existing otherAt: #rowNr] "when we are updating an existing row"! !

!WebGrid methodsFor: 'private-building' stamp: ' 21/4/07 22:07'!
endTagFor: anObject
	(self rowBoldBlock notNil and: [self rowBoldBlock value: anObject]) ifTrue: [^'</b>'].
	^''! !

!WebGrid methodsFor: 'private-building'!
linkForPage: aNumber
	| app linkTarget dummyLink |
	app := self app.
	linkTarget := app isStandaloneApp ifTrue: [app class] ifFalse: [app observee].
	dummyLink := WebLink text: aNumber printString linkTo: (Array with: linkTarget with: '-').
	app inDefaultView ifFalse: [dummyLink view: app view].
	dummyLink onClickUpdate: self with: 'page-', aNumber printString.
	^dummyLink! !

!WebGrid methodsFor: 'private-building'!
prepareToHtmlStreamingOn: aSession
	super prepareToHtmlStreamingOn: aSession.
	self buildTable! !

!WebGrid methodsFor: 'private-building'!
printCheckboxIndex: aNumber object: anObject in: anElement
	| field |
	field := WebCheckBox newForObject: anObject from: self checkboxesCollection.
"	self app form registerFormElementsIn: field.  "
	anElement add: field.! !

!WebGrid methodsFor: 'private-building'!
printColumn: aColumn index: aNumber object: anObject in: anElement
	| start |
	aColumn align notNil 
		ifTrue: [anElement align: aColumn align].
	aColumn isNumbered  ifTrue: 
		[aColumn hasAddBlock ifTrue:
			[^self error: 'this column is numbered and cannot have addBlock!!'].
		start := self hasPages ifTrue: [(self page-1) * self rowsOnPage] ifFalse: [0].
		^self printNumber: start+aNumber object: anObject in: anElement].
	aColumn isCheckboxed  
		ifTrue: [^self printCheckboxIndex: aNumber object: anObject in: anElement].
	aColumn hasLink 
		ifTrue: [^self printLinkTo: anObject column: aColumn in: anElement]. 
	aColumn hasAddBlock 
		ifTrue: [^anElement add: (aColumn addBlock value: anObject)].
	anElement addText: 
		(self startTagFor: anObject), (aColumn viewBlock value: anObject), (self endTagFor: anObject)! !

!WebGrid methodsFor: 'private-building' stamp: ' 21/4/07 22:07'!
printLinkTo: anObject column: aColumn in: anElement
	| view object linkText |
	view := aColumn linkView notNil ifTrue: [aColumn linkView] ifFalse: [#main].
	object := aColumn linkAspect notNil 
		ifTrue: [anObject perform: aColumn linkAspect] ifFalse: [anObject].
	linkText := (self startTagFor: anObject), (aColumn viewBlock value: anObject), 
		(self endTagFor: anObject).
	object notNil
		ifTrue: [anElement addLinkTo: object text: linkText view: view]
		ifFalse: [anElement addText: linkText]! !

!WebGrid methodsFor: 'private-building' stamp: ' 21/4/07 22:07'!
printNumber: aNumber object: anObject in: anElement
	anElement addText: 
		(self startTagFor: anObject), aNumber printDotString, '.', (self endTagFor: anObject)! !

!WebGrid methodsFor: 'private-building' stamp: ' 21/4/07 22:07'!
resetSummary
	self columns do: [:each | each resetSummary].! !

!WebGrid methodsFor: 'private-building'!
rowsStart
	"at which position in subelements a first row starts. See #buildTableRows"
	^self
		otherAt: #rowsStart
		ifAbsent: [1]! !

!WebGrid methodsFor: 'private-building'!
rowsStart: aNumber
	"at which position in subelements a first row starts. See #buildTableRows"
	self
		otherAt: #rowsStart
		put: aNumber! !

!WebGrid methodsFor: 'private-building'!
setCollectionFromAspect
	"if aspect set instead of colelction directly"
	self aspect isNil ifTrue: [^nil].
	self collection: (self object perform: self aspect)! !

!WebGrid methodsFor: 'private-building'!
setRowAttributesFor: aWebRow object: anObject
	self rowUpdateWhenChangedEnabled ifTrue:
		[self setUpdateDependencyFor: aWebRow object: anObject].
	(self rowRedBlock notNil and: [self rowRedBlock value: anObject]) 
		ifTrue: [^aWebRow class: #red].
	(self rowGreenBlock notNil and: [self rowGreenBlock value: anObject]) 
		ifTrue: [^aWebRow class: #green].
	(self rowBlueBlock notNil and: [self rowBlueBlock value: anObject]) 
		ifTrue: [^aWebRow class: #blue].
	(self rowYellowBlock notNil and: [self rowYellowBlock value: anObject]) 
		ifTrue: [^aWebRow class: #yellow].
	(self rowOrangeBlock notNil and: [self rowOrangeBlock value: anObject]) 
		ifTrue: [^aWebRow class: #orange].
	(self rowGrayBlock notNil and: [self rowGrayBlock value: anObject]) 
		ifTrue: [^aWebRow class: #gray].! !

!WebGrid methodsFor: 'private-building'!
setUpdateDependencyFor: aWebRow object: anObject
 	"to update this row when object change (with anObject aidaAnnounceChange)"
	aWebRow 
		registerId; 
		updateWhenChanged: anObject! !

!WebGrid methodsFor: 'private-building' stamp: ' 21/4/07 22:07'!
startTagFor: anObject
	(self rowBoldBlock notNil and: [self rowBoldBlock value: anObject]) ifTrue: [^'<b>'].
	^''! !

!WebGrid methodsFor: 'private-building'!
streamHtmlTo: aStream for: aRequest on: aSession
	"self buildTable." "not so late, build imediately after adding to some parent!!"
	self prepareToHtmlStreamingOn: aSession. "buildTable"
	aStream nextPutAll: self ident, '<div'. self streamAttributesTo: aStream for: aSession. 
	aStream nextPutAll: '>', self eol.
	elements notNil ifTrue: [elements do: [:element | 
		element notNil ifTrue: [element streamHtmlTo: aStream for: aRequest on: aSession] ] ].
	aStream nextPutAll: self ident, '</div>', self eol.! !

!WebGrid methodsFor: 'private-building' stamp: ' 21/4/07 22:07'!
summaryForColumn: aColumn index: aNumber object: anObject
	aColumn needsSummary ifFalse: [^nil].
	aColumn addToSummary: anObject.! !


!WebGrid methodsFor: 'private-filters'!
canFilterObject: anObject onColumns: aColumnsToFilter
	aColumnsToFilter do: [:column || value |
		column aspect notNil ifTrue: 
			[value := anObject perform: column aspect].
		column addBlock notNil ifTrue:   "to filter addBlocks too!!"
			[value := (column addBlock value: anObject) asString].
		value notNil ifTrue: 
			[value := WebFormElement autoConvertToString: value.
			value notNil ifTrue:
				[(('*', (column filter trimBlanks copyWithout: $*), '*') match: value) ifFalse: [^false]]  ] ] . "always * "
"			value notNil ifTrue:
				[((column filter, '*') match: value) ifFalse: [^false]]  ] ] .
"	^true! !

!WebGrid methodsFor: 'private-filters'!
filterRows
	| columnsToFilter | 
	columnsToFilter := self columns select: [:each | each isFilterEntered]. 
	self filtered removeAll; addAll: 
		(columnsToFilter notEmpty
			ifTrue: [(self collection select: [:obj | 
				self canFilterObject: obj onColumns: columnsToFilter])] 
			ifFalse: [self collection])! !

!WebGrid methodsFor: 'private-filters'!
wasFilterChangedFor: aWebGridColumn on: anInputField
	 aWebGridColumn filter ~= aWebGridColumn filterValue ifTrue: 
		[aWebGridColumn filterValue: aWebGridColumn filter.
		^true].
	^false! !


!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
checkboxesColumn: aColumnId collection: aCollection
	"this column will have checboxes. Checked row objects will be in aCollection.
	preselected rows are done from initial aCollection"
	self checkboxes: aColumnId.
	self checkboxesCollection: aCollection! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
column: aColumnId addBlock: aBlock
	"this block will be called with current row object as an argument. 
	It must return kind of WebElement which will be added to the table cell"
	self columns size < aColumnId ifTrue: [self addNewColumn].
	(self columns at: aColumnId) addBlock: aBlock! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
column: aColumnId viewBlock: aBlock
	"this block will be called with current row object as an argument. It must return plain string!!"
	self columns size < aColumnId ifTrue: [self addNewColumn]. "?"
	(self columns at: aColumnId) viewBlock: aBlock! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
columnAlign: anArrayOfSymbols
	"#left #right #center, nil if default left is used"
	| inx |
	inx := 1.
	anArrayOfSymbols do: [:each |
		self columns size < inx ifTrue: [self addNewColumn].
		(self columns at: inx) align: each.
		inx := inx + 1]! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
columnAspects: anArrayOfSymbols
	"methods to be called for each column on every object in collection"
	| inx |
	inx := 1.
	anArrayOfSymbols do: [:each |
		self columns size < inx ifTrue: [self addNewColumn].
		(self columns at: inx) aspect: each.
		inx := inx + 1]! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
columnFilters: anArrayOfBooleanOrNumbers
	"row with filter input fields, put true or field width on a column to add filter"
	| inx |
	inx := 1.
	anArrayOfBooleanOrNumbers do: [:each |
		self columns size < inx ifTrue: [self addNewColumn].
		each notNil ifTrue: [(self columns at: inx) setFilter].
		(each notNil and: [each class ~= True "but number"])  
			ifTrue: [(self columns at: inx) filterWidth: each].
		inx := inx + 1]! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
columnLinkAspects: anArrayOfSymbols
	"url link to an aspects of an object. Specify views with separate columnLinkViews: method"
	| inx |
	inx := 1.
	anArrayOfSymbols do: [:each |
		self columns size < inx ifTrue: [self addNewColumn].
		(self columns at: inx) linkAspect:  each.
		inx := inx + 1]! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
columnLinkViews: anArrayOfSymbols
	"link to an aspect of object(if set with columnLinks:, otherwise to object itself) with a view 
	will be shown in thi column"
	| inx |
	inx := 1.
	anArrayOfSymbols do: [:each |
		self columns size < inx ifTrue: [self addNewColumn].
		(self columns at: inx) linkView:  each.
		inx := inx + 1]! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
columnNames: anArrayOfStrings
	"set names of columns to be shown in header of table"
	| inx |
	inx := 1.
	anArrayOfStrings do: [:each |
		self columns size < inx ifTrue: [self addNewColumn].
		(self columns at: inx) name: each.
		inx := inx + 1]! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
columnWidth: anArrayOfNumbers
	"width of column or nil."
	| inx |
	inx := 1.
	anArrayOfNumbers do: [:each |
		self columns size < inx ifTrue: [self addNewColumn].
		(self columns at: inx) width: each.
		inx := inx + 1]! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
noZeros
	"don't show if value is zero"
	^self settingsAt: #noZeros put: true! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
setNumbering
	"in first column a sequential nr. of this row will be shown"
	self setNumberingOn: 1! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
setNumberingOn: aColumnId
	"in this column a sequential nr. of this row will be shown"
	self numbering: aColumnId! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
shortDates
	"year in two digits only"
	^self settingsAt: #shortDates put: true! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
sortAscendingOn: aColumnId
	"this column will be sorted ascending"
	self sortColumn: aColumnId.
	self sortOrder: #ascending! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
sortDescendingOn: aColumnId
	"this column will be sorted ascending"
	self sortColumn: aColumnId.
	self sortOrder: #descending! !

!WebGrid methodsFor: 'settings-column' stamp: ' 21/4/07 22:07'!
sortOn: aColumnId
	"this column will be sorted ascending"
	self sortAscendingOn: aColumnId! !


!WebGrid methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
collection
	collection isNil ifTrue: [^#()].
	^collection! !

!WebGrid methodsFor: 'accessing'!
collection: aCollection
	"to be Ajax updatable with fresh content use #collectionAspect:for: instead!!"
	collection := aCollection! !

!WebGrid methodsFor: 'accessing'!
collectionAspect: aCollectionMethodSymbol for: anObject
	"Wse this way for updatable grids, instread of setting a collection directy!!"
	"When Ajax update request comes, aspect of this object is called to get a fresh collection"
	aspect := aCollectionMethodSymbol.
	object := anObject.! !

!WebGrid methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
columnWithId: aNumber
	aNumber > self columns size ifTrue: [^nil].
	^self columns at: aNumber! !

!WebGrid methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
defaultCssClass
	^#webGrid! !

!WebGrid methodsFor: 'accessing' stamp: 'np 5/7/2008 17:37'!
defaultWidth
	^1 "100%"! !

!WebGrid methodsFor: 'accessing' stamp: 'np 5/7/2008 17:37'!
width
	^self settingsAt: #width ifAbsent: [self defaultWidth]! !

!WebGrid methodsFor: 'accessing' stamp: 'np 5/7/2008 17:38'!
width: anInteger
	self settingsAt: #width put: anInteger! !


!WebGrid methodsFor: 'private-settings'!
filterCssClass
	"CSS class of filter row"
	^self settingsAt: #filterCssClass ifAbsent: [nil]! !


!WebGrid methodsFor: 'settings-styles'!
filterCssClass:  aSymbol
	"CSS class of filter row"
	^self settingsAt: #filterCssClass put: aSymbol! !


!WebGrid methodsFor: 'settings-row' stamp: ' 21/4/07 22:07'!
filterRow: anArrayOfBooleanOrNumbers
	"OBSOLETE!!"
	"row with filter input fields, put true or field width on a column to add filter"
	self columnFilters: anArrayOfBooleanOrNumbers! !

!WebGrid methodsFor: 'settings-row'!
filteredCollection: aCollection
	"for external access to filtered rows only"
	filtered := aCollection! !

!WebGrid methodsFor: 'settings-row'!
noPageNumbers
	"pagination enabled but without page links, just number of rows is shown"
	^self settingsAt: #noPageNumbers put: true! !

!WebGrid methodsFor: 'settings-row' stamp: ' 21/4/07 22:07'!
rowBlueIfTrue: aBlock
	^self settingsAt: #rowBlueBlock put: aBlock! !

!WebGrid methodsFor: 'settings-row' stamp: ' 21/4/07 22:07'!
rowBoldIfTrue: aBlock
	^self settingsAt: #rowBoldBlock put: aBlock! !

!WebGrid methodsFor: 'settings-row' stamp: ' 21/4/07 22:07'!
rowGrayIfTrue: aBlock
	^self settingsAt: #rowGrayBlock put: aBlock! !

!WebGrid methodsFor: 'settings-row' stamp: ' 21/4/07 22:07'!
rowGreenIfTrue: aBlock
	^self settingsAt: #rowGreenBlock put: aBlock! !

!WebGrid methodsFor: 'settings-row'!
rowOrangeIfTrue: aBlock
	^self settingsAt: #rowOrangeBlock put: aBlock! !

!WebGrid methodsFor: 'settings-row' stamp: ' 21/4/07 22:07'!
rowRedIfTrue: aBlock
	^self settingsAt: #rowRedBlock put: aBlock! !

!WebGrid methodsFor: 'settings-row'!
rowUpdateWhenChanged
	"set a dependency so when an object change, its row is updated"
	^self 
		settingsAt: #rowUpdateWhenChanged 
		put: true! !

!WebGrid methodsFor: 'settings-row'!
rowUpdateWhenChangedEnabled
	"is enabled a dependency to when an object change, its row is updated"
	^self 
		settingsAt: #rowUpdateWhenChanged 
		ifAbsent: [false]! !

!WebGrid methodsFor: 'settings-row' stamp: ' 21/4/07 22:07'!
rowYellowIfTrue: aBlock
	^self settingsAt: #rowYellowBlock put: aBlock! !

!WebGrid methodsFor: 'settings-row'!
rowsOnPage: anInteger
	"enables pagination of a table"
	^self settingsAt: #rowsOnPage put: anInteger! !

!WebGrid methodsFor: 'settings-row' stamp: ' 21/4/07 22:07'!
summaryRow: anArrayOfSymbolsOrStrings
	"if you want a summary row, define for desired column: #sum, #count or 'some text' "
	| inx |
	inx := 1.
	anArrayOfSymbolsOrStrings do: [:each |
		self columns size < inx ifTrue: [self addNewColumn].
		(self columns at: inx) summaryType:  each.
		inx := inx + 1]! !


!WebGrid methodsFor: 'private-testing' stamp: ' 21/4/07 22:07'!
hasFilters
	"any column has a filter"
	^self columns contains: [:each | each filter notNil].! !

!WebGrid methodsFor: 'private-testing' stamp: ' 21/4/07 22:07'!
hasNoZeros
	"don't show zeros"
	^self settingsAt: #noZeros ifAbsent: [false]! !

!WebGrid methodsFor: 'private-testing' stamp: ' 21/4/07 22:07'!
hasPages
	^self rowsOnPage notNil and: [self collection size > self rowsOnPage].! !

!WebGrid methodsFor: 'private-testing' stamp: ' 21/4/07 22:07'!
hasShortDates
	"year in two digits only"
	^self settingsAt: #shortDates ifAbsent: [false]! !

!WebGrid methodsFor: 'private-testing' stamp: ' 21/4/07 22:07'!
needsSummary
	"summary row needed or not"
	^self columns contains: [:each | each needsSummary].! !


!WebGrid methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initColumns
	columns := OrderedCollection new! !

!WebGrid methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initFiltered
	filtered isNil 
		ifTrue: [filtered := OrderedCollection new]
		ifFalse: [filtered removeAll]! !

!WebGrid methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initSettings
	settings := Dictionary new.! !


!WebGrid methodsFor: 'private-row blocks'!
rowBlueBlock
	^self settingsAt: #rowBlueBlock! !

!WebGrid methodsFor: 'private-row blocks'!
rowBoldBlock
	^self settingsAt: #rowBoldBlock! !

!WebGrid methodsFor: 'private-row blocks'!
rowGrayBlock
	^self settingsAt: #rowGrayBlock! !

!WebGrid methodsFor: 'private-row blocks'!
rowGreenBlock
	^self settingsAt: #rowGreenBlock! !

!WebGrid methodsFor: 'private-row blocks'!
rowOrangeBlock
	^self settingsAt: #rowOrangeBlock! !

!WebGrid methodsFor: 'private-row blocks'!
rowRedBlock
	^self settingsAt: #rowRedBlock! !

!WebGrid methodsFor: 'private-row blocks'!
rowYellowBlock
	^self settingsAt: #rowYellowBlock! !


!WebGrid methodsFor: 'private-sort'!
sortColumnsIfNessesary
	"sort also addBlocks"
	| column sortBlock | 
	 self sortColumn isNil ifTrue: [^nil].
	column := self columns at: self sortColumn.
	(column aspect isNil and: [column addBlock isNil]) ifTrue: [^nil].
	sortBlock := (self sortOrder = #ascending)
		ifTrue: [ [:a :b || valuea valueb | 
			column aspect ifNotNil: 
				[valuea := a perform: column aspect].
			column addBlock ifNotNil: 
				[valuea := (column addBlock value: a) asString].
			column aspect ifNotNil: 
				[valueb := b perform: column aspect].
			column addBlock ifNotNil: 
				[valueb := (column addBlock value: b) asString].
			valuea ifNil: [valuea := self sortLeastValueFor: valueb].
			valueb ifNil: [valueb := self sortLeastValueFor: valuea].
			valuea < valueb ] ]
		ifFalse: [ [:a :b || valuea valueb| 
			column aspect ifNotNil: 
				[valuea := a perform: column aspect].
			column addBlock ifNotNil: 
				[valuea := (column addBlock value: a) asString].
			column aspect ifNotNil: 
				[valueb := b perform: column aspect].
			column addBlock ifNotNil: 
				[valueb := (column addBlock value: b) asString].
			valuea ifNil: [valuea := self sortLeastValueFor: valueb].
			valueb ifNil: [valueb := self sortLeastValueFor: valuea].
			valuea > valueb ] ].
	self collection: (SortedCollection withAll: self collection sortBlock: sortBlock).! !

!WebGrid methodsFor: 'private-sort'!
sortLeastValueFor: aValue
	aValue ifNil: [^0].  "nil cannot be compared with > < "
	(aValue isKindOf: String) ifTrue: [^''].
	(aValue isKindOf: Date) ifTrue: [^Date newDay: 1 monthNumber: 1 year: 0].
	(aValue isKindOf: Number) ifTrue: [^0].! !

!WebGrid methodsFor: 'private-sort'!
sortLinkColumn: aWebGridColumn
	| app linkTarget dummyLink |
	"Cannot sort a numbered column"
	aWebGridColumn isNumbered ifTrue: [^WebText text: aWebGridColumn name].
	app := self app.
	linkTarget := app isStandaloneApp 
		ifTrue: [app class] 
		ifFalse: [app observee].
	dummyLink := WebLink text: aWebGridColumn name linkTo: (Array with: linkTarget with: '-').
	app inDefaultView 
		ifFalse: [dummyLink view: app view].
	dummyLink 
		onClickUpdate: self 
		with: 'sort-', aWebGridColumn id printString.
	^dummyLink! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebGrid class
	instanceVariableNames: ''!

!WebGrid class methodsFor: 'instance creation'!
new
	^super new
		creationMethod: #ajaxUpdateWith:  "this method will be called after ajax update";
		initialize "to build"! !


Object subclass: #WebGridColumn
	instanceVariableNames: 'parent id name width align aspect linkAspect linkView viewBlock addBlock sorted filter filterWidth filterValue summaryType summary'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebGridColumn commentStamp: '<historical>' prior: 0!
WebGrid is a powerfull widget to show tabular data, with filters, sorting, paginations and many more.

!


!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
addBlock
	^addBlock! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
align
	^align! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
aspect
	^aspect! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
filter
	^filter! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
filter: aString
	"show only rows with value starting with aString"
	filter := aString.
	self parent page: 1 "always to the first page after filter change!!"! !

!WebGridColumn methodsFor: 'private-accessing'!
filterValue
	"value of last filter entry, to detect entry changes"
	filterValue ifNil: [^''].
	^filterValue! !

!WebGridColumn methodsFor: 'private-accessing'!
filterValue: aString
	"value of last filter entry, to detect entry changes"
	filterValue := aString! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
id
	^id! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
linkAspect
	^linkAspect! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
linkView
	^linkView! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
name
	^name! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
parent
	^parent! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
sorted
	^sorted! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
sorted: aSymbol
	"nil #ascending #descending"
	sorted := aSymbol! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
summary
	"here summary of all rows is acumulated, depending on summaryType"
	^summary! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
summary: aNumber
	"see comment in method #summary"
	summary := aNumber! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
summaryValue
	"for adding to a table"
	self summary isNil ifTrue: [^''].
	(self summary isKindOf: Number) ifTrue: [^self summary printDotString].
	^self summary "as text"! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
viewBlock
	viewBlock isNil ifTrue: [self viewBlock: self defaultViewBlock].
	^viewBlock! !

!WebGridColumn methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
width
	^width! !


!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
addBlock: aBlock
	"result must be kind of WebElement which will be added to table cell"
	"block needs a row object as an argument"
	addBlock := aBlock! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
align: aSymbol
	align := aSymbol! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
aspect: aSymbol
	"a method to be called for this column on objects of current row in a collection"
	aspect := aSymbol! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
filterWidth
	"filter input field width"
	^filterWidth! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
filterWidth: aNumber
	"filter input field width"
	filterWidth := aNumber! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
id: aSymbolOrNumber
	"by default it is a position (1st, 2nd etc.)"
	id := aSymbolOrNumber! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
linkAspect: aSymbol
	"if set, a link to aspect of  row object will be made"
	linkAspect := aSymbol.! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
linkView: aSymbol
	"if set, a link to aspect of  row object (spesified with linkAspect:) with that view will be shown"
	linkView := aSymbol.! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
name: aString
	"header name for that column"
	name := aString! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
setFilter
	"this column will have a filter input field in a row below header"
	self filter: ''! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
sort
	self parent sortColumn == self id
		ifTrue: [self toggleSortOrder]
		ifFalse: [self sortAscending]! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
sortAscending
	self parent sortAscendingOn: self id! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
sortDescending
	self parent sortDescendingOn: self id! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
summaryType
	"summary row is added with appropriate value, which can be:
	- #sum : sum of all cels in that column
	- #count : number of all rows, without heading and summary
	- 'some text' to be shown in this summary cell"
	^summaryType! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
summaryType: aSymbolOrString
	"see comment in method #summary"
	summaryType := aSymbolOrString.
	(aSymbolOrString = #count) | (aSymbolOrString = #sum)
		ifTrue: [self summary: 0]
		ifFalse: [self summary: aSymbolOrString].! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
toggleSortOrder
	self parent sortColumn == self id
		ifTrue: [self parent sortOrder == #descending
			ifTrue: [self sortAscending]
			ifFalse: [self sortDescending]]
		ifFalse: [self sortAscending]! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
viewBlock: aBlock
	"how to show this column from collection. There is a default"
	"block needs a row object as an argument"
	viewBlock := aBlock! !

!WebGridColumn methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
width: aNumber
	width := aNumber! !


!WebGridColumn methodsFor: 'private' stamp: ' 21/4/07 22:07'!
addToSummary: anObject
	self summaryType = #count ifTrue: [^self summary: self summary + 1].
	self summaryType = #sum ifTrue:
		[^self summary: self summary + (anObject perform: self aspect)]! !

!WebGridColumn methodsFor: 'private' stamp: 'np 10/17/2008 17:40'!
aidaDeepCopyNotIn: aDict 
	^ nil! !

!WebGridColumn methodsFor: 'private' stamp: 'janko 8/8/2011 20:28'!
autoConvert: anObject
	(anObject class == Date and: [self parent hasShortDates]) 
		ifTrue: [^anObject shorterPrintSloString].
	(anObject class == SpDate) "Sport portable date"
		ifTrue: [^anObject shorterPrintSloString].
	(anObject class == SpTimestamp) "Sport portable timestamp"
		ifTrue: [^anObject printString].
	(anObject = 0 and: [self parent hasNoZeros]) ifTrue: [^''].
	^WebFormElement autoConvertToString: anObject! !

!WebGridColumn methodsFor: 'private'!
defaultViewBlock
	^[:object || value |
		self aspect isNil 
			ifTrue: [value := '']
			ifFalse: 
				[value := object perform: self aspect.
				value ifNil: [value := ''] ].
		self autoConvert: value]! !

!WebGridColumn methodsFor: 'private' stamp: ' 21/4/07 22:07'!
parent: anObject
	parent := anObject! !

!WebGridColumn methodsFor: 'private' stamp: ' 21/4/07 22:07'!
printString
	^'aWebGridColumn id: ', self id printString! !

!WebGridColumn methodsFor: 'private' stamp: ' 21/4/07 22:07'!
representBinaryOn: writer
	^0! !

!WebGridColumn methodsFor: 'private' stamp: ' 21/4/07 22:07'!
resetSummary
	(self summary notNil and: [self summary isKindOf: Number]) 
		ifTrue: [self summary: 0].! !


!WebGridColumn methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
hasAddBlock
	^self addBlock notNil! !

!WebGridColumn methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
hasLink
	^self linkAspect notNil | self linkView notNil! !

!WebGridColumn methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isCheckboxed
	self parent checkboxes isNil ifTrue: [^false].
	^self parent checkboxes = self id! !

!WebGridColumn methodsFor: 'testing'!
isFilterEntered
	"filter criteria is entered"
	^self filter notNil and: [self filter trimBlanks notEmpty].! !

!WebGridColumn methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isNumbered
	self parent numbering isNil ifTrue: [^false].
	^self parent numbering = self id! !

!WebGridColumn methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isSortedAscending
	^(self parent sortColumn = self id) and: [self parent sortOrder = #ascending]! !

!WebGridColumn methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isSortedDescending
	^(self parent sortColumn = self id) and: [self parent sortOrder = #descending]! !

!WebGridColumn methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
needsSummary
	"summary row is needed"
	^self summaryType notNil! !

!WebGridColumn methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
needsSummaryCount
	^self summaryType notNil and: [self summaryType = #count]! !

!WebGridColumn methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
needsSummarySum
	^self summaryType notNil and: [self summaryType = #sum]! !

!WebGridColumn methodsFor: 'testing'!
shouldAddColumnSpace
	"should add a small column after tihs one if next collumz is too close to this one (because of alignment)"
	| next |
	self align ifNil: [^false].
	self == self parent columns last ifTrue: [^false].
	next :=  self parent columns at: (self parent columns indexOf: self)+1.
	^self align = #right and: [next align ~= #right]! !


!WebGridColumn methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebGridColumn class
	instanceVariableNames: ''!

!WebGridColumn class methodsFor: 'instance creation'!
newOn: aWebGrid
	^super new 
		initialize 
		parent: aWebGrid! !


WebFormElement subclass: #WebInPlaceEditable2Text
	instanceVariableNames: 'size attribute formated allow triggerElement'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebInPlaceEditable2Text commentStamp: 'janko 8/25/2012 14:27' prior: 0!
WebInPlaceEditableText for editing text directly on the page, simply with a click on the text. 

Based on jQuery UI Editable (currently in development, downloaded jul12) http://wiki.jqueryui.com/w/page/12137959/Editable


See WebDemoApp>>jQueryInPlaceEditorExample for an example.
!


!WebInPlaceEditable2Text methodsFor: 'private-streaming'!
addSetupScript
	"jQuery specific"
self scriptBefore: '
$(function() {
	var $log = $( "#log" );
	function log( text ) {
		$log.append( text + "<br/>" );
	}
	$( "#', self id asString, '" )
		.bind( "editsave", function( ev, ui ) {
			log( "save: " + ui.value );
		})
		.bind( "editchange", function( ev, ui ) {
			log( "change: " + ui.value );
		})
		.bind( "editcancel", function() {
			log( "cancel" );
	})
	.editable();
}); 
'! !

!WebInPlaceEditable2Text methodsFor: 'private-streaming'!
prepareClassAttribute
	self class: #( #'ui-editable' #'ui-widget')! !

!WebInPlaceEditable2Text methodsFor: 'private-streaming'!
properlyFormatedValueOn: aSession
	| vlue |
	vlue := self value.
	vlue isNil ifTrue: [^''].
	self isFormated ifTrue: [vlue := vlue asWikiHtml].
	^AIDASite convertToWeb: "UTF8 encoding"
		(WebFormElement autoConvertAndEncodeQuotes: vlue) on: aSession! !

!WebInPlaceEditable2Text methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	self ensureId. 
	self prepareClassAttribute.
	self prepareToHtmlStreamingOn: aSession.
	self allow ifTrue: [self addSetupScript].
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	aStream nextPutAll: self startAttributeTag.
	aStream nextPutAll: '<span '. self streamAttributesTo: aStream for: aSession. aStream nextPut: $>. 
	aStream nextPutAll: (self properlyFormatedValueOn: aSession).
	aStream nextPutAll: '</span>', self endAttributeTag.
	(self allow and: [self triggerElement isKindOf: WebElement])
		ifTrue: [self triggerElement streamHtmlTo: aStream for: aRequest on: aSession].
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !


!WebInPlaceEditable2Text methodsFor: 'accessing'!
allow
	"is edit allowed at all?"
	allow isNil ifTrue: [^true].
	^allow! !

!WebInPlaceEditable2Text methodsFor: 'accessing'!
bold
	self attribute: '<b>'! !

!WebInPlaceEditable2Text methodsFor: 'accessing'!
size: aNumberOrPoint
	"if number, then editor is one line, if point, it is text area!!"
	size := aNumberOrPoint! !

!WebInPlaceEditable2Text methodsFor: 'accessing'!
triggerElement
	"element which triggers edit mode. If it is real element and not only id, it will be 
       added after editable text, "
	^triggerElement! !

!WebInPlaceEditable2Text methodsFor: 'accessing'!
triggerElement: aWebElementOrId
	triggerElement := aWebElementOrId! !

!WebInPlaceEditable2Text methodsFor: 'accessing'!
wikiFormated
	"source text is formated in wiki format"
	formated := true! !


!WebInPlaceEditable2Text methodsFor: 'private'!
allow: aBoolean
	allow := aBoolean! !

!WebInPlaceEditable2Text methodsFor: 'private'!
attribute
	"<b> etc"
	attribute isNil ifTrue: [^''].
	^attribute! !

!WebInPlaceEditable2Text methodsFor: 'private'!
attribute: aString
	attribute := aString! !

!WebInPlaceEditable2Text methodsFor: 'private'!
endAttributeTag
	self attribute isEmpty ifTrue: [^''].
	^'</', self attribute copyFrom: 3 to: 5! !

!WebInPlaceEditable2Text methodsFor: 'private'!
externalControl
	"Scriptaculous specific"
	| idSymbol |
	self triggerElement isNil ifTrue: [^''].
	idSymbol := self triggerElement isSymbol 
		ifTrue: [self triggerElement] ifFalse: [self triggerElement ensureId. self triggerElement id].
	^', externalControl:''', idSymbol asString, ''''! !

!WebInPlaceEditable2Text methodsFor: 'private'!
isFormated
	^formated notNil and: [formated]! !

!WebInPlaceEditable2Text methodsFor: 'private'!
rowsCols
	^'rows:', self rows printString, ',cols:', self columns printString! !

!WebInPlaceEditable2Text methodsFor: 'private'!
size
	"if number, then editor is one line, if point, it is text area!!"
	^size! !

!WebInPlaceEditable2Text methodsFor: 'private'!
startAttributeTag
	^self attribute! !

!WebInPlaceEditable2Text methodsFor: 'private'!
textOptions
	"Scriptaculous specific"
	| text |
	text := ', okText:''', self okText, ''', cancelText:''', self cancelText, ''', savingText:''', self savingText, ''''.
	^AIDASite convertToWeb: text on: self app session! !


!WebInPlaceEditable2Text methodsFor: 'settings'!
cancelText
	^'Preklic^i'  convertToSloveneChars! !

!WebInPlaceEditable2Text methodsFor: 'settings'!
columns
	"length of edit field or textarea"
	self size isNil ifTrue: [^20].
	self size class == Point ifTrue: [^self size x].
	^self size! !

!WebInPlaceEditable2Text methodsFor: 'settings'!
okText
	^'Zapis^i'  convertToSloveneChars! !

!WebInPlaceEditable2Text methodsFor: 'settings'!
rows
	"number of lines in edit area"
	self size isNil ifTrue: [^1].
	self size class == Point ifTrue: [^self size y].
	^1! !

!WebInPlaceEditable2Text methodsFor: 'settings'!
savingText
	^'...'! !


!WebInPlaceEditable2Text methodsFor: 'initialize-release'!
initialize
	"jQuery specific"
	super initialize.
	JQueryLibrary ensureUI "in page header"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebInPlaceEditable2Text class
	instanceVariableNames: ''!

!WebInPlaceEditable2Text class methodsFor: 'instance creation'!
aspect: aSymbol for: anObject
	^self new aspect: aSymbol for: anObject! !

!WebInPlaceEditable2Text class methodsFor: 'instance creation'!
aspect: aSymbol for: anObject size: aNumberOrPoint
	^self new aspect: aSymbol for: anObject; size: aNumberOrPoint! !

!WebInPlaceEditable2Text class methodsFor: 'instance creation'!
aspect: aSymbol for: anObject size: aNumberOrPoint allow: aBoolean
	^self new aspect: aSymbol for: anObject; 
		size: aNumberOrPoint;
		allow: aBoolean	"is edit allowed at all?"! !


WebFormElement subclass: #WebInPlaceEditableText
	instanceVariableNames: 'size attribute formated allow triggerElement'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebInPlaceEditableText commentStamp: '<historical>' prior: 0!
WebInPlaceEditableText for editing text directly on the page, simply with a click on the text. See WebDemoApp>>ajaxInPlaceEditorExample for an example.!


!WebInPlaceEditableText methodsFor: 'private'!
addSetupScript
	"Scriptaculous specific"
	| url urlFormated |
	url := self ajaxCallUrl, '?', (self ajaxCallUrlParametersFor: self context: self context), '&ajaxInPlaceEditing'.
	urlFormated := self isFormated ifTrue: [url, '&wikiFormated'] ifFalse: [url].
	self scriptAfter: 'new Ajax.InPlaceEditor(''', self id asString, 
		''', ''', urlFormated, ''', {', self rowsCols, self textOptions, self externalControl, 
		(self isFormated ifTrue: [',loadTextURL:''', url, ''''] ifFalse: ['']), '})'! !

!WebInPlaceEditableText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
allow: aBoolean
	allow := aBoolean! !

!WebInPlaceEditableText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
attribute
	"<b> etc"
	attribute isNil ifTrue: [^''].
	^attribute! !

!WebInPlaceEditableText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
attribute: aString
	attribute := aString! !

!WebInPlaceEditableText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
endAttributeTag
	self attribute isEmpty ifTrue: [^''].
	^'</', self attribute copyFrom: 3 to: 5! !

!WebInPlaceEditableText methodsFor: 'private'!
externalControl
	"Scriptaculous specific"
	| idSymbol |
	self triggerElement isNil ifTrue: [^''].
	idSymbol := self triggerElement isSymbol 
		ifTrue: [self triggerElement] ifFalse: [self triggerElement ensureId. self triggerElement id].
	^', externalControl:''', idSymbol asString, ''''! !

!WebInPlaceEditableText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
isFormated
	^formated notNil and: [formated]! !

!WebInPlaceEditableText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
rowsCols
	^'rows:', self rows printString, ',cols:', self columns printString! !

!WebInPlaceEditableText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
size
	"if number, then editor is one line, if point, it is text area!!"
	^size! !

!WebInPlaceEditableText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
startAttributeTag
	^self attribute! !

!WebInPlaceEditableText methodsFor: 'private'!
textOptions
	"Scriptaculous specific"
	| text |
	text := ', okText:''', self okText, ''', cancelText:''', self cancelText, ''', savingText:''', self savingText, ''''.
	^AIDASite convertToWeb: text on: self app session! !


!WebInPlaceEditableText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allow
	"is edit allowed at all?"
	allow isNil ifTrue: [^true].
	^allow! !

!WebInPlaceEditableText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
bold
	self attribute: '<b>'! !

!WebInPlaceEditableText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
size: aNumberOrPoint
	"if number, then editor is one line, if point, it is text area!!"
	size := aNumberOrPoint! !

!WebInPlaceEditableText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
triggerElement
	"element which triggers edit mode. If it is real element and not only id, it will be 
       added after editable text, "
	^triggerElement! !

!WebInPlaceEditableText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
triggerElement: aWebElementOrId
	triggerElement := aWebElementOrId! !

!WebInPlaceEditableText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
wikiFormated
	"source text is formated in wiki format"
	formated := true! !


!WebInPlaceEditableText methodsFor: 'settings' stamp: 'mivsek 1/10/2008 22:37'!
cancelText
	| app |
	app := self app.
	^app notNil 
		ifTrue: [self app style inPlaceCancelText]
		ifFalse: ['Cancel']! !

!WebInPlaceEditableText methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
columns
	"length of edit field or textarea"
	self size isNil ifTrue: [^20].
	self size class == Point ifTrue: [^self size x].
	^self size! !

!WebInPlaceEditableText methodsFor: 'settings' stamp: 'mivsek 1/10/2008 22:37'!
okText
	| app |
	app := self app.
	^app notNil 
		ifTrue: [self app style inPlaceOkText]
		ifFalse: ['Ok']! !

!WebInPlaceEditableText methodsFor: 'settings' stamp: ' 21/4/07 22:07'!
rows
	"number of lines in edit area"
	self size isNil ifTrue: [^1].
	self size class == Point ifTrue: [^self size y].
	^1! !

!WebInPlaceEditableText methodsFor: 'settings' stamp: 'mivsek 1/10/2008 22:37'!
savingText
	^'...'! !


!WebInPlaceEditableText methodsFor: 'initialize-release'!
initialize
	"Scriptaculous specific"
	super initialize.
	ScriptaculousLibrary ensureScriptaculous.! !


!WebInPlaceEditableText methodsFor: 'private-streaming'!
properlyFormatedValueOn: aSession
	| vlue |
	vlue := self value.
	vlue isNil ifTrue: [^''].
	self isFormated ifTrue: [vlue := vlue asWikiHtml].
	^AIDASite convertToWeb: "UTF8 encoding"
		(WebFormElement autoConvertAndEncodeQuotes: vlue) on: aSession! !

!WebInPlaceEditableText methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	self ensureId. 
	self prepareToHtmlStreamingOn: aSession.
	self allow ifTrue: [self addSetupScript].
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	aStream nextPutAll: self startAttributeTag.
	aStream nextPutAll: '<span '. self streamAttributesTo: aStream for: aSession. aStream nextPut: $>. 
	aStream nextPutAll: (self properlyFormatedValueOn: aSession).
	aStream nextPutAll: '</span>', self endAttributeTag.
	(self allow and: [self triggerElement isKindOf: WebElement])
		ifTrue: [self triggerElement streamHtmlTo: aStream for: aRequest on: aSession].
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebInPlaceEditableText class
	instanceVariableNames: ''!

!WebInPlaceEditableText class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject
	^self new aspect: aSymbol for: anObject! !

!WebInPlaceEditableText class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject size: aNumberOrPoint
	^self new aspect: aSymbol for: anObject; size: aNumberOrPoint! !

!WebInPlaceEditableText class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject size: aNumberOrPoint allow: aBoolean
	^self new aspect: aSymbol for: anObject; 
		size: aNumberOrPoint;
		allow: aBoolean	"is edit allowed at all?"! !


WebMethodResource subclass: #WebLivePDFCreator
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebLivePDFCreator commentStamp: '<historical>' prior: 0!
WebLivePDFCreator created PDF from HTML source together with Table of contents!! It uses external HTMLDOC converter (http://www.htmldoc.org/)
!


!WebLivePDFCreator methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
aidaDontCache
	"refresh content always!! "
	^true! !

!WebLivePDFCreator methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
expiresTimestamp
	^nil! !


!WebLivePDFCreator methodsFor: 'converting' stamp: 'np 10/18/2008 13:15'!
convertToPdf: aHtmlString
	| fname pdfname stream |
	fname := (AIDASite random new next * 1000) truncated printString, '.html'.
	pdfname := (AIDASite random new next * 1000) truncated printString, '.pdf'.
	[stream := (SpFilename named: fname) writeStream. stream nextPutAll: aHtmlString] 
		ensure: [stream close].
	OSProcess exec: 'htmldoc --batch htmldoc.book --outfile ', pdfname, ' ', fname.
	(SpFilename named: fname) delete.
	[stream := (SpFilename named: pdfname) readStream binary. ^stream contents] 
		ensure: [stream close. (SpFilename named: pdfname) delete].! !


!WebLivePDFCreator methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	| html pdf |
	html := AIDASite convert: (self object perform: self method) toCodepage: #'iso-8859-2'.
	pdf := self convertToPdf: html.
	aStream nextPutAll:  pdf asByteString.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebLivePDFCreator class
	instanceVariableNames: ''!

!WebLivePDFCreator class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
fromHtmlMethod: aMethodSymbol on: anObject site: anAIDASite
	"this method should return a complete html page!! "
	| docname |
	docname := (anObject class canUnderstand: #preferedUrlName) 
		ifTrue: [anObject preferedUrlName] ifFalse: ['live'].
	^self fromMethod: aMethodSymbol on: anObject 
		contentType: 'application/pdf' preferedUrl: '/generated/', docname, '.pdf' site: anAIDASite! !


WebWidget subclass: #WebNonHTMLResource
	instanceVariableNames: 'content contentType filename'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebNonHTMLResource commentStamp: '<historical>' prior: 0!
NonHTMLResource for returning information in other formats like PDF, plain text etc.

Usage: in your view method for returning PDF as an example:

  MyApp>>viewAsPDF

	^WebNonHTMLResource forPDF: self pdf

Response will be with content type 'application/pdf', while url extension will still be .html. If you want appropriate url extension too, you need to temporary register that element in urlResolver and redirect to it.
!


!WebNonHTMLResource methodsFor: 'accessing' stamp: 'jm 7/29/2010 12:17'!
aidaContentType
	^contentType! !

!WebNonHTMLResource methodsFor: 'accessing' stamp: 'jm 7/29/2010 12:18'!
aidaContentType: anObject
	contentType := anObject ! !

!WebNonHTMLResource methodsFor: 'accessing' stamp: 'np 10/18/2008 13:30'!
content
	^content! !

!WebNonHTMLResource methodsFor: 'accessing' stamp: 'np 10/18/2008 13:31'!
content: anObject
	content := anObject! !

!WebNonHTMLResource methodsFor: 'accessing' stamp: 'np 10/18/2008 13:31'!
filename
	^filename! !

!WebNonHTMLResource methodsFor: 'accessing' stamp: 'np 10/18/2008 13:31'!
filename: anObject
	filename := anObject! !


!WebNonHTMLResource methodsFor: 'private-streaming'!
aidaPresenterFor: aRequest on: aSession 
	^self! !

!WebNonHTMLResource methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	self filename isNil
		ifTrue: [aStream nextPutAll: self content]
		ifFalse: [aStream nextPutAll: 
			(SpFilename named: self filename) 
				underlyingFilename contentsOfEntireBinaryFile asString]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebNonHTMLResource class
	instanceVariableNames: ''!

!WebNonHTMLResource class methodsFor: 'instance creation'!
forPDF: aByteArray
	^super new
		aidaContentType: 'application/pdf';
		content: aByteArray;
		initialize! !

!WebNonHTMLResource class methodsFor: 'instance creation'!
forPDFFile: aFilenameString
	^super new
		aidaContentType: 'application/pdf';
		filename: aFilenameString;
		initialize! !

!WebNonHTMLResource class methodsFor: 'instance creation'!
forText: aByteArray
	^super new
		aidaContentType: 'text/plain';
		content: aByteArray;
		initialize! !

!WebNonHTMLResource class methodsFor: 'instance creation'!
forXML: aByteArray
	^super new
		aidaContentType: 'text/xml';
		content: aByteArray;
		initialize! !


WebTextArea subclass: #WebRichEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebRichEditor commentStamp: '<historical>' prior: 0!
WebRichEditor is a JavaScript HTML WYSIWYG editor. Use it instead of text areas and you can rich edit your text!!

Usage:
	anElement addRichEditorAspect: #body for: myDocument!


!WebRichEditor methodsFor: 'setup parameters'!
buttonsFirstLine
	"which buttons are in first line of toolbar"
	^self otherAt: #buttonsFirstLine ifAbsent: [self defaultButtonsFirstLine]! !

!WebRichEditor methodsFor: 'setup parameters'!
buttonsFirstLine: aString
	"which buttons are in first line of toolbar"
	^self otherAt: #buttonsFirstLine put: aString! !

!WebRichEditor methodsFor: 'setup parameters'!
buttonsSecLine
	"which buttons are in second line of toolbar"
	^self otherAt: #buttonsSecLine ifAbsent: [self defaultButtonsSecLine]! !

!WebRichEditor methodsFor: 'setup parameters'!
buttonsSecLine: aString
	"which buttons are in second line of toolbar"
	^self otherAt: #buttonsSecLine put: aString! !

!WebRichEditor methodsFor: 'setup parameters'!
buttonsThirdLine
	"which buttons are in third line of toolbar"
	^self otherAt: #buttonsThirdLine ifAbsent: [self defaultButtonsThirdLine]! !

!WebRichEditor methodsFor: 'setup parameters'!
buttonsThirdLine: aString
	"which buttons are in third line of toolbar"
	^self otherAt: #buttonsThirdLine put: aString! !

!WebRichEditor methodsFor: 'setup parameters'!
contentStyleUrl
	"where we have a CSS for content"
	^'/rich-editor.css' "as defined in WebStyle richEditorStyleSheet"
"	^'/tinymce/jscripts/tiny_mce/themes/advanced/skins/default/content.css'" "default only" 
"	^'/tinymce/jscripts/tiny_mce/themes/advanced/skins/default/content.css, /screen.css'"! !

!WebRichEditor methodsFor: 'setup parameters'!
inlinePopups
	"popup windows shown inline?"
	^self otherAt: #inlinePopups ifAbsent: [self defaultInlinePopups]! !

!WebRichEditor methodsFor: 'setup parameters'!
plugins
	"which plugins to load"
	^self otherAt: #plugins ifAbsent: [self defaultPlugins]! !

!WebRichEditor methodsFor: 'setup parameters'!
plugins: aString
	"which plugins to load"
	^self otherAt: #plugins put: aString! !

!WebRichEditor methodsFor: 'setup parameters'!
saveCallback
	"a JS script to execute when save button pressed or whole form submited"
	^self otherAt: #saveCallback ifAbsent: [nil]! !

!WebRichEditor methodsFor: 'setup parameters'!
saveCallback: aString
	"a JS script to execute when save button pressed or whole form submited"
	^self otherAt: #saveCallback put: aString! !


!WebRichEditor methodsFor: 'setup defaults'!
defaultButtonsFirstLine
	"which buttons are in first line of toolbar"
	"see http://wiki.moxiecode.com/index.php/TinyMCE:Configuration/theme_advanced_buttons_1_n"
	^'save, , | , undo, redo, | , bold, italic, underline, strikethrough, sub, sup, | , bullist, numlist, outdent, indent, | , formatselect, fontsizeselect, | , justifyleft, justifycenter, justifyright,  justifyfull'! !

!WebRichEditor methodsFor: 'setup defaults'!
defaultButtonsSecLine
	"which buttons are in second line of toolbar"
	"see http://wiki.moxiecode.com/index.php/TinyMCE:Configuration/theme_advanced_buttons_1_n"
	^'cut, copy, pastetext, pasteword, | , search, replace, hr, | , tablecontrols, | , forecolor,backcolor, | , charmap, image,  flash, link, unlink'! !

!WebRichEditor methodsFor: 'setup defaults'!
defaultButtonsThirdLine
	"no buttons by default in third line of toolbar"
	"see http://wiki.moxiecode.com/index.php/TinyMCE:Configuration/theme_advanced_buttons_1_n"
	^''! !

!WebRichEditor methodsFor: 'setup defaults'!
defaultInlinePopups
	"popup windows shown inline?"
	^true! !

!WebRichEditor methodsFor: 'setup defaults'!
defaultPlugins
	"default plugins to load"
	^'paste, table, save, autosave, searchreplace, advimage'! !


!WebRichEditor methodsFor: 'setup'!
initScript
	"See TinyMCE docs for explanation: http://tinymce.moxiecode.com/tinymce/docs/index.html"
	"beware, only one instance of editor should run at once!! "
	"WebRichEditor basicNew richEditorInitScript"
	| language |
	language := self firstAppFromStack notNil
		ifTrue: [self firstAppFromStack site style richEditorLanguage]
		ifFalse: ['en'].
	^'
tinyMCE.init({
	mode : "specific_textareas",
	textarea_trigger : "mce_editable",
	language : "', language ,  '",
	content_css : "', self contentStyleUrl, '",
	theme : "advanced",
	plugins : "', self plugins, 
		(self inlinePopups ifTrue: [', inlinepopups'] ifFalse: ['']), '",
	theme_advanced_buttons1 : "', self buttonsFirstLine, '",
	theme_advanced_buttons2 : "', self buttonsSecLine, '",
	theme_advanced_buttons3 : "', self buttonsThirdLine, '",
	theme_advanced_toolbar_location : "top",
	theme_advanced_toolbar_align : "left",
	extended_valid_elements : "a[name|href|target|title|onclick],img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]",
	save_enablewhendirty: "true",
	paste_use_dialog : "false",
	button_tile_map : "true",
	gecko_spellcheck : "true" ', 
 	(self saveCallback notNil ifTrue: [',
		save_callback : "', self saveCallback, '" ' ] ifFalse: ['']),
'});
'! !


!WebRichEditor methodsFor: 'initialize-release'!
initialize
	super initialize.
	self 
		attributesAt: 'mce_editable'
		put: 'true'.
	self class ensureResourcesInPageHeader "JavaScript, CSS"! !


!WebRichEditor methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
"	aRequest isAjaxRequest ifTrue:
		[self scriptBefore: self class richEditorInitScript]." "otherwise it won't show in Ajax update"
	self scriptBefore: self initScript. "for every editor instance, is that good? "
	^super streamHtmlTo: aStream for: aRequest on: aSession! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebRichEditor class
	instanceVariableNames: ''!

!WebRichEditor class methodsFor: 'ensure resources'!
ensureResourcesInPageHeader
	"JavaScript, CSS"
	" For CSS see WebStyle richEditorCssResource and richEditorStyleSheet"
	"Be carefull to add the same url in initRichEditorScript at content_css !!"
	| site |
	TinyMCELibrary ensure.
	site := self firstAppFromStack site.
	site style richEditorCssResource. "just to register if not yet"! !


WebWidget subclass: #WebRichEditorWakeup
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebRichEditorWakeup commentStamp: '<historical>' prior: 0!
WebRichEditorWakeup is a component which speedup editing by loading all JS and other libraries for rich text editor in background. 

Add it to the end of your pages but only if user has editing rights.!


!WebRichEditorWakeup methodsFor: 'printing'!
build
	| iframe |
	self clear.
	self setDiv. self hide.
"	self isWakeupTimeout ifFalse: [^self]. "
	iframe := WebIFrame new src: '/admin.html?view=wakeupRichEditor'.
	self add: iframe.
	self setWakeupTimestamp.
	
"	self setDiv. self registerId.
	self session lastRequest isAjaxRequest 
		ifFalse: 
			[self hide.
			self update ] ""to call iframe below in backgrund""
		ifTrue: 
			[iframe := WebIFrame new src: '/admin.html?view=wakeupRichEditor'.
			self add: iframe.
			self setWakeupTimestamp]
"! !


!WebRichEditorWakeup methodsFor: 'timeout' stamp: 'janko 7/18/2008 17:13'!
isWakeupTimeout
	"more that one hour since last prefech?"
	"why refresh every hour?"
	| last |
	last := self session userValues at: #wakeupRichEditorTimestamp ifAbsent: [^true].
	^SpTimestamp now asSeconds - last asSeconds > 3600! !

!WebRichEditorWakeup methodsFor: 'timeout' stamp: 'janko 7/18/2008 17:11'!
setWakeupTimestamp
	"store in user's session when last wakeup was done"
	self session userValues at: #wakeupRichEditorTimestamp put: SpTimestamp now.
! !


WebList subclass: #WebTabs
	instanceVariableNames: 'selected'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebTabs commentStamp: '<historical>' prior: 0!
WebTabs are visual selection tool. selected tab is in front, others are back and have url links.
By default an instance have CSS class 'webtabs' and selected tab 'webtabselected' and 'active' "

Usage
	self addTextBold: 'Selected without link'. 
	self addLinkTo: someObject text: 'not-selected with link' view: #view.
	self selected: 1.


Instance Variables
	selected	<Integer>	which tab is selected. By default is first.
!


!WebTabs methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
defaultClass
	"default CSS class for tabs, see WebStyle cssTabs1 for more info"
	^#tabs1! !

!WebTabs methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
selected
	^selected! !

!WebTabs methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
selected: aNumber
	"whivh tab is selected, that is in front"
	selected := aNumber! !

!WebTabs methodsFor: 'accessing'!
selectedClass
	"CSS class for selected tab, auto composed!! "
	^(self attributesAt: #class), 'selected active' "like tabs1selected" "active for Bootstrap"! !

!WebTabs methodsFor: 'accessing'!
selectedClass2
	"CSS class for selected tab, Bootstrap compatible "
	^'active'! !


!WebTabs methodsFor: 'initialize-release'!
initialize
	super initialize.
	self unordered.
	self class: self defaultClass.
	self selected: 1! !


!WebTabs methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	(self selected notNil and: [self selected <= self elements size]) ifTrue:
		[(self elements at: self selected) 
			class: self selectedClass].
	super streamHtmlTo: aStream for: aRequest on: aSession.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebTabs class
	instanceVariableNames: ''!

!WebTabs class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !


WebTabs subclass: #ViewTabs
	instanceVariableNames: 'views'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!ViewTabs commentStamp: '<historical>' prior: 0!
For quick selection of App views. Just fill with view names and descriptions, all other will be automatic. Tab for curently shown will be colored as shown, other tabls will have links to self observee and appropriate view!


!ViewTabs methodsFor: 'adding tabs'!
addView: aSymbol description: aString
	(self views contains: [:each | each key == aSymbol asSymbol]) 
		ifTrue: [^nil].
	self views 
		add: (Association 
				key: aSymbol asSymbol 
				value: (Array with: aString with: #()))! !

!ViewTabs methodsFor: 'adding tabs'!
addView: aSymbol description: aString also: aSymbolArray
	"if view is in aSymbolArray, then it is also considered selected"
	(self views contains: [:each | each key == aSymbol asSymbol]) 
		ifTrue: [^nil].
	self views 
		add: (Association 
				key: aSymbol asSymbol 
				value: (Array with: aString with: aSymbolArray))! !


!ViewTabs methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initViews
	views := OrderedCollection new.! !

!ViewTabs methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	super initialize.
	self initViews.
	^self! !


!ViewTabs methodsFor: 'private'!
prepareTabsList
	| app inx view linkTarget |
	app := self app.  inx := 1. 
      view := app view. view = #'' ifTrue: [view := #main].
	linkTarget := app isStandaloneApp ifTrue: [app class] ifFalse: [app observee].
	self views do: [:each | 
		view = each key | ((each value at: 2) includes: view)
			ifTrue: 
				[self addLinkTo: linkTarget text: (each value at: 1) view: each key.
				self selected: inx]
"		 	ifTrue: [self addTextBold: (each value at: 1). self selected: inx] "
			ifFalse: [self addLinkTo: linkTarget text: (each value at: 1) view: each key].
		inx := inx + 1]! !

!ViewTabs methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareTabsList.
	^super streamHtmlTo: aStream for: aRequest on: aSession! !

!ViewTabs methodsFor: 'private' stamp: ' 21/4/07 22:07'!
views
	^views! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ViewTabs class
	instanceVariableNames: ''!

!ViewTabs class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !


WebWidget subclass: #WebValidationError
	instanceVariableNames: 'origin'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Widgets'!
!WebValidationError commentStamp: '<historical>' prior: 0!
WebValidationError shows the error message in case of verification failure of input values in form elements

Instance Variables:
	origin	<WebFormElement>	should reply to #errorText 

!


!WebValidationError methodsFor: 'printing'!
build
	| text |
	self clear.
	self class: #validationError.	"CSS"	"red background etc. See DefaultWebStyle>>css231Validation"
	(self origin isNil or: [self origin isValid]) ifFalse:
		[text := self origin errorText trimBlanks.
		text isEmpty ifTrue: [text := 'Error!!'].
		self addText: text]! !


!WebValidationError methodsFor: 'accessing' stamp: ' 3/8/10 15:32'!
origin
	
	^origin! !

!WebValidationError methodsFor: 'accessing' stamp: 'jm 8/3/2010 15:38'!
origin: aWebFormElement
	
	origin := aWebFormElement! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebValidationError class
	instanceVariableNames: ''!

!WebValidationError class methodsFor: 'instance creation'!
newFor: aFormElement
	^super new
		origin: aFormElement;
		initialize! !
