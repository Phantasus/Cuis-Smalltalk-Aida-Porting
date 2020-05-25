Object subclass: #ImageStream
	instanceVariableNames: 'imageStream progressValue'
	classVariableNames: 'ColorPalette256 GrayPalette256 ImageKindTable'
	poolDictionaries: ''
	category: 'Aida-Imaging'!
!ImageStream commentStamp: '<historical>' prior: 0!
ImageStream 

Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.
!


!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
atEnd
	^imageStream atEnd! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
close
	imageStream close! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
contents
	^imageStream contents! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
cr
	^imageStream nextPut: Character cr asInteger! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
lf
	^imageStream nextPut: Character lf asInteger! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
next
	^imageStream next! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
next: size 
	^imageStream next: size! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
nextLong
	^(imageStream next bitShift: 24)
		+ (imageStream next bitShift: 16) + (imageStream next bitShift: 8) + imageStream next! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
nextLongPut: a32BitW 
	imageStream nextPut: ((a32BitW bitShift: -24)
			bitAnd: 255).
	imageStream nextPut: ((a32BitW bitShift: -16)
			bitAnd: 255).
	imageStream nextPut: ((a32BitW bitShift: -8)
			bitAnd: 255).
	imageStream nextPut: (a32BitW bitAnd: 255).
	^a32BitW! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
nextPut: aByte 
	^imageStream nextPut: aByte! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
nextPutAll: aByteArray 
	^imageStream nextPutAll: aByteArray! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
nextWord
	^(imageStream next bitShift: 8)
		+ imageStream next! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
nextWordPut: a16BitW 
	imageStream nextPut: ((a16BitW bitShift: -8)
			bitAnd: 255).
	imageStream nextPut: (a16BitW bitAnd: 255).
	^a16BitW! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
position
	^imageStream position! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
position: anInteger 
	^imageStream position: anInteger! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
size
	^imageStream size! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
skip: anInteger 
	^imageStream skip: anInteger! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
space
	^imageStream nextPut: Character space asInteger! !

!ImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
tab
	^imageStream nextPut: Character tab asInteger! !


!ImageStream methodsFor: 'progress' stamp: ' 21/4/07 22:07'!
compute: aBlock 
	(self progressValue isKindOf: ValueHolder)
		ifTrue: [self progressValue compute: aBlock]! !

!ImageStream methodsFor: 'progress' stamp: ' 21/4/07 22:07'!
progress
	^self progressValue value! !

!ImageStream methodsFor: 'progress' stamp: ' 21/4/07 22:07'!
progress: normalizedNumber 
	(0 <= normalizedNumber and: [normalizedNumber <= 1])
		ifTrue: 
			[| truncatedValue |
			truncatedValue := normalizedNumber roundTo: 0.005.
			self progressValue value = truncatedValue ifFalse: [self progressValue value: truncatedValue]]! !

!ImageStream methodsFor: 'progress' stamp: ' 21/4/07 22:07'!
progressValue
	^progressValue! !

!ImageStream methodsFor: 'progress' stamp: ' 21/4/07 22:07'!
progressValue: aValueHolder 
	progressValue := aValueHolder! !


!ImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
convertValue: value from: fromScale to: toScale 
	^value = 0
		ifTrue: [0]
		ifFalse: [value = fromScale
				ifTrue: [toScale]
				ifFalse: [(value + 1 * (toScale + 1) / (fromScale + 1)) rounded - 1 max: 0]]! !

!ImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
errorCanNotRead
	self error: 'can''t read the image'.
	^nil! !

!ImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
errorCanNotWrite
	self error: 'can''t write the image'.
	^nil! !

!ImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
hasMagicNumber: aByteArray 
	| position array |
	position := imageStream position.
	imageStream size - position >= aByteArray size
		ifTrue: 
			[array := (imageStream next: aByteArray size) asByteArray.
			array = aByteArray ifTrue: [^true]].
	imageStream position: position.
	^false! !


!ImageStream methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
nextImage
	^self subclassResponsibility! !

!ImageStream methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
nextPutImage: anImage 
	^self subclassResponsibility! !


!ImageStream methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
on: aStream 
	imageStream := aStream.
	(imageStream respondsTo: #binary)
		ifTrue: [imageStream binary].
	self progressValue: (ValueHolder with: nil)! !


!ImageStream methodsFor: 'viewing' stamp: ' 21/4/07 22:07'!
show: anImage 
	^self class show: anImage! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ImageStream class
	instanceVariableNames: ''!

!ImageStream class methodsFor: 'controls' stamp: ' 21/4/07 22:07'!
assert: assertBlock do: doBlock ensure: ensureBlock 
	assertBlock value.
	[doBlock value]
		valueNowOrOnUnwindDo: [ensureBlock value]! !


!ImageStream class methodsFor: 'constants of palette' stamp: ' 21/8/07 09:38'!
colorPalette256
	"ImageStream colorPalette256."

	| anArray |
	ColorPalette256 notNil ifTrue: [^ColorPalette256].
	anArray := self colorPalette256Array
				collect: 
					[:array | 
					| r g b color |
					r := array at: 1.
					g := array at: 2.
					b := array at: 3.
					ColorValue scalingValue = 8191
						ifTrue: [color := ColorValue
										scaledRed: r
										scaledGreen: g
										scaledBlue: b]
						ifFalse: 
							[r := r / 8191.
							g := g / 8191.
							b := b / 8191.
							color := ColorValue
										red: r
										green: g
										blue: b].
					color yourself].
	ColorPalette256 := MappedPalette withColors: anArray reverse.
	^ColorPalette256! !

!ImageStream class methodsFor: 'constants of palette' stamp: ' 21/8/07 09:38'!
colorPalette256Array
	"ImageStream colorPalette256Array."
	^#(	#(8191 8191 8191)
		#(8191 8191 6553)
		#(8191 8191 4915)
		#(8191 8191 3276)
		#(8191 8191 1638)
		#(8191 8191 0)
		#(8191 6553 8191)
		#(8191 6553 6553)
		#(8191 6553 4915)
		#(8191 6553 3276)
		#(8191 6553 1638)
		#(8191 6553 0)
		#(8191 4915 8191)
		#(8191 4915 6553)
		#(8191 4915 4915)
		#(8191 4915 3276)
		#(8191 4915 1638)
		#(8191 4915 0)
		#(8191 3276 8191)
		#(8191 3276 6553)
		#(8191 3276 4915)
		#(8191 3276 3276)
		#(8191 3276 1638)
		#(8191 3276 0)
		#(8191 1638 8191)
		#(8191 1638 6553)
		#(8191 1638 4915)
		#(8191 1638 3276)
		#(8191 1638 1638)
		#(8191 1638 0)
		#(8191 0 8191)
		#(8191 0 6553)
		#(8191 0 4915)
		#(8191 0 3276)
		#(8191 0 1638)
		#(8191 0 0)
		#(6553 8191 8191)
		#(6553 8191 6553)
		#(6553 8191 4915)
		#(6553 8191 3276)
		#(6553 8191 1638)
		#(6553 8191 0)
		#(6553 6553 8191)
		#(6553 6553 6553)
		#(6553 6553 4915)
		#(6553 6553 3276)
		#(6553 6553 1638)
		#(6553 6553 0)
		#(6553 4915 8191)
		#(6553 4915 6553)
		#(6553 4915 4915)
		#(6553 4915 3276)
		#(6553 4915 1638)
		#(6553 4915 0)
		#(6553 3276 8191)
		#(6553 3276 6553)
		#(6553 3276 4915)
		#(6553 3276 3276)
		#(6553 3276 1638)
		#(6553 3276 0)
		#(6553 1638 8191)
		#(6553 1638 6553)
		#(6553 1638 4915)
		#(6553 1638 3276)
		#(6553 1638 1638)
		#(6553 1638 0)
		#(6553 0 8191)
		#(6553 0 6553)
		#(6553 0 4915)
		#(6553 0 3276)
		#(6553 0 1638)
		#(6553 0 0)
		#(4915 8191 8191)
		#(4915 8191 6553)
		#(4915 8191 4915)
		#(4915 8191 3276)
		#(4915 8191 1638)
		#(4915 8191 0)
		#(4915 6553 8191)
		#(4915 6553 6553)
		#(4915 6553 4915)
		#(4915 6553 3276)
		#(4915 6553 1638)
		#(4915 6553 0)
		#(4915 4915 8191)
		#(4915 4915 6553)
		#(4915 4915 4915)
		#(4915 4915 3276)
		#(4915 4915 1638)
		#(4915 4915 0)
		#(4915 3276 8191)
		#(4915 3276 6553)
		#(4915 3276 4915)
		#(4915 3276 3276)
		#(4915 3276 1638)
		#(4915 3276 0)
		#(4915 1638 8191)
		#(4915 1638 6553)
		#(4915 1638 4915)
		#(4915 1638 3276)
		#(4915 1638 1638)
		#(4915 1638 0)
		#(4915 0 8191)
		#(4915 0 6553)
		#(4915 0 4915)
		#(4915 0 3276)
		#(4915 0 1638)
		#(4915 0 0)
		#(3276 8191 8191)
		#(3276 8191 6553)
		#(3276 8191 4915)
		#(3276 8191 3276)
		#(3276 8191 1638)
		#(3276 8191 0)
		#(3276 6553 8191)
		#(3276 6553 6553)
		#(3276 6553 4915)
		#(3276 6553 3276)
		#(3276 6553 1638)
		#(3276 6553 0)
		#(3276 4915 8191)
		#(3276 4915 6553)
		#(3276 4915 4915)
		#(3276 4915 3276)
		#(3276 4915 1638)
		#(3276 4915 0)
		#(3276 3276 8191)
		#(3276 3276 6553)
		#(3276 3276 4915)
		#(3276 3276 3276)
		#(3276 3276 1638)
		#(3276 3276 0)
		#(3276 1638 8191)
		#(3276 1638 6553)
		#(3276 1638 4915)
		#(3276 1638 3276)
		#(3276 1638 1638)
		#(3276 1638 0)
		#(3276 0 8191)
		#(3276 0 6553)
		#(3276 0 4915)
		#(3276 0 3276)
		#(3276 0 1638)
		#(3276 0 0)
		#(1638 8191 8191)
		#(1638 8191 6553)
		#(1638 8191 4915)
		#(1638 8191 3276)
		#(1638 8191 1638)
		#(1638 8191 0)
		#(1638 6553 8191)
		#(1638 6553 6553)
		#(1638 6553 4915)
		#(1638 6553 3276)
		#(1638 6553 1638)
		#(1638 6553 0)
		#(1638 4915 8191)
		#(1638 4915 6553)
		#(1638 4915 4915)
		#(1638 4915 3276)
		#(1638 4915 1638)
		#(1638 4915 0)
		#(1638 3276 8191)
		#(1638 3276 6553)
		#(1638 3276 4915)
		#(1638 3276 3276)
		#(1638 3276 1638)
		#(1638 3276 0)
		#(1638 1638 8191)
		#(1638 1638 6553)
		#(1638 1638 4915)
		#(1638 1638 3276)
		#(1638 1638 1638)
		#(1638 1638 0)
		#(1638 0 8191)
		#(1638 0 6553)
		#(1638 0 4915)
		#(1638 0 3276)
		#(1638 0 1638)
		#(1638 0 0)
		#(0 8191 8191)
		#(0 8191 6553)
		#(0 8191 4915)
		#(0 8191 3276)
		#(0 8191 1638)
		#(0 8191 0)
		#(0 6553 8191)
		#(0 6553 6553)
		#(0 6553 4915)
		#(0 6553 3276)
		#(0 6553 1638)
		#(0 6553 0)
		#(0 4915 8191)
		#(0 4915 6553)
		#(0 4915 4915)
		#(0 4915 3276)
		#(0 4915 1638)
		#(0 4915 0)
		#(0 3276 8191)
		#(0 3276 6553)
		#(0 3276 4915)
		#(0 3276 3276)
		#(0 3276 1638)
		#(0 3276 0)
		#(0 1638 8191)
		#(0 1638 6553)
		#(0 1638 4915)
		#(0 1638 3276)
		#(0 1638 1638)
		#(0 1638 0)
		#(0 0 8191)
		#(0 0 6553)
		#(0 0 4915)
		#(0 0 3276)
		#(0 0 1638)
		#(7645 0 0)
		#(7099 0 0)
		#(6007 0 0)
		#(5461 0 0)
		#(4369 0 0)
		#(3822 0 0)
		#(2730 0 0)
		#(2184 0 0)
		#(1092 0 0)
		#(546 0 0)
		#(0 7645 0)
		#(0 7099 0)
		#(0 6007 0)
		#(0 5461 0)
		#(0 4369 0)
		#(0 3822 0)
		#(0 2730 0)
		#(0 2184 0)
		#(0 1092 0)
		#(0 546 0)
		#(0 0 7645)
		#(0 0 7099)
		#(0 0 6007)
		#(0 0 5461)
		#(0 0 4369)
		#(0 0 3822)
		#(0 0 2730)
		#(0 0 2184)
		#(0 0 1092)
		#(0 0 546)
		#(7645 7645 7645)
		#(7099 7099 7099)
		#(6007 6007 6007)
		#(5461 5461 5461)
		#(4369 4369 4369)
		#(3822 3822 3822)
		#(2730 2730 2730)
		#(2184 2184 2184)
		#(1092 1092 1092)
		#(546 546 546)
		#(0 0 0)
	)! !

!ImageStream class methodsFor: 'constants of palette' stamp: ' 21/4/07 22:07'!
flushPalettes
	"ImageStream flushPalettes."

	ColorPalette256 := nil.
	GrayPalette256 := nil! !

!ImageStream class methodsFor: 'constants of palette' stamp: ' 21/4/07 22:07'!
grayPalette256
	"ImageStream grayPalette256."

	| paletteSize anArray |
	GrayPalette256 notNil ifTrue: [^GrayPalette256].
	paletteSize := 256.
	anArray := Array new: paletteSize.
	1 to: paletteSize
		do: 
			[:index | 
			| color |
			color := ColorValue brightness: 1 - (index - 1 / (paletteSize - 1)).
			anArray at: index put: color].
	GrayPalette256 := MappedPalette withColors: anArray reverse.
	^GrayPalette256! !


!ImageStream class methodsFor: 'copyright' stamp: ' 21/4/07 22:07'!
copyright
	^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'! !

!ImageStream class methodsFor: 'copyright' stamp: ' 21/4/07 22:07'!
system
	^'Goodies'! !

!ImageStream class methodsFor: 'copyright' stamp: ' 21/4/07 22:07'!
version
	^'003'! !


!ImageStream class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
fromClipboard
	"ImageStream show: ImageStream fromClipboard."

	| pixmap image |
	pixmap := Pixmap fromClipboard.
	image := pixmap asImage.
	^image! !

!ImageStream class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
fromDisplay
	"ImageStream show: ImageStream fromDisplay."

	^self fromDisplay: Screen default bounds! !

!ImageStream class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
fromDisplay: aRectangle 
	"ImageStream show: (ImageStream fromDisplay: (0 @ 0 extent: 100 @ 100))."

	^Screen default completeContentsOfArea: aRectangle! !

!ImageStream class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
fromUser
	"ImageStream show: ImageStream fromUser."

	^self fromDisplay: Rectangle fromUser! !

!ImageStream class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
imageKindTable
	"ImageStream imageKindTable."

	ImageKindTable isNil
		ifTrue: 
			[| aDictionary |
			aDictionary := Dictionary new.
			aDictionary at: 'bos' put: #BosImageStream.
			aDictionary at: 'boss' put: #BosImageStream.
			aDictionary at: 'bmp' put: #BmpImageStream.
			aDictionary at: 'bmpf' put: #BmpImageStream.
			aDictionary at: 'gif' put: #GifImageStream.
			aDictionary at: 'giff' put: #GifImageStream.
			aDictionary at: 'jpg' put: #JpegImageStream.
			aDictionary at: 'jpeg' put: #JpegImageStream.
			aDictionary at: 'pic' put: #PictImageStream.
			aDictionary at: 'pict' put: #PictImageStream.
			ImageKindTable := aDictionary].
	^ImageKindTable! !

!ImageStream class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
imageStreamClassForFileName: aFilename 
	"ImageStream imageStreamClassForFileName: 'zzz.gif' asFilename."

	| aString aSymbol aClass |
	aString := (aFilename asString reverse copyUpTo: $.) reverse.
	aString := aString asLowercase.
	aSymbol := self imageKindTable at: aString ifAbsent: [nil].
	aSymbol isNil ifTrue: [^nil].
	aClass := Smalltalk at: aSymbol ifAbsent: [nil].
	^aClass! !

!ImageStream class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
toClipboard: anImage 
	"ImageStream toClipboard: Image fromUser."

	| pixmap |
	pixmap := anImage asRetainedMedium.
	pixmap toClipboard.
	^anImage! !


!ImageStream class methodsFor: 'class initialization' stamp: ' 21/4/07 22:07'!
initialize
	"ImageStream initialize."

	ImageKindTable := nil.
	self flushPalettes! !

!ImageStream class methodsFor: 'class initialization' stamp: ' 21/4/07 22:07'!
install
	"ImageStream install."

	self colorPalette256.
	self grayPalette256! !


!ImageStream class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
on: aStream 
	^self new on: aStream! !


!ImageStream class methodsFor: 'saving' stamp: ' 21/4/07 22:07'!
save
	"ImageStream save."

	| encodingName fileName classCollection aStream |
	encodingName := #default.
	fileName := 'ImgStrm.st'.
	classCollection := self saveClasses.
	aStream := (fileName asFilename withEncoding: encodingName) writeStream.
	[Cursor write
		showWhile: 
			[| timeStamp |
			timeStamp := Date today shortPrintString , ' ' , Time now shortPrintString.
			aStream cr.
			aStream nextChunkPut: timeStamp printString.
			aStream cr; cr.
			(self comment isNil or: [self comment isEmpty])
				ifFalse: 
					[aStream nextChunkPut: self comment printString.
					aStream cr; cr].
			classCollection
				do: 
					[:aClass | 
					aStream nextChunkPut: aClass definition.
					aStream cr; cr].
			classCollection
				do: 
					[:aClass | 
					| sourceCodeStream |
					aStream nextPut: Character newPage.
					aStream cr.
					sourceCodeStream := SourceCodeStream on: aStream.
					aClass fileOutSourceOn: sourceCodeStream.
					aStream cr]]]
		valueNowOrOnUnwindDo: [aStream close].
	^classCollection! !

!ImageStream class methodsFor: 'saving' stamp: ' 21/4/07 22:07'!
saveClasses
	"ImageStream saveClasses."

	| patternCollection classCollection |
	patternCollection := #('*ImageStream*' '*Progress*').
	classCollection := Smalltalk organization superclassOrder: self category.
	classCollection := classCollection
				select: 
					[:aClass | 
					| string something |
					string := aClass name asString.
					something := patternCollection detect: [:it | it match: string]
								ifNone: [nil].
					something notNil].
	^classCollection , Progress saveClasses! !


!ImageStream class methodsFor: 'viewing' stamp: ' 21/4/07 22:07'!
show: anImage 
	"ImageStream show: Image fromUser."

	| image extent window |
	(anImage isKindOf: OpaqueImage)
		ifTrue: [image := anImage]
		ifFalse: [image := CachedImage on: anImage].
	extent := 64 @ 64 max: (image extent min: Screen default bounds extent - 60 asPoint).
	window := ScheduledWindow new.
	window label: 'Image'.
	window minimumSize: extent.
	window component: image.
	window open.
	^anImage! !


ImageStream subclass: #BmpImageStream
	instanceVariableNames: 'bfType bfSize bfReserved1 bfReserved2 bfOffBits biSize biWidth biHeight biPlanes biBitCount biCompression biSizeImage biXPelsPerMeter biYPelsPerMeter biClrUsed biClrImportant imagePalette imageObject'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Imaging'!
!BmpImageStream commentStamp: '<historical>' prior: 0!
BmpImageStream 

Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.
!


!BmpImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
colorValueFrom: rgbInteger 
	| scalingValue |
	scalingValue := ColorValue scalingValue.
	^ColorValue
		scaledRed: (self
				convertValue: ((rgbInteger bitShift: -16)
						bitAnd: 255)
				from: 255
				to: scalingValue)
		scaledGreen: (self
				convertValue: ((rgbInteger bitShift: -8)
						bitAnd: 255)
				from: 255
				to: scalingValue)
		scaledBlue: (self
				convertValue: (rgbInteger bitAnd: 255)
				from: 255
				to: scalingValue)! !

!BmpImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
rgbIntegerArrayFor: aPalette 
	| colors |
	colors := Array new: aPalette maxIndex + 1.
	1 to: colors size do: [:i | colors at: i put: (self rgbIntegerFrom: (aPalette at: i - 1 ifAbsent: [ColorValue white]))].
	^colors! !

!BmpImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
rgbIntegerFrom: aColorValue 
	| scalingValue |
	scalingValue := ColorValue scalingValue.
	^((self
		convertValue: aColorValue scaledRed
		from: scalingValue
		to: 255)
		bitShift: 16)
		+ ((self
				convertValue: aColorValue scaledGreen
				from: scalingValue
				to: 255)
				bitShift: 8) + (self
			convertValue: aColorValue scaledBlue
			from: scalingValue
			to: 255)! !


!BmpImageStream methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
nextImage
	self readBitmapFileHeader.
	self readBitmapInfoHeader.
	self readImagePalette.
	self readImageData.
	^imageObject! !

!BmpImageStream methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
nextPutImage: anImage 
	(anImage isKindOf: Image)
		ifFalse: [^self errorCanNotWrite].
	(anImage bitsPerPixel = 8 or: [anImage bitsPerPixel = 24])
		ifTrue: [imageObject := anImage]
		ifFalse: [anImage bitsPerPixel > 8
				ifTrue: [imageObject := anImage convertToPalette: (FixedPalette
									redShift: 16
									redMask: 255
									greenShift: 8
									greenMask: 255
									blueShift: 0
									blueMask: 255)]
				ifFalse: [Cursor wait showWhile: [imageObject := anImage convertToPalette: self class colorPalette256 renderedBy: ErrorDiffusion new]]].
	self writeBitmapFileHeader.
	self writeBitmapInfoHeader.
	self writeImagePalette.
	self writeImageData.
	bfSize := self position.
	^anImage! !


!BmpImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
nextLSBLong
	^self next + (self next bitShift: 8) + (self next bitShift: 16) + (self next bitShift: 24)! !

!BmpImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
nextLSBLongPut: a32BitW 
	self nextPut: (a32BitW bitAnd: 255).
	self nextPut: ((a32BitW bitShift: -8)
			bitAnd: 255).
	self nextPut: ((a32BitW bitShift: -16)
			bitAnd: 255).
	self nextPut: ((a32BitW bitShift: -24)
			bitAnd: 255)! !

!BmpImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
nextLSBWord
	^self next + (self next bitShift: 8)! !

!BmpImageStream methodsFor: 'stream access' stamp: ' 21/4/07 22:07'!
nextLSBWordPut: a16BitW 
	self nextPut: (a16BitW bitAnd: 255).
	self nextPut: ((a16BitW bitShift: -8)
			bitAnd: 255)! !


!BmpImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readBitmapFileHeader
	| position |
	position := self position.
	(self hasMagicNumber: 'BM' asByteArray)
		ifFalse: [^self errorCanNotRead].
	self position: position.
	bfType := self nextWord.
	bfSize := self nextLSBLong.
	bfReserved1 := self nextLSBWord.
	bfReserved2 := self nextLSBWord.
	bfOffBits := self nextLSBLong! !

!BmpImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readBitmapInfoHeader
	biSize := self nextLSBLong.
	biWidth := self nextLSBLong.
	biHeight := self nextLSBLong.
	biPlanes := self nextLSBWord.
	biBitCount := self nextLSBWord.
	biCompression := self nextLSBLong.
	biSizeImage := self nextLSBLong.
	biXPelsPerMeter := self nextLSBLong.
	biYPelsPerMeter := self nextLSBLong.
	biClrUsed := self nextLSBLong.
	biClrImportant := self nextLSBLong! !

!BmpImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readDepth1Data
	| image total progress count index |
	self position: bfOffBits.
	image := Image
				extent: biWidth @ biHeight
				depth: biBitCount
				palette: imagePalette.
	total := biWidth * biHeight.
	progress := 0.
	self progress: progress / total.
	biHeight - 1
		to: 0
		by: -1
		do: 
			[:y | 
			count := 128.
			0 to: biWidth - 1
				do: 
					[:x | 
					count = 128 ifTrue: [index := self next].
					image
						atX: x
						y: y
						put: (index bitAnd: count).
					count := count / 2.
					count < 1 ifTrue: [count := 128].
					progress := progress + 1.
					self progress: progress / total]].
	^image! !

!BmpImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readDepth1Palette
	^MappedPalette blackWhite! !

!BmpImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readDepth24Data
	| image total progress count rgb color index |
	self position: bfOffBits.
	image := Image
				extent: biWidth @ biHeight
				depth: biBitCount
				palette: imagePalette.
	total := biWidth * biHeight.
	progress := 0.
	self progress: progress / total.
	biHeight - 1
		to: 0
		by: -1
		do: 
			[:y | 
			count := 0.
			0 to: biWidth - 1
				do: 
					[:x | 
					rgb := self next + (self next bitShift: 8) + (self next bitShift: 16).
					color := self colorValueFrom: rgb.
					index := image palette indexOfPaintNearest: color.
					image
						atX: x
						y: y
						put: index.
					count := count + 3.
					progress := progress + 1.
					self progress: progress / total].
			[count \\ 4 = 0]
				whileFalse: 
					[self next.
					count := count + 1]].
	^image! !

!BmpImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readDepth24Palette
	^FixedPalette
		redShift: 16
		redMask: 255
		greenShift: 8
		greenMask: 255
		blueShift: 0
		blueMask: 255! !

!BmpImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readDepth8Data
	| image total progress count index |
	self position: bfOffBits.
	image := Image
				extent: biWidth @ biHeight
				depth: biBitCount
				palette: imagePalette.
	total := biWidth * biHeight.
	progress := 0.
	self progress: progress / total.
	biHeight - 1
		to: 0
		by: -1
		do: 
			[:y | 
			count := 0.
			0 to: biWidth - 1
				do: 
					[:x | 
					index := self next.
					image
						atX: x
						y: y
						put: index.
					count := count + 1.
					progress := progress + 1.
					self progress: progress / total].
			[count \\ 4 = 0]
				whileFalse: 
					[self next.
					count := count + 1]].
	^image! !

!BmpImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readDepth8Palette
	| size colors rgb color |
	size := 1 bitShift: biBitCount.
	biClrUsed = 0 ifFalse: [size := biClrUsed].
	colors := Array new: size.
	1 to: size
		do: 
			[:index | 
			rgb := self next + (self next bitShift: 8) + (self next bitShift: 16).
			self next.
			color := self colorValueFrom: rgb.
			colors at: index put: color].
	^MappedPalette withColors: colors! !

!BmpImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readImageData
	biCompression = 0 ifFalse: [^self errorCanNotRead].
	imageObject := nil.
	biBitCount = 24 ifTrue: [imageObject := self readDepth24Data].
	biBitCount = 8 ifTrue: [imageObject := self readDepth8Data].
	biBitCount = 1 ifTrue: [imageObject := self readDepth1Data].
	imageObject isNil ifTrue: [^self errorCanNotRead].
	^imageObject! !

!BmpImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readImagePalette
	imagePalette := nil.
	biBitCount = 24 ifTrue: [imagePalette := self readDepth24Palette].
	biBitCount = 8 ifTrue: [imagePalette := self readDepth8Palette].
	biBitCount = 1 ifTrue: [imagePalette := self readDepth1Palette].
	imagePalette isNil ifTrue: [^self errorCanNotRead]! !


!BmpImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeBitmapFileHeader
	bfType := ($B asInteger bitShift: 8)
				+ $M asInteger.
	bfSize := 0.
	bfReserved1 := 0.
	bfReserved2 := 0.
	bfOffBits := nil.
	imageObject bitsPerPixel = 8 ifTrue: [bfOffBits := 54 + (imageObject palette size * 4)].
	imageObject bitsPerPixel = 24 ifTrue: [bfOffBits := 54].
	bfOffBits isNil ifTrue: [^self errorCanNotWrite].
	self nextWordPut: bfType.
	self nextLSBLongPut: bfSize.
	self nextLSBWordPut: bfReserved1.
	self nextLSBWordPut: bfReserved2.
	self nextLSBLongPut: bfOffBits! !

!BmpImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeBitmapInfoHeader
	biSize := 40.
	biWidth := imageObject width.
	biHeight := imageObject height.
	biPlanes := 1.
	biBitCount := imageObject bitsPerPixel.
	biCompression := 0.
	biSizeImage := 0.
	biXPelsPerMeter := 0.
	biYPelsPerMeter := 0.
	biClrUsed := 0.
	imageObject bitsPerPixel = 8 ifTrue: [biClrUsed := (imageObject palette size)].
	biClrImportant := 0.
	self nextLSBLongPut: biSize.
	self nextLSBLongPut: biWidth.
	self nextLSBLongPut: biHeight.
	self nextLSBWordPut: biPlanes.
	self nextLSBWordPut: biBitCount.
	self nextLSBLongPut: biCompression.
	self nextLSBLongPut: biSizeImage.
	self nextLSBLongPut: biXPelsPerMeter.
	self nextLSBLongPut: biYPelsPerMeter.
	self nextLSBLongPut: biClrUsed.
	self nextLSBLongPut: biClrImportant! !

!BmpImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeDepth24Data
	| total progress count index color rgb |
	self position = bfOffBits ifFalse: [^self errorCanNotWrite].
	total := biWidth * biHeight.
	progress := 0.
	self progress: progress / total.
	biHeight - 1
		to: 0
		by: -1
		do: 
			[:y | 
			count := 0.
			0 to: biWidth - 1
				do: 
					[:x | 
					index := imageObject atX: x y: y.
					color := imageObject palette at: index.
					rgb := self rgbIntegerFrom: color.
					self nextPut: (rgb bitAnd: 255).
					self nextPut: ((rgb bitShift: -8)
							bitAnd: 255).
					self nextPut: ((rgb bitShift: -16)
							bitAnd: 255).
					count := count + 3.
					progress := progress + 1.
					self progress: progress / total].
			[count \\ 4 = 0]
				whileFalse: 
					[self nextPut: 0.
					count := count + 1]].
	^imageObject! !

!BmpImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeDepth24Palette
	^imageObject palette! !

!BmpImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeDepth8Data
	| count index |
	self position = bfOffBits ifFalse: [^self errorCanNotWrite].
"
	total := biWidth * biHeight.
	progress := 0.
	self progress: progress / total. 
"
	biHeight - 1
		to: 0
		by: -1
		do: 
			[:y | 
			count := 0.
			0 to: biWidth - 1
				do: 
					[:x | 
					index := imageObject atX: x y: y.
					self nextPut: index.
					count := count + 1.
"					progress := progress + 1.
					self progress: progress / total
"
					].
			[count \\ 4 = 0]
				whileFalse: 
					[self nextPut: 0.
					count := count + 1]].
	^imageObject! !

!BmpImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeDepth8Palette
	| size palette array |
	size := 1 bitShift: biBitCount.
	palette := imageObject palette.
	palette size = size ifFalse: [self errorCanNotWrite].
	array := self rgbIntegerArrayFor: palette.
	array
		do: 
			[:rgb | 
			self nextPut: (rgb bitAnd: 255).
			self nextPut: ((rgb bitShift: -8)
					bitAnd: 255).
			self nextPut: ((rgb bitShift: -16)
					bitAnd: 255).
			self nextPut: 0].
	^imageObject palette! !

!BmpImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeImageData
	biCompression = 0 ifFalse: [^self errorCanNotWrite].
	biBitCount = 24 ifTrue: [^self writeDepth24Data].
	biBitCount = 8 ifTrue: [^self writeDepth8Data].
	^self errorCanNotWrite! !

!BmpImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeImagePalette
	imagePalette := nil.
	biBitCount = 24 ifTrue: [imagePalette := self writeDepth24Palette].
	biBitCount = 8 ifTrue: [imagePalette := self writeDepth8Palette].
	imagePalette isNil ifTrue: [^self errorCanNotWrite]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BmpImageStream class
	instanceVariableNames: ''!

!BmpImageStream class methodsFor: 'copyright' stamp: ' 21/4/07 22:07'!
copyright
	^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'! !

!BmpImageStream class methodsFor: 'copyright' stamp: ' 21/4/07 22:07'!
system
	^'Goodies'! !

!BmpImageStream class methodsFor: 'copyright' stamp: ' 21/4/07 22:07'!
version
	^'003'! !


!BmpImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example1
	"BmpImageStream example1."

	| image filename stream |
	image := Image fromUser.
	filename := 'zzz.bmp' asFilename.
	stream := BmpImageStream on: filename writeStream.
	[Cursor write showWhile: [stream nextPutImage: image]]
		valueNowOrOnUnwindDo: [stream close].
	^image! !

!BmpImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example2
	"BmpImageStream example2."

	| filename stream image |
	filename := 'zzz.bmp' asFilename.
	stream := BmpImageStream on: filename readStream.
	[Cursor read showWhile: [image := stream nextImage]]
		valueNowOrOnUnwindDo: [stream close].
	stream show: image.
	^image! !

!BmpImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example3
	"BmpImageStream example3."

	| image filename stream |
	image := Image fromUser.
	filename := 'zzz.bmp' asFilename.
	stream := BmpImageStream on: filename writeStream.
	[Cursor write
		showWhile: 
			[stream compute: [:value | Transcript cr; show: value printString].
			stream nextPutImage: image]]
		valueNowOrOnUnwindDo: [stream close].
	^image! !

!BmpImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example4
	"BmpImageStream example4."

	| filename stream image |
	filename := 'zzz.bmp' asFilename.
	stream := BmpImageStream on: filename readStream.
	[Cursor read
		showWhile: 
			[stream compute: [:value | Transcript cr; show: value printString].
			image := stream nextImage]]
		valueNowOrOnUnwindDo: [stream close].
	stream show: image.
	^image! !

!BmpImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example5
	"BmpImageStream example5."

	| image filename stream progress |
	image := Image fromUser.
	filename := 'zzz.bmp' asFilename.
	stream := BmpImageStream on: filename writeStream.
	[Cursor write
		showWhile: 
			[progress := Progress new.
			stream compute: [:value | progress value: value].
			progress message: 'writing bmp...'.
			progress do: [stream nextPutImage: image]]]
		valueNowOrOnUnwindDo: [stream close].
	^image! !

!BmpImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example6
	"BmpImageStream example6."

	| filename stream progress image |
	filename := 'zzz.bmp' asFilename.
	stream := BmpImageStream on: filename readStream.
	[Cursor read
		showWhile: 
			[progress := Progress new.
			stream compute: [:value | progress value: value].
			progress message: 'reading bmp...'.
			progress do: [image := stream nextImage]]]
		valueNowOrOnUnwindDo: [stream close].
	stream show: image.
	^image! !


ImageStream subclass: #GifImageStream
	instanceVariableNames: 'width height bitsPerPixel colorPalette rowByteSize xpos ypos pass interlace codeSize clearCode eoiCode freeCode maxCode prefixTable suffixTable remainBitCount bufByte bufStream transparentPixel'
	classVariableNames: 'Extension GraphicControlLabel ImageSeparator Terminator'
	poolDictionaries: ''
	category: 'Aida-Imaging'!
!GifImageStream commentStamp: '<historical>' prior: 0!
GifImageStream 

Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.
!


!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
checkCodeSize
	(freeCode > maxCode and: [codeSize < 12])
		ifTrue:
			[codeSize := codeSize + 1.
			maxCode := (1 bitShift: codeSize) - 1]! !

!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
colorValueFrom: rgbInteger 
	| scalingValue |
	scalingValue := ColorValue scalingValue.
	^ColorValue
		scaledRed: (self
				convertValue: ((rgbInteger bitShift: -16)
						bitAnd: 255)
				from: 255
				to: scalingValue)
		scaledGreen: (self
				convertValue: ((rgbInteger bitShift: -8)
						bitAnd: 255)
				from: 255
				to: scalingValue)
		scaledBlue: (self
				convertValue: (rgbInteger bitAnd: 255)
				from: 255
				to: scalingValue)! !

!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
convertToCoverageWithTransparentPixel: pixelValue with: anImage 
	| image row |
	image := Image
				extent: anImage extent
				depth: 1
				palette: CoveragePalette monoMaskPalette.
	0 to: anImage height - 1
		do: 
			[:i | 
			row := anImage rowAt: i.
			row := row collect: [:p | p = pixelValue
							ifTrue: [0]
							ifFalse: [1]].
			image rowAt: i putAll: row].
	^image! !

!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
convertToGray: coverageValue 
	coverageValue = CoverageValue transparent ifTrue: [^ColorValue white].
	coverageValue = CoverageValue opaque ifTrue: [^ColorValue black].
	^ColorValue brightness: coverageValue coverage! !

!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
convertToMappedPalette: coveragePalette 
	coveragePalette size = 2 ifTrue: [^MappedPalette whiteBlack].
	^MappedPalette withColors: (coveragePalette collect: [:coverage | self convertToGray: coverage])! !

!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
packBits: bits depthFrom8To: depth width: xSize height: ySize pad: pad 
	| maxPixelVal pixelInByte bitsWidth pBitsWidth pBits |
	(#(1 2 4) includes: depth)
		ifFalse: [^self error: 'depth must be 1, 2, or 4'].
	(#(8 16 32) includes: pad)
		ifFalse: [^self error: 'pad must be 8, 16, or 32'].
	maxPixelVal := (1 bitShift: depth)
				- 1.
	pixelInByte := 8 / depth.
	bitsWidth := xSize * 8 + pad - 1 // pad * (pad / 8).
	pBitsWidth := xSize * depth + pad - 1 // pad * (pad / 8).
	pBits := ByteArray new: pBitsWidth * ySize.
	1 to: ySize
		do: 
			[:i | 
			| bitIndex pBitIndex pixelVal count |
			bitIndex := i - 1 * bitsWidth.
			pBitIndex := i - 1 * pBitsWidth.
			pixelVal := 0.
			count := 0.
			1 to: xSize
				do: 
					[:j | 
					| val |
					val := bits at: (bitIndex := bitIndex + 1).
					val > maxPixelVal ifTrue: [^self error: 'can''t pack bits'].
					pixelVal := (pixelVal bitShift: depth)
								+ val.
					(count := count + 1) >= pixelInByte
						ifTrue: 
							[pBits at: (pBitIndex := pBitIndex + 1) put: pixelVal.
							pixelVal := 0.
							count := 0]].
			count > 0 ifTrue: [pBits at: (pBitIndex := pBitIndex + 1) put: (pixelVal bitShift: depth * (pixelInByte - count))]].
	^pBits! !

!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
rgbIntegerArrayFor: aPalette 
	| colors |
	colors := Array new: aPalette maxIndex + 1.
	1 to: colors size do: [:i | colors at: i put: (self rgbIntegerFrom: (aPalette at: i - 1 ifAbsent: [ColorValue white]))].
	^colors! !

!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
rgbIntegerFrom: aColorValue 
	| scalingValue |
	scalingValue := ColorValue scalingValue.
	^((self
		convertValue: aColorValue scaledRed
		from: scalingValue
		to: 255)
		bitShift: 16)
		+ ((self
				convertValue: aColorValue scaledGreen
				from: scalingValue
				to: 255)
				bitShift: 8) + (self
			convertValue: aColorValue scaledBlue
			from: scalingValue
			to: 255)! !

!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
setParameters: initCodeSize
	clearCode := 1 bitShift: initCodeSize.
	eoiCode := clearCode + 1.
	freeCode := clearCode + 2.
	codeSize := initCodeSize + 1.
	maxCode := (1 bitShift: codeSize) - 1! !

!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
unpackBits: bits depthTo8From: depth width: xSize height: ySize pad: pad 
	| bitMask pixelInByte bitsWidth upBitsWidth stopWidth trailingSize upBits |
	(#(1 2 4) includes: depth)
		ifFalse: [^self error: 'depth must be 1, 2, or 4'].
	(#(8 16 32) includes: pad)
		ifFalse: [^self error: 'pad must be 8, 16, or 32'].
	bitMask := (1 bitShift: depth)
				- 1.
	pixelInByte := 8 / depth.
	bitsWidth := xSize * depth + pad - 1 // pad * (pad / 8).
	upBitsWidth := xSize * 8 + pad - 1 // pad * (pad / 8).
	stopWidth := xSize * depth + 7 // 8.
	trailingSize := xSize - (stopWidth - 1 * pixelInByte).
	upBits := ByteArray new: upBitsWidth * ySize.
	1 to: ySize
		do: 
			[:i | 
			| bitIndex upBitIndex val |
			bitIndex := i - 1 * bitsWidth.
			upBitIndex := i - 1 * upBitsWidth.
			1 to: stopWidth - 1
				do: 
					[:j | 
					val := bits at: (bitIndex := bitIndex + 1).
					upBitIndex := upBitIndex + pixelInByte.
					1 to: pixelInByte
						do: 
							[:k | 
							upBits at: upBitIndex - k + 1 put: (val bitAnd: bitMask).
							val := val bitShift: depth negated]].
			val := (bits at: (bitIndex := bitIndex + 1))
						bitShift: depth negated * (pixelInByte - trailingSize).
			upBitIndex := upBitIndex + trailingSize.
			1 to: trailingSize
				do: 
					[:k | 
					upBits at: upBitIndex - k + 1 put: (val bitAnd: bitMask).
					val := val bitShift: depth negated]].
	^upBits! !

!GifImageStream methodsFor: 'private' stamp: ' 21/4/07 22:07'!
updatePixelPosition
	(xpos := xpos + 1) >= width ifFalse: [^self].
	xpos := 0.
	interlace
		ifFalse: 
			[ypos := ypos + 1.
			^self].
	pass = 0
		ifTrue: 
			[(ypos := ypos + 8) >= height
				ifTrue: 
					[pass := pass + 1.
					ypos := 4].
			^self].
	pass = 1
		ifTrue: 
			[(ypos := ypos + 8) >= height
				ifTrue: 
					[pass := pass + 1.
					ypos := 2].
			^self].
	pass = 2
		ifTrue: 
			[(ypos := ypos + 4) >= height
				ifTrue: 
					[pass := pass + 1.
					ypos := 1].
			^self].
	pass = 3
		ifTrue: 
			[ypos := ypos + 2.
			^self].
	^self error: 'can''t happen'! !


!GifImageStream methodsFor: 'packing' stamp: ' 21/4/07 22:07'!
fillBuffer
	| packSize |
	packSize := self next.
	bufStream := ReadStream on: (self next: packSize)! !

!GifImageStream methodsFor: 'packing' stamp: ' 21/4/07 22:07'!
flushBuffer
	bufStream isEmpty ifTrue: [^self].
	self nextPut: bufStream size.
	self nextPutAll: bufStream contents.
	bufStream := WriteStream on: (ByteArray new: 256)! !

!GifImageStream methodsFor: 'packing' stamp: ' 21/4/07 22:07'!
nextByte
	bufStream atEnd
		ifTrue:
			[self atEnd ifTrue: [^nil].
			self fillBuffer].
	^bufStream next! !

!GifImageStream methodsFor: 'packing' stamp: ' 21/4/07 22:07'!
nextBytePut: aByte
	bufStream nextPut: aByte.
	bufStream size >= 254 ifTrue: [self flushBuffer]! !

!GifImageStream methodsFor: 'packing' stamp: ' 21/4/07 22:07'!
peekByte
	bufStream atEnd
		ifTrue:
			[self atEnd ifTrue: [^nil].
			self fillBuffer].
	^bufStream peek! !


!GifImageStream methodsFor: 'bits access' stamp: ' 21/4/07 22:07'!
flushBits
	remainBitCount = 0
		ifFalse: 
			[self nextBytePut: bufByte.
			remainBitCount := 0].
	self flushBuffer! !

!GifImageStream methodsFor: 'bits access' stamp: ' 21/4/07 22:07'!
nextBits
	| integer readBitCount shiftCount |
	integer := 0.
	remainBitCount = 0
		ifTrue: 
			[readBitCount := 8.
			shiftCount := 0]
		ifFalse: 
			[readBitCount := remainBitCount.
			shiftCount := remainBitCount - 8].
	[readBitCount < codeSize]
		whileTrue: 
			[self peekByte isNil ifTrue: [^eoiCode].
			integer := integer + (self nextByte bitShift: shiftCount).
			shiftCount := shiftCount + 8.
			readBitCount := readBitCount + 8].
	self peekByte isNil ifTrue: [^eoiCode].
	(remainBitCount := readBitCount - codeSize) = 0
		ifTrue: [integer := integer + (self nextByte bitShift: shiftCount)]
		ifFalse: [integer := integer + (self peekByte bitShift: shiftCount)].
	^integer bitAnd: maxCode! !

!GifImageStream methodsFor: 'bits access' stamp: ' 21/4/07 22:07'!
nextBitsPut: anInteger 
	| integer writeBitCount shiftCount |
	shiftCount := 0.
	remainBitCount = 0
		ifTrue: 
			[writeBitCount := 8.
			integer := anInteger]
		ifFalse: 
			[writeBitCount := remainBitCount.
			integer := bufByte + (anInteger bitShift: 8 - remainBitCount)].
	[writeBitCount < codeSize]
		whileTrue: 
			[self nextBytePut: ((integer bitShift: shiftCount)
					bitAnd: 255).
			shiftCount := shiftCount - 8.
			writeBitCount := writeBitCount + 8].
	(remainBitCount := writeBitCount - codeSize) = 0
		ifTrue: [self nextBytePut: (integer bitShift: shiftCount)]
		ifFalse: [bufByte := integer bitShift: shiftCount].
	^anInteger! !


!GifImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
flushCode
	self flushBits! !

!GifImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
readPixelFrom: bits
	| pixel |
	ypos >= height ifTrue: [^nil].
	pixel := bits at: (ypos * rowByteSize + xpos + 1).
	self updatePixelPosition.
	^pixel! !

!GifImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeBitData: bits 
	| maxBits maxMaxCode tSize initCodeSize ent tShift fCode pixel set |

	pass := 0.
	xpos := 0.
	ypos := 0.
	rowByteSize := width * 8 + 31 // 32 * 4.
	remainBitCount := 0.
	bufByte := 0.
	bufStream := WriteStream on: (ByteArray new: 256).
	maxBits := 12.
	maxMaxCode := 1 bitShift: maxBits.
	tSize := 5003.
	prefixTable := Array new: tSize.
	suffixTable := Array new: tSize.
	initCodeSize := bitsPerPixel <= 1
				ifTrue: [2]
				ifFalse: [bitsPerPixel].
	self nextPut: initCodeSize.
	self setParameters: initCodeSize.
	tShift := 0.
	fCode := tSize.
	[fCode < 65536]
		whileTrue: 
			[tShift := tShift + 1.
			fCode := fCode * 2].
	tShift := 8 - tShift.
	1 to: tSize do: [:i | suffixTable at: i put: -1].

"	set := Set new: height.
	self progress: set size / height.
	set add: ypos. 
	self progress: set size / height."

	self writeCodeAndCheckCodeSize: clearCode.
	ent := self readPixelFrom: bits.
	[(pixel := self readPixelFrom: bits) == nil]
		whileFalse: 
			[| index disp nomatch |

"			set add: ypos. 
			self progress: set size / height."

			fCode := (pixel bitShift: maxBits)
						+ ent.
			index := ((pixel bitShift: tShift)
						bitXor: ent)
						+ 1.
			(suffixTable at: index)
				= fCode
				ifTrue: [ent := prefixTable at: index]
				ifFalse: 
					[nomatch := true.
					(suffixTable at: index)
						>= 0
						ifTrue: 
							[disp := tSize - index + 1.
							index = 1 ifTrue: [disp := 1].
							
							[(index := index - disp) < 1 ifTrue: [index := index + tSize].
							(suffixTable at: index)
								= fCode
								ifTrue: 
									[ent := prefixTable at: index.
									nomatch := false].
							nomatch and: [(suffixTable at: index)
									> 0]] whileTrue].
					nomatch
						ifTrue: 
							[self writeCodeAndCheckCodeSize: ent.
							ent := pixel.
							freeCode < maxMaxCode
								ifTrue: 
									[prefixTable at: index put: freeCode.
									suffixTable at: index put: fCode.
									freeCode := freeCode + 1]
								ifFalse: 
									[self writeCodeAndCheckCodeSize: clearCode.
									1 to: tSize do: [:i | suffixTable at: i put: -1].
									self setParameters: initCodeSize]]].
"			set add: ypos. 
			self progress: set size / height"].

	prefixTable := suffixTable := nil.
	self writeCodeAndCheckCodeSize: ent.
	self writeCodeAndCheckCodeSize: eoiCode.
	self flushCode.
	self nextPut: 0.
	self nextPut: Terminator! !

!GifImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeCode: aCode
	self nextBitsPut: aCode! !

!GifImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeCodeAndCheckCodeSize: aCode
	self writeCode: aCode.
	self checkCodeSize! !

!GifImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeHeader
	| byte array |
	self nextPutAll: 'GIF89a' asByteArray.
	self writeWord: width.
	self writeWord: height.
	byte := 128.
	byte := byte bitOr: (bitsPerPixel - 1 bitShift: 5).
	byte := byte bitOr: bitsPerPixel - 1.
	self nextPut: byte.
	self nextPut: 0.
	self nextPut: 0.
	array := self rgbIntegerArrayFor: colorPalette.
	array do: [:rgb | self nextPut: ((rgb bitShift: -16)
				bitAnd: 255); nextPut: ((rgb bitShift: -8)
				bitAnd: 255); nextPut: (rgb bitAnd: 255)].
	array size + 1 to: (1 bitShift: bitsPerPixel)
		do: [:i | self nextPut: 0; nextPut: 0; nextPut: 0].
	transparentPixel notNil ifTrue: [self writeGraphicControlExtensionBlock].
	self nextPut: ImageSeparator.
	self writeWord: 0.
	self writeWord: 0.
	self writeWord: width.
	self writeWord: height.
	byte := interlace
				ifTrue: [64]
				ifFalse: [0].
	self nextPut: byte! !

!GifImageStream methodsFor: 'encoding' stamp: ' 21/4/07 22:07'!
writeWord: aWord 
	self nextPut: (aWord bitAnd: 255).
	self nextPut: ((aWord bitShift: -8)
			bitAnd: 255).
	^aWord! !


!GifImageStream methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
nextImage
	| bits depth image |
	self readHeader isNil ifTrue: [^nil].
	bits := self readBitData.
	depth := bitsPerPixel > 8
				ifTrue: [^self error: 'unexpected bits per pixel']
				ifFalse: [bitsPerPixel = 1
						ifTrue: [1]
						ifFalse: [bitsPerPixel = 2
								ifTrue: [2]
								ifFalse: [bitsPerPixel <= 4
										ifTrue: [4]
										ifFalse: [8]]]].
	depth < 8 ifTrue: [bits := self
					packBits: bits
					depthFrom8To: depth
					width: width
					height: height
					pad: 8].
	image := Image
				extent: width @ height
				depth: depth
				palette: colorPalette
				bits: bits
				pad: 8.
	transparentPixel notNil ifTrue: [image := OpaqueImage figure: image shape: (CachedImage on: (self convertToCoverageWithTransparentPixel: transparentPixel with: image) asRetainedMedium)].
	^image! !

!GifImageStream methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
nextPutImage: anImage 
	| theImage trueBitsPerPixel achievableBitsPerPixel bits |
	(anImage isKindOf: Image)
		ifFalse: [^self errorCanNotWrite].
	anImage bitsPerPixel > 8
		ifTrue: [theImage := anImage convertToPalette: self class colorPalette256 "renderedBy: ErrorDiffusion new"]
		ifFalse: [theImage := anImage].
	width := theImage width.
	height := theImage height.
	colorPalette := theImage palette.
	trueBitsPerPixel := theImage bitsPerPixel.
	achievableBitsPerPixel := 2 raisedTo: ((colorPalette size - 1) highBit - 1) highBit.
	bitsPerPixel := achievableBitsPerPixel.
	colorPalette := theImage palette.
	colorPalette paintBasis == CoverageValue
		ifTrue: 
			[transparentPixel := 0.
			colorPalette := self convertToMappedPalette: colorPalette].
	bits := theImage bits.
	trueBitsPerPixel < 8 ifTrue: [bits := self
					unpackBits: bits
					depthTo8From: bitsPerPixel
					width: theImage width
					height: theImage height
					pad: 32].
	interlace := true.
	
	[self writeHeader.
	self writeBitData: bits]
		valueNowOrOnUnwindDo: [self close].
	^theImage! !


!GifImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readBitData
	| bits outCodes outCount bitMask initCodeSize code curCode oldCode inCode finChar set |
	pass := 0.
	xpos := 0.
	ypos := 0.
	rowByteSize := width * 8 + 7 // 8.
	remainBitCount := 0.
	bufByte := 0.
	bufStream := ReadStream on: ByteArray new.
	bits := ByteArray new: width * height.
	outCodes := ByteArray new: 1025.
	outCount := 0.
	bitMask := (1 bitShift: bitsPerPixel)
				- 1.
	prefixTable := Array new: 4096.
	suffixTable := Array new: 4096.
	initCodeSize := self next.
	self setParameters: initCodeSize.
	set := Set new: height.
	self progress: set size / height.
	[(code := self readCode) = eoiCode]
		whileFalse: [code = clearCode
				ifTrue: 
					[self setParameters: initCodeSize.
					curCode := oldCode := code := self readCode.
					finChar := curCode bitAnd: bitMask.
					set add: ypos.
					self progress: set size / height.
					self writePixel: finChar to: bits]
				ifFalse: 
					[curCode := inCode := code.
					curCode >= freeCode
						ifTrue: 
							[curCode := oldCode.
							outCodes at: (outCount := outCount + 1) put: finChar].
					[curCode > bitMask]
						whileTrue: 
							[outCount > 1024 ifTrue: [^self error: 'corrupt GIF file (OutCount)'].
							outCodes at: (outCount := outCount + 1) put: (suffixTable at: curCode + 1).
							curCode := prefixTable at: curCode + 1].
					finChar := curCode bitAnd: bitMask.
					outCodes at: (outCount := outCount + 1) put: finChar.
					outCount
						to: 1
						by: -1
						do: 
							[:i | 
							set add: ypos.
							self progress: set size / height.
							self writePixel: (outCodes at: i)
								to: bits].
					outCount := 0.
					prefixTable at: freeCode + 1 put: oldCode.
					suffixTable at: freeCode + 1 put: finChar.
					oldCode := inCode.
					freeCode := freeCode + 1.
					self checkCodeSize]].
	prefixTable := suffixTable := nil.
	^bits! !

!GifImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readCode
	^self nextBits! !

!GifImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readHeader
	| byte hasColorMap |
	((self hasMagicNumber: 'GIF89a' asByteArray)
		or: [self hasMagicNumber: 'GIF87a' asByteArray])
		ifFalse: [^self errorCanNotRead].
	self readWord.
	self readWord.
	byte := self next.
	hasColorMap := (byte bitAnd: 128)
				~= 0.
	bitsPerPixel := (byte bitAnd: 7)
				+ 1.
	byte := self next.
	byte := self next.
	hasColorMap
		ifTrue: 
			[| array |
			array := Array new: (1 bitShift: bitsPerPixel).
			1 to: array size do: [:i | array at: i put: (self colorValueFrom: (self next bitShift: 16)
							+ (self next bitShift: 8) + self next)].
			colorPalette := MappedPalette withColors: array]
		ifFalse: 
			[Transcript cr; show: 'GIF file does not have a color map.'.
			colorPalette := MappedPalette monochromeDefault].
	
	[byte := self next.
	byte == Extension]
		whileTrue: [self readExtension].
	byte = ImageSeparator ifFalse: [^self error: 'corrupt GIF file (nosep)'].
	self readWord.
	self readWord.
	width := self readWord.
	height := self readWord.
	interlace := (self next bitAnd: 64)
				~= 0! !

!GifImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
readWord
	^self next + (self next bitShift: 8)! !

!GifImageStream methodsFor: 'decoding' stamp: ' 21/4/07 22:07'!
writePixel: pixel to: bits 
	bits at: ypos * rowByteSize + xpos + 1 put: pixel.
	self updatePixelPosition! !


!GifImageStream methodsFor: 'GIF89a' stamp: ' 21/4/07 22:07'!
readExtension
	| label |
	label := self next.
	label == GraphicControlLabel
		ifTrue: [self readGraphicControlExtensionBlock]
		ifFalse: [self error: 'unsupported extension block']! !

!GifImageStream methodsFor: 'GIF89a' stamp: ' 21/4/07 22:07'!
readGraphicControlExtensionBlock
	| isTransparent |
	self next.
	isTransparent := (self next bitAnd: 1)
				= 1.
	self next: 2.
	isTransparent
		ifTrue: [transparentPixel := self next]
		ifFalse: [self next].
	self next! !

!GifImageStream methodsFor: 'GIF89a' stamp: ' 21/4/07 22:07'!
transparentPixel: aPixelValueOrNil 
	transparentPixel := aPixelValueOrNil! !

!GifImageStream methodsFor: 'GIF89a' stamp: ' 21/4/07 22:07'!
writeGraphicControlExtensionBlock
	self nextPut: Extension.
	self nextPut: GraphicControlLabel.
	self nextPut: 4.
	transparentPixel notNil
		ifTrue: [self nextPut: 1]
		ifFalse: [self nextPut: 0].
	self nextPut: 0.
	self nextPut: 0.
	transparentPixel notNil
		ifTrue: [self nextPut: transparentPixel]
		ifFalse: [self nextPut: 0].
	self nextPut: 0! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GifImageStream class
	instanceVariableNames: ''!

!GifImageStream class methodsFor: 'copyright' stamp: ' 21/4/07 22:07'!
copyright
	^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'! !

!GifImageStream class methodsFor: 'copyright' stamp: ' 21/4/07 22:07'!
system
	^'Goodies'! !

!GifImageStream class methodsFor: 'copyright' stamp: ' 21/4/07 22:07'!
version
	^'003'! !


!GifImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example1
	"GifImageStream example1."

	| image filename stream |
	image := Image fromUser.
	filename := 'zzz.gif' asFilename.
	stream := GifImageStream on: filename writeStream.
	[Cursor write showWhile: [stream nextPutImage: image]]
		valueNowOrOnUnwindDo: [stream close].
	^image! !

!GifImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example2
	"GifImageStream example2."

	| filename stream image |
	filename := 'zzz.gif' asFilename.
	stream := GifImageStream on: filename readStream.
	[Cursor read showWhile: [image := stream nextImage]]
		valueNowOrOnUnwindDo: [stream close].
	stream show: image.
	^image! !

!GifImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example3
	"GifImageStream example3."

	| image filename stream |
	image := Image fromUser.
	filename := 'zzz.gif' asFilename.
	stream := GifImageStream on: filename writeStream.
	[Cursor write
		showWhile: 
			[stream compute: [:value | Transcript cr; show: value printString].
			stream nextPutImage: image]]
		valueNowOrOnUnwindDo: [stream close].
	^image! !

!GifImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example4
	"GifImageStream example4."

	| filename stream image |
	filename := 'zzz.gif' asFilename.
	stream := GifImageStream on: filename readStream.
	[Cursor read
		showWhile: 
			[stream compute: [:value | Transcript cr; show: value printString].
			image := stream nextImage]]
		valueNowOrOnUnwindDo: [stream close].
	stream show: image.
	^image! !

!GifImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example5
	"GifImageStream example5."

	| image filename stream progress |
	image := Image fromUser.
	filename := 'zzz.gif' asFilename.
	stream := GifImageStream on: filename writeStream.
	[Cursor write
		showWhile: 
			[progress := Progress new.
			stream compute: [:value | progress value: value].
			progress message: 'writing gif...'.
			progress do: [stream nextPutImage: image]]]
		valueNowOrOnUnwindDo: [stream close].
	^image! !

!GifImageStream class methodsFor: 'examples' stamp: ' 21/4/07 22:07'!
example6
	"GifImageStream example6."

	| filename stream image progress |
	filename := 'zzz.gif' asFilename.
	stream := GifImageStream on: filename readStream.
	[Cursor read
		showWhile: 
			[progress := Progress new.
			stream compute: [:value | progress value: value].
			progress message: 'reading gif...'.
			progress do: [image := stream nextImage]]]
		valueNowOrOnUnwindDo: [stream close].
	stream show: image.
	^image! !


!GifImageStream class methodsFor: 'class initialization' stamp: ' 21/4/07 22:07'!
initialize
	"GifImageStream initialize."

	ImageSeparator := $, asInteger.
	Extension := $!! asInteger.
	Terminator := $; asInteger.
	GraphicControlLabel := 249! !


FileProxy subclass: #WebCaptcha
	instanceVariableNames: 'text random'
	classVariableNames: 'Cache'
	poolDictionaries: ''
	category: 'Aida-Imaging'!
!WebCaptcha commentStamp: 'janko 3/22/2008 15:26' prior: 0!
A WebCaptcha provides a CAPTCHA image from input text, to be used for separating humans from bots, for instance when submiting blog comments (http://en.wikipedia.org/wiki/Captcha)

Our capthca is using ImageMagick (http://www.imagemagick.org) which must be installed first. It combines a background image (by default captcha-background.png, must be on current directory) with generated one from provided text in default font (see method fontName, currently Andy), which also must be installed and known to ImageMagick. 

To collect all installed fonts in your system for IMagics, run script
	imagick_type_gen > ~/.magics/type.xml

See http://www.imagemagick.org/Usage/scripts/imagick_type_gen

To see and change parameters of building captcha, look into method #prepareCaptchaImage!


!WebCaptcha methodsFor: 'accessing'!
aidaContentType
	^'image/png'.! !

!WebCaptcha methodsFor: 'accessing' stamp: 'janko 3/22/2008 18:35'!
randomCharacter
	"from 25 lowercase, 25 upercase, 10 numbers"
	| rnum |
	rnum := (Random new next * 60) truncated.
	rnum <= 25 ifTrue: [^($a asInteger + rnum) asCharacter].
	rnum <= 50 ifTrue: [^($A asInteger + rnum-25) asCharacter].
	^($0 asInteger + rnum-50) asCharacter
! !

!WebCaptcha methodsFor: 'accessing' stamp: 'janko 3/22/2008 18:40'!
randomCharacterOnGen: aRandom
	"from 25 lowercase, 25 upercase, 10 numbers"
	| rnum |
	rnum := (aRandom next * 60) truncated.
	rnum <= 25 ifTrue: [^($a asInteger + rnum) asCharacter].
	rnum <= 50 ifTrue: [^($A asInteger + rnum-25) asCharacter].
	^($0 asInteger + rnum-50) asCharacter
! !

!WebCaptcha methodsFor: 'accessing' stamp: 'janko 3/22/2008 18:42'!
setRandomText
	"5 characters or numbers"
	| rnd rgen |
	rnd := ByteString new: 5. rgen := Random new.
	1 to: 5 do: [:inx | rnd at: inx put: (self randomCharacterOnGen: rgen)].
	self text: rnd.
! !

!WebCaptcha methodsFor: 'accessing' stamp: 'janko 3/22/2008 18:27'!
text
	"string to be converted into captcha image"
	text isNil ifTrue: [^''].
	^text! !

!WebCaptcha methodsFor: 'accessing' stamp: 'janko 3/22/2008 18:27'!
text: aString
	"string to be converted into captcha image"
	text := aString! !


!WebCaptcha methodsFor: 'private' stamp: 'janko 4/25/2012 10:58'!
aidaIsRespondingStreamed
	^false! !

!WebCaptcha methodsFor: 'private' stamp: 'janko 3/22/2008 16:26'!
isExpired
	"it exists more than few hours"
	^(SpTimestamp now asSeconds - self preparedTimestamp asSeconds) > (10*3600)! !

!WebCaptcha methodsFor: 'private' stamp: 'janko 3/22/2008 16:07'!
preparedTimestamp
	^self timestamps at: #prepared ifAbsent: [nil]! !

!WebCaptcha methodsFor: 'private' stamp: 'janko 3/22/2008 16:08'!
setPreparedTimestamp
	^self timestamps at: #prepared put: SpTimestamp now.! !

!WebCaptcha methodsFor: 'private' stamp: 'janko 3/22/2008 15:59'!
size
	^self filename fileSize! !


!WebCaptcha methodsFor: 'private-streaming'!
aidaPresenterFor: aRequest on: aSession 
	^self! !

!WebCaptcha methodsFor: 'private-streaming'!
contentsOfCaptcha
	^self filename contentsOfEntireFileBinary asString! !

!WebCaptcha methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession 
	self prepareCaptchaImage.
	aStream nextPutAll: self contentsOfCaptcha.
	self filename delete.
	self class
		addToCache: self ;
		releaseExpiredCaptchas! !


!WebCaptcha methodsFor: 'defaults' stamp: 'janko 3/22/2008 01:16'!
backgroundImageFilename
	^'captcha-background.png'! !

!WebCaptcha methodsFor: 'defaults' stamp: 'janko 3/22/2008 15:11'!
fontName
	^'Andy'! !

!WebCaptcha methodsFor: 'defaults' stamp: 'janko 3/22/2008 23:23'!
imageSize
	^150@30	! !


!WebCaptcha methodsFor: 'converting' stamp: 'janko 7/18/2008 17:52'!
prepareCaptchaImage
	| textFName captchaFName |
	textFName := 'captchatext', self random, '.png'. captchaFName := 'captcha', self random, '.png'.
	OSProcess waitForCommand: 
		'convert -size 150x30 xc:transparent -font ', self fontName, ' -pointsize 25 -draw "text 40,23 ''', 
		self text, ''' " ', textFName.
	OSProcess waitForCommand: 'composite -gravity center ', 
		textFName, ' ', self backgroundImageFilename, ' ',  captchaFName.
	(SpFilename named: textFName) delete.
	self filename: captchaFName.
	self setPreparedTimestamp.! !

!WebCaptcha methodsFor: 'converting' stamp: 'janko 7/18/2008 17:53'!
random
	random isNil ifTrue: 
		[random := (AIDASite random next * 1000) truncated printString].
	^random
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebCaptcha class
	instanceVariableNames: ''!

!WebCaptcha class methodsFor: 'private-cache' stamp: 'janko 3/22/2008 16:29'!
addToCache: aCaptcha
	self cache add: aCaptcha! !

!WebCaptcha class methodsFor: 'private-cache' stamp: 'janko 3/22/2008 16:28'!
cache
	Cache isNil ifTrue: [self initCache].
	^Cache! !

!WebCaptcha class methodsFor: 'private-cache' stamp: 'janko 3/22/2008 16:28'!
initCache
	Cache := Set new.! !

!WebCaptcha class methodsFor: 'private-cache' stamp: 'janko 3/22/2008 16:30'!
releaseExpiredCaptchas
	self cache do: [:each | 
		each isExpired ifTrue: [each removeYourself "from url resolver"]]! !


!WebCaptcha class methodsFor: 'instance creation' stamp: 'janko 3/22/2008 18:38'!
new
	"prepare a CAPTCHA with random string"
	| session |
	session := self firstSessionFromStack. "on which we are building this captcha"
	^super new 
		site: (session notNil ifTrue: [session site] ifFalse: [nil]);
		setRandomText! !

!WebCaptcha class methodsFor: 'instance creation' stamp: 'janko 3/22/2008 18:39'!
newFor: aString
	"prepare a CAPTCHA image for that string"
	^self new 
		text: aString! !


WebElement subclass: #WebLiveImage
	instanceVariableNames: 'gif refreshed width height painter'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Imaging'!
!WebLiveImage commentStamp: '<historical>' prior: 0!
WebLiveImage is used for live, dynamic GIF image construction.

Instance Variables:
	gif			<ByteArray>	content of image in GIF format
	refreshed	<Timestamp>	timestamp of last gif creation, used for caching algoritms

!


!WebLiveImage methodsFor: 'private-caching' stamp: ' 21/4/07 22:07'!
addToCache
	self makeRoomInCache.
	self class cache add: self.! !

!WebLiveImage methodsFor: 'private-caching' stamp: ' 21/4/07 22:07'!
cacheHysteresis
	"when removing from cache, make room for that number of entries"
	^10! !

!WebLiveImage methodsFor: 'private-caching' stamp: ' 21/4/07 22:07'!
makeRoomInCache
	"if cache is full, remove least used images"
	| cached  toRemove |
	self class cache size < self maxCacheSize ifTrue: [^self].
	cached := (SortedCollection 
		withAll: self class cache
		sortBlock: [:a :b | a lastUsed < b lastUsed]) asOrderedCollection.
	self cacheHysteresis timesRepeat:
		[toRemove := cached first.
		toRemove removeFromCache.
		cached removeFirst]! !

!WebLiveImage methodsFor: 'private-caching' stamp: ' 21/4/07 22:07'!
maxCacheSize
	^50! !

!WebLiveImage methodsFor: 'private-caching' stamp: ' 21/4/07 22:07'!
removeFromCache
	self class cache remove: self ifAbsent: [].
	self removeFromURLResolver.
	self gif: nil.! !

!WebLiveImage methodsFor: 'private-caching' stamp: ' 21/4/07 22:07'!
removeFromURLResolver
	self resolver notNil
		ifTrue: [self resolver removeObject: self]! !


!WebLiveImage methodsFor: 'private' stamp: 'jm 7/29/2010 12:16'!
aidaContentType
	"MIME type for our image"
	^'image/gif'! !

!WebLiveImage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
gif
	"returns a representation of a image in GIF format"
	^gif! !

!WebLiveImage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
gif: aByteArray

	"also set a refreshed timestamp"

	gif := aByteArray.
	self refreshed: Timestamp now.! !

!WebLiveImage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
isComposite
	^false! !

!WebLiveImage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
lastUsed
	"timestamp of last usage. Used for caching algorithms. Set at HTML generation"

	lastUsed isNil ifTrue: [self lastUsed: Timestamp now].
	^lastUsed! !

!WebLiveImage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
lastUsed: aTimestamp
	"timestamp of last usage. Used for caching algorithms"

	lastUsed := aTimestamp! !

!WebLiveImage methodsFor: 'private'!
preferredUrl
	| random |
	random := (AIDASite random next * 10000) truncated printString.
	^'/image/live-', random, '.gif'! !

!WebLiveImage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
refreshed
	"timestamp of last gif creation. Used for caching algorithms. Set,when calling gif: method"

	refreshed isNil ifTrue: [self refreshed: Timestamp now].
	^refreshed! !

!WebLiveImage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
refreshed: aTimestamp
	"timestamp of last gif creation. Used for caching algorithms"

	refreshed := aTimestamp! !

!WebLiveImage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
resolver
	^resolver! !

!WebLiveImage methodsFor: 'private' stamp: ' 21/4/07 22:07'!
resolver: anObject
	resolver := anObject! !


!WebLiveImage methodsFor: 'as yet unclassified' stamp: 'janko 4/25/2012 10:59'!
aidaIsRespondingStreamed
	"is this page able to stream HTML directly into response?"
	^false! !


!WebLiveImage methodsFor: 'private-streaming'!
aidaPresenterFor: aRequest on: aSession 
	^self! !

!WebLiveImage methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	"refresh gif if nesessary and put it into a HTML stream"
	Processor activeProcess priority: (Processor activeProcess priority - 3).
	self refreshNeeded ifTrue: 
		[self drawImage.
		self addToCache].
	aStream nextPutAll: self gif asByteString.
	Processor activeProcess priority: (Processor activeProcess priority + 3).
	self lastUsed: Timestamp now.

"	aSession server urlResolver removeObject: self "! !


!WebLiveImage methodsFor: 'drawing' stamp: ' 21/4/07 22:07'!
displayOn: aGraphicsContext

	"default painting - some hello message. Subclasses should override for some more paintings"

	| composite text |
	composite := CompositePart new.
	text := 'This is a live GIF image' asText.
	text emphasizeAllWith: (Array with: #bold with: #color -> ColorValue blue).
	text := text asComposedText.
	composite add: text at: 100 @ (height/2).
	composite displayOn: aGraphicsContext.! !

!WebLiveImage methodsFor: 'drawing' stamp: ' 21/4/07 22:07'!
drawImage
	"it paints a drawing with a painter and convert it to GIF"
	| pixmap graphicsContext image stream |
	pixmap := Pixmap extent: self width @ self height.
	graphicsContext := pixmap graphicsContext.
	self painter displayOn: graphicsContext.
	image := pixmap asImage.
	stream := GifImageStream on: ByteArray new writeStream.
	[stream nextPutImage: image. self gif: stream contents] 
		valueNowOrOnUnwindDo: [stream close].! !


!WebLiveImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
height
	"height of image, default is 300 pixels"
	height isNil ifTrue: [self height: 300].
	^height! !

!WebLiveImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
height: anInteger
	height := anInteger.! !

!WebLiveImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
painter
	"painter is an object, which actually paints an image. It must respond to message displayOn: anGraphicsContect. By default, painter is self and paints some hello message. Subclasses should override displayOn: appropriately"

	painter isNil ifTrue: [self painter: self].
	^painter! !

!WebLiveImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
painter: anObject
	painter := anObject.! !

!WebLiveImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
width
	"width of image, default is 500 pixels"
	width isNil ifTrue: [self width: 500].
	^width! !

!WebLiveImage methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
width: anInteger
	width := anInteger.! !


!WebLiveImage methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebElement
	^false! !

!WebLiveImage methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isWebPage
	^true! !

!WebLiveImage methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
refreshNeeded
	^self gif isNil! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebLiveImage class
	instanceVariableNames: ''!

!WebLiveImage class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
cache
	Cache isNil ifTrue: [self initCache].
	^Cache! !

!WebLiveImage class methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
initCache
	Cache := Set new.! !


WebLiveImage subclass: #WebGraph
	instanceVariableNames: 'data margin title graphics'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Imaging'!
!WebGraph commentStamp: '<historical>' prior: 0!
WebGraph for drawing graphs, on VisualWorks only, here just as an example for future porting.

For Smalltak wide use rather AidaCharts (JavaScript charting package) instead.!


!WebGraph methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
data
	data isNil ifTrue: [data := #(120 200 500 230 90 80 200 100 40)].
	^data! !

!WebGraph methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
data: anArray 
	data := anArray! !

!WebGraph methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
getMax
	| b max1 maxim maxAt |
	max1 := 0.
	b := self data size.
	1 to: b
		do: [:x | (data at: x) > max1 ifTrue: 
					[max1 := data at: x.
					maxAt := x]].
	maxim := max1.
	^Array with: maxim with: maxAt.! !

!WebGraph methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
graphics
	graphics isNil ifTrue: [self initGraphics].
	^graphics! !

!WebGraph methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
margin
	margin isNil ifTrue: [self margin: (self marginFor: (self getMax at: 1))].
	^margin! !

!WebGraph methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
margin: aNumber

	margin := aNumber.! !

!WebGraph methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
title 
	title isNil ifTrue: [title := 'Here comes the title'].
	^title! !

!WebGraph methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
title: aString
	title:= aString! !


!WebGraph methodsFor: 'drawing' stamp: ' 21/4/07 22:07'!
displayOn: aGraphicsContext
	| rectangle |
	self initGraphics.
	rectangle := Rectangle origin: 2 @ 2 extent: (self width - 4) @ (self height - 4).
	self graphics add: rectangle asStroker.
	self drawAxle.
	self drawYPoints.
	self graph.
	self drawTitle.
	self graphics displayOn: aGraphicsContext.! !

!WebGraph methodsFor: 'drawing' stamp: ' 21/4/07 22:07'!
drawAxle
	| points yAxis xAxis z c a grayLine blackLine b |
	z := self xLeftPosition.
	c := self yBottomPosition.
	b := self yTopPosition.
	a := self xRightPosition.
	points := List new: 2.
	points add: z @ (self yTopPosition - 10);
		add: z @ (c + 5).
	yAxis := Spline controlPoints: points.
	points := List new: 2.
	points add: (z - 5) @ c;
		add: a @ c.
	xAxis := Spline controlPoints: points.
	graphics add: yAxis asStroker;
		add: xAxis asStroker.
	b to: c - ((c - b) // 5)
		by: (c - b) // 5
		do: 
			[:x | 
			points := List new: 2.
			points add: (z + 1) @ x;
				add: a @ x.
			grayLine := Spline controlPoints: points.
			graphics add: ((GraphicsAttributesWrapper on: grayLine asStroker)
						attributes: (GraphicsAttributes new paint: ColorValue veryLightGray)).
			points := List new: 2.
			points add: (z - 5) @ x;
				add: z @ x.
			blackLine := Spline controlPoints: points.
			graphics add: blackLine asStroker]! !

!WebGraph methodsFor: 'drawing' stamp: ' 21/4/07 22:07'!
drawGraphWindow
	"WebGraph new drawGraphWindow"
	| win rectangle |
	win := ScheduledWindow new.
	win label: 'Graf obiskov na spletno stran'.
	win minimumSize: self width @ self height.
	graphics := CompositePart new.
	rectangle := Rectangle origin: 2 @ 2 extent: (self width - 4) @ (self height - 4).
	graphics add: rectangle asStroker.
	self drawAxle.
	self drawYPoints.
	self graph.
	self drawTitle.
	win component: (BoundedWrapper on: graphics).
	win open! !

!WebGraph methodsFor: 'drawing' stamp: ' 21/4/07 22:07'!
drawTitle
	| aTitle |
	aTitle:= (self title asComposedText compositionWidth: (self width-40)) centered.
	self graphics add: aTitle at: 20@10! !

!WebGraph methodsFor: 'drawing' stamp: ' 21/4/07 22:07'!
drawYPoints
	| string c stepOne step mark b |
	c := self yBottomPosition.
	b := self yTopPosition.
	stepOne := 0.
	step :=self stepFor:(self getMax at: 1).
	c to: b
		by: (0-((c - b) // 5))
		do: 
			[:x | 
			string := stepOne printString.
			mark := (string asText emphasizeAllWith: #small) asComposedText.
			mark compositionWidth: 30.
			mark rightFlush.
			graphics add: mark at: (self xLeftPosition - 40) @ ( x -13).
			stepOne := stepOne + step]! !

!WebGraph methodsFor: 'drawing' stamp: ' 21/4/07 22:07'!
graph
	"WebGraph new drawGraph"

	| aData aRectangle z c |
	z := self xLeftPosition + 1.
	c := self yBottomPosition.
	1 to: self data size
		do: 
			[:x | 
			aData := data at: x.
			aRectangle := Rectangle left: z
						right: z + self distance - 2
						top: c - (self heightInPixelsFor: aData)
						bottom: c.
			z := z + self distance.
			graphics add: ((GraphicsAttributesWrapper on: aRectangle asFiller)
						attributes: (GraphicsAttributes new paint: ColorValue blue))]! !


!WebGraph methodsFor: 'constants' stamp: ' 21/4/07 22:07'!
distance
	^(self xRightPosition - self xLeftPosition) // self data size! !

!WebGraph methodsFor: 'constants' stamp: ' 21/4/07 22:07'!
height	
	^300! !

!WebGraph methodsFor: 'constants' stamp: ' 21/4/07 22:07'!
width
	^500! !

!WebGraph methodsFor: 'constants' stamp: ' 21/4/07 22:07'!
xLeftPosition
	^50! !

!WebGraph methodsFor: 'constants' stamp: ' 21/4/07 22:07'!
xRightPosition
	^self width - 20! !

!WebGraph methodsFor: 'constants' stamp: ' 21/4/07 22:07'!
yBottomPosition
	^self height - 30! !

!WebGraph methodsFor: 'constants' stamp: ' 21/4/07 22:07'!
yTopPosition
	^40! !


!WebGraph methodsFor: 'transformations' stamp: ' 21/4/07 22:07'!
heightInPixelsFor:  aNumber

	^(((self yBottomPosition - self yTopPosition) / self margin) * aNumber) truncated

"
|graf|
graf := WebGraf new.
graf data: #(10 20 30 40 50).
graf heightInPixelsFor: 15.
"! !

!WebGraph methodsFor: 'transformations' stamp: ' 21/4/07 22:07'!
marginFor:  aNumber

	| margin |
	aNumber < 10 ifTrue: [^10].
	margin := 10 ** ((aNumber log: 10) truncated + 1).
	margin = (aNumber * 10) ifTrue: [^margin / 10].
	aNumber > (margin / 2) ifTrue: [^margin].
	aNumber > (margin / 4) ifTrue: [^margin / 2].
	^margin / 4.

"WebGraf new marginFor: 1001"! !

!WebGraph methodsFor: 'transformations' stamp: ' 21/4/07 22:07'!
stepFor:  aNumber

	^(self marginFor: aNumber) / 5

"WebGraf new stepFor: 1001"! !


!WebGraph methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initGraphics
	graphics := CompositePart new! !


WebMethodResource subclass: #WebMethodImage
	instanceVariableNames: 'lastUsed'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Imaging'!
!WebMethodImage commentStamp: '<historical>' prior: 0!
This image is actually in-lined in a method, which is called on defined object and must return a ByteArray of image contents. 

Instance Variables:
	contentType	<String>	 content type of an image eg. 'image/gif', which is default.
	method	<Symbol>	symbol of a method to be called on object
	object	<Object>	object on which a method will be called

!


!WebMethodImage methodsFor: 'private-sprites'!
addToSprite
	"is this method image part of sprite? If #addToSprite in method image called then yes. Add it to sprite if 
	doesn't exist yet."
	self site style class sprite 
		appendImageNamed: self method! !

!WebMethodImage methodsFor: 'private-sprites'!
checkForSprite
	"is this method image part of sprite? If #addToSprite in method image called then yes. Add it to sprite if 
	doesn't exist yet."
	[self object perform: self method]
		on: WebSpriteException   "called from #addToSprite in method image, if exists"
		do: [:ex | 
			self isFromSprite ifFalse: [self addToSprite].
			^self].
	self isFromSprite ifTrue:  "no more #addToSprite call from method image"
		[^self "remove from sprite, not yet implemented"]! !

!WebMethodImage methodsFor: 'private-sprites'!
isFromSprite
	"Exist this image in default CSS sprite for site's style class?"
	^self site style class sprite 
		existsImageNamed: self method! !


!WebMethodImage methodsFor: 'accessing'!
aidaContentType
	contentType 
		ifNil: [self guessContentType]. "from a method name which should be in format like #rssGif "
	^contentType! !

!WebMethodImage methodsFor: 'accessing' stamp: 'jmivsek 5/24/2020 17:40'!
guessContentType
	"from a method name which should be in format like #rssGif "
	| ext |
	self method size < 3 ifTrue: [^self aidaContentType: 'image/gif'].
	ext := self method copyFrom: self method size-2 to: self method size.
	ext = 'Png' ifTrue: [^self aidaContentType: 'image/png'].
	ext = 'Gif' ifTrue: [^self aidaContentType: 'image/gif'].
	(ext = 'Jpg') | (ext = 'jpeg') ifTrue: [^self aidaContentType: 'image/jpeg'].
	self aidaContentType: 'image/gif' "default one"! !

!WebMethodImage methodsFor: 'accessing'!
preferredUrl
	| ext |
	ext := self site mimeMap extensionForType: self aidaContentType.
	ext isNil ifTrue: [ext := ''].
	^'/img/' , self method asString asLowercase , '.', ext! !

!WebMethodImage methodsFor: 'accessing'!
resolver
	^self site urlResolver! !


!WebMethodImage methodsFor: 'private'!
printString
	^'aWebMethodImage #', self method asString, ' on ', self object class name! !


!WebMethodImage methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	^super streamHtmlTo: aStream for: aRequest on: aSession

	"redirect to a CSS sprite if method image is part of it"
"	^self isFromSprite
		ifFalse: [super streamHtmlTo: aStream for: aRequest on: aSession]
		ifTrue: [self site style class sprite streamHtmlTo: aStream for: aRequest on: aSession]
"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebMethodImage class
	instanceVariableNames: 'cache'!

!WebMethodImage class methodsFor: 'instance creation'!
fromMethod: aSymbol on: anObject site: anAIDASite
	^super 
		fromMethod: aSymbol 
		on: anObject 
		contentType: nil "to lazily auto set it from a method name" 
		site: anAIDASite! !


Object subclass: #WebSprite
	instanceVariableNames: 'styleClass entries content'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Imaging'!
!WebSprite commentStamp: '<historical>' prior: 0!
WebSprite contains a CSS sprite (a composed image) of all method images which contains 'self addToSprite' call at start of the method. Each WebStyle class has its own sprite. Per style class therefore, not per site are sprites, to spare memory.

Prerequisite: ImageMagick installed!! http://www.imagemagick.org


Instance Variables
	content	<ByteArray> binary content of a whole sprite image
	entries	<OrderedCollection of WebSpriteEntry> images, their sizes and positions in the sprite!


!WebSprite methodsFor: 'adding-removing'!
addImageNamed: aMethodImageSymbol size: aSizePoint position: aPosPoint
	"to the entries"
	(self existsImageNamed: aMethodImageSymbol) 
		ifTrue: [self error: 'image with that name already exist'].
	^self entries add:
		(WebSpriteEntry newForImageNamed: aMethodImageSymbol size: aSizePoint position: aPosPoint)

"AidaWebStyle sprite addImageNamed: #downloadPng size: 179@39 position: 0@0 "! !

!WebSprite methodsFor: 'adding-removing'!
appendImageNamed: aMethodImageSymbol	
	"add this method image to current sprite (to both content and entries) "
	| ext imgFname spriteFname |
	(self existsImageNamed: aMethodImageSymbol) ifTrue: [self error: 'this image already in sprite'].
	self checkExecutable. "ImageMagick installed?"
	ext := aMethodImageSymbol copyFrom: aMethodImageSymbol size-2 to: aMethodImageSymbol size.
	imgFname := self tempDir, self separator, 'tempImg', self random, '.', ext asLowercase.
	spriteFname := self tempDir, self separator, 'tempSprite', self random, '.png'.
	self exportTo: spriteFname.
	self exportImageNamed:  aMethodImageSymbol to: imgFname.
	self appendImageFile: imgFname toSpriteFile: spriteFname.	
	self importFrom: spriteFname.
	self 
		addImageNamed: aMethodImageSymbol
		size: (self imageWidthOf: imgFname) @ (self imageHeightOf: imgFname)
		position: self newImagePosition.
	(SpFilename named: imgFname) delete.
	(SpFilename named: spriteFname) delete.! !

!WebSprite methodsFor: 'adding-removing'!
exportTo: aFilenameString
	| fname stream |
	fname := SpFilename named: aFilenameString.
	[stream := fname writeStream binary.
	stream nextPutAll: self content]
		ensure: [stream close]

"AidaWebStyle sprite exportTo: 'tempSprite.png' "! !

!WebSprite methodsFor: 'adding-removing'!
importFrom: aFilenameString
	| fname stream |
	fname := SpFilename named: aFilenameString.
	[stream := fname readStream binary.
	self content: stream upToEnd]
		ensure: [stream close]

"AidaWebStyle sprite importFrom: 'tempSprite.png' "! !

!WebSprite methodsFor: 'adding-removing'!
newImagePosition
	"On which coordinate a new image will be put in sprite"
	self entries isEmpty ifTrue: [^0@0]. 
	^0 @ (self entries last position y + self entries last size y)! !


!WebSprite methodsFor: 'private'!
aidaContentType
	"Sprite is always PNG"	
	^'image/png'! !

!WebSprite methodsFor: 'private'!
aidaIsRespondingNeverStreamed
	^false! !

!WebSprite methodsFor: 'private'!
aidaIsRespondingStreamed
	"always stream method resources"
	^true! !

!WebSprite methodsFor: 'private'!
content: aByteArray
	"a content of this sprite - binary representation of sprite image"
	content := aByteArray

"AidaWebStyle sprite content: AidaWebStyle new downloadPng "! !

!WebSprite methodsFor: 'private'!
entries
	entries ifNil: [self initEntries].
	^entries! !

!WebSprite methodsFor: 'private'!
styleClass: aWebStyleClass
	styleClass := aWebStyleClass! !

!WebSprite methodsFor: 'private'!
tempDir
	"Use one from default site because it is not known to which site this sprite belongs, because 
       it belongs to a style class"
	^AIDASite default tempDirectory! !


!WebSprite methodsFor: 'private-streaming'!
aidaPresenterFor: aRequest on: aSession 
	^self! !

!WebSprite methodsFor: 'private-streaming'!
streamHtmlTo: aStream for: aRequest on: aSession
	| response |
	response := aRequest streamedResponse.
	[aRequest session site addResponseHeadersTo: response forPage: self on: aSession.
	response length: self content size.
	response nextPutAll: self content. 
	response close]
		on: Error
		do: [:ex | "ignore "]! !


!WebSprite methodsFor: 'private-imaging'!
appendImageFile: anImageFnameString toSpriteFile: aSpriteFnameString
	| result |
	(SpFilename named: anImageFnameString) exists ifFalse: [self error: 'image file does not exist'].
	(SpFilename named: aSpriteFnameString) exists ifFalse: [self error: 'image file does not exist'].
	result := self exec:
		(self content isEmpty
			ifTrue: ['convert ', anImageFnameString, ' -append ', aSpriteFnameString]
			ifFalse:  ['convert ', aSpriteFnameString, ' ', anImageFnameString, ' -append ', aSpriteFnameString]).
	result isEmpty ifFalse: [self error: result]

"AidaWebStyle sprite appendImageFile: 'tempDL.png' toSpriteFile: 'tempSprite.png' "! !

!WebSprite methodsFor: 'private-imaging'!
checkExecutable
	"Is ImageMagick correctly installed and working?"
	"WebSprite new checkExecutable"
	| result |
	result := self exec: 'convert -version'.
	('Version: ImageMagick*' match: result)
		ifFalse: [^self error: 'ImageMagick not executable, is it correctly installed?']
		ifTrue: [^true].! !

!WebSprite methodsFor: 'private-imaging'!
exec: aCommandString
	"execute the command and return result"
	"VW specific"
	SpEnvironment onUnix ifTrue: [^UnixProcess cshOne: aCommandString].
	SpEnvironment onWindows ifTrue: [^WinProcess cshOne: aCommandString].! !

!WebSprite methodsFor: 'private-imaging'!
exportImageNamed: aMethodImageSymbol to: aFilenameString
	| fname stream |
	fname := SpFilename named: aFilenameString.
	[stream := fname writeStream binary.
	stream nextPutAll: (self styleClass new perform: aMethodImageSymbol)]
		ensure: [stream close]

"AidaWebStyle sprite exportImageNamed: #downloadPng to: 'tempDl.png' "! !

!WebSprite methodsFor: 'private-imaging'!
imageHeightOf: aFilenameString
	(SpFilename named: aFilenameString) exists ifFalse: [self error: 'image file does not exist'].
	^(self exec: 'identify  -format "%[fx:h]" ', aFilenameString)
		asInteger

"AidaWebStyle sprite imageHeightOf: 'tempDL.png' "! !

!WebSprite methodsFor: 'private-imaging'!
imageWidthOf: aFilenameString
	(SpFilename named: aFilenameString) exists ifFalse: [self error: 'image file does not exist'].
	^(self exec: 'identify  -format "%[fx:w]" ', aFilenameString)
		asInteger

"AidaWebStyle sprite imageWidthOf: 'tempDL.png' "! !

!WebSprite methodsFor: 'private-imaging'!
random
	"a random number string for temporary files"
	^(Random new  next * 1000000) truncated printString.! !

!WebSprite methodsFor: 'private-imaging'!
separator
	" '/' or '\' "
	^SpEnvironment onWindows ifTrue: ['\'] ifFalse: ['/'].! !


!WebSprite methodsFor: 'accessing'!
content
	"a content of this sprite - binary representation of sprite image"
	content ifNil: [^ByteArray new].
	^content! !

!WebSprite methodsFor: 'accessing'!
imageNamed: aMethodImageSymbol
	^self entries 
		detect: [:entry | entry imgName = aMethodImageSymbol]
		ifNone: [nil]! !

!WebSprite methodsFor: 'accessing'!
styleClass
	"Style class for which is that CSS sprite"
	^styleClass! !

!WebSprite methodsFor: 'accessing'!
url
	^'/sprite.png'! !


!WebSprite methodsFor: 'testing'!
existsImageNamed: aMethodImageSymbol
	"This image already part of sprite?"
	^(self imageNamed: aMethodImageSymbol) 
		notNil! !


!WebSprite methodsFor: 'initialize-release'!
initEntries
	entries := OrderedCollection new.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebSprite class
	instanceVariableNames: ''!

!WebSprite class methodsFor: 'accessing'!
default
	"CSS sprite for style of default site"
	"WebSprite default"
	^AIDASite default style class sprite! !


!WebSprite class methodsFor: 'instance creation'!
newFor: aWebStyleClass
	^super new
		styleClass: aWebStyleClass! !


Object subclass: #WebSpriteEntry
	instanceVariableNames: 'imgName size position'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Imaging'!
!WebSpriteEntry commentStamp: '<historical>' prior: 0!
WebSpriteEntry describes individual images from which a CSS sprite is composed!


!WebSpriteEntry methodsFor: 'accessing'!
imgName
	"actually a method name of  method image"
	^imgName! !

!WebSpriteEntry methodsFor: 'accessing'!
imgName: aMethodNameSymbol
	imgName := aMethodNameSymbol! !

!WebSpriteEntry methodsFor: 'accessing'!
position
	"position of this image in CSS sprite"
	^position! !

!WebSpriteEntry methodsFor: 'accessing'!
position: aPoint
	position := aPoint! !

!WebSpriteEntry methodsFor: 'accessing'!
size
	"image size in pixels"
	^size! !

!WebSpriteEntry methodsFor: 'accessing'!
size: aPoint
	size := aPoint! !


!WebSpriteEntry methodsFor: 'printing'!
printString
	^'aWebSpriteEntry
	imgName: ', self imgName printString, '
	size: ', self size printString, '
	position: ', self position printString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WebSpriteEntry class
	instanceVariableNames: ''!

!WebSpriteEntry class methodsFor: 'instance creation'!
newForImageNamed: aMethodImageSymbol size: aSizePoint position: aPosPoint
	^self new
		imgName: aMethodImageSymbol;
		size: aSizePoint;
		position: aPosPoint! !


Exception subclass: #WebSpriteException
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Imaging'!
!WebSpriteException commentStamp: '<historical>' prior: 0!
WebSpriteException to signal via an exception from #addToSprite call in method images, that this method image is part of CSS sprite
!


ImageStream initialize!
GifImageStream initialize!