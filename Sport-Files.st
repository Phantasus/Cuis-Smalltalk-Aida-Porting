Object subclass: #SpFileStream
	instanceVariableNames: 'underlyingStream filename'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Files'!

!SpFileStream methodsFor: 'initialize-release' stamp: 'JM 4/18/2007 13:54'!
appendingToFilename: aSpFilename
	self filename: aSpFilename.
	underlyingStream := aSpFilename exists
		ifTrue: [FileStream oldFileNamed: self filename asString]
		ifFalse: [FileStream newFileNamed: self filename asString].
"	underlyingStream guessDefaultLineEndConvention. "
	^self! !

!SpFileStream methodsFor: 'initialize-release' stamp: 'JM 4/14/2007 19:17'!
readingFromFileNamed: aString
	"^self
	I initialize myself to write to a file named aString."
	filename := aString.
	underlyingStream := (FileUrl named: aString) readStream.
	underlyingStream lineEndTransparent.
	^self! !

!SpFileStream methodsFor: 'initialize-release' stamp: 'JM 4/18/2007 14:00'!
readingFromFilename: aSpFilename 
	self filename: aSpFilename.
	underlyingStream := FileStream oldFileNamed: self filename asString.
	^self! !

!SpFileStream methodsFor: 'initialize-release' stamp: 'JM 4/14/2007 19:18'!
writingToFileNamed: aString 
	"^self
	I initialize myself to write to a file named aString."
	filename := aString.
	underlyingStream := (FileUrl named: aString) writeStream.
	underlyingStream lineEndTransparent.
	^self! !

!SpFileStream methodsFor: 'initialize-release' stamp: 'JM 4/18/2007 14:02'!
writingToFilename: aSpFilename 
	self filename: aSpFilename.
	underlyingStream := FileStream newFileNamed: self filename asString.
	^self! !


!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:00'!
atEnd
	^self underlyingStream atEnd! !

!SpFileStream methodsFor: 'services' stamp: 'mivsek 8/22/2007 17:13'!
binary
	^self underlyingStream binary! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:00'!
close
	^self underlyingStream close! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:00'!
closed
	^self underlyingStream closed! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:01'!
cr
	^self underlyingStream cr! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:01'!
flush
	^self underlyingStream flush! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:01'!
next
	^self underlyingStream next! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:01'!
nextPut: anObject 
	^self underlyingStream nextPut: anObject! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:01'!
nextPutAll: aCollection 
	^self underlyingStream nextPutAll: aCollection! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:01'!
peek
	^self underlyingStream peek! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:01'!
position
	^self underlyingStream position! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:02'!
position: aNumber
	^self underlyingStream position: aNumber! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:02'!
skip: anInteger
	^self underlyingStream skip: anInteger! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:02'!
store: anObject 
	^self underlyingStream store: anObject! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:02'!
throughAll: aCollection
	^self underlyingStream throughAll: aCollection! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:02'!
upTo: anObject
	^self underlyingStream upTo: anObject! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:05'!
upToAll: aCollection
	^self underlyingStream upToAll: aCollection! !

!SpFileStream methodsFor: 'services' stamp: 'BB 1/25/2006 16:05'!
upToEnd
	^self underlyingStream upToEnd! !


!SpFileStream methodsFor: 'accessing' stamp: 'JM 4/14/2007 19:19'!
contentsStream
	^self underlyingStream contents readStream! !

!SpFileStream methodsFor: 'accessing' stamp: 'JM 4/14/2007 19:19'!
filename
	^filename! !

!SpFileStream methodsFor: 'accessing' stamp: 'JM 4/18/2007 12:52'!
filename: aSpFilename
	filename := aSpFilename! !

!SpFileStream methodsFor: 'accessing' stamp: 'JM 4/14/2007 19:19'!
underlyingStream
	^underlyingStream! !


!SpFileStream methodsFor: '*Swazoo' stamp: 'janko 10/30/2012 10:57'!
nextAvailable: aNumber

    ^underlyingStream nextAvailable: aNumber! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpFileStream class
	instanceVariableNames: ''!

!SpFileStream class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:20'!
appendingToFilename: aSpFilename 
	"^a SpFileStream
	I create a new instance of myself to append to the file identified by anOSkFilename."

	^self new appendingToFilename: aSpFilename! !

!SpFileStream class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:21'!
readingFromFileNamed: aString 
	"^a SpFileStream
	I create a new instance of myself to read from a file named aString."

	^self new readingFromFileNamed: aString! !

!SpFileStream class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:21'!
readingFromFilename: aSpFilename 
	"^a SpFileStream
	I create a new instance of myself to read the file identified by anOSkFilename."

	^self new readingFromFilename: aSpFilename! !

!SpFileStream class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:22'!
writingToFileNamed: aString 
	"^a SpFileStream
	I create a new instance of myself to write to a file named aString."

	^self new writingToFileNamed: aString! !

!SpFileStream class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:22'!
writingToFilename: aSpFilename 
	"^an SpFileStream
	I create a new instance of myself to append to the file identified by aSpFilename."

	^self new writingToFilename: aSpFilename! !


Object subclass: #SpFilename
	instanceVariableNames: 'filename'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Files'!
!SpFilename commentStamp: 'JM 4/18/2007 16:10' prior: 0!
A SpFilename represents a file or directory and allows operations like delete, makeDirectory, etc
Part of code is copied with permission from Cincom VisualWorks

Instance Variables
	filename:		<String> name of a file or directory

!


!SpFilename methodsFor: 'services' stamp: 'JM 4/14/2007 19:13'!
appendStream
	"^a SpFileStream
	I create an append stream on the file I represent."

	^SpFileStream appendingToFilename: self! !

!SpFilename methodsFor: 'services' stamp: 'JM 4/14/2007 19:14'!
readStream
	"^a SpFileStream
	I create a read stream on the file I represent."

	^SpFileStream readingFromFilename: self! !

!SpFilename methodsFor: 'services' stamp: 'JM 4/14/2007 19:14'!
writeStream
	"^a SpFileStream
	I create a write stream on the file I represent."

	^SpFileStream writingToFilename: self! !


!SpFilename methodsFor: 'accessing' stamp: 'JM 4/18/2007 12:30'!
asString
	^self filename! !


!SpFilename methodsFor: 'private' stamp: 'JM 4/14/2007 19:15'!
underlyingFilename
	"^a Filename
	I return the Filename instance that I am a wrapper for."
	^underlyingFilename! !


!SpFilename methodsFor: 'testing' stamp: 'JM 4/26/2007 15:38'!
exists	
	"^a Boolean
	I return true if the file or direcotory I represent actually exists"
	^[(FileDirectory default fileExists: self asAbsoluteFilename asString) 
		or: [FileDirectory default directoryExists: self asString] ]
			on: Error, Exception 
			do: [:ex | ^false].
! !


!SpFilename methodsFor: 'initialize-release' stamp: 'JM 4/18/2007 12:27'!
named: aString 
	"^self
	I initialize myself to represent the filename identified by aString."

	filename := aString.
	^self! !


!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'pete 5/28/2008 15:11'!
asAbsoluteFilename
	"Answer a Filename pointing to the same file using absolute path.
	The method may answer the receiver it it is already absolute."

	^self isAbsolute
		ifTrue: [self]
		ifFalse: [self class named: 
			(FileDirectory default pathName, (String with: self separator), 
				(SpEnvironment onWindows
					ifTrue: [self asString copyReplaceAll: '.\' with: ''] "windows only"
					ifFalse: [self asString copyReplaceAll: './' with: ''] "unix only!!"))]! !

!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'JM 4/18/2007 12:34'!
asFilename
	^self! !

!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'mivsek 8/22/2007 16:51'!
createdTimestamp
	"a SpTimestamp
	timestamp of file creation. "
	| dir entry |
	dir := FileDirectory forFileName: self asAbsoluteFilename asString.
	entry := dir directoryEntryFor: self tail.
	^SpTimestamp fromSeconds: entry creationTime "is this correct on all OSes?"
! !

!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'JM 4/18/2007 15:13'!
directory
	"a filename of the directory for this Filename."
	^self class named: self head! !

!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'JM 4/18/2007 16:23'!
etag
	"^a String
	The etag of a file entity is taken to be the date last modified as a String. 
	We use the SpTimestamp in "

	^self lastModified asRFC1123String! !

!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'JM 4/18/2007 15:16'!
extension
	"Answer the receiver's extension if any.  This is the characters from the
	 last occurrence of a period to the end, inclusive. E.g. the extension of
	 'squeak.image' is '.image'. Answer nil if none.  Note that e.g. .login has no
	 extension."

	| string periodIndex |
	string := self tail.
	periodIndex := string lastIndexOf: $..
	^periodIndex > 1 ifTrue: [string copyFrom: periodIndex to: string size]! !

!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'mivsek 8/22/2007 22:05'!
fileSize
	| dir entry |
	dir := FileDirectory forFileName: self asAbsoluteFilename asString.
	entry := dir directoryEntryFor: self tail.
	^entry fileSize 
! !

!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'JM 4/18/2007 15:06'!
head
	"Answer the directory prefix as a String."

	| index |
	(index := self lastSeparatorIndex) notNil
		ifTrue:	[index := index max: 2.
				^self asString copyFrom: 1 to: index-1]
		ifFalse:	[^FileDirectory default pathName]! !

!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'hmm 6/5/2012 16:30'!
lastModified
	^self modifiedTimestamp! !

!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'mivsek 8/22/2007 16:51'!
modifiedTimestamp
	"a SpTimestamp
	timestamp of last file modification"
	| dir entry |
	dir := FileDirectory forFileName: self asAbsoluteFilename asString.
	entry := dir directoryEntryFor: self tail.
	^SpTimestamp fromSeconds: entry modificationTime "is this correct on all OSes?"
! !

!SpFilename methodsFor: '*Swazoo-accessing' stamp: 'JM 4/18/2007 15:06'!
tail
	"Answer the filename suffix as a String."

	| index nm |
	nm := self asString.
	(index := self lastSeparatorIndex) notNil
		ifTrue:	[^nm copyFrom: index+1 to: nm size]
		ifFalse:	[^nm copy]! !


!SpFilename methodsFor: '*Swazoo-private' stamp: 'JM 4/18/2007 15:29'!
construct: extraFn
	"Make a new instance, treating the receiver as a directory, and
	the string argument as a file within the pathname."

	^self class named: (self filename, (String with: self separator), extraFn)! !

!SpFilename methodsFor: '*Swazoo-private' stamp: 'JM 4/18/2007 12:31'!
filename
	 "^a String"
	^filename! !

!SpFilename methodsFor: '*Swazoo-private' stamp: 'JM 4/18/2007 15:07'!
lastSeparatorIndex
	^self asString lastIndexOf: self separator ifAbsent: [nil]! !

!SpFilename methodsFor: '*Swazoo-private' stamp: 'JM 4/18/2007 13:49'!
separator
	"Answer the platform's filename component separator."

	^FileDirectory primPathNameDelimiter! !


!SpFilename methodsFor: '*Swazoo-services' stamp: 'mivsek 8/22/2007 22:16'!
contentsOfEntireFile
	| stream |
	[stream := FileStream oldFileNamed: self filename.
	^stream contentsOfEntireFile]
		ensure: [stream close]
! !

!SpFilename methodsFor: '*Swazoo-services' stamp: 'JM 4/18/2007 15:24'!
delete
	| dir |
	dir := FileDirectory forFileName: self asAbsoluteFilename asString.
	self isDirectory
		ifTrue: [dir deleteDirectory: self asString]
		ifFalse: [dir deleteFileNamed: self tail ifAbsent: [] ]! !

!SpFilename methodsFor: '*Swazoo-services' stamp: 'pete 5/28/2008 15:15'!
makeDirectory
	| dir |
	dir := FileDirectory forFileName: self asAbsoluteFilename asString.
	[dir createDirectory: self asString]
		on: Error
		do: [:ex | ].! !


!SpFilename methodsFor: '*Swazoo-testing' stamp: 'pete 5/28/2008 15:06'!
isAbsolute
	"Answer true if this name is absolute (e.g. not relative to the
	'current directory')."

	self asString size = 0 ifTrue:	[^false].
	SpEnvironment onWindows ifTrue: [
		^(self asString at: 1) isLetter and: [(self asString at: 2) = $:]]. "absolute pathnames on windows looks like 'C:'"
	^(self asString at: 1) == self separator! !

!SpFilename methodsFor: '*Swazoo-testing' stamp: 'JM 4/18/2007 14:33'!
isDirectory
	^FileDirectory default directoryExists: self asString! !

!SpFilename methodsFor: '*Swazoo-testing' stamp: 'JM 4/18/2007 13:00'!
isRelative
	"Answer true if this name must be interpreted relative to some directory."
	^self isAbsolute not! !


!SpFilename methodsFor: '*Aida' stamp: 'np 3/18/2008 05:58'!
contentsAsMethod
	"return a body of method with a literal array with contents of that file"
	| input output |
	input := self readStream.
	input binary.
	output := WriteStream with: String new.
	output nextPutAll: '^#('.
	[ [input atEnd] whileFalse: [output nextPutAll: input next printString; nextPut: $ ].
	output nextPutAll: ')' ]
		ensure: [input close].
	^output contents

"(SpFilename named: 'source.st') contentsAsMethod "! !

!SpFilename methodsFor: '*Aida' stamp: 'janko 3/22/2008 17:17'!
contentsOfEntireFileBinary
	| stream |
	[stream := FileStream oldFileNamed: self filename.
	^stream binary contentsOfEntireFile]
		ensure: [stream close]
! !

!SpFilename methodsFor: '*Aida' stamp: 'np 6/11/2008 05:02'!
directoryContents
	| entries |
	entries := FileDirectory new directoryContentsFor: (self asAbsoluteFilename filename).
	^entries collect: [:each | each name]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpFilename class
	instanceVariableNames: ''!

!SpFilename class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:11'!
named: aString 
	"^a SpFilename
	I create a new instance of myself to represent the filename identified by aString."

	^self new named: aString! !
