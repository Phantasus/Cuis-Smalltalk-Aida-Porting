SwazooResource subclass: #FileMappingResource
	instanceVariableNames: 'directoryIndex filePath'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Fileserver'!

!FileMappingResource methodsFor: 'serving' stamp: ' 14/4/07 23:10'!
answerTo: aRequest 
	(self checkExistence: aRequest) ifFalse: [^nil].
	(self checkURI: aRequest) 
		ifFalse: 
			[| response |
			response := HTTPResponse movedPermanently.
			response headers 
				addField: (HTTPLocationField new uriString: aRequest uri identifier , '/').
			^response].
	^self file: (self fileFor: aRequest) answerTo: aRequest! !


!FileMappingResource methodsFor: 'private' stamp: ' 14/4/07 23:10'!
checkExistence: aRequest 
	(self rootFileFor: aRequest) exists ifFalse: [^false].
	^(self fileFor: aRequest) exists! !

!FileMappingResource methodsFor: 'private' stamp: ' 14/4/07 23:10'!
checkURI: aRequest 
	| needsFinalSlash |
	needsFinalSlash := (self rootFileFor: aRequest) isDirectory 
				and: [aRequest uri isDirectory not].
	^needsFinalSlash not! !

!FileMappingResource methodsFor: 'private' stamp: ' 14/4/07 23:10'!
file: aFilename answerTo: aRequest 
	^self subclassResponsibility! !

!FileMappingResource methodsFor: 'private' stamp: 'mivsek 8/16/2007 22:05'!
fileDirectory
	^SpFilename named: self filePath! !

!FileMappingResource methodsFor: 'private' stamp: ' 14/4/07 23:10'!
fileFor: aRequest 
	| fn |
	fn := self rootFileFor: aRequest.
	fn isDirectory ifTrue: [fn := fn construct: self directoryIndex].
	^fn! !

!FileMappingResource methodsFor: 'private' stamp: ' 14/4/07 23:10'!
rootFileFor: aRequest 
	^aRequest tailPath inject: self fileDirectory
		into: 
			[:subPath :each | 
			(#('.' '..') includes: (HTTPString trimBlanksFrom: each)) 
				ifTrue: [subPath]
				ifFalse: [subPath construct: each]]! !


!FileMappingResource methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
directoryIndex
	^directoryIndex! !

!FileMappingResource methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
directoryIndex: aString 
	directoryIndex := aString! !

!FileMappingResource methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
filePath
	^filePath! !

!FileMappingResource methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
filePath: aString 
	filePath := aString! !


!FileMappingResource methodsFor: 'private-initialize' stamp: ' 14/4/07 23:10'!
initialize
	super initialize.
	self directoryIndex: 'index.html'! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

FileMappingResource class
	instanceVariableNames: ''!

!FileMappingResource class methodsFor: 'instance creation' stamp: ' 14/4/07 23:10'!
uriPattern: aString filePath: aFilePath 
	^(self uriPattern: aString) filePath: aFilePath! !

!FileMappingResource class methodsFor: 'instance creation' stamp: ' 14/4/07 23:10'!
uriPattern: aString filePath: aFilePath directoryIndex: anotherString 
	^(self uriPattern: aString)
		filePath: aFilePath;
		directoryIndex: anotherString! !


FileMappingResource subclass: #FileResource
	instanceVariableNames: ''
	classVariableNames: 'ContentTypes'
	poolDictionaries: ''
	category: 'Swazoo-Fileserver'!

!FileResource methodsFor: 'private'!
contentTypeFor: aString 
	^ContentTypes 
		at: aString asLowercase 
		ifAbsent: ['application/octet-stream']! !

!FileResource methodsFor: 'private' stamp: ' 14/4/07 23:10'!
file: aFilename answerTo: aRequest 
	| cacheControl response |
	cacheControl := SwazooCacheControl new request: aRequest
				cacheTarget: aFilename.
	response := cacheControl isNotModified 
				ifTrue: [HTTPResponse notModified]
				ifFalse: 
					[FileResponse ok entity: ((MimeObject new)
								value: aFilename;
								contentType: (self contentTypeFor: aFilename extension))].
	cacheControl addResponseHeaders: response.
	^response! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

FileResource class
	instanceVariableNames: ''!

!FileResource class methodsFor: 'class initialization' stamp: 'hmm 6/9/2012 21:46'!
initialize
	"self initialize"

	ContentTypes := (Dictionary new)
				add: '.txt' -> 'text/plain';
				add: '.html' -> 'text/html';
				add: '.htm' -> 'text/html';
				add: '.css' -> 'text/css';
				add: '.xml' -> 'text/xml';
				add: '.js' -> 'text/javascript';
				add: '.png' -> 'image/png';
				add: '.gif' -> 'image/gif';
				add: '.jpg' -> 'image/jpeg';
				add: '.m3u' -> 'audio/mpegurl';
				add: '.ico' -> 'image/x-icon';
				add: '.pdf' -> 'application/pdf';
				yourself! !


HTTPResponse subclass: #FileResponse
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Fileserver'!

!FileResponse methodsFor: 'accessing-headers' stamp: ' 14/4/07 23:10'!
contentType
	^self entity contentType! !


!FileResponse methodsFor: 'accessing' stamp: 'hmm 6/5/2012 15:44'!
entity: aMimeObject 
	body := aMimeObject! !


!FileResponse methodsFor: 'private-printing' stamp: ' 14/4/07 23:10'!
printContentLengthOn: aStream 
	self entity isNil 
		ifFalse: 
			[aStream
				nextPutAll: 'Content-Length: ';
				print: self entity value fileSize.
			self crlfOn: aStream]! !

!FileResponse methodsFor: 'private-printing' stamp: 'hmm 6/9/2012 19:50'!
printEntityOn: aStream 
	| rs |
	self entity isNil 
		ifFalse: 
			[rs := self entity value readStream.
			rs binary.
			SpExceptionContext 
				for: 
					[[[rs atEnd] whileFalse: [aStream nextPutAll: (rs nextAvailable: 4096)]] 
						ensure: [rs close]]
				on: SpError
				do: [:ex | ex return]]! !

!FileResponse methodsFor: 'private-printing' stamp: ' 14/4/07 23:10'!
printHeadersOn: aStream 
	self contentType: self entity contentType.
	super printHeadersOn: aStream! !


FileResource subclass: #HomeResource
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Fileserver'!

!HomeResource methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
answerTo: aRequest 
	aRequest tailPath isEmpty ifTrue: [^nil].
	(self validateHomePath: aRequest tailPath first) ifFalse: [^nil].
	^super answerTo: aRequest! !


!HomeResource methodsFor: 'private' stamp: ' 14/4/07 23:10'!
rootFileFor: aRequest 
	| homeKey file |
	homeKey := aRequest tailPath first copyFrom: 2
				to: aRequest tailPath first size.
	file := (self fileDirectory construct: homeKey) construct: 'html'.
	(aRequest tailPath copyFrom: 2 to: aRequest tailPath size) 
		do: [:each | each = '..' ifFalse: [file := file construct: each]].
	^file! !

!HomeResource methodsFor: 'private' stamp: ' 14/4/07 23:10'!
validateHomePath: aString 
	^aString first = $~! !


Object subclass: #SwazooCacheControl
	instanceVariableNames: 'request cacheTarget etag lastModified'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Fileserver'!

!SwazooCacheControl methodsFor: 'operations' stamp: ' 14/4/07 23:10'!
addNotModifedHeaders: aResponse 
	"RFC2616 10.3.5
	If the conditional GET used a strong cache validator (see section 13.3.3), the response SHOULD NOT include other entity-headers. ... this prevents inconsistencies between cached entity-bodies and updated headers. "

	self isRequestStrongValidator 
		ifTrue: [aResponse headers addField: (HTTPETagField new entityTag: self etag)]
		ifFalse: [self basicAddResponseHeaders: aResponse].
	^aResponse! !

!SwazooCacheControl methodsFor: 'operations' stamp: ' 14/4/07 23:10'!
addResponseHeaders: aResponse 
	"Add response headers to the response.
	We MUST differentiate between 200/302 responses"

	^aResponse isNotModified 
		ifTrue: [self addNotModifedHeaders: aResponse]
		ifFalse: [self basicAddResponseHeaders: aResponse]! !

!SwazooCacheControl methodsFor: 'operations' stamp: 'JM 4/18/2007 16:23'!
basicAddResponseHeaders: aResponse 
	"RFC 2616 13.3.4
	HTTP/1.1 origin servers: 
      	- SHOULD send an entity tag validator unless it is not feasible to generate one.
		- SHOULD send a Last-Modified value "

	aResponse headers addField: (HTTPETagField new entityTag: self etag).
	aResponse headers addField: (HTTPLastModifiedField new timestamp: self lastModified).
	^aResponse! !

!SwazooCacheControl methodsFor: 'operations' stamp: ' 14/4/07 23:10'!
generateETag
	^self cacheTarget etag! !

!SwazooCacheControl methodsFor: 'operations' stamp: ' 14/4/07 23:10'!
generateLastModified
	^self cacheTarget lastModified! !


!SwazooCacheControl methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
cacheTarget
	^cacheTarget! !

!SwazooCacheControl methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
etag
	etag isNil ifTrue: [etag := self generateETag].
	^etag! !

!SwazooCacheControl methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
etag: aString 
	etag := aString! !

!SwazooCacheControl methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
request: aHTTPGet cacheTarget: anObject 
	request := aHTTPGet.
	cacheTarget := anObject! !


!SwazooCacheControl methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isIfModifiedSince
	"Answers true if either 
		- the request does not included the header
		-or there is not a match"

	| ifModifiedSince |
	ifModifiedSince := request headers fieldOfClass: HTTPIfModifiedSinceField
				ifNone: [nil].
	^ifModifiedSince isNil or: [self lastModified > ifModifiedSince date]! !

!SwazooCacheControl methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isIfNoneMatch
	"Answers true if either 
		- the request does not included the header
		-or there is not a match"

	| field |
	field := request headers fieldOfClass: HTTPIfNoneMatchField ifNone: [nil].
	^field isNil or: [(field entityTags includes: self etag) not]! !

!SwazooCacheControl methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isNotModified
	"Compare the cacheTarget with the request headers and answer if the client's version is not modified.
	Takes into account http version, and uses best practices defined by HTTP spec"

	^self isIfNoneMatch not or: [self isIfModifiedSince not]! !

!SwazooCacheControl methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
isRequestStrongValidator
	| field |
	field := request headers fieldOfClass: HTTPIfNoneMatchField ifNone: [nil].
	^field notNil and: [field entityTags isEmpty not]! !

!SwazooCacheControl methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
lastModified
	lastModified isNil ifTrue: [lastModified := self generateLastModified].
	^lastModified! !

!SwazooCacheControl methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
lastModified: aRFC1123TimeStampString 
	lastModified := aRFC1123TimeStampString! !

FileResource initialize!