Object subclass: #WebCountry
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-i18n'!
!WebCountry commentStamp: 'janko 8/25/2012 17:14' prior: 0!
WebCountry on class side holds a table of country names and their ISO codes
!



Object subclass: #WebLanguage
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-i18n'!
!WebLanguage commentStamp: 'janko 8/25/2012 17:14' prior: 0!
WebLanguage on class side holds a table of language names and their ISO codes

!



Object subclass: #WebTranslDict
	instanceVariableNames: 'translator class method language dict changes'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-i18n'!
!WebTranslDict commentStamp: '<historical>' prior: 0!
WebTranslDict is a dictionary holding the last level in WebTranslator cache. Special dictionary is needed to catch the changes when doing translations by translation tools and storing them back to appropriate class translation methods.!


!WebTranslDict methodsFor: 'accessing'!
at: key
	^self dict at: key! !

!WebTranslDict methodsFor: 'accessing'!
at: key ifAbsent: aBlock
	^self dict at: key ifAbsent: aBlock! !

!WebTranslDict methodsFor: 'accessing'!
at: key ifAbsentPut: aBlock
	^self at: key ifAbsent: [self initialAt: key put: aBlock value]! !

!WebTranslDict methodsFor: 'accessing'!
at: key put: value
	"this one should be used by translation tools!!"
	"This method is called by WebInlineEditableText widget after the text change is posted. See 
       WebText>>#prepareForTranslation, how the aspect of this widget is prepared to achieve that."
	self changes add: key.
	self dict at: key put: value.
	self writeChanges. "immediatelly after each change, for now"
	^value! !

!WebTranslDict methodsFor: 'accessing'!
initialAt: key put: value
	"this one does not register the change, use it for initial dict setup!!"
	^self dict at: key put: value! !

!WebTranslDict methodsFor: 'accessing'!
language
	"language of translations in this dictionary"
	^language! !

!WebTranslDict methodsFor: 'accessing'!
method
	"a creation method which holds our translations (contains multilingual associations"
	^method! !

!WebTranslDict methodsFor: 'accessing'!
site
	^self translator site! !

!WebTranslDict methodsFor: 'accessing'!
translClass	
	"a class holding this transactions on its class side methods. Usually a sublcass of WebApplication"
	^class! !

!WebTranslDict methodsFor: 'accessing'!
translator
	^translator! !


!WebTranslDict methodsFor: 'private'!
changes
	"changes of multilingual text to be written on class side of classses with translations"
	changes isNil ifTrue: [self initChanges].
	^changes! !

!WebTranslDict methodsFor: 'private'!
dict
	dict ifNil: [self initDict].
	^dict! !

!WebTranslDict methodsFor: 'private'!
language: aSymbol
	language := aSymbol! !

!WebTranslDict methodsFor: 'private'!
method: aSymbol
	"a creation method which holds our translations (contains multilingual associations"
	method := aSymbol! !

!WebTranslDict methodsFor: 'private'!
printOn: aStream
	aStream nextPutAll: 'aWebTranslDict ('.
	self dict keysAndValuesDo: [:key :value | 
		aStream nextPutAll: key printString, '->', value printString, ' '].
	aStream nextPutAll: ') '! !

!WebTranslDict methodsFor: 'private'!
translClass: aClassWithTransactions
	"a class holding this transactions on its class side methods. Usually a sublcass of WebApplication"
	class := aClassWithTransactions! !

!WebTranslDict methodsFor: 'private'!
translator: aWebTranslator
	translator := aWebTranslator! !

!WebTranslDict methodsFor: 'private'!
view: aSymbol
	"a view on our App class where those translations belong"
	view := aSymbol! !


!WebTranslDict methodsFor: 'initialize-release'!
initChanges
	changes := Set new.! !

!WebTranslDict methodsFor: 'initialize-release'!
initDict
	dict := Dictionary new.! !


!WebTranslDict methodsFor: 'changing'!
writeChanges
	self changes do: [:key |
		self translator 
			changeTranslationKey: key 
			to: (self at: key) 
			language: self language 
			class: self translClass 
			method: self method].
	self initChanges.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebTranslDict class
	instanceVariableNames: ''!

!WebTranslDict class methodsFor: 'instance creation'!
newOn: aWebTranslator forClass: aWebAppClass method: aSymbol language: aLangSymbol
	^super new
		translator: aWebTranslator;
		translClass: aWebAppClass;
		method: aSymbol;
		language: aLangSymbol! !


Object subclass: #WebTranslator
	instanceVariableNames: 'parent cache other'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-i18n'!
!WebTranslator commentStamp: 'jm 6/27/2009 20:07' prior: 0!
WebTranslator offers a translation support to web apps. Apps on class side hold translations of the text. WebTranslator is then called by executing app to find a proper translation for each text, if it is used as in this example:

	e addText: #fr->'Bonjour'!


!WebTranslator methodsFor: 'private-cache' stamp: 'np 3/25/2009 15:30'!
cache
	"cached translations. A multilevel dictionary"
	"class->(method->(langCode->(key->translation))))) "
	cache isNil ifTrue: [self initCache].
	^cache! !

!WebTranslator methodsFor: 'private-cache'!
cachedTranslate: aString toLanguage: aLanguageCode class: aClassWithTransl method: aMethodSymbol
	"cache hierarchy: class->(method->(langCode->(key->translation))))) "
	"last dictionary is WebTranslDict!! "
	^(((self cache at: aClassWithTransl ifAbsent: [self refreshClass: aClassWithTransl])
		at: aMethodSymbol ifAbsentPut: [^aString])
			at: aLanguageCode ifAbsent: [^aString])
				at: aString ifAbsent: [^aString]! !

!WebTranslator methodsFor: 'private-cache'!
refreshClass: aClassWithTransl
	"refresh a cache from translations stored in class methods of specified class"
	| classDict methodDict langDict |
	classDict := self cache at: aClassWithTransl put: Dictionary new. "just remove old stuff"
	(self methodsOn: aClassWithTransl) do: [:method |
		methodDict := classDict at: method put: Dictionary new.
		(self langsForMethod: method on: aClassWithTransl) do: [:lang |
			langDict := methodDict 
				at: lang 
				put: (WebTranslDict newOn: self forClass: aClassWithTransl method: method language: lang).
			(self pairsForLang: lang method: method on: aClassWithTransl) do: [:assoc |
				langDict initialAt: assoc key put: assoc value ]]]. "initalAt:put: to avoid signaling change"
	^classDict! !


!WebTranslator methodsFor: 'private-classes-changes'!
changePairs: aPairsCollection key: aKeyString value: aString
	"change (or add new pair) a value of a pair (an association) on specified key"
	| pair |
	pair := aPairsCollection 
		detect: [:assoc | assoc key = aKeyString]
		ifNone: [aPairsCollection add: (aKeyString -> '')].
	pair value: aString.
	^aPairsCollection! !

!WebTranslator methodsFor: 'private-classes-changes'!
checkCreateTranslation: aMultilangAssociation forLanguage: aLanguageCode inDict: aTranslDict
	"check if that translation exists and if not, create a pair in a dict. Same for original lang too!!"
	| origLang origDict |
	(aTranslDict at: aMultilangAssociation value ifAbsent: [nil]) notNil ifTrue: [^true]. "exists, no need to create"
	aTranslDict  
		at:  aMultilangAssociation value
		put:  aMultilangAssociation value. "default text is from orig lang"
	origLang := aMultilangAssociation key.
	origDict := ((self cache at: aTranslDict translClass) at: aTranslDict method) at: origLang.
	self checkCreateTranslation: aMultilangAssociation forLanguage: origLang inDict: origDict.! !

!WebTranslator methodsFor: 'private-classes-changes'!
checkOrCreateMethod: aTranslMethodSymbol onClass: aClassWithTransl
	"check if exist and if not, create that method with translations (empty so far)  on a class side of class"
	(aClassWithTransl respondsTo: aTranslMethodSymbol) ifTrue: [^true].
	self writeBackPairs: #() intoMethod: aTranslMethodSymbol onClass: aClassWithTransl! !

!WebTranslator methodsFor: 'private-classes-changes'!
openDictsToTranslate: aMultilangAssociation toLanguage: aLanguageCode forMethod: aMethodSymbol on: aClassWithTransl
	"check/create dict for orig language, then create dict for specified language"
	| origLang translMethod pairs pair |
	origLang := aMultilangAssociation key.
	translMethod := self translMethodForLang: origLang method: aMethodSymbol.
	pairs := (aClassWithTransl respondsTo: translMethod) 
		ifTrue: [self pairsForLang: origLang method: aMethodSymbol on: aClassWithTransl.]
		ifFalse: [OrderedCollection new].
	self changePairs: pairs key:  aMultilangAssociation value value: aMultilangAssociation value.
	self writeBackPairs: pairs intoMethod: translMethod onClass: aClassWithTransl.
	translMethod := self translMethodForLang: aLanguageCode method: aMethodSymbol.
	pair := aMultilangAssociation value -> aMultilangAssociation value. "default one for specified lang too"	
	self writeBackPairs: (Array with: pair) intoMethod: translMethod onClass: aClassWithTransl! !

!WebTranslator methodsFor: 'private-classes-changes'!
writeBackPairs: aTranslPairsArray intoMethod: aTranslMethodSymbol onClass: aClassWithTransl
	| cr mstream semaphore |
	cr :=  (String with: Character cr).
	mstream := WriteStream on: String new.
	mstream
		nextPutAll: aTranslMethodSymbol asString, cr;
		nextPut: Character tab; nextPutAll: '^#('.
	aTranslPairsArray do: [:assoc |
		mstream 
			nextPut: Character cr; nextPut: Character tab; nextPutAll: '(';
			nextPut: $'; nextPutAll: (AIDASite convert: assoc key toCodepage: #UTF8); nextPut: $'; 
			nextPutAll: '->';
			nextPut: $'; nextPutAll:  (AIDASite convert: assoc value toCodepage: #UTF8); nextPut: $';
			nextPutAll: ')'].
	mstream nextPut: Character cr; nextPut: Character tab; nextPutAll: ')', cr. 
	semaphore := Semaphore new.
	[aClassWithTransl class compile: mstream contents  classified: 'translations'. semaphore signal] 
		fork. "well, don't ask why :( "
	semaphore wait. "for forked compilation to finish"! !


!WebTranslator methodsFor: 'translating'!
changeTranslationKey: aKeyString to: aNewString language: aLanguageCode class: aClassWithTransl method: aMethodSymbol
	"change that translation by recompiling the apropriate method in a class side of App class"
	| translMethod translPairs |
	translMethod := self translMethodForLang: aLanguageCode method: aMethodSymbol.
	self checkOrCreateMethod: translMethod onClass: aClassWithTransl.
	translPairs := self pairsForLang: aLanguageCode method: aMethodSymbol on: aClassWithTransl.
	translPairs := self changePairs: translPairs key: aKeyString value: aNewString.
	self writeBackPairs: translPairs intoMethod: translMethod onClass: aClassWithTransl! !

!WebTranslator methodsFor: 'translating'!
dictToTranslate: aMultilangAssociation to: aLanguageCode for: anElement on: aSession
	"returns WebTranslDict, for setting an aspect to edit by translation tools"
	"Open a new one automatically if not yet exist for that method and language"
	| translClass method dict |
	translClass := aSession lastApp class. "app class where translations reside"
	method := anElement creationMethod. "method which created an element with multilang text"
	dict := ((self cache at: translClass ifAbsent: [self refreshClass: translClass])
		at: method ifAbsent: 
			[self openDictsToTranslate: aMultilangAssociation 
				toLanguage: aLanguageCode forMethod: method on: translClass.
			self refreshClass: translClass.
			(self cache at: translClass) at: method])
				at: aLanguageCode ifAbsent: 
					[self openDictsToTranslate: aMultilangAssociation 
						toLanguage: aLanguageCode forMethod: method on: translClass.
						self refreshClass: translClass.
						((self cache at: translClass) at: method) at: aLanguageCode].
	self checkCreateTranslation: aMultilangAssociation forLanguage: aLanguageCode inDict: dict.
	^dict! !

!WebTranslator methodsFor: 'translating'!
translate: aMultilangAssociation to: aLanguageCode for: anElement on: aSession
	| translClass translation |
	translClass := aSession lastApp class. "app class where translations reside"
	translation := self 
		cachedTranslate: aMultilangAssociation value
		toLanguage: aLanguageCode
		class: translClass
		method: anElement creationMethod. "method which created an element with multilang text"
	^translation notNil 
		ifTrue: [translation] 
		ifFalse: [aMultilangAssociation value] "original text"! !


!WebTranslator methodsFor: 'initialize-release' stamp: 'np 3/25/2009 15:29'!
initCache
	"cached translations"
	cache := Dictionary new.! !

!WebTranslator methodsFor: 'initialize-release' stamp: 'np 3/25/2009 15:29'!
initOther
	other := Dictionary new! !


!WebTranslator methodsFor: 'private-classes' stamp: 'np 3/25/2009 15:31'!
langFromTranslMethod: aMethodSymbol
	"extract language code from transl.method:  #fr from #frViewCalendar"
	^(aMethodSymbol asString copyFrom: 1 to: 2) asSymbol! !

!WebTranslator methodsFor: 'private-classes' stamp: 'np 3/25/2009 15:31'!
langsForMethod: aMethodSymbol on: aClassWithTransl
	"get all languages for which we have a translation for that creation method"
	^((self translMethodsOn: aClassWithTransl)
		 select: [:each | (self methodFromTranslMethod: each) = aMethodSymbol]) 
			collect: [:each | self langFromTranslMethod: each]! !

!WebTranslator methodsFor: 'private-classes' stamp: 'np 3/25/2009 15:31'!
methodFromTranslMethod: aMethodSymbol
	"extract creation method name from transl.method:  #viewCalendar from #frViewCalendar"
	| method |
	method := String with: (aMethodSymbol asString at: 3) asLowercase.
	^(method, (aMethodSymbol asString copyFrom: 4 to: aMethodSymbol size)) asSymbol.! !

!WebTranslator methodsFor: 'private-classes' stamp: 'np 3/25/2009 15:31'!
methodsOn: aClassWithTransl
	"get all creation methods for elements holding multilang text"
	^((self translMethodsOn: aClassWithTransl) collect: [:each | self methodFromTranslMethod: each]) 
		asSet "to find a unique set of those methods"! !

!WebTranslator methodsFor: 'private-classes'!
pairsForLang: aLanguageCode method: aMethodSymbol on: aClassWithTransl
	| translMethod pairs |
	translMethod := self translMethodForLang: aLanguageCode method: aMethodSymbol.
	pairs := (aClassWithTransl perform: translMethod) 
		collect: [:triple | Association 
			key: (AIDASite convert: triple first fromCodepage: #UTF8)
			value: (AIDASite convert: triple last fromCodepage: #UTF8)]. "triple midlle is just ->"
	^pairs asOrderedCollection! !

!WebTranslator methodsFor: 'private-classes' stamp: 'np 3/25/2009 15:31'!
translLanguagesOn: aClassWithTransl
	"get all languages (codes) in which we have trnaslations"
	^(self translMethodsOn: aClassWithTransl) 
		inject: Set new 
		into: [:each :set | set add: (self langFromTranslMethod: each); yourself]! !

!WebTranslator methodsFor: 'private-classes' stamp: 'np 3/25/2009 15:31'!
translMethodForLang: aLanguageCode method: aMethodSymbol
	"compose that method name. For #fr and #viewCalendar = #frViewCalendar"
	^(aLanguageCode asString, (String with: aMethodSymbol asString first) asUppercase,
		(aMethodSymbol asString copyFrom: 2 to: aMethodSymbol size))
			asSymbol! !

!WebTranslator methodsFor: 'private-classes' stamp: 'np 3/25/2009 15:32'!
translMethodsOn: aClassWithTransl
	"get all class method names holding translations"
	"VW specific"
	^aClassWithTransl class organization listAtCategoryNamed: self translationsCategory! !


!WebTranslator methodsFor: 'private' stamp: 'np 3/25/2009 15:29'!
other
	^other! !

!WebTranslator methodsFor: 'private' stamp: 'np 3/25/2009 15:29'!
otherAt: aSymbol
	"other values"
	^self otherAt: aSymbol ifAbsent: [nil]! !

!WebTranslator methodsFor: 'private' stamp: 'np 3/25/2009 15:30'!
otherAt: aSymbol ifAbsent: aBlock
	"other values"
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!WebTranslator methodsFor: 'private' stamp: 'np 3/25/2009 15:30'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!WebTranslator methodsFor: 'private' stamp: 'np 3/25/2009 15:30'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !

!WebTranslator methodsFor: 'private' stamp: 'np 3/25/2009 15:30'!
parent: anObject
	parent := anObject! !


!WebTranslator methodsFor: 'accessing' stamp: 'np 3/25/2009 15:28'!
parent
	^parent! !

!WebTranslator methodsFor: 'accessing' stamp: 'np 3/25/2009 15:28'!
site	
	^self parent! !

!WebTranslator methodsFor: 'accessing' stamp: 'np 3/25/2009 15:28'!
translationsCategory
	"name of category holding translations on class side of App classes"
	^#translations! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebTranslator class
	instanceVariableNames: ''!

!WebTranslator class methodsFor: 'instance creation' stamp: 'np 3/25/2009 15:28'!
newOn: anAIDASite
	^super new
		parent: anAIDASite! !
