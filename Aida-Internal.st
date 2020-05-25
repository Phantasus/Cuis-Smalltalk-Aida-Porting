Object subclass: #AidaDependencies
	instanceVariableNames: 'parent dependencies'
	classVariableNames: 'Instances'
	poolDictionaries: ''
	category: 'Aida-Internal'!

!AidaDependencies methodsFor: 'dependencies'!
aidaChangeAnnouncedOf: anObject
	"notify all dependencies of change of anObject"
	(self dependencies 
		at: anObject
		ifAbsent: [^nil])
			aidaChangeAnnouncedOf: anObject! !

!AidaDependencies methodsFor: 'dependencies' stamp: 'jmivsek 5/24/2020 18:13'!
depend: aWebElement on: anObject in: aWebContext
 	"web element is dependent of anObject's changes"
	| contexts elements |
	contexts := self dependencies
		at: anObject
		ifAbsentPut: ["Ephemeron"Dictionary new].
	elements := contexts
		at: aWebContext
		ifAbsentPut: ["Ephemeron"Dictionary new].
	elements
		at: aWebElement
		put: aWebElement! !

!AidaDependencies methodsFor: 'dependencies'!
removeContext: aWebContext
	"to clean EphemeronDictionaries in advance, before GC."
	self dependencies keysAndValuesDo:[:obj :objDict |
		objDict 
			removeKey: aWebContext
			ifAbsent: [] ]! !

!AidaDependencies methodsFor: 'dependencies'!
removeElement: aWebElement
	"to clean EphemeronDictionaries in advance, before GC. It also removes nonactive contexts"
	self dependencies keysAndValuesDo:[:obj :objDict |
		objDict keys do: [:ctx |
			ctx isActive ifFalse: [objDict removeKey: ctx] ].
		objDict keysAndValuesDo: [:ctx :ctxDict |
			(ctxDict includesKey: aWebElement) ifTrue: 
				[ctxDict removeKey: aWebElement.
				^true] 
		]
	]! !


!AidaDependencies methodsFor: 'accessing'!
allContexts
	"search for all execution contexts registered in this dependency registry. Duplicates included!!"
	"AIDASite default dependencies allContexts"
	^self dependencies keys
		inject: OrderedCollection new
		into: [:col :object | 
			col addAll: (self dependencies at: object) keys.
			col]! !

!AidaDependencies methodsFor: 'accessing'!
allElements
	"search for all web elements registered to update in this dependency registry. Duplicates included!!"
	"AIDASite default dependencies allElements"
	^self dependencies keys
		inject: OrderedCollection new
		into: [:col :object | 
			col addAll: ((self dependencies at: object) keys
				inject: OrderedCollection new
				into: [:col2 :ctx | 
					col2 addAll: ((self dependencies at: object) at: ctx) keys.
					col2]).
			col]! !

!AidaDependencies methodsFor: 'accessing'!
dependencies
	"an EmpeheronDictioanary of dependencies (or hierarchy of further EmpehronDictionaries)"
	dependencies 
		ifNil: [self initDependencies].
	^dependencies! !

!AidaDependencies methodsFor: 'accessing'!
parent
	^parent! !

!AidaDependencies methodsFor: 'accessing'!
site
	^self parent! !


!AidaDependencies methodsFor: 'initialize-release'!
clear
	self initDependencies! !

!AidaDependencies methodsFor: 'initialize-release' stamp: 'jmivsek 5/24/2020 13:30'!
initDependencies
	"an EphemeronDictionary of dependencies (or hierarchy of further EphemeronDictionaries)"
	"Note for Squeak: no Ephemeros usported, use normal Dictionary"
	"Squeak specific"
	dependencies := "Ephemeron"Dictionary new! !


!AidaDependencies methodsFor: 'private'!
parent: anAIDASite
	parent := anAIDASite! !

!AidaDependencies methodsFor: 'private'!
printContextsString
	| notActive |
	notActive := self allContexts 
		select: [:ctx | ctx isActive not].
	^notActive isEmpty 
		ifTrue: ['']
		ifFalse: [', nonactive: ', notActive size printString]! !

!AidaDependencies methodsFor: 'private'!
printElementsString
	| notActive |
	notActive := self allElements
		select: [:ctx | ctx isActive not].
	^notActive isEmpty 
		ifTrue: ['']
		ifFalse: [', nonactive: ', notActive size printString]! !

!AidaDependencies methodsFor: 'private'!
printString
	^'anAidaDependency on ', self site name, '
	objects: ', self dependencies keys size printString, '
	contexts: ', self allContexts size printString, self printContextsString, '
	elements: ', self allElements size printString, self printElementsString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AidaDependencies class
	instanceVariableNames: ''!

!AidaDependencies class methodsFor: 'announcements'!
aidaChangeAnnouncedOf: anObject
	"notify all dependencies of change of anObject"
	self instances keys do:
		[:each | each aidaChangeAnnouncedOf: anObject]! !


!AidaDependencies class methodsFor: 'accessing' stamp: 'jmivsek 5/24/2020 17:45'!
initInstances
	Instances := "Ephemeron"Dictionary new! !

!AidaDependencies class methodsFor: 'accessing'!
instances
	"current instances of AIDASite"
	Instances ifNil: [self initInstances].
	^Instances! !


!AidaDependencies class methodsFor: 'instance creation'!
newOn: anAIDASite
	| new |
	new := super new
		parent: anAIDASite.
	self instances 
		at: new
		put: new.
	^new! !


Object subclass: #AidaModelAdaptor
	instanceVariableNames: 'subject aspect index format buffer changed validationBlock'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!AidaModelAdaptor commentStamp: '<historical>' prior: 0!
AIDAModelAdaptor adapts the web form elements to the domain model. Main goal of adaptor is to adapt model object accessors to just #value/#value: methods, used by form elements

Example: aPerson name/name: is adapted to value/value: by a subclass AspectAdaptor, #name as an aspect of aPerson!


!AidaModelAdaptor methodsFor: 'accessing'!
aspect

	^aspect! !

!AidaModelAdaptor methodsFor: 'accessing'!
changed
	"is value changed?"
	changed ifNil: [self resetChanged].
	^changed! !

!AidaModelAdaptor methodsFor: 'accessing'!
convertedAndEncodedValue
	self format = #iso ifTrue: 	"Date should be ISO formated: yyyy-mm-dd"
		[^self value year printString, '-', 
			(self value monthIndex < 10 ifTrue: ['0'] ifFalse: ['']), self value monthIndex printString, '-',
			(self value dayOfMonth < 10 ifTrue: ['0'] ifFalse: ['']), self value dayOfMonth printString].
	^self value! !

!AidaModelAdaptor methodsFor: 'accessing'!
format
	"format of the value. Dep≈°ends of value type. If nil, autoformating is used"
	"For Date can be #iso #sloDate #shortSloDate"
	^format! !

!AidaModelAdaptor methodsFor: 'accessing'!
format: aSymbol
	"format of the value. Dep≈°ends of value type. If nil, autoformating is used"
	"For Date can be #iso #sloDate #shortSloDate"
	format := aSymbol! !

!AidaModelAdaptor methodsFor: 'accessing'!
index

	^index! !

!AidaModelAdaptor methodsFor: 'accessing'!
subject
	"subject of adapting, a domain object"
	^subject! !

!AidaModelAdaptor methodsFor: 'accessing'!
value
	self isAspectAdaptor ifTrue: [^self subject perform: self aspect].
	self isIndexAdaptor ifTrue: [^self subject at: self index]! !

!AidaModelAdaptor methodsFor: 'accessing'!
value: aValue
	"value is first put in buffer. To the domain model is written with #save, but only if 
	pass the validation with #isValid"
	self buffer: aValue.
	self setChanged! !


!AidaModelAdaptor methodsFor: 'private'!
aspect: aSymbol

	aspect := aSymbol! !

!AidaModelAdaptor methodsFor: 'private'!
buffer
	"a buffered value before saved to the domain object"
	"an already converted value before it is saved to the domain object"
	^buffer! !

!AidaModelAdaptor methodsFor: 'private'!
buffer: aValue
	"an already converted value before it is saved to the domain object"
	buffer := aValue! !

!AidaModelAdaptor methodsFor: 'private'!
index: aNumber
	index := aNumber! !

!AidaModelAdaptor methodsFor: 'private'!
resetChanged
	changed := false! !

!AidaModelAdaptor methodsFor: 'private'!
sanitize
	"sanitize input from <script> and similar input to prevent entering XSS and similar malicious code"
	| in out |
	in := ReadStream on: self buffer.
	out := WriteStream on: String new.
	[in atEnd] whileFalse:
		[in peek = $< 
			ifTrue: [out nextPutAll: (self sanitizeTagFrom: in)]
			ifFalse: [out nextPut: in next] ].
	self buffer: out contents! !

!AidaModelAdaptor methodsFor: 'private'!
sanitizeTagFrom: aStream
	"sanitize tag by just skipping 'script' if found "
	| out inx|
	out := WriteStream on: String new.
	[aStream atEnd or: [aStream peek = $> ]] whileFalse:
		[out nextPut: aStream next.
		aStream peek = $< ifTrue: [out nextPutAll: (self sanitizeTagFrom: aStream)]]. "deal with tags within tags"
	aStream peek = $> ifTrue: [out nextPut: aStream next].
	^('*script*' match: out contents)
		ifTrue: 
			[inx := out contents asLowercase indexOfSubCollection: 'script' startingAt: 1.
			(out contents copyFrom: 1 to: inx-1), (out contents copyFrom: inx+6 to: out contents size)]
		ifFalse: [out contents].! !

!AidaModelAdaptor methodsFor: 'private'!
saveValue: aValue
	self isAspectAdaptor ifTrue: [self subject perform: (self aspect asString, ':') asSymbol with: aValue].
	self isIndexAdaptor ifTrue: [self subject at: self index put: aValue]! !

!AidaModelAdaptor methodsFor: 'private'!
setChanged
	changed := true! !

!AidaModelAdaptor methodsFor: 'private'!
subject: anObject
	"subject of adapting, a domain object"
	subject := anObject! !


!AidaModelAdaptor methodsFor: 'initialize-release'!
initDefaultValidationBlock
	self validationBlock: [:value | true ] "just validate it"! !


!AidaModelAdaptor methodsFor: 'testing'!
isAspectAdaptor
	^self aspect notNil! !

!AidaModelAdaptor methodsFor: 'testing'!
isEmpty
	"nothing entered in this field"
	^self buffer isNil or: [self buffer trimBlanks isEmpty]! !

!AidaModelAdaptor methodsFor: 'testing'!
isIndexAdaptor
	^self index notNil! !


!AidaModelAdaptor methodsFor: 'validation'!
isValid
	"bufered value is valid according to the rule in validationBlock"
	self changed ifFalse: [^true]. "value not changed, nothing to validate!!"
	self validationBlock isNil ifTrue: [^true]. "leave this instvar nil until really needed, to avoid garbage"
	^self validationBlock value: self buffer! !

!AidaModelAdaptor methodsFor: 'validation'!
validationBlock
	"block must return true to validate a value, which is argument of that block"
	"example block: [:value | value class = Date ] "
"	validationBlock isNil ifTrue: [self initDefaultValidationBlock]. " "leave nil to avoid unecessary garbage"
	^validationBlock! !

!AidaModelAdaptor methodsFor: 'validation'!
validationBlock: aBlock
	"block must return true to validate a value, which is argument of that block"
	"example block: [:value | value class = Date ] "
	validationBlock := aBlock! !


!AidaModelAdaptor methodsFor: 'saving'!
save
	"save the value to the domain model. Save only if validated, othewise raise an exception"
	self changed ifFalse: [^nil].
	self isValid ifFalse: [self error: 'value validation failed!!'].
	self saveValue: self buffer.
	self resetChanged.
	self buffer: nil! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AidaModelAdaptor class
	instanceVariableNames: ''!

!AidaModelAdaptor class methodsFor: 'instance creation'!
forAspect: aSymbol
	^super new aspect: aSymbol! !

!AidaModelAdaptor class methodsFor: 'instance creation'!
forIndex: aNumber
	^super new index: aNumber! !


AidaModelAdaptor subclass: #AidaModelNullAdaptor
	instanceVariableNames: 'value'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!AidaModelNullAdaptor commentStamp: '<historical>' prior: 0!
AIDAModelNullAdaptor adapts actually nothing just holds the value. This is a default adaptor in form element if no one is set. Usefull for preparing forms in advance, without connecting to domain model.

Example adding a hidden field:

	e add: (WebInputField new setHidden; name: 'MyHiddenField'; value: '12345')!


!AidaModelNullAdaptor methodsFor: 'validation'!
isValid
	^true! !


!AidaModelNullAdaptor methodsFor: 'saving'!
save
	"nothing to save here"! !


!AidaModelNullAdaptor methodsFor: 'accessing'!
value
	^value notNil ifTrue: [value] ifFalse: ['']! !

!AidaModelNullAdaptor methodsFor: 'accessing'!
value: aString
	value := aString! !


Object subclass: #AidaMutex
	instanceVariableNames: 'semaphore owner'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!AidaMutex commentStamp: 'janko 3/19/2012 13:08' prior: 0!
AidaMutex provides proper support for critical sections.

Only one process at a time can execute code within its #critical: method. Other processes attempting to call #critical: will block until the first process leaves the critical section. The process that owns the mutex (the one currently in the critical section), however, may call #critical: repeatedly without fear of blocking.

The process currently inside the critical section can be terminated by calling #terminateOwner. This will result in the process being unwound and the critical section being freed.!


!AidaMutex methodsFor: 'critical sections'!
critical: aBlock
	| process |
	process := Processor activeProcess.
	^ (owner == process)
		ifTrue: [ aBlock value ]
		ifFalse: [
			semaphore critical: [
				owner := process.
				aBlock ensure: [ owner := nil ] ] ]! !

!AidaMutex methodsFor: 'critical sections'!
terminateOwner
	owner notNil ifTrue: [owner terminate]! !


!AidaMutex methodsFor: 'initialize-release'!
initialize
	super initialize.
	semaphore := Semaphore forMutualExclusion! !


!AidaMutex methodsFor: 'accessing'!
owner
	^ owner! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AidaMutex class
	instanceVariableNames: ''!

!AidaMutex class methodsFor: 'instance creation'!
new
	^super basicNew
		initialize! !


Object subclass: #DefaultAuthenticator
	instanceVariableNames: 'site'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!DefaultAuthenticator commentStamp: '<historical>' prior: 0!
DefaultAuthenticator authentificates the user during login by username and password, which are stored locally in site's security manager, by contrast to for instance the LDAPAuthenticator, which asks the LDAP directory server to authenticate this user.
!


!DefaultAuthenticator methodsFor: 'authenticating'!
authenticateUserNamed: anUsernameString withPassword: aPasswordString
	^(self site securityManager userNamed: anUsernameString withPassword: aPasswordString)
		notNil.! !

!DefaultAuthenticator methodsFor: 'authenticating'!
endAuthentication
	"indicate that authetication is ended"! !

!DefaultAuthenticator methodsFor: 'authenticating'!
existUserNamed: anUsernameString
	^(self site securityManager userNamed: anUsernameString)
		notNil.! !

!DefaultAuthenticator methodsFor: 'authenticating'!
startAuthentication
	"indicate that authetication will soon start"! !


!DefaultAuthenticator methodsFor: 'accessing'!
site
	^site! !

!DefaultAuthenticator methodsFor: 'accessing'!
userNamed: anUsernameString
	^self site securityManager userNamed: anUsernameString! !


!DefaultAuthenticator methodsFor: 'private'!
site: anAIDASite
	site := anAIDASite! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

DefaultAuthenticator class
	instanceVariableNames: ''!

!DefaultAuthenticator class methodsFor: 'instance creation'!
newOn: anAIDASite
	^super new
		site: anAIDASite! !


Object subclass: #DocLink
	instanceVariableNames: 'title url object'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!DocLink commentStamp: '<historical>' prior: 0!
DocLink is used in WebClipboard to cut/copy/paste references to resources on the web. (example: documents to paste as references on other documents, in Scribo)
!


!DocLink methodsFor: 'converting' stamp: ' 21/4/07 22:07'!
asWebLink
	^WebLink text: self title linkTo: self url! !


!DocLink methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	^self! !


!DocLink methodsFor: 'private' stamp: ' 21/4/07 22:07'!
migrateToUnicode
	"DocLink allInstances do: [:each | each migrateToUnicode]"
	title notNil ifTrue: [title := title ensureUnicodeSloveneChars]! !

!DocLink methodsFor: 'private' stamp: ' 21/4/07 22:07'!
printString
	^'a Doclink
		title:  ', (self title notNil ifTrue: [self title] ifFalse: ['']), '
		url: ', (self url notNil ifTrue: [self url] ifFalse: ['']), '
		object: ', self object printString! !


!DocLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
object
	^object! !

!DocLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
object: anObject
	object := anObject! !

!DocLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
title
	^title! !

!DocLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
title: aString
	title := aString! !

!DocLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
url
	^url! !

!DocLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
url: aString
	url := aString! !

!DocLink methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
uuid
	^self hash printString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

DocLink class
	instanceVariableNames: ''!

!DocLink class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	"Answer a newly created and initialized instance."

	^super new initialize! !


Object subclass: #FileProxy
	instanceVariableNames: 'site filename timestamps content contentType size caching codepage elements bodyTagIndex imgTagIndexes linkTagIndexes servletTagIndexes'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!

!FileProxy methodsFor: 'parsing' stamp: ' 21/4/07 22:07'!
absoluteTagFrom: aTagString urlStart: anURLString

	""

	| tag url |
	tag := (aTagString copyReplaceAll: '\' with: '/').
	((tag copyFrom: 1 to: 3) = '../')
		ifFalse:  "not relative to parent directory"
			[^((tag copyUpTo: $"), '"', anURLString, 
				(tag copyFrom: ((tag indexOf: $") + 1) to: tag size))]
		ifTrue:
			[tag := tag readStream upTo: $/; upToEnd.
			url := anURLString copyFrom: 1 to: (anURLString lastIndexOf: $/).
			^self absoluteTagFrom: tag urlStart: url].! !

!FileProxy methodsFor: 'parsing' stamp: 'mivsek 1/10/2008 19:16'!
makeAbsoluteImgTags
	"if image url's are relative, make them absolute. Also do it for a body tag (background image). 
	Url is constructed from a imageServer address from WebServer settings, and from filename with 	homeDirectory substracted. "
	| fname urlStart index tag bodyTag |
	fname := (self filename asString) copyReplaceAll: (self site homeDirectory) with: ''.
	fname := fname copyFrom: 1 to: (fname lastIndexOf: (AIDASite slash at: 1)).
	urlStart := 'http://', self site host, (fname copyReplaceAll: '\' with: '/').
	self imgTagIndexes do: [:inx  | tag := self elements at: inx.
		('*http://*' match: tag) ifFalse:    "not an absolute source url"
			[self elements at: inx put: (self absoluteTagFrom: tag urlStart: urlStart)] ].
	self bodyTagIndex notNil ifTrue:
		[bodyTag := self elements at: bodyTagIndex.
		(('*background*' match:  bodyTag) and: [('*http://*' match:  bodyTag) not]) 
			ifTrue: 
				[index := bodyTag asLowercase findString: 'background' startingAt: 1.
				index := bodyTag findString: '"' startingAt: index.
				(( bodyTag at: index+1) = $#) ifTrue: [^self]. "only colored background"
				self elements at: bodyTagIndex put:
					((bodyTag copyFrom: 1 to: index), urlStart, 
						(bodyTag copyFrom: index + 1 to: bodyTag size)) ] ].! !

!FileProxy methodsFor: 'parsing' stamp: ' 21/8/07 09:38'!
prepareHTMLPage
	"decompose content into elements (texts and tags)"
	| stream tag index |
	self clearElements. self clearImgTagIndexes. 
	self clearLinkTagIndexes. self clearServletTagIndexes.
	stream := ReadStream on: self content.
	index := 1.
	[stream atEnd] whileFalse:
		[self elements add: (stream upTo: $<). index := index + 1.
		tag := ('<', (stream upTo: $>), '>').
		('<aida*' match: tag) ifTrue: [self servletTagIndexes add: index].
		('*img*' match: tag) ifTrue: [self imgTagIndexes add: index].
		('*href*' match: tag) 
			ifTrue: [self linkTagIndexes add: index]
			ifFalse: 
				[(('*body*' match: tag) and: [('*/body*' match: tag) not])
					ifTrue: [self bodyTagIndex: index]].
		self elements add: tag. index := index + 1.
		].! !

!FileProxy methodsFor: 'parsing'!
prepareHtmlPage
	"decompose content into elements (texts and tags)"
	| stream tag index |
	self clearElements. self clearImgTagIndexes. 
	self clearLinkTagIndexes. self clearServletTagIndexes.
	stream := ReadStream on: self content.
	index := 1.
	[stream atEnd] whileFalse:
		[self elements add: (stream upTo: $<). index := index + 1.
		tag := ('<', (stream upTo: $>), '>').
		('<aida*' match: tag) ifTrue: [self servletTagIndexes add: index].
		('*img*' match: tag) ifTrue: [self imgTagIndexes add: index].
		('*href*' match: tag) 
			ifTrue: [self linkTagIndexes add: index]
			ifFalse: 
				[(('*body*' match: tag) and: [('*/body*' match: tag) not])
					ifTrue: [self bodyTagIndex: index]].
		self elements add: tag. index := index + 1.
		].! !


!FileProxy methodsFor: 'accessing-timestamps' stamp: 'mivsek 8/22/2007 16:02'!
accessedTimestamp
	^self timestamps at: #accessed ifAbsent: [nil]! !

!FileProxy methodsFor: 'accessing-timestamps' stamp: 'mivsek 8/22/2007 16:02'!
createdTimestamp
	^self timestamps at: #created ifAbsent: [nil]! !

!FileProxy methodsFor: 'accessing-timestamps' stamp: 'mivsek 8/22/2007 17:10'!
expiresTimestamp
	"for broswer: after 6 hours by default. It is good to reload from time to time 
	if changes were made "
	^SpTimestamp fromSeconds: (SpTimestamp now asSeconds + (6 * 3600))! !

!FileProxy methodsFor: 'accessing-timestamps' stamp: 'mivsek 8/22/2007 16:01'!
modifiedTimestamp
	^self timestamps at: #modified ifAbsent: [nil]! !


!FileProxy methodsFor: 'accessing'!
aidaContentType
	"MIME type of original content. 'unknown' if not known"
	contentType isNil ifTrue: [self aidaContentType: 'unknown'].
	^contentType.! !

!FileProxy methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
codepage
	" #iso2 by default"
	codepage isNil ifTrue: [self codepage: #'iso-8859-2'].
	^codepage.! !

!FileProxy methodsFor: 'accessing' stamp: 'jm 2/16/2011 23:43'!
content
	content isNil ifTrue: 
		[(self aidaContentType ~= 'text/html') 
			ifTrue: [self refreshContent] 
			ifFalse: [self content: ''] ].
	^content! !

!FileProxy methodsFor: 'accessing'!
filename
	| separator |
	separator := SpEnvironment onUnix ifTrue: ['/'] ifFalse: ['\'].
	(filename isKindOf: SpFilename) ifTrue: [self filename: filename].
	filename isNil ifTrue: [^''].
	SpEnvironment onUnix   "needed in case of migration to other OS"
		ifTrue: [(filename includes: $\ ) ifTrue: 
			[filename := filename copyReplaceAll: '\' with: '/'] ]
		ifFalse: [(filename includes: $/ ) ifTrue: 
			[filename := filename copyReplaceAll: '/' with: '\'] ].
	^SpFilename named:
		(self site homeDirectory, 
			(filename 
				copyReplaceAll: (self site homeDirectory copyReplaceAll: '.', separator with: '')
				with: ''))! !

!FileProxy methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
put: aString
	"replace self with contents in aString from PUT request"
	self content: aString.
	self writeToFile! !

!FileProxy methodsFor: 'accessing' stamp: 'jm 2/16/2011 23:33'!
resetCaching
	"don't cahce this file,except if it is smallter than "
	caching := false! !

!FileProxy methodsFor: 'accessing' stamp: 'jm 2/16/2011 23:33'!
setCaching
	"this file should always be cached, regardless of size"
	caching := true! !

!FileProxy methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
site
	^site! !

!FileProxy methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
size
	"size of content"
	size isNil ifTrue: [self setSize].
	^size! !

!FileProxy methodsFor: 'accessing' stamp: 'jm 2/16/2011 23:34'!
sizeToCache
	"file size below which files are always cached"
	^(5 * 1024) "bytes" "5KB"! !


!FileProxy methodsFor: 'private'!
aidaContentType: aMIMEString
	"MIME type of original content"
	contentType := aMIMEString.! !

!FileProxy methodsFor: 'private' stamp: ' 21/4/07 22:07'!
codepage: aSymbol
	codepage := aSymbol.! !

!FileProxy methodsFor: 'private' stamp: ' 21/4/07 22:07'!
content: aString
	content := aString.! !

!FileProxy methodsFor: 'private' stamp: ' 21/4/07 22:07'!
detectCodepage: aString
	" "
	| win1250 iso2 sevenBit above127 |
	win1250 := 0.
	aString do: [:ch | (#(200 154 138 158 142) includes: ch asInteger) ifTrue: [win1250 := win1250+1] ].
	iso2 := 0.
	aString do: [:ch | (#(200 185 169 190 174) includes: ch asInteger) ifTrue: [iso2 := iso2+1] ].
	sevenBit := 0.
"	aString do: [:ch | (#(94 123 91 96 64) includes: ch asInteger) ifTrue: [sevenBit := sevenBit+1] ]."
	above127 := 0.
	aString do: [:ch | ch asInteger > 127 ifTrue: [above127 := above127+1] ].
	above127 = 0 
		ifTrue: [sevenBit ~= 0 ifTrue: [^#'7bit'] ifFalse: [^#csz] ]
		ifFalse: [iso2 > win1250 ifTrue: [^#'iso-8859-2'] ifFalse: [^#'win-1250'] ].! !

!FileProxy methodsFor: 'private' stamp: 'np 10/20/2008 13:53'!
elements

	"all elements (texts and tags) of a html page"

	elements isNil ifTrue: 
		[self clearElements.
"		(self contentType = 'text/html') ifTrue: [self refreshContent] "].
	^elements! !

!FileProxy methodsFor: 'private' stamp: 'janko 3/22/2008 13:20'!
filename: aFilename
	filename := aFilename asString.
	self site notNil ifTrue: 
		[filename := filename copyReplaceAll: self site homeDirectory with: ''].! !

!FileProxy methodsFor: 'private'!
printString
	^('aFileProxy for: ', self filename asString)! !

!FileProxy methodsFor: 'private' stamp: 'mivsek 8/22/2007 16:34'!
refreshTimestamps
	self timestamps at: #created put: self filename createdTimestamp.
	self timestamps at: #modified put: self filename modifiedTimestamp.! !

!FileProxy methodsFor: 'private'!
removeYourself
	"remove from url resolver and elsewhere"
	self releaseContent.
	self site urlResolver removeObject: self.
	self fileStillExist ifTrue: [self filename delete]! !

!FileProxy methodsFor: 'private' stamp: ' 21/8/07 09:38'!
setSize
	"size of content in bytes"
	(self elements notEmpty)
		ifTrue: [self size: (self elements inject: 0 into: [:sum : e | sum + e size]) ]
		ifFalse: [self size: self content size]! !

!FileProxy methodsFor: 'private' stamp: ' 21/4/07 22:07'!
site: anAIDASite
	site := anAIDASite.! !

!FileProxy methodsFor: 'private' stamp: ' 21/8/07 09:38'!
size: anInteger
	size := anInteger! !

!FileProxy methodsFor: 'private' stamp: ' 21/4/07 22:07'!
timestamps
	timestamps isNil ifTrue: [self timestamps: Dictionary new.].
	^timestamps! !

!FileProxy methodsFor: 'private' stamp: ' 21/4/07 22:07'!
timestamps: aDictionary
	" a dictionary with a DateAndTime at: 
	#accessed #modified #statusChanged #created"
	timestamps := aDictionary.! !

!FileProxy methodsFor: 'private' stamp: ' 21/4/07 22:07'!
writeToFile
	| stream |
	[stream := self filename writeStream. stream binary.
	stream nextPutAll: self content]
		ensure: [stream close].
	self refreshTimestamps.! !


!FileProxy methodsFor: 'testing'!
aidaIsRespondingNeverStreamed
	^false! !

!FileProxy methodsFor: 'testing' stamp: 'janko 4/25/2012 10:58'!
aidaIsRespondingStreamed
	"should we stream that file directly to TCP socket or not?"
	self content notNil ifTrue: [^false].  "cached content is sent faster without streaming"
	self aidaContentType = 'text/html' ifTrue: [^false]. "pure HTML files also not"
	^true! !

!FileProxy methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
fileStillExist
	^self filename exists! !

!FileProxy methodsFor: 'testing' stamp: 'mivsek 8/22/2007 17:07'!
hasFileChanged
	"check if original file changed since last visit"
	^self modifiedTimestamp ~= self filename modifiedTimestamp.! !

!FileProxy methodsFor: 'testing' stamp: 'jm 2/16/2011 23:31'!
isCaching
	"should this file be always cached?"
	caching isNil ifTrue: [self resetCaching].
	^caching! !

!FileProxy methodsFor: 'testing' stamp: 'jm 2/16/2011 23:30'!
isToBeCached
	"cache this file or not?"
	^self isCaching or: [self size < self sizeToCache]! !

!FileProxy methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebElement
	^false! !

!FileProxy methodsFor: 'testing' stamp: ' 21/8/07 09:38'!
isWebPage
	^true "not actually, but let pretend it is"! !

!FileProxy methodsFor: 'testing' stamp: 'mivsek 2/10/2008 15:53'!
sizeAboveMark

	"test if content is above specified size"
	^self size > (5 * 1024) "bytes" "5KB"! !


!FileProxy methodsFor: 'private-streaming'!
aidaPresenterFor: aRequest on: aSession 
	self fileStillExist ifFalse: [self removeYourself. ^WebPage new].
	(self content isNil and: [self aidaContentType = 'text/html' or: [self isToBeCached] ]) 
		ifTrue: [^self refreshContent]. 
	self hasFileChanged ifTrue: 
		[self refreshContent.
		self indexContent].
	^self! !

!FileProxy methodsFor: 'private-streaming' stamp: 'janko 3/19/2012 14:24'!
streamFileToResponse: aHTTPStreamedResponse
	| stream | 
	[stream := self filename asFilename readStream binary. 
	[stream atEnd] whileFalse: [aHTTPStreamedResponse nextPut: stream next] ] 
		ensure: [stream close]! !

!FileProxy methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	"stream content to a response"
	| response |
	response := aRequest streamedResponse.
	response length: self size. "to stream on HTTP/1.0 too, because chunking is not allowed"
	self site addResponseHeadersTo: response forPage: self on: aSession.
	[self content notNil "cached"
		ifTrue: [response nextPutAll: (AIDASite properArray: self content)]
		ifFalse: [self streamFileToResponse: response].
	response close]
		on: Error
		do: [:ex | "ignore" ].
	self isToBeCached ifFalse: [self releaseContent].  "for large files"

" 
	self contentType = 'text/html'
		ifTrue:
			[index := 1.
			self elements do: [:each | 
				each == self elements last ifTrue: [^self]. 
				(self servletTagIndexes includes: index) 
					ifTrue: [self printServlet: index on: aStream forSession: aSession]
					ifFalse: [aStream nextPutAll: 
						(AIDASite convertToWeb: each on: aSession)].
				index := index + 1 ] ]
		ifFalse: 
			[aStream nextPutAll: self content asByteString].
"! !


!FileProxy methodsFor: 'servlets'!
argumentsFrom: aMessageString

	^Array new: 0 "for now!! "! !

!FileProxy methodsFor: 'servlets'!
methodFrom: aMessageString

	^aMessageString asSymbol "for now!! "! !

!FileProxy methodsFor: 'servlets'!
servletPerform: aMessageString on: aWebApp

	| method |
	method := (self methodFrom: aMessageString).
	(aWebApp class canUnderstand: method) ifFalse: [^nil].
	^aWebApp
		perform: method
		withArguments: (self argumentsFrom: aMessageString).! !


!FileProxy methodsFor: 'accessing-tags' stamp: ' 21/4/07 22:07'!
bodyTagIndex
	"index of element, which represent body tag in original html file"
	^bodyTagIndex! !

!FileProxy methodsFor: 'accessing-tags' stamp: ' 21/4/07 22:07'!
bodyTagIndex: anInteger
	"set the index of element, which represent body tag in original html file"
	bodyTagIndex := anInteger.! !

!FileProxy methodsFor: 'accessing-tags' stamp: ' 21/4/07 22:07'!
clearImgTagIndexes
	imgTagIndexes := OrderedCollection new.! !

!FileProxy methodsFor: 'accessing-tags' stamp: ' 21/4/07 22:07'!
clearLinkTagIndexes
	linkTagIndexes := OrderedCollection new.! !

!FileProxy methodsFor: 'accessing-tags' stamp: ' 21/4/07 22:07'!
clearServletTagIndexes
	servletTagIndexes := OrderedCollection new.! !

!FileProxy methodsFor: 'accessing-tags' stamp: ' 21/4/07 22:07'!
imgTagIndexes
	"indexes of elements, which represent image tags in original html file"
	imgTagIndexes isNil ifTrue: [self clearImgTagIndexes].
	^imgTagIndexes! !

!FileProxy methodsFor: 'accessing-tags' stamp: ' 21/4/07 22:07'!
linkTagIndexes
	"indexes of elements, which represent link tags in original html file"
	linkTagIndexes isNil ifTrue: [self clearLinkTagIndexes].
	^linkTagIndexes! !

!FileProxy methodsFor: 'accessing-tags' stamp: ' 21/4/07 22:07'!
servletTagIndexes
	"indexes of elements, which represent servlet in original html file"
	servletTagIndexes isNil ifTrue: [self clearServletTagIndexes].
	^servletTagIndexes! !


!FileProxy methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
clearElements
	elements := OrderedCollection new.! !

!FileProxy methodsFor: 'initialize-release'!
from: aString
	| file relFilename |
	self releaseContent. "if any from before"
	file := SpFilename named: aString. file exists ifFalse: [^nil].
	relFilename := (file asString copyReplaceAll: self site homeDirectory with: '').
	self filename: (relFilename isEmpty ifTrue: ['\'] ifFalse: [relFilename]).
	self refreshTimestamps.
	self aidaContentType: (self site mimeMap typeForExtension: file extension).
	self size: file fileSize.
	self aidaContentType = 'text/html' 
		ifTrue:
			[self content: file contentsOfEntireFile.
			self codepage: #utf8. "(self detectCodepage: self content)."
"			self content: (AIDASite convert: self content fromCodepage: self codepage). "
			self setSize
			"self prepareHTMLPage. self makeAbsoluteImgTags. self content: nil"]
		ifFalse: 
			[self isToBeCached ifTrue:  "otherwise we will stream directly"
				[| stream | 
				[stream := file readStream binary. self content: stream contents] ensure: [stream close] ] ]! !

!FileProxy methodsFor: 'initialize-release' stamp: 'np 10/20/2008 13:44'!
refreshContent
	self releaseContent. "in case we switch from cached to non cached because of size change"
	self from: self filename asString.! !

!FileProxy methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
releaseContent
	"release origContent and elements to save memory"
	content := nil.
	elements := nil.! !


!FileProxy methodsFor: 'indexing'!
indexContent
	"index text in server global index"
	self aidaContentType = 'text/html' ifTrue: [self site index indexObject: self]! !

!FileProxy methodsFor: 'indexing' stamp: ' 21/4/07 22:07'!
indexText
	"pure text, without tags, for indexer"
	| stream bodyStart element text |
	bodyStart := (1 to: self elements size) 
		detect: [:index | '<BODY*' match: (self elements at: index)] ifNone: [1].
	stream := WriteStream on: String new.
	bodyStart + 1 to: self elements size do:  [:index | 
		element := self elements at: index.
		(element notEmpty and: [element first ~= $<]) ifTrue: [stream nextPutAll: element] ].
	text := stream contents "copyReplaceAll: WebElement new eol with: ' '". 
	text := text copyReplaceAll: '&nbsp;' with: ' '.
	^text! !

!FileProxy methodsFor: 'indexing' stamp: ' 21/4/07 22:07'!
indexTitle
	"find title, if noone, then return url"
	1 to: self elements size do: [:index |
		('<TITLE*' match: (self elements at: index)) ifTrue: [^self elements at: index+1] ].
	^self site urlResolver halfUrlFor: self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

FileProxy class
	instanceVariableNames: ''!

!FileProxy class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
from: aFilenameString onSite: aSite
	"read a file and make a HTML proxy of it. Return nil, if file does not exist or cannot be opened. 
	Also record a server for which you make a proxy"
	| proxy |
	proxy := self new site: aSite; from: aFilenameString.
	proxy indexContent.
	^proxy! !


Object subclass: #MIMEMap
	instanceVariableNames: 'mimeTypes fileExtensions'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!MIMEMap commentStamp: '<historical>' prior: 0!
MIMEMap maps content types to file extensions and back. Example: 'image.jpg' is of content type 'image/jpeg'
!


!MIMEMap methodsFor: 'adding-removing' stamp: ' 21/4/07 22:07'!
addType: aTypeString andExtension: anExtensionString
	| exts |
	exts := self mimeTypes at: aTypeString ifAbsentPut: [OrderedCollection new].
	(exts includes: anExtensionString) ifFalse: [exts add: anExtensionString].
	self fileExtensions at: anExtensionString ifAbsentPut: [aTypeString].! !

!MIMEMap methodsFor: 'adding-removing' stamp: ' 21/4/07 22:07'!
removeType: aTypeString andExtension: anExtensionString
	| exts |
	exts := self mimeTypes at: aTypeString ifAbsent: [OrderedCollection new].
	(exts includes: anExtensionString) ifTrue: [exts remove: anExtensionString].
	exts isEmpty ifTrue: [self mimeTypes removeKey: aTypeString ifAbsent: [] ].
	self fileExtensions removeKey: anExtensionString ifAbsent: [].! !


!MIMEMap methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
extensionForType: aString
	"only first one if more than one ext exist for this mime type"
	| exts string |
	string := aString = 'image/pjpeg' ifTrue: ['image/jpeg'] ifFalse: [aString]. "wierd IE problem"
	string := aString = 'image/x-png' ifTrue: ['image/png'] ifFalse: [string]. "wierd IE problem"
	exts := self mimeTypes at: string asLowercase ifAbsent: [#()].
	^exts notEmpty ifTrue: [exts first] ifFalse: [nil]

"MIMEMap new extensionForType: 'image/jpeg'"! !

!MIMEMap methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
extensionsForType: aString
	^self mimeTypes at: aString asLowercase ifAbsent: [#()].

"MIMEMap new extensionsForType: 'image/jpeg'"! !

!MIMEMap methodsFor: 'accessing'!
iconForType: aString
	"a name of icon to represent this content type, from WebStyle imgs-filetype icons"
	aString isNil ifTrue: [^#unknownSmallPng].
	'text/plain' = aString ifTrue: [^#txtSmallPng].
	'text/xml' = aString ifTrue: [^#xmlSmallPng].
	'application/pdf' = aString ifTrue: [^#pdfSmallPng].
	'application/msword' = aString ifTrue: [^#wordSmallPng].
	'application/rtf' = aString ifTrue: [^#wordSmallPng].
	'application/excel' = aString ifTrue: [^#excelSmallPng]. "depreceated!!"
	'application/vnd.ms-excel' = aString ifTrue: [^#excelSmallPng].
	'application/powerpoint' = aString ifTrue: [^#powerpointSmallPng].   "depreceated!!"
	'application/vnd.ms-powerpoint' = aString ifTrue: [^#powerpointSmallPng].
	'application/zip' = aString ifTrue: [^#zipSmallPng].
	('image/*' match: aString) ifTrue: [^#imageSmallPng].
	('audio/*' match: aString) ifTrue: [^#multimediaSmallPng].
	('video/*' match: aString) ifTrue: [^#multimediaSmallPng].
	^#unknownSmallPng

"MIMEMap new iconForType: 'image/jpeg'"! !

!MIMEMap methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
typeForExtension: aString
	| ext |
	ext := aString asLowercase copyWithout: $. .
	^self fileExtensions at: ext ifAbsent: [nil].

"MIMEMap new typeForExtension: 'jpg'"! !


!MIMEMap methodsFor: 'private' stamp: ' 21/4/07 22:07'!
fileExtensions
	fileExtensions isNil ifTrue: [self initFileExtensions].
	^fileExtensions! !

!MIMEMap methodsFor: 'private' stamp: ' 21/4/07 22:07'!
mimeTypes
	mimeTypes isNil ifTrue: [self initMimeTypes].
	^mimeTypes! !


!MIMEMap methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initFileExtensions
	fileExtensions := Dictionary new.! !

!MIMEMap methodsFor: 'initialize-release'!
initFromApacheMimeTypes
	"see class method. Only mime types, which have some extension defined, are set!! "
	"MIMEMap allInstances do: [:each | each initFromApacheMimeTypes] "
	| collection |
	self initMimeTypes; initFileExtensions.
	collection := self class arrayFromApacheMimeTypes.
	collection do: [:col | 
		2 to: col size do: [:inx | self addType: col first andExtension: (col at: inx)] ]! !

!MIMEMap methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initMimeTypes
	mimeTypes := Dictionary new.! !

!MIMEMap methodsFor: 'initialize-release'!
initialize
	"MIMEMap allInstances do: [:each | each initialize]"
	self initFromApacheMimeTypes! !


!MIMEMap methodsFor: 'testing'!
isTextType: aTypeString
	"is this content type text based?"
	^self class arrayFromTextMimeTypes includes: aTypeString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MIMEMap class
	instanceVariableNames: ''!

!MIMEMap class methodsFor: 'accessing'!
apacheMimeTypes
	"from /etc/apache2/mime.types after Apache v2.x is installed. docx, xlsx added manually"
	"Dont forget to initialize all MIMEMaps after any change here!!"
	"MIMEMap allInstances do: [:each | each initialize]"
	"# This file controls what Internet media types are sent to the client for
# given file extension(s).  Sending the correct media type to the client
# is important so they know how to handle the content of the file.
# For more information about Internet media types, please read 
# RFC 2045, 2046, 2047, 2048, and 2077.  The Internet media type
# registry is at <ftp://ftp.iana.org/assignments/media-types/>.

# MIME type			Extension"

	^'application/andrew-inset ez
application/chemtool cht
application/dicom dcm
application/docbook+xml docbook
application/ecmascript ecma
application/flash-video flv
application/illustrator ai
application/javascript
application/mac-binhex40
application/mathematica nb
application/msword doc docx
application/octet-stream bin
application/oda oda
application/ogg ogg
application/pdf pdf
application/pgp pgp
application/pgp-encrypted
application/pgp-encrypted pgp gpg
application/pgp-keys
application/pgp-keys skr pkr
application/pgp-signature
application/pgp-signature sig
application/pkcs7-mime
application/pkcs7-signature p7s
application/postscript ps
application/rtf rtf
application/sdp sdp
application/smil smil smi sml
application/stuffit sit
application/vnd.corel-draw cdr
application/vnd.hp-hpgl hpgl
application/vnd.hp-pcl pcl
application/vnd.lotus-1-2-3 123 wk1 wk3 wk4 wks
application/vnd.mozilla.xul+xml xul
application/vnd.ms-excel xls xlc xll xlm xlw xla xlt xld xlsx xltx
application/vnd.ms-powerpoint ppz ppt pps pot pptx potx ppsx
application/vnd.oasis.opendocument.chart odc
application/vnd.oasis.opendocument.database odb
application/vnd.oasis.opendocument.formula odf
application/vnd.oasis.opendocument.graphics odg
application/vnd.oasis.opendocument.graphics-template otg
application/vnd.oasis.opendocument.image odi
application/vnd.oasis.opendocument.presentation odp
application/vnd.oasis.opendocument.presentation-template otp
application/vnd.oasis.opendocument.spreadsheet ods
application/vnd.oasis.opendocument.spreadsheet-template ots
application/vnd.oasis.opendocument.text odt
application/vnd.oasis.opendocument.text-master odm
application/vnd.oasis.opendocument.text-template ott
application/vnd.oasis.opendocument.text-web oth
application/vnd.palm pdb
application/vnd.rn-realmedia
application/vnd.rn-realmedia rm
application/vnd.rn-realmedia-secure rms
application/vnd.rn-realmedia-vbr rmvb
application/vnd.stardivision.calc sdc
application/vnd.stardivision.chart sds
application/vnd.stardivision.draw sda
application/vnd.stardivision.impress sdd sdp
application/vnd.stardivision.mail smd
application/vnd.stardivision.math smf
application/vnd.stardivision.writer sdw vor sgl
application/vnd.sun.xml.calc sxc
application/vnd.sun.xml.calc.template stc
application/vnd.sun.xml.draw sxd
application/vnd.sun.xml.draw.template std
application/vnd.sun.xml.impress sxi
application/vnd.sun.xml.impress.template sti
application/vnd.sun.xml.math sxm
application/vnd.sun.xml.writer sxw
application/vnd.sun.xml.writer.global sxg
application/vnd.sun.xml.writer.template stw
application/vnd.wordperfect wpd
application/x-abiword abw abw.CRASHED abw.gz zabw
application/x-amipro sam
application/x-anjuta-project prj
application/x-applix-spreadsheet as
application/x-applix-word aw
application/x-arc
application/x-archive a
application/x-arj arj
application/x-asax asax
application/x-ascx ascx
application/x-ashx ashx
application/x-asix asix
application/x-asmx asmx
application/x-asp asp
application/x-awk
application/x-axd axd
application/x-bcpio bcpio
application/x-bittorrent torrent
application/x-blender blender blend BLEND
application/x-bzip bz bz2
application/x-bzip bz2 bz
application/x-bzip-compressed-tar tar.bz tar.bz2
application/x-bzip-compressed-tar tar.bz tar.bz2 tbz tbz2
application/x-cd-image iso
application/x-cgi cgi
application/x-chess-pgn pgn
application/x-chm chm
application/x-class-file
application/x-cmbx cmbx
application/x-compress Z
application/x-compressed-tar tar.gz tar.Z tgz taz
application/x-compressed-tar tar.gz tgz
application/x-config config
application/x-core
application/x-cpio cpio
application/x-cpio-compressed cpio.gz
application/x-csh csh
application/x-cue cue
application/x-dbase dbf
application/x-dbm
application/x-dc-rom dc
application/x-deb deb
application/x-designer ui
application/x-desktop desktop kdelnk
application/x-devhelp devhelp
application/x-dia-diagram dia
application/x-disco disco
application/x-dvi dvi
application/x-e-theme etheme
application/x-egon egon
application/x-executable exe
application/x-font-afm afm
application/x-font-bdf bdf
application/x-font-dos
application/x-font-framemaker
application/x-font-libgrx
application/x-font-linux-psf psf
application/x-font-otf
application/x-font-pcf pcf
application/x-font-pcf pcf.gz
application/x-font-speedo spd
application/x-font-sunos-news
application/x-font-tex
application/x-font-tex-tfm
application/x-font-ttf ttc TTC
application/x-font-ttf ttf
application/x-font-type1 pfa pfb gsf pcf.Z
application/x-font-vfont
application/x-frame
application/x-frontline aop
application/x-gameboy-rom gb
application/x-gdbm
application/x-gdesklets-display display
application/x-genesis-rom gen md
application/x-gettext-translation gmo
application/x-glabels glabels
application/x-glade glade
application/x-gmc-link
application/x-gnome-db-connection connection
application/x-gnome-db-database database
application/x-gnome-stones caves
application/x-gnucash gnucash gnc xac
application/x-gnumeric gnumeric
application/x-graphite gra
application/x-gtar gtar
application/x-gtktalog
application/x-gzip gz
application/x-gzpostscript ps.gz
application/x-hdf hdf
application/x-ica ica
application/x-ipod-firmware
application/x-jamin jam
application/x-jar jar
application/x-java class
application/x-java-archive jar ear war
application/x-java-jnlp-file jnlp
application/x-jbuilder-project jpr jpx
application/x-karbon karbon
application/x-kchart chrt
application/x-kformula kfo
application/x-killustrator kil
application/x-kivio flw
application/x-kontour kon
application/x-kpovmodeler kpm
application/x-kpresenter kpr kpt
application/x-krita kra
application/x-kspread ksp
application/x-kspread-crypt
application/x-ksysv-package
application/x-kugar kud
application/x-kword kwd kwt
application/x-kword-crypt
application/x-lha lha lzh
application/x-lha lzh
application/x-lhz lhz
application/x-linguist ts
application/x-lyx lyx
application/x-lzop lzo
application/x-lzop-compressed-tar tar.lzo tzo
application/x-macbinary
application/x-machine-config
application/x-magicpoint mgp
application/x-master-page master
application/x-matroska mkv
application/x-mdp mdp
application/x-mds mds
application/x-mdsx mdsx
application/x-mergeant mergeant
application/x-mif mif
application/x-mozilla-bookmarks
application/x-mps mps
application/x-ms-dos-executable exe
application/x-mswinurl
application/x-mswrite wri
application/x-msx-rom msx
application/x-n64-rom n64
application/x-nautilus-link
application/x-nes-rom nes
application/x-netcdf cdf nc
application/x-netscape-bookmarks
application/x-object o
application/x-ole-storage
application/x-oleo oleo
application/x-palm-database
application/x-palm-database pdb prc
application/x-par2 PAR2 par2
application/x-pef-executable
application/x-perl pl pm al perl
application/x-php php php3 php4
application/x-pkcs12 p12 pfx
application/x-planner planner mrproject
application/x-planperfect pln
application/x-prjx prjx
application/x-profile
application/x-ptoptimizer-script pto
application/x-pw pw
application/x-python-bytecode pyc pyo
application/x-quattro-pro wb1 wb2 wb3
application/x-quattropro wb1 wb2 wb3
application/x-qw qif
application/x-rar rar
application/x-rar-compressed rar
application/x-rdp rdp
application/x-reject rej
application/x-remoting rem
application/x-resources resources
application/x-resourcesx resx
application/x-rpm rpm
application/x-ruby
application/x-sc
application/x-sc sc
application/x-scribus sla sla.gz scd scd.gz
application/x-shar shar
application/x-shared-library-la la
application/x-sharedlib so
application/x-shellscript sh
application/x-shockwave-flash swf
application/x-siag siag
application/x-slp
application/x-smil kino
application/x-smil smi smil
application/x-sms-rom sms gg
application/x-soap-remoting soap
application/x-streamingmedia ssm
application/x-stuffit
application/x-stuffit bin sit
application/x-sv4cpio sv4cpio
application/x-sv4crc sv4crc
application/x-tar tar
application/x-tarz tar.Z
application/x-tex-gf gf
application/x-tex-pk k
application/x-tgif obj
application/x-theme theme
application/x-toc toc
application/x-toutdoux
application/x-trash   bak old sik
application/x-troff tr roff t
application/x-troff-man man
application/x-troff-man-compressed
application/x-tzo tar.lzo tzo
application/x-ustar ustar
application/x-wais-source src
application/x-web-config
application/x-wpg wpg
application/x-wsdl wsdl
application/x-x509-ca-cert der cer crt cert pem
application/x-xbel xbel
application/x-zerosize
application/x-zoo zoo
application/xhtml+xml xhtml
application/zip zip
audio/ac3 ac3
audio/basic au snd
audio/midi mid midi
audio/mpeg mp3
audio/prs.sid sid psid
audio/vnd.rn-realaudio ra
audio/x-aac aac
audio/x-adpcm
audio/x-aifc
audio/x-aiff aif aiff
audio/x-aiff aiff aif aifc
audio/x-aiffc
audio/x-flac flac
audio/x-m4a m4a
audio/x-mod mod ult uni XM m15 mtm 669
audio/x-mp3-playlist
audio/x-mpeg
audio/x-mpegurl m3u
audio/x-ms-asx
audio/x-pn-realaudio ra ram rm
audio/x-pn-realaudio ram rmm
audio/x-riff
audio/x-s3m s3m
audio/x-scpls pls
audio/x-scpls pls xpl
audio/x-stm stm
audio/x-voc voc
audio/x-wav wav
audio/x-xi xi
audio/x-xm xm
image/bmp bmp
image/cgm cgm
image/dpx
image/fax-g3 g3
image/g3fax
image/gif gif
image/ief ief
image/jpeg jpeg jpg jpe
image/jpeg2000 jp2
image/png png
image/rle rle
image/svg+xml svg
image/tiff tif tiff
image/vnd.djvu djvu djv
image/vnd.dwg dwg
image/vnd.dxf dxf
image/x-3ds 3ds
image/x-applix-graphics ag
image/x-cmu-raster ras
image/x-compressed-xcf xcf.gz xcf.bz2
image/x-dcraw bay BAY bmq BMQ cr2 CR2 crw CRW cs1 CS1 dc2 DC2 dcr DCR fff FFF k25 K25 kdc KDC mos MOS mrw MRW nef NEF orf ORF pef PEF raf RAF rdc RDC srf SRF x3f X3F
image/x-dib
image/x-eps eps epsi epsf
image/x-fits fits
image/x-fpx
image/x-icb icb
image/x-ico ico
image/x-iff iff
image/x-ilbm ilbm
image/x-jng jng
image/x-lwo lwo lwob
image/x-lws lws
image/x-msod msod
image/x-niff
image/x-pcx
image/x-photo-cd pcd
image/x-pict pict pict1 pict2
image/x-portable-anymap pnm
image/x-portable-bitmap pbm
image/x-portable-graymap pgm
image/x-portable-pixmap ppm
image/x-psd psd
image/x-rgb rgb
image/x-sgi sgi
image/x-sun-raster sun
image/x-tga tga
image/x-win-bitmap cur
image/x-wmf wmf
image/x-xbitmap xbm
image/x-xcf xcf
image/x-xfig fig
image/x-xpixmap xpm
image/x-xwindowdump xwd
inode/blockdevice
inode/chardevice
inode/directory
inode/fifo
inode/mount-point
inode/socket
inode/symlink
message/delivery-status
message/disposition-notification
message/external-body
message/news
message/partial
message/rfc822
message/x-gnu-rmail
model/vrml wrl
multipart/alternative
multipart/appledouble
multipart/digest
multipart/encrypted
multipart/mixed
multipart/related
multipart/report
multipart/signed
multipart/x-mixed-replace
text/calendar vcs ics
text/css css CSSL
text/directory vcf vct gcrd
text/enriched
text/html html htm
text/htmlh
text/javascript js
text/mathml mml
text/plain txt asc
text/rdf rdf
text/rfc822-headers
text/richtext rtx
text/rss rss
text/sgml sgml sgm
text/spreadsheet sylk slk
text/tab-separated-values tsv
text/vnd.rn-realtext rt
text/vnd.wap.wml wml
text/x-adasrc adb ads
text/x-authors
text/x-bibtex bib
text/x-boo boo
text/x-c++hdr hh
text/x-c++src cpp cxx cc C c++
text/x-chdr h h++ hp
text/x-comma-separated-values csv
text/x-copying
text/x-credits
text/x-csrc c
text/x-dcl dcl
text/x-dsl dsl
text/x-dsrc d
text/x-dtd dtd
text/x-emacs-lisp el
text/x-fortran f
text/x-gettext-translation po
text/x-gettext-translation-template pot
text/x-gtkrc
text/x-haskell hs
text/x-idl idl
text/x-install
text/x-java java
text/x-js js
text/x-ksysv-log
text/x-literate-haskell lhs
text/x-log log
text/x-makefile
text/x-moc moc
text/x-msil il
text/x-nemerle n
text/x-objcsrc m
text/x-pascal p pas
text/x-patch diff patch
text/x-python py
text/x-readme
text/x-rng rng
text/x-scheme scm
text/x-setext etx
text/x-speech
text/x-sql sql
text/x-suse-ymp ymp
text/x-suse-ymu ymu
text/x-tcl tcl tk
text/x-tex tex ltx sty cls
text/x-texinfo texi texinfo
text/x-texmacs tm ts
text/x-troff-me me
text/x-troff-mm mm
text/x-troff-ms ms
text/x-uil uil
text/x-uri uri url
text/x-vb vb
text/x-xds xds
text/x-xmi xmi
text/x-xsl xsl
text/x-xslfo fo xslfo
text/x-xslt xslt xsl
text/xmcd
text/xml xml
video/3gpp 3gp
video/dv dv dif
video/isivideo
video/mpeg mpeg mpg mp2 mpe vob dat
video/quicktime qt mov moov qtvr
video/vivo
video/vnd.rn-realvideo rv
video/wavelet
video/x-3gpp2 3g2
video/x-anim anim[1-9j]
video/x-avi
video/x-flic fli flc
video/x-mng mng
video/x-ms-asf asf asx
video/x-ms-wmv wmv
video/x-msvideo avi
video/x-nsv nsv NSV
video/x-real-video
video/x-sgi-movie movie
'! !

!MIMEMap class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
arrayFromApacheMimeTypes
	| collection stream |
	collection:= OrderedCollection new.
	stream := ReadStream on: self apacheMimeTypes.
	[stream atEnd] whileFalse:
		[ | col line word |
		col := OrderedCollection new.
		line := (stream upTo: Character cr) readStream.
		[line atEnd] whileFalse: [word := line upToSeparator. word notEmpty ifTrue: [col add: word] ].
		collection add: col].
	^collection

"MIMEMap arrayFromApacheMimeTypes"! !

!MIMEMap class methodsFor: 'accessing'!
arrayFromTextMimeTypes
	"MIMEMap arrayFromTextMimeTypes"
	| collection stream |
	collection:= OrderedCollection new.
	stream := ReadStream on: self textMimeTypes.
	[stream atEnd] whileFalse:
		[ | line word |
		line := (stream upTo: Character cr) readStream.
		word := line upToSeparator. word notEmpty ifTrue: [collection add: word] ].
	^collection! !

!MIMEMap class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
default
	^AIDASite default mimeMap! !

!MIMEMap class methodsFor: 'accessing'!
textMimeTypes
	"which content/mime types are text based"
	"warning, not necessary complete!!"

	^'
application/docbook+xml
application/ecmascript
application/javascript
application/x-javascript
application/pkcs7-mime
application/pkcs7-signature
application/postscript
application/rtf
application/vnd.hp-hpgl
application/vnd.hp-pc
application/vnd.mozilla.xul+xml
application/x-cgi
application/x-config
application/x-csh
application/x-gettext-translation
application/x-jar
application/x-java
application/x-machine-config
application/x-perl
application/x-php
application/x-pkcs12
application/x-ruby
application/x-toc
application/x-web-config
application/x-wsdl
application/x-x509-ca-cert
application/xhtml+xml
image/svg+xml
message/delivery-status
message/disposition-notification
message/external-body
message/news
message/partial
message/rfc822
multipart/alternative
multipart/digest
multipart/encrypted
multipart/mixed
multipart/related
multipart/report
multipart/signed
multipart/x-mixed-replace
text/calendar
text/css
text/directory
text/enriched
text/html
text/htmlh
text/mathml
text/javascript
text/plain
text/rdf
text/rfc822-headers
text/richtext
text/rss
text/sgml sgml
text/spreadsheet sylk
text/tab-separated-values
text/vnd.rn-realtext
text/vnd.wap.wml
text/x-adasrc
text/x-authors
text/x-bibtex
text/x-boo
text/x-c++hdr
text/x-c++src
text/x-chdr
text/x-comma-separated-values
text/x-copying
text/x-credits
text/x-csrc
text/x-dcl
text/x-dsl
text/x-dsrc
text/x-dtd
text/x-emacs-lisp
text/x-fortran
text/x-gettext-translation
text/x-gettext-translation-template
text/x-gtkrc
text/x-haskell
text/x-idl
text/x-install
text/x-java
text/x-js
text/x-ksysv-log
text/x-literate-haskell
text/x-log
text/x-makefile
text/x-moc
text/x-msil
text/x-nemerle
text/x-objcsrc
text/x-pascal
text/x-patch
text/x-python
text/x-readme
text/x-rng
text/x-scheme
text/x-setext
text/x-speech
text/x-sql
text/x-suse-ymp
text/x-suse-ymu
text/x-tcl
text/x-tex
text/x-texinfo
text/x-texmacs
text/x-troff-me
text/x-troff-mm
text/x-troff-ms
text/x-uil
text/x-uri
text/x-vb
text/x-xds
text/x-xmi
text/x-xsl
text/x-xslfo
text/x-xslt
text/xmcd
text/xml

'! !


!MIMEMap class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !


Object subclass: #VersionSpec
	instanceVariableNames: 'object number current parent next'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!VersionSpec commentStamp: '<historical>' prior: 0!
VersionSpec defines a versioned object by its number and position in version chain.

Instance Variables:
	number	<String>	 number of that version. Integer by default, but it can be any string
	current	<Boolean> true, if this version is current, that is, most important, released, etc.
	parent	<Object> parent, that is, previous version of that object, nil if noone
	next		<Object> next version of that object, nil if noone

!


!VersionSpec methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allVersionSpecs
	^self olderVersionSpecs, (Array with: self), self newerVersionSpecs! !

!VersionSpec methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
currentVersionSpec
	"find a version spec of current object in a chain"
	self isCurrent ifTrue: [^self].
	^self olderVersionSpecs detect: [:each | each isCurrent] ifNone: 
		[^self newerVersionSpecs detect: [:each | each isCurrent] 
			ifNone: [self error: 'no current version!!'] ].! !

!VersionSpec methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
newerVersionSpecs
	"return all version specs of that object, newer than this one"
	self isNewest ifTrue: [^#()].
	^OrderedCollection new 
		add: self next version; addAll: self next version newerVersionSpecs;
		yourself! !

!VersionSpec methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
next
	"next version of an object in version chain, if any"
	^next! !

!VersionSpec methodsFor: 'accessing'!
number
	"version number, as string"
	^number! !

!VersionSpec methodsFor: 'accessing'!
number: aString
	number = aString ifTrue: [^number].
	(self existNumber: aString)
		 ifTrue: [^self error: 'version with that number already exist!!'].
	number := aString! !

!VersionSpec methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
object
	"object for which is this version spec"
	^object! !

!VersionSpec methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
olderVersionSpecs
	"return all version specs of that object, older than this one"
	self isOldest ifTrue: [^#()].
	^OrderedCollection new 
		addAll: self parent version olderVersionSpecs; add: self parent version;
		yourself! !

!VersionSpec methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
otherVersionSpecs
	"older and newer versions, if any"
	^self olderVersionSpecs, self newerVersionSpecs! !

!VersionSpec methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
parent
	"older version of an object in version chain, if any. It is a parent of that object, 
	because it is derived from it"
	^parent! !

!VersionSpec methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setCurrent
	self current: true.
	self otherVersionSpecs do: [:each | each clearCurrent].! !

!VersionSpec methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
versionSpecWithNumber: aString
	"find spec  with that version number"
	self number = aString ifTrue: [^self].
	^self olderVersionSpecs detect: [:each | each number = aString] ifNone: 
		[^self newerVersionSpecs detect: [:each | each number = aString] ifNone: [nil] ].! !


!VersionSpec methodsFor: 'private' stamp: ' 21/4/07 22:07'!
clearCurrent
	current := false! !

!VersionSpec methodsFor: 'private' stamp: ' 21/4/07 22:07'!
current
	"this version current one? Current version object have a direct url, without 'version=' in query part"
	^current! !

!VersionSpec methodsFor: 'private' stamp: ' 21/4/07 22:07'!
current: aBoolean
	current := aBoolean! !

!VersionSpec methodsFor: 'private' stamp: ' 21/4/07 22:07'!
next: anObject
	next := anObject! !

!VersionSpec methodsFor: 'private' stamp: ' 21/4/07 22:07'!
object: anObject
	object := anObject! !

!VersionSpec methodsFor: 'private' stamp: ' 21/4/07 22:07'!
parent: anObject
	parent := anObject! !

!VersionSpec methodsFor: 'private' stamp: ' 21/4/07 22:07'!
printString
	^'aVersionSpec version: ', self number! !


!VersionSpec methodsFor: 'testing'!
existNumber: aString
	"check if this version number already exists in version chain"
	^(self versionSpecWithNumber: aString) notNil! !

!VersionSpec methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isCurrent
	^self current! !

!VersionSpec methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isNewest
	^self next isNil! !

!VersionSpec methodsFor: 'testing'!
isNumberUnique: aString
	"check if this version number already exists in version chain"! !

!VersionSpec methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isOldest
	^self parent isNil! !


!VersionSpec methodsFor: 'initalize-release' stamp: ' 21/4/07 22:07'!
setDefaultNumber
	self isOldest 
		ifTrue: [self number: '1'] 
		ifFalse: [self setIncrementedNumberFromParent]! !

!VersionSpec methodsFor: 'initalize-release' stamp: ' 21/4/07 22:07'!
setIncrementedNumberFromParent
	"for now, later it should increment last number in string"
	self number: (self parent version number asInteger + 1) printString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

VersionSpec class
	instanceVariableNames: ''!

!VersionSpec class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
firstFor: anObject
	"for a first version of an object"
	^super new
		object: anObject;
		setDefaultNumber;
		setCurrent! !

!VersionSpec class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
newFromParent: anOldObject for: aNewObject
	| newSpec |
	newSpec := super new
		object: aNewObject;
		parent: anOldObject;
		setIncrementedNumberFromParent;
		clearCurrent.
	aNewObject version: newSpec.
	anOldObject version next: aNewObject.
	^newSpec! !


!VersionSpec class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
new
	^self shouldNotImplement! !


Object subclass: #VersionedObject
	instanceVariableNames: 'version'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!VersionedObject commentStamp: '<historical>' prior: 0!
VersionedObject for objects of many versions through the time, with a current version and a new one maybe in preparation. Prime example is Document in Scribo CMS. More on http://www.aidaweb.si/advanced-features.html
!


!VersionedObject methodsFor: 'accessing-versions' stamp: ' 21/4/07 22:07'!
allVersions
	^self version allVersionSpecs collect: [:each | each object]! !

!VersionedObject methodsFor: 'accessing-versions' stamp: ' 21/4/07 22:07'!
newerVersions
	^self version newerVersionSpecs collect: [:each | each object]! !

!VersionedObject methodsFor: 'accessing-versions' stamp: ' 21/4/07 22:07'!
newestVersion
	self isNewestVersion ifTrue: [^self].
	^self newerVersions last! !

!VersionedObject methodsFor: 'accessing-versions' stamp: ' 21/4/07 22:07'!
nextVersion
	"next version of an object in version chain, if any"
	^self version next! !

!VersionedObject methodsFor: 'accessing-versions' stamp: ' 21/4/07 22:07'!
olderVersions
	^self version olderVersionSpecs collect: [:each | each object]! !

!VersionedObject methodsFor: 'accessing-versions' stamp: ' 21/4/07 22:07'!
oldestVersion
	self isOldestVersion ifTrue: [^self].
	^self olderVersions first! !

!VersionedObject methodsFor: 'accessing-versions' stamp: ' 21/4/07 22:07'!
parentVersion
	"older version of an object in version chain, if any. It is a parent of that object, 
	because it is derived from it"
	^self version parent! !


!VersionedObject methodsFor: 'copying' stamp: ' 21/4/07 22:07'!
asNewVersion
	"return a new version of that object with all its current contents"
	| new |
	new := self class new.
	new version: (VersionSpec newFromParent: self for: new).
	self copyContentsTo: new.
	^new! !

!VersionedObject methodsFor: 'copying' stamp: ' 21/4/07 22:07'!
copyContentsTo: anObject
	"override in subclases to copy contents to a new object"! !

!VersionedObject methodsFor: 'copying'!
undoNewVersion
	"remove new version, if not yet current. Return previous one"
	| previous |
	self isCurrentVersion ifTrue: [^self error: 'cannot remove current version'].
	self isNewestVersion ifFalse: [^self error: 'cannot remove version which is nost last/newest'].
	self isOnlyVersion ifTrue: [^self error: 'cannot remove the one and only version'].
	previous := self parentVersion.
	previous version next: nil.  "this will break a chain of versions to this one"
	^previous! !


!VersionedObject methodsFor: 'accessing-current' stamp: ' 21/4/07 22:07'!
currentVersion
	"find a current version of object in a version chain"
	^self version currentVersionSpec object! !

!VersionedObject methodsFor: 'accessing-current' stamp: ' 21/4/07 22:07'!
setCurrentVersion
	"set this object as current version, which has always the same identity "
	| other |
	self isCurrentVersion ifTrue: [^nil].
	other := self currentVersion.
	self swapIdentityWith: other.
	^other version setCurrent "because other is now me!! "! !


!VersionedObject methodsFor: 'accessing'!
existsVersionNumber: aString
	"version with that number already exist?"
	^(self versionWithNumber: aString trimBlanks)
		notNil! !

!VersionedObject methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
versionNumber
	"version number, integer by default, but it can be any string"
	^self version number! !

!VersionedObject methodsFor: 'accessing'!
versionNumber: aString
	"set version number other than default"
	^self version number: aString trimBlanks! !

!VersionedObject methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
versionWithNumber: aString
	"find version with that number"
	| spec |
	spec := self version versionSpecWithNumber: aString.
	^spec notNil ifTrue: [spec object] ifFalse: [nil]! !


!VersionedObject methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initVersion
	self version: (VersionSpec firstFor: self)! !


!VersionedObject methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isCurrentVersion
	^self version isCurrent! !

!VersionedObject methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isNewestVersion
	^self version isNewest! !

!VersionedObject methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isOldestVersion
	^self version isOldest! !

!VersionedObject methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isOnlyVersion
	^self version isOldest & self version isNewest! !

!VersionedObject methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isVersionedObject
	^true! !


!VersionedObject methodsFor: 'private'!
removeOldVersions
	"remove all versions of this document, which are older than current version"
	| vobjects |
	vobjects := self currentVersion olderVersions.
	vobjects do: [:each | 
		each version parent: nil; next: nil.
		each version: nil]! !

!VersionedObject methodsFor: 'private' stamp: ' 21/4/07 22:07'!
swapIdentityWith: anObject
	"carefully adjust object references (object, parent, next) in version specs too!!"
	|  o1 o2 s1Spec s2Spec |
	o1 := self. o2 := anObject.  s1Spec := o1 version. s2Spec := o2 version.
	o1 become: o2.
	s1Spec object: o2. s2Spec object: o1.
	s1Spec isNewest ifFalse:
		[s1Spec next == o2 ifTrue: [s1Spec next: o1] ifFalse: [s1Spec next version parent: o2] ].
	s1Spec isOldest ifFalse:
		[s1Spec parent == o2 ifTrue: [s1Spec parent: o1] ifFalse: [s1Spec parent version next: o2]].
	s2Spec isNewest ifFalse:
		[s2Spec next == o1 ifTrue: [s2Spec next: o2] ifFalse: [s2Spec next version parent: o1] ].
	s2Spec isOldest ifFalse:
		[s2Spec parent == o1 ifTrue: [s2Spec parent: o2] ifFalse: [s2Spec parent version next: o1]].! !

!VersionedObject methodsFor: 'private' stamp: ' 21/4/07 22:07'!
version
	version isNil ifTrue: [self initVersion].
	^version! !

!VersionedObject methodsFor: 'private' stamp: ' 21/4/07 22:07'!
version: aVersionSpec
	version := aVersionSpec! !


Object subclass: #WebCache
	instanceVariableNames: 'objects other settings parent'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebCache commentStamp: '<historical>' prior: 0!
WebCache is Memcached-like cache to speedup serving pages which don't change too frequently. See http://www.aidaweb.si/caching.html for usage and examples.

!


!WebCache methodsFor: 'private-cache' stamp: 'np 3/16/2009 12:33'!
addObject: anObject view: aViewSymbol content: aByteStringOrArray timeout: aSeconds
	| views |
	views := self objects at: anObject ifAbsentPut: [Dictionary new].
	views at: aViewSymbol put: 
		(WebCacheEntry new content: aByteStringOrArray; timeout: aSeconds)! !

!WebCache methodsFor: 'private-cache' stamp: 'np 3/16/2009 12:34'!
entryForObject: anObject view: aViewSymbol
	^(self objects at: anObject ifAbsent: [^nil])
		at: aViewSymbol ifAbsent: [nil]! !

!WebCache methodsFor: 'private-cache' stamp: 'np 3/16/2009 12:36'!
removeObject: anObject
	self objects removeKey: anObject ifAbsent: [nil]! !

!WebCache methodsFor: 'private-cache' stamp: 'np 3/16/2009 12:36'!
removeObject: anObject view: aViewSymbol
	| views |
	views := self objects at: anObject ifAbsent: [^nil].
	views removeKey: aViewSymbol ifAbsent: [^nil].
	views isEmpty ifTrue: [self removeObject: anObject].! !


!WebCache methodsFor: 'settings' stamp: 'np 3/16/2009 12:34'!
cacheTimeout
	"in seconds, how long cache entry lives until is invalidated"
	"default is one day"
	^self settingsAt: #CacheDuration ifAbsentPut: [24*3600]! !

!WebCache methodsFor: 'settings' stamp: 'np 3/16/2009 12:34'!
cacheTimeout: aSeconds
	"in seconds, how long cache entry lives until is invalidated"
	^self settingsAt: #CacheDuration put: aSeconds! !


!WebCache methodsFor: 'initialize-release' stamp: 'np 3/16/2009 12:34'!
initObjects
	objects := Dictionary new! !

!WebCache methodsFor: 'initialize-release' stamp: 'np 3/16/2009 12:34'!
initOther
	other := Dictionary new! !

!WebCache methodsFor: 'initialize-release' stamp: 'np 3/16/2009 12:34'!
initSettings
	settings := Dictionary new! !


!WebCache methodsFor: 'caching' stamp: 'np 3/16/2009 12:35'!
invalidateObject: anObject
	"if exist then cache entries for that object are not valid anymore and shall be refreshed"
	self removeObject: anObject! !

!WebCache methodsFor: 'caching' stamp: 'np 3/16/2009 12:35'!
isCached: anObject to: aRequest on: aWebSession
	| entry |
	entry := ((self objects at: anObject ifAbsent: [^false])
		at: aRequest view ifAbsent: [^false]).
	entry isTimedOut 
		ifTrue: [self removeObject: anObject view: aRequest view. ^false].
	^true! !

!WebCache methodsFor: 'caching' stamp: 'np 3/16/2009 13:00'!
purgeCache
	"invalidate all timed-out cache entries"
	"run it from time to time, like every day from SwazooServer>>watchogOther"
	self objects associations do: [:assoc |
		assoc value associations do: [:vassoc | vassoc value isTimedOut 
			ifTrue: [self removeObject: assoc key view: vassoc key] ] ]! !

!WebCache methodsFor: 'caching' stamp: 'np 3/16/2009 12:37'!
respond: anObject to: aRequest on: aWebSession
	| response |
	response := HTTPResponse ok.
	aRequest task response: response.
	self site addResponseHeadersTo: response forPage: nil on: aWebSession.
	response entity: (self entryForObject: anObject view: aRequest view) content. 
	self site log: ' cached done'.
	^response! !

!WebCache methodsFor: 'caching' stamp: 'np 3/16/2009 12:37'!
shouldCache: anObject to: aRequest on: aWebSession
	^anObject aidaCacheView: aRequest view on: aWebSession! !

!WebCache methodsFor: 'caching' stamp: 'np 3/16/2009 12:38'!
store: aByteStringOrArray for: anObject to: aRequest on: aWebSession
	| timeout |
	timeout := anObject aidaCacheTimeout notNil
		ifTrue: [anObject aidaCacheTimeout notNil] "per domain object cache timeout"
		ifFalse: [self cacheTimeout]. 		"global cache timeout"
	self addObject: anObject view: aRequest view 
		content: aByteStringOrArray timeout: timeout! !


!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:35'!
objects
	"a dictionary of cache entries per domain object per view"
	objects isNil ifTrue: [self initObjects].
	^objects! !

!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:35'!
other
	^other! !

!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:36'!
otherAt: aSymbol
	"other values"
	^self otherAt: aSymbol ifAbsent: [nil]! !

!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:36'!
otherAt: aSymbol ifAbsent: aBlock
	"other values"
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:36'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:36'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !

!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:37'!
settings
	settings isNil ifTrue: [self initSettings].
	^settings! !

!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:37'!
settingsAt: aSymbol
	^self settingsAt: aSymbol ifAbsent: [nil]! !

!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:37'!
settingsAt: aSymbol ifAbsent: aBlock
	^self settings at: aSymbol ifAbsent: aBlock! !

!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:37'!
settingsAt: aSymbol ifAbsentPut: aValue
	^self settings at: aSymbol ifAbsentPut: aValue! !

!WebCache methodsFor: 'private' stamp: 'np 3/16/2009 12:37'!
settingsAt: aSymbol put: aValue
	^self settings at: aSymbol put: aValue! !


!WebCache methodsFor: 'accessing' stamp: 'np 3/16/2009 12:36'!
parent
	^parent! !

!WebCache methodsFor: 'accessing' stamp: 'np 3/16/2009 12:36'!
parent: anObject
	parent := anObject! !

!WebCache methodsFor: 'accessing' stamp: 'np 3/16/2009 12:37'!
site	
	^self parent! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebCache class
	instanceVariableNames: ''!

!WebCache class methodsFor: 'instance creation' stamp: 'np 3/16/2009 12:33'!
newOn: anAIDASite
	^super new
		parent: anAIDASite! !


Object subclass: #WebCacheEntry
	instanceVariableNames: 'content created timeout'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebCacheEntry commentStamp: '<historical>' prior: 0!
WebCacheEntry instances hold cached content in WebCache.

!


!WebCacheEntry methodsFor: 'accessing' stamp: 'np 3/16/2009 12:38'!
content
	"cached content"
	^content! !

!WebCacheEntry methodsFor: 'accessing' stamp: 'np 3/16/2009 12:39'!
content: aByteStringOrArray
	"cached content"
	content := aByteStringOrArray! !

!WebCacheEntry methodsFor: 'accessing' stamp: 'np 3/16/2009 12:39'!
created
	"when the cahce entry was created"
	^SpTimestamp fromSeconds: self createdAsSeconds! !

!WebCacheEntry methodsFor: 'accessing' stamp: 'np 3/16/2009 12:39'!
timeout
	"how many seconds this cached content is valid"
	^timeout! !

!WebCacheEntry methodsFor: 'accessing' stamp: 'np 3/16/2009 12:39'!
timeout: aSeconds
	"how many seconds this cached content is valid"
	timeout := aSeconds! !


!WebCacheEntry methodsFor: 'private' stamp: 'np 3/16/2009 12:39'!
createdAsSeconds
	"when the cahce entry was created"
	^created! !

!WebCacheEntry methodsFor: 'private' stamp: 'np 3/16/2009 12:39'!
setCreated
	created := SpTimestamp now asSeconds! !


!WebCacheEntry methodsFor: 'testing' stamp: 'np 3/16/2009 12:39'!
isTimedOut
	^(SpTimestamp now asSeconds - self createdAsSeconds) > self timeout! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebCacheEntry class
	instanceVariableNames: ''!

!WebCacheEntry class methodsFor: 'instance creation' stamp: 'np 3/16/2009 12:40'!
new
	^super new setCreated! !


Object subclass: #WebClipboard
	instanceVariableNames: 'title url object'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebClipboard commentStamp: '<historical>' prior: 0!
Used for cut/copy/paste page references (not page contents!!) for easier hyperlinking of pages. Every page should have copy action. Then you can paste url to related links section in some other page.

Instance Variables:
	title	<String> title of a page
	url	<String>	url link to a page

!


!WebClipboard methodsFor: 'converting' stamp: ' 21/4/07 22:07'!
asDocLink
	"return clipboard contents as a new DocLink"
	^DocLink new
		title: self title;
		url: self url;
		object: self object! !

!WebClipboard methodsFor: 'converting' stamp: ' 21/4/07 22:07'!
copyFromDocLink: aDocLink
	self title: aDocLink title.
	self url: aDocLink url.
	self object: aDocLink object! !


!WebClipboard methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isEmpty
	^(self url isNil or: [self url isEmpty]) and: [self object isNil].! !


!WebClipboard methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
object
	^object! !

!WebClipboard methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
object: anObject
	object := anObject! !

!WebClipboard methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
title
	^title! !

!WebClipboard methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
title: anObject
	title := anObject! !

!WebClipboard methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
url
	^url! !

!WebClipboard methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
url: anObject
	url := anObject! !


Object subclass: #WebCommand
	instanceVariableNames: 'command context element value attributes other'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebCommand commentStamp: '<historical>' prior: 0!
WebCommand to send commands to and from the browser via JSON
!


!WebCommand methodsFor: 'accessing'!
app
	^self element notNil
		ifTrue: [self element app]	"on which app this element was built"
		ifFalse: [nil]! !

!WebCommand methodsFor: 'accessing'!
attributes
	"web element attributes to update, as dictionary of name -> value pairs"
	^attributes! !

!WebCommand methodsFor: 'accessing'!
attributes: aDictionary
	"web element attributes to update, as dictionary of name -> value pairs"
	attributes := aDictionary! !

!WebCommand methodsFor: 'accessing'!
command
	" #update, ..."
	^command! !

!WebCommand methodsFor: 'accessing'!
context
	^context! !

!WebCommand methodsFor: 'accessing'!
context: aContextIdString
	context := aContextIdString! !

!WebCommand methodsFor: 'accessing'!
element
	"web element for which is that command (like update this element)"
	^element! !

!WebCommand methodsFor: 'accessing'!
element: aWebElement
	element := aWebElement! !

!WebCommand methodsFor: 'accessing'!
value
	^value! !

!WebCommand methodsFor: 'accessing'!
value: aString
	value := aString! !

!WebCommand methodsFor: 'accessing'!
view
	"on which app view this element was created"
	self element isNil ifTrue: [^nil].
	^self element creationContext notNil
		ifTrue: [self element creationContext view]
		ifFalse: [self element app view]! !


!WebCommand methodsFor: 'converting'!
asJSON
	| dict |
	dict := Dictionary new. "will become a JS object on client side"
	self command ifNotNil: 
		[dict at: 'command' put: self command asString].
	self context ifNotNil:
		[dict at: 'context' put: self context].
	self element ifNotNil:
		[dict at: 'id' put: self element id asString].
	self value ifNotNil:
		[dict at: 'value' put: self value].
	self attributes ifNotNil:
		[dict at: 'attributes' put: self attributesAsArray].
	self other ifNotNil:
		[self at: 'other' put: self other]. "should be with string/number/boolean/nil values ony"
	^WebJSON stringify: dict! !

!WebCommand methodsFor: 'converting'!
attributesAsArray
	"actually an array of array with attribute name and value"
	| array |
	array := OrderedCollection new.
	self attributes keysAndValuesDo: [:name :vlue |
		array add: 
			(Array with: name with: vlue)].
	^array asArray! !


!WebCommand methodsFor: 'private'!
command: aSymbol
	command := aSymbol! !

!WebCommand methodsFor: 'private'!
printString
	^'aWebCommand 
	command: ', self command printString, '
	context: ', self context printString, '
	app: ', (self app notNil ifTrue: [self app class name] ifFalse: ['unknown']), '
	view: ', self view printString, '
	element: ', (self element notNil 
		ifTrue: [self element class name, ' ', self element id printString] ifFalse: ['nil']), '
	value: ', (self value notNil ifTrue: [self value size printString, ' bytes'] ifFalse: ['nil'])! !


!WebCommand methodsFor: 'initialize-release'!
initOther
	other := Dictionary new.! !


!WebCommand methodsFor: 'testing'!
isUpdate
	"command to update some element?"
	^self command = #update! !


!WebCommand methodsFor: 'private-other'!
other
	^other! !

!WebCommand methodsFor: 'private-other'!
otherAt: aSymbol
	^self otherAt: aSymbol ifAbsent: [nil]! !

!WebCommand methodsFor: 'private-other'!
otherAt: aSymbol ifAbsent: aBlock
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!WebCommand methodsFor: 'private-other'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!WebCommand methodsFor: 'private-other'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebCommand class
	instanceVariableNames: ''!

!WebCommand class methodsFor: 'instance creation'!
newLoadUrl: aString
	"command to load in current browser window some other page or reload current one"
	^self new 
		command: #load;
		value: aString! !

!WebCommand class methodsFor: 'instance creation'!
newUpdate: aWebElement with: aString
	"command to update some element on webpage"
	^self new 
		command: #update;
		element: aWebElement;
		value: aString! !

!WebCommand class methodsFor: 'instance creation'!
newUpdate: aWebElement with: aString attributes: aDictionary
	"command to update some element on webpage, updating its attributes too"
	^self new 
		command: #update;
		element: aWebElement;
		value: aString;
		attributes: aDictionary! !


Object subclass: #WebContext
	instanceVariableNames: 'id parent child state window ids nextId event answer result'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebContext commentStamp: 'janko 8/25/2012 14:57' prior: 0!
WebContext holds an execution context for a web request. Contexts can be linked in a stack like structure for tree-like control flow (like a confirmation dialog as popup of some delete action)

Instance Variables
	id		<Integer>	unique id of the context inside one App instance
	parent	<WebContext or WebApplication>	parent in context chain
	child	<WebContext> chils in context chain, if any
	form		<WebForm>	a web form with input fields of this context
	ids		<Dictionary>	 the elements which have id defined, for fast access to them from AJAX requests"
	nextId   <Integer>     number for a next element's id
!


!WebContext methodsFor: 'accessing'!
activeContext
	"active is always the last context in the chain"
	^self isLast
		ifTrue: [self]
		ifFalse: [self child activeContext]! !

!WebContext methodsFor: 'accessing'!
answer
	"answer by the widget called in #onSubmitAnswer: or similar methods"
	^answer! !

!WebContext methodsFor: 'accessing'!
app
	"the instance of WebApplication on which this context is executing"
	^self parent app! !

!WebContext methodsFor: 'accessing'!
child
	"another context in the chain, if any"
	^child! !

!WebContext methodsFor: 'accessing'!
event
	"current, later last event (a WebEvent or HTTPRequest) executed on that context"
	^event! !

!WebContext methodsFor: 'accessing'!
event: aWebEventOrRequest
	"current, later last event (a WebEvent or HTTPRequest) executed on that context"
	^event := aWebEventOrRequest! !

!WebContext methodsFor: 'accessing'!
first
	"first context up in the chain"
	^self parent first! !

!WebContext methodsFor: 'accessing'!
form
	"a web form with input fields of this context"
	^self window form! !

!WebContext methodsFor: 'accessing'!
id
	"unique identifier of the context inside the app instance"
	id isNil ifTrue: [self setId].
	^id! !

!WebContext methodsFor: 'accessing'!
level
	"on which level this context is in context chain. First one has level 0"
	^self parent level + 1! !

!WebContext methodsFor: 'accessing'!
page
	"a web page on which we are executing. This is always a window of first context in the chain"
	^self first 
		window! !

!WebContext methodsFor: 'accessing'!
parent
	"parent context up in the chain, but an app on the first context"
	^parent! !

!WebContext methodsFor: 'accessing'!
result
	"resulted web element of executing the context"
	^result! !

!WebContext methodsFor: 'accessing'!
session
	^self app session! !

!WebContext methodsFor: 'accessing'!
view
	"view on which context is executed"
	^self first view! !

!WebContext methodsFor: 'accessing'!
window
	"a window (or web page in case of first/top context) in which this context execute the request"
	window ifNil: 
		[self initWindow].
	^window! !


!WebContext methodsFor: 'accessing-other'!
afterCloseUpdate
	"used for temporary reference to the element to update after some popup will be closed. 
	See WebElement onClickPopup:thenClose, and WebElement>>addClosingLinkText: "
	^self otherAt: #AfterCloseUpdate ifAbsent: [nil]! !

!WebContext methodsFor: 'accessing-other'!
afterCloseUpdate: anElement
	"used for temporary reference to the element to update after some popup will be closed. 
	See WebElement onClickPopup:thenClose, and WebElement>>addClosingLinkText: "
	^self otherAt: #AfterCloseUpdate put: anElement! !


!WebContext methodsFor: 'private-ids'!
announceReplacementWith: anOldElement
	"next creation of WebElement (see class #new) will replace its id by that from anOldElement"
	"for robustness we store also the process it announced that!! "
	self replacementAnnouncements at: Processor activeProcess put: anOldElement! !

!WebContext methodsFor: 'private-ids'!
cancelReplacement
	"cancel next #registerId to replace the next element with old one in ids"
	self replacementAnnouncements removeKey: Processor activeProcess ifAbsent: []! !

!WebContext methodsFor: 'private-ids'!
currentReplacement
	"an old element to be replaced with a new one"
	^self replacementAnnouncements at:  Processor activeProcess ifAbsent: [nil]! !

!WebContext methodsFor: 'private-ids'!
elementId: aSymbol
	"search in a whole context chain, not only in current context!! "
	^self ids at: aSymbol ifAbsent: 
		[self isFirst not
			ifTrue: [self parent elementId: aSymbol]
			ifFalse: [nil]].! !

!WebContext methodsFor: 'private-ids'!
existsId: aSymbol
	"check in a whole context chain, not only in current context!! "
	^(self elementId: aSymbol) notNil! !

!WebContext methodsFor: 'private-ids'!
ids
	"dictionary of elements which have id defined, for fast access to them from AJAX requests"
	ids isNil ifTrue: [self initIds].
	^ids! !

!WebContext methodsFor: 'private-ids'!
isRegistered: anElement
	^self registeredSet includes: anElement! !

!WebContext methodsFor: 'private-ids'!
nextId
	" example: #id9
	Consider also already registered ids in contexts above in chain if any "
	^('id', self nextIdNumber printString)
		asSymbol! !

!WebContext methodsFor: 'private-ids'!
nextIdNumber
	"considering also already registered ids on above contexts"
	| nr |
	nextId isNil ifTrue: [nextId := self ids size + 1].
	nr := self isFirst not ifTrue: [self parent nextIdNumber - 1] ifFalse: [0].
	nr := nr + nextId + 1.
	nextId := nextId + 1.
	^nr! !

!WebContext methodsFor: 'private-ids'!
registerIdFor: anElement
	anElement id isNil ifTrue: 
		[anElement basicId: self nextId]. "auto id if not manually defined!! "
	(self isRegistered: anElement) 
		ifTrue: [^nil].
	(self ids includesKey: anElement id) ifTrue: 
		[self registeredSet remove: (self ids at: anElement id)]. "to replace with a new one"
	self ids 
		at: anElement id 
		put: anElement.
	self 	registeredSet 
		add: anElement.! !

!WebContext methodsFor: 'private-ids'!
registeredSet
	^self ids at: #setOfRegisteredElements ifAbsent: [self initRegisteredSet]! !

!WebContext methodsFor: 'private-ids'!
removeId: aSymbol
	| element |
	element := self ids 
		at: aSymbol 
		ifAbsent: [^nil].
	self ids 
		removeKey: aSymbol.
	self registeredSet 
		remove: element 
		ifAbsent: [].! !

!WebContext methodsFor: 'private-ids'!
replaceIdIn: anElement with: anOldElement
	"new anElement should have same id as an old one"
	anOldElement isNil ifTrue: [^nil].
	self registeredSet 
		remove: anOldElement ifAbsent: []; 
		add: anElement.
	self ids removeKey: anOldElement id ifAbsent: [].
	anElement attributesAt: #id put: anOldElement id. "anElement id: would deadlock!! "
	self ids at: anElement id put: anElement.! !

!WebContext methodsFor: 'private-ids'!
replacementAnnouncements
	"current elememnt id replacement announcements"
	^self ids at: #replacementAnnouncements ifAbsent: [self initReplacementAnnouncements]! !


!WebContext methodsFor: 'private'!
answer: anObject
	"answer by the widget called in #ask: or similar methods"
	answer := anObject! !

!WebContext methodsFor: 'private'!
child: aContext
	"add another context in the chain"
	(child notNil and: [aContext notNil]) ifTrue: [child close]. "and remove from app contexts etc."
	child := aContext.
	aContext notNil ifTrue: [aContext parent: self]! !

!WebContext methodsFor: 'private'!
parent: aContext
	parent := aContext! !

!WebContext methodsFor: 'private'!
printString
	^'aWebContext ', 
		(self isFirst ifTrue: ['first'] ifFalse: ['popup']), 
		' id: ', self id printString, '
	state: ', self state, '
	level: ', self level printString! !

!WebContext methodsFor: 'private'!
queue
	"for sending commands back to browser. Onlly first, page-level context has such queue"
	^self first queue! !

!WebContext methodsFor: 'private'!
result: aWebElement
	result := aWebElement! !

!WebContext methodsFor: 'private'!
widget
	^nil! !

!WebContext methodsFor: 'private'!
window: aWebWindow
	"a window (or web page) in which this context execute the request"
	window := aWebWindow! !


!WebContext methodsFor: 'executing'!
close
	"pass control to parent context, which will continue executing itrs process if any" 
	"It also removes itself from context chain"
	self app removeContext: self.
	self isFirst not ifTrue: 
		[self parent child: nil.
		self event notNil ifTrue: 	  " parent context will now continue executing our req (and 
								 	its old req if different)"
			[self event context: self parent.    "just to be sure" 
			self parent event notNil ifTrue: 
				[self parent event context: self parent]] ]. 
	self event: nil; answer: nil.
	self setClosed.
	self app session ifNil: [^true].
	self app site dependencies
		removeContext: self  "if exists there"! !

!WebContext methodsFor: 'executing'!
createNewContext
	"create and add as a child to receiver, also to the app"
	| ctx |
	ctx := WebContext newOn: self.
	self child: ctx.
	self app addContext: ctx.
	^ctx! !

!WebContext methodsFor: 'executing'!
finalizeExecutionOf: aRequest
	"do all necessary cleanup after request was composed and HTML streamed to response"
	self event: nil.   
"	aRequest context: nil.	 "
	self 
		answer: nil; 
		result: nil.! !

!WebContext methodsFor: 'executing'!
serialize: aRequest
	"Serialize execution if some other request is already executing"
	"for now just wait until previous request finish execution"
	[self isBusy ] 
		whileTrue: [(Delay forMilliseconds: 200) wait].! !


!WebContext methodsFor: 'initialize-release'!
initIds
	ids := Dictionary new.! !

!WebContext methodsFor: 'initialize-release'!
initOther
	other := Dictionary new.! !

!WebContext methodsFor: 'initialize-release'!
initRegisteredSet
	^self ids at: #setOfRegisteredElements put: Set new.! !

!WebContext methodsFor: 'initialize-release'!
initReplacementAnnouncements
	^self ids at: #replacementAnnouncements put: Dictionary new.! !

!WebContext methodsFor: 'initialize-release'!
initWindow
	self window: 
		((WebWindow newOnPopupCtx: self)
			 parent: self)! !

!WebContext methodsFor: 'initialize-release'!
setId
	"set a random number and check it for uniquines"
	id := (AIDASite random next * 100000) truncated.
	(self app contexts includesKey: self id) 
		ifTrue: [^self setId]     "repeat until unique at least on this App"! !


!WebContext methodsFor: 'testing'!
isActive
	"executing or waiting for user action but not terminated"
	^self isClosed not! !

!WebContext methodsFor: 'testing'!
isBusy
	^self isExecuting | self isInterrupted! !

!WebContext methodsFor: 'testing'!
isFirst
	"is this first/upper context in the chain?"
	^false! !

!WebContext methodsFor: 'testing'!
isLast
	"is this last/lower context in the chain?"
	^self child isNil! !

!WebContext methodsFor: 'testing'!
isWebElement
	"because some elements (like WebWindow, WebPage)  have a context as the parent"
	^false! !

!WebContext methodsFor: 'testing'!
mustNeverCache
	^true.    "is this safe enough? needs more testing. Mivsek apr20"

	"if ≈ôealtime, then reload pages always"
"	^self page isRealtimeEnabled"! !


!WebContext methodsFor: 'testing-states'!
isClosed
	"a context is already closed"
	^self state = #closed! !

!WebContext methodsFor: 'testing-states'!
isInterrupted
	"a context's process is in an interrupted state, waiting for subcontext to finish and close"
	^self state = #interrupted! !

!WebContext methodsFor: 'testing-states'!
isReady
	"a context is ready to execute"
	^self state = #ready! !


!WebContext methodsFor: 'private-other'!
other
	^other! !

!WebContext methodsFor: 'private-other'!
otherAt: aSymbol
	^self otherAt: aSymbol ifAbsent: [nil]! !

!WebContext methodsFor: 'private-other'!
otherAt: aSymbol ifAbsent: aBlock
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!WebContext methodsFor: 'private-other'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!WebContext methodsFor: 'private-other'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !


!WebContext methodsFor: 'private-states'!
setClosed
	"a context is already closed"
	self state:  #closed! !

!WebContext methodsFor: 'private-states'!
setReady
	"a context after creation"
	self state:  #ready! !

!WebContext methodsFor: 'private-states'!
state
	" #ready #closed "
	state ifNil: 
		[self setReady].
	^state! !

!WebContext methodsFor: 'private-states'!
state: aSymbol
	" #noprocess #idle #interrupted "
	state := aSymbol! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebContext class
	instanceVariableNames: ''!

!WebContext class methodsFor: 'accessing'!
contextIdName
	"query name for contexts in in URLs: 'aidaCtx=1456' "
	^'aidaCtx'! !


!WebContext class methodsFor: 'instance creation'!
newOn: aContext
	^super new 
		parent: aContext;
		setReady "an initial state"! !


WebContext subclass: #WebContextFirst
	instanceVariableNames: 'view queue sender'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!

!WebContextFirst methodsFor: 'accessing'!
app
	"the instance of WebApplication on which this context is executing"
	^self parent! !

!WebContextFirst methodsFor: 'accessing'!
first
	"first context up in the chain. In this case is me"
	^self! !

!WebContextFirst methodsFor: 'accessing'!
level
	"on which level this context is in context chain. First one has level 0"
	^0! !

!WebContextFirst methodsFor: 'accessing'!
parent: aWebApplication
	parent := aWebApplication! !

!WebContextFirst methodsFor: 'accessing'!
tabId
	"unique browser's tab id where this top context is executing"
	^self
		otherAt: #TabId
		ifAbsent: [nil]! !

!WebContextFirst methodsFor: 'accessing'!
tabId: aString
	"unique browser's tab id where this top context is executing"
	^self
		otherAt: #TabId
		put: aString! !

!WebContextFirst methodsFor: 'accessing'!
view
	"view on which context is executed"
	^view! !

!WebContextFirst methodsFor: 'accessing'!
view: aSymbol
	"view on which context is executed. #main is default"
	view := aSymbol isNil 
		ifTrue: [#main] 
		ifFalse: [aSymbol]! !


!WebContextFirst methodsFor: 'executing'!
close
	"close process if any, and release other things. It also removes itself from context chain"
	super close.
	self closeSender. "if happens to be still alive"
	self closeRealtimeConnections. "like WebSockets" "BEWARE, it can terminate current process!!"! !

!WebContextFirst methodsFor: 'executing'!
closeRealtimeConnections
	"like open WebSockets"
	self session ifNil: [^nil].
	self session realtimeHandler 
		connections copy do: [:conn | 
			conn context = self
				 ifTrue: [conn removeYourself] ]! !

!WebContextFirst methodsFor: 'executing'!
closeSender
	self sender ifNotNil: 
		[self sender terminate.
		self sender: nil]! !


!WebContextFirst methodsFor: 'initialize-release'!
initQueue
	"for sending commands back to browser"
	queue := OrderedCollection new.! !

!WebContextFirst methodsFor: 'initialize-release'!
initWindow
	self window:
		((WebPage newOnCtx: self)  "as subclass of WebWindow"
			parent: self)! !

!WebContextFirst methodsFor: 'initialize-release'!
removeOtherContextsOnSameTab
	"if this context is created on the same tab, cleanup older contexts on this tab"
	self app contexts values do: [:ctx |
		(ctx ~= self and: [ctx isFirst and: [ctx tabId = self tabId]]) ifTrue:
			["Transcript cr; show: '*** context first: remove other ctx same tab:'."
			ctx close] ]! !


!WebContextFirst methodsFor: 'testing'!
isFirst
	"is this first/upper context in the chain?"
	^true! !

!WebContextFirst methodsFor: 'testing'!
isRealtimeOpen
	"this context is served over realtime connection"
	^self session realtimeHandler
		isRealtimeOpenFor: self! !


!WebContextFirst methodsFor: 'accessing-visibility'!
isLoaded
	"page is loaded"
	^self 
		otherAt: #PageLoaded
		ifAbsent: [false]! !

!WebContextFirst methodsFor: 'accessing-visibility'!
resetLoaded
	"page unload"
	^self 
		otherAt: #PageLoaded
		put: false! !

!WebContextFirst methodsFor: 'accessing-visibility'!
setLoaded
	"page is loaded"
	^self 
		otherAt: #PageLoaded
		put: true! !


!WebContextFirst methodsFor: 'queuing'!
notifyQueueAddition
	"to send added command immediatelly if some realtime channel is open, otherwise 
	wait for current or next Ajax request"
	self isRealtimeOpen 
		ifFalse: [^nil]. "serve with Ajax"
	self sender 
		ifNotNil: [^nil]. "sender is already there to wait then send from queue"
	self sender: 
		[self senderProcess] "this process wil wait a bit then send a queue at once"
			fork! !

!WebContextFirst methodsFor: 'queuing'!
queue
	"for sending commands back to browser"
	queue ifNil: 
		[self initQueue].
	^queue! !

!WebContextFirst methodsFor: 'queuing'!
queueCommand: aWebCommand
	self queue 
		add: aWebCommand.
	self 
		notifyQueueAddition.! !

!WebContextFirst methodsFor: 'queuing'!
queueUpdateElement: anElement
	"this element is to be updated on the browser, stream it to a WebCommand and put into waiting queue"
	"Note that element to stream can be different than element to update. Example: "
	| stream toStream toUpdate |
"	Transcript cr; show: '*** context first:: queue update element'. "
	stream := WriteStream on: String new.
	toStream := anElement isWrapped  "wrapped <span> element?"
		ifFalse: [anElement ]
		ifTrue: [anElement parent copy]. 
	toStream setStreamInnerHtml. 
	toStream 
		streamHtmlTo: stream 
		for: nil 
		on: anElement creationContext session.
	toStream resetStreamInnerHtml.
	toUpdate := toStream.
	self queueCommand: 
		(WebCommand 
			newUpdate: toUpdate
			with: stream contents
			attributes: toUpdate attributes).
	anElement 
		releasePartially "keep simplified hierachy of elements with id and forms"! !

!WebContextFirst methodsFor: 'queuing'!
sender
	"a process sending from a queue"
	^sender! !

!WebContextFirst methodsFor: 'queuing'!
sender: aProcess
	"a process sending from a queue"
	sender := aProcess! !

!WebContextFirst methodsFor: 'queuing'!
senderProcess
	"wait 10ms then send all from queue at once"
	(Delay forMilliseconds: 10) wait.
	self session realtimeHandler 
		sendMesagesFromQueue. "if any realtime connection open. Also clear sent msgs from queue"
	self sender: nil.! !


!WebContextFirst methodsFor: 'private'!
printString
	^'aWebContextFirst id: ', self id printString, '
	state: ', self state, '
	view: ' , self view printString , '
	queue: ', (self queue isEmpty 
		ifTrue: ['empty'] 
		ifFalse: [self queue size printString, ' msgs'])! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebContextFirst class
	instanceVariableNames: ''!

!WebContextFirst class methodsFor: 'instance creation'!
newOn: aWebApplication
	^super new 
		parent: aWebApplication;
		setReady "an initial state"! !


Object subclass: #WebCounter
	instanceVariableNames: 'started day year dailyCounts hourlyCounts todayHourlyCounts total yearlyHistory'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebCounter commentStamp: '<historical>' prior: 0!
WebCounter for counting web requests daily and per hour. Mostly used in URLResolver for counting visits of pages.!


!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
addArray: aFirstArray to: aSecondArray

	1 to: aFirstArray size do: [:index |
		aSecondArray
			at: index
			put: (aFirstArray at: index) + (aSecondArray at: index)]! !

!WebCounter methodsFor: 'private'!
checkIfNewYear

	(SpDate today year = (self year + 1)) ifTrue:
		[self yearlyHistory
			at: self year
			put: self dailyCounts.
		self initDailyCounts.
		self year: SpDate today year].! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
dailyCounts
	"array of counters for each day in current year. When new year arrives, counters are 
	copied in a yearlyHistory"

	dailyCounts isNil ifTrue: [self initDailyCounts].
	^dailyCounts! !

!WebCounter methodsFor: 'private'!
day
	day isNil ifTrue: [self day: SpDate today dayOfYear].
	^day! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
day: aNumber
	day := aNumber! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
hourlyCounts
	"array of counters for each hour in a day."

	hourlyCounts isNil ifTrue: [self initHourlyCounts].
	^hourlyCounts! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
incDailyCounterOnDate: aDate
	aDate year = self year 
		ifTrue: 
			[self dailyCounts at: aDate day put: (self  dailyCounts at: aDate day) + 1]
		ifFalse:
			[self checkIfNewYear.
			self incHistoryCounterOnDate: aDate].! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
incHistoryCounterOnDate: aDate
	| array |
	aDate year < self year ifTrue: [^self error: 'future years not allowed'].
	array := (self yearlyHistory at: aDate year ifAbsentPut: [Array new: 366 withAll: 0] ).
	array at: aDate day put: (array at: aDate day)+1! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
incHourlyCounterOnTime: aTime
	| hours |
	hours := aTime hours.
	self hourlyCounts at: hours+1 	put: (self  hourlyCounts at: hours+1) + 1.! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
incHourlyCounterOnTimestamp: aTimestamp
	| hours |
	hours := aTimestamp asTime hours.
	self hourlyCounts at: hours+1 put: (self  hourlyCounts at: hours+1) + 1.
	self incTodayHourlyCounterOnTimestamp: aTimestamp! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
incTodayHourlyCounterOnTimestamp: aTimestamp

	| hours dayOfYear |
	dayOfYear := aTimestamp asDate day.
	self day ~= dayOfYear 	ifTrue: 
		[self initTodayHourlyCounts.
		self day: dayOfYear].
	hours := aTimestamp asTime hours.
	self todayHourlyCounts 
		at: hours+1
		put: (self  todayHourlyCounts at: hours+1) + 1.! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
incTotal

	self total: self total + 1.! !

!WebCounter methodsFor: 'private'!
printString

	^'aWebCounter total: ', self total printDotString! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
todayHourlyCounts
	"array of counters for each hour today."

	todayHourlyCounts isNil ifTrue: [self initTodayHourlyCounts].
	^todayHourlyCounts! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
total: aNumber
	total := aNumber.! !

!WebCounter methodsFor: 'private'!
year
	year isNil ifTrue: [self year: SpDate today year].
	^year! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
year: aNumber
	year := aNumber.! !

!WebCounter methodsFor: 'private' stamp: ' 21/4/07 22:07'!
yearlyHistory
	yearlyHistory isNil ifTrue: [self initYearlyHistory].
	^yearlyHistory! !


!WebCounter methodsFor: 'adding' stamp: ' 21/4/07 22:07'!
addCounter: aWebCounter
	"add counts from specified counter"
	aWebCounter year = self year ifTrue: 
		[self addArray: aWebCounter dailyCounts to: self dailyCounts].
	self addArray: aWebCounter hourlyCounts to: self hourlyCounts.
	self total: self total + aWebCounter total.
	aWebCounter yearlyHistory keysAndValuesDo: [:yr :array |
		self addArray: array to: (self yearlyHistory at: yr ifAbsentPut: [Array new: 366 withAll: 0]) ].

"WebCounter new addCounter: WebCounter new"! !


!WebCounter methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allCountsInYear: aYearNumber

	aYearNumber = self year 
		ifTrue: [^self dailyCounts copy]
		ifFalse: 
			[^(self yearlyHistory 
				at: aYearNumber 
				ifAbsent: [^Array new: 366 withAll: 0]) copy]! !

!WebCounter methodsFor: 'accessing'!
allCountsThatYear
	
	"return array of counts for each day in current year"

	^self allCountsInYear: SpDate today year! !

!WebCounter methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allHourlyCounts

	^self hourlyCounts copy! !

!WebCounter methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allTodayHourlyCounts

	^self todayHourlyCounts copy! !

!WebCounter methodsFor: 'accessing' stamp: 'mivsek 1/10/2008 19:19'!
countsFrom: aStartDate to: anEndDate

	| collection |
	collection := OrderedCollection new.
	aStartDate asDays to: anEndDate asDays do: [:days | 
		collection add: (self countsOnDate: (SpDate fromDays: days))].
	^collection! !

!WebCounter methodsFor: 'accessing'!
countsMonthlyFromDate: aDate
	| date collection |
	date := SpDate newDay: 1
		monthNumber: aDate monthIndex
		year: aDate year.
	collection := OrderedCollection new.
	[date < SpDate today] whileTrue:
		[collection add: (self countsOnMonth: date monthIndex year: date year).
		date := SpDate newDay: 1
			monthNumber: (date addDays: 31) monthIndex
			year: (date addDays: 31) year].
	^collection

"AIDASite default totalCounter countsMonthlyFromDate: (Date today subtractDays: 6)"! !

!WebCounter methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
countsMonthlyOnYear: aYear

	^(1 to: 12) collect: [:month | self countsOnMonth: month year: aYear]

"WebServer default totalCounter countsMonthlyOnYear: 1999"! !

!WebCounter methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
countsOnDate: aDate

	| counts |
	counts := self allCountsInYear: aDate year.
	^counts at: aDate day! !

!WebCounter methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
countsOnHour: aNumber

	^self hourlyCounts at: aNumber! !

!WebCounter methodsFor: 'accessing'!
countsOnMonth: aMonth year: aYear

	| counts date |
	date := SpDate newDay: 1 monthNumber: aMonth year: aYear.
	counts := self allCountsInYear: date year.
	^(date day to: date day + date daysInMonth - 1)
		inject: 0 into: [:sum :dy | sum + (counts at: dy)]

"AIDASite default totalCounter countsOnMonth: 10 year: 1999"! !

!WebCounter methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
countsTodayOnHour: aNumber

	^self todayHourlyCounts at: aNumber! !

!WebCounter methodsFor: 'accessing'!
currentWeekCounts
	"counts for every day in current week"
	| firstDay collection |
	firstDay := SpDate today subtractDays: SpDate today weekdayIndex + 1.
	collection := OrderedCollection new.
	firstDay asDays to: firstDay asDays + 6 do: [:days |
		collection add: (self countsOnDate: (SpDate fromDays: days))].
	^collection! !

!WebCounter methodsFor: 'accessing' stamp: 'janko 10/31/2008 16:05'!
started
	"return a timestamp, from when web visits are counted"

	started isNil ifTrue: [self initStarted].
	^SpTimestamp fromSeconds: started! !

!WebCounter methodsFor: 'accessing'!
today
	
	"return number of requests today"

	^self countsOnDate: SpDate today! !

!WebCounter methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
todayHourlyCounts: anObject
	todayHourlyCounts := anObject! !

!WebCounter methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
total
	"total number of visits, registered by this counter"

	total isNil ifTrue: [self initTotal].
	^total.! !

!WebCounter methodsFor: 'accessing' stamp: ' 21/8/07 09:38'!
weekly
	"total count in current week"
	^self currentWeekCounts inject: 0 into: [:sum :each | sum + each]! !

!WebCounter methodsFor: 'accessing' stamp: 'mivsek 1/10/2008 19:19'!
yesterday
	"return number of requests yesterday"
	^self countsOnDate: (SpDate today subtractDays: 1)! !


!WebCounter methodsFor: 'counting' stamp: ' 21/4/07 22:07'!
countRequest: aWebRequest

	"register a request by incrementing daily, hourly and total counter."

	self incCounterOnTimestamp: aWebRequest timestamp! !

!WebCounter methodsFor: 'counting' stamp: 'JM 4/25/2007 21:22'!
incCounter

	"increment daily, hourly and total counter with date and time now"

	self incCounterOnTimestamp: SpTimestamp now! !

!WebCounter methodsFor: 'counting' stamp: ' 21/4/07 22:07'!
incCounterOnTimestamp: aTimestamp

	"increment daily, hourly and total counter with date and time defined"

	
	self incDailyCounterOnDate: aTimestamp asDate.
	self incHourlyCounterOnTimestamp: aTimestamp.
	self incTotal.! !


!WebCounter methodsFor: 'initialize-release'!
initDailyCounts
	dailyCounts := Array new: 366 withAll: 0.
	self year: SpDate today year.! !

!WebCounter methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initHourlyCounts
	hourlyCounts := Array new: 24 withAll: 0.! !

!WebCounter methodsFor: 'initialize-release' stamp: 'JM 4/25/2007 21:22'!
initStarted
	"set a timestamp to a current time"
	started := SpTimestamp now asSeconds.! !

!WebCounter methodsFor: 'initialize-release'!
initTodayHourlyCounts

	todayHourlyCounts := Array new: 24 withAll: 0.
	self day: SpDate today day.! !

!WebCounter methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initTotal

	self total: 0.! !

!WebCounter methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initYearlyHistory
	yearlyHistory := Dictionary new.! !

!WebCounter methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
reset

	"set all counters to zero and set started timestamp to now. YOU WILL LOOSE ALL HISTORY
	OF COUNTS !! "

	self initDailyCounts.
	self initHourlyCounts.
	self initTotal.
	self initStarted.! !


!WebCounter methodsFor: 'testing' stamp: 'np 10/24/2008 12:57'!
isFirstOnDate: aDate sinceDays: nrOfDays
	"a first/new count since specified nr of days, when there were no counts"
	| since current |
	current := aDate day.
	since := (day - nrOfDays) max: 1. "well what about first 7 days in new year?"
	(self dailyCounts at: current) = 0 ifTrue: [^false].
	since to: current-1 do: [:d | (self dailyCounts at: d) > 0 ifTrue: [^false] ].
	^true! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebCounter class
	instanceVariableNames: ''!

!WebCounter class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
instVarMap
	"Gemstone odb"

	^super instVarMap,
		#( 	(todayHourlyCounts nil)	)! !

!WebCounter class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
replicationSpec
	"Gemstone"
	^super replicationSpec, 
	 	#( 	(started max 2)
			(day replicate)
			(year replicate)
			(dailyCounts max 2)
			(hourlyCounts max 2)
			(total replicate)
			(yearlyHistory stub)	)! !

!WebCounter class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
setupOdbStorage
	"Versant"

	self 
		store: #(started dailyCounts hourlyCounts total )
		as: #(Integer IntegerArray IntegerArray Integer).! !


!WebCounter class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new reset! !


!WebCounter class methodsFor: 'summing' stamp: ' 21/4/07 22:07'!
sumCounters: aCounterCollection

	"return a new counter with sum of all specified counters"
	| sumCounter |
	sumCounter := WebCounter new.
	aCounterCollection do: [:counter |
		sumCounter addCounter: counter].
	^sumCounter! !


!WebCounter class methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
throughMidnightTest

	Janko := WebCounter new.
	[100 timesRepeat: 
		[Janko incCounter.
		(Delay forSeconds: 1) wait]
	] fork.
	^Janko inspect

"WebCounter throughMidnightTest"! !

!WebCounter class methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
throughNewYearTest

	Janko := WebCounter new.
	[100 timesRepeat: 
		[Janko incCounter.
		(Delay forSeconds: 1) wait]
	] fork.
	^Janko inspect

"WebCounter throughNewYearTest"! !


Object subclass: #WebEvent
	instanceVariableNames: 'event element context pageUrl value'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebEvent commentStamp: 'janko 8/25/2012 17:11' prior: 0!
WebEvent holds details of event triggered on some element of web page. It is transfered as a JSON message from the browser.

!


!WebEvent methodsFor: 'accessing'!
app
	^self context app! !

!WebEvent methodsFor: 'accessing'!
context
	"a context in which this element occured"
	^context! !

!WebEvent methodsFor: 'accessing'!
element
	"a web element on which this handler responds to events" 
	^element! !

!WebEvent methodsFor: 'accessing'!
event
	"on which event this handler responds, like #click, #mouseOver etc." 
	^event! !

!WebEvent methodsFor: 'accessing'!
pageUrl
	"Url of the page on which this event occured"
	^pageUrl! !

!WebEvent methodsFor: 'accessing'!
pageView
	"get the view from the Url"
	| query view |
	query := self pageUrl readStream upTo: $? ; upToEnd.
	query := (query readStream upTo: $# ) trimBlanks. "skip #anchor if any"
	(query isEmpty or: [(query findString: 'view=' startingAt: 1) = 0]) ifTrue: [^#main].
	view := query readStream upToAll: 'view';  skip: 5 "view="; upTo: $& .
	 ^view asSymbol! !

!WebEvent methodsFor: 'accessing'!
relativeUrl
	"from page Url, without host and query part"
	| stream relative ch |
	stream := self pageUrl readStream.
	stream upTo: $/; upTo: $/; upTo: $/ . "skip protocol and hostname"
	relative := WriteStream on: String new.
	[stream atEnd] whileFalse:   "up to query part or #, if any"
		[ch := stream next. 
		(ch = $? or: [ch = $#]) 
			ifTrue: [stream upToEnd]
			ifFalse: [relative nextPut: ch] ].
	^'/', relative contents! !


!WebEvent methodsFor: 'private'!
context: aWebContextOrNumber
	context := aWebContextOrNumber! !

!WebEvent methodsFor: 'private'!
element: aWebElementOrId
	element := aWebElementOrId! !

!WebEvent methodsFor: 'private'!
event: aSymbol
	event := aSymbol! !

!WebEvent methodsFor: 'private'!
pageUrl: aString
	"Url of the page on which this event occured"
	pageUrl := aString! !

!WebEvent methodsFor: 'private'!
printString
	^'aWebEvent
	event: ', self event printString, '
	element: ', (self element notNil 
		ifTrue: [(self element isKindOf: Symbol) 
			ifTrue: [self element printString] 
			ifFalse: [self element class name, ' id: ', self element id printString] ]
		ifFalse: ['nil']), '
	context: ', (self context notNil 
		ifTrue: [(self context isKindOf: Number)  
			ifTrue: [self context printString] 
			ifFalse: [self context class name, 
				(self context isFirst not ifTrue: [' popup '] ifFalse: [' ']), 
				self context id printString] ]
		ifFalse: ['nil'] ), '
	value: ', self value printString! !

!WebEvent methodsFor: 'private'!
value: aString
	"corresponding value, if any. Like field value in submit event"
	value := aString! !


!WebEvent methodsFor: 'parsing'!
fromJSON: aString
	"get an event from JSON message"
	| dict |
	aString ifNil: [^self].
	aString trimBlanks isEmpty ifTrue: [^self].
	dict := WebJSON parse: aString.
	self 	event: (dict at: 'event') asSymbol. "event is mandatory"
	(dict at: 'id') notNil ifTrue: 
		[self element: (dict at: 'id') asSymbol].
	(dict at: 'context') notNil ifTrue: 
		[self context: (dict at: 'context') asInteger]. "context is mandatory except for page events"
	self pageUrl: (AIDASite convertFromWebString: (dict at: 'pageUrl')). "also mandatory"
	(dict includesKey: 'value') ifTrue: 
		[self value: (dict at: 'value')].! !

!WebEvent methodsFor: 'parsing'!
reconnectOn: aSession
	"find a right element and a context (at start we have only their ids)"
	| object app e |
	self pageUrl ifNil: [^nil].
	object := aSession site urlResolver 
		objectOnUrl: self relativeUrl.
	app := aSession webAppFor: object. 
	app ifNil: [^nil].
	self context: 
		(app contexts 
			at: context 
			ifAbsent: [^nil]).
	e := self context 
		elementId: self element.
	e ifNil: 
		[self event = #unload ifTrue: [^nil]. "probalby late unload event, just ignore it"
		self event = #submit
			ifTrue: [^self error: 'Unknown element,  #noSubmit missing before onClick... on a button?']
			ifFalse: [^self error: 'Unknown element. Is its id proprely registered in creation context?'] ].
	self element: e.! !


!WebEvent methodsFor: 'testing'!
isAjaxRequest
	^false! !

!WebEvent methodsFor: 'testing'!
isClassicalRequest
	"classical requests are non Ajax HTTPRequests, not WebEvents"
	^false! !

!WebEvent methodsFor: 'testing'!
isWebEvent
	^true! !

!WebEvent methodsFor: 'testing'!
isWebRequest
	^false! !


!WebEvent methodsFor: 'accessing-value'!
postData
	"parse a submited form in value into a postData with key/value pairs"
	"From Swazoo HTTPPost>>urlencodedDataFrom:"
	| postData tokens |
	postData := HTTPPostDataArray new.
	tokens := HTTPString subCollectionsFrom: (HTTPString stringFromBytes: self value) delimitedBy: $&.
	(tokens collect: [:each | HTTPString subCollectionsFrom: each delimitedBy: $=]) 
		do: 	[:keyVal | | datum key |
			datum := HTTPPostDatum new.
			datum value: (HTTPString decodedHTTPFrom: 
 				(keyVal last collect: [:char | char = $+ ifTrue: [Character space] ifFalse: [char]])).
			key := (HTTPString decodedHTTPFrom: 
 				(keyVal first collect: [:char | char = $+ ifTrue: [Character space] ifFalse: [char]])).
			postData at: key put: datum].
	^postData

"WebEvent new value: 'a=&c=d'; postData"! !

!WebEvent methodsFor: 'accessing-value'!
postKeysAndValuesDo: aTwoArgBlock 
	self postData 
		keysAndValuesDo: [:key :each | aTwoArgBlock value: key value: each value]! !

!WebEvent methodsFor: 'accessing-value'!
value
	"corresponding value, if any. Like field value in submit event"
	^value! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebEvent class
	instanceVariableNames: ''!

!WebEvent class methodsFor: 'instance creation'!
newFromJSON: aJSONString
	^super new
		fromJSON: aJSONString! !


Object subclass: #WebEventHandler
	instanceVariableNames: 'event element actionBlocks'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebEventHandler commentStamp: 'janko 8/25/2012 17:12' prior: 0!
WebEventHandler registers and then responds to events (like onClick) on elements of web page

!


!WebEventHandler methodsFor: 'private'!
actionBlocks
	actionBlocks isNil ifTrue: [self initActionBlocks].
	^actionBlocks! !

!WebEventHandler methodsFor: 'private'!
element: aWebElement
	element := aWebElement! !

!WebEventHandler methodsFor: 'private'!
event: aSymbol
	event := aSymbol! !


!WebEventHandler methodsFor: 'actions'!
addAcceptPostedInput
	"event is a post of form element input, accept it"
	^self addActionBlock: [:receivedEvent || field |
		field := receivedEvent element.
		field acceptInputFromValue: receivedEvent value.
		field announceChange.
		(field isSingleFieldPost and: [field isValid])
			ifTrue: [field save] ] "otherwise save at complete form submit"! !

!WebEventHandler methodsFor: 'actions'!
addAcceptSubmittedForm
	"event is a submit of a form, accept it"
	^self addActionBlock: [:receivedEvent || form |
		form := receivedEvent element form.
		form acceptFormInputFrom: receivedEvent.
		form isValid ifTrue: [form save].
		form allFields do: [:field | 
			field isButton ifFalse: "don't handle itself once again"
				[field handleSubmitEvent: receivedEvent] ] ]  "call #submit event blocks on all form fields "! !

!WebEventHandler methodsFor: 'actions'!
addActionBlock: aBlock
	^self actionBlocks add: aBlock! !

!WebEventHandler methodsFor: 'actions'!
addAnswer: anObject
	"set answer to current context"
	^self addActionBlock:
		[:receivedEvent |
		receivedEvent context answer: anObject].! !

!WebEventHandler methodsFor: 'actions'!
addPageBlur
	"blur event: page not anymore in user focus"
	^self addActionBlock:
		[:receivedEvent |
"		Transcript cr; show: 'event handler: page blur/unfocus event on context ', 
			receivedEvent context id printString. "
		]! !

!WebEventHandler methodsFor: 'actions'!
addPageFocus
	"focus event: page in user focus"
	^self addActionBlock:
		[:receivedEvent |
"		Transcript cr; show: 'event handler: page focus event on context ', receivedEvent context id printString.  "
		]! !

!WebEventHandler methodsFor: 'actions'!
addPageLoad
	"load event: page (in browser tab or window) was loaded successfuly"
	^self addActionBlock:
		[:receivedEvent |
"		Transcript cr; show: 'event handler: page load event on context ', 
			receivedEvent context id printString,
			' and ', (receivedEvent value notNil ifTrue: [receivedEvent value] ifFalse: ['tab nil']).
"		receivedEvent context 
			tabId: receivedEvent value;
			setLoaded;
			removeOtherContextsOnSameTab]! !

!WebEventHandler methodsFor: 'actions'!
addPageUnload
	"unload event: page (in browser tab or window) was closed"
	^self addActionBlock:
		[:receivedEvent |
"		Transcript cr; show: 'event handler: page unload event on context ', 
			receivedEvent context id printString. 
"		receivedEvent context 
			resetLoaded;
			close]! !

!WebEventHandler methodsFor: 'actions'!
addUpdate: anElement with: anArgObject
	^self addActionBlock:
		[:receivedEvent |
		anElement updateWith: anArgObject] "if any (not nil)"! !

!WebEventHandler methodsFor: 'actions'!
handleEvent: aWebEvent
	"Execute all action blocks in order and return result of the last. Result of last 
	action block should be a kind of WebElement"
	| result |
"	Transcript cr; show: 'handler: handle event ', aWebEvent printString. "
	self actionBlocks do: [:actionBlock | 
		result := actionBlock numArgs = 0 
			ifTrue: [actionBlock value]  "onClickDo: blocks have usually no argument"
			ifFalse: [actionBlock value: aWebEvent] ].
	^result  "only last result is returned, is that ok? "! !


!WebEventHandler methodsFor: 'actions-popup'!
addCloseWindow
	"closes that popup window and also its execution context"
	| popupCtx parentCtx |
	^self addActionBlock:
		[:receivedEvent |
		popupCtx := receivedEvent context. 
		popupCtx isFirst ifFalse: " otherwise a top window with aWebContextFirst cannot be closed"
			[parentCtx := popupCtx parent.
			popupCtx result: WebElement basicNew.
			parentCtx 
				result: popupCtx result; "just in case"
				answer: popupCtx answer. "if any"
			receivedEvent context: parentCtx. " switch back to parent context as currently executing context"
			parentCtx window popupStub update. "to actually close popup window on browser"
			self runCloseEventHandler. "to run all action blocks on #close pseudo event"
			popupCtx window afterCloseUpdate ifNotNil: 
				[popupCtx window afterCloseUpdate updateWith: 
					popupCtx window afterCloseUpdate creationArgument "if any"].
			popupCtx close]  "finaly the time to safely close popup context "
			]! !

!WebEventHandler methodsFor: 'actions-popup'!
addPopup: anElement onStub: aStubElement
	"WebElement onClickPopup:thenUpdate: installs this event handler. After click it is triggered and this action block is called from a WebApplication respondToEvent: to update popup element. In the following WebApplication wrap:intoPopupWidow:  an updated element will be wraped in popup window and replace the parent window stub to show itself on the overlay as popup"
	^self addActionBlock:
		[:receivedEvent | | parentCtx |
			anElement isActive not ifTrue:  "recreate back to be updatable again for popup"
				[parentCtx := self firstContextFromStack parent.
				anElement
					basicCreationContext: parentCtx;
					parent: parentCtx window; "well, just something"
					resetOldAfterUpdate].
			anElement
				resetStubForPopup; "now it will become visible" 
				resetShallQueue; "queue not in #update but after popup is wraped into window in WebApplication wrap..."
				updateWith: anElement creationArgument "if any"]! !

!WebEventHandler methodsFor: 'actions-popup'!
runCloseEventHandler
	"run all action blocks on the closed widget if any, on #close pseudo event"
	| wdget handler |
	wdget := self element widget.
	wdget ifNil: [^nil].
	handler := wdget eventHandlerFor: #close.
	handler notNil ifTrue:
		[^handler handleEvent: nil]. "event is not important"! !


!WebEventHandler methodsFor: 'accessing'!
context
	"a web exectution context on which element with this handler was created"
	^self element context! !

!WebEventHandler methodsFor: 'accessing'!
element
	"a web element on which this handler responds to events" 
	^element! !

!WebEventHandler methodsFor: 'accessing'!
event
	"on which event this handler responds, like #click, #mouseOver etc." 
	^event! !


!WebEventHandler methodsFor: 'initialize-release'!
initActionBlocks
	actionBlocks := OrderedCollection new.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebEventHandler class
	instanceVariableNames: ''!

!WebEventHandler class methodsFor: 'instance creation'!
newForEvent: aSymbol on: aWebElement 
	^super new
		element: aWebElement;
		event: aSymbol! !


Object subclass: #WebGeolocation
	instanceVariableNames: 'timestamp latitude longitude accuracy altitude latitudeAccuracy heading speed'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!

!WebGeolocation methodsFor: 'accessing'!
accuracy
	"accuracy of latitude and longitude, in meters"
	^accuracy! !

!WebGeolocation methodsFor: 'accessing'!
latitude
	 "distance north or south of equator, in decimal degrees"
	^latitude! !

!WebGeolocation methodsFor: 'accessing'!
locationPoint
	^self latitude@self longitude! !

!WebGeolocation methodsFor: 'accessing'!
longitude
	^longitude! !

!WebGeolocation methodsFor: 'accessing'!
timestamp
	"timestamp of location"
	^timestamp! !


!WebGeolocation methodsFor: 'private'!
accuracy: anInteger
	accuracy := anInteger! !

!WebGeolocation methodsFor: 'private'!
altitude: anInteger
	altitude := anInteger! !

!WebGeolocation methodsFor: 'private'!
altitudeAccuracy: anInteger
	altitudeAccuracy := anInteger! !

!WebGeolocation methodsFor: 'private'!
heading: anInteger
	heading := anInteger! !

!WebGeolocation methodsFor: 'private'!
latitude: aDouble
	latitude := aDouble! !

!WebGeolocation methodsFor: 'private'!
longitude: aDouble
	longitude := aDouble! !

!WebGeolocation methodsFor: 'private'!
speed: anInteger
	speed := anInteger! !

!WebGeolocation methodsFor: 'private'!
timestamp: aSpTimestamp
	timestamp := aSpTimestamp! !


!WebGeolocation methodsFor: 'accessing-additional'!
altitude
	"the height of the user's location, in meter"
	^altitude! !

!WebGeolocation methodsFor: 'accessing-additional'!
altitudeAccuracy
	"altitude accuracy in meters, nil if no altitude provided"
	^altitudeAccuracy! !

!WebGeolocation methodsFor: 'accessing-additional'!
heading
	"direction of travel, in degrees relative to true north"
	^heading! !

!WebGeolocation methodsFor: 'accessing-additional'!
speed
	"ground speed in meters per second"
	^speed! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebGeolocation class
	instanceVariableNames: ''!

!WebGeolocation class methodsFor: 'distance formula'!
distanceBetween: aFirstPoint and: aSecondPoint
	"in Km between latitude1@longitide1 and  latitude2@longitide2"
	" By harversine formula http://www.movable-type.co.uk/scripts/latlong.html"
	| radius d2r dlat dlon lat1 lat2 a  c |
	radius := 6371. "earth radius in Km"
	d2r := 0.0174532925199433d.  "Pi / 180, for conversion to radians"
	dlat := (aSecondPoint x - aFirstPoint x) * d2r.
	dlon := (aSecondPoint y - aFirstPoint y) * d2r.
	lat1 := (aFirstPoint x) * d2r.
	lat2 := (aSecondPoint x) * d2r.
	a := (((dlat / 2) sin) ** 2) + 
		((((dlon / 2) sin) ** 2) * (lat1 cos) *  (lat2 cos)).
	c := 2 * (a sqrt) aidaArcTan: (1 - a) sqrt.
	^ radius * c.

"
| p1 p2 comment |
p1 := 45.880181d@13.90561d. comment := 'MRP Ajdovscina'.
p2 := 46.092728d@14.482335. comment := 'MRP Ljubljana'.
self distanceBetween: p1 and: p2.
"! !


!WebGeolocation class methodsFor: 'instance creation'!
newFromJSON: aString
	| html5Position coords location |
	html5Position := WebJSON parse: aString.
	((html5Position isKindOf: Collection) and: [html5Position notEmpty]) ifFalse: [^nil].
	coords := html5Position at: 'coords'.
	location := self new.
	location 
		latitude: (coords at: 'latitude');
		longitude: (coords at: 'longitude');
		accuracy: (coords at: 'accuracy');
		altitude: (coords at: 'altitude' ifAbsent: [nil]);
		altitudeAccuracy: (coords at: 'altitudeAccuracy' ifAbsent: [nil]);
		speed: (coords at: 'speed' ifAbsent: [nil]);
		heading: (coords at: 'heading' ifAbsent: [nil]);
		timestamp: SpTimestamp now "(SpTimestamp fromUTCString: (html5Position at: 'timestamp'))".
	^location! !


Object subclass: #WebJSON
	instanceVariableNames: 'stream ctorMap'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebJSON commentStamp: '<historical>' prior: 0!
WebJSON to serialize and parse in JSON format. 

	WebJSON parse: aString
	WebJSON stringify: anObject

anObject can be Collection or Dictionary, or String, Number, True, False, Undefined. Or combination of them.

Based on JSON package from SqueakSource done by Tony Garnock-Jones.!


!WebJSON methodsFor: 'private-parsing'!
consume: aString1 or: aString2 returning: anObject
	| inx max c ch1 ch2 |
	inx := 1. max := aString1 size max: aString2 size.
	[inx <= max] whileTrue:
		[c := self next.
		ch1 := inx <= aString1 size ifTrue: [aString1 at: inx] ifFalse: [nil].
		ch2 := inx <= aString2 size ifTrue: [aString2 at: inx] ifFalse: [nil].
		(ch1 = c and: [inx = aString1 size]) 
			ifTrue: [^anObject].
		(ch2 = c and: [inx = aString2 size]) 
			ifTrue: [^anObject].
		(ch1 = c) | (ch2 = c) 
			ifFalse: [^self error: 'Expected ', aString1, ' or ', aString2].
		inx := inx +1].
	^ anObject

"WebJSON new 
	stream: 'null' readStream; 
	consume: 'null' or: 'nan' returning: nil "
"WebJSON new 
	stream: 'nan' readStream; 
	consume: 'null' or: 'nan' returning: nil "
"WebJSON new 
	stream: 'non' readStream; 
	consume: 'null' or: 'nan' returning: nil "! !

!WebJSON methodsFor: 'private-parsing'!
consume: aString returning: anObject
	aString do: [:c | self next == c ifFalse: [self error: 'Expected ''', aString, ''''] ].
	^ anObject! !

!WebJSON methodsFor: 'private-parsing' stamp: 'jm 12/15/2010 00:06'!
interpretStringEscape
	| c |
	c := self next.
	c == $b ifTrue: [^ Character backspace].
	c == $n ifTrue: [^ Character lf].
	c == $f ifTrue: [^ Character newPage].
	c == $r ifTrue: [^ Character cr].
	c == $t ifTrue: [^ Character tab].
	^ c.! !

!WebJSON methodsFor: 'private-parsing'!
next
	^ self stream next! !

!WebJSON methodsFor: 'private-parsing'!
numberFrom: aString
	"Integer, Float or Double"
	"WebJSON new numberFrom: '14.49156' "
	| nrDecimals clean pos exponent result sign |
	(aString includes: $. ) ifFalse: [^aString asNumber].
	nrDecimals := aString size - (aString indexOf: $. ).
	sign := aString detect: [:ch | ch = $- | ch isDigit].
	sign = $- ifTrue: [sign := -1] ifFalse: [sign := 1].
	clean := aString select: [:ch | ch isDigit | (ch = $. )].
	pos := clean indexOf: $. .
	pos = 0 
		ifTrue: [result := clean asInteger asFloat]
		ifFalse: 
			[exponent := pos - 2.
			clean := clean select: [:ch | ch isDigit].
			result := nrDecimals <= 4 ifTrue: [0.0] ifFalse: [0.0d].
			clean do: [:digit | 
				result := result + ((digit asInteger - $0 asInteger) * (10**exponent)).
				exponent := exponent - 1]].
	^result * sign! !

!WebJSON methodsFor: 'private-parsing'!
peek
	^ self stream peek! !

!WebJSON methodsFor: 'private-parsing'!
readArray
	| a needComma |
	a := OrderedCollection new.
	needComma := false.
	[
		self skipWhitespace.
		self peek == $] ifTrue: [self next. ^ a asArray].
		needComma
			ifTrue: [self peek == $, ifFalse: [ILJsonSyntaxError signal: 'Missing comma'].
					self next.]
			ifFalse: [needComma := true]. 
		a add: self parseAny.
	] repeat.! !

!WebJSON methodsFor: 'private-parsing'!
readConstructor
	| s c v ctor |
	s := WriteStream on: ''.
	[
		c := self peek.
		c ifNil: [ILJsonSyntaxError signal: 'Premature EOF reading constructor name'].
		((c == $.) or: [c isLetter])
			ifTrue: [s nextPut: c. self next]
			ifFalse: [
				v := self parseAny.
				s := s contents.
				ctor := ctorMap ifNotNil: [ctor := ctorMap at: s ifAbsent: [nil]].
				ctor ifNil: [ILJsonSyntaxError signal: 'Unknown ctor ', s].
				^ ctor constructFromJson: v]
	] repeat.! !

!WebJSON methodsFor: 'private-parsing'!
readDictionary
	"OBSOLETE, use #readJsonObject instead"
	| m k v needComma |
	m := Dictionary new.
	needComma := false.
	[
		self skipWhitespace.
		self peek == $} ifTrue: [self next. ^ m].
		needComma
			ifTrue: [self peek == $, ifFalse: [ILJsonSyntaxError signal: 'Missing comma'].
					self next. self skipWhitespace]
			ifFalse: [needComma := true.].
		self next == $" ifFalse: [ILJsonSyntaxError signal: 'Key in dictionary must be string'].
		k := self readString.
		self skipWhitespace.
		self peek == $: ifFalse: [ILJsonSyntaxError signal: 'Missing colon'].
		self next.
		v := self parseAny.
		m at: k put: v.
	] repeat.! !

!WebJSON methodsFor: 'private-parsing'!
readJsonObject
	| m k v needComma |
	m := WebJSONObject new.
	needComma := false.
	[
		self skipWhitespace.
		self peek == $} ifTrue: [self next. ^ m].
		needComma
			ifTrue: [self peek == $, ifFalse: [self error: 'Missing comma'].
					self next. self skipWhitespace]
			ifFalse: [needComma := true.].
		self next == $" ifFalse: [self error: 'Key in dictionary must be string'].
		k := self readString.
		self skipWhitespace.
		self peek == $: ifFalse: [self error: 'Missing colon'].
		self next.
		v := self parseAny.
		m at: k put: v.
	] repeat.! !

!WebJSON methodsFor: 'private-parsing'!
readNumber
	| str ch |
	str := WriteStream on: String new.
	[
		ch := self peek.
		(ch isNil not and: [self class numbersMayContain: ch]) ifFalse: [
			[^self numberFrom: str contents] on: Error do: [self error: 'Invalid number']].
		str nextPut: ch.
		self next.
	] repeat.! !

!WebJSON methodsFor: 'private-parsing'!
readString
	| str ch |
	str := WriteStream on: String new.
	[
		ch := self next.
		ch == $\
			ifTrue: [str nextPut: self interpretStringEscape.]
			ifFalse: [ch == $" ifTrue: [^ str contents.].
					str nextPut: ch]
	] repeat.! !

!WebJSON methodsFor: 'private-parsing'!
skipComment
	self peek == $/ ifTrue: [
		self next.
		self peek == $/
			ifTrue: [self skipToEndOfLine]
			ifFalse: [self peek == $*
						ifTrue: [self next. self skipCommentBody]
						ifFalse: [ILJsonSyntaxError signal: 'Invalid comment syntax']]]! !

!WebJSON methodsFor: 'private-parsing'!
skipCommentBody
	[
		[self next == $*] whileFalse.
		self peek == $/
	] whileFalse.
	self next. "skip that last slash"
	self skipWhitespace.! !

!WebJSON methodsFor: 'private-parsing'!
skipToEndOfLine
	[self peek == Character cr or: [self peek == Character lf]] whileFalse: [self next].
	self skipWhitespace! !

!WebJSON methodsFor: 'private-parsing' stamp: 'janko 8/30/2013 15:16'!
skipWhitespace
	self stream atEnd not ifTrue: 
		[[self peek isSeparator] whileTrue: [self next].
		self skipComment].! !


!WebJSON methodsFor: 'accessing'!
ctorMap
	^ctorMap! !

!WebJSON methodsFor: 'accessing'!
ctorMap: m
	ctorMap := m! !

!WebJSON methodsFor: 'accessing'!
stream
	"Answer the value of stream"

	^ stream! !

!WebJSON methodsFor: 'accessing'!
stream: anObject
	"Set the value of stream"

	stream := anObject! !


!WebJSON methodsFor: 'private-serializing'!
jsonCollection: aCollection on: aStream
	| needComma |
	needComma := false.
	aStream nextPut: $[.
	aCollection do: [:element |
		needComma
			ifTrue: [ aStream nextPutAll: ', ' ]
			ifFalse: [ needComma := true ].
		self jsonObject: element on: aStream].
	aStream nextPut: $].! !

!WebJSON methodsFor: 'private-serializing'!
jsonDictionary: aDictionary on: aStream
	| needComma |
	needComma := false.
	aStream nextPut: ${.
	aDictionary keysAndValuesDo: [:key :value |
		needComma
			ifTrue: [ aStream nextPutAll: ', ' ]
			ifFalse: [ needComma := true ].
"		self jsonKey: key asString on: aStream. "
		self jsonString: key asString on: aStream.
		aStream nextPutAll: ': '.
		self jsonObject: value on: aStream].
	aStream nextPut: $}.! !

!WebJSON methodsFor: 'private-serializing'!
jsonFalseOn: aStream
	aStream nextPutAll: 'false'! !

!WebJSON methodsFor: 'private-serializing'!
jsonJsonObject: aDictionary on: aStream
	| needComma |
	needComma := false.
	aStream nextPut: ${.
	aDictionary keysAndValuesDo: [:key :value |
		needComma
			ifTrue: [ aStream nextPutAll: ', ' ]
			ifFalse: [ needComma := true ].
		self jsonString: key asString on: aStream.
		aStream nextPutAll: ': '.
		self jsonObject: value on: aStream].
	aStream nextPut: $}.! !

!WebJSON methodsFor: 'private-serializing'!
jsonKey: aString on: aStream
	| replacement |
	aString do: [:ch |
		replacement := self class escapeForCharacter: ch.
		replacement
			ifNil: [ aStream nextPut: ch ]
			ifNotNil: [ aStream nextPut: $\; nextPut: replacement ] ].! !

!WebJSON methodsFor: 'private-serializing'!
jsonNilOn: aStream
	aStream nextPutAll: 'null'! !

!WebJSON methodsFor: 'private-serializing'!
jsonNumber: aNumber on: aWriteStream 
	aWriteStream nextPutAll: aNumber asString.! !

!WebJSON methodsFor: 'private-serializing'!
jsonObject: anObject on: aStream
	(anObject isKindOf: String) ifTrue: [^self jsonString: anObject on: aStream].
	(anObject isKindOf: Number) ifTrue: [^self jsonNumber: anObject on: aStream].
	(anObject isKindOf: Dictionary) ifTrue: [^self jsonDictionary: anObject on: aStream].
	(anObject isKindOf: Collection) ifTrue: [^self jsonCollection: anObject on: aStream].
	(anObject isKindOf: WebJSONObject) ifTrue: [^self jsonJsonObject: anObject on: aStream].
	anObject isNil ifTrue: [^self jsonNilOn: aStream].
	anObject = true ifTrue: [^self jsonTrueOn: aStream].
	anObject = false ifTrue: [^self jsonFalseOn: aStream].! !

!WebJSON methodsFor: 'private-serializing'!
jsonString: aString on: aStream
	| replacement |
	aStream nextPut: $".
	aString do: [:ch |
		replacement := self class escapeForCharacter: ch.
		replacement
			ifNil: [ aStream nextPut: ch ]
			ifNotNil: [ aStream nextPut: $\; nextPut: replacement ] ].
	aStream nextPut: $".! !

!WebJSON methodsFor: 'private-serializing'!
jsonTrueOn: aStream
	aStream nextPutAll: 'true'! !


!WebJSON methodsFor: 'parsing'!
parseAny
	"This is the main entry point for the JSON parser. See also readFrom: on the class side."
	| c |
	self skipWhitespace.
	c := self peek asLowercase.
	c == ${ ifTrue: [self next. ^ self readJsonObject].
	c == $[ ifTrue: [self next. ^ self readArray].
	c == $" ifTrue: [self next. ^ self readString].
	c == $t ifTrue: [^ self consume: 'true' returning: true].
	c == $f ifTrue: [^ self consume: 'false' returning: false].
	c == $n ifTrue: [^ self consume: 'null' or: 'nan' returning: nil].
	c == $@ ifTrue: [self next. ^ self readConstructor].
	(WebJSON numbersMayContain: c) ifTrue: [^ self readNumber].
	self error: 'Unknown Json input'! !

!WebJSON methodsFor: 'parsing'!
parseFrom: aStream
	self stream: aStream.
	^ self parseAny! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebJSON class
	instanceVariableNames: ''!

!WebJSON class methodsFor: 'private'!
characterEscapeMap
	"WebJSON initCharacterEscapeMap"
	CharacterEscapeMap isNil ifTrue: [self initCharacterEscapeMap].
	^CharacterEscapeMap! !

!WebJSON class methodsFor: 'private'!
escapeForCharacter: c
	^ self characterEscapeMap at: c ifAbsent: [nil]! !

!WebJSON class methodsFor: 'private'!
initCharacterEscapeMap
	"WebJSON initCharacterEscapeMap"
	CharacterEscapeMap := Dictionary new
		add: $" -> $";
		add: $\ -> $\;
		add: Character backspace -> $b;
		add: Character lf -> $n;
		add: Character newPage -> $f;
		add: Character cr -> $r;
		add: Character tab -> $t;
		yourself.! !

!WebJSON class methodsFor: 'private'!
mimeType
	^'application/json'! !

!WebJSON class methodsFor: 'private'!
newWithConstructors: aCollection
	| m |
	m := Dictionary new.
	aCollection do: [:each |
		(each isKindOf: Association)
			ifTrue: [m add: each]
			ifFalse: [m at: each name greaseString put: each]].
	^ self new ctorMap: m; yourself.! !

!WebJSON class methodsFor: 'private'!
numbersMayContain: aChar
	^ aChar isDigit or: [#($- $+ $. $e $E) includes: aChar]! !


!WebJSON class methodsFor: 'parsing'!
parse: aString
	^self parseFrom: aString readStream! !

!WebJSON class methodsFor: 'parsing'!
parseFrom: aStream
	^self new parseFrom: aStream! !


!WebJSON class methodsFor: 'serializing'!
stringify: anObject
	| stream |
	stream := WriteStream on: String new.
	self new jsonObject: anObject on: stream.
	^stream contents.! !


Object subclass: #WebJSONObject
	instanceVariableNames: 'attributes'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebJSONObject commentStamp: '<historical>' prior: 0!
WebJSONObject is an imitation of JavaScript Object. It is an ordered collection of key->value associations.

Instance Variables
	attributes	<OrderedCollection>	attributes/instance variables
!


!WebJSONObject methodsFor: 'accessing' stamp: 'janko 8/30/2013 15:15'!
add: anAssociation
	^self at: anAssociation key put: anAssociation value "to prevent duplicates"! !

!WebJSONObject methodsFor: 'accessing'!
at: aKey
	^self at: aKey ifAbsent: [nil]! !

!WebJSONObject methodsFor: 'accessing'!
at: aKey ifAbsent: absentBlock
	^(self attributes 
		detect: [:assoc | assoc key = aKey]
		ifNone: [^absentBlock value])
			value! !

!WebJSONObject methodsFor: 'accessing'!
at: aKey put: aValue
	| existing |
	existing := self at: aKey.
	existing notNil
		ifTrue: [existing value: aValue]
		ifFalse: [self attributes add: (Association key: aKey value: aValue)].
	^aValue! !


!WebJSONObject methodsFor: 'private'!
attributes
	attributes ifNil: [self initAttributes].
	^attributes! !

!WebJSONObject methodsFor: 'private'!
initAttributes
	attributes := OrderedCollection new.! !


!WebJSONObject methodsFor: 'testing'!
includesKey: aKey
	^self attributes contains: [:assoc | assoc key = aKey]! !


!WebJSONObject methodsFor: 'enumerating'!
keysAndValuesDo: aBlock
	self attributes do: [:assoc | 
		aBlock value: assoc key value: assoc value]! !


Object subclass: #WebJSONPresenter
	instanceVariableNames: 'session observee presenterBlock other'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebJSONPresenter commentStamp: '<historical>' prior: 0!
WebJSONPresenter presents a domain object in JSON format.

Domain object must implement a method #asJson. Object's URL must end with '.json' and it will automatically be directed to that presenter.

Later it will be extendable like WebApplication. Say for Person a PersonJson, or something like that. 
!


!WebJSONPresenter methodsFor: 'accessing'!
aidaContentType
	^'application/json'! !

!WebJSONPresenter methodsFor: 'accessing'!
observee
	"return reference to an object, for which this app acts as an observer - to make an user interface
	of them"
	^observee! !

!WebJSONPresenter methodsFor: 'accessing'!
presenterBlock
	"this block will be executed in streaming phase. [self observee asJson] is default"
	presenterBlock ifNil: [self initDefaultPresenterBlock].
	^presenterBlock! !

!WebJSONPresenter methodsFor: 'accessing'!
presenterBlock: aBlock
	presenterBlock := aBlock! !

!WebJSONPresenter methodsFor: 'accessing'!
session
	"on which this App represent the observed domain object"
	^session! !

!WebJSONPresenter methodsFor: 'accessing'!
site
	"reference to a site on which this app shows some object. "
	^self session site! !


!WebJSONPresenter methodsFor: 'private'!
aidaIsRespondingNeverStreamed
	^false! !

!WebJSONPresenter methodsFor: 'private' stamp: 'janko 4/25/2012 10:59'!
aidaIsRespondingStreamed
	^false! !

!WebJSONPresenter methodsFor: 'private'!
observee: anObject
	"set the reference to an object, for which this app acts as an observer - to make an user interface
	of them"
	observee := anObject! !

!WebJSONPresenter methodsFor: 'private'!
session: aWebSession
	"on which this App represent the observed domain object"
	session := aWebSession! !


!WebJSONPresenter methodsFor: 'initialize-release'!
initDefaultPresenterBlock
	self presenterBlock: 
		[self observee asJson]! !


!WebJSONPresenter methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	"Well, we actually stream JSON!!"
	aStream nextPutAll: 
		self presenterBlock value "by default [self observee asJson] value"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebJSONPresenter class
	instanceVariableNames: ''!

!WebJSONPresenter class methodsFor: 'instance creation'!
newFor: anObject on: aSession
	^self new
		observee: anObject;
		session: aSession! !


Object subclass: #WebMethodResource
	instanceVariableNames: 'site object method contentType preferedUrl'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebMethodResource commentStamp: '<historical>' prior: 0!
WebMethodResource serves resources like images which are stored in plain methods (mosty from WebStyle subclasses).
!


!WebMethodResource methodsFor: 'accessing' stamp: 'jm 7/29/2010 12:30'!
aidaContentType
	"MIME type for our resource"	
	contentType isNil ifTrue: [self aidaContentType: 'image/gif'].
	^contentType! !

!WebMethodResource methodsFor: 'accessing' stamp: 'jm 7/29/2010 12:30'!
aidaContentType: aString
	contentType := aString! !

!WebMethodResource methodsFor: 'accessing'!
expiresTimestamp
	"a week from now, to avoid reloading of images" 
	^SpTimestamp fromSeconds: SpTimestamp now asSeconds + (7*24*3600)! !

!WebMethodResource methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
method
	^method! !

!WebMethodResource methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
method: aSymbol
	method := aSymbol! !

!WebMethodResource methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
object
	^object! !

!WebMethodResource methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
object: anObject
	object := anObject! !

!WebMethodResource methodsFor: 'accessing' stamp: 'janko 3/19/2012 13:21'!
preferredUrl
	^preferedUrl! !

!WebMethodResource methodsFor: 'accessing' stamp: 'janko 3/19/2012 21:17'!
preferredUrl: aString
	preferedUrl := aString! !

!WebMethodResource methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
site
	"a Site on which this resource will be shown"
	^site! !

!WebMethodResource methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
site: anAIDASite
	site := anAIDASite! !


!WebMethodResource methodsFor: 'testing'!
aidaIsRespondingNeverStreamed
	^false! !

!WebMethodResource methodsFor: 'testing' stamp: 'janko 4/25/2012 10:59'!
aidaIsRespondingStreamed
	"always stream method resources"
	^true! !

!WebMethodResource methodsFor: 'testing'!
isTextContent
	^self site mimeMap isTextType: self aidaContentType! !

!WebMethodResource methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebElement
	^false! !

!WebMethodResource methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebPage
	^true! !


!WebMethodResource methodsFor: 'private-streaming'!
aidaPresenterFor: aRequest on: aSession 
	^self! !

!WebMethodResource methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	"stream content of method resource to a response. Gzip compress it if text like CSS or JS"
	| response content |
	response := aRequest streamedResponse.
	content := self object perform: self method.
	content := AIDASite properArray: content. "in case of TwoByteString or Array"
	[self site addResponseHeadersTo: response forPage: self on: aSession.
	self isTextContent ifTrue:   "gzip compress text content"
		[response gzipEncoded; dontCompress. "because we will compress in advance"
		content := response class gzipCompress: content].
	response length: content size. "to stream on HTTP/1.0 too, because chunking is not allowed"
	response nextPutAll: content. 
	response close]
		on: Error
		do: [:ex | "ignore "]! !


!WebMethodResource methodsFor: 'private'!
printString
	^'aWebMethodResource
	method: ', self method printString, '
	preferedUrl: ', self preferredUrl, '
	content type: ', self aidaContentType! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebMethodResource class
	instanceVariableNames: ''!

!WebMethodResource class methodsFor: 'instance creation' stamp: 'janko 3/19/2012 21:17'!
fromMethod: aSymbol on: anObject contentType: aString preferedUrl: aString2 site: anAIDASite
	^super new
		object: anObject;
		method: aSymbol;
		aidaContentType: aString;
		preferredUrl: aString2;
		site: anAIDASite! !

!WebMethodResource class methodsFor: 'instance creation'!
fromMethod: aSymbol on: anObject contentType: aString site: anAIDASite
	^super new
		object: anObject;
		method: aSymbol;
		aidaContentType: aString;
		site: anAIDASite! !


Object subclass: #WebRealtimeConnection
	instanceVariableNames: 'type handler connection app view context'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebRealtimeConnection commentStamp: 'janko 7/8/2011 23:14' prior: 0!
WebRealtimeConnection holds information about browser connection to send commands in realtime. It can be WebSocket or long-polling Comet (Ajax call which delays response until something is to send back)

Instance Variables
	type	<Symbol>	#comet or #websocket
	handler <WebRealtimeHandler>
	connection <HTTPCoonnection or WebSocketConnection>
	app	<WebAplication>	 in which App this realtime connection is open
	view	<Symbol>	on which App view
	semaphore	<Semaphore>	for long-polling Comet to wait on!


!WebRealtimeConnection methodsFor: 'accessing'!
app
	^self context
		app! !

!WebRealtimeConnection methodsFor: 'accessing'!
connection
	"HTTPConnection for Comet or WebSocketConnection"
	^connection! !

!WebRealtimeConnection methodsFor: 'accessing'!
context
	"an execution context for which this realtime channel is open"
	^context! !

!WebRealtimeConnection methodsFor: 'accessing'!
handler
	"a parent handler of that and other realtime channels to the browser"
	^handler! !

!WebRealtimeConnection methodsFor: 'accessing'!
session
	"session in which this realtime connection is open"
	^self handler notNil 
		ifTrue: [self handler session]
		ifFalse: [nil]! !

!WebRealtimeConnection methodsFor: 'accessing'!
type

	^type! !

!WebRealtimeConnection methodsFor: 'accessing'!
view
     "view on the app on which this connection was open"
	^self context
		view! !


!WebRealtimeConnection methodsFor: 'handling-websocket'!
closedConnection: aWebSocketConnection
	"a callback when underlying websocket connection close for any reason"
"	Transcript cr; show: '*** realtimeConnection closedConnection callback'. "
	self removeYourself! !

!WebRealtimeConnection methodsFor: 'handling-websocket'!
respondToWebSocketMessage: aString
	"responds to webSocket messages"
	"Intialized as webSocket's receiveBlock in streamWebSocketOn:for:on: "
	| event backToUtf8|
	"Transcript cr; show: 'websocket msg received'."
	backToUtf8 := AIDASite convert: aString asString  toCodepage: #'UTF_8'. "because convertion happens in WebFormElement acceptInputFrom:value: ... This needs to be changed, conversions on the periphery!!"
	[event := WebEvent newFromJSON: backToUtf8.
	event reconnectOn: self session]
		on: Error
		do: [:ex | "just ignore this message" ^nil].
	[event app respondToEvent: event]
		on: Error
		do: [:exception | 
			"self handler site reportException: exception. "
			exception defaultAction]! !

!WebRealtimeConnection methodsFor: 'handling-websocket'!
setWebSocketFrom: aRequest
	self connection: aRequest webSocket.
	self setAppContextFrom: aRequest.
	self connection
		receiveBlock: [:msg | self respondToWebSocketMessage: msg];
		closeHandler: self. "to notify back a websocket connection close"! !


!WebRealtimeConnection methodsFor: 'private'!
connection: aHTTPOrWebSocketConnection
	connection := aHTTPOrWebSocketConnection! !

!WebRealtimeConnection methodsFor: 'private'!
context: aWebContextFirst
	"an execution context for which this realtime channel is open"
	context := aWebContextFirst! !

!WebRealtimeConnection methodsFor: 'private'!
handler: aWebRealtimeHandler
	handler := aWebRealtimeHandler! !

!WebRealtimeConnection methodsFor: 'private'!
printString
	^'aWebRealtimeConnection 
	type: ', self type printString, '
	session: ',  (self session notNil ifTrue: [self session id printString] ifFalse: ['nil']), '
	app: ', (self app notNil ifTrue: [self app class name] ifFalse: ['nil']), '
	view: ', self view printString, '
	context: ', self context id printString, '
	connection: ', (self isClosed ifFalse: ['open'] ifTrue: ['closed'])! !

!WebRealtimeConnection methodsFor: 'private'!
type: anObject

	type := anObject! !


!WebRealtimeConnection methodsFor: 'testing'!
isClosed
	"realtime channel connection is closed"
	self connection isNil ifTrue: [^true].
	^self isWebSocket 
		ifTrue: [self connection isOpen not]
		ifFalse: [self connection isClosed] "for Comet"! !

!WebRealtimeConnection methodsFor: 'testing'!
isComet
	^self type = #comet! !

!WebRealtimeConnection methodsFor: 'testing'!
isWebSocket
	^self type = #websocket! !


!WebRealtimeConnection methodsFor: 'handling'!
pageUrlFrom: aRequest
	"An url of page on which this realtime connection is open. From query part of url"
	| url |
	(aRequest queryAt: 'pageurl') isNil ifTrue: [^nil].
	url := (aRequest queryAt: 'pageurl') readStream upTo: $? .
	^url readStream upTo: $#! !

!WebRealtimeConnection methodsFor: 'handling' stamp: 'janko 8/28/2013 17:04'!
pageViewFrom: aRequest
	"A view on which this realtime connection is open. From query part of url"
	"Squeak specific"
	| query pview |
	(aRequest queryAt: 'pageurl') isNil ifTrue: [^nil].
	query := (aRequest queryAt: 'pageurl') readStream upTo: $? ; upToEnd.
	query := (query readStream upTo: $# ) trimBlanks. "skip #anchor if any"
	(query isEmpty or: [(query findString: 'view=' startingAt: 1) = 0]) ifTrue: [^#main].
	pview := query readStream upToAll: 'view';  skip: 1 "="; upTo: $& . "Squeak specific" "upToAll: !!!!!!"
	 ^pview asSymbol! !

!WebRealtimeConnection methodsFor: 'handling'!
sendMesagesFromQueue
	"try to send messages to all open channels, depending on the target app on view of the connection"
	| msgs jsonString |
"	Transcript cr; show: 'realtime connection: send msgs from queue ('. "
	msgs := self context queue select: [:msg | 
		msg app = self app and: [msg view = self view] ].
	msgs addAll: (self context queue select: [:msg |
		#( #load ) includes: msg command]).
"	Transcript show: msgs size printString, ' msgs)'. "
	msgs isEmpty ifTrue: [^nil].
	jsonString := self session packToJSONMessages: msgs.
	[self connection sendUtf8Text: jsonString] "json values are already UTF8 encoded"
		on: Error
		do: [:ex |
			Transcript cr; show: '*** realtime connection: error while sending from queue'.
			self connection close].
	self context queue removeAll: msgs.! !

!WebRealtimeConnection methodsFor: 'handling'!
setAppContextFrom: aRequest
	| url object appl ctx |
	url := self pageUrlFrom: aRequest.
	object := self session site 
		urlResolver objectOnUrl: url.
	appl := self session webAppFor: object.
	appl ifNil: 
		[^Transcript cr; show: '*** realtime connection: app is nil, set context failed'].
	ctx := appl findContextFor: aRequest.
"	Transcript cr; show: 'realtime connection: set context: ', ctx printString. "
	self context: ctx.! !


!WebRealtimeConnection methodsFor: 'cleanup'!
removeNonactive
	"check and remove if app or view is nonactive, also if connection is already closed"
	"call that when page unload event came to close its realtime connections"
	self isClosed ifTrue: 
		[^self removeYourself].
	(self app isNil  or: [self app isActive not])
		ifTrue: [self removeYourself]
		ifFalse: [ ]! !

!WebRealtimeConnection methodsFor: 'cleanup'!
removeYourself
"	Transcript cr; show: '*** realtimeConnection: removeYourself ', (self context notNil ifTrue: ['on context ', self context id printString] ifFalse: ['']). "
	self handler notNil ifTrue:
		[self handler connections remove: self ifAbsent: [nil] ].
	(self context notNil and: [self context isActive]) ifTrue:
		[self context  close].
	self connection notNil ifTrue: 
		[self connection close].  "BEWARE, this can terminate current process!! "! !


!WebRealtimeConnection methodsFor: 'handling-comet'!
setCometFrom: aRequest
	self setAppContextFrom: aRequest! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebRealtimeConnection class
	instanceVariableNames: ''!

!WebRealtimeConnection class methodsFor: 'instance creation'!
newCometOn: aWebRealtimeHandler from: aRequest
	^super new
		type: #comet;
		handler: aWebRealtimeHandler;
		setCometFrom: aRequest! !

!WebRealtimeConnection class methodsFor: 'instance creation'!
newWebSocketOn: aWebRealtimeHandler from: aRequest
	^super new
		type: #websocket;
		handler: aWebRealtimeHandler;
		setWebSocketFrom: aRequest! !


Object subclass: #WebRealtimeHandler
	instanceVariableNames: 'session connections'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebRealtimeHandler commentStamp: 'janko 8/25/2012 17:12' prior: 0!
WebRealtimeHandler handles all realtime (WebSocket and Comet) channels to browser on that session"

Instance Variables
	session	<WebSession>  on which session 
	connections	<OrderedCollection>	all currently open realtime connections

!


!WebRealtimeHandler methodsFor: 'private'!
add: aRealtimeConnection
	^self connections 
		add: aRealtimeConnection! !

!WebRealtimeHandler methodsFor: 'private'!
session: aWebSession
	session := aWebSession! !


!WebRealtimeHandler methodsFor: 'initialize-release'!
cleanup
	"remove all realtime connections with closed apps or views, etc."
	self isRealtimeOpen 
		ifFalse: [^nil].
	self connections copy 
		do: [:conn | conn removeNonactive]! !

!WebRealtimeHandler methodsFor: 'initialize-release'!
initConnections
	connections := OrderedCollection new! !

!WebRealtimeHandler methodsFor: 'initialize-release'!
removeAll
	"close and remove all realtime connections"
	self connections copy 
		do: [:conn | conn removeYourself]! !


!WebRealtimeHandler methodsFor: 'handling-comet'!
cometConnections
	"open Comet connections and their sempaphores"
	^self connections select: [:each | each isComet ]! !

!WebRealtimeHandler methodsFor: 'handling-comet'!
respondToCometRequest: aRequest
	(Delay forSeconds: 5) wait. 
	^self! !

!WebRealtimeHandler methodsFor: 'handling-comet'!
streamCometOn: aStream for: aRequest on: aWebSession
	"Long polling Comet.
	This Ajax request will be blocked until some command come to queue"! !


!WebRealtimeHandler methodsFor: 'accessing'!
connections
	"all currently open realtime connections"
	connections isNil ifTrue: [self initConnections].
	^connections! !

!WebRealtimeHandler methodsFor: 'accessing'!
session
	^session! !

!WebRealtimeHandler methodsFor: 'accessing'!
site
	^self session site! !


!WebRealtimeHandler methodsFor: 'testing'!
isRealtimeOpen
	"is any realtime connection open?"
	^self connections
		notEmpty! !

!WebRealtimeHandler methodsFor: 'testing'!
isRealtimeOpenFor: aWebContextFirst
	^self connections
		contains: [:each | each context = aWebContextFirst]! !


!WebRealtimeHandler methodsFor: 'serving'!
sendMesagesFromQueue
	"try to send messages to all open channels, depending on the target app on view of the connection"
"	Transcript cr; show: '*** realtime handler: send msgs from queue'.  "
	self cleanup. "remove all closed connections first"
	self connections do: [:conn | 
		conn sendMesagesFromQueue] "also remove sent msgs from queue"! !


!WebRealtimeHandler methodsFor: 'handling-websocket'!
streamWebSocketOn: aStream for: aRequest on: aWebSession
	"For upgrade to web socket to become connected as bidirectional channel to browser"
	| realtimeConn response |
	aRequest isWebSocketRequest ifFalse: [^HTTPResponse forbidden].
	"put authorization check here!! "
	realtimeConn := WebRealtimeConnection 
		newWebSocketOn: self 
		from: aRequest.
	self 
		add: realtimeConn.
	response := realtimeConn connection 
		answerTo: aRequest.
	aStream nextPutAll:  
		response body asString. "because of postprocessing on AIDASite answerToGetOrPost:on:"
	aRequest task response 
		become: response. "switch with a preprepared response"! !

!WebRealtimeHandler methodsFor: 'handling-websocket'!
webSocketConnections
	"open WebSocket connections"
	^self connections select: [:each | each isWebSocket ]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebRealtimeHandler class
	instanceVariableNames: ''!

!WebRealtimeHandler class methodsFor: 'instance creation'!
newOn: aWebSession
	^super new
		session: aWebSession! !


Object subclass: #WebRouter
	instanceVariableNames: 'site routes'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebRouter commentStamp: '<historical>' prior: 0!
WebRouter routes a web request to the appropriate resource (handler), which can be a domain object which is able to represent itself on the web (via URLResolver), or a static file (via FileProxy) or anything else. Router's main method is #resourceFor: aRequest, which returns a resource able to handle that request or nil in case no resource was found.

It contains an ordered collection of routes, which are checked in the sequence until response not nil.
Each route is an association of url pattern and a reference to a handler. Default route is for instance:

	'/*' -> anURLResolver

Url pattern is simply a Smalltalk #match: method criteria, matched over there relative Url of web request.

!


!WebRouter methodsFor: 'adding-removing'!
addFirstRoutePattern:  aPatternString handler: aHandler
	"add a route at the start of routes"
	^self routes addFirst: (aPatternString -> aHandler)! !

!WebRouter methodsFor: 'adding-removing'!
addMethodLibrariesRoute
	"AIDASite allInstances do: [:each | each router addMethodLibrariesRoute] "
	"WebStyles holds method resources like JS, CSS, etc, while method images are dealed in URLResolver"
	(self routes contains: [:route | route value == WebMethodLibrary]) "only one lib route!!"
		ifTrue: [^nil].
	self addRoutePattern: '/*' handler: WebMethodLibrary "class directly, it will route further by itself"! !

!WebRouter methodsFor: 'adding-removing'!
addMethodResourcesAndSpriteRoute
	"AIDASite allInstances do: [:each | 
		each router addMethodResourcesAndSpriteRoute.
		each urlResolver removeObjectsOfClass: WebMethodResource] "
	"WebStyles holds method resources like JS, CSS, etc, while method images are dealed in URLResolver"
	"including a CSS sprite of that style class"
	(self routes contains: [:route | route value isKindOf: WebStyle]) "only one style!!"
		ifTrue: [^nil].
	self addRoutePattern: '/*' handler: self site style! !

!WebRouter methodsFor: 'adding-removing'!
addRoutePattern:  aPatternString handler: aHandler
	"add a route at the end of routes"
	^self routes add: (aPatternString -> aHandler)! !

!WebRouter methodsFor: 'adding-removing'!
addSessionManagerRoute
	"routes all session related requests like Ajax and WebSocket to session manager"
	"AIDASite allInstances do: [:site | site router addSessionManagerRoute] "
	(self routes contains: [:route | route value class == WebSessionManager]) "only one route!!"
		ifTrue: [^nil].
	self addFirstRoutePattern: '/aidasession/*' handler: self site sessionManager! !

!WebRouter methodsFor: 'adding-removing'!
addStaticServerRoute
	"WebStaticServer as an one-way router to serve static files"
	(self routes contains: [:route | route value isKindOf: WebStaticServer]) "only one static server!!"
		ifTrue: [^nil].
	self addRoutePattern: '/*' handler: self site staticServer! !

!WebRouter methodsFor: 'adding-removing'!
addURLResolverRoute
	"URLResolver as a two-way router between urls and domain objects"
	(self routes contains: [:route | route value isKindOf: WebStaticServer]) "only one url resolver!!"
		ifTrue: [^nil].
	self addRoutePattern: '/*' handler: self site urlResolver! !

!WebRouter methodsFor: 'adding-removing'!
setMethodRouteStyle: aWebStyle
	"called from AIDASite styleClass: to redirect correctly requests for method images etc."
	| methodRoute |
	methodRoute := self routes 
		detect: [:each | each value isKindOf: WebStyle]
		ifNone: [self error: 'no method route found?'].
	methodRoute value: aWebStyle.! !


!WebRouter methodsFor: 'initialize-release'!
initDefaultRoutes
	self addSessionManagerRoute. "routes all session related requests like WebSocket"
	self addURLResolverRoute.
	self addMethodLibrariesRoute.
	self addMethodResourcesAndSpriteRoute. "to the style (WebStyle subclass)"
	self addStaticServerRoute.! !

!WebRouter methodsFor: 'initialize-release'!
initRoutes
	routes := OrderedCollection new! !

!WebRouter methodsFor: 'initialize-release'!
initialize
	self initDefaultRoutes! !


!WebRouter methodsFor: 'routing'!
resourceFor: aRequest
	"it routes a request to appropriate handler, which returns a resource to respond to request"
	| url resource  | 
	url := [AIDASite convertFromWeb: aRequest uriString on: aRequest session]  "for i8n Urls"
		on: Error
		do: [:ex | ^nil]. "URL intentionally miscomposed?"
	self routes do: [:route |
		(route key "url pattern" match: url) ifTrue: 
			[resource := route value "handler" resourceFor: aRequest.
			resource notNil ifTrue: [^resource] ] ].
	^nil "no route to resource for that request"! !


!WebRouter methodsFor: 'accessing'!
routes
	routes ifNil: [self initRoutes].
	^routes! !

!WebRouter methodsFor: 'accessing'!
site
	^site! !


!WebRouter methodsFor: 'private'!
site: anAIDASite
	site := anAIDASite! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebRouter class
	instanceVariableNames: ''!

!WebRouter class methodsFor: 'instance creation' stamp: 'jm 9/8/2010 20:48'!
newOn: anAIDASite
	^super basicNew
		site: anAIDASite;
		initialize! !


Object subclass: #WebScheduledEvent
	instanceVariableNames: 'parent timestamp period method object block'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebScheduledEvent commentStamp: '<historical>' prior: 0!
WebScheduledEvent instances as entries in the WebSheduler hold blocks to run periodically or once at a scheduled time.

!


!WebScheduledEvent methodsFor: 'private-scheduling'!
adjustMissedEvent
	"set a timestamp in the future according to a period"
	| nowMs |
	self isSecondPeriod ifTrue: 
		[^self timestamp: (SpTimestamp fromMilliseconds: 
			((SpTimestamp now milliseconds: self timestamp milliseconds) asMilliseconds + (1*1000)))]. "can run a second late"
	nowMs := SpTimestamp now asMilliseconds.
	[nowMs > self timestamp asMilliseconds] whileTrue:
		[self isDayPeriod ifTrue: 
			[self timestamp: (SpTimestamp fromMilliseconds: (self timestamp asMilliseconds + (60*60*24*1000)))].
		self isHourPeriod ifTrue: 
			[self timestamp: (SpTimestamp fromMilliseconds: (self timestamp asMilliseconds + (60*60*1000)))].
		self isMinutePeriod ifTrue: 
			[self timestamp: (SpTimestamp fromMilliseconds: (self timestamp asMilliseconds + (60*1000)))].
		].! !

!WebScheduledEvent methodsFor: 'private-scheduling'!
reschedule
	"periodic events only: calculate and set a new time to run, according to a period"
	self isDayPeriod ifTrue: 
		[self timestamp: (SpTimestamp fromMilliseconds: (self timestamp asMilliseconds + (60*60*24*1000)))].
	self isHourPeriod ifTrue: 
		[self timestamp: (SpTimestamp fromMilliseconds: (self timestamp asMilliseconds + (60*60*1000)))].
	self isMinutePeriod ifTrue: 
		[self timestamp: (SpTimestamp fromMilliseconds: (self timestamp asMilliseconds + (60*1000)))].
	self isSecondPeriod ifTrue: 
		[self timestamp: (SpTimestamp fromMilliseconds: (self timestamp asMilliseconds + (1*1000)))].
	self timestamp < SpTimestamp now "after rescheduling a missed event a time is stil in the past?" 
		ifTrue: [self adjustMissedEvent].
	self parent scheduleEvent: self.! !


!WebScheduledEvent methodsFor: 'private' stamp: 'np 10/17/2008 17:40'!
aidaDeepCopyNotIn: aDictionary 
	^ nil! !

!WebScheduledEvent methodsFor: 'private' stamp: ' 21/4/07 22:07'!
block: anObject
	block := anObject! !

!WebScheduledEvent methodsFor: 'private' stamp: ' 21/4/07 22:07'!
method: aSymbol
	"a method to be called on an object at a scheduled time"
	method := aSymbol! !

!WebScheduledEvent methodsFor: 'private' stamp: ' 21/4/07 22:07'!
object: anObject
	object := anObject! !

!WebScheduledEvent methodsFor: 'private' stamp: ' 21/4/07 22:07'!
parent: anObject
	parent := anObject! !

!WebScheduledEvent methodsFor: 'private'!
printString
	^'aScheduledEvent 
	timestamp: ', self timestamp printSloString, 
		':', self timestamp asTime seconds printString, 
		'.',  self timestamp asTime milliseconds printString, '
	period: ', self period key printString, ' ', self period value printString, '
	method: ', self method printString, '
	object: ', self object printString, '
	block: ', self block printString! !

!WebScheduledEvent methodsFor: 'private' stamp: ' 21/4/07 22:07'!
representBinaryOn: binWriter
	"for BOSS out. Blocks are not BOSSed out correctly, therefore we cannot export evens that way!!"
	"TEMPORARY, find a better solution!!"
	^0! !

!WebScheduledEvent methodsFor: 'private'!
timestamp: aSpTimestamp
	timestamp := aSpTimestamp asSpTimestamp "just for sure"! !


!WebScheduledEvent methodsFor: 'setup'!
at: aSpTimestamp runBlock: aBlockClosure
	self timestamp: aSpTimestamp.
	self block: aBlockClosure.
	self setPeriodSingle! !

!WebScheduledEvent methodsFor: 'setup'!
everyDayAt: aTimeOrHour  runBlock: aBlock
	| time stamp |
	time := aTimeOrHour class == Time 
		ifTrue: [aTimeOrHour] 
		ifFalse: [Time fromSeconds: aTimeOrHour*60*60].
	stamp := SpTimestamp fromDate: Date today andTime: time.
	stamp < SpTimestamp now ifTrue: "in this case add one day"
		[stamp := SpTimestamp 
			fromMilliseconds: (stamp asMilliseconds + (24*60*60*1000))].
	self timestamp: stamp.
	self block: aBlock.
	self periodType: #day value: time! !

!WebScheduledEvent methodsFor: 'setup'!
everyHourAt: aMinuteNumber runBlock: aBlock
	| stamp |
	stamp := SpTimestamp 
		fromDate: Date today 
		andTime: 
			(Time fromSeconds: 
				(Time now hours * 3600) 
				+ (aMinuteNumber * 60)).
	stamp < SpTimestamp now ifTrue: "in this case add one hour"
		[stamp := SpTimestamp 
			fromMilliseconds: (stamp asMilliseconds + (60*60*1000))].
	self timestamp: stamp.
	self block: aBlock.
	self periodType: #hour value: aMinuteNumber! !

!WebScheduledEvent methodsFor: 'setup'!
everyMinuteAt: aSecondNumber runBlock: aBlock
	| stamp |
	stamp := SpTimestamp 
		fromDate: Date today 
		andTime: 
			(Time fromSeconds: 
				(Time now hours * 3600) 
				+ (Time now minutes * 60) 
				+ aSecondNumber).
	stamp < SpTimestamp now ifTrue: "in this case add one minute"
		[stamp := SpTimestamp 
			fromMilliseconds: (stamp asMilliseconds + (60*1000))].
	self timestamp: stamp.
	self block: aBlock.
	self periodType: #minute value: aSecondNumber! !

!WebScheduledEvent methodsFor: 'setup'!
everySecondAt: aMillisecondNumber runBlock: aBlock
	| stamp |
	stamp := SpTimestamp 
		fromDate: Date today 
		andTime: (Time fromMilliseconds: 
					(Time now hours * 3600 * 1000) 
					+ (Time now minutes * 60 * 1000) 
					+ aMillisecondNumber).
	stamp < SpTimestamp now ifTrue: "in this case add one second"
		[stamp := SpTimestamp 
			fromMilliseconds: (stamp asMilliseconds + (1*1000))].
	self timestamp: stamp.
	self block: aBlock.
	self periodType: #second value: aMillisecondNumber! !


!WebScheduledEvent methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
block
	"a block to be run at event"
	^block! !

!WebScheduledEvent methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
method
	"a method to be called on an object at a scheduled time"
	^method! !

!WebScheduledEvent methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
object
	"object on which a method wil be called at scheduled time"
	^object! !

!WebScheduledEvent methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
parent
	^parent! !

!WebScheduledEvent methodsFor: 'accessing'!
priority
	"at which process priority a next action of this event will be run"
	priority ifNil: [self priority: self defaultPriority].
	^priority! !

!WebScheduledEvent methodsFor: 'accessing'!
priority: aNumber
	"to define at which process priority a next action of this event will be run"
	^priority := aNumber! !

!WebScheduledEvent methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
timestamp
	"when this event must occur"
	^timestamp! !


!WebScheduledEvent methodsFor: 'running'!
defaultPriority
	^Processor userBackgroundPriority! !

!WebScheduledEvent methodsFor: 'running'!
run
	"run this event (in forked process), remove it from queue and reschedule if periodic"
	self block notNil 
		ifTrue: [ 
			[self block value] 
				forkAt: self priority]
		ifFalse: [
			[self object perform: self method] 
				forkAt: self priority].
	self parent queue removeFirst.
	self isPeriodic ifTrue: [self reschedule]! !


!WebScheduledEvent methodsFor: 'initialize-release'!
initialize
	self priority. "to be set to #defaultPriority"! !


!WebScheduledEvent methodsFor: 'testing'!
isDayPeriod
	^self period notNil 
		and: [self period key = #day]! !

!WebScheduledEvent methodsFor: 'testing'!
isHourPeriod
	^self period notNil 
		and: [self period key = #hour]! !

!WebScheduledEvent methodsFor: 'testing'!
isMinutePeriod
	^self period notNil 
		and: [self period key = #minute]! !

!WebScheduledEvent methodsFor: 'testing'!
isPeriodic
	^(self period isNil 
		or: [self period key = #single]) 
			not! !

!WebScheduledEvent methodsFor: 'testing'!
isScheduled
	^self parent
		isScheduledEvent: self! !

!WebScheduledEvent methodsFor: 'testing'!
isSecondPeriod
	^self period notNil 
		and: [self period key = #second]! !


!WebScheduledEvent methodsFor: 'private-periods' stamp: ' 21/4/07 22:07'!
period
	"asociation with type and parameter: #single>nil #day>aTime, ... "
	^period! !

!WebScheduledEvent methodsFor: 'private-periods' stamp: ' 21/4/07 22:07'!
periodType: aSymbol value: anObject
	period := Association key: aSymbol value: anObject! !

!WebScheduledEvent methodsFor: 'private-periods' stamp: ' 21/4/07 22:07'!
setPeriodSingle
	self periodType: #single value: nil! !


!WebScheduledEvent methodsFor: 'start/stop'!
start
	"schedule this event if not already"
	(self parent isScheduledEvent: self) 
		ifTrue: [^nil].
	self parent 
		scheduleEvent: self! !

!WebScheduledEvent methodsFor: 'start/stop'!
stop
	"stop this event by removing it from a scheduler"
	(self parent isScheduledEvent: self) 
		ifFalse: [^nil].
	self parent 
		removeEvent: self 
		ifAbsent: []! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebScheduledEvent class
	instanceVariableNames: ''!

!WebScheduledEvent class methodsFor: 'instance creation'!
newOn: aScheduler
	^super new 
		parent: aScheduler;
		initialize! !


Object subclass: #WebStaticServer
	instanceVariableNames: 'site files'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebStaticServer commentStamp: '<historical>' prior: 0!
WebStaticServer serves static content from files. It holds a dictionary of urls and FileProxies, for each file one.!


!WebStaticServer methodsFor: 'serving'!
fileProxyForURL: aString
	" Try to find a html file for a specified URL and make aHTMLFileProxy. 
	Returns nil if such a file does not exist. Index content in default WebIndex"
	| add home fname proxy |
	aString isEmpty ifTrue: [^nil].
	(aString last = $/) ifTrue: [add := 'index.htm'] ifFalse: [add := ''].
	home := self site homeDirectory.
	(home last = $/ ) | (home last = $\ ) ifTrue: [home := home copyFrom: 1 to: home size-1].
	fname := home, aString, add.
	SpEnvironment onWindows ifTrue: [fname := fname copyReplaceAll: '/' with: '\'].
	((SpFilename named: fname) exists and: [(SpFilename named: fname) isDirectory not]) ifFalse:
		[fname := fname, 'l'.   ".html instead just .htm"
		(SpFilename named: fname) exists ifFalse: [^nil] ].
	proxy := FileProxy from: fname onSite: self site.
	proxy indexContent.
	^proxy! !

!WebStaticServer methodsFor: 'serving'!
resourceFor: aHTTPRequest
	"returns or creates an instance of FileProxy for requested file. Nil if not exist"
	| url proxy |
	url := AIDASite convertFromWeb: aHTTPRequest uriString on: aHTTPRequest session.  "for international Urls"
	url = '/' ifTrue: [^self resourceForRootUrl].
	^self files at: url ifAbsentPut:
		[proxy := self fileProxyForURL: url.
		proxy ifNil: [^nil].
		proxy]! !

!WebStaticServer methodsFor: 'serving'!
resourceForRootUrl
	"returns or creates an instance of FileProxy for root index.htm or index.html"
	| url proxy |
	url := '/index.htm'.
	proxy := self files at: url ifAbsent: 
		[proxy := self fileProxyForURL: url.
		proxy notNil ifTrue: 
			[self files at: url put: proxy. 
			^proxy]].
	url := '/index.html'.
	^self files at: url ifAbsentPut: 
		[proxy := self fileProxyForURL: url.
		proxy isNil ifTrue: [^nil].
		proxy].! !


!WebStaticServer methodsFor: 'accessing'!
files
	"a dictionary of urls as keys  and FileProxies as values"
	files ifNil: [self initFiles].
	^files! !

!WebStaticServer methodsFor: 'accessing'!
site
	^site! !


!WebStaticServer methodsFor: 'initialize-release'!
initFiles
	files := Dictionary new! !

!WebStaticServer methodsFor: 'initialize-release'!
initialize
	"put yoursef in a router and remove all files from urlResolver, where are not needed anymore"
	self site router addStaticServerRoute.
	self site urlResolver removeObjectsOfClass: FileProxy.! !


!WebStaticServer methodsFor: 'private'!
site: anAIDASite
	site := anAIDASite! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebStaticServer class
	instanceVariableNames: ''!

!WebStaticServer class methodsFor: 'instance creation' stamp: 'jm 9/8/2010 20:49'!
newOn: anAIDASite
	^super basicNew
		site: anAIDASite! !


Object subclass: #WebTransactionMonitor
	instanceVariableNames: ''
	classVariableNames: 'BusySessions LastCommit LocalServers Muttex NotificationSent Transactions'
	poolDictionaries: ''
	category: 'Aida-Internal'!
!WebTransactionMonitor commentStamp: '<historical>' prior: 0!
WebTransactionMonitor is used for coordinating transactions on databases like Gemstone.
!


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebTransactionMonitor class
	instanceVariableNames: 'lock'!

!WebTransactionMonitor class methodsFor: 'local servers' stamp: ' 21/4/07 22:07'!
addServer: aWebServer

	self localServers add: aWebServer! !

!WebTransactionMonitor class methodsFor: 'local servers' stamp: ' 21/4/07 22:07'!
removeServer: aWebServer

	self localServers remove: aWebServer ifAbsent: []! !


!WebTransactionMonitor class methodsFor: 'transactions' stamp: ' 21/4/07 22:07'!
beginTransaction

	"Mark the beginning of transaction on current process. 
	Mark the end with commit or cancelTransaction"

	self beginTransactionOn: Processor activeProcess.! !

!WebTransactionMonitor class methodsFor: 'transactions' stamp: ' 21/4/07 22:07'!
beginTransactionOn: aProcess

	"Mark the beginning of transaction. Mark the end with commit or cancelTransaction"

	self critical: 
		[self transactions add: aProcess]! !

!WebTransactionMonitor class methodsFor: 'transactions' stamp: ' 21/4/07 22:07'!
cancelTransaction

	"cancel the transaction without commiting on current process. 
	Used in exception handling routines"

	self cancelTransactionOn: Processor activeProcess! !

!WebTransactionMonitor class methodsFor: 'transactions' stamp: ' 21/4/07 22:07'!
cancelTransactionOn: aProcess

	"cancel the transaction without commiting. Used in exception handling routines"

	self critical: 
		[self transactions remove: aProcess ifAbsent: []].! !

!WebTransactionMonitor class methodsFor: 'transactions' stamp: ' 21/4/07 22:07'!
clearHangedProcesses

	"remove all processes with hanged  suspended context from set of transactions. "
	"WebTransactionMonitor clearHangedProcesses"
" TEMORARY, vw5i4 sender unknown !! "
	self transactions copy do: 
		[:each | (each suspendedContext notNil and:
""
			[(each suspendedContext sender selector = #readWait) | 
			(each suspendedContext sender selector = #writeWait)] )
""
				ifTrue:
					[each terminate.
					self transactions remove: each] ].
""! !

!WebTransactionMonitor class methodsFor: 'transactions' stamp: ' 21/4/07 22:07'!
clearNilProcesses

	"remove all processes with nil  suspended context from set of transactions. Such processes
	died somewhere and were not removed with method cancelTransaction"

	self transactions copy do: 
		[:each | each suspendedContext isNil 
			ifTrue:
				[self transactions remove: each] ].! !

!WebTransactionMonitor class methodsFor: 'transactions' stamp: ' 21/4/07 22:07'!
commit

	"commit the transaction if there is no more pending transactions, otherwise defer commit to
	the next call of this method."
	"WebTransactionMonitor commit"
	self critical: 
		[self clearNilProcesses.
		"self transactions isEmpty" true
			ifTrue: 
				["WebServer default diagnostics ifTrue: [Transcript show: ' comm.']."
"				Swazoo.SwazooServer isPersistent ifTrue: [self gemstoneCommit].  "
				"WebServer default diagnostics ifTrue: [Transcript show: '.ited ']."
				self setLastCommit. ]
			ifFalse: 
				[self clearHangedProcesses.
				self transactions notEmpty ifTrue: 
					[self noCommitFor10min ifTrue: 
						[self notifyNoCommiting.
"						Swazoo.SwazooServer isPersistent ifTrue: [self gemstoneCommit] "]
					]
				]
		].

"WebTransactionMonitor commit"! !

!WebTransactionMonitor class methodsFor: 'transactions' stamp: ' 21/4/07 22:07'!
commitTransaction

	"commit the transaction on current process if there is no more pending transactions, 
	otherwise defer commit to the next call of this method."

	self commitTransactionOn: Processor activeProcess! !

!WebTransactionMonitor class methodsFor: 'transactions' stamp: ' 21/4/07 22:07'!
commitTransactionOn: aProcess

	"commit the transaction if there is no more pending transactions, otherwise defer commit to
	the next call of this method."

	self critical: 
		[self cancelTransactionOn: aProcess.
		self commit].! !


!WebTransactionMonitor class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
busySessions

	"a collection of database sessions, which are busy on that moment"

	BusySessions isNil ifTrue: [self initBusySessions].
	^BusySessions! !

!WebTransactionMonitor class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
isNotificationSent

	NotificationSent isNil ifTrue: [self resetNotificationSent].
	^NotificationSent! !

!WebTransactionMonitor class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
lastCommit

	"return the time of last real odb commit"

	^AIDASite default lastCommitTimestamp.! !

!WebTransactionMonitor class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
resetNotificationSent

	NotificationSent := false.! !

!WebTransactionMonitor class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setLastCommit

	"set the time of last real odb commit to time now"
	
	self localServers do: [:each | each setLastCommitTimestamp].
	self resetNotificationSent! !

!WebTransactionMonitor class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
setNotificationSent

	NotificationSent := true.! !


!WebTransactionMonitor class methodsFor: 'critical sections'!
critical: aBlock
	"For protecting critical sections in parallel execution of web requests. Use it always
	when you do things, which cannot be disturbed by another request. Example:
		WebTransactionMonitor critical: [<a block with critical section>]. "

	^self mutex critical: aBlock.! !


!WebTransactionMonitor class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
freeSession

	"find a session in a pool of sessions which is not current and not busy"

	| allSessions pick |
	allSessions := GBSM loggedInSessions asOrderedCollection.
	allSessions 
		remove: GBSM currentSession;
		removeAll: self busySessions.
	allSessions notEmpty
		ifTrue:
			[pick := (Random new next * allSessions size) truncated + 1.
			^allSessions at: pick]
		ifFalse: [^GBSM currentSession]


"WebTransactionMonitor freeSession"! !

!WebTransactionMonitor class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
gemstoneCommit

	| result |
	AIDARoot critical:
		[result := GBSM currentSession commitTransaction.
		result == true ifFalse: 
			[result := GBSM currentSession commitTransaction.
			result == true ifFalse: 
				[Transcript cr; show: '****** commit troubles !!!!!! ******'] ].
		].

"WebTransactionMonitor commit"! !

!WebTransactionMonitor class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
onFreeSessionFor: anObject remotePerform: aSelector

	^self onFreeSessionFor: anObject remotePerform: aSelector withArgs: #()


"WebTransactionMonitor onFreeSessionFor: AIDARoot remotePerform: #copy"! !

!WebTransactionMonitor class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
onFreeSessionFor: anObject remotePerform: aSelector with: anArgument

	^self onFreeSessionFor: anObject remotePerform: aSelector withArgs: (Array with: anArgument)

"WebTransactionMonitor onFreeSessionFor: AIDARoot remotePerform: #at: with: 'planid' "! !

!WebTransactionMonitor class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
onFreeSessionFor: anObject remotePerform: aSelector withArgs: argsArray

	| session gsObject result |
	session := self freeSession.
	[	
		self busySessions add: session.
		gsObject := anObject asGSObjectInSession: session .
		result := gsObject remotePerform: aSelector withArgs: argsArray.
		result := gsObject remotePerform: aSelector withArgs: argsArray.
		result := result asLocalObject.
		session commitTransaction
	] valueNowOrOnUnwindDo: 
		[self busySessions remove: session ifAbsent: [].
		 session disconnectST: anObject fromGS: gsObject].
	^result

"WebTransactionMonitor onFreeSessionFor: WebServer default remotePerform: #settings withArgs: #()"! !

!WebTransactionMonitor class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
versantCommit

"	ODBInterface checkpointCommit "! !


!WebTransactionMonitor class methodsFor: 'initialize' stamp: ' 21/4/07 22:07'!
initBusySessions

	BusySessions := Set new.! !

!WebTransactionMonitor class methodsFor: 'initialize' stamp: ' 21/4/07 22:07'!
initTransactions

	Transactions := Set new.! !

!WebTransactionMonitor class methodsFor: 'initialize' stamp: ' 21/4/07 22:07'!
initialize
	self initTransactions.
	self initBusySessions.

"WebTransactionMonitor initialize"! !


!WebTransactionMonitor class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
localServers
	"all active web servers, whose are running on local image"
	LocalServers isNil ifTrue: [LocalServers := Set new].
	self removeNonactiveServers.
	^LocalServers! !

!WebTransactionMonitor class methodsFor: 'private' stamp: 'janko 3/19/2012 21:59'!
mutex
	"for critical sections"
	Muttex isNil ifTrue: [Muttex := AidaMutex new].
	^Muttex! !

!WebTransactionMonitor class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
removeNonactiveServers
	LocalServers copy do: [:srv | 
		srv isServing ifFalse: [LocalServers remove: srv ifAbsent: []] ]! !

!WebTransactionMonitor class methodsFor: 'private' stamp: ' 21/4/07 22:07'!
transactions

	"a collection of all processes with open transactions . Such a process is 
	addded with method beginTransaction and removed with commit or cancelTransaction"
	"WebTransactionMonitor transactions"
	Transactions isNil ifTrue: [self initTransactions].
	^Transactions! !


!WebTransactionMonitor class methodsFor: 'error notifying' stamp: 'rob.rothwell 3/2/2009 22:02'!
noCommitFor10min

	"check if there was no real odb commit more than 10min"

	^(TimeStamp now asSeconds - self lastCommit asSeconds) > (10 * 60)! !

!WebTransactionMonitor class methodsFor: 'error notifying' stamp: ' 21/4/07 22:07'!
notifyNoCommiting

	"if there is no odb commit for more than 10min then an e-mail message is sent to a 
	specified address (from settings in WebServer)"
	"WebTransactionMonitor notifyNoCommiting"



	| subject body |

	self isNotificationSent ifTrue: [^self].
"
	subject := 'AIDAWeb Urgent: No odb commit!!'.
	body := 'No commit for more than 10 minutes!!'.
	WebServer default urgentEMailSubject: subject body: body.
"
	self setNotificationSent.! !

WebTransactionMonitor initialize!