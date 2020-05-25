Object subclass: #WebChat
	instanceVariableNames: 'lines announcers'
	classVariableNames: 'Singleton'
	poolDictionaries: ''
	category: 'Aida-Demos'!
!WebChat commentStamp: 'janko 7/8/2011 22:07' prior: 0!
WebChat is domain object for Chat real-time web example!


!WebChat methodsFor: 'adding-removing'!
addLine: aString
	self lines add: aString.
	self removeOlderLines.
	self announceChange! !


!WebChat methodsFor: 'changes'!
announceChange
	self announcers associations do: [:assoc |
		assoc key "app" isActive 
			ifTrue: [assoc value value]
			ifFalse: [self announcers removeKey: assoc key] ] "self cleanup of released application state"! !

!WebChat methodsFor: 'changes'!
whenChangedDo: aBlock on: aWebApplication
	"register a block to be executed when new chat line was entered"
	self announcers at: aWebApplication put: aBlock! !


!WebChat methodsFor: 'private'!
announcers
	"actually blocks to be executed when change occurs. A weak dictionary with an App as key, so that sesion app 
	state cleanup also removes the block from here"
	announcers isNil ifTrue: [self initAnnouncers].
	^announcers! !

!WebChat methodsFor: 'private'!
lines
	lines isNil ifTrue: [self initLines].
	^lines! !

!WebChat methodsFor: 'private'!
removeOlderLines
	(self lines size - 4) timesRepeat: [self lines removeFirst]! !


!WebChat methodsFor: 'initialize-release'!
initAnnouncers
	announcers := "Weak"Dictionary new.! !

!WebChat methodsFor: 'initialize-release'!
initLines
	lines := OrderedCollection new.! !


!WebChat methodsFor: 'accessing'!
last4Lines
	"empty lines in front, if less than 4 lines exist"
	| last |
	last := OrderedCollection new.
	((4 - self lines size) max: 0) timesRepeat: [last add: ''].
	((self lines size - 4) max: 1) to: self lines size do: [:inx | last add: (self lines at: inx)].
	^last! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebChat class
	instanceVariableNames: ''!

!WebChat class methodsFor: 'accessing'!
singleton
	Singleton isNil ifTrue: [Singleton := self new].
	^Singleton! !


WebApplication subclass: #WebChatApp
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Demos'!

!WebChatApp methodsFor: 'views'!
chatElement
	| e le |
	e := WebElement newDiv.
	e addTextH1: 'Multi-user Chat'.
	le := self linesElement.
	e add: le;  addBreak.
	(e addInputFieldAspect: #line for: self) focus.
	(e addButtonText: 'Send')
		onSubmitDo:   "Ajax submit then execute this block"
			[self observee addLine: self line. self line: ''.
			e update].  "update lines and input field"
	self observee whenChangedDo: [le update] on: self.
	^e! !

!WebChatApp methodsFor: 'views'!
linesElement
	| e  |
	e:= WebElement newDiv.
	self observee last4Lines do: [:line |
		e addNbSp: 4; addText: line.
		e addBreak].
	^e! !

!WebChatApp methodsFor: 'views'!
viewMain
	self add: self chatElement! !


!WebChatApp methodsFor: 'accessing'!
line
	line isNil ifTrue: [^''].
	^line! !

!WebChatApp methodsFor: 'accessing'!
line: aString
	line := aString! !


Object subclass: #WebDemo
	instanceVariableNames: 'introduction date input delayedInput field1 field2 editField content submitValue deleted counter'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Demos'!
!WebDemo commentStamp: '<historical>' prior: 0!
WebDemo is a domain model part of few demos, see WebDemoApp for more

!


!WebDemo methodsFor: 'accessing'!
asJson
	"to return some JSON content on http://localhost:8888/demo.json"
	^WebJSON stringify: #(12 'Aida' 45)! !

!WebDemo methodsFor: 'accessing' stamp: 'np 3/15/2009 16:00'!
content
	"for Rich Editor demo"
	content isNil ifTrue: [^''].
	^content! !

!WebDemo methodsFor: 'accessing' stamp: 'np 3/15/2009 16:00'!
content: aString
	"for Rich Editor demo"
	^content := aString! !

!WebDemo methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
date
	date isNil ifTrue: [^''].
	^date! !

!WebDemo methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
date: aString
	date := aString! !

!WebDemo methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
delayedInput
	delayedInput isNil ifTrue: [^''].
	^delayedInput! !

!WebDemo methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
delayedInput: aString
	delayedInput := aString! !

!WebDemo methodsFor: 'accessing'!
delete
	"for a control flow example"
	deleted := true.! !

!WebDemo methodsFor: 'accessing'!
deleted
	"for a control flow example"
	deleted isNil ifTrue: [self resetDelete].
	^deleted! !

!WebDemo methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
editField
	"for in-place editor demo"
	editField isNil ifTrue: [^'Click me to edit!!'].
	^editField! !

!WebDemo methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
editField: anObject
	editField := anObject! !

!WebDemo methodsFor: 'accessing'!
field1
	^field1! !

!WebDemo methodsFor: 'accessing'!
field1: anObject
	field1 := anObject! !

!WebDemo methodsFor: 'accessing'!
field2
	^field2! !

!WebDemo methodsFor: 'accessing'!
field2: anObject
	field2 := anObject! !

!WebDemo methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
input
	input isNil ifTrue: [^''].
	^input! !

!WebDemo methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
input: aString
	input := aString! !

!WebDemo methodsFor: 'accessing'!
preferredUrl
	^'/demos'! !

!WebDemo methodsFor: 'accessing'!
resetDelete
	"for a control flow example"
	deleted := false.! !

!WebDemo methodsFor: 'accessing'!
submitValue
	submitValue isNil ifTrue: [^''].
	^submitValue! !

!WebDemo methodsFor: 'accessing'!
submitValue: aString
	submitValue := aString! !


!WebDemo methodsFor: 'accessing-counter'!
counter
	"for realtime demo"
	counter ifNil: [self counter: 0].
	^counter! !

!WebDemo methodsFor: 'accessing-counter'!
counter: anInteger
	"for realtime demo"
	counter := anInteger.
	self aidaAnnounceChange! !

!WebDemo methodsFor: 'accessing-counter'!
decCounter
	self counter: self counter - 1.! !

!WebDemo methodsFor: 'accessing-counter'!
incCounter
	self counter: self counter + 1.! !


!WebDemo methodsFor: 'introduction'!
defaultIntroductionText

^'<b>Congratulations!!</b><br><br>
You just started your Aida/Web Smalltalk Web Application Server. Here you can look at few simple <a href=/demos?view=grid><b>demos</b></a> (see navigation bar at the left) and on top left there are links to main website, where you can find more information. <br>
<br>
You are encougared to:
<ul>
<li>look at <a href=http://www.aidaweb.si/screenshots><b>Screenshots</b></a> to see, what kind of complex web applications you can build with AIDA/Web,</li>
<li>see <a href=http://www.aidaweb.si/tutorial><b>Tutorial</b></a> to build your first web application,</li>
<li>read other <a href=http://www.aidaweb.si/documentation><b>Documentation</b></a> to learn more (Architecture, Administrator''s guide, Programer''s guide, Ajax, Advanced features, Articles and presentations and more),</li> 
<li>join the <a href=http://www.aidaweb.si/community><b>Community</b></a>.</li>
</ul>
You can also <a href=/admin?view=login><b>login</b></a> with username: <b>admin</b> and password: <b>password</b>. <br><br>

Development team wish you a lot of great moments with Aida/Web !!
'.! !

!WebDemo methodsFor: 'introduction' stamp: 'jm 6/28/2009 11:09'!
introduction
	"introduction text, In instvar to allow changing it by Scribo and other packages at installation"
	introduction isNil ifTrue: [self introduction: self defaultIntroductionText].
	^introduction! !

!WebDemo methodsFor: 'introduction' stamp: 'jm 6/28/2009 11:06'!
introduction: aString
	"introduction text, In instvar to allow changing it by Scribo and other packages at installation"
	introduction := aString.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebDemo class
	instanceVariableNames: ''!

!WebDemo class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
default
	^AIDASite default demo! !


WebApplication subclass: #WebDemoApp
	instanceVariableNames: 'liveImage selectedClasses filename fileContentType fileStream startStamp'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Demos'!
!WebDemoApp commentStamp: '<historical>' prior: 0!
WebDemoApp collects few demonstrations of Aida/Web in action, like examples of Ajax use etc.!


!WebDemoApp methodsFor: 'actions'!
actionAjaxSomething
	"from #ajaxSubmitExample, just to test Ajax action calling"
	Transcript cr; show: 'Ajax submit'! !

!WebDemoApp methodsFor: 'actions' stamp: 'mivsek 3/7/2008 19:17'!
actionEditMembers
	"just for security to work!!"! !

!WebDemoApp methodsFor: 'actions' stamp: ' 21/4/07 22:07'!
actionEditMembersSave
	self redirectToView: #gridSelected! !

!WebDemoApp methodsFor: 'actions' stamp: 'janko 8/1/2008 20:44'!
actionFileUpload
	self fileStream notNil ifTrue:
		[self fileStream close]. "while content were already streamed to the file before"! !

!WebDemoApp methodsFor: 'actions' stamp: 'mivsek 3/7/2008 19:16'!
actionGridSelected
	"just for security to work!!"! !

!WebDemoApp methodsFor: 'actions' stamp: ' 21/4/07 22:07'!
actionGridSelectedEditMembers
	self redirectToView: #editMembers! !

!WebDemoApp methodsFor: 'actions' stamp: ' 21/4/07 22:07'!
actionWebdav
	| stream file |
	file := self webdavExampleFilename asFilename. file exists ifTrue: [file delete].
	[stream :=  file appendStream. stream binary. 
	stream nextPutAll: self observee file asByteArray] 
		ensure: [self observee file: nil. stream close].! !

!WebDemoApp methodsFor: 'actions'!
actionrichEditor
	"just to enable setup of access rights"! !


!WebDemoApp methodsFor: 'actions-control flow'!
actionControlFlow
	"just for access rights setup"! !

!WebDemoApp methodsFor: 'actions-control flow'!
actionControlFlowDelete
	"tree-like control flow in action!! "
	(self ask: (WebDialog newConfirm text: 'Delete?') )
		ifTrue: [self observee delete]! !

!WebDemoApp methodsFor: 'actions-control flow'!
actionControlFlowReset
	self observee resetDelete! !


!WebDemoApp methodsFor: 'views'!
addWebDAVVBScript
	"to open directly from web and not copy a document in local cache"
	self context page scriptBefore: '
 <SCRIPT LANGUAGE=VBScript>
   Function OpenDoc(strLocation)
   Dim objWord
      Set objWord = CreateObject("Word.Application")
      objWord.Visible = true
      objWord.Documents.Open strLocation
   End Function
 </SCRIPT>
'! !

!WebDemoApp methodsFor: 'views'!
introductionElement
	| e |
	e := WebElement new.
	e addText: self observee introduction. "see WebDemo>>defaultIntroductionText for initial content"
	^e! !

!WebDemoApp methodsFor: 'views'!
viewAjax
	| e |
	e := WebElement newDiv. e table width: 1. "100%"
	e cell colspan: 2; addTextH1: 'Simple AJAX examples'. e newRow. 
	e cell addText: 'See the code in method #viewAjax from WebDemoApp'. e newRow.
	e cell width: 0.6; valign: #top; add: self ajaxUpdateTimeExample. 
"	e newCell width: 0.4; valign: #top; add: self ajaxPeriodicUpdaterExample.  " e newRow. 
	self ajaxLiveAndDelayedFieldExampleTo: e. e newRow.
	self ajaxAutocompleteExampleTo: e. e newRow.
	e cell add: self ajaxInPlaceEditorExample. e newRow.
	e cell valign: #top; add: self ajaxPopupWindowExample.
	e newCell valign: #top; add: self ajaxPopupDialogExample. e newRow.
	e cell valign: #top; add: self ajaxSubmitExample. 
	e newCell valign: #top; add: self ajaxValidationExample. e newRow.
	self style pageFrameWith: e title: 'AJAX examples'! !

!WebDemoApp methodsFor: 'views'!
viewCalendar
	| e |
	e := WebElement new.
	e addTextH1: #en->'Date input with Javascript Calendar example'.	 e addBreak.
	e addDateInputFieldAspect: #date for: self observee. e addBreak.
	self style pageFrameWith: e title: 'Calendar example'! !

!WebDemoApp methodsFor: 'views'!
viewControlFlow
	| e |
	e := WebElement new.
	e cell addTextH1: 'Tree-like control flow examples'. e newRow. e newRow.
	e add: self flowConfirmDeleteExample.
	self style pageFrameWith: e title: 'Control flow examples'! !

!WebDemoApp methodsFor: 'views'!
viewFonts
	| e |
	e := WebElement new. e table width: 1. "100%"
	e cell colspan: 2; addTextH1: 'Web Fonts example'. e newRow.
	e cell addText: 'This text is dispayed in Teko-Light font, stored in DefaultWebStyle #tekoLightTff method. '.
	e newRow. e cell align: #center; addBreak; addBreak. 
	self style pageFrameWith: e title: 'Web Fonts example'! !

!WebDemoApp methodsFor: 'views'!
viewImageGallery
	| e |
	e := WebElement new.
	e addText: 'This is a collection of so called <b>method images</b>, that is: images embeded in methods in class <b>WebStyle</b> or its subclasses.'.

	"filetype icons"
	e cell cell addGif: #pdfSmallGif. e cell newCell addText: 'pdfSmallGif'. e cell newRow.
	e cell cell addGif: #pdfMediumGif. e cell newCell addText: 'pdfMediumGif'. e cell newRow.
	e cell cell addGif: #pdfBigGif. e cell newCell addText: 'pdfBigGif'. e cell newRow.
	e cell cell addGif: #wordBigGif. e cell newCell addText: 'wordBigGif'. e cell newRow.
	e cell cell addGif: #excelBigGif. e cell newCell addText: 'excelBigGif'. e cell newRow.
	e cell cell addGif: #xmlBigGif. e cell newCell addText: 'xmlBigGif'. e cell newRow.
	e newCell.

	"filetype icons"
	e cell cell addGif: #arrowBigBlueGif. e cell newCell addText: 'arrowBigBlueGif'. e cell newRow.
	e cell cell addGif: #arrowBigRedGif. e cell newCell addText: 'arrowBigRedGif'. e cell newRow.
	e cell cell addGif: #arrowBigYellowGif. e cell newCell addText: 'arrowBigYellowGif'. e cell newRow.
	e cell cell addGif: #arrowDownBigRedGif. e cell newCell addText: 'arrowDownBigRedGif'. e cell newRow.
	e cell cell addGif: #arrowSmallBlackGif. e cell newCell addText: 'arrowSmallBlackGif'. e cell newRow.
	e cell cell addGif: #arrowTriangleRedGif. e cell newCell addText: 'arrowTriangleRedGif'. e cell newRow.
	e cell cell addGif: #arrowTriangleYellowGif. e cell newCell addText: 'arrowTriangleYellowGif'. e cell newRow.
	e cell cell addGif: #arrowCircledRedGif. e cell newCell addText: 'arrowCircledRedGif'. e cell newRow.
	e cell cell addGif: #arrowCircledGreyGif. e cell newCell addText: 'arrowCircledGreyGif'. e cell newRow.
	e newRow.

	e cell cell addPDFLinkTo: 'http://wiki.eranova.si/e-logis/DOWNLOAD/EAN-standards-roadmap.pdf'.
	e cell newCell addText: 'addPDFLinkTo: '.
	self style pageFrameWith: e title: 'Gallery of embedded images'! !

!WebDemoApp methodsFor: 'views'!
viewJquery
	| e |
	e := WebElement new. e table width: 1. "100%"
	e cell colspan: 2; addTextH1: 'Simple jQuery examples'. e newRow. 
	self jQueryAutocompleteExampleTo: e. e newRow.
	self jQueryEditableExampleTo: e. e newRow.
	self style pageFrameWith: e title: 'AJAX examples'! !

!WebDemoApp methodsFor: 'views'!
viewLiveImage
	| e |
	self liveImage isNil ifTrue: [self liveImage: WebGraph new].  "subclass WebLiveImage"
	e := WebElement new.
	e addTextH1: 'Live image example'. e addBreak.
	e addImage: self liveImage.
	self style pageFrameWith: e title: 'Live image example'! !

!WebDemoApp methodsFor: 'views'!
viewMain
	| e |
	e := WebElement new.
	e addTextH1: 'Introduction'. e addBreak.
	e add: self introductionElement.
	self style pageFrameWith: e title: 'Aida/Web - Introduction'! !

!WebDemoApp methodsFor: 'views'!
viewRichEditor
	| e |
	e := WebElement new.
	e addTextH1: 'JavaScript HTML WYSIWYG Editor example'.	 e addBreak.
	e addRichEditorAspect: #content for: self observee size: 50@10. e addBreak.
	e addButtonText: 'Save'. e addBreak.
	e addTextH2: 'Result: '. e addBreak.
	e addText: self observee content.
	self style pageFrameWith: e title: 'Rich Editor example'! !

!WebDemoApp methodsFor: 'views'!
viewWebdav
	| e link |
	"link := '/', self webdavExampleFilename."
	link := self site uriPattern first currentUrl, '/', self webdavExampleFilename.
	self addWebDAVVBScript. "IE only!!"
	link := 'javascript:OpenDoc(''', link, ''')'. "for IE browser only!!"
	e := WebElement new. self title: 'WebDAV publishing example'.
	e cell addTextH2: self title. e newRow. e cell addNbSp. e newRow.
	e cell addText: '1. Upload  MS Word document: '.
	e cell add: (WebFileInputField aspect: #file filenameAspect: #filename 
		contentTypeAspect: #fileContentType forObject: self observee). 
	e cell addSpace; addButtonText: 'Upload'. e newRow.
	e cell addText: '2. Now open document from: '. e cell addLinkTo: link text: 'here'. e newRow.
	e cell addText: '3. Save document'. e newRow.
	e cell addText: '4. Repeat from 2 to see if changes got saved'. e newRow.
	self style pageFrameWith: e title: self title.! !

!WebDemoApp methodsFor: 'views' stamp: 'janko 10/28/2011 15:28'!
viewWidgets
	| e |
	e := WebElement new. e table width: 1. "100%"
	e cell colspan: 2; addTextH1: 'Widget examples'. e newRow. 
	e cell addText: 'See the code in method #viewWidgets from WebDemoApp'. e newRow.
	e cell width: 0.6; valign: #top; add: self widgetEmbeddedExample.  e newRow.
	e cell add: self widgetComposedExample.  e newRow.
	e cell add: self widgetPopupExample. 
	self style pageFrameWith: e title: 'Widget examples'! !


!WebDemoApp methodsFor: 'views-ajax'!
ajaxAutocompleteExampleTo: e
	| field1 field2 result |
	e cell colspan: 2; addTextH4: 'Example: Autocomplete field with data from server'. e newRow.
	e cell valign: #top; addTextSmall: 'Type first chars of month names to select: '; addBreak.
	field1 := WebAutocompleteField 
		aspect: #field1 for: self observee choicesAspect: #monthsStarting: for: self.
	e cell add: field1.
	e newCell addTextSmall: 'Again, the choice will be posted instantly: '. e cell addBreak.
	result := self ajaxAutocompleteResult.
	field2 := WebAutocompleteField 
		aspect: #field2 for: self observee choicesAspect: #monthsStarting: for: self.
	field2 afterPostAndUpdate: result.
	e cell add: field2. e cell addBreak.
	e cell add: result.
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxAutocompleteResult
	| e |
	e := WebElement new.
	e addTextBold: self observee field2.
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxDelayedFieldElement
	| e |
	e := WebElement newSpan.
	e addTextBold: self observee delayedInput.
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxInPlaceEditorExample
	| e |
	e := WebElement new.
	e addTextH4: 'Example: In-place editor example'.
	e addText: 'Click text below to edit it'. e addBreak.
"	e addInPlaceEditableTextAspect: #editField for: self observee." "that's shorter way"
	e add: ((WebInPlaceEditableText aspect: #editField for: self observee)
		triggerElement: ((WebImage gif: #buttonEditGif) title: 'Edit this text') ). "image to enter edit"
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxLiveAndDelayedFieldExample
	| e element1 input1 element2 input2 |
	e := WebElement new. e table width: 1. "100%"
	e cell colspan: 2; addTextH4: 'Example: Live and Delayed input send to server'. e newRow.
	element1 := self ajaxLiveFieldElement.
	input1 := WebInputField aspect: #input for: self observee.
	input1 onKeyUpPostAndUpdate: element1.
	e cell width: 0.5; add: input1; addBreak; add: element1.
	element2 := self ajaxDelayedFieldElement.
	input2 := WebDelayedField aspect: #delayedInput for: self observee.
	input2 afterPostUpdate: element2.
	e newCell add: input2; addBreak; add: element2.
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxLiveAndDelayedFieldExampleTo: e
	| element1 input1 element2 input2 |
	e cell colspan: 2; addTextH4: 'Example: Live and Delayed input send to server'. e newRow.
	element1 := self ajaxLiveFieldElement.
	input1 := WebInputField aspect: #input for: self observee.
	input1 onKeyUpPostAndUpdate: element1.
	e cell width: 0.5; add: input1; addBreak; add: element1.
	element2 := self ajaxDelayedFieldElement.
	input2 := WebDelayedField aspect: #delayedInput for: self observee.
	input2 onChangePostAndUpdate: element2.
	e newCell add: input2; addBreak; add: element2.
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxLiveFieldElement
	| e |
	e := WebElement newSpan.
	e addTextBold: self observee input.
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxPeriodicUpdaterExample
	| e element |
	e := WebElement new.
	e addTextH4: 'Periodicaly update element from server'.
	element := self ajaxTimeElement.
	element updateEverySeconds: 1.
	e add: element.
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxPopupDialogExample
	| e |
	e := WebElement new.
	e addTextH4: 'Popup info dialog'.
	(e addNilLinkText: 'Click me for popup')
		onClickPopup: (WebDialog newInfo text: 'Just hello!!').
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxPopupWindowExample
	| e |
	e := WebElement new.
	e addTextH4: 'Example: Popup window with Ajax content from server'.
	(e addNilLinkText: 'Click me for popup')
		onClickPopup: self ajaxPopupWindowLive.
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxPopupWindowLive
	| e |
	e := WebElement newDiv.
	self context event isClassicalRequest ifTrue: [^e]. "because this method is also called while building 
		 										    main page in #ajaxPopupWindowExample"
	e addTextH1: 'Popup window with live content from server'. e addBreak.
	e addText: 'Timestamp now: ',  SpTimestamp now printString; addBreak; addBreak.
	(e addNilLinkText: 'popup one more')
		onClickPopup: self ajaxPopupWindowLive2 thenUpdate: e. "to refresh time"
	e addText: ' | '.
	e addCloseLinkText: 'close'.   "closing link, via Ajax closes also the window and context on the server"
	^e! !

!WebDemoApp methodsFor: 'views-ajax' stamp: 'janko 11/1/2011 13:07'!
ajaxPopupWindowLive2
	| e |
	e := WebElement new.
	e addText: SpTimestamp now printString; addBreak.
	e addCloseLinkText: 'close'.   "closing link"
	e addText: ' or '.
	(e addButtonText: 'Close')
		onSubmitClose.
	^e! !

!WebDemoApp methodsFor: 'views-ajax' stamp: 'janko 10/26/2011 22:41'!
ajaxSubmitExample
	| e |
	e := WebElement new.
	e addTextH4: 'Example: Ajax form submit to the server'.
	e addInputFieldAspect: #submitValue for: self observee. e addSpace.
	(e addButtonText: 'Ajax submit' action: #something) "will call also call #actionAjaxSomething"
		onSubmitUpdate: e.
	e addBreak; addTextBold: self observee submitValue.
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxTimeElement
	| e |
	e := WebElement newSpan.
	e style: '{background-color: #eee }'.
	e addTextBold: SpDate today shortPrintSloString, ' ', SpTimestamp now asTime printSecSloString. 
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxUpdateTimeExample
	| e element |
	e := WebElement new.
	e addTextH4: 'Example: Update element from server'.
	element := self ajaxTimeElement.
	e add: element; addBreak.
	(e addNilLinkText: 'Click me to update')
		onClickUpdate: element.
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxValidationExample
	| e field |
	e := WebElement new. e table width: 220.
	e cell colspan:2; addTextH4: 'Instant validation example'. e newRow.
	e cell width: 160; addText: 'Today''s year is: '.
	field := e cell addInputFieldAspect: #year for: self size: 4.
	field 
		onChangePost;
		validIfTrue: [:value | value isEmpty"temporary!!" or: [value asInteger = SpDate today year]];
		errorText: 'Wrong!!'.
	e newCell add: field errorElement. "this element will show error text in red near input field, if year is wrong"
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
ajaxVerificationExample
	| e field |
	e := WebElement new.
	e addTextH4: 'Example: instant verification example'.
	e addText: 'Today''s year is: '. e addBreak.
	field := e addInputFieldAspect: #year for: self.
	field 
		onChangePost;
		validIfTrue: [:value | value asInteger = Date today year];
		errorText: 'Wrong!!'.
	e add: field errorElement. "this element will show error text in red near input field, if year is wrong"
	^e! !

!WebDemoApp methodsFor: 'views-ajax'!
monthsStarting: aString
	"as choicesAspect for autocompletion demo"
	"WebDemoApp new monthsStarting: 'j' "
	| months |
	months := 
		#('januar' 'prosinec' 'sijec^anj' 'January' 
		   'februar', 'svec^an' 'veljac^a' 'February'
		   'marec', 'sus^ec' 'oz^ujak' 'Mart'
		   'april', 'mali traven' 'travanj' 'April'
		   'maj', 'veliki traven' 'svibanj' 'May'
		   'junij', 'roz^nik' 'lipanj' 'June'
		   'julij', 'mali srpen' 'srpanj' 'July'
		   'avgust', 'veliki srpen' 'kolovoz' 'August'
		   'september', 'kimavec' 'rujan' 'September'
		   'oktober', 'vinotok' 'listopad' 'October'
		   'november', 'listopad' 'studeni' 'November'
		   'december', 'gruden' 'prosinac' 'December').
	^months select: [:each | aString, '*' match: each]! !


!WebDemoApp methodsFor: 'views-grid'!
classesEditElement
	| e |
	e := WebElement new.
	e addButtonText: 'Save' action: #save.
	e add: (WebGrid new
		columnNames: #('' 'Class name');
		columnAspects: #(nil #name);
		sortOn: 2;
		collection: WebApplication allWebAppClasses;
		checkboxesColumn: 1 collection: self selectedClasses;
		yourself).
	^e! !

!WebDemoApp methodsFor: 'views-grid'!
classesSelectedElement
	| e |
	e := WebElement new.
	e addButtonText: 'Select classes' action: #editMembers.
	e add: (WebGrid new
		columnNames: #('nr.' 'Class name');
		columnAspects: #(nil #name);
		setNumbering; sortOn: 2;
		collection: self selectedClasses;
		yourself).
	^e! !

!WebDemoApp methodsFor: 'views-grid'!
classesTableElement
	| e |
	e := WebElement new.
	e add: (WebGrid new
		columnNames: #('nr.' 'Class name');
		columnFilters: #(nil true);
		columnAspects: #(nil #name);
		setNumbering; sortOn: 2;
		collection: WebApplication allWebAppClasses;
		yourself).
	^e! !

!WebDemoApp methodsFor: 'views-grid'!
gridTabsElement
 	^ViewTabs new
		addView: #grid description: 'All App classes';
		addView: #gridSelected description: 'Selected App classes';
		yourself.! !

!WebDemoApp methodsFor: 'views-grid'!
viewEditMembers
	| e |
	e := WebElement new.
	e cell addTextH1: 'WebGrid, tabs, live filtering, Ajax sorting, checkboxes...'. e newRow.
	e cell add: self classesEditElement.
	self style pageFrameWith: e title: 'Grid example'! !

!WebDemoApp methodsFor: 'views-grid'!
viewGrid
	| e |
	e := WebElement new.
	e cell addTextH1: 'WebGrid, tabs, live filtering, Ajax sorting, checkboxes...'. e newRow.
	e cell addText: 'See the code in method #viewGrid from WebDemoApp'. e newRow.
	e cell add: self gridTabsElement. e newRow.
	e cell add: self classesTableElement.
	self style pageFrameWith: e title: 'Grid example'! !

!WebDemoApp methodsFor: 'views-grid'!
viewGridSelected
	| e |
	e := WebElement new.
	e cell addTextH1: 'WebGrid, tabs, live filtering, Ajax sorting, checkboxes...'. e newRow.
	e cell add: self gridTabsElement. e newRow.
	e cell add: self classesSelectedElement.
	self style pageFrameWith: e title: 'Grid example'! !


!WebDemoApp methodsFor: 'accessing' stamp: 'janko 8/1/2008 21:13'!
fileContentType
	^fileContentType! !

!WebDemoApp methodsFor: 'accessing' stamp: 'janko 8/1/2008 21:14'!
fileContentType: aString
	fileContentType := aString! !

!WebDemoApp methodsFor: 'accessing' stamp: 'janko 8/1/2008 20:09'!
fileStream
	"for file upload"
	^fileStream! !

!WebDemoApp methodsFor: 'accessing' stamp: 'janko 8/1/2008 20:09'!
fileStream: aFileStream
	"for file upload"
	fileStream := aFileStream! !

!WebDemoApp methodsFor: 'accessing' stamp: 'janko 8/1/2008 21:12'!
filename
	filename isNil ifTrue: [^''].
	^filename! !

!WebDemoApp methodsFor: 'accessing' stamp: 'janko 8/1/2008 21:13'!
filename: aString
	filename := aString! !

!WebDemoApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
liveImage
	^liveImage! !

!WebDemoApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
liveImage: aWebLiveImage
	liveImage := aWebLiveImage! !

!WebDemoApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
selectedClasses
	selectedClasses isNil ifTrue: [self selectedClasses: OrderedCollection new].
	^selectedClasses! !

!WebDemoApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
selectedClasses: anObject
	selectedClasses := anObject! !

!WebDemoApp methodsFor: 'accessing' stamp: 'janko 8/1/2008 20:12'!
setStartStamp
	"start timestamp of some action"
	^startStamp := SpTimestamp now! !

!WebDemoApp methodsFor: 'accessing' stamp: 'janko 8/1/2008 20:12'!
startStamp
	"start timestamp of some action"
	^startStamp! !

!WebDemoApp methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
webdavExampleFilename
	^'aida-webdav-example.doc'.! !

!WebDemoApp methodsFor: 'accessing'!
year
	"used in #ajaxValidationExample"
	year isNil ifTrue: [^''].
	^year! !

!WebDemoApp methodsFor: 'accessing'!
year: aString
	"used in #ajaxValidationExample"
	year := aString! !


!WebDemoApp methodsFor: 'views-control flow'!
flowConfirmDeleteExample
	"see #actionControlFlowDelete for actual control flow example"
	| e |
	e := WebElement new.
	e addTextH4: 'Example: Delete with confirmation dialog'.
	self observee deleted not
		ifTrue: 
			[(e addButtonText: 'Delete' action: #delete) "then see #actionControlFlowDelete !! "
			"	onSubmitUpdate: e"]  "later!!"
		ifFalse: 
			[e addTextBold: 'Deleted!!'; addSpace; addButtonText: 'Reset delete' action: #reset].
	^e! !


!WebDemoApp methodsFor: 'views-jquery'!
jQueryAutocompleteExampleTo: e
	| field1 |
	e cell colspan: 2; addTextH4: 'Example: jQuery Autocomplete field with data from server'. e newRow.
	e cell valign: #top; addTextSmall: 'Type first chars of month names to select: '; addBreak.
	field1 := WebAutocomplete2Field 
		aspect: #field1 for: self observee choicesAspect: #monthsStarting: for: self.
	e cell add: field1.
	^e! !

!WebDemoApp methodsFor: 'views-jquery'!
jQueryEditableExampleTo: e
	e cell colspan: 2; addTextH4: 'Example: jQuery in-place editable field with data from server'. e newRow.
	e addText: 'Click text below to edit it'. e addBreak.
"	e addInPlaceEditableTextAspect: #editField for: self observee." "that's shorter way"
	e add: ((WebInPlaceEditable2Text aspect: #editField for: self observee)
		triggerElement: ((WebImage gif: #buttonEditGif) title: 'Edit this text') ). "image to enter edit"
	^e! !


!WebDemoApp methodsFor: 'views-javascript'!
jsShowAlertExample
	| e |
	e := WebElement new.
	e addTextH4: 'Example 1: onClick event on some text'. e addBreak.
	e add: 
		((WebText text: 'click on me to show alert!!') onClick: 'alert(''This is an alert!!'')'). 
	^e.! !

!WebDemoApp methodsFor: 'views-javascript'!
jsShowHideToggleExample
	| e element |
	e := WebElement new.
	e addTextH4: 'Example 2: show/hide an element with a click'.
	element := WebElement new addText: 'This element is now shown'; style: '{background-color: #ccc }'.
	element hide.  "hide from the start"
	e 
		add: ((WebText text: 'show') onClickShow: element); addSpace;
		add: ((WebText text: 'hide') onClickHide: element); addSpace;
		add: ((WebText text: 'toggle') onClickToggle: element); addSpace;
	 	add: element.
	^e! !

!WebDemoApp methodsFor: 'views-javascript'!
jsShowWithMouseOverExample
	| e element |
	e := WebElement new.
	e addTextH4: 'Example 3: show/hide an element with mouse over'.
	element := WebElement new addText: 'This element is now shown'; style: '{background-color: #ccc }'.
	element hide.  "hide from the start"
	e 
		add: ((WebText text: 'mouse over to show') 
			onMouseOverShow: element; onMouseOutHide: element); addSpace;
	 	add: element.
	^e! !

!WebDemoApp methodsFor: 'views-javascript'!
viewJavascript
	| e |
	e := WebElement new.
	e cell addTextH1: 'Simple Javascript examples'. e newRow. e newRow.
	e cell addText: 'See the code in method #viewJavascript from WebDemoApp'. e newRow.
	e cell add: self jsShowAlertExample. e newRow.
	e cell add: self jsShowHideToggleExample. e newRow.
	e cell add: self jsShowWithMouseOverExample. e newRow. 
	self style pageFrameWith: e title: 'Javascript examples'! !


!WebDemoApp methodsFor: 'views-realtime'!
realtimeCounterElement
	| e |
	e := WebElement newSpan.
	e style: 'font-size: 40px'.
	e addText: self observee counter printString. 
	e updateWhenChanged: self observee.
	^e! !

!WebDemoApp methodsFor: 'views-realtime'!
viewRealtime
	| e |
	self enableRealtime. 
	e := WebElement new. 
	e table width: 1. "100%"
	e cell colspan: 2; addTextH1: 'Realtime (WebSockets enabled) example'. 
	e newRow.
	e cell addText: 'Open this example in two different browsers (or private windows) or two tabs, press the buttons and see changes in both browsers, windows or tabs. '.
	e cell addText: 'See the code in method #viewRealtime from WebDemoApp.'.
	e newRow. e cell align: #center; addBreak; addBreak. 

	e cell 
		add: self realtimeCounterElement.
	e cell 
		addBreak; addBreak.
	(e cell addButtonText: ' Decrement ')
		noSubmit; 
		onClickDo: 
			[self observee decCounter].
	(e cell addSpace; addButtonText: ' Increment ')
		noSubmit; 
		onClickDo: 
			[self observee incCounter].
	self style 
		pageFrameWith: e 
		title: 'Realtime example'! !


!WebDemoApp methodsFor: 'views-upload'!
uploadReportAndResetElement
	"report if anything then delete file and reset variables"
	| e elapsed fileSize |
	e := WebElement new.
	self filename isEmpty ifTrue: [^e].
	elapsed := SpTimestamp now asSeconds - self startStamp asSeconds.
	fileSize := (SpFilename named: self filename) fileSize.
	e addText: 'uploaded file: ', self filename, ' size: ', fileSize printDotString, ' bytes in ', 
		elapsed printDotString, ' seconds (', ((fileSize/(elapsed max: 1)) rounded) printDotString, 'bytes/s)'.
	(SpFilename named: self filename) delete.
	self filename: ''. self fileStream: nil.
	^e! !

!WebDemoApp methodsFor: 'views-upload'!
viewFileUpload
	| e field fname |
	e := WebElement new.
	e cell addTextH1: 'File upload example'. e newRow. e newRow.
	field := WebFileInputField 
		beforeStreamingDo: [:datum |  "datum is actually MIME part"
			fname := datum filename trimBlanks. 
			fname notEmpty ifTrue:
				[self fileStream: (SpFilename named: fname) writeStream. "will be closed in action method"
				self fileStream binary.
				datum writeStream: self fileStream.
				self setStartStamp ] ]    "for measuring upload time"
		filenameAspect: #filename 
		contentTypeAspect: #fileContentType 
		forObject: self.
	e cell add: field; addButtonText: 'Upload'. e newRow.
	e cell add: self uploadReportAndResetElement. "also deletes uploaded file!!"
	self style pageFrameWith: e title: 'File upload example'! !


!WebDemoApp methodsFor: 'views-widgets'!
widgetComposedExample
	| e |
	e := WebElement new.
	e addTextH4: 'Example: Widget composed of two independent reusable widgets'.
	e add: WebDemoWidget2 new.
	^e! !

!WebDemoApp methodsFor: 'views-widgets' stamp: 'janko 10/26/2011 22:41'!
widgetEmbeddedExample
	| e |
	e := WebElement new.
	e addTextH4: 'Example: Widget embeded on the page'.
	e add: WebDemoWidget new.
	^e! !

!WebDemoApp methodsFor: 'views-widgets'!
widgetPopupExample
	| e |
	e := WebElement newDiv.
	e addTextH4: 'Example: Widget popup example'.
	e addTextSmall: 'Updated: ', Time now printString. e addBreak.
	(e addNilLinkText: 'Click to popup')
		onClickPopup: WebDemoWidget new.
	e addText: ' | '.
	(e addNilLinkText: 'Popup then update')
		onClickPopup: WebDemoWidget new thenUpdate: e.
	e addText: ' | '.
	(e addNilLinkText: 'Click to popup composed widget')
		onClickPopup: WebDemoWidget2 new.

	^e! !


WebWidget subclass: #WebDemoWidget
	instanceVariableNames: 'username password result'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Demos'!
!WebDemoWidget commentStamp: 'janko 11/21/2011 17:42' prior: 0!
WebDemoWidget2 to show a hierarchy of widgets. This widget is namelly composed of two WebDemoWidget!


!WebDemoWidget methodsFor: 'views'!
build
	| field |
	self clear.
	self 
		addTextSmall: 'Widget created: ', Time now printString;
		addBreak;
		addText: 'Password check'. 
	self cell valign: #top; 
		addText: 'Username: '.
	field := (self newCell addInputFieldAspect: #username for: self)
		onChangePost;
		validIfTrue: [:value |
			self site securityManager existUserNamed: value];
		errorText: 'This username does not exist!!'.
	self cell 
		addBreak; 
		add: field errorElement. 
	self newRow. 
	self cell addText: 'Password: '.
	self newCell 
		addInputFieldAspect: #password for: self.
	self newRow.
	(self addButtonText: 'Check')
		onSubmitDo: 
			[self checkAndSetResult. 
			self update];
		onSubmitClose.  "just for popups, ignored elsewhere"
	(self addSpace; addNilLinkText: 'Refresh time')
		onClickDo: [self update].
	self 
		addSpace; 
		addTextBold: self result! !


!WebDemoWidget methodsFor: 'actions'!
checkAndSetResult
	"check username and password"
	(self site securityManager 
		existUserNamed: self username 
		withPassword: self password)
			ifTrue: [self result: 'Correct!!']
			ifFalse: [self result: 'Wrong!!']! !


!WebDemoWidget methodsFor: 'accessing' stamp: 'janko 10/27/2011 14:06'!
password
	^ password! !

!WebDemoWidget methodsFor: 'accessing' stamp: 'janko 10/27/2011 14:06'!
password: aString
	password := aString! !

!WebDemoWidget methodsFor: 'accessing' stamp: 'janko 10/27/2011 19:20'!
result
	result ifNil: [^''].
	^ result
! !

!WebDemoWidget methodsFor: 'accessing' stamp: 'janko 10/27/2011 19:20'!
result: aString
	result := aString
! !

!WebDemoWidget methodsFor: 'accessing' stamp: 'janko 10/27/2011 14:05'!
username
	^ username! !

!WebDemoWidget methodsFor: 'accessing' stamp: 'janko 10/27/2011 14:06'!
username: aString
	username := aString! !


WebWidget subclass: #WebDemoWidget2
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Demos'!
!WebDemoWidget2 commentStamp: 'janko 10/28/2011 13:34' prior: 0!
WebDemoWidget2 to show a hierarchy of widgets. This widget is namelly composed of two WebDemoWidget!


!WebDemoWidget2 methodsFor: 'views'!
build
	"compose a widget from two subwidgets"
	self clear.
	self cell add: WebDemoWidget new.
	self newCell add: WebDemoWidget new.! !
