Object subclass: #HTTPHeaders
	instanceVariableNames: 'fields'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPHeaders methodsFor: 'services' stamp: ' 14/4/07 23:10'!
addField: aField 
	"HTTPSpec1.1 Sec4.2
Multiple message-header fields with the same field-name MAY be present in a message if and only if the entire field-value for that header field is defined as a comma-separated list [i.e., #(values)]. It MUST be possible to combine the multiple header fields into one 'field-name: field-value' pair, without changing the semantics of the message, by appending each subsequent field-value to the first, each separated by a comma. The order in which header fields with the same field-name are received is therefore significant to the interpretation of the combined field value, and thus a proxy MUST NOT change the order of these field values when a message is forwarded.
Note that we have to use the field name here as we may be adding a field for which there is no class, i.e. it's a GenericHeaderField."

	(self includesFieldNamed: aField name) 
		ifTrue: [(self fieldNamed: aField name) combineWith: aField]
		ifFalse: [self fields at: aField name asUppercase put: aField].
	^self! !

!HTTPHeaders methodsFor: 'services' stamp: ' 14/4/07 23:10'!
fieldNamed: aString 
	"^aString
If I contain a field named aString, I return it.  Otherwise an exception is thrown.
This is a bad way of getting a field.  Use >> fieldOfClass: instead."

	| targetString |
	targetString := aString asUppercase.
	^self fields detect: [:aField | aField name asUppercase = targetString]! !

!HTTPHeaders methodsFor: 'services' stamp: ' 14/4/07 23:10'!
fieldNamed: aString ifNone: aBlock 
	"^aString
If I contain a field named aString, I return it.  Otherwise I evaluate aBlock."

	^self fields at: aString asUppercase ifAbsent: aBlock! !

!HTTPHeaders methodsFor: 'services' stamp: ' 14/4/07 23:10'!
fieldNamed: aFieldName ifPresent: presentBlock ifAbsent: absentBlock 
	"^an Object
I look for a field named aFieldName among my fields.  If I find it, I return the result of evaluating presentBlock with the found field as an argument, otherwise I return the result of evaluate the absentBlock"

	| foundField |
	foundField := self fieldNamed: aFieldName ifNone: [nil].
	^foundField isNil 
		ifTrue: [absentBlock value]
		ifFalse: [presentBlock value: foundField]! !

!HTTPHeaders methodsFor: 'services' stamp: ' 14/4/07 23:10'!
fieldOfClass: aClass 
	"^aString
If I contain a field of class aClass, I return it.   Otherwise an exception is thrown."

	^self fields detect: [:aField | aField class == aClass] ifNone: [^nil]! !

!HTTPHeaders methodsFor: 'services' stamp: ' 14/4/07 23:10'!
fieldOfClass: aClass ifNone: aBlock 
	"^aString
If I contain a field of class aClass, I return it.   Otherwise I evaluate aBlock."

	^self fields detect: [:aField | aField class == aClass] ifNone: aBlock! !

!HTTPHeaders methodsFor: 'services' stamp: ' 14/4/07 23:10'!
fieldOfClass: fieldClass ifPresent: presentBlock ifAbsent: absentBlock 
	"^an Object
I look for a field of class fieldClass among my fields.  If I find it, I return the result of evaluating presentBlock with the found field as an argument, otherwise I return the result of evaluate the absentBlock"

	| foundField |
	foundField := self fieldOfClass: fieldClass ifNone: [nil].
	^foundField isNil 
		ifTrue: [absentBlock value]
		ifFalse: [presentBlock value: foundField]! !

!HTTPHeaders methodsFor: 'services' stamp: ' 14/4/07 23:10'!
getOrMakeFieldOfClass: aClass 
	"^a HeaderField
If I contain a field of class aClass, I return it.   Otherwise I create a new instance if the field class and add it to my collection of headers."

	^self fieldOfClass: aClass
		ifNone: 
			[| newField |
			newField := aClass new.
			self addField: newField.
			newField]! !


!HTTPHeaders methodsFor: 'emitting' stamp: ' 14/4/07 23:10'!
crlfOn: aStream 
	aStream
		nextPut: Character cr;
		nextPut: Character lf! !

!HTTPHeaders methodsFor: 'emitting' stamp: ' 14/4/07 23:10'!
writeOn: aStream 
	"^self
I write all my fields to aStream."

	self fields do: 
			[:aField | 
			aField printOn: aStream.
			self crlfOn: aStream]! !


!HTTPHeaders methodsFor: 'private' stamp: ' 14/4/07 23:10'!
fields
	fields isNil ifTrue: [fields := Dictionary new].
	^fields! !

!HTTPHeaders methodsFor: 'private' stamp: 'mivsek 12/31/2007 14:01'!
printOn: aStream
	aStream nextPutAll: 'a HTTPHeaders'; cr.
	self fields values do: [:each | aStream nextPutAll: '   ', each printString; cr]! !


!HTTPHeaders methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
includesFieldNamed: aString 
	"^a Boolean
I return true if one of my fields has the name aString."

	| targetField |
	targetField := self fieldNamed: aString ifNone: [nil].
	^targetField notNil! !

!HTTPHeaders methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
includesFieldOfClass: aClass 
	"^a Boolean
I return true if one of my fields is of class aClass."

	^self 
		fieldOfClass: aClass
		ifPresent: [:aField | true]
		ifAbsent: [false]! !


!HTTPHeaders methodsFor: 'initialize-release' stamp: ' 14/4/07 23:10'!
readFieldFromString: aString 
	"^self
First I get the field parsed from aString, then I add the new field to my collection of fields.  Adding the new field may involve merging field values if I already have a field of that class."

	self addField: (HeaderField fromLine: aString).
	^self! !

!HTTPHeaders methodsFor: 'initialize-release' stamp: ' 10/7/07 17:21'!
readFrom: aSwazooStream 
	"^an HTTPHeaders
I return a new instance of myself which contains fields parsed from aStream.  Everything upto the next blank line is a header field."
	
	| nextLine |
	[nextLine := aSwazooStream nextUnfoldedLine.
	nextLine isEmpty]
		whileFalse: [self readFieldFromString: nextLine].
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPHeaders class
	instanceVariableNames: ''!

!HTTPHeaders class methodsFor: 'instance creation' stamp: ' 10/7/07 17:21'!
readFrom: aSwazooStream 
	"^an HTTPHeaders
I return a new instance of myself which contains fields parsed from aStream."

	^self new readFrom: aSwazooStream! !


Object subclass: #HeaderField
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HeaderField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
combineWith: aHeaderField 
	SwazooHeaderFieldParseError raiseSignal: 'Not supported'! !


!HeaderField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^self subclassResponsibility! !

!HeaderField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
name
	^self subclassResponsibility! !

!HeaderField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
values
	^self subclassResponsibility! !


!HeaderField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isConditional
	^false! !

!HeaderField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isContentDisposition
	^false! !

!HeaderField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isContentType
	^false! !


!HeaderField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
printOn: aStream 
	aStream
		nextPutAll: self name;
		nextPutAll: ': '.
	self valuesAsStringOn: aStream.
	^self! !

!HeaderField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsString
	| targetStream |
	targetStream := WriteStream on: String new.
	self valuesAsStringOn: targetStream.
	^targetStream contents! !

!HeaderField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream
	^self subclassResponsibility! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HeaderField class
	instanceVariableNames: 'httpFieldNameToClassDictionary'!

!HeaderField class methodsFor: 'private' stamp: ' 14/4/07 23:10'!
classForFieldName: aString 
	"^a Class
If I can find a specific header field with a name matching aString I return that.  Otherwise I return the GenericHeaderField class."

	^self httpFieldNameToClassDictionary at: aString
		ifAbsent: [GenericHeaderField]! !

!HeaderField class methodsFor: 'private' stamp: ' 14/4/07 23:10'!
httpFieldNameToClassDictionary
	"^a Class
I return the dictionarry of my subclasses keyed on the name of the field they represent.
Note that we only need *Request* headers listed in here because they are the only thing we will be parsing for."

	"After a change here, remeber to do 'HeaderField resetHttpFieldNameToClassDictionary' "

	httpFieldNameToClassDictionary isNil 
		ifTrue: 
			[| headerClasses |
			headerClasses := OrderedCollection new.
			headerClasses
				add: ContentDispositionField;
				add: HTTPContentLengthField;
				add: ContentTypeField;
				add: HTTPAcceptField;
				add: HTTPAuthorizationField;
				add: HTTPConnectionField;
				add: HTTPHostField;
				add: HTTPIfMatchField;
				add: HTTPIfModifiedSinceField;
				add: HTTPIfNoneMatchField;
				add: HTTPIfRangeField;
				add: HTTPIfUnmodifiedSinceField;
				add: HTTPRefererField;
				add: HTTPUserAgentField.
			httpFieldNameToClassDictionary := Dictionary new.
			headerClasses do: 
					[:aClass | 
					httpFieldNameToClassDictionary at: aClass fieldName asUppercase put: aClass]].
	^httpFieldNameToClassDictionary! !

!HeaderField class methodsFor: 'private' stamp: ' 14/4/07 23:10'!
newForFieldName: fieldNameString withValueFrom: fieldValueString 
	^self subclassResponsibility! !

!HeaderField class methodsFor: 'private' stamp: ' 14/4/07 23:10'!
resetHttpFieldNameToClassDictionary
	
	httpFieldNameToClassDictionary := nil .
	^self! !


!HeaderField class methodsFor: 'instance creation' stamp: ' 14/4/07 23:10'!
fromLine: aString 
	| sourceStream fieldName fieldValue fieldClass |
	sourceStream := ReadStream on: aString.
	fieldName := (HTTPString trimBlanksFrom: (sourceStream upTo: $:)) 
				asUppercase.
	fieldClass := self classForFieldName: fieldName.
	fieldValue := HTTPString trimBlanksFrom: sourceStream upToEnd.
	^fieldClass newForFieldName: fieldName withValueFrom: fieldValue! !


HeaderField subclass: #GenericHeaderField
	instanceVariableNames: 'name value'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!GenericHeaderField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
combineWith: aHeaderField 
	"^self
I simply take my values and concatenate the values of aHeaderField."

	value := self value , ', ' , aHeaderField value.
	^self! !


!GenericHeaderField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
1 halt: 'use >>name instead'.
	^self name! !

!GenericHeaderField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
name
	^name! !

!GenericHeaderField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
value
	^value! !

!GenericHeaderField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
values
	^(HTTPString subCollectionsFrom: self value delimitedBy: $,) 
		collect: [:each | HTTPString trimBlanksFrom: each]! !


!GenericHeaderField methodsFor: 'initialize-release' stamp: ' 14/4/07 23:10'!
forFieldName: fieldNameString andValue: fieldValueString 
	name := fieldNameString.
	value := fieldValueString.
	^self! !


!GenericHeaderField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream nextPutAll: value.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GenericHeaderField class
	instanceVariableNames: ''!

!GenericHeaderField class methodsFor: 'instance creation' stamp: ' 14/4/07 23:10'!
newForFieldName: fieldNameString withValueFrom: fieldValueString 
	^self new forFieldName: fieldNameString andValue: fieldValueString! !


HeaderField subclass: #SpecificHeaderField
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!SpecificHeaderField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
name
	^self class fieldName! !

!SpecificHeaderField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
parameterAt: aString ifAbsent: aBlock 
1 halt: 'use the transfer encodings of the field, not this'.
	^self parameters at: aString ifAbsent: aBlock! !

!SpecificHeaderField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
values
	^Array with: self value! !


!SpecificHeaderField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString
	^self subclassResponsibility! !

!SpecificHeaderField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
readParametersFrom: sourceStream 
	"^a Dictionary
c.f. RFC 2616 3.6 Transfer Codings"

	| parameters |
	parameters := Dictionary new.
	[sourceStream atEnd] whileFalse: 
			[| attribute value |
			attribute := HTTPString trimBlanksFrom: (sourceStream upTo: $=).
			value := HTTPString trimBlanksFrom: (sourceStream upTo: $;).
			parameters at: attribute put: value].
	^parameters! !


!SpecificHeaderField methodsFor: 'initialize-release' stamp: ' 14/4/07 23:10'!
valueFrom: fieldValueString 
	self parseValueFrom: fieldValueString.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpecificHeaderField class
	instanceVariableNames: ''!

!SpecificHeaderField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^self subclassResponsibility! !


!SpecificHeaderField class methodsFor: 'private' stamp: ' 14/4/07 23:10'!
newForFieldName: fieldNameString withValueFrom: fieldValueString 
	^self newWithValueFrom: fieldValueString! !

!SpecificHeaderField class methodsFor: 'private' stamp: ' 14/4/07 23:10'!
newWithValueFrom: fieldValueString 
	^self new valueFrom: fieldValueString! !


SpecificHeaderField subclass: #ContentDispositionField
	instanceVariableNames: 'type parameters'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!ContentDispositionField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isContentDisposition
	^true! !


!ContentDispositionField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
parameterAt: aString 
	^parameters at: aString ifAbsent: [nil]! !


!ContentDispositionField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString 
	| sourceStream |
	sourceStream := aString readStream.
	type := HTTPString trimBlanksFrom: (sourceStream upTo: $;).
	parameters := self readParametersFrom: sourceStream.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ContentDispositionField class
	instanceVariableNames: ''!

!ContentDispositionField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Content-Disposition'! !


SpecificHeaderField subclass: #ContentTypeField
	instanceVariableNames: 'mediaType transferCodings'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!ContentTypeField methodsFor: 'accessing'!
charset: aString
	"add a specified character set to the content type field"
	self transferCodings
		at: 'charset' 
		put: aString! !

!ContentTypeField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
defaultMediaType
	"^a String
See RFC 2616 '7.2.1 Type'.  If no media type is specified, application/octet-stream is the default."

	^'application/octet-stream'! !

!ContentTypeField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
mediaType
	^mediaType isNil ifTrue: [self defaultMediaType] ifFalse: [mediaType]! !

!ContentTypeField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
mediaType: aString 
	mediaType := aString.
	^self! !

!ContentTypeField methodsFor: 'accessing'!
transferCodings
	transferCodings isNil ifTrue: [transferCodings := Dictionary new].
	^transferCodings! !


!ContentTypeField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isContentType
	^true! !


!ContentTypeField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString 
	| sourceStream |
	sourceStream := aString readStream.
	mediaType := (HTTPString trimBlanksFrom: (sourceStream upTo: $;)).
	transferCodings := self readParametersFrom: sourceStream.
	^self! !


!ContentTypeField methodsFor: 'printing'!
valuesAsStringOn: aStream 
	aStream nextPutAll: self mediaType.
	self transferCodings isEmpty ifFalse: 
		[self transferCodings keysAndValuesDo: 
			[:name :value | 
			aStream
				nextPutAll: '; ';
				nextPutAll: name;
				nextPut: $=;
				nextPutAll: value]].
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ContentTypeField class
	instanceVariableNames: ''!

!ContentTypeField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Content-Type'! !


SpecificHeaderField subclass: #HTTPAcceptField
	instanceVariableNames: 'mediaTypes'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPAcceptField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
combineWith: aHeaderField 
	"^self
I simply take my values and concatenate the values of aHeaderField."

	self mediaTypes addAll: aHeaderField mediaTypes.
	^self! !


!HTTPAcceptField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
mediaTypes
	mediaTypes isNil ifTrue: [mediaTypes := OrderedCollection new].
	^mediaTypes! !


!HTTPAcceptField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString 
	mediaTypes := HTTPString subCollectionsFrom: aString delimitedBy: $,.
	^self! !


!HTTPAcceptField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: targetStream 
	self mediaTypes isEmpty 
		ifFalse: 
			[targetStream nextPutAll: self mediaTypes first.
			2 to: self mediaTypes size
				do: 
					[:methodIndex | 
					targetStream
						nextPut: $,;
						nextPutAll: (self mediaTypes at: methodIndex)]].
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPAcceptField class
	instanceVariableNames: ''!

!HTTPAcceptField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Accept'! !


SpecificHeaderField subclass: #HTTPAllowField
	instanceVariableNames: 'methods'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPAllowField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
methods
	methods isNil ifTrue: [methods := OrderedCollection new].
	^methods! !


!HTTPAllowField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: targetStream 
	self methods isEmpty 
		ifFalse: 
			[targetStream nextPutAll: self methods first.
			2 to: self methods size
				do: 
					[:methodIndex | 
					targetStream
						nextPut: $,;
						nextPutAll: (self methods at: methodIndex)]].
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPAllowField class
	instanceVariableNames: ''!

!HTTPAllowField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Allow'! !


SpecificHeaderField subclass: #HTTPAuthorizationField
	instanceVariableNames: 'credentials'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPAuthorizationField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
credentials
	^credentials! !


!HTTPAuthorizationField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString 
	credentials := HTTPString trimBlanksFrom: aString.
	^self! !


!HTTPAuthorizationField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream nextPutAll: self credentials.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPAuthorizationField class
	instanceVariableNames: ''!

!HTTPAuthorizationField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Authorization'! !


!HTTPAuthorizationField class methodsFor: 'private' stamp: ' 14/4/07 23:10'!
newForFieldName: fieldNameString withValueFrom: fieldValueString 
	"^an HTTPAuthorizationField
I return an instance of one of my concrete subclasses.  To get to this point, the field name *must* be 'AUTHORIZATION'."

	| sourceStream schemeName |
	sourceStream := ReadStream on: fieldValueString.
	schemeName := sourceStream upTo: Character space.
	^schemeName = 'Basic' 
		ifTrue: [HTTPAuthorizationBasicField newWithValueFrom: sourceStream upToEnd]
		ifFalse: [HTTPAuthorizationDigestField newWithValueFrom: sourceStream upToEnd]! !


HTTPAuthorizationField subclass: #HTTPAuthorizationBasicField
	instanceVariableNames: 'userid password'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPAuthorizationBasicField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
password
	"^a String
I return the password string (as defined in RFC 2617 pp.2) part of the user-pass value in my credentials."

	password isNil ifTrue: [self resolveUserPass].
	^password! !

!HTTPAuthorizationBasicField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
userid
	"^a String
I return the userid string (as defined in RFC 2617 pp.2) part of the user-pass value in my credentials."

	userid isNil ifTrue: [self resolveUserPass].
	^userid! !


!HTTPAuthorizationBasicField methodsFor: 'private' stamp: 'np 3/24/2008 02:36'!
resolveUserPass
	"^self
I look at my credentials string and pull out the userid and password.  Note that having to check for atEnd before the upToEnd is for GemStone which crashes if upToEnd is used when already atEnd."

	"(Base64EncodingReadStream on: 'YnJ1Y2U6c3F1aWRzdXBwbGllZHBhc3N3b3Jk' ) upToEnd asString "

	| userPassString sourceStream |
	userPassString := userPassString := Base64MimeConverter mimeDecode: self credentials as: String.
	sourceStream := ReadStream on: userPassString.
	userid := sourceStream upTo: $:.
	password := sourceStream atEnd 
				ifTrue: [String new]
				ifFalse: [sourceStream upToEnd].
	^self! !


!HTTPAuthorizationBasicField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream nextPutAll: 'Basic '.
	super valuesAsStringOn: aStream.
	^self! !


HTTPAuthorizationField subclass: #HTTPAuthorizationDigestField
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPAuthorizationDigestField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream nextPutAll: 'Digest '.
	super valuesAsStringOn: aStream.
	^self! !


SpecificHeaderField subclass: #HTTPCacheControlField
	instanceVariableNames: 'directives private maxAge noStore noCache mustRevalidate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPCacheControlField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
directives
	"for easy setting directives in one string"
	^directives! !

!HTTPCacheControlField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
directives: aString 
	"for easy setting directives in one string"
	"example: 'no-store, no-cache, must-revalidate'"
	directives := aString! !

!HTTPCacheControlField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
maxAge
	"^an Integer or nil
I return my max age which is either an integer number of seconds for which the entity can be considdered fresh, or nil, in which case other headers such as Expires can be used by a cache to determine the expiration time of the entity."

	^maxAge! !

!HTTPCacheControlField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
private
	"^a Boolean or nil
There are three possible values for private.  Explicity true (the entity can only be cached in private caches), explicity false (this is a public entity and can be held in a shared/public cache perhaps even when stale) or nil (the default which means that the entity may be held in a public shared cache, but only until it goes stale)."

	^private! !


!HTTPCacheControlField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
maxAge: anIntegerOrNil 
	"^self
I record the number of seconds for which the resource is 'fresh' and after which will expire and become 'stale' for caching purposes.  Setting this to nil means the max age is unspecified, and this is the default.  This directive takes presidence over any Expires header when a cache or client is handling an HTTP message."

	maxAge := anIntegerOrNil.
	^self! !

!HTTPCacheControlField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
setNotPublicOrPrivate
	"^self
I am being told that the entity in my message is not explicity public or private.  This is the default and means that public caches may retain copies of the resource, but should not be as relaxed about the rules as with an explicitly public resource. c.f >>setPublic & >>setPrivate."

	private := nil.
	^self! !

!HTTPCacheControlField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
setPrivate
	"^self
I am being told that the entity in my message is a private one that can only be cached on private caches, i.e. caches that can be drawn upon a single clients.  An example of a private cache is the one *inside* your web browser.   This is probably what you want if the entity contains personal information."

	private := true.
	^self! !

!HTTPCacheControlField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
setPublic
	"^self
I am being told that the entity in my message is a public one that can be cached on public caches, i.e. caches that can be drawn upon by many clients.  This is probably not what you want if the entity contains personal information!!  c.f. >>setPrivate  Note that expicitly setting cache-control public actually loosens some other rules and means resources can be used by cached beyond their normal life."

	private := false.
	^self! !


!HTTPCacheControlField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream nextPut: Character space.
	self directives notNil ifTrue: [aStream nextPutAll: self directives].
	self private notNil 
		ifTrue: 
			[self writePublicOrPrivateTo: aStream.
			self maxAge notNil ifTrue: [aStream nextPutAll: ', ']].
	self maxAge notNil ifTrue: [self writeMaxAgeTo: aStream].
	^self! !

!HTTPCacheControlField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
writeMaxAgeTo: aStream 
	"^self
I write the maxAge directive to aStream"

	aStream nextPutAll: 'max-age='.
	self maxAge printOn: aStream.
	^self! !

!HTTPCacheControlField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
writePublicOrPrivateTo: aStream 
	"^self
I write the either the public or the private directive to aStream"

	self private 
		ifTrue: [aStream nextPutAll: 'private']
		ifFalse: [aStream nextPutAll: 'public'].
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPCacheControlField class
	instanceVariableNames: ''!

!HTTPCacheControlField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Cache-Control'! !


SpecificHeaderField subclass: #HTTPConnectionField
	instanceVariableNames: 'connectionToken'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!
!HTTPConnectionField commentStamp: '<historical>' prior: 0!
c.f. RFC 2616 14.10

   The Connection header has the following grammar:

       Connection = "Connection" ":" 1#(connection-token)
       connection-token  = token

!


!HTTPConnectionField methodsFor: 'services'!
combineWith: aConnectionHeaderField
	self connectionToken: 
		self connectionToken, ', ' , aConnectionHeaderField connectionToken.! !

!HTTPConnectionField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
setToClose
	self connectionToken: 'close'.
	^self! !

!HTTPConnectionField methodsFor: 'services' stamp: 'mivsek 12/31/2007 14:00'!
setToKeepAlive
	self connectionToken: 'keep-alive'.
	^self! !

!HTTPConnectionField methodsFor: 'services'!
setToUpgrade
	self connectionToken: 'Upgrade'.
	^self! !


!HTTPConnectionField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
connectionToken
	"^a String
Common values are 'close' and 'keep-alive'."

	^connectionToken! !

!HTTPConnectionField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
connectionToken: aString 
	"^self"

	connectionToken := aString.
	^self! !


!HTTPConnectionField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
connectionTokenIsClose
	^self connectionToken = 'close'! !


!HTTPConnectionField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString 
	connectionToken := HTTPString trimBlanksFrom: aString.
	^self! !


!HTTPConnectionField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream nextPutAll: connectionToken.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPConnectionField class
	instanceVariableNames: ''!

!HTTPConnectionField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Connection'! !


SpecificHeaderField subclass: #HTTPContentLengthField
	instanceVariableNames: 'contentLength'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPContentLengthField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
contentLength
	^contentLength! !

!HTTPContentLengthField methodsFor: 'accessing' stamp: 'mivsek 12/31/2007 14:01'!
contentLength: anInteger
	contentLength := anInteger! !


!HTTPContentLengthField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString
	contentLength := aString asNumber.
	^self! !


!HTTPContentLengthField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	self contentLength printOn: aStream.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPContentLengthField class
	instanceVariableNames: ''!

!HTTPContentLengthField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Content-Length'! !


SpecificHeaderField subclass: #HTTPCookieField
	instanceVariableNames: 'values'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPCookieField class
	instanceVariableNames: ''!

!HTTPCookieField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Cookie'! !


SpecificHeaderField subclass: #HTTPDateField
	instanceVariableNames: 'date'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPDateField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
date
	^date! !

!HTTPDateField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
date: aDate 
	"^self
Note that this is an HTTP Date, and so is really a timestamp :-/ "

	date := aDate.
	^self! !


!HTTPDateField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	self date asRFC1123StringOn: aStream.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPDateField class
	instanceVariableNames: ''!

!HTTPDateField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Date'! !


SpecificHeaderField subclass: #HTTPETagField
	instanceVariableNames: 'entityTag'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!
!HTTPETagField commentStamp: '<historical>' prior: 0!
RFC 2626 14.19 ETag

   The ETag response-header field provides the current value of the
   entity tag for the requested variant. The headers used with entity
   tags are described in sections 14.24, 14.26 and 14.44. The entity tag
   MAY be used for comparison with other entities from the same resource
   (see section 13.3.3).

      ETag = "ETag" ":" entity-tag

   Examples:

      ETag: "xyzzy"
      ETag: W/"xyzzy"
      ETag: ""

!


!HTTPETagField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
entityTag
	^entityTag! !

!HTTPETagField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
entityTag: aString 
	entityTag := aString.
	^self! !


!HTTPETagField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream
		nextPut: $";
		nextPutAll: self entityTag;
		nextPut: $".
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPETagField class
	instanceVariableNames: ''!

!HTTPETagField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'ETag'! !


SpecificHeaderField subclass: #HTTPExpiresField
	instanceVariableNames: 'timestamp'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPExpiresField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
timestamp
	^timestamp! !

!HTTPExpiresField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
timestamp: aTimestamp
	timestamp := aTimestamp.! !


!HTTPExpiresField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	self timestamp asRFC1123StringOn: aStream.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPExpiresField class
	instanceVariableNames: ''!

!HTTPExpiresField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Expires'! !


SpecificHeaderField subclass: #HTTPHostField
	instanceVariableNames: 'hostName portNumber'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPHostField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
hostName
	^hostName! !

!HTTPHostField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
portNumber
	^portNumber isNil ifTrue: [80] ifFalse: [portNumber]! !


!HTTPHostField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString 
	| sourceStream portNumberString |
	sourceStream := ReadStream on: aString.
	hostName := sourceStream upTo: $:.
	portNumberString := sourceStream atEnd 
				ifTrue: [String new]
				ifFalse: [sourceStream upToEnd].
	portNumberString notEmpty 
		ifTrue: [portNumber := portNumberString asNumber].
	^self! !


!HTTPHostField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream nextPutAll: self hostName.
	portNumber notNil 
		ifTrue: 
			[aStream nextPut: $:.
			self portNumber printOn: aStream].
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPHostField class
	instanceVariableNames: ''!

!HTTPHostField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Host'! !


SpecificHeaderField subclass: #HTTPIfModifiedSinceField
	instanceVariableNames: 'date'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPIfModifiedSinceField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
date
	^date! !


!HTTPIfModifiedSinceField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isCacheHitFor: anEntity 
	"^a Boolean
I return true if an anEntity is a cache hit given the conditional I represent.  So in my case, I'm looking to see that the entity has not changed since my date.
anEntity *must* respond to >>lastModified"

	^anEntity lastModified <= self date! !

!HTTPIfModifiedSinceField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isConditional
	^true! !


!HTTPIfModifiedSinceField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString 
	date := SpTimestamp fromRFC1123String: aString.
	^self! !


!HTTPIfModifiedSinceField methodsFor: 'printing' stamp: 'janko 7/26/2008 13:51'!
valuesAsStringOn: aStream 
	self date notNil ifTrue: [self date asRFC1123StringOn: aStream].
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPIfModifiedSinceField class
	instanceVariableNames: ''!

!HTTPIfModifiedSinceField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'If-Modified-Since'! !


SpecificHeaderField subclass: #HTTPIfRangeField
	instanceVariableNames: 'tagOrDate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPIfRangeField methodsFor: 'private'!
parseValueFrom: aString 
	self tagOrDate: aString.! !


!HTTPIfRangeField methodsFor: 'accessing'!
tagOrDate

	^tagOrDate! !

!HTTPIfRangeField methodsFor: 'accessing'!
tagOrDate: aString
	tagOrDate := aString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPIfRangeField class
	instanceVariableNames: ''!

!HTTPIfRangeField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'If-Range'! !


SpecificHeaderField subclass: #HTTPIfUnmodifiedSinceField
	instanceVariableNames: 'date'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPIfUnmodifiedSinceField methodsFor: 'accessing'!
date
	^date! !


!HTTPIfUnmodifiedSinceField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isCacheHitFor: anEntity 
	"^a Boolean
I return true if an anEntity is a cache hit given the conditional I represent. 
anEntity *must* respond to >>entutyTag"

	1 halt.
	^self! !

!HTTPIfUnmodifiedSinceField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isConditional
	^true! !


!HTTPIfUnmodifiedSinceField methodsFor: 'private'!
parseValueFrom: aString 
	date := SpTimestamp fromRFC1123String: aString.
	^self! !


!HTTPIfUnmodifiedSinceField methodsFor: 'printing'!
valuesAsStringOn: aStream 
	self date notNil ifTrue: [self date asRFC1123StringOn: aStream].
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPIfUnmodifiedSinceField class
	instanceVariableNames: ''!

!HTTPIfUnmodifiedSinceField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'If-Unmodified-Since'! !


SpecificHeaderField subclass: #HTTPLastModifiedField
	instanceVariableNames: 'timestamp'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPLastModifiedField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
timestamp
	^timestamp! !

!HTTPLastModifiedField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
timestamp: aTimestamp
	timestamp := aTimestamp.! !


!HTTPLastModifiedField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	self timestamp asRFC1123StringOn: aStream.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPLastModifiedField class
	instanceVariableNames: ''!

!HTTPLastModifiedField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Last-Modified'! !


SpecificHeaderField subclass: #HTTPLocationField
	instanceVariableNames: 'uri'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPLocationField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
uri
	^uri! !

!HTTPLocationField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
uri: aSwazooURI 
	uri := aSwazooURI.
	^self! !

!HTTPLocationField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
uriString: aString 
	uri := SwazooURI fromString: aString.
	^self! !


!HTTPLocationField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	self uri printOn: aStream.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPLocationField class
	instanceVariableNames: ''!

!HTTPLocationField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Location'! !


SpecificHeaderField subclass: #HTTPMatchField
	instanceVariableNames: 'entityTags'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPMatchField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
addEntityTag: aString 
	self entityTags add: aString.
	^self! !

!HTTPMatchField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
combineWith: aHeaderField 
	"^self
I add the entity tags of aHeaderField to my own collection of entity tags."

	self entityTags addAll: aHeaderField entityTags.
	^self! !


!HTTPMatchField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
entityTags
	^self matchesAnyCurrentEntity 
		ifTrue: [nil]
		ifFalse: 
			[entityTags isNil ifTrue: [entityTags := OrderedCollection new].
			entityTags]! !


!HTTPMatchField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isConditional
	^true! !

!HTTPMatchField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
matchesAnyCurrentEntity
	^entityTags = '*'! !


!HTTPMatchField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString 
	aString = '*' 
		ifTrue: [entityTags := aString]
		ifFalse: 
			[| sourceStream |
			entityTags := OrderedCollection new.
			sourceStream := ReadStream on: aString.
			[sourceStream atEnd] whileFalse: 
					[| entityTag |
					sourceStream upTo: $".
					entityTag := sourceStream upTo: $".
					entityTags add: entityTag.
					sourceStream upTo: $,]].
	^self! !


!HTTPMatchField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: targetStream 
	self write: self entityTags first asQuotedStringTo: targetStream.
	2 to: self entityTags size
		do: 
			[:tagIndex | 
			targetStream nextPut: $,.
			self write: (self entityTags at: tagIndex) asQuotedStringTo: targetStream].
	^self! !

!HTTPMatchField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
write: aString asQuotedStringTo: targetStream 
	"^self
See RFC 2616 2.2"

	targetStream nextPut: $".
	aString do: 
			[:character | 
			character == $" 
				ifTrue: [targetStream nextPutAll: '\"']
				ifFalse: [targetStream nextPut: character]].
	targetStream nextPut: $".
	^self! !


HTTPMatchField subclass: #HTTPIfMatchField
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!
!HTTPIfMatchField commentStamp: '<historical>' prior: 0!
From RFC 2616

14.24 If-Match

   The If-Match request-header field is used with a method to make it
   conditional. A client that has one or more entities previously
   obtained from the resource can verify that one of those entities is
   current by including a list of their associated entity tags in the
   If-Match header field. Entity tags are defined in section 3.11. The
   purpose of this feature is to allow efficient updates of cached
   information with a minimum amount of transaction overhead. It is also
   used, on updating requests, to prevent inadvertent modification of
   the wrong version of a resource. As a special case, the value "*"
   matches any current entity of the resource.

       If-Match = "If-Match" ":" ( "*" | 1#entity-tag )

   If any of the entity tags match the entity tag of the entity that
   would have been returned in the response to a similar GET request
   (without the If-Match header) on that resource, or if "*" is given

   and any current entity exists for that resource, then the server MAY
   perform the requested method as if the If-Match header field did not
   exist.

   A server MUST use the strong comparison function (see section 13.3.3)
   to compare the entity tags in If-Match.

   If none of the entity tags match, or if "*" is given and no current
   entity exists, the server MUST NOT perform the requested method, and
   MUST return a 412 (Precondition Failed) response. This behavior is
   most useful when the client wants to prevent an updating method, such
   as PUT, from modifying a resource that has changed since the client
   last retrieved it.

   If the request would, without the If-Match header field, result in
   anything other than a 2xx or 412 status, then the If-Match header
   MUST be ignored.

   The meaning of "If-Match: *" is that the method SHOULD be performed
   if the representation selected by the origin server (or by a cache,
   possibly using the Vary mechanism, see section 14.44) exists, and
   MUST NOT be performed if the representation does not exist.

   A request intended to update a resource (e.g., a PUT) MAY include an
   If-Match header field to signal that the request method MUST NOT be
   applied if the entity corresponding to the If-Match value (a single
   entity tag) is no longer a representation of that resource. This
   allows the user to indicate that they do not wish the request to be
   successful if the resource has been changed without their knowledge.
   Examples:

       If-Match: "xyzzy"
       If-Match: "xyzzy", "r2d2xxxx", "c3piozzzz"
       If-Match: *

   The result of a request having both an If-Match header field and
   either an If-None-Match or an If-Modified-Since header fields is
   undefined by this specification.

!


!HTTPIfMatchField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isCacheHitFor: anEntity 
	"^a Boolean
I return true if an anEntity is a cache hit given the conditional I represent. 
anEntity *must* respond to >>entutyTag"

	1 halt.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPIfMatchField class
	instanceVariableNames: ''!

!HTTPIfMatchField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'If-Match'! !


HTTPMatchField subclass: #HTTPIfNoneMatchField
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!
!HTTPIfNoneMatchField commentStamp: '<historical>' prior: 0!
This is a confitional header field.  The HTTP client is asking for a resource on the basis of this condition.  So, we need to have first found the resource, and then we can considder the condition, as follows ...

From RFC 2616:

14.26 If-None-Match

   The If-None-Match request-header field is used with a method to make
   it conditional. A client that has one or more entities previously
   obtained from the resource can verify that none of those entities is
   current by including a list of their associated entity tags in the
   If-None-Match header field. The purpose of this feature is to allow
   efficient updates of cached information with a minimum amount of
   transaction overhead. It is also used to prevent a method (e.g. PUT)
   from inadvertently modifying an existing resource when the client
   believes that the resource does not exist.

   As a special case, the value "*" matches any current entity of the
   resource.

       If-None-Match = "If-None-Match" ":" ( "*" | 1#entity-tag )

   If any of the entity tags match the entity tag of the entity that
   would have been returned in the response to a similar GET request
   (without the If-None-Match header) on that resource, or if "*" is
   given and any current entity exists for that resource, then the
   server MUST NOT perform the requested method, unless required to do
   so because the resource's modification date fails to match that
   supplied in an If-Modified-Since header field in the request.
   Instead, if the request method was GET or HEAD, the server SHOULD
   respond with a 304 (Not Modified) response, including the cache-
   related header fields (particularly ETag) of one of the entities that
   matched. For all other request methods, the server MUST respond with
   a status of 412 (Precondition Failed).

   See section 13.3.3 for rules on how to determine if two entities tags
   match. The weak comparison function can only be used with GET or HEAD
   requests.

   If none of the entity tags match, then the server MAY perform the
   requested method as if the If-None-Match header field did not exist,
   but MUST also ignore any If-Modified-Since header field(s) in the
   request. That is, if no entity tags match, then the server MUST NOT
   return a 304 (Not Modified) response.

   If the request would, without the If-None-Match header field, result
   in anything other than a 2xx or 304 status, then the If-None-Match
   header MUST be ignored. (See section 13.3.4 for a discussion of
   server behavior when both If-Modified-Since and If-None-Match appear
   in the same request.)

   The meaning of "If-None-Match: *" is that the method MUST NOT be
   performed if the representation selected by the origin server (or by
   a cache, possibly using the Vary mechanism, see section 14.44)
   exists, and SHOULD be performed if the representation does not exist.
   This feature is intended to be useful in preventing races between PUT
   operations.

   Examples:

       If-None-Match: "xyzzy"
       If-None-Match: W/"xyzzy"
       If-None-Match: "xyzzy", "r2d2xxxx", "c3piozzzz"
       If-None-Match: W/"xyzzy", W/"r2d2xxxx", W/"c3piozzzz"
       If-None-Match: *

   The result of a request having both an If-None-Match header field and
   either an If-Match or an If-Unmodified-Since header fields is
   undefined by this specification.!


!HTTPIfNoneMatchField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isCacheHitFor: anEntity 
	"^a Boolean
I return true if an anEntity is a cache hit given the conditional I represent.  So in my case, I'm looking to see that the entity has a tag which is in my collection of entityTags.
anEntity *must* respond to >>entityTag"

	^self entityTags includes: anEntity entityTag! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPIfNoneMatchField class
	instanceVariableNames: ''!

!HTTPIfNoneMatchField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'If-None-Match'! !


SpecificHeaderField subclass: #HTTPRefererField
	instanceVariableNames: 'uri'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!
!HTTPRefererField commentStamp: '<historical>' prior: 0!
RFC 2616: 14.36 Referer

   The Referer[sic] request-header field allows the client to specify,
   for the server's benefit, the address (URI) of the resource from
   which the Request-URI was obtained (the "referrer", although the
   header field is misspelled.) The Referer request-header allows a
   server to generate lists of back-links to resources for interest,
   logging, optimized caching, etc. It also allows obsolete or mistyped
   links to be traced for maintenance. The Referer field MUST NOT be
   sent if the Request-URI was obtained from a source that does not have
   its own URI, such as input from the user keyboard.

       Referer        = "Referer" ":" ( absoluteURI | relativeURI )

   Example:

       Referer: http://www.w3.org/hypertext/DataSources/Overview.html

   If the field value is a relative URI, it SHOULD be interpreted
   relative to the Request-URI. The URI MUST NOT include a fragment. See
   section 15.1.3 for security considerations.

!


!HTTPRefererField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString 
	uri := SwazooURI fromString: aString.
	^self! !


!HTTPRefererField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
uri
	^uri! !


!HTTPRefererField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	self uri printOn: aStream.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPRefererField class
	instanceVariableNames: ''!

!HTTPRefererField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Referer'! !


SpecificHeaderField subclass: #HTTPServerField
	instanceVariableNames: 'productTokens'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPServerField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
productTokens
	^productTokens! !

!HTTPServerField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
productTokens: aString 
	productTokens := aString.
	^self! !


!HTTPServerField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream nextPutAll: self productTokens.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPServerField class
	instanceVariableNames: ''!

!HTTPServerField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Server'! !


SpecificHeaderField subclass: #HTTPSetCookieField
	instanceVariableNames: 'cookies'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPSetCookieField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
addCookie: aCookieString
	^self cookies add: aCookieString! !

!HTTPSetCookieField methodsFor: 'services' stamp: ' 14/4/07 23:10'!
combineWith: aSetCookieField 
	"^self
I add the cookies of aSetCookieField to my own collection of cookies."

	self cookies addAll: aSetCookieField cookies.
	^self! !


!HTTPSetCookieField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
cookies
	cookies isNil ifTrue: [cookies := OrderedCollection new].
	^cookies! !


!HTTPSetCookieField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream nextPutAll: (self cookies at: 1).
	2 to: self cookies size
		do: 
			[:cookieIndex | 
			aStream
				nextPutAll: ', ';
				nextPutAll: (self cookies at: cookieIndex)].
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPSetCookieField class
	instanceVariableNames: ''!

!HTTPSetCookieField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'Set-Cookie'! !


SpecificHeaderField subclass: #HTTPUserAgentField
	instanceVariableNames: 'productTokens'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!
!HTTPUserAgentField commentStamp: '<historical>' prior: 0!
RFC 2616: 14.43 User-Agent

   The User-Agent request-header field contains information about the
   user agent originating the request. This is for statistical purposes,
   the tracing of protocol violations, and automated recognition of user
   agents for the sake of tailoring responses to avoid particular user
   agent limitations. User agents SHOULD include this field with
   requests. The field can contain multiple product tokens (section 3.8)
   and comments identifying the agent and any subproducts which form a
   significant part of the user agent. By convention, the product tokens
   are listed in order of their significance for identifying the
   application.

       User-Agent     = "User-Agent" ":" 1*( product | comment )

   Example:

       User-Agent: CERN-LineMode/2.15 libwww/2.17b3!


!HTTPUserAgentField methodsFor: 'private' stamp: ' 14/4/07 23:10'!
parseValueFrom: aString 
	"^self
I could try and parse out the product name and version numbers, but there is no need to worry about this at the moment, so I just record the string."

	productTokens := HTTPString trimBlanksFrom: aString.
	^self! !


!HTTPUserAgentField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
productTokens
	^productTokens! !


!HTTPUserAgentField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream nextPutAll: productTokens.
	^self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPUserAgentField class
	instanceVariableNames: ''!

!HTTPUserAgentField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'User-Agent'! !


SpecificHeaderField subclass: #HTTPWWWAuthenticateField
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPWWWAuthenticateField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isBasic
	"^a Boolean
I return true if I represent a header for basic authentication. c.f. RFC 2617 sec 2."

	^false! !

!HTTPWWWAuthenticateField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isDigest
	"^a Boolean
I return true if I represent a header for digest authentication. c.f. RFC 2617 sec 3."

	^false! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPWWWAuthenticateField class
	instanceVariableNames: ''!

!HTTPWWWAuthenticateField class methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
fieldName
	^'WWW-Authenticate'! !


HTTPWWWAuthenticateField subclass: #HTTPWWWAuthenticateBasicField
	instanceVariableNames: 'realm'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPWWWAuthenticateBasicField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isBasic
	"^a Boolean
I return true if I represent a header for basic authentication. c.f. RFC 2617 sec 2."

	^true! !


!HTTPWWWAuthenticateBasicField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
realm
	"^a String
I return the realm for which I represent an autentication challenge.  This string will be presented to the browser user in the login dialog."

	^realm! !

!HTTPWWWAuthenticateBasicField methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
realm: anObject
	realm := anObject! !


!HTTPWWWAuthenticateBasicField methodsFor: 'printing' stamp: ' 14/4/07 23:10'!
valuesAsStringOn: aStream 
	aStream
		nextPutAll: 'Basic realm="';
		nextPutAll: self realm;
		nextPut: $".
	^self! !


HTTPWWWAuthenticateField subclass: #HTTPWWWAuthenticateDigestField
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Headers'!

!HTTPWWWAuthenticateDigestField methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isDigest
	"^a Boolean
I return true if I represent a header for digest authentication. c.f. RFC 2617 sec 3."

	^true! !
