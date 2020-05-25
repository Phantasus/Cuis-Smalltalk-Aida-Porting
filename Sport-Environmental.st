Object subclass: #SpEnvironment
	instanceVariableNames: ''
	classVariableNames: 'ImageShutdownTaskBlocks ImageStartupTaskBlocks'
	poolDictionaries: ''
	category: 'Sport-Environmental'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpEnvironment class
	instanceVariableNames: ''!

!SpEnvironment class methodsFor: 'image startup/shutdown' stamp: 'mivsek 9/5/2007 22:45'!
addImageShutdownTask: aBlock for: anObject 
	"^self
	I add aBlock to the list of actions and note that this is for anObject"

	self imageShutdownTaskBlocks at: anObject put: aBlock.
	^self
! !

!SpEnvironment class methodsFor: 'image startup/shutdown' stamp: 'mivsek 9/5/2007 22:45'!
addImageStartupTask: aBlock for: anObject 
	"^self
	I add aBlock to the list of actions and note that this is for anObject"

	self imageStartupTaskBlocks at: anObject put: aBlock.
	^self
! !

!SpEnvironment class methodsFor: 'image startup/shutdown' stamp: 'mivsek 9/5/2007 22:49'!
removeShutdownActionFor: anObject 
	"^self
	I remove the task block for an object it it has one"

	self imageShutdownTaskBlocks removeKey: anObject ifAbsent: [nil].
	^self! !

!SpEnvironment class methodsFor: 'image startup/shutdown' stamp: 'mivsek 9/5/2007 22:49'!
removeStartupActionFor: anObject 
	"^self
	I remove the task block for an object it it has one"

	self imageStartupTaskBlocks removeKey: anObject ifAbsent: [nil].
	^self! !


!SpEnvironment class methodsFor: 'queries' stamp: 'JM 6/8/2007 12:01'!
allSubclassesOf: aClass
	"^an Array
	I return the array of classes which are subclasses of aClass."

	^aClass allSubclasses asArray
	
"SpEnvironment allSubclassesOf: Error"! !


!SpEnvironment class methodsFor: 'hex' stamp: 'mivsek 8/17/2007 16:34'!
byteArrayFromHexString: aString 

"not yet ported!!
	^ByteArray fromHexString: aString
"	
"SpEnvironmet byteArrayFromHexString: '1abc3' "! !

!SpEnvironment class methodsFor: 'hex' stamp: 'mivsek 8/17/2007 16:34'!
hexStringFromByteArray: aByteArray 

"not yet ported!!
	^aByteArray asHexString
"! !


!SpEnvironment class methodsFor: 'services' stamp: 'JM 6/8/2007 11:59'!
characterFromInteger: anInteger 
	^Character value: anInteger
	
"SpEnvironment characterFromInteger: 32"! !

!SpEnvironment class methodsFor: 'services' stamp: 'JM 6/8/2007 11:59'!
integerFromString: aString
	"^an Integer
	We need this because of what looks like a bug in GemStone's String>>asNumber 
	(e.g. '16rFF' -> 1.6000000000000000E+01, not 255)."

	^aString asNumber
	
"SpEnvironment integerFromString: '32' "! !

!SpEnvironment class methodsFor: 'services' stamp: 'JM 4/14/2007 19:08'!
streamStartPosition
	"^an Integer
	Streams start at position 0 in VisualWorks & Squeak, and position 1 in
	GemStone(!!). "
	^ 0! !

!SpEnvironment class methodsFor: 'services' stamp: 'JM 6/8/2007 11:56'!
writeStackDumpForException: exception to: targetStream 
	targetStream nextPutAll: 
		'SpEnvironment class>>writeStackDumpForException:to: does not work yet :-/'! !


!SpEnvironment class methodsFor: 'compiling' stamp: 'JM 4/17/2007 09:58'!
evaluate: aString in: anEnvironment
	"Squeak doesn't need anEnvironment as VW"
	^Compiler 
		evaluate: aString
		for: nil
		notifying: nil
		logged: false! !

!SpEnvironment class methodsFor: 'compiling' stamp: 'JM 4/17/2007 09:59'!
evaluate: aString receiver: anObject in: anEnvironment
	"Squeak doesn't need anEnvironment as VW"
	^Compiler 
		evaluate: aString
		for: anObject
		notifying: nil
		logged: false! !


!SpEnvironment class methodsFor: 'private' stamp: 'mivsek 9/5/2007 23:15'!
imageShutdownTaskBlocks
	"self imageShutdownTaskBlocks"
	ImageShutdownTaskBlocks isNil 
		ifTrue: [ImageShutdownTaskBlocks := IdentityDictionary new].
	^ImageShutdownTaskBlocks! !

!SpEnvironment class methodsFor: 'private' stamp: 'mivsek 9/5/2007 23:15'!
imageStartupTaskBlocks
	"self imageStartupTaskBlocks"
	ImageStartupTaskBlocks isNil 
		ifTrue: [ImageStartupTaskBlocks := IdentityDictionary new].
	^ImageStartupTaskBlocks! !

!SpEnvironment class methodsFor: 'private' stamp: 'mivsek 9/5/2007 22:43'!
initialize
	"self initialize"
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self! !

!SpEnvironment class methodsFor: 'private' stamp: 'mivsek 9/5/2007 22:39'!
shutDown
	"Squeak specific!!"
	self imageShutdownTaskBlocks values do: [:shutdownTask | shutdownTask value].
	^self! !

!SpEnvironment class methodsFor: 'private' stamp: 'mivsek 9/5/2007 22:38'!
startUp
	"Squeak specific!!"
	self imageStartupTaskBlocks values do: [:startupTask | startupTask value].
	^self! !


!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'mivsek 9/6/2007 11:17'!
isAmbraiSmalltalk
	^false! !

!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'JM 6/8/2007 11:55'!
isDolphin
	^false! !

!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'mivsek 9/6/2007 10:47'!
isGNUSmalltalk
	^false! !

!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'JM 4/14/2007 19:09'!
isGemStone
	^false! !

!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'mivsek 9/6/2007 11:11'!
isObjectStudio
	^false! !

!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'mivsek 9/6/2007 11:10'!
isSmalltalkX
	^false! !

!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'mivsek 9/6/2007 11:17'!
isSmalltalkXY
	^false! !

!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'JM 4/14/2007 19:09'!
isSqueak
	^true! !

!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'mivsek 9/6/2007 11:13'!
isVASmalltalk
	^false! !

!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'mivsek 9/6/2007 11:14'!
isVisualSmalltalk
	^false! !

!SpEnvironment class methodsFor: 'testing-dialects' stamp: 'JM 4/14/2007 19:09'!
isVisualWorks
	^false! !


!SpEnvironment class methodsFor: 'testing' stamp: 'JM 4/14/2007 19:09'!
isHeadless
	^false! !


!SpEnvironment class methodsFor: 'os commands' stamp: 'mivsek 8/17/2007 16:32'!
runShellCommandString: aCommandString

" not yet ported!!
 
	^UnixProcess cshOne: aCommandString
"! !


!SpEnvironment class methodsFor: '*Swazoo-Extensions-testing' stamp: 'janko 10/31/2012 19:25'!
onUnix
	"we are running on Unix, yes or no?"
	^Smalltalk os platformName = 'unix'! !

!SpEnvironment class methodsFor: '*Swazoo-Extensions-testing' stamp: 'jm 2/7/2011 13:18'!
onWindows
	"we are running on Windows, yes or no?"
	^Smalltalk os platformName asLowercase = 'win32'! !


Object subclass: #SpStringUtilities
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Environmental'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpStringUtilities class
	instanceVariableNames: ''!

!SpStringUtilities class methodsFor: 'services-encoding' stamp: 'JM 4/14/2007 19:06'!
bytes: subjectBytes asStringUsingEncodingNames: anEncodingName
	^ subjectBytes asString! !

!SpStringUtilities class methodsFor: 'services-encoding' stamp: 'JM 4/14/2007 19:06'!
string: subjectString asBytesUsingEncodingNamed: anEncodingName
	^ subjectString asByteArray! !

!SpStringUtilities class methodsFor: 'services-encoding' stamp: 'JM 6/8/2007 12:11'!
stringFromBytes: aByteArray 
	"^a String
	In GemStone ['Hello, World' asByteArray asString] returns the string 'aByteArray' !!
	This is the boring long way of getting a string from a ByteArray - but it does work
	in GemStone."
	"SpStringUtilities stringFromBytes: ('Hello, World' asByteArray)"

	^aByteArray asString
! !


!SpStringUtilities class methodsFor: 'services' stamp: 'JM 6/8/2007 12:13'!
prevIndexOf: anElement from: startIndex to: stopIndex in: aString
	"Answer the previous index of anElement within the receiver between 
	startIndex and stopIndex working backwards through the receiver.  If the receiver 
	does not contain anElement, answer nil"

	startIndex to: stopIndex by: -1 do:
		[:i |
		(aString at: i) = anElement
			ifTrue: [^i]].
	^nil! !

!SpStringUtilities class methodsFor: 'services' stamp: 'JM 4/14/2007 21:55'!
tokensBasedOn: separatorString in: aString 
	"Answer an OrderedCollection of the sub-sequences
	 of the receiver that are separated by anObject."

	| result lastIdx idx lastToken |
	result := OrderedCollection new.
	aString size = 0 ifTrue: [^result].
	lastIdx := 0.
	
	[idx := aString findString: separatorString startingAt: lastIdx + 1.
	idx > 0] 
			whileTrue: 
				[idx == (lastIdx + 1) 
					ifTrue: [result addLast: String new]
					ifFalse: [result addLast: (aString copyFrom: lastIdx + 1 to: idx - 1)].
				lastIdx := idx].
	lastToken := lastIdx = aString size 
				ifTrue: [String new]
				ifFalse: [aString copyFrom: lastIdx + 1 to: aString size].
	result addLast: lastToken.
	^result! !

!SpStringUtilities class methodsFor: 'services' stamp: 'JM 4/25/2007 20:53'!
trimBlanksFrom: aString 
	"^a String
	I return a copy of aString with all leading and trailing blanks removed."

	| first last |
	first := 1.
	last := aString size.
	[last > 0 and: [(aString at: last) isSeparator]] 
		whileTrue: [last := last - 1].
	^last == 0 
		ifTrue: [String new]
		ifFalse: 
			[[first < last and: [(aString at: first) isSeparator]] 
				whileTrue: [first := first + 1].
			aString copyFrom: first to: last]! !


Object subclass: #SpTranscript
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Environmental'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpTranscript class
	instanceVariableNames: ''!

!SpTranscript class methodsFor: 'logging' stamp: 'JM 4/14/2007 19:05'!
cr	
	^ SpEnvironment isHeadless
		ifTrue: [self]
		ifFalse: [Transcript cr]! !

!SpTranscript class methodsFor: 'logging' stamp: 'JM 4/14/2007 19:05'!
nextPut: anObject
	^self show: (String with: anObject)! !

!SpTranscript class methodsFor: 'logging' stamp: 'JM 4/14/2007 19:05'!
nextPutAll: aCollection 
	^self show: aCollection! !

!SpTranscript class methodsFor: 'logging' stamp: 'JM 4/14/2007 19:06'!
show: aString
	^ SpEnvironment isHeadless
		ifTrue: [self]
		ifFalse: [Transcript show: aString]! !


Object subclass: #SpWeakArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Environmental'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpWeakArray class
	instanceVariableNames: ''!

!SpWeakArray class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:04'!
new: anInteger
	"^a WeakArray
	I don't return an instance of myself, I return a real WeakArray."
	^WeakArray new: anInteger! !

!SpWeakArray class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:04'!
withAll: aCollection 
	"^a WeakArray
	I don't return an instance of myself at all. I return a real Weak array."
	^ WeakArray withAll: aCollection asArray! !

SpEnvironment initialize!