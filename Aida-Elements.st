Object subclass: #WebElement
	instanceVariableNames: 'parent elements attributes eventHandlers other'
	classVariableNames: 'Colors'
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebElement methodsFor: 'events-effects&dragdrop'!
acceptDropsTo: aCollectionOfElements
	| script |
	"Scriptaculous specific"
	self ensureId.
	ScriptaculousLibrary ensureScriptaculous.
	script := '// <!![CDATA[ 
		Sortable.create("', self id asString,'"'.
	(self isKindOf: WebList) ifFalse: [
		self setDiv.
		script := script,  'tag: "div", '].
	script := script, ',{dropOnEmpty: true,constraint: false, containment: ['.
	aCollectionOfElements do: [:each |
		each ensureId.
		script := script, each id, ','].
	script := script,']});
	// ]]>'.
	self parent scriptAfter: script! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 3/31/2008 01:39'!
beDraggable
	self beDraggableAndRevert: false! !

!WebElement methodsFor: 'events-effects&dragdrop'!
beDraggableAndRevert: aBoolean
	"Scriptaculous specific"
	self ensureId.
	ScriptaculousLibrary ensureScriptaculous.
	self scriptAfter: '// <!![CDATA[ 
	new Draggable("', self id asString,'",{revert:', aBoolean asString, '});
	// ]]> 
	'! !

!WebElement methodsFor: 'events-effects&dragdrop'!
beSortable
	"Scriptaculous specific"
	| script |
	self ensureId.
	ScriptaculousLibrary ensureScriptaculous.
	script := '// <!![CDATA[ 
		Sortable.create("', self id asString,'",{'.
	(self isKindOf: WebList) ifFalse: [
		self setDiv.
		script := script,  'tag: "div", '].
	script := script, 'dropOnEmpty: true, constraint: false});
		// ]]>'.
	self scriptAfter: script! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 3/31/2008 00:06'!
onClickDoEffect: aSymbol
	self onClickDoEffect: aSymbol for: self! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 9/24/2008 17:04'!
onClickDoEffect: aSymbol duration: aNumber
	self onClickDoEffect: aSymbol for: self duration: aNumber! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 9/24/2008 17:05'!
onClickDoEffect: aSymbol for: anElementOrId
	^self onClickDoEffect: aSymbol for: anElementOrId duration: 1.0! !

!WebElement methodsFor: 'events-effects&dragdrop'!
onClickDoEffect: aSymbol for: anElementOrId duration: aNumber
	"Scriptaculous specific"
	| idSymbol |
	ScriptaculousLibrary ensureScriptaculous.
	idSymbol := anElementOrId isSymbol 
		ifTrue: [anElementOrId] ifFalse: [anElementOrId ensureId. anElementOrId id].
	self onClick: 'new Effect.', aSymbol asString, '(''', idSymbol asString, ''', {duration:', aNumber asString,'})'.! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 9/24/2008 17:03'!
onClickDoToggleEffect: aSymbol for: anElementOrId
	^self onClickDoToggleEffect: aSymbol for: anElementOrId duration: 1.0! !

!WebElement methodsFor: 'events-effects&dragdrop'!
onClickDoToggleEffect: aSymbol for: anElementOrId duration: aNumber
	"Scriptaculous specific"
	| idSymbol |
	ScriptaculousLibrary ensureScriptaculous.
	idSymbol := anElementOrId isSymbol 
		ifTrue: [anElementOrId] ifFalse: [anElementOrId ensureId. anElementOrId id].
	self onClick: 'new Effect.toggle(''', idSymbol asString, ''', ''', aSymbol asString, ''', {duration:', aNumber asString,'})'.! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 3/31/2008 01:15'!
onMouseOutDoEffect: aSymbol
	self onMouseOutDoEffect: aSymbol for: self! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 9/24/2008 17:06'!
onMouseOutDoEffect: aSymbol duration: aNumber
	self onMouseOutDoEffect: aSymbol for: self duration: aNumber! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 9/24/2008 17:07'!
onMouseOutDoEffect: aSymbol for: anElementOrId
	^self onMouseOutDoEffect: aSymbol for: anElementOrId duration: 1.0! !

!WebElement methodsFor: 'events-effects&dragdrop'!
onMouseOutDoEffect: aSymbol for: anElementOrId duration: aNumber
	"Scriptaculous specific"
	| idSymbol |
	ScriptaculousLibrary ensureScriptaculous.
	idSymbol := anElementOrId isSymbol 
		ifTrue: [anElementOrId] ifFalse: [anElementOrId ensureId. anElementOrId id].
	self onMouseOut: 'new Effect.', aSymbol asString, '(''', idSymbol asString, ''', {duration: ', aNumber asString, '});'.! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 3/31/2008 01:15'!
onMouseOverDoEffect: aSymbol
	self onMouseOverDoEffect: aSymbol for: self! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 9/24/2008 17:07'!
onMouseOverDoEffect: aSymbol duration: aNumber
	self onMouseOverDoEffect: aSymbol for: self duration: aNumber! !

!WebElement methodsFor: 'events-effects&dragdrop' stamp: 'np 9/24/2008 17:08'!
onMouseOverDoEffect: aSymbol for: anElementOrId
	^self onMouseOverDoEffect: aSymbol for: anElementOrId duration: 1.0! !

!WebElement methodsFor: 'events-effects&dragdrop'!
onMouseOverDoEffect: aSymbol for: anElementOrId duration: aNumber
	"Scriptaculous specific"
	| idSymbol |
	ScriptaculousLibrary ensureScriptaculous.
	idSymbol := anElementOrId isSymbol 
		ifTrue: [anElementOrId] ifFalse: [anElementOrId ensureId. anElementOrId id].
	self onMouseOver: 'new Effect.', aSymbol asString, '(''', idSymbol asString, ''', {duration: ', aNumber asString,'});'.! !


!WebElement methodsFor: 'private-subelements'!
add: aWebElement
	"Include new element as one of the receiver's elements.  Answer aWebElement.
	If you nest a web page into another web page, then add only elements of it"
	"if nested web pages then add elements without header"
	self = aWebElement "endless loop prevention"
		ifTrue: [self error: 'adding itself to a WebElement, ^e missing somewhere?'].
	self checkAndInitElements.  "if not composite element, then error"
	aWebElement isWebApplication
		ifTrue: [^self error: 'Whole App added? ^e at the end of some method forgotten?'].
	(aWebElement isWebPage and: [self isWebPage])
		ifTrue: [^elements add: aWebElement elements].
	aWebElement 
		parent: self.
	elements 
		add: aWebElement.
	aWebElement isWebWidget ifTrue:
		[aWebElement form superform: self form]. "set a proper superform for a widget"
	aWebElement postAddAction. "now the element is added to the parent, it can do some more actions"
	^aWebElement! !

!WebElement methodsFor: 'private-subelements'!
allElements
	"get a collection of all subelements of elements down in a hierarcy of this element"
	| collection |
	collection := OrderedCollection new.
	self elements notNil ifTrue:
		[collection addAll: self elements.
		self elements do: [:each | collection addAll: each allElements] ].
	^collection

"
| el |
el := WebElement new.
el add: (WebLink image: nil  linkTo: nil).
el add: (WebText text: 'aaa').
el allElements.
"! !

!WebElement methodsFor: 'private-subelements'!
first
	"Answer the first element.  If the receiver is empty, provide an error 
	notification."

	self checkAndInitElements.  "if not composite element, then error"
	^elements first! !

!WebElement methodsFor: 'private-subelements'!
last
	"Answer the last element.  If the receiver is empty, create an error notification."

	self checkAndInitElements.  "if not composite element, then error"
	^elements last! !

!WebElement methodsFor: 'private-subelements'!
newSubelementTag: aTagSymbol
	"add and immediatelly return a new structural element with that tag. It remembers it, later can 
      be found with a method, like #div" "The same princliple as for tables: newTable, newCell, cell, .."
	self subelement: (WebElement new tag: aTagSymbol).
	self add: self subelement.
	^self subelement! !

!WebElement methodsFor: 'private-subelements'!
registerFormElements
	"find form elements down in element hierachy and register them in an apropriate 
       form (from page, popup window or widget)"
	self registerFormElementsTo: self form! !

!WebElement methodsFor: 'private-subelements'!
registerFormElementsTo: aWebForm
	"find form elements down in element hierachy and register them in an apropriate 
       form (from page, popup window or widget). Also setup the form hierarchy"
	| form |
	form := (self isWebForm and: [self ~= aWebForm])  "another form found, change to it as a registration target"
		ifTrue: [aWebForm addSubform: self. self] 
		ifFalse: [aWebForm].
	self isFormElement ifTrue: [form registerFormElement: self].
	self elements do: [:subelement |
		subelement registerFormElementsTo: form]! !

!WebElement methodsFor: 'private-subelements'!
releaseFully
 	"break this hierarchy of elements fully. Usually is run after #releasePartially was run to finalize cleanup"
	elements ifNotNil:
		[elements do: [:e |
			e releaseFully]].
	elements := nil.
	parent := nil.
	self basicCreationContext ifNotNil:
		[self basicCreationContext: nil]. "this finally make an element inactive"! !

!WebElement methodsFor: 'private-subelements'!
releasePartially
 	"Release as much memory as possible from the element and its subelements. Keep only elements with id
       including forms and form elements. End result is a simplied hierarchy of only those elements"
	| toKeep |
	toKeep := self elements 
		inject: OrderedCollection new
		into: [:col :each | col addAll: each releasePartially. col].
	self hasId
		ifTrue: 
			[toKeep do: [:e | e parent: self].
			elements := toKeep.
			^Array with: self]
		ifFalse: 
			[elements := nil.
			parent := nil.
			^toKeep]! !

!WebElement methodsFor: 'private-subelements'!
replace: aSubelement with: anElement
	| index |
	aSubelement == anElement  "obviously no need to replace"
		ifTrue: [^self].
	index := self elements indexOf: aSubelement.
	index > 0 ifTrue:   "found"
		[self elements
			at: index 
			put: anElement].
	anElement parent: self.
	aSubelement parent: nil.! !

!WebElement methodsFor: 'private-subelements'!
subelement
	"current subelement we are composing on. Similar as for tables"
	^self otherAt: #Subelement ifAbsent: [nil]! !

!WebElement methodsFor: 'private-subelements'!
subelement: aWebElement
	"current subelement we are composing on. Similar as for tables"
	^self otherAt: #Subelement put: aWebElement! !

!WebElement methodsFor: 'private-subelements'!
subelementTag: aTagSymbol
	"Return a current subelement if it is of that tag. Create it if not yet exist"
	"The same principle as for tables: newTable, newCell, cell, .."
	self subelement ifNil: [^self newSubelementTag: aTagSymbol].
	self subelement tag ~= aTagSymbol ifTrue: [self error: 'Current subelement is not of desired tag'].
	^self subelement! !


!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addAnchorName: aString
	^self add: (WebAnchor name: aString)! !

!WebElement methodsFor: 'adding links'!
addCloseLinkText: aString
	"a link to close that window if popup (it also closes its execution context!!)"
	^(self addNilLinkText: aString)
		onClickClose! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addLinkTo: anObject text: aString
	^self add: (WebLink text: aString  linkTo: anObject)! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addLinkTo: anObject text: aString attributes: anArray
	^self add: (WebLink text: aString  attributes: anArray linkTo: anObject)! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addLinkTo: anObject text: aString parameter: aParmString value: aValueString
	^self add: (WebLink text: aString  linkTo: anObject 
		parameter: aParmString value: aValueString)! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addLinkTo: anObject text: aString 
	parameter: a1ParmString value: a1ValueString
	parameter: a2ParmString value: a2ValueString

	^self add: (WebLink text: aString  linkTo: anObject 
		parameter: a1ParmString value: a1ValueString
		parameter: a2ParmString value: a2ValueString)! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addLinkTo: anObject text: aString view: aViewString
	^self add: ((WebLink text: aString  linkTo: anObject)
		view: aViewString; yourself)! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addLinkTo: anObject text: aString view: aViewString  parameter: aParmString value: aValueString
	^self add: ((WebLink text: aString  linkTo: anObject)
		view: aViewString;
		parameter: aParmString value: aValueString; yourself)! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addLinkTo: anObject text: aString view: aViewString  
		parameter: aParm1String value: aValue1String 
		parameter: aParm2String value: aValue2String

	^self add: ((WebLink text: aString  linkTo: anObject)
		view: aViewString;
		parameter: aParm1String value: aValue1String;
		parameter: aParm2String value: aValue2String; yourself)! !

!WebElement methodsFor: 'adding links'!
addNilLinkText: aString
	"just to click on it and trigger some onClick event"
	^self add: (WebLink nilLinkText: aString)! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addPDFLinkTo: anObject
	^self add: ((WebLink linkTo: anObject) addGif: #pdfBigGif)! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addSecureLinkTo: anObject text: aString
	^self add: ((WebLink text: aString  linkTo: anObject) security: #grayed)! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addSecureLinkTo: anObject 
	text: aString parameter: aParmString value: aValueString

	^self add: ((WebLink text: aString  linkTo: anObject 
		parameter: aParmString value: aValueString) security: #grayed)! !

!WebElement methodsFor: 'adding links' stamp: ' 21/8/07 09:38'!
addSecureLinkTo: anObject text: aString view: aViewString
	^self add: ((WebLink text: aString  linkTo: anObject 
		view: aViewString) security: #grayed)! !


!WebElement methodsFor: 'adding form elements'!
addAspect: aSymbol for: anObject input: aBoolean size: aSizeNumberOrPoint
	"adds an auto converted text of aspect for that object. If imput argument is true, then add 
	an input field or text area, depending in size (eg. size: 5 or size: 5@5)"
	aBoolean
		ifFalse: 
			[^self addText: (WebFormElement autoConvertToString: (anObject perform: aSymbol))]
		ifTrue:
			[(aSizeNumberOrPoint isKindOf: Number) 	ifTrue: 
				[^self add: (WebInputField new
							size: aSizeNumberOrPoint;
							aspect: aSymbol for: anObject)].
			(aSizeNumberOrPoint isKindOf: Point) ifTrue: 
				[^self add: (WebTextArea new
							size: aSizeNumberOrPoint;
							aspect: aSymbol for: anObject)] 
			].! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addCheckboxAspect: aSymbol for: anObject
	"aspect method will be called and true/false will be set/clear on an object"
	^self add: (WebCheckBox aspect:  aSymbol for: anObject)! !

!WebElement methodsFor: 'adding form elements'!
addCheckboxObject: anObject from: aCollection
	"if checked, this object will be put in collection. If object is initially in collection, 
	checkbox will be checked. Usefull for easy selection among many objects"
	^self add: (WebCheckBox newForObject: anObject from: aCollection)! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addInputFieldAspect: aSymbol for: anObject
	^self add: (WebInputField new aspect:  aSymbol for: anObject)! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addInputFieldAspect: aSymbol for: anObject size: aNumber
	^self add: ((WebInputField new aspect:  aSymbol for: anObject) size: aNumber)! !

!WebElement methodsFor: 'adding form elements'!
addLabelFor: anElementOrId text: aString
	"<label> tag  defines a label for related input element"
	^self add: 
		(WebLabel newFor: anElementOrId text: aString)! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addMenuAspect: aSymbol collection: aCollection selected: aSelectedCollection
	"Multiple selection menu.. Aspect of every element in aColection will be shown in menu. 
	Selection will be put in aSelectedCollection. Here also an initial selection can be set"
	^self add: (WebMenu aspect: aSymbol collection: aCollection selected: aSelectedCollection)! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addMenuAspect: aSymbol collection: aCollection selectedToAspect: aSymbol2 of: anObject
	"Single selection menu.. Aspect of every element in aColection will be shown in menu. 
	Single selection will be put in an seelcted aspect of object. Here also initial selection can be set"
	^self add: 
		(WebMenu aspect: aSymbol collection: aCollection selectedToAspect: aSymbol2 of: anObject)! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addMenuCollection: aCollection selected: aSelectedCollection
	"Multiple selection menu..Every element (text!!) in aColection will be shown in menu. 
	Selection will be put 	in aSelectedCollection. Here also an initial selection can be set"
	^self add: (WebMenu collection: aCollection selected: aSelectedCollection)! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addMenuCollection: aCollection selectedToAspect: aSymbol2 of: anObject
	"Single selection menu. Every element (text!!) in aColection will be shown in menu. 
	Single selection will be put in an seelcted aspect of object. Here also initial selection can be set"
	^self add: (WebMenu collection: aCollection selectedToAspect: aSymbol2 of: anObject)! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addPasswordFieldAspect: aSymbol for: anObject
	^self add: (WebInputField new type: #password; aspect:  aSymbol for: anObject)! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addPasswordFieldAspect: aSymbol for: anObject size: aNumber
	^self add: ((WebInputField new type: #password; aspect:  aSymbol for: anObject) size: aNumber)! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addTextAreaAspect: aSymbol for: anObject
	^self add: (WebTextArea new aspect:  aSymbol for: anObject)! !

!WebElement methodsFor: 'adding form elements' stamp: ' 21/4/07 22:07'!
addTextAreaAspect: aSymbol for: anObject size: aPoint
	^self add: ((WebTextArea new aspect:  aSymbol for: anObject) size: aPoint)! !


!WebElement methodsFor: 'adding other elements' stamp: ' 21/8/07 09:38'!
addBreak
	^self add: (WebSeparator break).! !

!WebElement methodsFor: 'adding other elements' stamp: ' 21/8/07 09:38'!
addComment: aString
	^self add: (WebComment text: aString).! !

!WebElement methodsFor: 'adding other elements' stamp: ' 21/8/07 09:38'!
addErrorReport
	^self add: self app errorReport! !

!WebElement methodsFor: 'adding other elements' stamp: ' 21/8/07 09:38'!
addNbSp
	^self addText: '&nbsp;'.! !

!WebElement methodsFor: 'adding other elements' stamp: ' 21/8/07 09:38'!
addNbSp: aNumber
	aNumber timesRepeat: [self addNbSp].! !

!WebElement methodsFor: 'adding other elements'!
addPageBreak
	"for printing to printer, to break into a new page!!"
	self add: (WebElement newDiv class: #pageBreak).

"	^self addBreak
		class: #printOnly;
		style: 'page-break-after: always';
		yourself."! !

!WebElement methodsFor: 'adding other elements' stamp: ' 21/8/07 09:38'!
addParagraph
	^self add: (WebSeparator paragraph).! !

!WebElement methodsFor: 'adding other elements'!
addRuler
	^self addRulerSize: 1! !

!WebElement methodsFor: 'adding other elements' stamp: ' 21/8/07 09:38'!
addRulerSize: aNumber
	^self add: (WebSeparator rulerSize: aNumber).! !


!WebElement methodsFor: 'adding form buttons'!
addButtonGif: anImageSymbol
	"add a button as an image"
	^self add: (WebButton image: (WebImage gif: anImageSymbol))! !

!WebElement methodsFor: 'adding form buttons'!
addButtonGif: anImageSymbol action: aSymbol
	"add a button as an image"
	^self add: (WebButton image: (WebImage gif: anImageSymbol) action: aSymbol)! !

!WebElement methodsFor: 'adding form buttons'!
addButtonJpeg: anImageSymbol
	"add a button as an image"
	^self add: (WebButton image: (WebImage jpeg: anImageSymbol))! !

!WebElement methodsFor: 'adding form buttons'!
addButtonJpeg: anImageSymbol action: aSymbol
	"add a button as an image"
	^self add: (WebButton image: (WebImage jpeg: anImageSymbol) action: aSymbol)! !

!WebElement methodsFor: 'adding form buttons'!
addButtonPng: anImageSymbol
	"add a button as an image"
	^self add: (WebButton image: (WebImage jpeg: anImageSymbol))! !

!WebElement methodsFor: 'adding form buttons'!
addButtonPng: anImageSymbol action: aSymbol
	"add a button as an image"
	^self add: (WebButton image: (WebImage png: anImageSymbol) action: aSymbol)! !

!WebElement methodsFor: 'adding form buttons'!
addButtonText: aString
	^self add: (WebButton text: aString)! !

!WebElement methodsFor: 'adding form buttons'!
addButtonText: aString action: aSymbol
	"for more than one buttons. Action method is a composed name from 'action', aView, Symbol.
	example: for view #main, action #addFolder is action method #actionMainAddFolder"
	^self add: (WebButton text: aString action: aSymbol)! !


!WebElement methodsFor: 'adding ajax components' stamp: ' 21/8/07 09:38'!
addDateInputFieldAspect: aSymbol for: anObject
	"with popup calendar"
	^self add: (WebDateInputField new aspect:  aSymbol for: anObject)! !

!WebElement methodsFor: 'adding ajax components' stamp: ' 21/4/07 22:07'!
addDelayedFieldAspect: aSymbol for: anObject
	"for Ajax instant posting, posting is done with a delay. Usefull for live-search fields"
	^self add: (WebDelayedField new aspect:  aSymbol for: anObject)! !

!WebElement methodsFor: 'adding ajax components' stamp: ' 21/4/07 22:07'!
addDelayedFieldAspect: aSymbol for: anObject size: aNumber
	"for Ajax instant posting, posting is done with a delay. Usefull for live-search fields"
	^self add: ((WebDelayedField new aspect:  aSymbol for: anObject) size: aNumber)! !

!WebElement methodsFor: 'adding ajax components' stamp: ' 21/8/07 09:38'!
addInPlaceEditableTextAspect: aSymbol for: anObject
	^self add: (WebInPlaceEditableText aspect:  aSymbol for: anObject)! !

!WebElement methodsFor: 'adding ajax components' stamp: ' 21/8/07 09:38'!
addInPlaceEditableTextAspect: aSymbol for: anObject size: aNumberOrPoint
	^self add: (WebInPlaceEditableText aspect:  aSymbol for: anObject size: aNumberOrPoint)! !

!WebElement methodsFor: 'adding ajax components' stamp: ' 21/8/07 09:38'!
addInPlaceEditableTextAspect: aSymbol for: anObject size: aNumberOrPoint allow: aBoolean
	^self add: 
		(WebInPlaceEditableText aspect:  aSymbol for: anObject size: aNumberOrPoint allow: aBoolean)! !

!WebElement methodsFor: 'adding ajax components' stamp: ' 21/8/07 09:38'!
addRichEditorAspect: aSymbol for: anObject
	"JavaScript HTML WYSIWYG editor instead of textarea"
	^self add: (WebRichEditor new aspect:  aSymbol for: anObject)! !

!WebElement methodsFor: 'adding ajax components' stamp: ' 21/8/07 09:38'!
addRichEditorAspect: aSymbol for: anObject size: aPoint
	"JavaScript HTML WYSIWYG editor instead of textarea"
	^self add: ((WebRichEditor new aspect:  aSymbol for: anObject) size: aPoint)! !


!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addGif: aSymbol
	"this method will be called in your webStyle and this method 
	should return a gif in byte array format"
	^self add: (WebImage gif: aSymbol)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addGif: aSymbol size: aPoint
	"this method will be called in your webStyle and this method 
	should return a gif in byte array format"
	^self add: (WebImage gif: aSymbol size: aPoint)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addImage: anImageOrURL
	^self add: (WebImage image: anImageOrURL)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addImage: anImageOrURL imageMap: aWebImageMap
	^self add: 
		((WebImage image: anImageOrURL)
			imageMap: aWebImageMap)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addImage: anImageOrURL size: aPoint
	^self add: (WebImage image: anImageOrURL size: aPoint)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addImage: anImageOrURL size: aPoint align: aSymbol
	^self add: ((WebImage image: anImageOrURL size: aPoint) align: aSymbol)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addImage: anImageOrURL size: aPoint valign: aSymbol
	^self add: ((WebImage image: anImageOrURL size: aPoint) valign: aSymbol)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addJpeg: aSymbol
	"this method will be called in your webStyle and this method 
	should return a gif in byte array format"
	^self add: (WebImage jpeg: aSymbol)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addJpeg: aSymbol size: aPoint
	"this method will be called in your webStyle and this method 
	should return a gif in byte array format"
	^self add: (WebImage jpeg: aSymbol size: aPoint)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addLiveImage: aWebLiveImage
	^self add: 
		((WebImage image: aWebLiveImage)
			size: (aWebLiveImage width)@(aWebLiveImage height))! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addLiveImage: aWebLiveImage imageMap: aWebImageMap
	^self add: 
		((WebImage image: aWebLiveImage)
			size: (aWebLiveImage width)@(aWebLiveImage height);
			imageMap: aWebImageMap)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addMethodImage: aWebMethodImage
	^self add: 
		(WebImage image: aWebMethodImage)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addMethodImage: aWebMethodImage size: aPoint
	^self add: 
		((WebImage image: aWebMethodImage) size: aPoint)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addPng: aSymbol
	"this method will be called in your webStyle and this method 
	should return a png in byte array format"
	^self add: (WebImage png: aSymbol)! !

!WebElement methodsFor: 'adding images' stamp: ' 21/8/07 09:38'!
addPng: aSymbol size: aPoint
	"this method will be called in your webStyle and this method 
	should return a png in byte array format"
	^self add: (WebImage png: aSymbol size: aPoint)! !


!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject gif: aGifSymbol title: aString
	^self add: 
		((WebLink linkTo: anObject) 
			title: aString; 
			addGif: aGifSymbol; 
			yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject gif: aGifSymbol title: aString size: aPoint
	^self add: 
		((WebLink linkTo: anObject) 
			title: aString; 
			addGif: aGifSymbol 
			size: aPoint; 
			yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject gif: aGifSymbol title: aString view: aViewSymbol
	^self add: 
		(((WebLink linkTo: anObject) 
			title: aString; 
			view: aViewSymbol) 
		addGif: aGifSymbol; 
		yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject gif: aGifSymbol title: aString view: aViewSymbol
	 parameter: aParmString value: aValueString
	^self add: 
		(((WebLink linkTo: anObject) 
			title: aString; 
			view: aViewSymbol;
			parameter: aParmString value: aValueString) 
		addGif: aGifSymbol; 
		yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject image: anImageOrURL
	^self add: 
		((WebLink linkTo: anObject) 
			addImage: anImageOrURL; 
			yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject image: anImageOrURL parameter: aParmString value: aValueString
	^self add: 
		(((WebLink linkTo: anObject)
			parameter: aParmString value: aValueString) 
		addImage: anImageOrURL; 
		yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject image: anImageOrURL size: aPoint
	^self add: 
		((WebLink linkTo: anObject) 
			addImage: anImageOrURL 
			size: aPoint; 
			yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject image: anImageOrURL view: aViewSymbol
	^self add: 
		(((WebLink linkTo: anObject) 
			view: aViewSymbol) 
		addImage: anImageOrURL; 
		yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject jpeg: aSymbol title: aString
	^self add: 
		((WebLink linkTo: anObject) 
			title: aString; 
			addJpeg: aSymbol; 
			yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject jpeg: aSymbol title: aString view: aViewSymbol
	^self add: 
		(((WebLink linkTo: anObject) 
			title: aString; 
			view: aViewSymbol) 
		addJpeg: aSymbol; 
		yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject png: aPngSymbol title: aString
	^self add: 
		((WebLink linkTo: anObject) 
			title: aString; 
			addPng: aPngSymbol; 
			yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject png: aPngSymbol title: aString view: aViewSymbol
	^self add: 
		(((WebLink linkTo: anObject) 
			title: aString; 
			view: aViewSymbol) 
		addPng: aPngSymbol; 
		yourself)! !

!WebElement methodsFor: 'adding links (image)'!
addLinkTo: anObject png: aPngSymbol title: aString view: aViewSymbol
	 parameter: aParmString value: aValueString
	^self add: 
		(((WebLink linkTo: anObject) 
			title: aString; 
			view: aViewSymbol;
			parameter: aParmString value: aValueString) 
		addPng: aPngSymbol; 
		yourself)! !


!WebElement methodsFor: 'adding text' stamp: 'janko 7/30/2008 15:15'!
addRedStar
	"red * for mandatory fields in a form"
	^self addText: '<sup>*</sup>'! !

!WebElement methodsFor: 'adding text' stamp: ' 21/8/07 09:38'!
addSpace
	"just a simple space, nothing more"
	^self addText: ' '! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 11:50'!
addText: aStringOrAssociation "multilang"
	aStringOrAssociation isNil ifTrue: [^nil].
	^self add: (WebText text: aStringOrAssociation)! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 11:50'!
addText: aStringOrAssociation attributes:  aSymbolArray
	aStringOrAssociation isNil ifTrue: [^nil].
	^self add: ((WebText text: aStringOrAssociation) textAttributes: aSymbolArray)! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 11:51'!
addText: aStringOrAssociation header: aNumber
	aStringOrAssociation isNil ifTrue: [^nil].
	^self add: ((WebText text: aStringOrAssociation) header: aNumber)! !

!WebElement methodsFor: 'adding text' stamp: ' 21/8/07 09:38'!
addTextAspect: aSymbol for: anObject
	"depening on portlet mode (#view or #edit) return only text or make an input field"
	^self app inEditMode
		ifTrue: [self addInputFieldAspect: aSymbol for: anObject]
		ifFalse: [self addText: (anObject perform: aSymbol)]! !

!WebElement methodsFor: 'adding text' stamp: ' 21/8/07 09:38'!
addTextAspect: aSymbol for: anObject attributes: aSymbolOrArray
	"depening on portlet mode (#view or #edit) return only text or make an input field"
	^self app inEditMode
		ifTrue: [self addInputFieldAspect: aSymbol for: anObject]
		ifFalse: [self addText: (anObject perform: aSymbol) attributes: aSymbolOrArray]! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 11:46'!
addTextBig: aStringOrAssociation
	^self addText: aStringOrAssociation attributes: #big! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 12:18'!
addTextBold: aStringOrAssociation
	^self addText: aStringOrAssociation attributes: #b! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 12:19'!
addTextBoldAspect: aSymbol for: anObject
	"depening on portlet mode (#view or #edit) return only text or make an input field"
	^self addTextAspect: aSymbol for: anObject attributes: #b! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 11:47'!
addTextCode: aStringOrAssociation
	^self addText: aStringOrAssociation attributes: #code.! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 12:19'!
addTextH1: aStringOrAssociation
	^self addText: aStringOrAssociation header: 1! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 12:19'!
addTextH2: aStringOrAssociation
	^self addText: aStringOrAssociation header: 2! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 12:19'!
addTextH3: aStringOrAssociation
	^self addText: aStringOrAssociation header: 3! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 12:19'!
addTextH4: aStringOrAssociation
	^self addText: aStringOrAssociation header: 4! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 12:19'!
addTextH5: aStringOrAssociation
	^self addText: aStringOrAssociation header: 5! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 12:20'!
addTextItalic: aStringOrAssociation
	^self addText: aStringOrAssociation attributes: #i! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 11:48'!
addTextPreformated: aStringOrAssociation
	^self addText: aStringOrAssociation attributes: #pre.! !

!WebElement methodsFor: 'adding text' stamp: 'janko 9/30/2011 11:49'!
addTextSmall: aStringOrAssociation
	^self addText: aStringOrAssociation attributes: #small! !


!WebElement methodsFor: 'private-events'!
afterCloseUpdate
	"For later update, like after window close"
	^self 
		otherAt: #afterCloseUpdate 
		ifAbsent: [nil]! !

!WebElement methodsFor: 'private-events'!
afterCloseUpdate: anElement
	"For later update, like after window close"
	self 
		otherAt: #afterCloseUpdate
		put: anElement! !

!WebElement methodsFor: 'private-events'!
aidaChangeAnnouncedOf: anObject	
	"To achieve decoupling between change announcements and web element updates, the update request is put in an intermediate
	queue on the site"
	self isActive ifFalse: 
		[self site ifNotNil: [self site dependencies removeElement: self].
		^nil].
	self site
		queueUpdateOf: self
		with: anObject

"	self creationArgument isNil
		ifTrue: [self update]
		ifFalse: [self updateWith: anObject]"   "be sure that just that anObject is really expected"! !

!WebElement methodsFor: 'private-events'!
delegateToNewestAfterUpdates
	"it can happen that there is still a reference to old elements like in onClickUpdate: argument "
	| newest |
	newest := self.
	[newest isOldAfterUpdate and: [newest newAfterUpdate notNil] ]
		whileTrue: [newest := newest newAfterUpdate].
	newest isOldAfterUpdate ifTrue: [^nil]. 
	newest updateArgument: self updateArgument.
	^newest update! !

!WebElement methodsFor: 'private-events'!
elementToReplace
	"Usually we 'replace' itself, but  for popup windows we replace an empty stub element"
	^self 
		otherAt: #ElementToReplace 
		ifAbsent: [self]! !

!WebElement methodsFor: 'private-events'!
elementToReplace: aWebElement
	"For now used for popup windows, where we don't update itself but replace an empty stub element"
	^self 
		otherAt: #ElementToReplace
		put: aWebElement! !

!WebElement methodsFor: 'private-events'!
eventHandlerFor: aSymbol
	^self eventHandlers 
		at: aSymbol 
		ifAbsentPut: [WebEventHandler 
						newForEvent: aSymbol 
						on: self]! !

!WebElement methodsFor: 'private-events'!
eventHandlers
	eventHandlers ifNil: 
		[self initEventHandlers].
	^eventHandlers! !

!WebElement methodsFor: 'private-events'!
eventHandlers: aDictionary
	eventHandlers := aDictionary! !

!WebElement methodsFor: 'private-events'!
existScriptForEvent: anEventString
	| eventPattern |
	eventPattern := '*aidaEvent(''', anEventString, '*'.
	self attributes isNil ifTrue: [^false].
	self attributes associationsDo: [:attribute |
		attribute value class = OrderedCollection
			ifFalse: [(eventPattern match: attribute value) ifTrue: [^true]]
			ifTrue: [(attribute value contains: [:attr | eventPattern match: attr]) ifTrue: [^true] ] ].
	^false! !

!WebElement methodsFor: 'private-events'!
handleEvent: aWebEvent
	| handler |
	handler := self eventHandlerFor: aWebEvent event.
	handler ifNil: 
		[self error: 'handler for that event does not exist'].
	^handler 
		handleEvent: aWebEvent! !

!WebElement methodsFor: 'private-events'!
isStubForPopup
	"Was just created but waiting to be popped up to be visible?"
	"Created as argument in call in Element onClickPopup:thenUpdate: "
	"it is cleared at the start of popup in ... "
	^self
		otherAt: #StubForPopup
		ifAbsent: [false]! !

!WebElement methodsFor: 'private-events'!
isWindowPopupRequested
	"click on this element requested a popup"
	^self 
		otherAt: #WindowPopupRequested 
		ifAbsent: [false]! !

!WebElement methodsFor: 'private-events'!
newAfterUpdate
	"pointer to a new element from old one after update"
	^self 
		otherAt: #NewAfterUpdate
		ifAbsent: [nil]! !

!WebElement methodsFor: 'private-events'!
newAfterUpdate: aWebElement
	"pointer to a new element from old one after update"
	^self 
		otherAt: #NewAfterUpdate
		put: aWebElement! !

!WebElement methodsFor: 'private-events'!
resetOldAfterUpdate
	"this element was recreated, no more old"
	^self other
		removeKey: #OldAfterUpdate
		ifAbsent: [nil]! !

!WebElement methodsFor: 'private-events'!
resetShallQueue
	"in #update, shall new element be queued for sendng to browser immediatelly or later. For popups 
	it is queued after element is wrapped in popup window, see WebApplication>>handleEvent: "
	^self 
		otherAt: #ShallQueue
		put: false! !

!WebElement methodsFor: 'private-events'!
resetStubForPopup
	"Was just created but waiting to be popped up to be visible?"
	"Created as argument in call in Element onClickPopup:thenUpdate: "
	"it is cleared at the start of popup in ... "
	^self
		otherAt: #StubForPopup
		put: false! !

!WebElement methodsFor: 'private-events'!
scriptForEvent: anEventSymbol context: aWebContext
	^'aidaEvent(''', anEventSymbol asString, ''',''', 
		(self ensureId; id) asString, ''',''', 
		aWebContext id asString, ''')'! !

!WebElement methodsFor: 'private-events'!
setOldAfterUpdate
	"this element was updated into new element"
	^self 
		otherAt: #OldAfterUpdate
		put: true! !

!WebElement methodsFor: 'private-events'!
setShallQueue
	"in #update, shall new element be queued for sendng to browser immediatelly or later. For popups 
	it is queued after element is wrapped in popup window, see WebApplication>>handleEvent: "
	^self 
		otherAt: #ShallQueue
		put: true! !

!WebElement methodsFor: 'private-events'!
setStubForPopup
	"Was just created but waiting to be popped up to be visible?"
	"Created as argument in call in Element onClickPopup:thenUpdate: "
	"it is cleared at the start of popup in ... "
	^self
		otherAt: #StubForPopup
		put: true! !

!WebElement methodsFor: 'private-events'!
setWindowPopupRequested
	"click on this element requests a popup"
	^self 
		otherAt: #WindowPopupRequested
		put: true! !

!WebElement methodsFor: 'private-events'!
shallQueue
	"in #update, shall new element be queued for sending to browser immediatelly or later. For popups 
	it is queued after element is wrapped in popup window, see WebApplication>>handleEvent: "
	^self 
		otherAt: #ShallQueue 
		ifAbsent: [true]! !

!WebElement methodsFor: 'private-events'!
updateArgument
	"an argument for an element update call, if any"
	^self 
		otherAt: #UpdateArgument 
		ifAbsent: [nil]! !

!WebElement methodsFor: 'private-events'!
updateArgument: anObject
	"an argument for an element update call, if any"
	self 
		otherAt: #UpdateArgument
		put: anObject! !


!WebElement methodsFor: 'testing'!
aidaIsRespondingNeverStreamed
	^false! !

!WebElement methodsFor: 'testing' stamp: 'janko 4/25/2012 10:58'!
aidaIsRespondingStreamed
	^false! !

!WebElement methodsFor: 'testing'!
checkAndInitElements
	"lazy initialization od elements, when needed. Only for composite elements, else error"
	self isComposite 
		ifTrue:[(elements = nil) ifTrue: [elements := OrderedCollection new.       ]]
		ifFalse: [Smalltalk error: 'This is not a composite WebElement'].! !

!WebElement methodsFor: 'testing'!
hasId
	^self id notNil! !

!WebElement methodsFor: 'testing'!
isActive
	"is this element still part of some active (displayed on the browser) App view and its context?"
	self isOldAfterUpdate  "this element was updated into new element"
		ifTrue: [^false].
	self basicCreationContext 
		ifNotNil: [^self basicCreationContext isActive ].
	self parent 
		ifNil: [^false].
	^self parent isActive. "search up in the hierarchy if still exists a context not yet released"! !

!WebElement methodsFor: 'testing'!
isComposite
	"true, if this element is allowed to be composed by subelements.
	This method should be overriden by subclasess if a new element is not a 	composite."
	^true! !

!WebElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isFormElement
	^false! !

!WebElement methodsFor: 'testing'!
isOldAfterUpdate
	"this element was updated into new element"
	^self 
		otherAt: #OldAfterUpdate
		ifAbsent: [false]! !

!WebElement methodsFor: 'testing'!
isPureWidget
	"not a window or page, which are also widgets, as subclasses"
	^false! !

!WebElement methodsFor: 'testing' stamp: 'jm 8/26/2009 15:02'!
isStubElement
	^false! !

!WebElement methodsFor: 'testing'!
isUpdatable
	"this element an be Ajax updated"
	^self hasTag	 "at least div, span or similar tag"! !

!WebElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebApplication
	^false! !

!WebElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebElement
	^true! !

!WebElement methodsFor: 'testing'!
isWebForm
	^false! !

!WebElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebPage
	^false! !

!WebElement methodsFor: 'testing'!
isWebWidget
	^false! !

!WebElement methodsFor: 'testing'!
isWebWindow
	^false! !

!WebElement methodsFor: 'testing'!
isWrapped
	"basic elements (inputs, buttons, ..) must be wrapped in <span> element to become updatable"
	^self otherAt: #Wrapped ifAbsent: [false]! !


!WebElement methodsFor: 'private-streaming'!
aidaPresenterFor: aRequest on: aSession
	^self! !

!WebElement methodsFor: 'private-streaming'!
prepareAttributesToStreamOn: aSession
	"override if you like to change or otherwise prepare attribute values"
	"don't forget to call first super prepareAttributesToPrintOn: !! "
	#('title') do: [:attrName || attrValue |
		attrValue := self attributesAt: attrName.
		attrValue notNil ifTrue:
			[attrValue aidaIsAssociation 
				ifTrue: "multilang value of this attribute"
					[self attributesAt: attrName put: (self textFromMultilang: attrValue on: aSession)]
				ifFalse: [		
					(attrValue includes: $^ ) "slovene csz are converted if char ^ is after such a char"
						ifTrue: [self attributesAt: attrName put: attrValue convertToSloveneChars] ]
			]
		]! !

!WebElement methodsFor: 'private-streaming'!
prepareToHtmlStreamingOn: aSession
	"all preparations just before html rendering"
	self prepareAttributesToStreamOn: aSession.  "some pre-html preparation of values"! !

!WebElement methodsFor: 'private-streaming'!
setStreamInnerHtml
	"just inner Html is streaming (no tags and attributes). Used for Ajax and realtime updates"
	self 
		otherAt: #streamInnerHtml 
		put: true! !

!WebElement methodsFor: 'private-streaming'!
streamAttribute: aNameSymbol value: aValue to: aStream for: aSession
	"if value is true/false, then if true, just print an atribute name, otherwise ommit both"
	"multivalue attributes are supposed to be javascript only!! "
	| multiValue |
	aStream nextPut:  $ . 
	((aValue ~= false) | (aValue == true)) ifTrue: [aStream nextPutAll: aNameSymbol asString].
	(aValue isNil or: [aValue isKindOf: Boolean]) ifTrue: [^self]. "just name"
	multiValue := aValue class == OrderedCollection.    aStream nextPutAll: '="'.
	multiValue not ifTrue: [aStream 
		nextPutAll: (AIDASite convertToWeb: aValue asString on: aSession); "UTF-8 encoding"
		nextPutAll: '"'. ^self].
	aValue do: [:value | 
		aStream nextPutAll:  (AIDASite convertToWeb: value asString on: aSession). "UTF-8"
		aStream nextPutAll: '; ']. "javascript sentence separator"
	aStream nextPutAll: '"'.! !

!WebElement methodsFor: 'private-streaming'!
streamAttributesTo: aStream for: aSession
	"start and end of tag is not my responsibility!!"
	self attributes isNil ifTrue: [^self].
	self attributes keysAndValuesDo: [:name :value |
		self streamAttribute: name value: value to: aStream for: aSession]! !

!WebElement methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	"WebElement with some attributes is enclosed inside <div> tag, for tricks with CSS"
	self prepareToHtmlStreamingOn: aSession.
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	(self hasTag and: [self streamInnerHtml not]) ifTrue: 
		[aStream nextPutAll: self ident, '<', self tag asString. self streamAttributesTo: aStream for: aSession. 
		aStream nextPutAll: '>', self eol].
	elements notNil ifTrue: [elements do: [:element | 
		element notNil ifTrue: [element streamHtmlTo: aStream for: aRequest on: aSession] ] ].
	(self hasTag and: [self streamInnerHtml not]) 
		ifTrue: [aStream nextPutAll: self ident, '</', self tag asString, '>', self eol].
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !

!WebElement methodsFor: 'private-streaming'!
streamInnerHtml
	"only inner Html (no element's tag and attributes) shall be streamed?"
	^self 
		otherAt: #streamInnerHtml 
		ifAbsentPut: [false]! !

!WebElement methodsFor: 'private-streaming'!
tagClosing
	^'>'! !


!WebElement methodsFor: 'private-obsolete'!
ajaxCallUrl
	"relative url of an app observee object. This url is used for AJAX calls back to the server"
	| app linkTarget |
	app := self app.
	linkTarget := app isStandaloneApp 
		ifTrue: [app class] 
		ifFalse: [app observee isVersionedObject 
			ifTrue: [app observee currentVersion] ifFalse: [app observee] ].
	^AIDASite 
		convert: ( app site urlResolver halfUrlFor: linkTarget) 
		toCodepage: #utf8! !

!WebElement methodsFor: 'private-obsolete'!
ajaxCallUrlExtended
	"relative url of an app observee object. This url is used for AJAX calls back to the server"
	"also includes 'ajaxRequest' in query part, to distinguish ajax request from others"
	"Prototype specific"
	| viewParm versionParm |
	viewParm := 'view=', self context form view asString.
	versionParm := ''.
	(self app isStandaloneApp not and: [self app observee isVersionedObject]) ifTrue:
		[self app observee isCurrentVersion ifFalse: 
			[versionParm := 'version=', self app observee versionNumber, '&'] ].
	^self ajaxCallUrl, '?', viewParm, '&', versionParm, 'ajaxRequest'! !

!WebElement methodsFor: 'private-obsolete'!
ajaxCallUrlParametersFor: anElement context: aContext
	"ajax url must have 'ajaxRequest' parm in query part!! Deal also with versioned objects"
	"Prototype specific"
	| idSymbol viewParm versionParm contextParm |
	idSymbol := (anElement isNil
		ifTrue: [#nil] 
		ifFalse: [anElement ensureId. anElement id] ).
	viewParm := 'view=', aContext view asString.
	versionParm := ''.
	self app observee isVersionedObject ifTrue:
		[self app observee isCurrentVersion 
			ifFalse: [versionParm := 'version=', self app observee versionNumber, '&'] ].
	contextParm := WebContext contextIdName "aidaCtx", '=', aContext id printString.
	^viewParm, '&', 
		versionParm, 
		'ajaxRequest&ajaxGetElementId=', idSymbol asString,
		'&', contextParm! !

!WebElement methodsFor: 'private-obsolete'!
oldAddCloseLinkText: aString
	"OBSOLETE"
	"a link to close that window if popup (it also closes by Ajax its execution context!!)"
	| ctx link |
	ctx := self context.
	link := self addNilLinkText: aString.
	link
		onClick: 'closeLightboxLevel(', ctx level printString,')'; "from WebStyle>>js30Lightbox"
		onClickUpdate: nil from: nil with: nil optional: 'aidaCloseWindow'.  "to close context too"
	ctx afterCloseUpdate notNil ifTrue: "if set by WebElement>>onClickPopup:thenUpdate:"
		[link onClick: "update on parent context of the popup!! "
			(self scriptForUpdate: ctx afterCloseUpdate from: ctx afterCloseUpdate
				with: nil 	optional: nil
				context: (ctx isFirst not ifTrue: [ctx parent] ifFalse: [ctx]) )]! !

!WebElement methodsFor: 'private-obsolete'!
onClickUpdate: anElementToUpdate  from: anElementToRecreate with: anArgString optional: anArg2String
	"ElementToUpdate will be replaced with contents of the elementToRecreate after its creation method will be   
      called to recreate it. Except for popups both elements are actually the same"
	"First argument will be send as an argument of the method while second is optional"
	"Note that parameters will be sent at the time of building the element and not at the event!!" 
	"See WebApplication>>respondToAjaxRequest: and specially #ajaxUpdateOfOld:from: for more"
	anElementToUpdate notNil ifTrue: [anElementToUpdate ensureId]. 
	self onClick: 
		(self scriptForEvent: #click context: self context).
	(self eventHandlerFor: #click) addUpdate: anElementToUpdate with: anArgString.
"		(self scriptForUpdate: anElementToUpdate from: anElementToRecreate
			with: anArgString optional: anArg2String 
			context: self context)
"! !

!WebElement methodsFor: 'private-obsolete'!
onMouseOverSyncUpdate: anElement
	"update (and show if not yet) a specified element from server (AJAX)"
	"wait until AJAX response returns (synchronous update)"
	self onMouseOverSyncUpdate: anElement with: nil! !

!WebElement methodsFor: 'private-obsolete'!
onMouseOverSyncUpdate: anElement with: anArgString
	"update a specified element from server (AJAX) wtih calling an element method with an argument"
	"wait until AJAX response returns (synchronous update)"
	"Prototype specific"
	| id url parms  |
	anElement ensureId. id := anElement id.
	url := self ajaxCallUrl. 
	parms:= self ajaxCallUrlParametersFor: anElement context: self context.
	anArgString notNil ifTrue: [parms := parms, '&parm=', anArgString].
	self onMouseOver: 'new Ajax.Updater(''', id asString, ''', ''', url, 
		''', {method: ''post'', postBody: ''', parms, ''', evalScripts: true, asynchronous: false})'! !

!WebElement methodsFor: 'private-obsolete'!
printHTMLPageOn: aStream for: aRequest on: aSession
	"OBSOLETE!!"
	^self streamHtmlTo: aStream for: aRequest on: aSession! !

!WebElement methodsFor: 'private-obsolete'!
scriptForUpdate: anElementToUpdate from: anElementToRecreate with: anArgString optional: anArg2String  context: aContext
	"OBSOLETE"
	"ElementToUpdate will be replaced with contents of the elementToRecreate after its creation method will be   
      called to recreate it. Except for popups both elements are actually the same"
	"First argument will be send as an argument of the method while second is optional"
	"If both elements are nil, only arguments will be sent, usefull for sending commands only, like close window"
	"Note that parameters will be sent at the time of building the element and not at the event!!" 
	"See WebApplication>>respondToAjaxRequest: and specially #ajaxUpdate:from: for more"
	"Prototype specific"
	| idToUpdate url parms  |
	idToUpdate := anElementToUpdate notNil 
		ifTrue: [self check: anElementToUpdate on: aContext. anElementToUpdate id]
		ifFalse: [#nothingToUpdate].  "just send arguments, if any"
	url := self ajaxCallUrl. 
	parms:= self ajaxCallUrlParametersFor: anElementToUpdate context: aContext.
	anArgString notNil ifTrue: [parms := parms, '&parm=', anArgString].
	anArg2String notNil ifTrue: [parms := parms, '&parm2=', anArg2String].
	anElementToRecreate notNil ifTrue:
		[self check: anElementToRecreate on: aContext.
		parms := parms, '&ajaxElementToRecreateId=', anElementToRecreate id asString].
	^'new Ajax.Updater(''', idToUpdate asString, ''', ''', url, 
		''', {method: ''post'', postBody: ''', parms, ''', evalScripts: true, asynchronous: false})'! !

!WebElement methodsFor: 'private-obsolete'!
updateEverySeconds: aNumber
	"OBSOLETE, use Comet techniques instead!!"
	"periodically update itself from server (AJAX) with calling an element method with a parameter"
	self updateEverySeconds: aNumber with: nil! !

!WebElement methodsFor: 'private-obsolete'!
updateEverySeconds: aNumber with: anArgString
	"OBSOLETE, use Comet techniques instead!!"
	"periodically update itself from server (AJAX) with calling an element method with an argument"
	"Prototype specific"
	| url parms  |
	self ensureId. self id.
	url := self ajaxCallUrl. 
	parms:= self ajaxCallUrlParametersFor: self context: self context.
	anArgString notNil ifTrue: [parms := parms, '&parm=', anArgString].
	parms := parms, '&ajaxElementToRecreateId=', self id asString.
	self scriptAfter: '
		function createRequest() {
			new Ajax.Request(''', url, ''', { method: ''post'', postBody: ''', parms, ''',
				onSuccess: function(transport) {
					document.getElementById(''', self id, ''').innerHTML=transport.responseText;
				}
			});
		}
		var intervalID= window.setInterval(createRequest, ', (aNumber*1000) printString, ');'.
"
	idToUpdate := anElementToUpdate notNil 
		ifTrue: [self check: anElementToUpdate on: aContext. anElementToUpdate id]
		ifFalse: [#nothingToUpdate]. 
	url := self ajaxCallUrl. 
	parms:= self ajaxCallUrlParametersFor: anElementToUpdate context: aContext.
	anArgString notNil ifTrue: [parms := parms, '&parm=', anArgString].
	anArg2String notNil ifTrue: [parms := parms, '&parm2=', anArg2String].
	anElementToRecreate notNil ifTrue:
		[self check: anElementToRecreate on: aContext.
		parms := parms, '&ajaxElementToRecreateId=', anElementToRecreate id asString].
"


"	this original Prototype one caues memory leak!! "
"	self scriptAfter: 'new Ajax.PeriodicalUpdater(''', self id asString, ''', ''', url, 
		''', {method: ''post'', postBody: ''', parms, 
		''', evalScripts: true, frequency: ', aNumber printString, '})'
"! !


!WebElement methodsFor: 'attributes'!
align: aSymbol
	"element alignment #left #center #right"
	(#(left center right) includes: aSymbol) ifFalse: [self error: 'wrong align symbol'].
	self attributesAt: #align put: aSymbol asString! !

!WebElement methodsFor: 'attributes'!
basicId: aSymbol
	"set a unique id of that element on a page. Used in javascript, urls, style sheets"
	"duplicate ids not allowed, error is raised!!"
	| ctx |
	ctx := self context.
	self unregisterId. "unregister old id"
	self attributesAt: #id put: aSymbol asSymbol.
	(self class = WebElement and: [self hasTag not]) 
		ifTrue: [self setDiv]. "element with id must be at least div"
	ctx registerIdFor: self.! !

!WebElement methodsFor: 'attributes'!
class: aSymbolOrArray
	"one or more style classes of that element. Used for Cascaded Style Sheets"
	| clsText |
	(self class == WebElement and: [self hasTag not]) ifTrue: [self setDiv]. "ensure at least some tag"
	clsText := (aSymbolOrArray class = Array)
		ifTrue: [aSymbolOrArray
			inject: '' into: [:text :cls | cls = aSymbolOrArray first 
				ifTrue: [cls asString] ifFalse: [text, ' ', cls asString]] ] 
		ifFalse: [aSymbolOrArray asString].
	self attributesAt: #class put: clsText! !

!WebElement methodsFor: 'attributes'!
ensureId
	"ensure that this element has Id and register it in the context"
	self id ifNil: 
		[self registerId].! !

!WebElement methodsFor: 'attributes'!
id
	^self 
		attributesAt: #id! !

!WebElement methodsFor: 'attributes'!
id: aSymbol
	"Manually set a unique id of that element on a page. Used in javascript, urls, style sheets"
	"Element ids are normally automatically generated (see WebContext), but hty can be overwrited by 
      this method, Duplicate ids not allowed, error is raised!!"
"	Transcript cr; show: '** manually set element id #', aSymbol asString, ' on ', self class printString. "
	self basicId: aSymbol! !

!WebElement methodsFor: 'attributes'!
noId
	"remove Id, usually because it is automatically generated"
	self attributes isNil ifTrue: [^nil].
	^self attributes removeKey: #id ifAbsent: [nil]! !

!WebElement methodsFor: 'attributes'!
registerId
	"put into current context ids dictionary for faster search from AJAX requests"
	| ctx |
	self id 
		ifNotNil: [^self]. "is probably already registered!! "
	ctx := self firstContextFromStack.
	ctx ifNotNil:
		[ctx registerIdFor: self]! !

!WebElement methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
style: aString
	"redefine a style of that element with CSS syntax, example:
	style: '{color: blue; font-style: italic}'   "
	self attributesAt: #style put: aString! !

!WebElement methodsFor: 'attributes'!
title: aStringOrAssociation
	"title of an element. it will be shown when mouse pause over it"
	"Slovenian csz are converted if char ^ is after such a char"
	| text |
	aStringOrAssociation ifNil: [^nil].
	text := (aStringOrAssociation aidaIsAssociation not and: [aStringOrAssociation includes: $^ ]) 
		ifTrue: [aStringOrAssociation convertToSloveneChars]
		ifFalse: [aStringOrAssociation].
	self attributesAt: #title put: text! !

!WebElement methodsFor: 'attributes'!
unregisterId
	"remove id registration from currently executing context"
	| ctx |
	self id ifNil: [^nil].
	ctx := self firstContextFromStack.
	self unregisterIdFromCtx: ctx! !

!WebElement methodsFor: 'attributes'!
unregisterIdFromCtx: aWebContext
	"remove id registration from this context"
	(aWebContext isRegistered: self) 
		ifTrue: [aWebContext removeId: self id].! !

!WebElement methodsFor: 'attributes'!
unregisterIds
	"remove id registration from currently executing context 
	down the whole hierarchy of elements"
	self unregisterId.
	self elements 
		do: [:e | e unregisterIds]! !

!WebElement methodsFor: 'attributes'!
unregisterIdsFromCtx: aWebContext
	"remove id registration from specified context 
	down the whole hierarchy of elements"
	self unregisterIdFromCtx: aWebContext.
	self elements do: [:e | 
		e unregisterIdsFromCtx: aWebContext]! !


!WebElement methodsFor: 'accessing'!
allParents
	"collect only parents up in the element hierarchy. Top one is first"
	self parent ifNil: [^OrderedCollection new: 10].
	self parent isWebElement not ifTrue: [^OrderedCollection new: 10].
	^self parent allParents
		add: self parent;
		yourself! !

!WebElement methodsFor: 'accessing'!
app
	"return anApplication on which we are composing or is created a web page with that element"
	| app |
	self parent ifNil:  "element probably not added to parent element yet"
		[app := self firstAppFromStack.
		app ifNil: [^nil].
		^app].
	^self parent 
		app! !

!WebElement methodsFor: 'accessing'!
asString
	"return only text part of the element and its subelements"
	"Needed for filtering and sorting of addBlocks in WebGrids"
	| stream |
	elements isNil ifTrue: [^''].
	stream := WriteStream on: String new.
	self elements do: [:each | 
		stream nextPutAll: each asString].
	^stream contents! !

!WebElement methodsFor: 'accessing'!
context
	"return a currently executing context. Use #creationContext if you want a context 
	which created or updated that element"
	^self 
		firstContextFromStack! !

!WebElement methodsFor: 'accessing'!
creationContext
	"a context which created this element. If not set, try to find it up in the hierarchy"
	| ctx |
	ctx := self basicCreationContext.
	ctx ifNotNil: [^ctx].
	self parent ifNil: [^nil].
	^self parent
		creationContext! !

!WebElement methodsFor: 'accessing'!
form
	"form to which belongs (or it will be) this element. it can be form on a page, popup window or widget"
	| form appOrWidget |
	self parent ifNotNil: 
		[form := self parent form. form notNil ifTrue: [^form] ].
	self creationObject ifNotNil: 
		[^self creationObject isWebWidget 
			ifTrue: [self creationObject form]	
			ifFalse: [self creationContext form] ].
	appOrWidget := self firstWidgetOrAppFromStack.
	^(appOrWidget notNil and: [appOrWidget isWebWidget])
		ifTrue: [appOrWidget form]
		ifFalse: [self firstContextFromStack form]! !

!WebElement methodsFor: 'accessing'!
method
	"a method which created this element, always from some App or Widget. 
	Valid only for aWebElement, never for its subclasses!!"
	^self otherAt: #creationMethod ifAbsent: [nil]! !

!WebElement methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
parent
	^parent! !

!WebElement methodsFor: 'accessing'!
session
	"return a Session for which we are composing a web page"
	^self app session! !

!WebElement methodsFor: 'accessing'!
site
	"return an AIDASite on which we are composing this web element"
	| webApp |
	webApp := self app.
	webApp ifNotNil: 
		[^self app site].
	^self firstSiteFromStack! !

!WebElement methodsFor: 'accessing'!
style
	"return a WebStyle on which we are composing a web page"
	^self site style! !

!WebElement methodsFor: 'accessing'!
webPage
	"find a WebPage up in the hierarchy on which this element belongs"
	^(self parent notNil and: [self parent isWebElement])
		ifTrue: [self parent webPage]
		ifFalse: [nil]! !

!WebElement methodsFor: 'accessing'!
widget
	"on which widget this element is shown, if any"
	self parent isNil ifTrue: [^nil].
	^self parent widget! !


!WebElement methodsFor: 'subelements'!
article
	"Return a current HTML5 subelement if it is of that tag. Create it if not yet exist"
	^self subelementTag: #article.! !

!WebElement methodsFor: 'subelements'!
aside
	"Return a current HTML5 subelement if it is of that tag, error otherwise. Create it if not yet exist"
	^self subelementTag: #aside.! !

!WebElement methodsFor: 'subelements'!
div
	"Return a current subelement if it is div. Create it if not yet exist"
	"The same as for tables: newTable, newCell, cell, .."
	^self subelementTag: #div.! !

!WebElement methodsFor: 'subelements'!
figCaption
	"Return a current HTML5 subelement if it is of that tag, error otherwise. Create it if not yet exist"
	^self subelementTag: #figcaption.! !

!WebElement methodsFor: 'subelements'!
figure
	"Return a current HTML5 subelement if it is of that tag, error otherwise. Create it if not yet exist"
	^self subelementTag: #figure.! !

!WebElement methodsFor: 'subelements'!
footer
	"Return a current HTML5 subelement if it is of that tag, error otherwise. Create it if not yet exist"
	^self subelementTag: #footer.! !

!WebElement methodsFor: 'subelements'!
header
	"Return a current HTML5 subelement if it is of that tag, error otherwise. Create it if not yet exist"
	^self subelementTag: #header.! !

!WebElement methodsFor: 'subelements'!
list
	"Return a current list (<ul> by default) subelement if it is of that tag, error otherwise. Create it if not yet exist"
	self subelement ifNil: [^self newList].
	self subelement class == WebList ifFalse: [self error: 'Current subelement is not of desired tag'].
	^self subelement! !

!WebElement methodsFor: 'subelements'!
nav
	"Return a current HTML5 subelement if it is of that tag, error otherwise. Create it if not yet exist"
	^self subelementTag: #nav.! !

!WebElement methodsFor: 'subelements'!
newArticle
	"New HTML5 <article> structural subelement"
	^self newSubelementTag: #article! !

!WebElement methodsFor: 'subelements'!
newAside
	"New HTML5 <aside> structural subelement"
	^self newSubelementTag: #aside! !

!WebElement methodsFor: 'subelements'!
newDiv
	"add and immediatelly return a new DIV. I remembers it, later can be found with #div"
	"The same as for tables: newTable, newCell, cell, .."
	^self newSubelementTag: #div.! !

!WebElement methodsFor: 'subelements'!
newFigCaption
	"New HTML5 structural subelement"
	^self newSubelementTag: #figcaption! !

!WebElement methodsFor: 'subelements'!
newFigure
	"New HTML5 structural subelement"
	^self newSubelementTag: #figure! !

!WebElement methodsFor: 'subelements'!
newFooter
	"New HTML5 structural subelement"
	^self newSubelementTag: #footer! !

!WebElement methodsFor: 'subelements'!
newHeader
	"New HTML5 structural subelement"
	^self newSubelementTag: #header! !

!WebElement methodsFor: 'subelements'!
newList
	"add and immediatelly return a new list (<ul> by default, send #ordered for <ol>). I remember it, later can be found 
	with #list"
	"The same as for tables: newTable, table, newCell, cell, .."
	self subelement: (WebList new unordered).
	self add: self subelement.
	^self subelement! !

!WebElement methodsFor: 'subelements'!
newNav
	"New HTML5 structural subelement"
	^self newSubelementTag: #nav! !

!WebElement methodsFor: 'subelements'!
newSection
	"New HTML5 structural subelement"
	^self newSubelementTag: #section! !

!WebElement methodsFor: 'subelements'!
newSpan
	"add and immediatelly return a new span. I remembers it, later can be found with #span"
	"The same as for tables: newTable, newCell, cell, .."
	^self newSubelementTag: #span! !

!WebElement methodsFor: 'subelements'!
section
	"Return a current HTML5 subelement if it is of that tag, error otherwise. Create it if not yet exist"
	^self subelementTag: #section.! !

!WebElement methodsFor: 'subelements'!
span
	"Return a current subelement if it is span. Create it if not yet exist"
	"The same as for tables: newTable, newCell, cell, .."
	^self subelementTag: #span! !


!WebElement methodsFor: 'private-attributes' stamp: ' 21/4/07 22:07'!
attributes
	^attributes! !

!WebElement methodsFor: 'private-attributes'!
attributesAt: aSymbol
	self attributes isNil ifTrue: [^nil].
	^self attributes 
		at: aSymbol 
		ifAbsent: [nil]! !

!WebElement methodsFor: 'private-attributes'!
attributesAt: aSymbol add: aString
	"some attributes can have more than one value (like javascript for events)"
	| coll |
	self attributes isNil ifTrue: [self initAttributes].
	coll := self attributes at: aSymbol ifAbsentPut: [OrderedCollection new].
	(coll isKindOf: OrderedCollection) ifFalse:
		[coll := (self attributes at: aSymbol put: 
			(OrderedCollection new add: (self attributes at: aSymbol); yourself)) ].
	coll add: aString! !

!WebElement methodsFor: 'private-attributes'!
attributesAt: aSymbol put: aString
	self attributes isNil 
		ifTrue: [self initAttributes].
	self attributes
		at: aSymbol
		put: aString! !


!WebElement methodsFor: 'private-creation'!
basicCreationContext
	"a context which created this element."
	^self 
		otherAt: #creationContext 
		ifAbsent: nil.! !

!WebElement methodsFor: 'private-creation'!
basicCreationContext: aWebContext
	"a context which created this updatable element"
	^self 
		otherAt: #creationContext
		put: aWebContext! !

!WebElement methodsFor: 'private-creation'!
creationArgument
	"an argument with which a creation method was called, if any" 
	^self 
		otherAt: #creationArgument 
		ifAbsent: nil! !

!WebElement methodsFor: 'private-creation'!
creationArgument: anObject
	"an argument with which a creation method was called, if any" 
	^self 
		otherAt: #creationArgument 
		put: anObject! !

!WebElement methodsFor: 'private-creation'!
creationContext: aWebContext
	"a context which created this updatable element"
	^self 
		otherAt: #creationContext
		put: aWebContext! !

!WebElement methodsFor: 'private-creation'!
creationMethod
	"a method which created this element, always from some App or Widget. 
	Valid only for aWebElement, never for its subclasses!!"
	^self 
		otherAt: #creationMethod
		ifAbsent: [nil]! !

!WebElement methodsFor: 'private-creation'!
creationMethod: aSymbol
	"a method which created this element, always from some App or Widget. 
	Valid only for aWebElement, never for its subclasses!!"
	self 
		otherAt: #creationMethod
		put: aSymbol.! !

!WebElement methodsFor: 'private-creation'!
creationObject
	"a Widget or App which created this element. 
	Valid only for aWebElement, never for its subclasses!!"
	^self 
		otherAt: #creationObject
		ifAbsent: [nil]! !

!WebElement methodsFor: 'private-creation'!
creationObject: aWidgetOrApp
	"a Widget or App which created this element. 
	Valid only for aWebElement, never for its subclasses!!"
	^self 
		otherAt: #creationObject
		put: aWidgetOrApp! !

!WebElement methodsFor: 'private-creation' stamp: 'janko 10/31/2012 16:53'!
setCreationMethodAndObject
	"find a name of a method and the object (Widget, App or Style) which created me"
	"Squeak specific"
	| stContext argument |
	stContext := thisContext.
	[stContext notNil] whileTrue: [
		((stContext receiver isKindOf: WebApplication) 
			or: [(stContext receiver isKindOf: WebWidget) 
				or: [stContext receiver isKindOf: WebStyle]]) ifTrue: 
					[self creationObject: stContext receiver. "who shall receive that method when needed"
					argument := stContext basicSize > 0 ifTrue: [stContext at: 1] ifFalse: [nil]. "Squeak specific"
					argument notNil ifTrue:
						[self creationArgument: argument].
					^self creationMethod: stContext selector].
		stContext := stContext sender].! !


!WebElement methodsFor: 'private'!
canUpdate
	"only pure WebElements (not subclasses, ok, few exceptions) can Ajax/WebSocket update"
	^self class == WebElement! !

!WebElement methodsFor: 'private'!
cell: aWebTableCell
	self initTableIfNessesary.
	self 
		otherAt: #currentCell 
		put: aWebTableCell.! !

!WebElement methodsFor: 'private' stamp: ' 21/4/07 22:07'!
colorValue: aColorSymbol
	"Hex number format is: #rrbbgg if not in that format, then it can be a color name as defined in 
	class variable Colors (class method initColorDictionary). If unknown color, then attribute is set to nil"
	| attribute |
	attribute := aColorSymbol asString asLowercase asSymbol.
	attribute := WebElement colorDictionary at: attribute ifAbsent:
		[attribute asString do: [:chr | 
			(chr isDigit or: [chr asInteger between: $a asInteger and: $f asInteger]) ifFalse: [^self] ] ].
	^'#', (attribute asString copyWithout: $# )

"WebElement new colorValue: #red"! !

!WebElement methodsFor: 'private'!
elements
	elements 
		ifNil: [self initElements].
	^elements! !

!WebElement methodsFor: 'private' stamp: ' 21/4/07 22:07'!
parent: aWebElement
	parent := aWebElement! !

!WebElement methodsFor: 'private' stamp: 'janko 10/27/2011 11:42'!
postAddAction
	"additional actions after this element was added to another (parent)"
	"override in your elements if needed"! !

!WebElement methodsFor: 'private'!
prepareForTranslation
	"if element has multilingual text, make it in-line editable for translation"
	"Sublcasses should implement editing accordingly"
	self elements 
		do: [:each | each prepareForTranslation]! !

!WebElement methodsFor: 'private'!
printCreationStrings
	| text basic |
	text := ''.
	self creationObject ifNotNil: [text := text, '
	creation object: ', self creationObject class name].
	self creationMethod ifNotNil: [text := text, '
	creation method: ', self creationMethod printString].
	basic := self basicCreationContext  
		ifNotNil: ['basic '] ifNil: [''].
	self creationContext ifNotNil: [text := text, '
	', basic, 'creation context ', 
		(self creationContext isFirst ifTrue: ['first: '] ifFalse: ['popup: ']), 
		self creationContext id printString].
	^text! !

!WebElement methodsFor: 'private'!
printOtherStrings
	| text |
	text := ''.
	self isOldAfterUpdate ifTrue: [text := text, '
	oldAfterUpdate: true'].
	^text! !

!WebElement methodsFor: 'private'!
printString
	^'a', self class printString, 
		(self tag notNil ifTrue: [' ', self tag asString] ifFalse: ['']),
		(self id notNil ifTrue: [' id: ', self id] ifFalse: ['']),
		((self attributesAt: #class)  notNil ifTrue: [' class: ', (self attributesAt: #class) ] ifFalse: ['']), '
	subelements: ', self elements size printString,
	self printCreationStrings,
	self printOtherStrings! !

!WebElement methodsFor: 'private'!
resetStreamInnerHtml
	self 
		otherAt: #streamInnerHtml 
		put: false! !

!WebElement methodsFor: 'private'!
row: aWebTableRow
	self initTableIfNessesary.
	self 
		otherAt: #currentRow 
		put: aWebTableRow.! !

!WebElement methodsFor: 'private'!
scriptAfter
	^self 
		otherAt: #scriptAfter 
		ifAbsent: [nil]! !

!WebElement methodsFor: 'private'!
scriptBefore
	^self 
		otherAt: #scriptBefore 
		ifAbsent: [nil]! !

!WebElement methodsFor: 'private'!
table: aWebTable
	self 
		otherAt: #currentTable 
		put: aWebTable.! !

!WebElement methodsFor: 'private'!
tag: aSymbol
	" #div, #span, ..."
	self 
		otherAt: #tag 
		put: aSymbol! !

!WebElement methodsFor: 'private'!
wrap
	"wrap this element in <span> element to become updatable, for basic elements like buttons or input fields"
	| wrap |
	self isWrapped ifTrue: [^nil].
	self parent isNil ifTrue: [self error: 'cannot wrap yet'].
	wrap := WebElement newSpan.
	wrap parent: self parent.
	self parent elements
		remove: self;
		add: wrap.
	wrap add: self. 
	self parent: wrap.
	wrap ensureId.
	self 
		otherAt: #Wrapped 
		put: true.! !


!WebElement methodsFor: 'tables' stamp: ' 21/4/07 22:07'!
cell
	"return a current table cell"
	self initTableIfNessesary.
	^self otherAt: #currentCell! !

!WebElement methodsFor: 'tables' stamp: ' 21/4/07 22:07'!
clearTableInfo
	"clear all table information"
	self initTable! !

!WebElement methodsFor: 'tables' stamp: ' 21/4/07 22:07'!
newCell
	"add a new cell to current table row. Return a new WebTableCell so that you can send messages
	to it immediatelly - color, width, addText etc."
	self cell: WebTableCell new.
	self row add: self cell.
	^self cell! !

!WebElement methodsFor: 'tables' stamp: ' 21/4/07 22:07'!
newRow
	"add a new row to current table. Return a new WebTableRow so that you can send messages
	to it immediatelly - color, width etc. Also reset current row and current cell to a new ones. "
	self row: WebTableRow new.
	self table add: self row.
	self newCell.
	^self row! !

!WebElement methodsFor: 'tables' stamp: ' 21/4/07 22:07'!
newTable
	"add a new table to this element. Return a new WebTable so that you can send messages
	to it immediatelly - color, width etc. Also reset current row and current cell to a new ones. "
	self table: WebTable new.
	self add: self table.
	self newRow.
	^self table! !

!WebElement methodsFor: 'tables' stamp: ' 21/4/07 22:07'!
row
	"return a current table row"
	self initTableIfNessesary.
	^self otherAt: #currentRow! !

!WebElement methodsFor: 'tables' stamp: ' 21/4/07 22:07'!
table
	"return a current web table. If not yet exist, create it"
	self initTableIfNessesary.
	^self otherAt: #currentTable! !


!WebElement methodsFor: 'private-ajax'!
changeContextFrom: oldCtx to: newCtx
	"scan for all references to contexts and change them. Also in subelements"
	self changeContextInAttributesFrom: oldCtx to: newCtx.
	self elements do: [:each | each changeContextFrom: oldCtx to: newCtx]! !

!WebElement methodsFor: 'private-ajax'!
changeContextInAttribute: aString from: oldCtx to: newCtx
	| in out aidaCtx |
	aidaCtx := WebContext contextIdName.
	(('*', aidaCtx, '*') match: aString) ifFalse: [^nil].
	in := aString readStream. out := WriteStream on: String new.
	[in atEnd] whileFalse: 
		[out nextPutAll: (in upToAll: aidaCtx). 
		in atEnd not ifTrue: 
			[in next "=". in upTo: $&.               "& not always? "
			out nextPutAll: aidaCtx, '=', newCtx id printString, '&' ] ].   
	^out contents! !

!WebElement methodsFor: 'private-ajax'!
changeContextInAttributesFrom: oldCtx to: newCtx
	"scan for all references to contexts and change them"
	| attrToChange |
	self attributes isNil ifTrue: [^nil].
	attrToChange := #( #onClick #onDblClick #onKeyDown #onKeyPress #onKeyUp 
		#onMouseDown #onMouseMove #onMouseOut #onMouseOver #onMouseUp 
		#onSelect #onFocus #onChange #onSubmit #onReset).
	(self attributes associations select: [:each | attrToChange includes: each key]) do: [:assoc |
		assoc value class = OrderedCollection
			ifTrue: [self attributesAt: assoc key put: 
					(assoc value collect: [:each | self changeContextInAttribute: each from: oldCtx to: newCtx]) ]
			ifFalse: [self attributesAt: assoc key put: (self changeContextInAttribute: assoc value from: oldCtx to: newCtx)] ].! !

!WebElement methodsFor: 'private-ajax'!
check: anElementToUpdate on: aContext
	"check if element is updatable: it is first in a creation method. id is set and if in composition mode, set it.
	Raise error with good description to help better prepare Ajax updatable elements"
	anElementToUpdate isWebWidget ifTrue: [^anElementToUpdate registerId]. "to be sure"
	anElementToUpdate isStubElement ifTrue: [^true].
"	anElementToUpdate isFirstInMethod ifFalse:
		[^self error: 'Element to update must be first element in creation method!! Widget can be used instead']. "
	anElementToUpdate registerId. "if not already"! !

!WebElement methodsFor: 'private-ajax' stamp: 'janko 1/2/2012 15:57'!
checkIfFirstInMethodOn: aContext
	"is this element created as first one in this method? Set the flag if true. Needed for checking if element is
	able to Ajax update or not"
	"this method doens't work correclty yet, it declares other elements in method as first too!!!!!!"
	| stContext request |
	stContext := thisContext . "find a context of a creation metod"
	[stContext receiver isWebApplication 
		or: [stContext receiver isWebWidget 
			or: [stContext receiver isWebStyle]] ]
		whileFalse: 
			[stContext := stContext sender. stContext isNil ifTrue: [^nil]].
	request := aContext event notNil
		ifTrue: [aContext event]
		ifFalse: [self firstRequestFromStack].
	(request isNil or: [request isAjaxRequest not])
		 ifTrue: [self otherAt: #firstInMethod put: true. ^self]. "Temporary!! in case of WebSocket message there is no request"
	(request creationStContexts includes: stContext) ifFalse:
		[self otherAt: #firstInMethod put: true.
		request creationStContexts add: stContext]! !

!WebElement methodsFor: 'private-ajax'!
isFirstInMethod
	"is this element created as first one in its creation method?"
	^(self otherAt: #firstInMethod ifAbsent: [false])! !


!WebElement methodsFor: 'initialize-release'!
clear
	"remove all subelements including tables and event handlers"
	self elements do: [:each | each parent: nil].
	self initElements.
	self clearTableInfo.
	self initScripts.
"	self initEventHandlers. "! !

!WebElement methodsFor: 'initialize-release'!
clearAttributesExceptId
	self attributes ifNil: [^nil].
	self attributes keys do: [:name |
		name ~= #id ifTrue: [self attributes removeKey: name] ]! !

!WebElement methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initAttributes
	attributes := Dictionary new.! !

!WebElement methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initElements
	elements := OrderedCollection new.! !

!WebElement methodsFor: 'initialize-release'!
initEventHandlers
	eventHandlers := Dictionary new.! !

!WebElement methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initOther
	other := Dictionary new.! !

!WebElement methodsFor: 'initialize-release'!
initScripts
	self other isNil ifTrue: [^nil].
	self other removeKey: #scriptBefore ifAbsent: [].
	self other removeKey: #scriptAfter ifAbsent: [].! !

!WebElement methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initTable
	"just remove from other, later will be initalized lazily"
	self other isNil ifTrue: [^nil].
	self other 
		removeKey: #currentTable ifAbsent: [];
		removeKey: #currentRow ifAbsent: [];
		removeKey: #currentCell ifAbsent: [].! !

!WebElement methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initTableIfNessesary
	"if not already exist"
	self otherAt: #currentTable ifAbsent: [self newTable]! !

!WebElement methodsFor: 'initialize-release'!
initialize
	"override in subclasses if needed"
	"always start with super initialize!! "! !

!WebElement methodsFor: 'initialize-release'!
nilAttributes
	attributes := nil.! !


!WebElement methodsFor: 'private-identation' stamp: ' 21/4/07 22:07'!
eol
	self setNewline.
	^String with: Character cr with: Character lf.! !

!WebElement methodsFor: 'private-identation' stamp: ' 21/4/07 22:07'!
ident
	"ident this tag to its level"
	| depth eol|
	eol := ''.
	self shouldIdent & self isNewline not ifTrue: [eol := self eol]. 
	depth := (self identationLevel - self identDepth) max: 0.
	self identDepth: self identationLevel.
	^eol, (String new: depth withAll: Character tab )! !

!WebElement methodsFor: 'private-identation'!
identDepth
	"how idented we are"
	| page |
	page := self webPage.
	^page notNil ifTrue: [page identDepth] ifFalse: [0].! !

!WebElement methodsFor: 'private-identation'!
identDepth: aNumber
	"how idented we are"
	| page |
	page := self webPage.
	^page isNil ifTrue: [0] ifFalse: [page identDepth: aNumber]! !

!WebElement methodsFor: 'private-identation' stamp: ' 21/4/07 22:07'!
identMore
	"ident inside tag content to its level and one deepier"
	self isNewline ifFalse: [self eol]. 
	self identDepth: self identationLevel+1.
	^String new: self identationLevel+1 withAll: $ ! !

!WebElement methodsFor: 'private-identation'!
identationLevel	
	"How much we need to ident. Top element (web page) has level 0"
	| page |
	self isWebPage ifTrue: [^0].
	^self parent notNil
		ifTrue: 
			[page := self webPage. page isNil ifTrue: [^0].
			self shouldIdent 
				ifTrue: [page identationLevel + 1] 
				ifFalse: [page identationLevel]]
		ifFalse: [0]! !

!WebElement methodsFor: 'private-identation'!
isNewline
	"are we at start of new line?"
	| page |
	page := self webPage.
	^page notNil ifTrue: [page isNewline] ifFalse: [false]! !

!WebElement methodsFor: 'private-identation' stamp: ' 21/4/07 22:07'!
level	
	"How deep we are in element hierarchy. Top element has level 0"
	^self parent notNil
		ifTrue: [self parent level + 1]
		ifFalse: [0]! !

!WebElement methodsFor: 'private-identation'!
setNewline
	"we are no longer at start of line"
	| page |
	page := self webPage.
	page notNil ifTrue: [page setNewline].! !

!WebElement methodsFor: 'private-identation'!
shouldIdent
	"true, if this element should be idented in html page"
	^self hasTag! !


!WebElement methodsFor: 'tags'!
hasTag
	"is this element enclosed or not in any tag like <div> or <span>"
	^self tag notNil! !

!WebElement methodsFor: 'tags'!
isDiv
	^self tag = #div! !

!WebElement methodsFor: 'tags'!
isSpan
	^self tag = #span! !

!WebElement methodsFor: 'tags'!
noDiv
	"remove automatically generated DIV"
	self isDiv ifTrue: [self tag: nil]! !

!WebElement methodsFor: 'tags'!
setArticle
	"HTML5 <article> structural element"
	self tag: #article! !

!WebElement methodsFor: 'tags'!
setAside
	"HTML5 <aside> structural element"
	self tag: #aside! !

!WebElement methodsFor: 'tags'!
setDiv
	self tag: #div! !

!WebElement methodsFor: 'tags'!
setFigCaption
	"HTML5 <figcaption> figure caption structural element"
	self tag: #figcaption! !

!WebElement methodsFor: 'tags'!
setFigure
	"HTML5 <figure> structural element"
	self tag: #figure! !

!WebElement methodsFor: 'tags'!
setFooter
	"HTML5 <footer> structural element"
	self tag: #footer! !

!WebElement methodsFor: 'tags'!
setHGroup
	"HTML5 <hgroup> header group structural element"
	self tag: #hgroup! !

!WebElement methodsFor: 'tags'!
setHeader
	"HTML5 <header> structural element"
	self tag: #header! !

!WebElement methodsFor: 'tags'!
setNav
	"HTML5 <nav> structural element"
	self tag: #nav! !

!WebElement methodsFor: 'tags'!
setSection
	"HTML5 <section> structural element"
	self tag: #section! !

!WebElement methodsFor: 'tags'!
setSpan
	self tag: #span! !

!WebElement methodsFor: 'tags'!
structuralTags
	^#(
		div
		span
		article
		aside
		figure
		figcaption
		header
		footer
		hgroup
		nav
		section)! !

!WebElement methodsFor: 'tags'!
tag
	" #div, #span, ..."
	^self otherAt: #tag ifAbsent: [nil]! !


!WebElement methodsFor: 'events'!
hide
	"hide me from web page"
	self ensureId.
	self scriptAfter: 'document.getElementById(''', self id, ''').style.display=''none'' '! !

!WebElement methodsFor: 'events'!
on: anEventSymbol script: aJavascriptCode
	" on #click, #keyPress etc add a specified script"
	"possible events (not all):
	#click #dblClick 
	#keyPress #keyDown #keyUp
	#mouseUp #mouseDown #mouseMove #mouseOut #mouseOver
	"
	self 
		attributesAt: ('on', anEventSymbol asString capitalized) asSymbol 
		add: aJavascriptCode! !

!WebElement methodsFor: 'events' stamp: 'janko 11/7/2011 13:58'!
onClick: aJavascriptCode
	self on: #click script: aJavascriptCode! !

!WebElement methodsFor: 'events'!
onClickHide: anElement
	"hide specified element on mouse click on me"
	anElement ensureId.
	self onClick: 'document.getElementById(''', anElement id, ''').style.display=''none'' '.! !

!WebElement methodsFor: 'events' stamp: 'np 10/20/2008 16:40'!
onClickReload
	"reload current page on click off that element"
	self onClick: 'window.location.reload()'.! !

!WebElement methodsFor: 'events'!
onClickShow: anElement
	"show specified element on mouse click on me"
	anElement ensureId.
	self onClick: 'document.getElementById(''', anElement id, ''').style.display=''block'' '.! !

!WebElement methodsFor: 'events' stamp: 'np 10/18/2008 13:34'!
onClickStore: aStringOrBoolean toAspect: aSymbol of: anObject
	"store the value via aspect (accessor/mutator method name) to specified object"
	^self notYetImplemented! !

!WebElement methodsFor: 'events'!
onClickToggle: anElement
	"toggle visibility of specified element on mouse click on me"
	anElement ensureId.
	self onClick: 'var e = document.getElementById(''', anElement id, '''); if (e.style.display == ''none'') a = ''block''; else a = ''none''; e.style.display = a; '! !

!WebElement methodsFor: 'events' stamp: 'janko 11/7/2011 14:03'!
onKeyPress: aJavascriptCode
	self on: #keyPress script: aJavascriptCode! !

!WebElement methodsFor: 'events' stamp: 'janko 11/7/2011 14:04'!
onKeyUp: aJavascriptCode
	self on: #keyUp script: aJavascriptCode! !

!WebElement methodsFor: 'events' stamp: 'janko 11/7/2011 14:05'!
onMouseOut: aJavascriptCode
	self on: #mouseOut script: aJavascriptCode! !

!WebElement methodsFor: 'events'!
onMouseOutHide: anElement
	"hide specified element when mouse get out of me"
	anElement ensureId.
	self onMouseOut: 'document.getElementById(''', anElement id, ''').style.display=''block'' '.! !

!WebElement methodsFor: 'events'!
onMouseOutShow: anElement
	"show specified element when mouse get out of me"
	anElement ensureId.
	self onMouseOut: 'document.getElementById(''', anElement id, ''').style.display=''block'' '.! !

!WebElement methodsFor: 'events' stamp: 'janko 11/7/2011 14:06'!
onMouseOver: aJavascriptCode
	self on: #mouseOver script: aJavascriptCode! !

!WebElement methodsFor: 'events'!
onMouseOverHide: anElement
	"hide specified element when mouse come over me"
	anElement ensureId.
	self onMouseOver: 'document.getElementById(''', anElement id, ''').style.display=''none'' '.! !

!WebElement methodsFor: 'events'!
onMouseOverShow: anElement
	"show specified element when mouse come over me"
	anElement ensureId.
	self onMouseOver: 'document.getElementById(''', anElement id, ''').style.display=''block'' '.! !

!WebElement methodsFor: 'events'!
show
	"show me (if not already) on web page"
	self ensureId.
	self scriptAfter: 'document.getElementById(''', self id, ''').style.display=''block'' ' "is this good enough?"! !

!WebElement methodsFor: 'events'!
toogle
	"toogle element visibility on  web page"
	self ensureId.
	self scriptAfter: 
'var e = document.getElementById(''', self id, ''');
if (e.style.display == ''none'') a = ''block''; else a = ''none'';
e.style.display = a; ' 
"	self addText: '<script>Element.toggle(''', self id, ''')</script>'"! !


!WebElement methodsFor: 'events-updates'!
isUpdating
	"this element is currently updating itsef"

	"this becames soon slow!!"
	| stContext |
	stContext := thisContext sender.
	[stContext notNil] whileTrue: 
		[((stContext receiver isKindOf: WebElement) 
			and: [stContext selector  = #update
				and: [stContext receiver creationMethod = self creationMethod]]) "good enough?"
					ifTrue: [^true]. "call from self update"
		stContext := stContext sender].
	^false

	"BEWARE: only first level, calls from submethods are not catched!!"
"	^thisContext sender sender selector = #update "  "call from WebElement>>update"! !

!WebElement methodsFor: 'events-updates'!
onClickClose
	"close the window if popup"
	(self existScriptForEvent: 'click') ifFalse: "only one script per event!!"
		[self onClick: (self scriptForEvent: #click context: self context)].
	(self eventHandlerFor: #click) 
		addCloseWindow! !

!WebElement methodsFor: 'events-updates'!
onClickUpdate: anElement
	"update (and show if not yet) a specified element from server (Ajax)"
	self onClickUpdate: anElement with: nil! !

!WebElement methodsFor: 'events-updates'!
onClickUpdate: anElement with: anArgObject
	"Update a specified element from server (Ajax) with calling the element's creation method 
      with an argument. Creation method must be able to receive a parameter. For instance: 
      #propertiesElementShow: aBoolean "
	anElement isNil ifTrue: [self error: 'no element to update!!'].
	anElement isUpdatable ifFalse: [self error: 'element not updatable, must be at least DIV'].
	anElement ensureId. 
	(self existScriptForEvent: #click) ifFalse: "only one script per event!!"
		[self onClick: (self scriptForEvent: #click context: self context)].
	(self eventHandlerFor: #click) 
		addUpdate: anElement with: anArgObject.! !

!WebElement methodsFor: 'events-updates'!
onMouseOutUpdate: anElement
	"update (and show if not yet) a specified element from server (Ajax)"
	self onMouseOutUpdate: anElement with: nil! !

!WebElement methodsFor: 'events-updates'!
onMouseOutUpdate: anElement with: anArgObject
	"update a specified element from server wtih calling an element method with an argument"
	anElement isNil ifTrue: [self error: 'no element to update!!'].
	anElement isUpdatable ifFalse: [self error: 'element not updatable, must be at least DIV'].
	anElement ensureId. 
	(self existScriptForEvent: #mouseOut) ifFalse: "only one script per event!!"
		[self onMouseOut: (self scriptForEvent: #mouseOut context: self context)].
	(self eventHandlerFor: #mouseOut) 
		addUpdate: anElement with: anArgObject.! !

!WebElement methodsFor: 'events-updates'!
onMouseOverUpdate: anElement
	"update (and show if not yet) a specified element from server (Ajax)"
	self onMouseOverUpdate: anElement with: nil! !

!WebElement methodsFor: 'events-updates'!
onMouseOverUpdate: anElement with: anArgObject
	"update a specified element from server wtih calling an element method with an argument"
	anElement isNil ifTrue: [self error: 'no element to update!!'].
	anElement isUpdatable ifFalse: [self error: 'element not updatable, must be at least DIV'].
	anElement ensureId. 
	(self existScriptForEvent: #mouseOver) ifFalse: "only one script per event!!"
		[self onMouseOver: (self scriptForEvent: #mouseOver context: self context)].
	(self eventHandlerFor: #mouseOver) 
		addUpdate: anElement with: anArgObject.! !

!WebElement methodsFor: 'events-updates'!
update
	"recreate that element on app or widget and send to the browser to update itself there too"
	| new ctx |
	self canUpdate ifFalse: 
		[self error: 'Only WebElements (not subclasses) and subclasses of WebWidget can be updated'].
	self isActive ifFalse: 
		[self isOldAfterUpdate 
			ifTrue: [^self delegateToNewestAfterUpdates]
			ifFalse: [self error: 'element not active anymore'] ].
	self creationMethod isNil ifTrue: [^self]. "in form elements it will return new value!!"
	self id isNil ifTrue: [self error: 'web element to update must have id in advance, use #ensureId !!'].
	('view*' match: self creationMethod asString) ifTrue: 
		[^self error: 'Cannot update views!! View in question: #', self creationMethod].
	ctx := self firstContextFromStack. "currently executing context, if any. It can differ from creation one in case of popup"
	ctx ifNil: [ctx := self creationContext].
	ctx announceReplacementWith: self.
	new := (self creationMethod asString last = $: )
		ifTrue: [self creationObject perform: self creationMethod with: self updateArgument ]  
		ifFalse: [self updateArgument notNil  "try to call the method with that argument anyway"
			ifTrue: [self creationObject perform: 
						(self creationMethod, ':') asSymbol with: self updateArgument]
			ifFalse: [self creationObject perform: self creationMethod] ].
	new basicCreationContext: ctx.
	ctx cancelReplacement. "if not already"
	((new isKindOf: WebElement) and: [new canUpdate]) 
		ifFalse: [self error: 'Not an updatable web element!!'].
	new id ifNil: [self error: 'does creation method return created object?'].
	new registerFormElements.
	new prepareToHtmlStreamingOn: self session. "to prepare again"
	new afterCloseUpdate: self afterCloseUpdate. "if any, to signal for later update, after
												window close for instance"
	new parent: self parent. "preserve parent"
	new eventHandlers: self eventHandlers.  "preserve handlers through updates"
	self shallQueue ifTrue:  "for popups queuing happens later after wrap into popup window"
		[ctx first queueUpdateElement: new]. "send via WebSocket if open or in Ajax response"
	self parent 
		replace: self with: new. "in element hierarchy"
	self "cleanup the old element"
		setOldAfterUpdate;
		newAfterUpdate: new;
		unregisterIdsFromCtx: self creationContext; "will unregister also old element itself"
		releaseFully.
	ctx registerIdFor: new. "new id is the same as old one."
	^new! !

!WebElement methodsFor: 'events-updates'!
updateWhenChanged: anObject
	"when #aidaAnnounceChange is called on anObject, this element will update. 
	If not realtime, then an update will happen only if user event triggered anObject change 
    	announcement."
	self site dependencies
		depend: self
		on: anObject
		in: self creationContext! !

!WebElement methodsFor: 'events-updates'!
updateWith: anArgObject
	"recreate that element by calling creation method with one argument,
	and send to the browser to update itself there"
"	self isUpdatable ifFalse: [self error: 'Element to update must be at least DIV']. "
	anArgObject notNil 
		ifTrue: [self updateArgument: anArgObject].
	^self update! !


!WebElement methodsFor: 'events-actions'!
on: anEventSymbol do: aBlock
	"execute that block when this event occurs, like #click, #mouseOver etc."
	self ensureId.
	(self existScriptForEvent:  anEventSymbol) ifFalse: "only one script per event!!"
		[self 
			on: anEventSymbol 
			script: (self scriptForEvent: anEventSymbol context: self context)].
	(self eventHandlerFor: anEventSymbol) 
		addActionBlock: aBlock.! !

!WebElement methodsFor: 'events-actions' stamp: 'janko 11/7/2011 14:11'!
onClickDo: aBlock
	"execute that block when this link is clicked"
	self on: #click do: aBlock! !


!WebElement methodsFor: 'events-popups'!
onClickPopup: anElement
	"popup a specified element (can be also a WebWidget) with fresh content from server (AJAX) in a 
       new window on the same page"
	self 
		onClickPopup: anElement 
		thenUpdate: nil! !

!WebElement methodsFor: 'events-popups'!
onClickPopup: anElement thenUpdate: anElementToUpdate
	"popup a specified element (can be also a WebWidget) with fresh content from server (AJAX) in a 
       new window on the same page. Update anElementToUpdate after popup window is closed"
	"note: anElement is created twice: first at this method call, second at popup. Except if a WebWidget!!"
	"note: anElement is NOT added to the calling element"
	| ctx |
	self ensureId. anElement ensureId.
	ctx := self context.  "currently ecexuting context"
	anElementToUpdate ifNotNil: 
		[anElementToUpdate isUpdatable ifFalse: [self error: 'element not updatable, must be at least DIV'].
		anElementToUpdate ensureId.
		anElement afterCloseUpdate: anElementToUpdate]. "will be copied in popup window"
	(self existScriptForEvent: #click) ifFalse: "only one script per event!!"
		[self onClick: (self scriptForEvent: #click context: self context)].
	(self eventHandlerFor: #click) 
		addPopup: anElement onStub: ctx window popupStub.
	self setWindowPopupRequested.
	anElement setStubForPopup. "because for now it won't be visible yet"
	anElement parent: self. "temporary, so that methods using a parent will work, like #app etc" 
	anElement isWebWidget ifTrue: [^self]. "widgets simply won't build itself yet" 
	anElement elements 
		do: [:e | e unregisterIds].
	anElement
		releaseFully; "not needed because it is not yet popped up"
		parent: self; "preserve parent"
		basicCreationContext: ctx "preserve creation context too"! !


!WebElement methodsFor: 'private-other' stamp: ' 21/4/07 22:07'!
other
	^other! !

!WebElement methodsFor: 'private-other'!
otherAt: aSymbol
	^self 
		otherAt: aSymbol
		ifAbsent: [nil]! !

!WebElement methodsFor: 'private-other'!
otherAt: aSymbol ifAbsent: aBlock
	self other isNil 
		ifTrue: [^aBlock value].
	^self other 
		at: aSymbol
		ifAbsent: aBlock! !

!WebElement methodsFor: 'private-other'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other 
		at: aSymbol 
		ifAbsent: [self other at: aSymbol put: aBlock value]! !

!WebElement methodsFor: 'private-other'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other 
		at: aSymbol
		put: anObject! !


!WebElement methodsFor: 'scripts' stamp: ' 21/4/07 22:07'!
script: aString
	"add this JavaScript  to scripts executed after this element"
	self scriptAfter: aString! !

!WebElement methodsFor: 'scripts' stamp: ' 21/4/07 22:07'!
scriptAfter: aString
	"add this JavaScript  to scripts executed after this element"
	(self otherAt: #scriptAfter ifAbsentPut: [WebScript new]) script: aString! !

!WebElement methodsFor: 'scripts' stamp: 'mivsek 1/10/2008 22:19'!
scriptAfterExternal: anUrlOrObject
	"add this externalJavaScript  to scripts executed after this element"
	| url |
	url := anUrlOrObject isString
		ifTrue: [anUrlOrObject]
		ifFalse: [self site urlResolver halfUrlFor: anUrlOrObject].
	(self otherAt: #scriptAfter ifAbsentPut: [WebScript new]) source: url! !

!WebElement methodsFor: 'scripts' stamp: ' 21/4/07 22:07'!
scriptBefore: aString
	"add this JavaScript  to scripts executed before this element"
	(self otherAt: #scriptBefore ifAbsentPut: [WebScript new]) script: aString! !

!WebElement methodsFor: 'scripts' stamp: 'mivsek 1/10/2008 22:20'!
scriptBeforeExternal: anUrlOrObject
	"add this external JavaScript  to scripts executed before this element"
	| url |
	url := anUrlOrObject isString
		ifTrue: [anUrlOrObject]
		ifFalse: [self site urlResolver halfUrlFor: anUrlOrObject].
	(self otherAt: #scriptBefore ifAbsentPut: [WebScript new]) source: url! !


!WebElement methodsFor: 'private-translation' stamp: 'janko 9/19/2011 14:21'!
textFromMultilang: aStringOrAssociation on: aSession
	"translate the multilang text in form #fr->'Bonjour' "
	^aSession site translator 
		translate: aStringOrAssociation
		to: aSession languageBasic
		for: self
		on: aSession! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebElement class
	instanceVariableNames: ''!

!WebElement class methodsFor: 'color values' stamp: ' 21/4/07 22:07'!
colorDictionary
	"return a dictionary of color names as keys and hex values for colors in 
	some web elements such as page and table background, text, links etc."
	Colors isNil ifTrue: [self initColorDictionary].
	^Colors! !

!WebElement class methodsFor: 'color values' stamp: ' 21/4/07 22:07'!
initColorDictionary
	"WebElement initColorDictionary"
	"WebElement colorDictionary"
	Colors := IdentityDictionary new.
	Colors 
		at: #white				put: #'ffffff';
		at: #red					put: #'ff0000' ;
		at: #green				put: #'00ff00' ;
		at: #blue				put: #'0000ff' ;
		at: #magenda			put: #'ff00ff';
		at: #cyan				put: #'00ffff' ;
		at: #yellow				put: #'ffff00' ;
		at: #black				put: #'000000';

		at: #aquamarine			put: #'70db93';

		at: #bakerschocolade	put: #'5c3317';
		at: #blueviolet	put: #'9f5f9f';
		at: #brass		put: #'b5a642';
		at: #brightgold	put: #'d9d919';
		at: #brown		put: #'a62a2a';
		at: #bronze		put: #'8c7853';
		at: #bronzeii		put: #'a67d3d';

		at: #cadetblue		put: #'5f9f9f';
		at: #coolcooper		put: #'d98719';
		at: #cooper			put: #'b87333';
		at: #coral			put: #'ff7f00';
		at: #cornflowerblue	put: #'42426f';

		at: #darkbrown		put: #'5c4033';
		at: #darkgreen		put: #'2f4f2f';
		at: #darkgreencooper put: #'4a766e';
		at: #darkolivegreen	put: #'4f4f2f';
		at: #darkorchid		put: #'9932cd';
		at: #darkpurple		put: #'871f78';
		at: #darkslateblue	put: #'6b238e';
		at: #darkslategrey	put: #'2f4f4f';
		at: #darktan			put: #'97694f';
		at: #darkturquoise	put: #'7093db';
		at: #darkwood		put: #'855e42';
		at: #dimgrey		put: #'545454';
		at: #dustyrose		put: #'856363';

		at: #feldspar			put: #'d19275';
		at: #firebrick			put: #'8e2323';
		at: #forestgreen		put: #'238e23';

		at: #gold			put: #'cd7f32';
		at: #goldenrod		put: #'dbdb70';
		at: #grey			put: #'c0c0c0';
		at: #greencooper	put: #'527f76';
		at: #greenyellow		put: #'93db70';

		at: #huntergreen		put: #'215e21';

		at: #indianred		put: #'4e2f2f';

		at: #khaki		 	put: #'9f9f5f';

		at: #lightblue		put: #'c0d9d9';
		at: #lightgrey		put: #'a8a8a8';
		at: #lightsteelblue	put: #'8f8fbd';
		at: #lightwood		put: #'e9c2a6';
		at: #limegreen		put: #'32cd32';

		at: #mandarianorange	put: #'e47833';
		at: #maroon			put: #'8e236b';
		at: #mediumaquamarine	put: #'32cd99';
		at: #mediumblue	put: #'3232cd';
		at: #mediumforestgreen	put: #'6b8e23';
		at: #mediumgoldenrod	put: #'eaeaae';
		at: #mediumorchid	put: #'9370db';
		at: #mediumseagreen	put: #'426f42';
		at: #mediumslateblue	put: #'7f00ff';
		at: #mediumspringgreen	put: #'7fff00';
		at: #mediumturquoise	put: #'70dbdb';
		at: #mediumvioletred		put: #'db7093';
		at: #mediumwood	put: #'a68064';
		at: #midnightblue	put: #'2f2f4f';
		
		at: #navyblue		put: #'23238e ';
		at: #neonblue		put: #'4d4dff';
		at: #neonpink		put: #'ff6ec7';
		at: #newmidnightblue	put: #'00009c';
		at: #newtan			put: #'ebc79e ';
		
		at: #oldgold			put: #'cfb53b ';
		at: #orange			put: #'ff7f00';
		at: #orangered		put: #'ff2400';
		at: #orchid			put: #'db70db';

		at: #palegreen		put: #'8fbc8f';
		at: #pink			put: #'bc8f8f';
		at: #plum			put: #'eaadea';

		at: #quartz			put: #'d9d9f3';

		at: #richblue			put: #'5959ab';

		at: #salmon			put: #'6f4242';
		at: #scarlet			put: #'8c1717';
		at: #seagreen		put: #'238e68';
		at: #semiswetchocolate		put: #'6b4226';
		at: #sienna			put: #'8e6b23';
		at: #silver			put: #'e6e8fa';
		at: #skyblue			put: #'3299cc';
		at: #slateblue		put: #'007fff';
		at: #spicypink		put: #'ff1cae';
		at: #springgreen		put: #'00ff7f';
		at: #steelblue		put: #'236b8e';
		at: #summersky		put: #'38b0de';

		at: #tan				put: #'db9370';
		at: #thistle			put: #'d8bfd8';
		at: #turquoise		put: #'adeaea';

		at: #verydarkbrown	put: #'5c4033';
		at: #verylightgrey	put: #'cdcdcd';
		at: #violet			put: #'4f2f4f';
		at: #violetred		put: #'cc3299';

		at: #wheat			put: #'d8d8bf';
		at: #yellowgreen		put: #'99cc32'.! !

!WebElement class methodsFor: 'color values' stamp: ' 21/4/07 22:07'!
valueForColor: aColorSymbolOrString
	"return a hex value for specified color. Case of color string is not important. 
	return red if color is unknown"
	| color |
	color := aColorSymbolOrString asString asLowercase asSymbol.
	^self colorDictionary at: color ifAbsent: [^self colorDictionary at: #red].

"
WebElement valueForColor: 'blue' 
"! !


!WebElement class methodsFor: 'testing'!
isWebApplication
	"for tests in climbing on the stack"
	^false! !

!WebElement class methodsFor: 'testing'!
isWebWidget
	"for tests in climbing on the stack"
	^false! !


!WebElement class methodsFor: 'instance creation'!
new
	"be sure to call super new in subclasses!!"
	| instance ctx |
	instance := super basicNew initialize.
	(self == WebElement or: [self == WebTableRow]) ifTrue: 
		[instance setCreationMethodAndObject. "Widget or App. Method's argument also set, if any"
		ctx := instance firstContextFromStack.  "a currently executing context, if any"
		ctx ifNil: [ctx := instance creationObject creationContext].
		instance basicCreationContext: ctx.
		instance checkIfFirstInMethodOn: ctx.  "and set the #firsInMethod"
		(ctx notNil and: [ctx currentReplacement notNil]) ifTrue: 
			"replace id from old element in Ajax updating, see WebApplication>>ajaxUpdate:from:on:"
			[ctx replaceIdIn: instance with: ctx currentReplacement. 
			ctx cancelReplacement] ].
	^instance! !

!WebElement class methodsFor: 'instance creation'!
newClass: aSymbol
	"new with CSS class as specified"
	^self new 
		class: aSymbol! !

!WebElement class methodsFor: 'instance creation'!
newDiv
	"element enclosed in div tag"
	^self new 
		setDiv;
		ensureId. "let all divs have ids in advance, for potential Ajax from action blocks like 'e update' "! !

!WebElement class methodsFor: 'instance creation'!
newId: aSymbol
	"new with id as specified. Be sure that you set some tag too, otherwise this id attribute won't be shown!!"
	^self new
		setDiv;
		id: aSymbol! !

!WebElement class methodsFor: 'instance creation'!
newSpan
	"element enclosed in span tag"
	^self new 
		setSpan;
		ensureId. "let all spans have ids in advance, for potential Ajax from action blocks like 'e update' "! !


WebElement subclass: #WebAudio
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!
!WebAudio commentStamp: 'janko 8/25/2012 15:00' prior: 0!
WebAudio  for HTML5 audio tag!


!WebAudio methodsFor: 'attributes'!
autoplay
	"audio will start playing as soon as it is ready"
	self attributes at: #autoplay put: true! !

!WebAudio methodsFor: 'attributes'!
controls: aString
	"Specifies that audio controls should be displayed (such as a play/pause button etc)."
	self attributes at: #controls put: aString! !

!WebAudio methodsFor: 'attributes'!
loop
	"audio will start over again, every time it is finished"
	self attributes at: #loop put: true! !

!WebAudio methodsFor: 'attributes'!
preload: aSymbol
	"Specifies if and how the author thinks the audio should be loaded when the page loads"
	" #auto #metadata or #none "
	self attributes at: #preload put: aSymbol asString! !

!WebAudio methodsFor: 'attributes'!
src: anUrlString
	"Specifies the URL of the video file"
	" #auto #metadata or #none "
	self attributes at: #src put: anUrlString! !

!WebAudio methodsFor: 'attributes'!
text: aString
	"will be shown if browser does not support audio"
	self addText: aString! !


!WebAudio methodsFor: 'private'!
tag
	^#audio! !


WebElement subclass: #WebCanvas
	instanceVariableNames: 'text'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebCanvas methodsFor: 'attributes'!
height: anInteger
	self attributesAt: #height put: anInteger printString! !

!WebCanvas methodsFor: 'attributes'!
size: aPoint
	"set the size of a canvas in format width@height"
	self width: aPoint x.
	self height: aPoint y.! !

!WebCanvas methodsFor: 'attributes'!
width: anInteger
	self attributesAt: #width put: anInteger printString! !


!WebCanvas methodsFor: 'private'!
tag
	^#canvas! !


WebElement subclass: #WebComment
	instanceVariableNames: 'text'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebComment methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	text := ''.! !


!WebComment methodsFor: 'private' stamp: ' 21/4/07 22:07'!
shouldIdent
	^false! !

!WebComment methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	aStream nextPutAll: self ident, '<!!-- '.
	aStream nextPutAll: self text.
	aStream nextPutAll: ' -->', self eol.! !


!WebComment methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
text
	^text! !

!WebComment methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
text: aString
	text := aString.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebComment class
	instanceVariableNames: ''!

!WebComment class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !

!WebComment class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
text: aString
	^self new text: aString

"WebText text: 'test'"! !


WebElement subclass: #WebFieldSet
	instanceVariableNames: 'legend'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!
!WebFieldSet commentStamp: '<historical>' prior: 0!
FieldSet element groups one or more input fields together. It usually (depends on style) also enclose them with border. Legend is for writing a name of the filedset on the corner!


!WebFieldSet methodsFor: 'private'!
hasTag
	^super hasTag! !

!WebFieldSet methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession 
	| text |
	self prepareToHtmlStreamingOn: aSession.
	aStream nextPutAll: self ident , '<fieldset'.
	self 
		streamAttributesTo: aStream
		for: aSession.
	aStream nextPutAll: '>' , self eol.
	self legend notNil ifTrue: [
		text := self legend aidaIsAssociation "multilingual"
			ifTrue: [self textFromMultilang: self legend on: aSession]
			ifFalse: [self legend].
		aStream nextPutAll: self identMore , '<legend>' , 
		(AIDASite convertToWeb: text on: aSession) , 
		'</legend>' , self eol].
	super 
		streamHtmlTo: aStream for: aRequest on: aSession.
	aStream nextPutAll: self ident , '</fieldset>' , self eol! !


!WebFieldSet methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	"Initialize a newly created instance. This method must answer the receiver."

	" *** Replace this comment with the appropriate initialization code *** "
	^self! !


!WebFieldSet methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
legend
	^legend! !

!WebFieldSet methodsFor: 'accessing' stamp: 'janko 9/19/2011 14:23'!
legend: aStringOrAssociation "multilang assoc"
	"a label to be shown on left top corner of fieldset"
	legend := aStringOrAssociation! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebFieldSet class
	instanceVariableNames: ''!

!WebFieldSet class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	"Answer a newly created and initialized instance."
	^super new initialize! !

!WebFieldSet class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newLegend: aString
	^self new legend: aString! !


WebElement subclass: #WebForm
	instanceVariableNames: 'fields action tabOrder superform subforms'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebForm methodsFor: 'model posting'!
acceptFormInputFrom: anEventOrRequest
 	"read a post data from request or WebEvent and write values to the valueModels of fields in a form.
	For checkboxes and radiobuttons, a set of values is expected under the same name"
	| postData value |
	postData := HTTPPostDataArray new. "like Dictionary, but multiple values per key"
	self uncheckAllProperChecboxesFor: anEventOrRequest. 
	self uncheckAllProperRadioButtonsFor: anEventOrRequest.
	anEventOrRequest  postKeysAndValuesDo: [:key :vlue | postData at: key put: vlue].
	self allFieldsIncludingSubforms do: [:field | 
		(postData includesKey: field name) ifTrue:
			[value := postData at: field name.
			field isMenu 
				ifTrue: [field acceptFormInputFrom: postData]
				ifFalse: [	field isFileInputField 
					ifTrue: 
						[field isStreamed ifFalse: [field value: (postData at: field name)] "streamed already read". 
						field acceptFileAttributesFrom: anEventOrRequest field: field name]
					ifFalse: [field acceptInputFromValue: value] ] "all other form elements"
			] 
		]! !

!WebForm methodsFor: 'model posting'!
acceptInputsFrom: aRequest
	"this method read form inputs (if any) and if all values pass validation, write them to the appropriate 
	aspects of model  objects. If entire form is validated, it saves inputs to model, all at once"
	| field |
	self acceptFormInputFrom: aRequest.  "just fields which are in request, can be only a single one in Ajax!!"
	aRequest isAjaxPostWithSingleInput  "form or single field validation"
		ifTrue: 
			[field := self fieldNamed: aRequest ajaxSingleInputName. 
			field isValid ifTrue: [field save] ]
		ifFalse: [self isValid ifTrue: [self save] ].    "check in action methods for validation again!!"! !

!WebForm methodsFor: 'model posting'!
buttonFrom: aRequest
	"return a button pressed. For defining an action method or block to be called"
	"note that image buttons send values in coordinates, like search.x search.y"
	| btname buttonNames postKeys |
	btname := aRequest postDataAt: 'ajaxPressedButton'.  "in case of Ajax form submit"
	btname notNil ifTrue: [^btname value].
	buttonNames := (self fieldSet select: [:each | each isButton]) 
		collect: [:each | each name].
	postKeys := aRequest postDataKeys collect: [:key | key copyUpTo: $. ]. "remove .x .y"
	btname := buttonNames detect: [:each | postKeys includes: each] ifNone: [''].
	^self fieldNamed: btname.! !

!WebForm methodsFor: 'model posting'!
save
	"save all changed form field values to the domain model. All values must be valid unitl any value is saved. 
	Raise error if any value is not validated. To avoid exception, check with #isValid before!!
	Save the subforms down in hierarchy as well"
	self isValid ifFalse: [self error: 'form fields not all valid'].
	self allFields do: [:field | field save]. "only changed fields are saved!! See WebModelAdaptor save"
	self subforms do: [:each | each save]! !

!WebForm methodsFor: 'model posting' stamp: 'janko 11/2/2011 21:45'!
uncheckAllProperChecboxesFor: anEventOrRequest
	"for single input event just that checbox, if any"
	| toUncheck |
	toUncheck := self allFieldsIncludingSubforms. "by default, for classical form submits"
	(anEventOrRequest isWebEvent  "probably check/uncheck event over  WebSocket "
		and: [anEventOrRequest element class == WebCheckBox]) 
			ifTrue: [toUncheck := Array with: anEventOrRequest element].
	anEventOrRequest isAjaxRequest ifTrue: 
		[toUncheck := Array with: 
			(self fields at: anEventOrRequest ajaxSingleInputName ifAbsent: [^nil])].
	toUncheck do: [:each | each isCheckBox ifTrue: [each uncheckValue] ]! !

!WebForm methodsFor: 'model posting'!
uncheckAllProperRadioButtonsFor: aRequest
	"for single input Ajax posts just that radio button, if any"! !


!WebForm methodsFor: 'accessing' stamp: 'jm 4/24/2009 20:44'!
action
	"Url of where to post form inputs, it is optional"
	^action! !

!WebForm methodsFor: 'accessing' stamp: 'jm 4/24/2009 20:44'!
action: aString
	"Url of where to post form inputs, it is optional"
	action := aString! !

!WebForm methodsFor: 'accessing' stamp: 'jm 11/11/2010 15:44'!
allFields
	"return all fields (form elements) in this form"
	^self fields values asSet
		remove: self fieldSet ifAbsent: [];
		remove: self streamedFieldSet ifAbsent: [];
		yourself
! !

!WebForm methodsFor: 'accessing'!
allFieldsIncludingSubforms
	"return all fields (form elements) in down the form hierarchy"
	| set  |
"	count := 0.
	stContext := thisContext sender.   ""TEMPORARY, FOR DEBUGGING!!""
	[stContext notNil] whileTrue: [
		(stContext receiver isKindOf: WebForm) ifTrue: 
			[count := count +1].
		stContext := stContext sender].
	count > 20 ifTrue: [self error: 'WebForm allFields infinite recursion!!'].
"
	set := self allFields.
	self subforms do: [:subform | set addAll: subform allFieldsIncludingSubforms].
	^set! !

!WebForm methodsFor: 'accessing'!
fieldNamed: aString
	"search down to subforms too"
	^self fields at: aString ifAbsent: 
		[self subforms do: [:form || field | 
			field := form fieldNamed: aString.
			field notNil ifTrue: [^field] ].
		nil].! !

!WebForm methodsFor: 'accessing'!
hideFormTag
	"form tag is not shown at all"
	^self otherAt: #FormTagHidden put: true! !

!WebForm methodsFor: 'accessing'!
invalidFields
	"all fields whith a not valid value, including from subforms"
	^self allFieldsIncludingSubforms reject: [:each | each isValid]! !

!WebForm methodsFor: 'accessing'!
subforms
	"forms in next level of widgets in this page/popup window/widget  "
	subforms isNil ifTrue: [^#() ].
	^subforms! !

!WebForm methodsFor: 'accessing'!
superform
	"parent form"
	^superform! !

!WebForm methodsFor: 'accessing'!
topForm
	"returns the first, top form in the page/popup window"
	^self isTopForm 
		ifTrue: [self]
		ifFalse: [self superform topForm]! !

!WebForm methodsFor: 'accessing'!
topFormOnPage
	"returns the first, top form in the whole page"
	self isTopFormOnPage ifTrue: [^self].
	^self context first form! !

!WebForm methodsFor: 'accessing'!
unhideFormTag
	"form tag is not shown again"
	^self otherAt: #FormTagHidden put: false! !

!WebForm methodsFor: 'accessing'!
validFields
	"all fields whith a not valid value"
	^self allFields select: [:each | each isValid]! !

!WebForm methodsFor: 'accessing'!
view
	"for which app view is that form"
	^self context view! !


!WebForm methodsFor: 'private'!
addSubform: aWebForm
	subforms isNil ifTrue: [self initSubforms].
	(subforms includes: aWebForm) ifTrue: [^nil].
	subforms copy do: [:form | 
		form parent == aWebForm parent ifTrue:  "parent was updated/recreated, old form discarded"
			[self removeSubform: form] ].
	subforms add: aWebForm.
	aWebForm superform: self! !

!WebForm methodsFor: 'private'!
form
	^self! !

!WebForm methodsFor: 'private'!
hasTag
	^false "well..."! !

!WebForm methodsFor: 'private' stamp: 'janko 10/31/2011 20:20'!
parent: anElement
	"temporary, for debugging!!"
	^super parent: anElement.
! !

!WebForm methodsFor: 'private'!
printString
	^'aWebForm', (self isTopForm ifTrue: [' top '] ifFalse: [' ']), 
			(self isTopFormOnPage ifTrue: ['on page'] ifFalse: ['on popup']), 
		(self id notNil ifTrue: 
			[(String with: Character cr), '     id: ', self id] ifFalse: ['']),
		((self attributesAt: #class)  notNil ifTrue: 
			[(String with: Character cr), '     class: ', self attributesAt: #class ] ifFalse: ['']),
		(String with: Character cr), '     valid: ', self isValid printString,
		(String with: Character cr), '     fields: ', (self fields size - 2) printString,
		(String with: Character cr), '     superform: ', (self superform isNil ifTrue: ['nil'] ifFalse: ['aWebForm']),
		(String with: Character cr), '     subforms: ', self subforms size printString,
		(String with: Character cr), '     parent: ', self parent printString! !

!WebForm methodsFor: 'private'!
removeSubform: aWebForm
	subforms isNil ifTrue: [^nil].
	subforms remove: aWebForm ifAbsent: [nil].! !

!WebForm methodsFor: 'private' stamp: ' 21/4/07 22:07'!
shouldIdent
	^true! !

!WebForm methodsFor: 'private'!
superform: aWebForm
	"parent form"
	self == aWebForm ifTrue: [self error: 'superform?']. "for debugging!!"
	superform := aWebForm! !

!WebForm methodsFor: 'private' stamp: ' 21/4/07 22:07'!
tabOrder
	"return a collection of all fields in this form, ordered by tab order"
	tabOrder isNil ifTrue: [self initTabOrder].
	^tabOrder! !


!WebForm methodsFor: 'private-fields' stamp: ' 21/8/07 09:38'!
addToFields: aWebFormElement
	"and to tab order"
	(self alreadyRegistered: aWebFormElement) ifTrue: [^self error: 'already exist!!'].
	self fields at: aWebFormElement name put: aWebFormElement.
	self tabOrder add: aWebFormElement.
	aWebFormElement isStreamed ifTrue: [self streamedFieldSet add: aWebFormElement].
	^self fieldSet add: aWebFormElement! !

!WebForm methodsFor: 'private-fields' stamp: ' 21/4/07 22:07'!
alreadyRegistered: aWebFormElement
	^self fieldSet includes: aWebFormElement! !

!WebForm methodsFor: 'private-fields' stamp: ' 21/4/07 22:07'!
fieldSet
	^self fields at: #set ifAbsent: [self initFieldSet].! !

!WebForm methodsFor: 'private-fields' stamp: ' 21/4/07 22:07'!
fields
	"return a dictionary of all fields in this form. a field name is used as a key"
	fields isNil ifTrue: [self initFields].
	^fields! !

!WebForm methodsFor: 'private-fields'!
nextFieldNumber
	"for unique numbering of fields on all form hierachy on the whole page" 
	| number |
	number := self otherAt: #NextFieldNumber ifAbsentPut: [0].
	number := number + 1.
	self otherAt: #NextFieldNumber put: number.
	^number! !

!WebForm methodsFor: 'private-fields' stamp: ' 21/8/07 09:38'!
streamedFieldSet
	^self fields at: #streamedFields ifAbsent: [self initStreamedFieldSet].! !


!WebForm methodsFor: 'private-ajax'!
announceChange: aFormElement
	self announcers do: [:each | each value: aFormElement]! !

!WebForm methodsFor: 'private-ajax'!
announcers
	"whom to announce form field change. A collection of blocks to call"
	^self otherAt: #announcers ifAbsentPut: [OrderedCollection new]! !

!WebForm methodsFor: 'private-ajax'!
onFormChangeDo: aBlock
	"run a block with changed field as argument immedatelly after field change is Ajax detected"
	self announcers add: aBlock! !

!WebForm methodsFor: 'private-ajax'!
scriptForPostAndUpdate: anElementToUpdate from: anElementToRecreate with: anArgString  optional: anArg2String button: aWebButton for: aContext
	"Whole form post!! Form from page, popup window or standalone widget"
	"Sychronous Ajax call, it blocks until call is finished!!"
	"ElementToUpdate will be replaced with contents of the elementToRecreate after its creation method will be   
      called to recreate it. Except for popups both elements are actually the same"
	"First argument will be send as an argument of the method while second is optional"
	"If both elements are nil, only arguments will be sent, usefull for sending commands only, like close window"
	"See WebApplication>>respondToAjaxRequest: for more"
	"Prototype specific"
	| url id parms buttonName buttonValue |
	id := anElementToUpdate notNil ifTrue: [anElementToUpdate ensureId; id] ifFalse: [#nil].
	url := self ajaxCallUrl. 
	parms := self ajaxCallUrlParametersFor: anElementToUpdate context: aContext.
	anArgString notNil ifTrue: [parms := parms, '&parm=', anArgString].
	anArg2String notNil ifTrue: [parms := parms, '&parm2=', anArg2String].
	anElementToRecreate notNil ifTrue: 
		[parms := parms, '&ajaxContentElementId=', 
			[anElementToRecreate registerId. anElementToRecreate id asString] value ].
	aWebButton notNil ifTrue: 
		[buttonName := aWebButton name.  "Form.Serialize somehow doesn't add that button, so we add it manually"
		buttonValue := aWebButton text].
	^'var serializedForm = Form.serialize(''', (self form registerId "if not yet"; id) asString, "page or widget form"
        '''); new Ajax.Updater(''', id asString, 
        ''', ''', "url, ''', {method: ''get'', parameters: ''', parms, ''' + form, evalScripts: true, asynchronous: false})'" url, 
        ''', {method: ''post'', postBody: serializedForm + ''', ('&', parms),  
	(aWebButton notNil ifTrue: ['&', buttonName, '=', buttonValue, '&ajaxPressedButton=', buttonName, ''] ifFalse: ['']), 
	''', evalScripts: true, asynchronous: false})'! !


!WebForm methodsFor: 'model adapting'!
bufferedValueAspect: aSymbol for: anObject
	"find a bufered (not yet saved) value of this aspect of domain object"
	| flds |
	flds := self allFields select: [:each | each adaptor subject == anObject].
	^(flds detect: [:each | each adaptor aspect = aSymbol] ifNone: [^nil])
		adaptor buffer! !

!WebForm methodsFor: 'model adapting'!
registerFormElement: aFormElement
	"register (add to fields and set model adaptor) element to this form"
	aFormElement isFormElement ifFalse: [self error: 'not a form element!!'].
	(self alreadyRegistered: aFormElement) ifTrue: [^nil]. 
	aFormElement hasName ifFalse:
		[aFormElement name: 'field', (self topFormOnPage nextFieldNumber) printString].
	self addToFields: aFormElement. 
	(aFormElement isRadioButton | aFormElement isCheckBox)
		ifTrue: [aFormElement joinToForm: self]
		ifFalse:	["aWebFormElement adapt" "not needed anymore!!"]! !

!WebForm methodsFor: 'model adapting' stamp: ' 21/8/07 09:38'!
registerStreamedFieldsInto: aHTTPPost
	"for streams it needs to be done before you use any post data, otherwise it is too late!!"
	self streamedFieldSet do: [:field | 
		field writeBlock notNil 
			ifTrue: [aHTTPPost postDataAt: field name beforeStreamingDo: field writeBlock].
		field writeStream notNil 
			ifTrue: [aHTTPPost postDataAt: field name streamTo: field writeStream] ]! !


!WebForm methodsFor: 'validation'!
collectErrorTexts
	"collect all validation error texts, separated by <br>"
	^self invalidFields 
		inject: ''
		into: [:text :each | text, each errorText, '<br>'].! !

!WebForm methodsFor: 'validation'!
isComplete
	"all required fields entered and all all fields valid"
	^self isEntered and: [self isValid]! !

!WebForm methodsFor: 'validation'!
isEntered
	"check if all required fields (form elements) have values entered. Check also subforms"
	self allFields do: [:field | field isEntered ifFalse: [^false] ].  "local form fields"
	self subforms do: [:subform | subform isEntered ifFalse: [^false] ].
	^true! !

!WebForm methodsFor: 'validation'!
isValid
	"check if all fields (form elements) have valid values. Check also subforms"
	self allFields do: [:field | field isValid ifFalse: [^false] ].  "local form fields"
	self subforms do: [:subform | subform isValid ifFalse: [^false] ].
	^true! !


!WebForm methodsFor: 'private-streaming'!
ensureOnSubmitReturnFalseAtEnd
	"for onSubmit script, ensure that 'return false' (if any) will be the last sentence in the script"
	| coll new |
	coll := self attributesAt: #onSubmit. coll isNil ifTrue: [^nil].
	(coll isKindOf: OrderedCollection) ifFalse: [^nil].
	(coll contains: [:each | '*return false*' match: each]) ifFalse: [^nil].
	new := coll reject: [:each | '*return false*' match: each].  "also to avoid duplicates"
	new := new add: 'return false'; yourself.
	self attributesAt: #onSubmit put: new.! !

!WebForm methodsFor: 'private-streaming'!
prepareActionStringOn: aSession
	"example of action string:  '/object.html?view=edit&aidaCtx=70413#anchor123"
	| actionString upToAnchor anchor ctx |
	actionString :=  (self action notNil 
		ifTrue: [self action "predefined action" ] ifFalse: [aSession fullUrlForCurrentPage]).
	upToAnchor := actionString readStream upTo: $#.
	anchor := actionString readStream upTo: $#; upToEnd.
	ctx := self context.
	actionString := upToAnchor, ((actionString includes: $? ) ifTrue: ['&'] ifFalse: ['?']),
		(ctx notNil ifTrue: [WebContext contextIdName "aidaCtx", '=', self context id printString] ifFalse: ['']).
	anchor notEmpty ifTrue: [actionString := actionString, '#', anchor]. "anchor always at the end!!"
	^actionString! !

!WebForm methodsFor: 'private-streaming'!
prepareToHtmlStreamingOn: aSession
	self ensureOnSubmitReturnFalseAtEnd.  "for ajaxSubmit to break normal submiting and full page reload"
	super prepareToHtmlStreamingOn: aSession.
	self reorderTabulation. "late reordering to ensure that all form elements are present"! !

!WebForm methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession.
	self isTopForm 
		ifTrue:   "subforms don't have a method parameter"
			[self isTagHidden ifFalse: 
				[aStream nextPutAll: 
					self ident, '<form  method="post" action="', (self prepareActionStringOn: aSession),  
						'"', ' enctype="multipart/form-data"'.
				self streamAttributesTo: aStream for: aSession.
				aStream nextPutAll: '>', self eol] ]
		ifFalse: 
			[aStream nextPutAll: '<div comment="subform" '.
				self streamAttributesTo: aStream for: aSession.
				aStream nextPutAll: '>', self eol].
	super streamHtmlTo: aStream for: aRequest on: aSession.
	aStream nextPutAll:  self ident, 
		((self isTopForm and: [self isTagHidden not]) ifTrue: ['</form>'] ifFalse: ['</div>'])
		, self eol.! !


!WebForm methodsFor: 'tabulation' stamp: ' 21/4/07 22:07'!
fieldWithTabIndex: aNumber	
	"return a form element with that tab index"
	^self tabOrder detect: [:field | field tabIndex = aNumber] ifNone: [nil].! !

!WebForm methodsFor: 'tabulation'!
nextFieldTabOrderIn: aFormElement
	"next element to tab into"
	| inx |
	self tabOrder isEmpty ifTrue: [^nil].
	inx := self tabOrder indexOf: aFormElement.
	inx = 0 ifTrue: [^self tabOrder first].
	inx = self tabOrder size ifTrue: [^self tabOrder first]. "rotate"
	^self tabOrder at: inx+1! !

!WebForm methodsFor: 'tabulation'!
reorderTabulation
	"builds and reorders tabOrder to match tabIndex order of form (and subforms) elements"
	| flds withTabIndex |
	self initTabOrder.
	flds := self allFieldsIncludingSubforms.
	withTabIndex := flds select: [:each | each tabIndex notNil and: [each tabIndex ~= 0] ]. "with tab index explicitly set"
	withTabIndex := SortedCollection withAll: withTabIndex sortBlock: [:a :b | a tabIndex < b tabIndex].
	self tabOrder addAll: withTabIndex.
	withTabIndex := withTabIndex asSet.
	 "those without tab index at the end"
	self tabOrder addAll: (flds reject: [:each | withTabIndex includes: each]).! !


!WebForm methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initFieldSet
	"with all fields for fast check, if field is already registered"
	^self fields at: #set put: Set new.! !

!WebForm methodsFor: 'initialize-release' stamp: ' 21/8/07 09:38'!
initFields
	fields := Dictionary new.
	self initFieldSet. "with all fields for fast check, if field is already registered"
	self initStreamedFieldSet! !

!WebForm methodsFor: 'initialize-release' stamp: ' 21/8/07 09:38'!
initStreamedFieldSet
	"all fields which demands request post data streaming directly to output stream"
	^self fields at: #streamedFields put: Set new.! !

!WebForm methodsFor: 'initialize-release'!
initSubforms
	subforms := OrderedCollection new.! !

!WebForm methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initTabOrder
	tabOrder := OrderedCollection new.! !


!WebForm methodsFor: 'testing'!
isTagHidden
	"form tag is not shown at all"
	^self otherAt: #FormTagHidden ifAbsent: [false]! !

!WebForm methodsFor: 'testing'!
isTopForm
	"top form in page or popup window"
	^self superform isNil! !

!WebForm methodsFor: 'testing'!
isTopFormOnPage
	"top form on the whole page"
	^self isTopForm and: [self parent isWebPage]! !

!WebForm methodsFor: 'testing'!
isWebForm
	^true! !


!WebForm methodsFor: 'events'!
onReset: aJavascriptCode
	self attributesAt: #onReset add: aJavascriptCode! !

!WebForm methodsFor: 'events'!
onSubmit: aJavascriptCode
	"many calls will add a JS code to the exisitng one!!"
	self attributesAt: #onSubmit add: aJavascriptCode! !


!WebForm methodsFor: 'events-ajax'!
onSubmitUpdate: anElement
	"update (and show if not yet) a specified element from server (AJAX)"
	self onSubmitUpdate: anElement with: nil optional: nil! !

!WebForm methodsFor: 'events-ajax'!
onSubmitUpdate: anElement with: anArgString optional: anArg2String
	"first argument will be send as an argument of the method while second is additional"
	"See WebApplication>>respondToAjaxRequest: and specially #ajaxUpdate:from: for more"
	"Prototype specific"
	self onSubmit: 
		(self scriptForUpdate: anElement from: anElement
			with: anArgString optional: anArg2String
		 	context: self context).! !


!WebForm methodsFor: 'private-subelements'!
releasePartially
	"don't touch a form"
 	"Release as much memory as possible from the form and its subelements. Keep only elements with id
       including forms and form elements. End result is a simplied hierarchy of only those elements"
	| toKeep |
	toKeep := self elements 
		inject: OrderedCollection new
		into: [:col :each | col addAll: each releasePartially. col].
	toKeep do: [:e | e parent: self].
	elements := toKeep.
	^Array with: self! !


!WebForm methodsFor: 'tags'!
tag
	^#form! !


WebElement subclass: #WebFormElement
	instanceVariableNames: 'adaptor enterTabForm'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebFormElement methodsFor: 'private'!
acceptInputFromValue: aString
	self subclassResponsibility! !

!WebFormElement methodsFor: 'private'!
adaptor: aProtocolAdaptor
	adaptor := aProtocolAdaptor.! !

!WebFormElement methodsFor: 'private'!
addEnterTabScriptIfNessesary
	"allow ENTER key to be used for tabulation, like a TAB"
	"Prototype specific"
	| next nextId |
	self enterTabForm isNil ifTrue: [^nil].
	next := self enterTabForm nextFieldTabOrderIn: self.
	nextId := next notNil 
		ifTrue: [next ensureId; id]
		ifFalse: [''].  "no tabulation, but also no default ENTER action!!" 
	self scriptAfter: 'Event.observe(''', self id, ''', ''keypress'', function(event) {
  		if (event.keyCode == Event.KEY_RETURN) {  
			Event.stop(event); $(''', nextId, ''').activate(); } } )'! !

!WebFormElement methodsFor: 'private'!
defaultErrorElement
	"this widget is Ajax updated with an error text in case of validation failure"
	^WebValidationError newFor: self.! !

!WebFormElement methodsFor: 'private'!
dontSanitize
	"don't sanitize input from <script> and similar possibly malicius input"
	self otherAt: #NoSanitizing put: true! !

!WebFormElement methodsFor: 'private'!
enterTabForm
	"is tab with ENTER enabled and in which form"
	^enterTabForm! !

!WebFormElement methodsFor: 'private'!
enterTabForm: aForm
	enterTabForm := aForm! !

!WebFormElement methodsFor: 'private'!
errorText
	"this text will be shown in errorElement in cas of validation failure"
	^self otherAt: #ErrorText ifAbsent: ['']! !

!WebFormElement methodsFor: 'private'!
hasTag
	"form elements have always HTML tag"
	^true! !

!WebFormElement methodsFor: 'private'!
isDiv
	^false! !

!WebFormElement methodsFor: 'private' stamp: 'janko 11/2/2011 21:01'!
printString
	"Squeak specific"
	^'a', self class printString, 
		(self id notNil ifTrue: 
			[(String with: Character cr), '     id: ', self id] ifFalse: ['']),
		((self attributesAt: #class)  notNil ifTrue: 
			[(String with: Character cr), '     class: ', (self attributesAt: #class) printString ] ifFalse: ['']),
		(self name notNil ifTrue: 
			[(String with: Character cr), '     name: ', self name] ifFalse: ['']),
		(String with: Character cr), '     value: ' , 
			(self value printString truncateWithElipsisTo:  30),  "Squeak specific"
		(String with: Character cr), '     buffered: ' , 
			(self adaptor buffer printString truncateWithElipsisTo: 30),  "Squeak specific"
		(String with: Character cr), '     changed: ', self adaptor changed printString,
		(String with: Character cr), '     valid: ', self isValid printString! !

!WebFormElement methodsFor: 'private'!
setValue: aString
	"preset the value of this form element, without set aspect adaptor"
	self notYetImplemented. "obsolete, just to catch senders!!"! !

!WebFormElement methodsFor: 'private'!
shouldSanitize
	"sanitize input from <script> and similar input to prevent entering XSS and similar malicious code"
	(self adaptor buffer isKindOf: String) ifFalse: [^false].
	^(self otherAt: #NoSanitizing ifAbsent: [false]) not! !


!WebFormElement methodsFor: 'events'!
activate
	"move focus and select the text in that form field. (focus+select)"
	self ensureId.
	self scriptAfter: 'document.getElementById(''', self id, ''').activate' 
"	self scriptAfter: 'Field.activate(''', self id, ''')'"! !

!WebFormElement methodsFor: 'events'!
blockEnterKey
	"don't allow that ENTER key press trigger unwanted form submit"
	self on: #keyPress script: 'return blockEnter(event)'! !

!WebFormElement methodsFor: 'events'!
disable
	"disable (gray out) this form element"
	self ensureId.
	self scriptAfter: 'document.getElementById(''', self id, ''').disabled = true'! !

!WebFormElement methodsFor: 'events'!
enable
	"enable again this form element"
	self ensureId.
	self scriptAfter: 'document.getElementById(''', self id, ''').disabled = false'! !

!WebFormElement methodsFor: 'events'!
focus
	"move the input focus to that form field"
	self ensureId.
	self scriptAfter: 
'var el = document.getElementById(''', self id, '''); 
if (el.createTextRange) {  
       //IE  
       var fieldRange = el.createTextRange();  
       fieldRange.moveStart(''character'', el.value.length);  
       fieldRange.collapse();  
       fieldRange.select();  
       }  
else {  
       //Firefox and Opera  
      el.focus(); 
     var len = el.value.length; 
     el.setSelectionRange(len, len);
	}'. 
"trick from http://stackoverflow.com/a/7445389 (http://stackoverflow.com/questions/511088/use-javascript-to-place-cursor-at-end-of-text-in-text-input-element)"! !

!WebFormElement methodsFor: 'events'!
ignoreEnterKey
	"don't allow ENTER/RETURN key to submit a form unintentionally, for instance"
	"Prototype specific"
	self scriptAfter: 'Event.observe(''', self id, ''', ''keypress'', function(event) {
  		if (event.keyCode == Event.KEY_RETURN) { Event.stop(event); } } )'! !

!WebFormElement methodsFor: 'events'!
onBlur: aJavascriptCode
	"when a form element loses focus either by mouse or tabulation"
	self attributesAt: #onBlur add: aJavascriptCode! !

!WebFormElement methodsFor: 'events' stamp: ' 21/4/07 22:07'!
onChange: aJavascriptCode
	self attributesAt: #onChange add: aJavascriptCode! !

!WebFormElement methodsFor: 'events' stamp: 'np 10/20/2008 16:41'!
onChangeReload
	"reload current page on change off that form element"
	self onChange: 'window.location.reload()'.! !

!WebFormElement methodsFor: 'events'!
onEnterTabulate
	"Prototype specific"
	"It goes to the next element in tabulation order"
	"This allows ENTER key to be used for tabulation, like a TAB. "
	ScriptaculousLibrary ensurePrototype.
	self enterTabForm: self form. "to make tabulation script late, just before htmlPrint"! !

!WebFormElement methodsFor: 'events'!
onEnterTabulateIn: aWidgetOrApp
	"Prototype specific"
	"It goes to the next element in tabulation order"
	"This allows ENTER key to be used for tabulation, like a TAB. "
	"Because widgets are nested, you can specify more exactly in which widget's form to tabulate"
	ScriptaculousLibrary ensurePrototype.
	self enterTabForm: aWidgetOrApp form. "to make tabulation script late, just before htmlPrint"! !

!WebFormElement methodsFor: 'events'!
onFocus: aJavascriptCode
	"when a form element receives a focus either by mouse or tabulation"
	self attributesAt: #onFocus add: aJavascriptCode! !

!WebFormElement methodsFor: 'events'!
onSelect: aJavascriptCode
	"when some text is selected in a form element"
	self attributesAt: #onSelect add: aJavascriptCode! !

!WebFormElement methodsFor: 'events'!
select
	"select a whole input. Be sure to focut it first!!"
	self ensureId.
	self scriptAfter: 'document.getElementById(''', self id, ''').select' 
"	self scriptAfter: 'Field.select(''', self id, ''')' "! !


!WebFormElement methodsFor: 'model adapting'!
adapterFor: anObject aspect: anAspectSymbolOrNumber
	"return an appropriate aspect adaptor for that element"
	((anObject isKindOf: Collection) or: [anObject isKindOf: WebTranslDict]) ifTrue:  
		"adapt to an element of collection, which must be an indexed one!! "
		[^(AidaModelAdaptor forIndex: anAspectSymbolOrNumber) subject: anObject].
	(anAspectSymbolOrNumber isKindOf: Symbol) ifTrue:
		[^(AidaModelAdaptor forAspect: anAspectSymbolOrNumber) subject: anObject].
	self error: 'innapropriate aspect'! !

!WebFormElement methodsFor: 'model adapting'!
aspect: aSymbolOrNumber for: anObject
	"set the link between this form element and an aspect (name of instance variable) 
	of an object , which value is presented in this webFormElement. The appropriate 
	aspect adaptor is generated"
	self adaptor: 
		(self adapterFor: anObject aspect: aSymbolOrNumber)! !

!WebFormElement methodsFor: 'model adapting'!
save
	"save value of this form element (field) to the domain model. Check with #isValid if value pass 
	validation othervise exception is raised!!"
	self shouldSanitize ifTrue: [self adaptor sanitize]. "remove <script> with possibly malicious code"
	^self adaptor save! !


!WebFormElement methodsFor: 'accessing'!
adaptor
	adaptor isNil ifTrue: [self initNullAdaptor]. "not yet connected to model, jsut to hold a value"
	^adaptor! !

!WebFormElement methodsFor: 'accessing'!
aspect
	^self adaptor aspect! !

!WebFormElement methodsFor: 'accessing'!
form
	"form (from page, popup window or widget) to which belongs (or it will be) this form element"
	^super form! !

!WebFormElement methodsFor: 'accessing'!
format
	"format of the value. Dep≈°ends of value type. If nil, autoformating is used"
	"For Date can be #iso #sloDate #shortSloDate"
	^self adaptor format! !

!WebFormElement methodsFor: 'accessing'!
format: aSymbol
	"format of the value. Dep≈°ends of value type. If nil, autoformating is used"
	"For Date can be #iso #sloDate #shortSloDate"
	^self adaptor format: aSymbol! !

!WebFormElement methodsFor: 'accessing'!
object
	^self adaptor subject! !

!WebFormElement methodsFor: 'accessing'!
value
	^self adaptor value! !

!WebFormElement methodsFor: 'accessing'!
value: aValue
	"set the value of this form element"
	self adaptor value:  aValue.! !


!WebFormElement methodsFor: 'private-events'!
announceChange
	self form announceChange: self! !

!WebFormElement methodsFor: 'private-events'!
canUpdate
	"form elements can be Ajax updated, to disable/enable them, a button for instance"
	^true! !

!WebFormElement methodsFor: 'private-events'!
handleSubmitEvent: aWebEvent
	"if there is some onSubmit action registered from that form element. Called after whole form is submitted"
	| handler |
	handler := self eventHandlerFor: #submit.
	handler isNil ifTrue: [^nil].
	^handler handleEvent: aWebEvent! !

!WebFormElement methodsFor: 'private-events'!
isSingleFieldPost
	"is field Ajax posted immediatelly after change, as single one, not entire form"
	^self otherAt: #singleFieldPost ifAbsent: [false]! !

!WebFormElement methodsFor: 'private-events'!
onChangeAnnounce
	"field will be posted to server but not saved, just change will be announced to form"
	"Saved will be only if setSingleFieldPost was called before"
	(self existScriptForEvent: #change) ifFalse:
		[self onChange: (self scriptForEvent: #change context: self context)].
	(self eventHandlerFor: #change)
		addAcceptPostedInput! !

!WebFormElement methodsFor: 'private-events'!
scriptForEvent: anEventSymbol context: aWebContext
	"send current value of this form element too"
	^'aidaEvent(''', anEventSymbol asString, ''',''', 
		(self ensureId; id) asString, ''',''', 
		aWebContext id asString, ''',',
		'document.getElementById(''', self id asString, ''').value);'

	"delay sending for few ms so that value will actuall be set"
"	^'setTimeout(function() {aidaEvent(''', anEventSymbol asString, ''',''', 
		(self ensureId; id) asString, ''',''', 
		aWebContext id asString, ''',',
		'document.getElementById(''', self id asString, ''').value);}, 100);' "! !

!WebFormElement methodsFor: 'private-events'!
setSingleFieldPost
	"field is Ajax posted immediatelly after change, as single one, not entire form"
	^self otherAt: #singleFieldPost put: true! !

!WebFormElement methodsFor: 'private-events'!
updateWith: anArgumentObject
	self error: 'cannot update basic web element with an argument'! !


!WebFormElement methodsFor: 'attributes'!
disabled
	"disable this form element for user input"
	self attributesAt: #disabled put: nil "just attribute name, no value"! !

!WebFormElement methodsFor: 'attributes'!
enabled
	self attributes removeKey: #disabled ifAbsent: [].! !

!WebFormElement methodsFor: 'attributes'!
max: aNumber
	"maximal value"
	^self attributesAt: #max put: aNumber printString! !

!WebFormElement methodsFor: 'attributes'!
min: aNumber
	"minimal value"
	^self attributesAt: #min put: aNumber printString! !

!WebFormElement methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
name
	^self attributesAt: #name! !

!WebFormElement methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
name: aString
	self attributesAt: #name put: aString! !

!WebFormElement methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
noTab
	"skip this form element when tabulating with TAB"
	"This attribute specifies the position of the current element in the tabbing order of that form"
	self tabIndex: 0.! !

!WebFormElement methodsFor: 'attributes'!
placeHolder: aString
	"a descriptive hint what to enter in this field"
	self attributesAt: #placeholder put: aString convertToSloveneChars! !

!WebFormElement methodsFor: 'attributes'!
readOnly
	"this form element od read only, cam be tabed in but not changed"
	self attributesAt: #readonly put: nil "just attribute name, no value"! !

!WebFormElement methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
tabIndex
	"This attribute specifies the position of the current element in the tabbing order of that form"
	^(self attributes at: #tabindex ifAbsent: [^nil]) asInteger! !

!WebFormElement methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
tabIndex: aNumber
	"This attribute specifies the position of the current element in the tabbing order 
	for the current document"
	self attributes at: #tabindex put: aNumber printString! !

!WebFormElement methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
type: aString
	"set the type of  this form element"
	self attributesAt: #type put: aString! !


!WebFormElement methodsFor: 'validation'!
errorElement
	"this element is Ajax updated wit an error text in case of validation failure. Call it only once!!"
	"Styling is determined in DefaultWebStyle>>css321Validation. Red background by default"
	| e already |
	already := self otherAt: #ErrorElementAlready ifAbsent: [false].
	already ifTrue: [self error: 'Use validation error element only once!!'].
	self otherAt: #ErrorElementAlready put: true.
	e := self otherAt: #ErrorElement ifAbsentPut: [self defaultErrorElement]. "instance of WebValidationError"
	self onChangeUpdate: e.
	^e! !

!WebFormElement methodsFor: 'validation'!
errorText: aString
	"this text will be shown in errorElement in case of validation failure"
	self otherAt: #ErrorText put: aString! !

!WebFormElement methodsFor: 'validation'!
isEntered
	"this input field is required and not empty. If not required it is entered even if empty"
	self isRequired ifFalse: [^true].
	^self adaptor changed
		ifTrue: [self adaptor isEmpty not] "changed value"
		ifFalse: [self isEmpty not] "old value"! !

!WebFormElement methodsFor: 'validation'!
isRequired
	"this input field is required and must not stay empty"
	^self otherAt: #name ifAbsent: [false]! !

!WebFormElement methodsFor: 'validation'!
isValid
	"form element (field) has a valid value"
	self adaptor isNil ifTrue: [^true].
	^self adaptor isValid! !

!WebFormElement methodsFor: 'validation'!
required
	"this input field is requied and must not stay empty"
	self otherAt: #name put: true! !

!WebFormElement methodsFor: 'validation'!
validIfTrue: aBlock
	"set the validation block to this form element . It accepts a value as argument and It must return true if entered 
	value is regarded as valid"
	"example for month verification block: [:value | value asInteger between: 1 and: 12 ] "
	self adaptor validationBlock: aBlock! !


!WebFormElement methodsFor: 'testing'!
hasName
	^self name notNil and: [self name notEmpty]! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isAutocompleteField
	^false! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isButton
	^false! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isCheckBox
	^false! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isDateInputField
	^false! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isEmpty
	"input field is empty or nil"
	| vlue |
	vlue := self object perform: self aspect.
	^vlue isNil 
		or: [((vlue isKindOf: String) and: [vlue isEmpty])
			or: [(vlue isKindOf: Number) and: [vlue = 0] ]]! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isFileInputField
	^false! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isFormElement
	^true! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isInputField
	^false! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isListBox
	^false! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isMenu
	^false! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isRadioButton
	^false! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/8/07 09:38'!
isStreamed
	"Post data from web request is streamed directly into output stream. 
	Only WebFileInputField can do that for now"
	^false! !

!WebFormElement methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isTextArea
	^false! !


!WebFormElement methodsFor: 'initialize-release'!
initNullAdaptor
	"not yet connected to model, just to hold a value"
	self adaptor: AidaModelNullAdaptor new! !

!WebFormElement methodsFor: 'initialize-release'!
initialize
	self ensureId. "web element id is mandatory for all form elements"
	self name: ''.! !


!WebFormElement methodsFor: 'events-ajax'!
onBlurUpdate: anElement
	"after field looses focus, AJAX update anElement  "
	self onBlurUpdate: anElement with: nil.! !

!WebFormElement methodsFor: 'events-ajax'!
onBlurUpdate: anElement with: anArgObject
	"after field looses focus, update anElement by calling its creation method with an argument "
	anElement isNil ifTrue: [self error: 'no element to update!!'].
	anElement isUpdatable ifFalse: [self error: 'element not updatable, must be at least DIV'].
	anElement ensureId. 
	(self existScriptForEvent: #blur) ifFalse:
		[self onChange: (self scriptForEvent: #blur context: self context)].
	(self eventHandlerFor: #blur) 
		addUpdate: anElement with: anArgObject.! !

!WebFormElement methodsFor: 'events-ajax'!
onChangeClose
	"Current window (if popup) is closed after element change, its context also"
	(self existScriptForEvent: #change) ifFalse:
		[self onChange: (self scriptForEvent: #change context: self context)].
	(self eventHandlerFor: #change) 
		addCloseWindow.! !

!WebFormElement methodsFor: 'events-ajax'!
onChangePost
	"after field change immediatelly post its value to server and save it to 
	domain object, if field is valid and complete"
	self setSingleFieldPost.   "so that field will actually be saved, otherwise change will be just announced"
	self onChangeAnnounce.! !

!WebFormElement methodsFor: 'events-ajax'!
onChangePostAndUpdate: anElement
	"after field change, post contents to server and AJAX update anElement  "
	self onChangePostAndUpdate: anElement with: nil! !

!WebFormElement methodsFor: 'events-ajax'!
onChangePostAndUpdate: anElement with: anArgObject
	"after field change, post contents to server and AJAX update anElement  with a parameter"
	anElement isNil ifTrue: [self error: 'no element to update!!'].
	anElement isUpdatable ifFalse: [self error: 'element not updatable, must be at least DIV'].
	anElement ensureId. 
	self onChangePost.	
	(self eventHandlerFor: #change)
		addUpdate: anElement with: anArgObject.! !

!WebFormElement methodsFor: 'events-ajax'!
onChangeUpdate: anElement
	"after field change update anElement on browser  "
	anElement isNil ifTrue: [self error: 'no element to update!!'].
	anElement isUpdatable ifFalse: [self error: 'element not updatable, must be at least DIV'].
	anElement ensureId. 
	(self existScriptForEvent: #change) ifFalse: "only one script per event!!"
		[self onChange:  	(self scriptForEvent: #change context: self context)].
	(self eventHandlerFor: #change) 
		addUpdate: anElement with: nil.! !

!WebFormElement methodsFor: 'events-ajax'!
onFocusUpdate: anElement
	"after field gets focus, AJAX update anElement  "
	self onFocusUpdate: anElement with: nil! !

!WebFormElement methodsFor: 'events-ajax'!
onFocusUpdate: anElement with: anArgObject
	"after field gets focus, update anElement by calling its creation method with an argument "
	anElement isNil ifTrue: [self error: 'no element to update!!'].
	anElement isUpdatable ifFalse: [self error: 'element not updatable, must be at least DIV'].
	anElement ensureId. 
	(self existScriptForEvent: #focus) ifFalse: "only one script per event!!"
		[self onFocus: (self scriptForEvent: #focus context: self context)].
	(self eventHandlerFor: #focus) 
		addUpdate: anElement with: anArgObject.! !

!WebFormElement methodsFor: 'events-ajax'!
onKeyPressPostAndUpdate: anElement
	"after any key press in a field, post input value to server and update anElement"
	anElement isNil ifTrue: [self error: 'no element to update!!'].
	anElement isUpdatable ifFalse: [self error: 'element not updatable, must be at least DIV'].
	anElement ensureId. 
	self setSingleFieldPost.   "so that field will actually be saved, otherwise change will be just announced"
	(self existScriptForEvent: #keypress) ifFalse: "only one script per event!!"
		[self onKeyPress: (self scriptForEvent: #keypress context: self context)].
	(self eventHandlerFor: #keypress)
		addAcceptPostedInput;
		addUpdate: anElement with: nil.! !

!WebFormElement methodsFor: 'events-ajax'!
onKeyUpPostAndUpdate: anElement
	"after  key up in a field, post input value to server and update anElement"
	anElement isNil ifTrue: [self error: 'no element to update!!'].
	anElement isUpdatable ifFalse: [self error: 'element not updatable, must be at least DIV'].
	anElement ensureId. 
	self setSingleFieldPost.   "so that field will actually be saved, otherwise change will be just announced"
	(self existScriptForEvent: #keyup) ifFalse: "only one script per event!!"
		[self onKeyUp:  (self scriptForEvent: #keyup context: self context)].
	(self eventHandlerFor: #keyup)
		addAcceptPostedInput;
		addUpdate: anElement with: nil.! !

!WebFormElement methodsFor: 'events-ajax'!
update
	"basic elements don't need to be recreated, just stream them to HTML with changed attributes again"
	self id isNil ifTrue: [self error: 'web element to update must have id in advance, use #ensureId !!'].
	self prepareToHtmlStreamingOn: self session. "to prepare again"
	self context first
		queueUpdateElement: self. "send immediatelly via WebSocket if open, or in Ajax response"
	^self! !


!WebFormElement methodsFor: 'events-actions' stamp: 'janko 1/2/2012 15:53'!
onChangePostAndDo: aBlock
	"execute that block when this form field is changed"
	self onChangePost.	
	(self eventHandlerFor: #change) 
		addActionBlock: aBlock.! !


!WebFormElement methodsFor: 'private-streaming'!
prepareToHtmlStreamingOn: aSession
	super prepareToHtmlStreamingOn: aSession.
	self addEnterTabScriptIfNessesary.! !

!WebFormElement methodsFor: 'private-streaming'!
releasePartially
 	"don't release contents of form elements, because #update just returns them without recereation"
	^Array with: self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebFormElement class
	instanceVariableNames: ''!

!WebFormElement class methodsFor: 'auto type converting'!
autoConvertAndEncodeQuotes: aValue
	"auto convertion, character entitites encoding (just quotes) for form elements"
	"while UTF-8 encoding is done in WebElement>>printAttribute:value:on:for: !! "
	| vlue |
	vlue := WebFormElement autoConvertToString: aValue. "dates, numbers etc."
	vlue := AIDASite encodeQuoteEntitiesIn: vlue.               "char entity encoding for double quote '' "
	^vlue! !

!WebFormElement class methodsFor: 'auto type converting'!
autoConvertAndEncodeValue: aValue
	"auto convertion, character entitites encoding for form elements"
	"while UTF-8 encoding is done in WebElement>>printAttribute:value:on:for: !! "
	| vlue |
	vlue := WebFormElement autoConvertToString: aValue. "dates, numbers etc."
	vlue := AIDASite encodeCharEntitiesIn: vlue.               "char entity encoding for < > & '' "
	^vlue! !

!WebFormElement class methodsFor: 'auto type converting' stamp: 'janko 8/3/2011 18:53'!
autoConvertString: aString toObject: anObject
	"try to convert string depending on object type"
	"Squeak specific"
	(anObject isKindOf: String) ifTrue: [^aString].
	(anObject isKindOf: Integer) ifTrue: [^aString asInteger].
	(anObject isKindOf: ScaledDecimal) ifTrue: [^aString asScaledDecimal: anObject scale].
	(anObject isKindOf: Date) ifTrue: [^Date readSloFrom: aString readStream].
	anObject isNil ifTrue: [^aString].
	^aString! !

!WebFormElement class methodsFor: 'auto type converting' stamp: 'jm 4/22/2009 23:38'!
autoConvertToString: anObject
	"try to convert object to string depending on object type"
	"Squeak specific!!"
	(anObject isKindOf: String) ifTrue: [^anObject].
	(anObject isKindOf: Integer) ifTrue: [^anObject printString].
	(anObject isKindOf: Point) ifTrue: [^anObject printDotString]. "???" "Squeak specific!!"
	(anObject isKindOf: Date) ifTrue: [^anObject shorterPrintSloString].
	anObject aidaIsAssociation ifTrue: [^anObject]. "multilingual"
	^anObject printString! !


!WebFormElement class methodsFor: 'instance creation' stamp: 'JM 4/25/2007 22:23'!
new
	^super basicNew initialize! !


WebFormElement subclass: #WebButton
	instanceVariableNames: 'type size'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!
!WebButton commentStamp: '<historical>' prior: 0!
WebButton2 for newer <button> tag
Instance Variables
	size 	<Integer>	size of the button
	type	<Symbol>	#submit, #reset or #button
!


!WebButton methodsFor: 'private'!
acceptInputFromValue: aString! !

!WebButton methodsFor: 'private'!
isValid
	"nothing to validate on a button"
	^true! !


!WebButton methodsFor: 'accessing'!
action
	^self otherAt: #Action  ifAbsent: [nil]! !

!WebButton methodsFor: 'accessing'!
action: aSymbol
	aSymbol isSymbol ifFalse: [self error: 'button action must be a symbol'].
	self otherAt: #Action  put: aSymbol! !

!WebButton methodsFor: 'accessing'!
disableUntilValid
	"until form is valid and with all required fields, button will be disabled, then it will Ajax enable"
"	self otherAt: #disableUntilValid put: true. "
	self disabled.
	self wrap. "wrap in <span> to become updatable"
	self form onFormChangeDo: [:field |
		self form isComplete 
			ifTrue:  "all requered fields and valid"
				[self enabled. 
				self focus.
				self update]
			ifFalse: "disable again if form became invalid after vas already valid"
				[self disabled. 
				self update] ]! !

!WebButton methodsFor: 'accessing'!
image: aWebImage
	"if button is an image"
	self add: aWebImage! !

!WebButton methodsFor: 'accessing'!
text: aStringOrAssociation
	"set the text to be shown in a button, It is actually a value attribute in input tag"
	| txt |
	"slovene csz are converted if char ^ is after such a char"
	txt := (aStringOrAssociation aidaIsAssociation not and: [aStringOrAssociation includes: $^ ]) 
		ifTrue: [aStringOrAssociation convertToSloveneChars] 
		ifFalse: [aStringOrAssociation].
	self addText: txt! !


!WebButton methodsFor: 'private-ajax'!
ajaxSubmit
	"submit a form by Ajax instead of normal post. Page is NOT reloaded!! " 
	self isNoSubmit ifTrue: [^nil].
	self isAjaxSubmit ifTrue: [^nil].
	self onClick:  "actually submit"
		(self scriptForSubmitOnEvent: #submit context: self context).
	(self eventHandlerFor: #submit)
		addAcceptSubmittedForm.
	self onClick: 'return false'. "to break normal form submitting and full page reload"	
	self setAjaxSubmit.! !

!WebButton methodsFor: 'private-ajax'!
onSubmitAnswer
	"Answer when button is clicked and form submitted.Answer to the currenty executing context"
	"Part of tree-like control flow, see WebDemoApp for example "
	^self otherAt: #OnSubmitAnswer ifAbsent: [nil]! !

!WebButton methodsFor: 'private-ajax'!
scriptForEvent: anEventSymbol context: aWebContext
	^'aidaEvent(''', anEventSymbol asString, ''',''', 
		(self ensureId; id) asString, ''',''', 
		aWebContext id asString, ''')'! !

!WebButton methodsFor: 'private-ajax'!
scriptForSubmitOnEvent: anEventSymbol context: aWebContext
	"send serialized form values as value"
	^'aidaEvent(''', anEventSymbol asString, ''',''', 
		(self ensureId; id) asString, ''',''', 
		aWebContext id asString, ''',',
		'aidaSerializeForm(''', self form id asString, '''))'! !

!WebButton methodsFor: 'private-ajax'!
setAjaxSubmit
	"this button will submit a form with Ajax request and a page will not be reloaded"
	^self otherAt: #AjaxSubmit put: true! !


!WebButton methodsFor: 'initialize-release'!
initialize
	self ensureId.
	self tag: 'button'.
	self type: 'submit'.! !


!WebButton methodsFor: 'testing'!
isAjaxSubmit
	"this button will submit a form with Ajax request and a page will not be reloaded"
	^(self otherAt: #AjaxSubmit) = true! !

!WebButton methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isButton
	^true! !

!WebButton methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isEmpty
	^true! !

!WebButton methodsFor: 'testing'!
isNoSubmit
	"this button was requested to not submit a form, nor classic nor Ajax way"
	^(self otherAt: #NoSubmit) = true! !

!WebButton methodsFor: 'testing'!
shouldAjaxSubmit
	"in popup window and widgets always Ajax submit!! "
	| form |
	form := self form.
	form parent isWebWindow not
		ifTrue: [^true].  "it is a widget, always Ajax submit"
	form parent isWebPage "and not a popup window" 
		ifTrue: [^false]. "can submit normally"
	^true! !

!WebButton methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
shouldIdent
	^false! !


!WebButton methodsFor: 'private-streaming'!
moveOnClickReturnFalseToEnd
	"for onClick script (if any) move the 'return false' (if any) to the end of the script"
	| coll new |
	coll := self attributesAt: #onClick. coll isNil ifTrue: [^nil].
	(coll isKindOf: OrderedCollection) ifFalse: [^nil].
	(coll contains: [:each | '*return false*' match: each]) ifFalse: [^nil].
	new := coll reject: [:each | '*return false*' match: each].  "also to avoid duplicates"
	new := new add: 'return false'; yourself.
	self attributesAt: #onClick put: new.! !

!WebButton methodsFor: 'private-streaming'!
prepareAttributesToStreamOn: aSession
	"prepare multilingual button text, if needed"
	super prepareAttributesToStreamOn: aSession.
	((self attributes includesKey: #value) 
		and: [(self attributes at: #value) aidaIsAssociation]) ifTrue:
			[self attributes 
				at: #value 
				put: (self textFromMultilang: (self attributes at: #value) on: aSession)
		]! !

!WebButton methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	(self isAjaxSubmit not "yet" and: [self shouldAjaxSubmit]) 
		ifTrue: [self ajaxSubmit].
	self moveOnClickReturnFalseToEnd. "for ajaxSubmit"
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	self prepareToHtmlStreamingOn: aSession.
	aStream nextPutAll: self ident, '<', self tag. self streamAttributesTo: aStream for: aSession. 
	aStream nextPutAll: '>', self eol.
	elements notNil ifTrue: [elements do: [:element | 
		element notNil ifTrue: [element streamHtmlTo: aStream for: aRequest on: aSession] ] ].
	aStream nextPutAll: self ident, '</', self tag, '>', self eol.
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !


!WebButton methodsFor: 'events-ajax'!
noSubmit
	"this button won't submit a form, nor classic not Ajax way"
	self isAjaxSubmit ifTrue: [self error: 'set noSubmit before calling ajaxSubmit!!'].
	self otherAt: #NoSubmit put: true.
	self onClick: 'return false'. "to break normal form submitting and full page reload"! !

!WebButton methodsFor: 'events-ajax'!
onSubmitAnswer: anObject
	"answer anObject as result when button is clicked and form submitted.Answer to the currenty executing context."
	"Answer is copied to parent context when widget and therefore context is closed"
	"Part of tree-like control flow, see WebDemoApp for example "
	self ajaxSubmit.
	(self eventHandlerFor: #submit) 
		addAnswer: anObject.! !

!WebButton methodsFor: 'events-ajax'!
onSubmitClose
	"Ajax submit then current window (if popup) is closed, its context also"
	self ajaxSubmit.
	(self eventHandlerFor: #submit) 
		addCloseWindow.! !

!WebButton methodsFor: 'events-ajax'!
onSubmitDo: aBlock
	"execute that block when this button is pressed and after form is Ajax posted"
	self ajaxSubmit.
	(self eventHandlerFor: #submit) 
		addActionBlock: aBlock.! !

!WebButton methodsFor: 'events-ajax'!
onSubmitUpdate: aWebElement
	"Ajax submit the update that element"
	^self onSubmitUpdate: aWebElement with: nil! !

!WebButton methodsFor: 'events-ajax'!
onSubmitUpdate: aWebElement with: anArgObject
	"Ajax submit the update that element"
	aWebElement isNil ifTrue: [self error: 'no element to update!!'].
	aWebElement ensureId. 
	self ajaxSubmit. "which will stop normal submit and page reload"
	(self eventHandlerFor: #submit) 
		addUpdate: aWebElement with: anArgObject.! !


!WebButton methodsFor: 'model adapting'!
save
	"nothing to save for button"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebButton class
	instanceVariableNames: ''!

!WebButton class methodsFor: 'instance creation'!
image: aWebImage
	^self new 
		type: #image; 
		image: aWebImage! !

!WebButton class methodsFor: 'instance creation'!
image: aWebImage action: aSymbol
	^self new 
		type: #image; 
		image: aWebImage;
		action: aSymbol! !

!WebButton class methodsFor: 'instance creation'!
text: aString
	^self new
		type: #submit;
		text: aString! !

!WebButton class methodsFor: 'instance creation'!
text: aString action: aSymbol
	^self new 
		type: #submit;
		text: aString;
		action: aSymbol! !


WebFormElement subclass: #WebCheckBox
	instanceVariableNames: 'checked selected'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebCheckBox methodsFor: 'private-events'!
acceptInputFromValue: aBooleanOrString
	"true/false comes from WebEvent, 'on' or '' from form post"
	(aBooleanOrString = true or: [aBooleanOrString = 'on'])
		ifTrue: [self checkValue]
		ifFalse: [self uncheckValue]! !

!WebCheckBox methodsFor: 'private-events'!
addObjectToSelected
	(self selected includes: self object) ifFalse: 
		[self selected add: self object.
		self adaptor setChanged]! !

!WebCheckBox methodsFor: 'private-events'!
checkValue
	self aspect notNil ifTrue: [self setAspectTrue].
	self selected notNil ifTrue: [self addObjectToSelected]! !

!WebCheckBox methodsFor: 'private-events'!
removeObjectFromSelected
	(self selected includes: self object) ifTrue: 
		[self selected remove: self object.
		self adaptor setChanged]! !

!WebCheckBox methodsFor: 'private-events'!
scriptForEvent: anEventSymbol context: aWebContext
	"send if chekbox checked or not after event"
	^'aidaEvent(''', anEventSymbol asString, ''',''', 
		(self ensureId; id) asString, ''',''', 
		aWebContext id asString, ''',',
		'this.checked);'! !

!WebCheckBox methodsFor: 'private-events'!
setAspectFalse
	self adaptor value: false! !

!WebCheckBox methodsFor: 'private-events'!
setAspectTrue
	self adaptor value: true! !

!WebCheckBox methodsFor: 'private-events'!
uncheckValue
	self aspect notNil ifTrue: [self setAspectFalse].
	self selected notNil ifTrue: [self removeObjectFromSelected]! !


!WebCheckBox methodsFor: 'private' stamp: ' 21/4/07 22:07'!
checked
	^checked! !

!WebCheckBox methodsFor: 'private' stamp: ' 21/4/07 22:07'!
checked: aBoolean
	checked := aBoolean! !

!WebCheckBox methodsFor: 'private' stamp: ' 21/4/07 22:07'!
joinToForm: aWebForm
	aWebForm fields keysAndValuesDo: [:fname :element | 
		element == self ifTrue: [self name: fname]. ^self]! !

!WebCheckBox methodsFor: 'private'!
object: anObject from: aCollection
	"if checked, this object will be put in collection. If object is initially in collection, 
	checkbox will be checked"
	"Usefull for easy selection among many objects"
	self adaptor: (AidaModelAdaptor new subject: anObject).
	self selected: aCollection.! !

!WebCheckBox methodsFor: 'private' stamp: ' 21/4/07 22:07'!
selected: aCollection
	"checked objects"
	selected := aCollection! !

!WebCheckBox methodsFor: 'private' stamp: ' 21/4/07 22:07'!
value
	^self attributesAt: 'value'! !

!WebCheckBox methodsFor: 'private' stamp: ' 21/4/07 22:07'!
value: aString
	"set the value name  of the  check box"
	^self attributesAt: 'value' put: aString! !


!WebCheckBox methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	super initialize.
	self type: 'checkbox'.
	self checked: false.! !


!WebCheckBox methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isCheckBox
	^true! !

!WebCheckBox methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isChecked
	| value |
	self aspect notNil ifTrue:
		[value := self object perform: self aspect.
		^value == true].  "so that false will be returned even if value is not so"
	self selected notNil ifTrue: [^self selected includes: self object]. 
	^self checked! !

!WebCheckBox methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
shouldIdent
	^false! !


!WebCheckBox methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
selected
	^selected! !

!WebCheckBox methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setChecked
	self checked: true! !

!WebCheckBox methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setUnchecked
	self checked: false! !


!WebCheckBox methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession.
	aStream nextPutAll: self ident, '<input'.
	self streamAttributesTo: aStream for: aSession.
	self isChecked ifTrue: [aStream nextPutAll: ' checked'].
	aStream nextPutAll: self tagClosing.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebCheckBox class
	instanceVariableNames: ''!

!WebCheckBox class methodsFor: 'obsolete'!
aspect: aSymbol for: anObject
	"obsolete!!"
	^self newAspect: aSymbol for: anObject! !


!WebCheckBox class methodsFor: 'instance creation'!
newAspect: aSymbol for: anObject
	"this method will be called and true/false will be set/clear on an object"
	^self new aspect: aSymbol for: anObject! !

!WebCheckBox class methodsFor: 'instance creation'!
newForObject: anObject from: aCollection
	"if checked, this object will be put in collection. If object is initially in collection, 
	checkbox will be checked"
	"Usefull for easy selection among many objects"
	^self new object: anObject from: aCollection! !


WebElement subclass: #WebIFrame
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!
!WebIFrame commentStamp: '<historical>' prior: 0!
WebIFrame is frame, inserted within a block of text. See IFRAME tag in HTML 4.01 spec
!


!WebIFrame methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
frameBorder: aNumber
	"1 yes (default), 0 no"
	self attributesAt: #frameborder put: aNumber! !

!WebIFrame methodsFor: 'attributes' stamp: 'mivsek 1/10/2008 22:20'!
height: aNumber
	self attributesAt: #height put: aNumber printString! !

!WebIFrame methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
scrolling: aSymbol
	"#yes #no #auto (default)"
	self attributesAt: #scrolling put: aSymbol! !

!WebIFrame methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
size: aPoint
	"set the size of frame area in format width@height pixels"
	self width: aPoint x.
	self height: aPoint y.! !

!WebIFrame methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
src: anUrlString
	self attributesAt: #src put: anUrlString! !

!WebIFrame methodsFor: 'attributes' stamp: 'mivsek 1/10/2008 22:21'!
width: aNumber
	self attributesAt: #width put: aNumber printString! !


!WebIFrame methodsFor: 'private'!
hasTag
	^true! !

!WebIFrame methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession. 
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	aStream nextPutAll: self ident, '<iframe'.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '>'.
	aStream nextPutAll: '</iframe>'.
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !


WebElement subclass: #WebImage
	instanceVariableNames: 'image imageMap'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebImage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
alt: aString
	self attributes at: #alt put: aString! !

!WebImage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
border: aNumber
	self attributesAt: #border put: aNumber printString! !

!WebImage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
height: aNumber
	self attributesAt: #height put: aNumber printString! !

!WebImage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
hspace: aNumber
	self attributesAt: #hspace put: aNumber printString! !

!WebImage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
imageAlign: aSymbol
	"#left #center #right"
	self attributesAt: #align put: aSymbol asString! !

!WebImage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
name: aString
	self attributesAt: #name put: aString! !

!WebImage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
size: aPoint
	"set the size of an image in format width@height"
	self width: aPoint x.
	self height: aPoint y.! !

!WebImage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
src: aString
	self attributesAt: #src put: aString! !

!WebImage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
usemap: aString
	self attributesAt: #usemap put: aString! !

!WebImage methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
width: aNumber
	self attributesAt: #width put: aNumber printString! !


!WebImage methodsFor: 'private'!
hasTag
	^true! !

!WebImage methodsFor: 'private' stamp: 'janko 9/19/2011 14:30'!
prepareAttributesToPrintOn: aSession
	super prepareAttributesToPrintOn: aSession.
	self src: (self urlOnSession: aSession).
	self imageMap notNil ifTrue: [self usemap: self imageMap name].! !

!WebImage methodsFor: 'private'!
shouldIdent
	^false! !


!WebImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
image
	^image! !

!WebImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
image: anImage
	"set the image object of WebImage. 
	If nil, then urlreference should exist for image somewhere else"
	image := anImage.! !

!WebImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
image: anImage align: aSymbol
	"set the image object of WebImage. and aligment"
	self image: anImage.
	self align: aSymbol! !

!WebImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
imageMap
	^imageMap! !

!WebImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
imageMap: anImageMap
	imageMap := anImageMap! !


!WebImage methodsFor: 'initialize-release' stamp: 'janko 3/21/2008 16:23'!
initialize
	self border: 0.
	self alt: ''.! !


!WebImage methodsFor: 'private-sprite'!
isFromSprite
	"this image is part of CSS sprite"
	^(self image isKindOf: WebMethodImage) and: 
		[self image 
			checkForSprite; "check if method image contains #addToSprite call and ensure it in sprite"
			isFromSprite]! !

!WebImage methodsFor: 'private-sprite'!
sprite
	"CSS sprite for a style of this site"
	^self site style class sprite! !

!WebImage methodsFor: 'private-sprite'!
streamFromSpriteTo: aStream for: aRequest on: aSession
	"this image is from CSS sprite, stream all necessary CSS sprite tricks for it"
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	aStream nextPutAll: self ident, 
		'<div style="width: ', self spriteWidth printString, 
		'px; height: ', self spriteHeight printString, 
		'px; background: url(''', self spriteUrl, ''') 0 -', self spritePos y printString , 'px ">'.
	aStream nextPutAll: '</div>'.
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !


!WebImage methodsFor: 'private-streaming'!
prepareAttributesToStreamOn: aSession
	super prepareAttributesToStreamOn: aSession.
	(self attributesAt: #src) notNil  "image source already set"
		ifFalse: [self src: (self urlOnSession: aSession)].
	self imageMap notNil ifTrue: [self usemap: self imageMap name].! !

!WebImage methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession

	self isFromSprite ifTrue:
		[^self streamFromSpriteTo: aStream for: aRequest on: aSession].

	self prepareToHtmlStreamingOn: aSession. 
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	aStream nextPutAll: self ident, '<img'.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: self tagClosing.
	self imageMap notNil ifTrue: 
		[imageMap streamHtmlTo: aStream for: aRequest on: aSession].
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !

!WebImage methodsFor: 'private-streaming'!
urlForLiveImageOn: aSession
	 ^aSession site urlResolver halfUrlFor: self image! !

!WebImage methodsFor: 'private-streaming'!
urlForMethodImageOn: aSession
	^self image isFromSprite
		ifFalse: [self image preferredUrl]
		ifTrue: [self site style class sprite url]! !

!WebImage methodsFor: 'private-streaming'!
urlOnSession: aSession
	self image isNil ifTrue: [^''].
	self image isString ifTrue: [^self image].
	(self image isKindOf: WebLiveImage) ifTrue: [^self urlForLiveImageOn: aSession].
	(self image isKindOf: WebMethodImage) ifTrue: [^self urlForMethodImageOn: aSession]. "including sprite"
	^aSession site urlResolver halfUrlFor: self image.! !


!WebImage methodsFor: 'sprite'!
spriteCss
	"all neccesary CSS to show this image from CSS sprite"
	"Example of generated CSS:
		/* AidaWebStyle #rssGif */
		background: url('/sprite.png') 0 -62px;
		width: 26px;
		height: 26px; "
	self isFromSprite "also ensure it in sprite if method image contains #addToSprite call"
		ifFalse: [self error: self sprite styleClass name, ' #', self image method,' not in sprite, #addToSprite call missing image method?'].
	^'  /*-- ', self sprite styleClass name, ' #', self image method, ' --*/
  background: url(''', self spriteUrl, ''') 0 -', self spritePos y printString, 'px;
  width: ', self spriteWidth printString, 'px;
  height: ', self spriteHeight printString, 'px;
'.! !

!WebImage methodsFor: 'sprite'!
spriteHeight
	^(self sprite imageNamed: self image method)
		size y! !

!WebImage methodsFor: 'sprite'!
spritePos
	self isFromSprite "also ensure it in sprite if method image contains #addToSprite call"
		ifFalse: [self error: 'this image not in sprite, #addToSprite call missing image method?'].
	^(self sprite imageNamed: self image method)
		position! !

!WebImage methodsFor: 'sprite'!
spriteUrl
	^self sprite url! !

!WebImage methodsFor: 'sprite'!
spriteWidth
	^(self sprite imageNamed: self image method)
		size x! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebImage class
	instanceVariableNames: ''!

!WebImage class methodsFor: 'instance creation'!
gif: aSymbol
	"this method will be called in your webStyle and this method 
	should return a gif in byte array format"
	^self gif: aSymbol  size: nil! !

!WebImage class methodsFor: 'instance creation'!
gif: aSymbol  size: aPoint
	"this method will be called in your webStyle and this method 
	should return a gif in byte array format"
	| methodImage image |
	image := self new.
	methodImage := WebMethodImage
		fromMethod: aSymbol 
		on: image style 
		contentType: 'image/gif' 
		site: image site.
	image image: methodImage.
	aPoint ifNotNil: [image  size: aPoint].
	^image! !

!WebImage class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
image: anImage
	^self new image: anImage! !

!WebImage class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
image: anImage align: aSymbol
	^self new image: anImage align: aSymbol! !

!WebImage class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
image: anImage size: aPoint
	^self new image: anImage; size: aPoint! !

!WebImage class methodsFor: 'instance creation'!
jpeg: aSymbol
	"this method will be called in your webStyle and this method 
	should return a jpeg in byte array format"
	^self jpeg: aSymbol  size: nil! !

!WebImage class methodsFor: 'instance creation'!
jpeg: aSymbol  size: aPoint
	"this method will be called in your webStyle and this method 
	should return a jpeg in byte array format"
	| methodImage image |
	image := self new.
	methodImage := WebMethodImage
		fromMethod: aSymbol 
		on: image style 
		contentType: 'image/jpeg' 
		site: image site.
	image image: methodImage.
	aPoint ifNotNil: [image  size: aPoint].
	^image! !

!WebImage class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !

!WebImage class methodsFor: 'instance creation'!
png: aSymbol
	"this method will be called in your webStyle and this method 
	should return a png in byte array format"
	^self png: aSymbol size: nil! !

!WebImage class methodsFor: 'instance creation'!
png: aSymbol  size: aPoint
	"this method will be called in your webStyle and this method 
	should return a jpeg in byte array format"
	| methodImage image |
	image := self new.
	methodImage := WebMethodImage
		fromMethod: aSymbol 
		on: image style 
		contentType: 'image/png' 
		site: image site.
	image image: methodImage.
	aPoint ifNotNil: [image  size: aPoint].
	^image! !


WebElement subclass: #WebImageMap
	instanceVariableNames: 'areas'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebImageMap methodsFor: 'adding areas' stamp: ' 21/4/07 22:07'!
addCirclePos: aPositionPoint diameter: aNumber  link: aWebLink

	| coords |
	coords := Array
		with: aPositionPoint x
		with: aPositionPoint y
		with: aNumber.
	self addShape: #circle coordinates: coords link: aWebLink! !

!WebImageMap methodsFor: 'adding areas' stamp: ' 21/4/07 22:07'!
addRectanglePos: aPositionPoint size: aSizePoint  link: aWebLink

	| coords |
	coords := Array
		with: aPositionPoint x
		with: aPositionPoint y
		with: (aPositionPoint + aSizePoint) x
		with: (aPositionPoint + aSizePoint) y.
	self addShape: #rect coordinates: coords link: aWebLink! !

!WebImageMap methodsFor: 'adding areas' stamp: ' 21/4/07 22:07'!
addShape: aShapeSymbol coordinates: anArray link: aWebLink

	self areas add: 
		(Array with: aShapeSymbol with: anArray with: aWebLink)! !


!WebImageMap methodsFor: 'private' stamp: ' 21/4/07 22:07'!
areas
	areas isNil ifTrue: [self initAreas].
	^areas! !

!WebImageMap methodsFor: 'private'!
hasTag
	^true! !

!WebImageMap methodsFor: 'private' stamp: 'np 10/18/2008 13:15'!
randomName

	^'map', ((AIDASite random next * 100) truncated) printString! !

!WebImageMap methodsFor: 'private' stamp: ' 21/4/07 22:07'!
shouldIdent
	^true! !

!WebImageMap methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession 
	| link |
	self prepareToHtmlStreamingOn: aSession.
	aStream nextPutAll: self ident , '<map'.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '"> ' , self eol.
	self areas do: 
			[:area | 
			aStream
				nextPutAll: self identMore , '<area shape="';
				nextPutAll: (area at: 1) asString;
				nextPutAll: '" coords="'.
			1 to: (area at: 2) size
				do: 
					[:inx | 
					inx > 1 ifTrue: [aStream nextPutAll: ','].
					aStream nextPutAll: ((area at: 2) at: inx) printString].
			link := area at: 3.
			link prepareAttributesToStreamOn: aSession.
			link streamAttributesTo: aStream for: aSession.
			aStream nextPutAll: '"> ' , self eol].
	aStream nextPutAll: self ident , '</map>' , self eol! !


!WebImageMap methodsFor: 'initialize - release' stamp: ' 21/4/07 22:07'!
initAreas
	areas := OrderedCollection new.! !

!WebImageMap methodsFor: 'initialize - release' stamp: ' 21/4/07 22:07'!
initialize
	self name: self randomName.! !


!WebImageMap methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
name
	^self attributesAt: #name! !

!WebImageMap methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
name: aString
	self attributesAt: #name put: aString.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebImageMap class
	instanceVariableNames: ''!

!WebImageMap class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !


WebFormElement subclass: #WebInputField
	instanceVariableNames: 'size maxLength type'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebInputField methodsFor: 'private'!
acceptInputFromValue: aString
	| vlue |
	aString isNil ifTrue: [^nil].  "error?"
	vlue :=  AIDASite convertFromWeb: aString on: self session. "ensure unicode!!"
	vlue := (WebFormElement autoConvertString:  vlue toObject: self value).
	self value: vlue.! !

!WebInputField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
hidden
	^self type = 'hidden'! !

!WebInputField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
hidden: aBoolean
	"make this input field hidden one"
	aBoolean ifTrue: [self type: 'hidden']! !

!WebInputField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
password
	^self type = 'password'! !

!WebInputField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
password: aBoolean
	"if true, then value will not be shown in input field"
	self type: 'password'.! !

!WebInputField methodsFor: 'private' stamp: 'np 10/20/2008 13:29'!
saveThroughAdapterValue: aValueString
	| vlue |
	aValueString isNil ifTrue: [^nil].  "error?"
	vlue :=  AIDASite convertFromWeb: aValueString on: self session. "ensure unicode!!"
	vlue := (WebFormElement autoConvertString:  vlue toObject: self value).
	self value: vlue.! !


!WebInputField methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject size: aNumber
	^self aspect: aSymbol for: anObject; size: aNumber! !

!WebInputField methodsFor: 'initialize-release'!
initialize
	super initialize.
	self tag: 'input'.
	self type: 'text'.! !


!WebInputField methodsFor: 'attributes'!
autocomplete: aBoolean
	"true if input field should have autocompete enabled (which is default in browsers)"
	self attributesAt: #autocomplete put: (aBoolean ifTrue: ['on'] ifFalse: ['off'])! !

!WebInputField methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
maxLength: aNumber
	"maximum number of characters allowed in this input field"
	self attributesAt: #maxlength put: aNumber printString! !

!WebInputField methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
resetHidden
	self hidden: false! !

!WebInputField methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
resetPassword
	self password: false! !

!WebInputField methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
setHidden
	self hidden: true! !

!WebInputField methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
setPassword
	self password: true! !

!WebInputField methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
size: aNumber
	"number of characters displayed in this input field"
	self attributesAt: #size put: aNumber printString! !


!WebInputField methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isHidden
	^self type = 'hidden'! !

!WebInputField methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isInputField
	^true! !

!WebInputField methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isPassword
	^self type = 'password'! !

!WebInputField methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
shouldIdent
	^false! !


!WebInputField methodsFor: 'private-streaming' stamp: 'janko 9/19/2011 14:30'!
prepareAttributesToPrintOn: aSession
	super prepareAttributesToPrintOn: aSession.
	self value notNil ifTrue:
		[self attributesAt: #value put: 
			(WebFormElement autoConvertAndEncodeValue: self value)]! !

!WebInputField methodsFor: 'private-streaming'!
prepareAttributesToStreamOn: aSession
	super prepareAttributesToStreamOn: aSession.
	self value isNil ifTrue: [^nil].
	self attributesAt: #value put:  
		(self adaptor format notNil
			ifTrue: [self adaptor convertedAndEncodedValue]
			ifFalse: [WebFormElement autoConvertAndEncodeValue: self adaptor value])! !

!WebInputField methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession.
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession.].
	aStream nextPutAll: self ident, '<', self tag.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '>'.
	aStream nextPutAll: '</', self tag, '>'.
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !


!WebInputField methodsFor: 'attributes-types'!
setColor
	self type: 'color'! !

!WebInputField methodsFor: 'attributes-types'!
setDate
	self type: 'date'! !

!WebInputField methodsFor: 'attributes-types'!
setDateTime
	self type: 'datetime'! !

!WebInputField methodsFor: 'attributes-types'!
setEmail
	self type: 'email'! !

!WebInputField methodsFor: 'attributes-types'!
setMonth
	self type: 'month'! !

!WebInputField methodsFor: 'attributes-types'!
setNumber
	self type: 'number'! !

!WebInputField methodsFor: 'attributes-types'!
setRange
	"HTML slider input field" 
	self type: 'range'! !

!WebInputField methodsFor: 'attributes-types'!
setSearch
	self type: 'search'! !

!WebInputField methodsFor: 'attributes-types'!
setTel
	"phone number"
	self type: 'tel'! !

!WebInputField methodsFor: 'attributes-types'!
setTime
	self type: 'time'! !

!WebInputField methodsFor: 'attributes-types'!
setUrl
	self type: 'url'! !

!WebInputField methodsFor: 'attributes-types'!
setWeek
	self type: 'week'! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebInputField class
	instanceVariableNames: ''!

!WebInputField class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
adaptIndex: aNumber ofCollection: aCollection

	^self new aspect: aNumber for: aCollection! !

!WebInputField class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject
	^self new aspect: aSymbol for: anObject! !

!WebInputField class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject size: aNumber
	^self new aspect: aSymbol for: anObject size: aNumber! !

!WebInputField class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
size: aNumber aspect: aSymbol forObject: anObject
	"OBSOLETE!!"
	^self new size: aNumber; aspect: aSymbol for: anObject! !


WebInputField subclass: #WebFileInputField
	instanceVariableNames: 'filenameAspect contentTypeAspect writeStream writeBlock'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebFileInputField methodsFor: 'aspect adapting' stamp: 'mu 5/5/2008 10:48'!
acceptFileAttributesFrom: aRequest field: aString
	| mutator |
	self filenameAspect notNil ifTrue:
		[| filename |
		mutator := (self filenameAspect asString, ':') asSymbol.
		filename := AIDASite convert: (aRequest postDataAt: aString) filenameWithoutPath fromCodepage: self session codePage.
		self object perform: mutator with: filename].
	self contentTypeAspect notNil ifTrue:
		[mutator := (self contentTypeAspect asString, ':') asSymbol.
		self object perform: mutator with: (aRequest postDataAt: aString) contentType]! !

!WebFileInputField methodsFor: 'aspect adapting' stamp: ' 21/4/07 22:07'!
aspect: aSymbol filenameAspect: aSymbol2 contentTypeAspect: aSymbol3 forObject: anObject
	^self aspect: aSymbol for: anObject; 
		filenameAspect: aSymbol2; 
		contentTypeAspect: aSymbol3! !

!WebFileInputField methodsFor: 'aspect adapting' stamp: ' 21/4/07 22:07'!
aspect: aSymbol filenameAspect: aSymbol2 forObject: anObject
	^self aspect: aSymbol for: anObject; filenameAspect: aSymbol2! !


!WebFileInputField methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
contentTypeAspect
	^contentTypeAspect! !

!WebFileInputField methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
contentTypeAspect: aSymbol
	contentTypeAspect := aSymbol! !

!WebFileInputField methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
filenameAspect
	^filenameAspect! !

!WebFileInputField methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
filenameAspect: aSymbol
	filenameAspect := aSymbol! !

!WebFileInputField methodsFor: 'accessing'!
object: anObject
	"set or change the object of model adaptor"
	self adaptor isNil  ifTrue: [self adaptor: AidaModelAdaptor new].
	self adaptor subject: anObject! !

!WebFileInputField methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
writeBlock
	^writeBlock! !

!WebFileInputField methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
writeBlock: aBlockClosure
	"this block will be called just before start of streaming to writeStream"
	writeBlock := aBlockClosure! !

!WebFileInputField methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
writeStream
	^writeStream! !

!WebFileInputField methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
writeStream: aStream
	"output binary stream where uploaded file will be directy writen"
	writeStream := aStream! !


!WebFileInputField methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	super initialize.
	self type: 'file'.! !


!WebFileInputField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
isFileInputField
	^true! !

!WebFileInputField methodsFor: 'private' stamp: ' 21/4/07 22:07'!
isInputField
	^false! !

!WebFileInputField methodsFor: 'private' stamp: ' 21/8/07 09:38'!
isStreamed
	"file is received directly from request into output stream"
	^self writeStream notNil or: [self writeBlock notNil]! !

!WebFileInputField methodsFor: 'private'!
prepareAttributesToStreamOn: aSession
	"just override value preparation to nothing"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebFileInputField class
	instanceVariableNames: ''!

!WebFileInputField class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol filenameAspect: aSymbol2 contentTypeAspect: aSymbol3 forObject: anObject

	^self new aspect: aSymbol for: anObject; 
		filenameAspect: aSymbol2;
		contentTypeAspect: aSymbol3! !

!WebFileInputField class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol filenameAspect: aSymbol2 forObject: anObject

	^self new aspect: aSymbol for: anObject; 
		filenameAspect: aSymbol2! !

!WebFileInputField class methodsFor: 'instance creation' stamp: ' 21/8/07 09:38'!
beforeStreamingDo: aBlock filenameAspect: aSymbol2 contentTypeAspect: aSymbol3 forObject: anObject
	"A block will be called just before streaming begins, with a HTTPPostDatum as parameter. Block
	  must set a write stream in datum (for instance open an output file and stream on it)"
	"example block: [:datum | datum writeStream: 'myfile' writeStream binary] "
	^self new 
		writeBlock: aBlock; 
		object: anObject; 
		filenameAspect: aSymbol2;
		contentTypeAspect: aSymbol3! !

!WebFileInputField class methodsFor: 'instance creation' stamp: ' 21/8/07 09:38'!
beforeStreamingDo: aBlock filenameAspect: aSymbol2 forObject: anObject
	"A block will be called just before streaming begins, with a HTTPPostDatum as parameter. Block
	 must set a write stream in datum (for instance open an output file and stream on it)"
	"example block: [:datum | datum writeStream: 'myfile' writeStream binary] "
	"Don't forget to close such a stream after!! This can be done in App action method"
	^self new 
		writeBlock: aBlock; 
		object: anObject; 
		filenameAspect: aSymbol2! !

!WebFileInputField class methodsFor: 'instance creation' stamp: ' 21/8/07 09:38'!
toStream: aStream filenameAspect: aSymbol2 contentTypeAspect: aSymbol3 forObject: anObject
	"wrrite uploaded file directly to aStream, which must be binary"
	^self new 
		writeStream: aStream; 
		object: anObject; 
		filenameAspect: aSymbol2;
		contentTypeAspect: aSymbol3! !

!WebFileInputField class methodsFor: 'instance creation' stamp: ' 21/8/07 09:38'!
toStream: aStream filenameAspect: aSymbol2 forObject: anObject
	"wrrite uploaded file directly to aStream, which must be binary"
	^self new 
		writeStream: aStream; 
		object: anObject; 
		filenameAspect: aSymbol2! !


WebElement subclass: #WebLabel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!
!WebLabel commentStamp: 'janko 8/25/2012 14:21' prior: 0!
WebLabel or  <label> tag defines a label for an <input> element.

The <label> element does not render as anything special for the user. However, it provides a usability improvement for mouse users, because if the user clicks on the text within the <label> element, it toggles the control.

The for attribute of the <label> tag should be equal to the id attribute of the related element to bind them together.
!


!WebLabel methodsFor: 'attributes'!
for: anElementOrId
	"a related element id for which is that label"
	^self attributesAt: #for put: 
		((anElementOrId isKindOf: WebElement)
			ifTrue: [anElementOrId id]
			ifFalse: [anElementOrId])! !

!WebLabel methodsFor: 'attributes'!
text: aString
	self addText: aString! !


!WebLabel methodsFor: 'private'!
hasTag
	^true! !


!WebLabel methodsFor: 'tags'!
tag
	^#label! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebLabel class
	instanceVariableNames: ''!

!WebLabel class methodsFor: 'instance creation'!
newFor: aWebElementOrId text: aString
	^super new
		for: aWebElementOrId;
		text: aString! !


WebElement subclass: #WebList
	instanceVariableNames: 'name kind type'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebList methodsFor: 'adding/removing' stamp: ' 21/4/07 22:07'!
add: anElement
	"ensure always WebListItem as subelement of list"
	| element |
	element := (anElement class == WebListItem)
		ifTrue: [anElement] 
		ifFalse: [WebListItem newListItem add: anElement; yourself].
	^super add: element! !

!WebList methodsFor: 'adding/removing' stamp: ' 21/4/07 22:07'!
addDefinition: anElement
	"ensure always WebListItem as subelement of list"
	| element |
	element := (anElement class == WebListItem)
		ifTrue: [anElement setDefinition] 
		ifFalse: [WebListItem newDefinition add: anElement; yourself].
	^super add: element! !

!WebList methodsFor: 'adding/removing' stamp: ' 21/4/07 22:07'!
addDefinitionTerm: anElement
	"ensure always WebListItem as subelement of list"
	| element |
	element := (anElement class == WebListItem)
		ifTrue: [anElement setDefinitionTerm] 
		ifFalse: [WebListItem newDefinitionTerm add: anElement; yourself].
	^super add: element! !

!WebList methodsFor: 'adding/removing'!
addLinkTo: anObject text: aString 
	"add new line to the list with text and link to some object. Return link, not line!!" 
	| line link |
	line := WebListItem new.
	link := line addLinkTo: anObject text: aString.
	self add: line.
	^link! !

!WebList methodsFor: 'adding/removing'!
addText: aString
	"make a new element with aString. Attributes are same as previous text. Return text, not list item!!" 
	| line text |
	line := WebListItem new.
	text := line addText: aString.
	self  add: line.
	^text! !


!WebList methodsFor: 'accessing'!
definition
 	self kind: #definition! !

!WebList methodsFor: 'accessing'!
kind
	"should be #ordered, #unordered, #definition"
	^kind! !

!WebList methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
name
	^name! !

!WebList methodsFor: 'accessing'!
name:  aString
	"set the name of this list. Used for accessing the selections from WebForm or WebApplication"
	name := aString.! !

!WebList methodsFor: 'accessing'!
ordered
 	self kind: #ordered! !

!WebList methodsFor: 'accessing'!
unordered
 	self kind: #unordered! !


!WebList methodsFor: 'private'!
hasTag
	^false "well.."! !

!WebList methodsFor: 'private'!
kind: aSymbol
	"should be #ordered, #unordered, #definition. By default is #unordered"
	kind := aSymbol.! !

!WebList methodsFor: 'private'!
shouldIdent
	^true! !

!WebList methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	| tag |
	self prepareToHtmlStreamingOn: aSession. 
	self kind == #ordered ifTrue: [tag := 'ol'].
	self kind == #unordered ifTrue: [tag := 'ul'].
	self kind == #definition ifTrue: [tag := 'dl'].
	aStream nextPutAll: self ident, '<', tag.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '>', self eol.
	super streamHtmlTo: aStream for: aRequest on: aSession.
	aStream nextPutAll: self ident, '</', tag, '>', self eol.! !


!WebList methodsFor: 'initialize-release'!
initialize
	self unordered! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebList class
	instanceVariableNames: ''!

!WebList class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
kind: aSymbol
	"should be #ordered, #unordered, #definition"

	^self new initialize kind: aSymbol! !

!WebList class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !

!WebList class methodsFor: 'instance creation'!
newDefinition
	^self new definition! !

!WebList class methodsFor: 'instance creation'!
newOrdered
	^self new ordered! !

!WebList class methodsFor: 'instance creation'!
newUnordered
	^self new unordered! !


WebElement subclass: #WebListItem
	instanceVariableNames: 'tag'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebListItem methodsFor: 'private'!
hasTag
	^false "otherwise duplicate tags!!"! !

!WebListItem methodsFor: 'private'!
shouldIdent
	^true! !

!WebListItem methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession. 
	aStream nextPutAll: self ident, '<', self tag.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '>'.
	super streamHtmlTo: aStream for: aRequest on: aSession.
	aStream nextPutAll: '</', self tag, '>', self eol.! !


!WebListItem methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	self setListItem! !


!WebListItem methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setDefinition
	self tag: 'dd'! !

!WebListItem methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setDefinitionTerm
	self tag: 'dt'! !

!WebListItem methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setListItem
	self tag: 'li'! !

!WebListItem methodsFor: 'accessing'!
tag
	tag isNil ifTrue: [self setListItem].
	^tag! !

!WebListItem methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
tag: aString
	tag := aString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebListItem class
	instanceVariableNames: ''!

!WebListItem class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !

!WebListItem class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newDefinition
	^self new setDefinition "dd"! !

!WebListItem class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newDefinitionTerm
	^self new setDefinitionTerm "dt"! !

!WebListItem class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newListItem
	^self new setListItem "li"! !


WebFormElement subclass: #WebMenu
	instanceVariableNames: 'multiple selected adaptorToStore sort'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!
!WebMenu commentStamp: '<historical>' prior: 0!
WebMenu is a dropdown menu, which can select single or multiple options. Options are read from a collection, selected options are put in selected. You can set aspect of each option if options are not plain text. 

Example:

	WebMenu aspect: #name collection: self persons selected: self selectedPersons

will show dropdown menu of all persons, shown by name. Selected person will be stored in selectedPersons collection. Above menu is  single selection, it can be multiple selection too if you do:

	aWebMenu setMultiple.!


!WebMenu methodsFor: 'model adapting'!
acceptFormInputFrom: aPostDataArray
	| values |
	values := aPostDataArray class == Dictionary
		ifTrue:  [Set new add: (aPostDataArray at: self name); yourself]
		ifFalse: [(aPostDataArray allAt: self name) asSet].
	self acceptInputFromValues: values! !

!WebMenu methodsFor: 'model adapting'!
acceptInputFromValues: aCollection
	| option result values |
	self selected isNil ifTrue: [self selected: OrderedCollection new]. "we need a collection!! "
	self selected copy do: [:each | self selected remove: each].
	values := aCollection collect: [:each | AIDASite convert: each fromCodepage: #'UTF-8'].
	self selected addAll: 
		(self collection select:  [:each |
			option := self aspect isNil ifTrue: [each] ifFalse: [each perform: self aspect].
			option := option trimBlanks. "it should also eliminate more than one spaces together!!"
			values contains: [:value | value match: option] ] ).
	self aspectToStore notNil ifTrue: 
		[result := self selected notEmpty ifTrue: [self selected asOrderedCollection first] ifFalse: [nil].
		self adaptorToStore value: result]! !

!WebMenu methodsFor: 'model adapting'!
aspect: aSymbol collection: aCollection selected: aSelectedCollection
	self adaptor: ((AidaModelAdaptor forAspect: aSymbol) subject: aCollection).
	self selected: aSelectedCollection.
	self setMultiple.
	self size: 4.! !

!WebMenu methodsFor: 'model adapting'!
aspect: aSymbol collection: aCollection selectedToAspect: aSymbol2 of: anObject
	self multiple: false.
	self adaptor: ((AidaModelAdaptor forAspect: aSymbol) subject: aCollection).
	self adaptorToStore: ((AidaModelAdaptor forAspect: aSymbol2) subject: anObject).! !

!WebMenu methodsFor: 'model adapting'!
collection: aCollection selected: aSelectedCollection
	self adaptor: (AidaModelAdaptor new subject: aCollection). "just to hold our collection"
	self selected: aSelectedCollection.
	self setMultiple.
	self size: 4.! !

!WebMenu methodsFor: 'model adapting'!
collection: aCollection selectedToAspect: aSymbol of: anObject
	self multiple: false.
	self adaptor: (AidaModelAdaptor new subject: aCollection). "just to hold our collection"
	self adaptorToStore: ((AidaModelAdaptor forAspect: aSymbol) subject: anObject).! !

!WebMenu methodsFor: 'model adapting'!
save
	^self adaptorToStore notNil ifTrue: [self adaptorToStore save]! !


!WebMenu methodsFor: 'private'!
acceptInputFromValue: aString
	self acceptInputFromValues: (Array with: aString)! !

!WebMenu methodsFor: 'private'!
adaptorToStore: anAIDAAspectAdaptor
	"an aspect - name of a method to call on object, to write down a result from selection"
	adaptorToStore := anAIDAAspectAdaptor! !

!WebMenu methodsFor: 'private' stamp: ' 21/4/07 22:07'!
joinToForm: aWebForm
	aWebForm fields keysAndValuesDo: [:fname :element | 
		element == self ifTrue: [self name: fname]. ^self]! !

!WebMenu methodsFor: 'private' stamp: ' 21/4/07 22:07'!
multiple
	^multiple! !

!WebMenu methodsFor: 'private' stamp: ' 21/4/07 22:07'!
multiple: aBoolean
	multiple := aBoolean! !

!WebMenu methodsFor: 'private' stamp: ' 21/4/07 22:07'!
selected: aCollection
	selected := aCollection! !

!WebMenu methodsFor: 'private' stamp: ' 21/4/07 22:07'!
shouldIdent
	^false! !


!WebMenu methodsFor: 'accessing'!
adaptorToStore
	"an aspect - name of a method to call on object, to write down a result from selection"
	^adaptorToStore! !

!WebMenu methodsFor: 'accessing'!
aspectToStore
	^self adaptorToStore notNil
		ifTrue: [self adaptorToStore aspect]
		ifFalse: [nil]! !

!WebMenu methodsFor: 'accessing'!
collection
	^self object "in adaptor"! !

!WebMenu methodsFor: 'accessing'!
objectToStore
	^self adaptorToStore notNil
		ifTrue: [self adaptorToStore subject]
		ifFalse: [nil]! !

!WebMenu methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
resetMultiple
	self multiple: false! !

!WebMenu methodsFor: 'accessing'!
selected
	"selected options wiil be stored here"
	^selected! !

!WebMenu methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setMultiple
	self multiple: true! !

!WebMenu methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
size: aRowNumber
	"number of rows visible in multiple selection menu"
	self attributesAt: #size put: aRowNumber printString! !


!WebMenu methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	super initialize.
	self resetMultiple.! !


!WebMenu methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isEmpty
	"input field is empty or nil"
	| vlue |
	self objectToStore notNil ifTrue: [vlue := self objectToStore perform: self aspectToStore].
	^vlue isNil 
		or: [((vlue isKindOf: String) and: [vlue isEmpty])
			or: [(vlue isKindOf: Number) and: [vlue = 0] ]]! !

!WebMenu methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isMenu
	^true! !

!WebMenu methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isMultiple
	"multiple selection?"
	^self multiple! !


!WebMenu methodsFor: 'validation'!
isValid
	self adaptorToStore isNil ifTrue: [^true].
	^self adaptorToStore isValid! !


!WebMenu methodsFor: 'private-streaming'!
prepareSelected
	"add aspect of objectToStore selected result. There a preselection can reside"
	self aspectToStore isNil ifTrue: [^nil]. "multiple selections used, selected already set"
	self selected: (Set with: self adaptorToStore value)! !

!WebMenu methodsFor: 'private-streaming' stamp: 'mivsek 1/10/2008 22:25'!
printOptionsOn: aStream
	| option preselected session |
	self collection isEmpty ifTrue: [^nil].
	self prepareSelected.
	preselected := self selected notNil ifTrue: [self selected asSet] ifFalse: [#()].
	aStream nextPutAll: '<option></option>'. "empty choice"
	session := self firstSessionFromStack.
	self collection do: [:each |
		option := self aspect isNil ifTrue: [each] ifFalse: [each perform: self aspect]. 
		option := AIDASite convertToWeb: option on: session.
		aStream nextPutAll: '<option'.
		aStream nextPutAll: ((preselected includes: each) ifTrue: [' selected>'] ifFalse: ['>']).
 		aStream nextPutAll: option; nextPutAll: '</option> ' ]! !

!WebMenu methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession.
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	aStream nextPutAll: self ident, '<select'.
	self streamAttributesTo: aStream for: aSession.
	self isMultiple ifTrue: [aStream nextPutAll: ' multiple'].
	aStream nextPutAll: '>'.
	self streamOptionsTo: aStream.
	aStream nextPutAll: '</select>'.
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !

!WebMenu methodsFor: 'private-streaming'!
streamOptionsTo: aStream
	| option preselected session |
	self collection isEmpty ifTrue: [^nil].
	self prepareSelected.
	preselected := self selected notNil ifTrue: [self selected asSet] ifFalse: [#()].
	aStream nextPutAll: '<option></option>'. "empty choice"
	session := self firstSessionFromStack.
	self collection do: [:each |
		option := self aspect isNil ifTrue: [each] ifFalse: [each perform: self aspect]. 
		option := AIDASite convertToWeb: option on: session.
		aStream nextPutAll: '<option'.
		aStream nextPutAll: ((preselected includes: each) ifTrue: [' selected>'] ifFalse: ['>']).
 		aStream nextPutAll: option; nextPutAll: '</option> ' ]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebMenu class
	instanceVariableNames: ''!

!WebMenu class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol collection: aCollection selected: aSelectedCollection
	"Multiple selection menu. Aspect of every element in aColection will be shown in menu. 
	Multiple selections will be put in aSelectedCollection. Here also initial selections can be set"
	^self new aspect: aSymbol collection: aCollection selected: aSelectedCollection! !

!WebMenu class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol collection: aCollection selectedToAspect: aSymbol2 of: anObject
	"Single selection menu.. Aspect of every element in aColection will be shown in menu. 
	Single selection will be put in an seelcted aspect of object. Here also initial selection can be set"
	^self new aspect: aSymbol collection: aCollection  selectedToAspect: aSymbol2 of: anObject! !

!WebMenu class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
collection: aCollection selected: aSelectedCollection
	"Multiple selection menu.Every element (text!!) in aColection will be shown in menu. 
	Multiple selection will be put in aSelectedCollection. Here also initial selections can be set"
	^self new collection: aCollection selected: aSelectedCollection! !

!WebMenu class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
collection: aCollection selectedToAspect: aSymbol2 of: anObject
	"Single selection menu.. Every element (text!!) in aColection will be shown in menu. 
	Single selection will be put in an seelcted aspect of object. Here also initial selection can be set"
	^self new collection: aCollection selectedToAspect: aSymbol2 of: anObject! !


WebFormElement subclass: #WebRadioButton
	instanceVariableNames: 'checked'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebRadioButton methodsFor: 'private' stamp: ' 21/4/07 22:07'!
checked
	^checked! !

!WebRadioButton methodsFor: 'private' stamp: ' 21/4/07 22:07'!
checked: aBoolean
	checked := aBoolean! !

!WebRadioButton methodsFor: 'private' stamp: ' 26/4/07 10:37'!
joinToForm: aWebForm
	"join  this checkbox to the group of them with the same name in aWebForm. 
	This method is called by aWebForm!!"
	| existing |
	existing := aWebForm fieldSet 
		detect: [:each | each isRadioButton and: [each name = self name]]
		ifNone: [self value: Dictionary new. self].
	(existing value = '') ifTrue: [existing value: Dictionary new].
	self adaptor: existing adaptor.
	(self value includesKey: self value) ifFalse:
		[self value at: self value put: false] "????"! !

!WebRadioButton methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession.
	aStream nextPutAll: self ident, '<input'.
	self streamAttributesTo: aStream for: aSession.
	self isChecked ifTrue: [aStream nextPutAll: ' checked'].
	aStream nextPutAll: self tagClosing.! !

!WebRadioButton methodsFor: 'private' stamp: ' 21/4/07 22:07'!
value
	^self attributesAt: 'value'! !

!WebRadioButton methodsFor: 'private' stamp: ' 21/4/07 22:07'!
value: aString
	"set the value name  of the  radio button"
	^self attributesAt: 'value' put: aString! !


!WebRadioButton methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	super initialize.
	self type: 'radio'.
	self checked: false.! !


!WebRadioButton methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isChecked
	^self checked! !

!WebRadioButton methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isRadioButton
	^true! !

!WebRadioButton methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
shouldIdent
	^false! !


!WebRadioButton methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setChecked
	self checked: true! !

!WebRadioButton methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setUnchecked
	self checked: false! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebRadioButton class
	instanceVariableNames: ''!

!WebRadioButton class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
name: aNameString value: aValueString 

	^(self new) name: aNameString; value: aValueString! !


WebElement subclass: #WebScript
	instanceVariableNames: 'script source async defer'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebScript methodsFor: 'accessing'!
async
	async ifNil: [async := false].
	^async! !

!WebScript methodsFor: 'accessing'!
defer
	defer ifNil: [defer := false].
	^defer! !

!WebScript methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
script
	^script! !

!WebScript methodsFor: 'accessing'!
script: aString
	"add to others if already exists, separate with JavaScript separator ; "
	script isNil ifTrue: [script := ''].
	(script notEmpty and: [script last ~= $; ]) ifTrue: [script := script, '; '].
	script := script, aString trimBlanks.! !

!WebScript methodsFor: 'accessing'!
setAsync
	"load and execute this script asynchronously  (only for external scripts)"
	async := true! !

!WebScript methodsFor: 'accessing'!
setDefer
	"defer loading and executing this this script until page loaded (only for external scripts)"
	async := true! !

!WebScript methodsFor: 'accessing'!
source
	"URL of external script source, if any"
	^source! !


!WebScript methodsFor: 'private'!
changeContextFrom: oldCtx to: newCtx
	"scan for all references to context ids and change them. Also in subelements"
	| in out aidaCtx sep |
	aidaCtx := WebContext contextIdName.
	(('*', aidaCtx, '*') match: self script) ifFalse: [^nil].
	in := self script readStream. out := WriteStream on: String new.
	[in atEnd] whileFalse: 
		[out nextPutAll: (in upTo: aidaCtx). 
		in atEnd not ifTrue: 
			[in skip "=". sep := in upTo: $&.
			out nextPutAll: aidaCtx, '=', newCtx id printString, sep ] ].
	self script: out contents! !

!WebScript methodsFor: 'private'!
hasTag
	^true! !

!WebScript methodsFor: 'private'!
includesScriptTag
	"if script starts and ends with a script tag. Otherwise we add it by ourselves"
	^'<script*' match: self script! !

!WebScript methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	| existScriptTag |
	existScriptTag := self includesScriptTag. "don't add script tag if script already have it!! "
	existScriptTag ifFalse: [aStream nextPutAll: '<script'].
	self async ifTrue: 
		[aStream nextPutAll: ' async'].
	self defer ifTrue: 
		[aStream nextPutAll: ' defer'].
	self source notNil ifTrue: 
		[aStream nextPutAll: ' src="', self source, '"'].
	existScriptTag ifFalse: [aStream nextPutAll: '>']. 
	self script notNil ifTrue: [aStream nextPutAll: script].
	existScriptTag ifFalse: [aStream nextPutAll: '</script>'].
	aStream nextPutAll: self eol.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebScript class
	instanceVariableNames: ''!

!WebScript class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
script: aString
	^super new script: aString! !

!WebScript class methodsFor: 'instance creation' stamp: 'mivsek 1/10/2008 19:38'!
source: anURLString
	"and external script, with an Url to it"
	^super new source: anURLString! !


WebElement subclass: #WebSeparator
	instanceVariableNames: 'type size length'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebSeparator methodsFor: 'private'!
hasTag
	^true! !

!WebSeparator methodsFor: 'private'!
shouldIdent
	^self type ~= #break! !

!WebSeparator methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	| tag |
	self prepareToHtmlStreamingOn: aSession. 
	type = #paragraph ifTrue: [tag := 'p'].
	type = #break ifTrue: [tag := 'br'].
	type = #ruler ifTrue: [tag := 'hr'].
	aStream nextPutAll: self ident, '<', tag.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: self tagClosing, self eol.! !


!WebSeparator methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
size: aNumber
	"size of a ruler"
	self attributesAt: #size put: aNumber printString.! !


!WebSeparator methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
type
	^type! !

!WebSeparator methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
type: aSymbol
	"#ruler #paragraph #break"
	type := aSymbol.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebSeparator class
	instanceVariableNames: ''!

!WebSeparator class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
break
	
	^ self new type: #break! !

!WebSeparator class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
paragraph
	
	^ self new type: #paragraph! !

!WebSeparator class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
rulerSize: aNumber
	
	^(self new) type: #ruler; size: aNumber! !


WebElement subclass: #WebStubElement
	instanceVariableNames: 'multiple collection selected aspectToStore objectToStore sort'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!
!WebStubElement commentStamp: 'jm 8/21/2009 19:45' prior: 0!
WebStubElement is an element which will be replaced with a real one after Ajax update

Example:
	u := WebStubElement newFor: #ajaxShowElement.
	(e addNilLinkText: 'update') onClickUpdate: u.
	e add: u.
	
This will show the element at the click to link by updating the empty stub element.!


!WebStubElement methodsFor: 'views'!
build
	self 
		clear;
		setDiv;
		addComment: 'popup stub'; "into html"
		attributesAt: #comment put: 'popup-stub' "into div tag, to spot it easier when inspecting html"! !

!WebStubElement methodsFor: 'views'!
buildAsNew
	"called from #update, to properly replace old stup with a new one"
	^(self class newOn: self basicCreationContext)
		id: self id.  "preserve id"! !


!WebStubElement methodsFor: 'testing'!
canUpdate
	"stub element needs to be updated back when closing a popup window"
	^true! !

!WebStubElement methodsFor: 'testing'!
isActive
	^true! !

!WebStubElement methodsFor: 'testing' stamp: 'jm 8/26/2009 15:02'!
isStubElement
	^true! !


!WebStubElement methodsFor: 'attributes'!
noDiv
	"ignore that, stub element must be always DIV"! !


!WebStubElement methodsFor: 'private'!
parent: aWindow
	"temporary for debugging"
	^super parent: aWindow! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebStubElement class
	instanceVariableNames: ''!

!WebStubElement class methodsFor: 'instance creation'!
newOn: aWebContext
	| instance |
	instance := super new.
	instance 
		creationMethod: #buildAsNew; "to return a new instance, not existing one"
		creationObject: instance;
		basicCreationContext: aWebContext;
		setDiv;
		registerId;
		build.
	^instance! !


WebElement subclass: #WebTable
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebTable methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
bgColor: aColorSymbol
	self attributesAt: #bgcolor put: (self colorValue: aColorSymbol)! !

!WebTable methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
border: aNumber
	"set the width of table border. default is 0"
	self attributesAt: #border put: aNumber printString.! !

!WebTable methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
cellPadding: aNumber
	"define spacing between vertically adjacent cells"
	self attributesAt: #cellpadding put: aNumber printString.! !

!WebTable methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
cellSpacing: aNumber
	"define spacing between adjacent cells horizontally"
	self attributesAt: #cellspacing put: aNumber printString.! !

!WebTable methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
color: aColorSymbol
	self	bgColor: aColorSymbol! !

!WebTable methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
height: aNumber
	| text |
	text := aNumber <= 1 
			ifTrue: [(aNumber * 100) asInteger printString, '%']
			ifFalse: [aNumber asInteger printString].
	self attributesAt: #height put: text! !

!WebTable methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
width: aNumber
	"set the width of entire table If nil, then table automaticaly addjust itself. 
	If number is between 0 and 1 then width is percent of document width.
	If number above 1 then width in pixels"
	| text |
	text := aNumber <= 1 
			ifTrue: [(aNumber * 100) asInteger printString, '%']
			ifFalse: [aNumber asInteger printString].
	self attributesAt: #width put: text! !


!WebTable methodsFor: 'private'!
hasTag
	^super hasTag! !

!WebTable methodsFor: 'private'!
shouldIdent
	^true! !

!WebTable methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession. 
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	aStream nextPutAll: self ident, '<table'.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '>', self eol.
	super streamHtmlTo: aStream for: aRequest on: aSession.
	aStream nextPutAll: self ident, '</table>', self eol.
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !


!WebTable methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	"self border: 0."! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebTable class
	instanceVariableNames: ''!

!WebTable class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !


WebElement subclass: #WebTableCell
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebTableCell methodsFor: 'attributes'!
align: aSymbol
	"set a horizontal aligment if cell content. It can be #left, #center #right or #justify"
	(#(left center right justify) includes: aSymbol) ifFalse: [self error: 'wrong align symbol'].
	self attributesAt: #align put: aSymbol asString.! !

!WebTableCell methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
background: aWebImage
	"bachground image"
	self attributesAt: #background put:
		(((aWebImage isKindOf: WebImage) ifTrue: [aWebImage] ifFalse: [WebImage image: aWebImage]) 
			urlOnSession: self session)! !

!WebTableCell methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
bgColor: aColorSymbol
	"set the color of table cell background. It can be in hex format (for example #00FF00) 
	or name of color (for example #White)"
	self attributesAt: #bgcolor put: (self colorValue: aColorSymbol)! !

!WebTableCell methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
color: aColorSymbol
	self	bgColor: aColorSymbol! !

!WebTableCell methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
colspan: aNumber
	"set the number of columns this cell will span"
	self attributesAt: #colspan put: aNumber printString.! !

!WebTableCell methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
height: aNumber
	| text |
	text := aNumber <= 1 
			ifTrue: [(aNumber * 100) asInteger printString, '%']
			ifFalse: [aNumber asInteger printString].
	self attributesAt: #height put: text! !

!WebTableCell methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
nowrap: aBoolean
	"if true then text is not wrapped in new lines of a cell but a cell is expanded to carry all the text"
	self attributesAt: #nowrap put: aBoolean.! !

!WebTableCell methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
rowspan: aNumber
	"set the number of rows this cell will span"
	self attributesAt: #rowspan put: aNumber printString.! !

!WebTableCell methodsFor: 'attributes' stamp: 'JM 4/26/2007 19:34'!
setHeader
"	self changeClassTo: WebTableHeader"
	self become: (self as: WebTableHeader)! !

!WebTableCell methodsFor: 'attributes'!
valign: aSymbol
	"set a verttical aligment if cell content. It can be #top, #middle, #bottom or #baseline"
	(#(top middle bottom baseline) includes: aSymbol) ifFalse: [self error: 'wrong valign symbol'].
	self attributesAt: #valign put: aSymbol asString.! !

!WebTableCell methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
width: aNumber
	"set the width of a cell. If nil, then cell automaticaly addjust itself. 
	If number is between 0 and 1 then width is percent of table width. 
	If number above 1 then width in pixels"
	| text |
	text := aNumber <= 1 
			ifTrue: [(aNumber * 100) asInteger printString, '%']
			ifFalse: [aNumber asInteger printString].
	self attributesAt: #width put: text! !


!WebTableCell methodsFor: 'testing'!
hasTag
	^super hasTag! !

!WebTableCell methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isTableHeader
	^false! !

!WebTableCell methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
shouldIdent
	^false! !


!WebTableCell methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize! !


!WebTableCell methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession. 
	aStream nextPutAll: self ident, '<td'.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '>'.
	super streamHtmlTo: aStream for: aRequest on: aSession.
	aStream nextPutAll: self ident, '</td>', self eol.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebTableCell class
	instanceVariableNames: ''!

!WebTableCell class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !


WebTableCell subclass: #WebTableHeader
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebTableHeader methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isTableHeader
	^true! !


!WebTableHeader methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession. 
	aStream nextPutAll: self ident, '<th'.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '>'.
	elements notNil ifTrue: [elements do: [:element | 
		element notNil ifTrue: 
			[element streamHtmlTo: aStream for: aRequest on: aSession] ] ].
	aStream nextPutAll: self ident, '</th>', self eol.! !


WebElement subclass: #WebTableRow
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebTableRow methodsFor: 'attributes'!
align: aSymbol
	"set a horizontal aligment for all cells in this row. It can be #left, #center or #right"
	(#(left center right) includes: aSymbol) ifFalse: [self error: 'wrong align symbol'].
	self attributesAt: #align put: aSymbol asString.! !

!WebTableRow methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
bgColor: aColorSymbol
	"set the color of table row background. It can be in hex format (for example #00FF00) 
	or name of color (for example #White)"
	self attributesAt: #bgcolor put: (self colorValue: aColorSymbol)! !

!WebTableRow methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
color: aColorSymbol
	self	bgColor: aColorSymbol! !

!WebTableRow methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
height: aNumber
	| text |
	text := aNumber <= 1 
			ifTrue: [(aNumber * 100) asInteger printString, '%']
			ifFalse: [aNumber asInteger printString].
	self attributesAt: #height put: text! !

!WebTableRow methodsFor: 'attributes'!
valign: aSymbol
	"set a vertical aligment for all cells in this row. It can be #top, #middle, #bottom or #baseline"
	(#(top middle bottom baseline) includes: aSymbol) ifFalse: [self error: 'wrong valign symbol'].
	self attributesAt: #valign put: aSymbol asString.! !


!WebTableRow methodsFor: 'private'!
canUpdate
	^true! !

!WebTableRow methodsFor: 'private'!
hasTag
	^super hasTag! !

!WebTableRow methodsFor: 'private'!
shouldIdent
	^true! !

!WebTableRow methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession. 
	aStream nextPutAll: self ident, '<tr'.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '>', self eol.
	super streamHtmlTo: aStream for: aRequest on: aSession.
	aStream nextPutAll: self ident, '</tr>', self eol.! !


!WebTableRow methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebTableRow class
	instanceVariableNames: ''!

!WebTableRow class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !


WebElement subclass: #WebText
	instanceVariableNames: 'text size textAttributes header paragraph font'
	classVariableNames: 'AttributeMarkup'
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebText methodsFor: 'accessing' stamp: 'janko 9/30/2011 12:21'!
addText: aStringOrAssociation
	"make a new element with aString. Attributes are same as previous text." 

	self add: (WebText text: aStringOrAssociation attributes: self attributes)! !

!WebText methodsFor: 'accessing' stamp: 'janko 9/30/2011 12:21'!
addText: aStringOrAssociation attributes: anArray
	"make a new element with aString. Attributes are same as previous text." 

	self add: (WebText text: aStringOrAssociation attributes: anArray)! !

!WebText methodsFor: 'accessing'!
asString
	^self text! !

!WebText methodsFor: 'accessing'!
color: aString
	self style: 'color: ', aString asString.! !

!WebText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
font
	^font! !

!WebText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
font: aString
	font := aString! !

!WebText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
header
	^header! !

!WebText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
header: aNumber
	
	"Assigns this WebText as a header text. Parameter can be 1 .. 5. If this parameter is nil then WebText is not a header"

	aNumber < 1 
		ifTrue: [header:= 1.   ]
		ifFalse:
			[aNumber > 5 ifTrue: [header := 5.] ifFalse: [header := aNumber.]].
	^self! !

!WebText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
paragraph
	^paragraph! !

!WebText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
paragraph: aBoolean
	
	"call this method if you want this text in a new paragraph"

	paragraph := aBoolean.! !

!WebText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
size
	^size! !

!WebText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
size: aNumber
	
	"larger or smaller text for aNumber factor. Range -7..+7"

	aNumber < -7 
		ifTrue: [size := -7.  ]
		ifFalse:
			[aNumber > 7 ifTrue: [size := 7.  ] ifFalse: [size := aNumber.]].
	^self! !

!WebText methodsFor: 'accessing'!
text
	"if text is association in format #lang->text, then this is a multilingual text"
	^text! !

!WebText methodsFor: 'accessing'!
text: aStringOrAssociation
	"if text is association in format #lang->text, then this is a multilingual text"
	self basicText: (WebFormElement 
		autoConvertToString: aStringOrAssociation).  "in case the argument  is not string but date, number  etc."
	"Slovenian csz are converted if char ^ is after such a char"
	(self text aidaIsAssociation not and: [self text includes: $^ ]) 
		ifTrue: [self basicText: self text convertToSloveneChars].! !

!WebText methodsFor: 'accessing' stamp: 'janko 9/30/2011 12:16'!
text: aStringOrAssociation attributes: anArray
	self text: aStringOrAssociation.
	self textAttributes: anArray.! !


!WebText methodsFor: 'private'!
basicText: aString
	text := aString! !

!WebText methodsFor: 'private'!
hasTag
	^false  "well, ...."! !

!WebText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
insideSpanTag
	"to enclose or not in span tag. Only if element have any attribute!!"
	^self attributes notNil and: [self isLink not]! !

!WebText methodsFor: 'private' stamp: ' 21/8/07 09:38'!
onChangePost
	"just if addAspect:for:editing: false returns text instead of input field!!"! !

!WebText methodsFor: 'private' stamp: ' 21/8/07 09:38'!
onChangePostAndUpdate: e
	"just if addAspect:for:editing: false returns text instead of input field!!"! !

!WebText methodsFor: 'private'!
printString

	^'''', [self text isNil ifTrue: [''] ifFalse: [self text] ] value,''''! !

!WebText methodsFor: 'private'!
releasePartially
 	"text is emptied, we certainly don't need it anymore"
	self text: ''.
	^super releasePartially! !

!WebText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
shouldIdent
	^false! !

!WebText methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	"make a header"
	self prepareToHtmlStreamingOn: aSession. 
	aStream nextPutAll: self ident.
	self insideSpanTag ifTrue: 
		[aStream nextPutAll: '<span'. self streamAttributesTo: aStream for: aSession. aStream nextPutAll: '>'].
	self header notNil ifTrue: [aStream nextPutAll: '<h', self header printString, '>'].
	"font size, color, face"
	(self size notNil | self font notNil ) ifTrue:
		[aStream nextPutAll: '<font '.
		self size notNil ifTrue:
			[aStream nextPutAll: 'size=', (self size > 0 ifTrue: ['+'] ifFalse: ['']), self size printString, ' '].
		self font notNil ifTrue:	[aStream nextPutAll: 'face=', self font, ' '].
		aStream nextPutAll: '> ' ].
	"set text attributes, if any"
	self textAttributes notNil ifTrue: 
		[self textAttributes do: [:attribute |  aStream nextPutAll: 
			'<', attribute asString, '>']].
	"print a text"
	self text notNil ifTrue: [aStream nextPutAll: 
		(AIDASite convertToWeb: 
			(self isMultilingual ifTrue: [self textFromMultilang: self text on: aSession] ifFalse: [self text]) 
			on: aSession)].
	"print composite elements"
	super streamHtmlTo: aStream for: aRequest on: aSession.
	"reset text attributes"
	self textAttributes notNil ifTrue: 
		[self textAttributes do: [:attribute |  aStream nextPutAll: 
			'</', attribute asString, '>']].
	"end of font adjustment"
	(self size notNil | self font notNil ) ifTrue: [aStream nextPutAll: '</font>'].
	self header notNil ifTrue: [aStream nextPutAll: '</h', self header printString, '>', self eol].
	self insideSpanTag ifTrue: [aStream nextPutAll: '</span>', self eol].! !

!WebText methodsFor: 'private' stamp: ' 21/4/07 22:07'!
textAttributes
	"get the attributes of a text" 
	^textAttributes! !

!WebText methodsFor: 'private' stamp: 'janko 9/30/2011 12:07'!
textAttributes: anArray
	"check and set the attributes of a text. Atribute can be one or a set of them" 

	(anArray isKindOf: Symbol)		"if only one attribute, convert to an Array"
		ifTrue: [textAttributes := Array with: anArray.       ]
		ifFalse: [(anArray isKindOf: Array)
			ifTrue: [textAttributes := anArray.      ]
			ifFalse: [anArray isNil
				ifTrue: [textAttributes := nil.     ]
				ifFalse: 
					[self error: 'Text attributes should be Array of Symbols']]].

"WebText text: 'test' attributes: #b"
"WebText text: 'test' attributes: #( #b #i)"
"WebText text: 'test' attributes: nil"! !


!WebText methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	text := ''.   
	paragraph := false.! !


!WebText methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isLink
	^false! !

!WebText methodsFor: 'testing'!
isMultilingual
	^self text aidaIsAssociation! !


!WebText methodsFor: 'translation'!
prepareForTranslation
	"if multilingual text, replace it with in-place input field"
	| translDict replacement session |
	self isMultilingual ifFalse: [^nil].
	session := self app session.
	translDict := session site translator 
		dictToTranslate: self text to: session languageBasic for: self  on: session. "it will create one if not exists yet"
	replacement := WebInPlaceEditableText 
		aspect: self text value for: translDict size: self text value size.
	replacement onChangePost.
"	self parent replace: self with: replacement. "
	self add: replacement. "this will encapsulate inline text editor in original text formating"
	text := nil.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebText class
	instanceVariableNames: ''!

!WebText class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
header: aNumber

	"create an empty header. You can add elements such as images and text later"

	^(self new) header: aNumber.

"| a | 
a := (WebText header: 1).
a add: (WebImage urlReference: 'http://pu/stefan.gif').
a inspect"! !

!WebText class methodsFor: 'instance creation'!
new
	^super new
		setCreationMethodAndObject; "Widget or App, needed for multilingual support"
		initialize.! !

!WebText class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newParagraph

	"To open a new paragraph. Use addText: for adding a paragraph text."

	^self new paragraph: true.! !

!WebText class methodsFor: 'instance creation' stamp: 'janko 9/30/2011 12:22'!
text: aStringOrAssociation
	^self new text: aStringOrAssociation

"WebText text: 'test'"! !

!WebText class methodsFor: 'instance creation' stamp: 'janko 9/30/2011 12:22'!
text: aStringOrAssociation attributes: anArray

	^self new text: aStringOrAssociation attributes: anArray

"WebText text: 'test' attributes: #b"! !


WebText subclass: #WebAnchor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebAnchor methodsFor: 'attributes'!
name: aString
	"name of the anchor. Used for referencing in web links"
"	self id: aString. "
	self attributesAt: #name put: aString.! !


!WebAnchor methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
shouldIndent
	^true! !


!WebAnchor methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession. 
	aStream nextPutAll: self ident, '<a'.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '>'.
	"print a text with attributes and composite elements"
	super streamHtmlTo: aStream for: aRequest on: aSession.
	aStream nextPutAll: '</a>', self  eol.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebAnchor class
	instanceVariableNames: ''!

!WebAnchor class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
name: aString
	"make an anchor with specified name"
	^self new name: aString! !

!WebAnchor class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
name: aString text: anotherString
	"make an anchor with specified name and text"
	^self new name: aString; text: anotherString.! !

!WebAnchor class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
nr: aNumber
	"make a web anchor in format 'anchorx', for example 'anchor6'"
	^self new name: ('anchor', aNumber printString).! !

!WebAnchor class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
nr: aNumber text: aString
	"make an anchor with specified numberName ('anchor5') and text"
	^(self nr: aNumber) text: aString.! !


WebText subclass: #WebLink
	instanceVariableNames: 'ooReference urlReference parms anchor security'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebLink methodsFor: 'security'!
accessAllowedFor: aSession
	"true if for object of that link a view is allowed. Only for object links, for plain urls access is always 	allowed, also for user with admin rights"
	| app view |
	self ooReference isNil ifTrue: [^true].
	aSession user hasAdminRights ifTrue: [^true].
	(ooReference aidaIsAccessAllowedFor: aSession user) ifFalse: [^false].
	app := self ooReference aidaWebAppFor: aSession.
	app isNil ifTrue: [^true].     "is this really good?"
	view := (self parms at: 'view' ifAbsent: [app defaultView]) asSymbol.
	^aSession site securityManager 
		isUser: aSession user allowedTo: (app class viewRightSymbolFor: view) on: app class name.! !


!WebLink methodsFor: 'accessing'!
accessNotAllowedText
	^#en->'You don''t have enough access rights to click this link'! !

!WebLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
anchor

	^anchor! !

!WebLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
anchor: aString

	anchor := aString! !

!WebLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
anchorNr: aNumber

	"set hypertext link anchor in the same page in format '#anchorx', for example '#anchor4'. Use WebAnchor nr: method to add an anchor in a web page."

	^self anchor: '#anchor', aNumber printString.! !

!WebLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
linkTo: aLink
	"set hypertext link to some other object or page. If argumet is a String, then this is an url reference, 	else this is object reference, which is resolved to url with help of URLResolver"
	"to add anchor: #(object anchor) !! "
	(aLink isKindOf: String ) ifTrue: [self urlReference: aLink. ^self].
	(aLink isKindOf: Array)
		ifTrue: [self ooReference: (aLink at: 1). self anchor: (aLink at: 2)]
		ifFalse: [self ooReference: aLink].! !

!WebLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
parameter: aParmString value: aValueString

	"set an optional parameter for query part of an URL string (e.g in http://www.eranova.si/demo.html?view=brief 'view' is a parameter and 'brief' is its value).
You can set more than one parameters by repeating this method"

	self parms at: aParmString asString put: aValueString asString.! !

!WebLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
security
	"you can gray or not show a link at all if this object is not accessible - a view 
	on that aWebApplication has no access rights in SecurityManager for current user.
	possible values:
	nil - no access restrictions, always show the link,
	#grayed - show only text in gray - no link if access denied
	#invisible - don't show anything - invisible link if access denied
	"

	^security! !

!WebLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
security: aSymbol

	security := aSymbol! !

!WebLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
text: aString linkTo: aLink
	self linkTo: aLink.
	self text: aString.! !

!WebLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
view: aViewStringOrSymbol
	"for speedy additions of a view parameters to urls"
	"ignore #main, because this is default view anyway!!"
	((aViewStringOrSymbol = 'main') | (aViewStringOrSymbol = #main)) ifTrue: [^self].
	self parameter: 'view' value: aViewStringOrSymbol! !


!WebLink methodsFor: 'private' stamp: ' 21/4/07 22:07'!
addAnchorTo: anUrlString
	| in out anch | 
	anch := (self anchor includes: $#) ifTrue: [''] ifFalse: ['#']. 
	anch := anch, self anchor.
	in := anUrlString readStream. out := WriteStream on: String new.
"
	out nextPutAll: (in upTo: $? ). out nextPutAll: anch. 
	in atEnd ifFalse: [out nextPut: $? . out nextPutAll: in upToEnd].
"
	out nextPutAll: in upToEnd. out nextPutAll: anch.
	^out contents

"(WebLink new anchor: 'activity222') addAnchorTo:	
	'http://biart.eranova.si/object/o7665965.html?view=editActivityName&uuid=1518'
"! !

!WebLink methodsFor: 'private'!
addSessionIdTo: aString on: aSession
	| url |
	url := (aString includes: $? ) 
		ifTrue: [aString, '&'] 
		ifFalse: [aString, '?'].
	^url, 'sessionId=', aSession id printString.! !

!WebLink methodsFor: 'private'!
asWebText
	"return just a text part (with formating) of this link"
	| wtext |
	wtext := WebText new.
	wtext 
		basicText: self text copy;
		textAttributes: self textAttributes copy.
	self header notNil ifTrue: [wtext header: self header].
	self size notNil ifTrue: [wtext size: self size].
	self paragraph notNil ifTrue: [wtext paragraph: self paragraph].
	self elements do: [:each | wtext add: each].
	^wtext! !

!WebLink methodsFor: 'private' stamp: ' 21/4/07 22:07'!
checkVersionedReference
	"if ooReference is not a current version, then point it to current and add 
	version parameter to url. Version objects have always same identity, that
	is those of current object in version chain!! "
	self ooReference isCurrentVersion ifTrue: [^self].
	self parameter: 'version' value: self ooReference versionNumber.
	ooReference := self ooReference currentVersion.! !

!WebLink methodsFor: 'private'!
composeURLOn: aSession
	"do url link only if ooReference or urlReference exists, return nil otherwise"
	| stream url |
	stream := WriteStream on: String new.
	(self ooReference notNil or: [self urlReference notNil] ) ifFalse: [^nil].
	"copy parameters to aSession parms, remove all other except session id"
	parms keysAndValuesDo: [:key :value | aSession parms at: key put: value].
	aSession parms copy keysAndValuesDo: [:key :value | 
		((parms includesKey: key) or: [key = 'id']) 
			ifFalse: [aSession parms removeKey: key ifAbsent: [nil]] ].
	"make an url reference"
	self ooReference notNil
		ifTrue:	
			[url := (aSession site urlResolver
				halfUrlFromPath:	(aSession site urlResolver halfUrlFor: self ooReference)
				andParms: aSession parms on: aSession).
			(self isEncryptedViewFor: self ooReference on: aSession) 
				ifTrue: [url := self encryptedUrl: url on: aSession] ]
		ifFalse: [url := self urlReference].
	anchor notNil ifTrue: [url := self addAnchorTo: url].
	stream nextPutAll: url.
	^stream contents
"	^self properAmpersand: stream contents " " &amp; instead of mere & in XHTML!! "! !

!WebLink methodsFor: 'private'!
encryptedUrl: aString on: aSession
	"https and port if not default"
	| url port sslPort stream |
	url := aSession site urlResolver urlFromHalfUrl: aString on: aSession.
	('https*' match: url) ifFalse: [url := url copyReplaceAll: 'http' with: 'https'].
	port := aSession site port.
	sslPort := aSession site sslPort.
	port = 80 & sslPort = 443 ifTrue: [^url].
	stream := url readStream.
	url := (stream upTo: $/ ), '//'.
	stream upTo: $/.
	url := url, (port = 80 ifTrue: [stream upTo: $/] ifFalse: [stream upTo: $: ]).
	port  ~= 80 ifTrue: [stream upTo: $/].
	sslPort ~= 443 ifTrue: [url := url, ':', sslPort printString].
	url := url, '/', stream upToEnd.
	url := self addSessionIdTo: url on: aSession.
	^url! !

!WebLink methodsFor: 'private'!
hasTag
	^false  "well .."! !

!WebLink methodsFor: 'private' stamp: 'jm 8/3/2010 10:23'!
isEncryptedViewFor: anObject on: aSession
	"check if we need to make an https link"
	| app view |
	app := anObject aidaWebAppFor: aSession.
	app isNil ifTrue: [^false].
	view := self parms at: 'view' ifAbsent: [app class defaultView].
	^app mustBeEncrypted: view! !

!WebLink methodsFor: 'private' stamp: ' 21/4/07 22:07'!
ooReference
	^ooReference! !

!WebLink methodsFor: 'private' stamp: ' 21/4/07 22:07'!
ooReference: anObject
	"Set the hypertext link to other object. This reference is at HTML generation 
	resolved to urlReference by URLResolver.  ooReference has precedence over 
	urlReference, if both are set."
	ooReference := anObject.
	anObject isVersionedObject ifTrue: [self checkVersionedReference]! !

!WebLink methodsFor: 'private' stamp: ' 21/4/07 22:07'!
parms
	"return a dictionary of parameter:value pairs for a query part of an URL"
	^parms! !

!WebLink methodsFor: 'private'!
printString
	^'aWebLink to: ', (self ooReference notNil 
		ifTrue: ['a', self ooReference printString] ifFalse: [self urlReference]), '
	', (self id notNil ifTrue: [' id: ', self id] ifFalse: ['']), '
	', ((self attributesAt: #class)  notNil ifTrue: [' class: ', (self attributesAt: #class) ] ifFalse: ['']), '
	subelements: ', self elements size printString,
	self printCreationStrings,
	self printOtherStrings! !

!WebLink methodsFor: 'private'!
pureUrlOn: aSession
	"without query and anchor part"
	| url |
	url := self composeURLOn: aSession.
	url ifNil: [^nil].
	url := url upTo: $#. "without anchor"
	url := url upTo: $?. "without queries"
	url last = $/ ifTrue: [url := url copyFrom: 1 to: url size-1]. "without last /, if any"
	^url! !

!WebLink methodsFor: 'private' stamp: ' 21/4/07 22:07'!
urlReference
	^urlReference! !

!WebLink methodsFor: 'private' stamp: ' 21/4/07 22:07'!
urlReference: aString
	"Set the URL hypertext link to the other Web page.  It is used if there is no ooReference 
	to resolve. ooReference has precedence over urlReference when both are set."
	urlReference := aString.! !


!WebLink methodsFor: 'private-streaming'!
addOriginAidaSiteIfNeeded
	"if web request comes from AidaGroup site, add to query part of all generated links 'originAidaSite' 
	parameter too"
	| lastRequest |
	lastRequest := self firstRequestFromStack.
	lastRequest ifNil: [^nil].
	lastRequest isFromOtherAidaSite ifTrue: 
		[self 
			parameter: 'originAidaSite' 
			value: (lastRequest queryAt: 'originAidaSite')]! !

!WebLink methodsFor: 'private-streaming'!
prepareAttributesToStreamOn: aSession
	super prepareAttributesToStreamOn: aSession.
	self addOriginAidaSiteIfNeeded.  "for cross-site access in AidaGroup"
	self href: (self composeURLOn: aSession).! !

!WebLink methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	| url allowed |
	self prepareToHtmlStreamingOn: aSession. 
	allowed := self security notNil ifTrue: [self accessAllowedFor: aSession] ifFalse: [true].
	allowed 	ifTrue: 
		[url := self composeURLOn: aSession.
		url notNil ifTrue:
			[aStream nextPutAll: self ident, '<a'. self streamAttributesTo: aStream for: aSession. 
			aStream nextPutAll: '>'.
			super streamHtmlTo: aStream for: aRequest on: aSession.
			aStream nextPutAll: '</a>'] ]
		ifFalse: [self security = #grayed ifTrue: 
			["print a grayed text with attributes and composite elements"
			self title: self accessNotAllowedText.
			aStream nextPutAll: self ident, '<font'. self streamAttributesTo: aStream for: aSession. 
			aStream nextPutAll: 'color="#c0c0c0">'.
			super streamHtmlTo: aStream for: aRequest on: aSession.
			aStream nextPutAll: '</font>', self  eol ] ].! !


!WebLink methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
href: aString
	"url of that link"
	self attributesAt: #href put: aString! !

!WebLink methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
target: aString
	self attributesAt: #target put: aString! !


!WebLink methodsFor: 'initialize-release'!
initialize
	parms := Dictionary new.
	self security: #grayed.  "if access not allowed, only gray text is shown"! !


!WebLink methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isLink
	^true! !


!WebLink methodsFor: 'events' stamp: ' 21/4/07 22:07'!
onBlur: aJavascriptCode
	"link lost a mouse focus (when in image map)"
	self attributesAt: #onBlur add: aJavascriptCode! !

!WebLink methodsFor: 'events' stamp: ' 21/4/07 22:07'!
onFocus: aJavascriptCode
	"link got maouse focus (when in image map)"
	self attributesAt: #onFocus add: aJavascriptCode! !


!WebLink methodsFor: 'translation'!
prepareForTranslation
	"if link with multilingual text, replace it with in-place input field and add a 'link' with link on right"
	| copied onlyText |
	self isMultilingual ifFalse: [^nil].
	copied := self copy.
	super prepareForTranslation. "of WebText part of link"
	onlyText := self asWebText.  "to avoid to be link anymore"
	copied text:  '<small>link</small>'.
	onlyText addTextSmall: ' ('; add: copied; addTextSmall: ')'.
	self parent replace: self with: onlyText.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebLink class
	instanceVariableNames: ''!

!WebLink class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
linkTo: aLink
	"set hypertext link to some other object or page. If argumet is a String, then this is an url reference, 	else this is object reference, which is resolved to url with help of URLResolver"
	"to add anchor: #(object anchor) !! "
	^self new linkTo: aLink! !

!WebLink class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !

!WebLink class methodsFor: 'instance creation'!
nilLinkText: aString
	"just to click on it and trigger some onClick event"
	^self text: aString linkTo: 'javascript:nic()'
"	^self text: aString addLinkTo: '#'"! !

!WebLink class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
text: aString attributes: anArray linkTo: aLink

	"set hypertext link and text to some other object or page. If argumet is a String, then this is an url reference, else this is object reference, which is resolved to url with help of URLResolver"
	| webLink |
	webLink := self linkTo: aLink.
	webLink text: aString attributes: anArray.
	^webLink

"WebLink text: 'text' linkTo: 'http://www.tris-a.si'"
"WebLink text: 'text' linkTo: Smalltalk"! !

!WebLink class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
text: aString linkTo: aLink

	"set hypertext link and text to some other object or page. If argumet is a String, then this is an url reference, else this is object reference, which is resolved to url with help of URLResolver"
	| webLink |
	webLink := self linkTo: aLink.
	webLink text: aString.
	^webLink

"WebLink text: 'text' linkTo: 'http://www.tris-a.si'"
"WebLink text: 'text' linkTo: Smalltalk"! !

!WebLink class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
text: aString linkTo: aLink parameter: aParmString value: aValueString
	"set hypertext link and text to some other object or page. If argumet is a String, then this is an url reference, else this is object reference, which is resolved to url with help of URLResolver. Add also one  parameter in query part of an URL"
	| webLink |
	webLink := self text: aString linkTo: aLink.
	webLink parameter: aParmString value: aValueString.
	^webLink

"WebLink text: 'text' linkTo: 'http://www.tris-a.si'"
"WebLink text: 'text' linkTo: Smalltalk"! !

!WebLink class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
text: aString linkTo: aLink 
	parameter: a1ParmString value: a1ValueString 
	parameter: a2ParmString value: a2ValueString
	"set hypertext link and text to some other object or page. If argumet is a String, then this is an url reference, else this is object reference, which is resolved to url with help of URLResolver. Add also one  parameter in query part of an URL"
	| webLink |
	webLink := self text: aString linkTo: aLink.
	webLink parameter: a1ParmString value: a1ValueString.
	webLink parameter: a2ParmString value: a2ValueString.
	^webLink! !

!WebLink class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
text: aString linkTo: aLink view: aViewString
	^(self text: aString linkTo: aLink) view: aViewString! !


WebLink subclass: #OtherAidaLink
	instanceVariableNames: 'siteName'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!OtherAidaLink methodsFor: 'private-streaming'!
addOriginAidaSite
	"from which site this request comes, 
	add to url in query part, something like:  http://aidademo.si?originAidaSite=biart "
	self
		parameter: 'originAidaSite'
		value: self site name! !

!OtherAidaLink methodsFor: 'private-streaming'!
changeHrefToFrameAppOn: aSession
	 "for framing an external content this link is pointing to"
	"change url to something like: /frame?fromAidaSite=aidademo;url=/democontent "
	| externalPureUrl frameUrl url |
	externalPureUrl := (self site frameApp instanceFor: aSession)
		urlForLink: self.
	frameUrl := self site urlResolver 
		halfUrlFor: self site frameApp.
	url := frameUrl, '?fromAidaSite=', self siteName, '&url=', externalPureUrl.
	self href: url.! !

!OtherAidaLink methodsFor: 'private-streaming'!
prepareAttributesToStreamOn: aSession
	super prepareAttributesToStreamOn: aSession.
	self changeHrefToFrameAppOn: aSession.  "for framing an external content this link is pointing to"
	self addOriginAidaSite.! !


!OtherAidaLink methodsFor: 'accessing'!
frameApp
	"find and instance of framing App to frame external content into local pages"
	^self site frameApp instance! !

!OtherAidaLink methodsFor: 'accessing'!
siteName
	"name of the other Aida site"
	^siteName! !

!OtherAidaLink methodsFor: 'accessing'!
siteName: aString
	"name of the other Aida site"
	^siteName := aString! !


!OtherAidaLink methodsFor: 'initialize-release'!
initialize
	super initialize.! !


!OtherAidaLink methodsFor: 'private'!
register
	"register this external link to the site's framingApp instance for current session"
	self frameApp 
		registerExternalLink: self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

OtherAidaLink class
	instanceVariableNames: ''!

!OtherAidaLink class methodsFor: 'instance creation'!
siteName: aSitenameString text: aString linkTo: aLink view: aViewString
	| new |
	new := super
		text: aString 
		linkTo: aLink 
		view: aViewString.
	new 
		siteName: aSitenameString;
		register.
	^new! !


WebText subclass: #WebRawText
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!
!WebRawText commentStamp: '<historical>' prior: 0!
WebRawText for plain ascii text, without any encodings!!!


!WebRawText methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	text notNil ifTrue: [aStream nextPutAll: self text].! !


!WebRawText methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
text: aString
	text := aString! !


WebFormElement subclass: #WebTextArea
	instanceVariableNames: 'rows columns'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!

!WebTextArea methodsFor: 'private'!
acceptInputFromValue: aString
	| vlue |
	aString isNil ifTrue: [^nil].  "error?"
	vlue :=  AIDASite convertFromWeb: aString on: self session. "ensure unicode!!"
	vlue := (WebFormElement autoConvertString:  vlue toObject: self value).
	self value: vlue.! !

!WebTextArea methodsFor: 'private'!
autoConvertAndEncodeValue: aValue
	| vlue |
	vlue := WebFormElement autoConvertToString: aValue. "dates, numbers etc."
	vlue := AIDASite encodeQuoteEntitiesIn: vlue.               "char entity encoding just for double quote '' "
	^vlue! !

!WebTextArea methodsFor: 'private'!
autoConvertAndEncodeValue: aValue on: aSession
	| vlue |
	vlue := WebFormElement autoConvertToString: aValue.   "dates, numbers etc."
	vlue := AIDASite encodeQuoteEntitiesIn: vlue.               "char entity encoding just for double quote '' "
	vlue := AIDASite convertToWeb: vlue on: aSession.      "UTF-8 encoding"
	^vlue! !

!WebTextArea methodsFor: 'private'!
streamHtmlTo: aStream for: aRequest on: aSession
	self prepareToHtmlStreamingOn: aSession.
	self scriptBefore notNil ifTrue: 
		[self scriptBefore streamHtmlTo: aStream for: aRequest on: aSession].
	aStream nextPutAll: self ident, '<textarea'.
	self streamAttributesTo: aStream for: aSession.
	aStream nextPutAll: '>'.
	self value notNil ifTrue:
		[aStream nextPutAll:    "encode only quotes as &quot; then UTF8" 
			(self autoConvertAndEncodeValue: self value on: aSession)]. 
	aStream nextPutAll: '</textarea>'.
	self scriptAfter notNil ifTrue: 
		[self scriptAfter streamHtmlTo: aStream for: aRequest on: aSession].! !


!WebTextArea methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject size: aNumber
	^self aspect: aSymbol for: anObject; size: aNumber! !

!WebTextArea methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	super initialize.
	self columns: 5; rows: 5; wrap: 'soft'.! !


!WebTextArea methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
columns: aNumber
	^self attributesAt: #cols put: aNumber printString! !

!WebTextArea methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
rows: aNumber
	^self attributesAt: #rows put: aNumber printString! !

!WebTextArea methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
size: aPoint
	"set the size of area in format colums@rows"
	self columns: aPoint x.
	self rows: aPoint y.! !

!WebTextArea methodsFor: 'attributes' stamp: ' 21/4/07 22:07'!
wrap: aString
	"how to wrap text in area"
	^self attributesAt: #wrap put: aString! !


!WebTextArea methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isTextArea
	^true! !

!WebTextArea methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
shouldIdent
	^false! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebTextArea class
	instanceVariableNames: ''!

!WebTextArea class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject
	^self new aspect: aSymbol for: anObject! !

!WebTextArea class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
aspect: aSymbol for: anObject size: aNumber
	^self new aspect: aSymbol for: anObject size: aNumber! !


WebElement subclass: #WebVideo
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Elements'!
!WebVideo commentStamp: 'janko 8/25/2012 12:10' prior: 0!
WebVideo for HTML5 video tag!


!WebVideo methodsFor: 'attributes'!
autoplay
	"video will start playing as soon as it is ready"
	self attributes at: #autoplay put: true! !

!WebVideo methodsFor: 'attributes'!
controls: aString
	"Specifies that video controls should be displayed (such as a play/pause button etc)."
	self attributes at: #controls put: aString! !

!WebVideo methodsFor: 'attributes'!
height: anInteger
	self attributesAt: #height put: anInteger printString! !

!WebVideo methodsFor: 'attributes'!
loop
	"video will start over again, every time it is finished"
	self attributes at: #loop put: true! !

!WebVideo methodsFor: 'attributes'!
muted
	"audio output of the video should be muted"
	self attributes at: #muted put: true! !

!WebVideo methodsFor: 'attributes'!
poster: anUrlString
	"Specifies an image to be shown while the video is downloading, or until the user hits the play button"
	self attributes at: #poster put: anUrlString! !

!WebVideo methodsFor: 'attributes'!
preload: aSymbol
	"Specifies if and how the author thinks the video should be loaded when the page loads"
	" #auto #metadata or #none "
	self attributes at: #preload put: aSymbol asString! !

!WebVideo methodsFor: 'attributes'!
size: aPoint
	"set the size of a video player in format width@height"
	self width: aPoint x.
	self height: aPoint y.! !

!WebVideo methodsFor: 'attributes'!
src: anUrlString
	"Specifies the URL of the video file"
	" #auto #metadata or #none "
	self attributes at: #src put: anUrlString! !

!WebVideo methodsFor: 'attributes'!
text: aString
	"will be shown if browser does not support video"
	self addText: aString! !

!WebVideo methodsFor: 'attributes'!
width: anInteger
	self attributesAt: #width put: anInteger printString! !


!WebVideo methodsFor: 'private'!
tag
	^#video! !
