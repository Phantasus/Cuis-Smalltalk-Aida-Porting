TestCase subclass: #CompositeResourceTest
	instanceVariableNames: 'composite'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!CompositeResourceTest methodsFor: 'testing' stamp: 'jm 2/8/2009 13:52'!
sampleInSite
	| site |
	site := SwazooSite new.
	site host: 'swazoo.org' ip: '127.0.0.1' port: 8200.
	site addResource: composite! !

!CompositeResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testAddResource
	| child |
	composite addResource: (child := HelloWorldResource uriPattern: 'hello.html').
	self assert: composite children size = 1.
	self assert: composite children first == child.
	self assert: child parent == composite! !

!CompositeResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testAddResources
	| child1 child2 |
	child1 := HelloWorldResource uriPattern: 'hello1.html'.
	child2 := HelloWorldResource uriPattern: 'hello2.html'.
	composite addResources: (Array with: child1 with: child2).
	self assert: composite children size = 2.
	composite children
		do: 
			[:each | 
			self assert: (composite children includes: each).
			self assert: each parent == composite]! !

!CompositeResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testCurrentUrl
	| child leaf |	
	self sampleInSite.
	self assert: composite currentUrl = 'http://swazoo.org:8200/'.
	composite addResource: (child := CompositeResource uriPattern: 'foo').
	self assert: child currentUrl = 'http://swazoo.org:8200/foo/'.
	child addResource: (leaf := HelloWorldResource uriPattern: 'hi.html').
	self assert: leaf currentUrl = 'http://swazoo.org:8200/foo/hi.html'.! !

!CompositeResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testEmptyURIPatternInvalid
	composite uriPattern: ''.
	self deny: composite isValidlyConfigured! !

!CompositeResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testNilURIPatternDoesNothing
	| pattern |
	pattern := composite uriPattern.
	composite uriPattern: nil.
	self assert: composite uriPattern = pattern! !

!CompositeResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testValidlyConfigured
	self assert: composite isValidlyConfigured! !


!CompositeResourceTest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
setUp
	composite := CompositeResource uriPattern: '/'! !


TestCase subclass: #FileResourceTest
	instanceVariableNames: 'resource'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!FileResourceTest methodsFor: 'running' stamp: 'mivsek 8/16/2007 22:09'!
setUp
	| directory firstFile ws |
	directory := SpFilename named: 'fResTest'.
	directory exists ifFalse: [directory makeDirectory].
	firstFile :=  (SpFilename named: 'fResTest') construct: 'abc.html'.
	ws := firstFile writeStream.
	[ws nextPutAll: 'hello'] ensure: [ws close].
	resource := FileResource uriPattern: 'foo' filePath: 'fResTest'! !

!FileResourceTest methodsFor: 'running' stamp: 'mivsek 8/16/2007 22:09'!
tearDown
	((SpFilename named: 'fResTest') construct: 'abc.html') delete.
	(SpFilename named: 'fResTest') delete! !


!FileResourceTest methodsFor: 'testing' stamp: 'JM 4/18/2007 16:34'!
testContentType
	self assert: (resource contentTypeFor: '.txt') = 'text/plain'.
	self assert: (resource contentTypeFor: '.html') = 'text/html'
! !

!FileResourceTest methodsFor: 'testing'!
testDirectoryIndex
	| request response |
	request := HTTPGet request: 'foo/'.
	resource directoryIndex: 'abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'foo'! !

!FileResourceTest methodsFor: 'testing'!
testETag
	"Filename etags do not have the leading and trailing double quotes.  Header fields add the quotes as necessary"

	| request response etag |
	request := HTTPGet request: 'foo/abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 200.
	self 
		assert: (etag := (response headers fieldOfClass: HTTPETagField) entityTag) 
				notNil.
	request := HTTPGet request: 'foo/abc.html'.
	request headers addField: (HTTPIfNoneMatchField new addEntityTag: etag).
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 304.
	self assert: (response headers fieldOfClass: HTTPETagField) entityTag = etag.
	request := HTTPGet request: 'foo/abc.html'.
	request headers addField: (HTTPIfNoneMatchField new valueFrom: '"wrong"').
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 200.
	self assert: (response headers fieldOfClass: HTTPETagField) entityTag = etag! !

!FileResourceTest methodsFor: 'testing'!
testExistantFile
	| request response |
	request := HTTPGet request: 'foo/abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'foo'! !

!FileResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testNonexistantFile
	| request response |
	request := HTTPGet request: 'foo/notThere.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil! !

!FileResourceTest methodsFor: 'testing'!
testRedirection
	| request response |
	request := HTTPGet request: 'foo'.
	resource directoryIndex: 'abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 301.
	self assert: (response headers fieldNamed: 'Location') uri asString 
				= 'http://foo/'.
	self assert: (response headers fieldNamed: 'Location') uri host = 'foo'! !

!FileResourceTest methodsFor: 'testing' stamp: 'JM 4/18/2007 16:33'!
testRelativeFile
"it doesn't work anyway!!
	| request response |
	request := HTTPGet request: 'foo/../', resource fileDirectory tail, '/abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil
"! !

!FileResourceTest methodsFor: 'testing'!
testSafeConstruct
	| request response |
	request := HTTPGet request: 'foo/../abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 200.
	request := HTTPGet request: 'foo/.. /./abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 200! !


TestCase subclass: #HTTPPostTest
	instanceVariableNames: 'request'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!HTTPPostTest methodsFor: 'requests' stamp: 'janko 7/26/2008 15:36'!
crlf
	^String with: Character cr with: Character lf.! !

!HTTPPostTest methodsFor: 'requests' stamp: 'janko 7/26/2008 15:33'!
fileContents
	"HTTPRequestTest new fileContents"
	| stream |
	stream := SwazooStream on: String new.
	stream
		nextPutLine: 'BEGIN:VCALENDAR';
		nextPutLine: 'PRODID:-//Squeak-iCalendar//-';
		nextPutLine: 'VERSION:2.0';
		nextPutLine: 'X-WR-CALNAME:test';
		nextPutLine: 'METHOD:PUBLISH';
		nextPutLine: 'BEGIN:VEVENT';
		nextPutLine: 'UID:an event with a start date and not date and time';
		nextPutLine: 'CATEGORIES:category1,category2';
		nextPutLine: 'CREATED:20050501T110231Z';
		nextPutLine: 'SEQUENCE:0';
		nextPutLine: 'SUMMARY:aTitle';
		nextPutLine: 'PRIORITY:5';
		nextPutLine: 'DTSTART;VALUE=DATE:20050425';
		nextPutLine: 'END:VEVENT';
		nextPutLine: 'END:VCALENDAR'.

	^stream writeBuffer contents asString! !

!HTTPPostTest methodsFor: 'requests' stamp: 'janko 7/26/2008 15:33'!
postDashes
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'POST  /document/aab.html HTTP/1.1';
		nextPutLine: 'Host: biart.eranova.si';
		nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
		nextPutLine: 'Content-Length: 149';
            crlf;
		nextPutLine: '--boundary';
		nextPutLine: 'Content-Disposition: form-data; name="id5273"';
		crlf; 
		nextPutLine: '----';
		nextPutLine: '--boundary';
		nextPutLine: 'Content-Disposition: form-data; name="field2"';
		crlf; 
		nextPutLine: '- --';
		nextPutLine: '--boundary--'.

	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPPostTest methodsFor: 'requests' stamp: 'janko 7/26/2008 15:33'!
postEmpty
	"post entity with empty value"
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'POST  /document/aab.html HTTP/1.1';
		nextPutLine: 'Host: biart.eranova.si';
		nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
		nextPutLine: 'Content-Length: 75';
            crlf;
		nextPutLine: '--boundary';
		nextPutLine: 'Content-Disposition: form-data; name="id5273"';
		crlf; 
		nextPutLine: '';
		nextPutLine: '--boundary--'.

	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPPostTest methodsFor: 'requests' stamp: 'janko 7/26/2008 15:33'!
postFile
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'POST  /document/aab.html HTTP/1.1';
		nextPutLine: 'Connection: Keep-Alive';
		nextPutLine: 'User-Agent: Mozilla/4.72 [en] (X11; I; Linux 2.3.51 i686)';
		nextPutLine: 'Host: biart.eranova.si';
		nextPutLine: 'Referer: http://www.bar.com/takeMeThere.html';
		nextPutLine: 'Content-Type: multipart/form-data; boundary= -----------------20752836116568320241700153999';
		nextPutLine: 'Content-Length: ', (527+self fileContents size) printString;
            crlf;
		nextPutLine: '-------------------20752836116568320241700153999';
		nextPutLine: 'Content-Disposition: form-data; name="id5273"';
		crlf; 
		nextPutLine: 'main';
		nextPutLine: '-------------------20752836116568320241700153999';
		nextPutLine: 'Content-Disposition: form-data; name="field2"';
		crlf; crlf;
		nextPutLine: '-------------------20752836116568320241700153999';
		nextPutLine: 'Content-Disposition: form-data; name="field7"; filename="event.ical"';
		nextPutLine: 'Content-Type: application/octet-stream';
		crlf;

		nextPutAll: self fileContents;

		crlf;
		nextPutLine: '-------------------20752836116568320241700153999';
		nextPutLine: 'Content-Disposition: form-data; name="attach"';
		crlf;
		nextPutLine: 'Attach';
		nextPutLine: '-------------------20752836116568320241700153999--'.

	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPPostTest methodsFor: 'requests' stamp: 'janko 7/26/2008 15:33'!
postPreambleEpilogue
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'POST  /document/aab.html HTTP/1.1';
		nextPutLine: 'Host: biart.eranova.si';
		nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
		nextPutLine: 'Content-Length: 146';
            crlf;
		nextPutLine: 'This is a multi-part message in MIME format';
		nextPutLine: '--boundary';
		nextPutLine: 'Content-Disposition: form-data; name="id5273"';
		crlf; 
		nextPutLine: 'main';
		nextPutLine: '--boundary--';
		nextPutLine: 'This is the epilogue'.

	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPPostTest methodsFor: 'requests' stamp: 'janko 7/26/2008 15:33'!
postSimple
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'POST  /document/aab.html HTTP/1.1';
		nextPutLine: 'Host: biart.eranova.si';
		nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
		nextPutLine: 'Content-Length: 79';
            crlf;
		nextPutLine: '--boundary';
		nextPutLine: 'Content-Disposition: form-data; name="id5273"';
		crlf; 
		nextPutLine: 'main';
		nextPutLine: '--boundary--'.

	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPPostTest methodsFor: 'requests' stamp: 'janko 7/26/2008 15:33'!
postUrlEncoded
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'POST  /document/aab.html HTTP/1.1';
		nextPutLine: 'Host: biart.eranova.si';
		nextPutLine: 'Content-Type: application/x-www-form-urlencoded';
		nextPutLine: 'Content-Length: 36';
            crlf;
		nextPutAll: 'home=Cosby+one&favorite+flavor=flies'.

	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !


!HTTPPostTest methodsFor: 'testing-mime parsing' stamp: 'janko 7/26/2008 15:35'!
testBlockCopy
	"streaming with 8k blocks for performance"
	"this is just a basic test with content shorter that one block"
	| boundary message in out |
	boundary := '--boundary--'.
	message := 'just something'. 
	in := SwazooStream on: message, self crlf, boundary.
	out := WriteStream on: String new.
	HTTPPost new blockStreamingFrom: in to: out until: boundary.
	self assert: out contents = message.! !


!HTTPPostTest methodsFor: 'testing-posts' stamp: 'janko 7/26/2008 15:33'!
testPost10Simple
	"just one entity"
	| post |
	post := self postSimple.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = 'main'.! !

!HTTPPostTest methodsFor: 'testing-posts' stamp: 'janko 7/26/2008 15:33'!
testPost2Empty
	"post entity with empty value"
	| post |
	post := self postEmpty.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = ''.! !

!HTTPPostTest methodsFor: 'testing-posts' stamp: 'janko 7/26/2008 15:33'!
testPost3Dashes
	"some ---- inside post data"
	| post |
	post := self postDashes.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = '----'.
	self assert: (post postDataStringAt: 'field2') = '- --'.! !

!HTTPPostTest methodsFor: 'testing-posts' stamp: 'janko 7/26/2008 15:33'!
testPost5UrlEncoded
	"just one entity"
	| post |
	post := self postUrlEncoded.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'home') = 'Cosby one'.
	self assert: (post postDataStringAt: 'favorite flavor') = 'flies'.! !

!HTTPPostTest methodsFor: 'testing-posts' stamp: 'janko 7/26/2008 15:33'!
testPostPreambleEpilogue
	"mime preamble before first part and epilogue at the end. See #postPreambleEpilogue"
	| post |
	post := self postPreambleEpilogue.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = 'main'.! !

!HTTPPostTest methodsFor: 'testing-posts' stamp: 'janko 7/26/2008 15:33'!
testPostRawEntity
	| requestStream post |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'POST /foobar HTTP/1.0';
		nextPutLine: 'Host: foo.com';
		nextPutLine: 'Content-Type: text/plain';
		nextPutLine: 'Content-Length: 12';
		crlf;
		nextPutLine: 'Hello, World'.
	post := HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents).
	self assert: post isPostDataEmpty.
	self assert: post entityBody = 'Hello, World'! !

!HTTPPostTest methodsFor: 'testing-posts' stamp: 'janko 7/26/2008 15:33'!
testPostUrlEncodedData
	| requestStream post |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'POST / HTTP/1.1';
		nextPutLine: 'Host: foo.com';
		nextPutLine: 'Content-Type: application/x-www-form-urlencoded';
		nextPutLine: 'Content-Length: 31';
		crlf;
		nextPutLine: 'address=+fs&product=&quantity=1'.
	post := HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents).
	self assert: (post postDataAt: 'address') value = ' fs'.
	self assert: (post postDataAt: 'product') value = ''.
	self assert: (post postDataAt: 'quantity') value = '1'! !


!HTTPPostTest methodsFor: 'testing-file posts' stamp: 'janko 7/26/2008 15:33'!
testPost40File
	| post |
	post := self postFile.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = 'main'.
	self assert: (post postDataStringAt: 'field2') = ''.
	self assert: (post postDataAt: 'field7') filename = 'event.ical'.
	self assert: ((post postDataStringAt: 'field7') readStream upTo: Character cr) = 'BEGIN:VCALENDAR'.
	self assert: (post postDataStringAt: 'field7') = self fileContents.
	self assert: (post postDataStringAt: 'attach') = 'Attach'.! !

!HTTPPostTest methodsFor: 'testing-file posts' stamp: 'janko 7/26/2008 15:33'!
testPost41FileStreamed
	| post stream |
	post := self postFile.
	stream := WriteStream on: ByteArray new.
	post postDataAt: 'field7' streamTo: stream.
	self assert: (post isPostDataStreamedAt: 'field7').
	self deny: post postData isParsed. "post data read from socket defered"
	self assert: (post postDataStringAt: 'id5273') = 'main'. 
	self assert: post postData isParsed.  "first access to post data trigger full read and parse"
	self assert: (post postDataAt: 'field7') filename = 'event.ical'.
	self assert: (stream contents asString readStream upTo: Character cr) = 'BEGIN:VCALENDAR'.
	self assert: stream contents asString = self fileContents.
	self assert: (post postDataStringAt: 'attach') = 'Attach'.! !

!HTTPPostTest methodsFor: 'testing-file posts' stamp: 'janko 7/26/2008 15:33'!
testPost42FileContentType
	| post |
	post := self postFile. "set the data to the post"
	self assert: post isPostDataEmpty not. "read the content of the stream"
	self assert: (post postDataAt: 'field7') contentType = 'application/octet-stream'.! !


TestCase subclass: #HTTPRequestTest
	instanceVariableNames: 'request'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!HTTPRequestTest methodsFor: 'requests-gets' stamp: ' 10/7/07 18:48'!
basicGet
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET / HTTP/1.1';
		nextPutLine: 'Host: foo.com';
		crlf.
	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPRequestTest methodsFor: 'requests-gets' stamp: ' 10/7/07 18:48'!
basicGetHTTP10
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET / HTTP/1.0';
		crlf.
	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPRequestTest methodsFor: 'requests-gets' stamp: ' 10/7/07 18:48'!
basicGetHTTP10Keepalive
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET / HTTP/1.0';
		nextPutLine: 'Connection: Keep-Alive';
		crlf.
	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPRequestTest methodsFor: 'requests-gets' stamp: ' 10/7/07 18:48'!
basicHead
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'HEAD / HTTP/1.1';
		nextPutLine: 'Host: foo.com';
		crlf.
	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPRequestTest methodsFor: 'requests-gets' stamp: ' 10/7/07 18:48'!
fullGet
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET /aaa/bbb/ccc.html?foo=bar&baz=quux HTTP/1.1';
		nextPutLine: 'Connection: Keep-Alive';
		nextPutLine: 'User-Agent: Mozilla/4.72 [en] (X11; I; Linux 2.3.51 i686)';
		nextPutLine: 'Host: foo.com:8888';
		nextPutLine: 'Referer: http://www.bar.com/takeMeThere.html';
		crlf.
	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPRequestTest methodsFor: 'requests-gets' stamp: 'mivsek 9/28/2007 22:56'!
getMultiValueHeader
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET /aaa/bbb/ccc.html?foo=bar&baz=quux HTTP/1.1';
		nextPutLine: 'Content-Type: multipart/form-data; boundary= --boundary';
		crlf.
	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!HTTPRequestTest methodsFor: 'requests-gets' stamp: ' 10/7/07 18:48'!
portedGet
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET / HTTP/1.1';
		nextPutLine: 'Host: foo.com:8888';
		crlf.
	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !


!HTTPRequestTest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
crlfOn: aStream 
	aStream
		nextPut: Character cr;
		nextPut: Character lf! !


!HTTPRequestTest methodsFor: 'testing-other' stamp: ' 14/4/07 23:10'!
test10ConnectionClose
	request := self basicGetHTTP10.
	self assert: request wantsConnectionClose! !

!HTTPRequestTest methodsFor: 'testing-other' stamp: ' 14/4/07 23:10'!
test10KeepAliveConnectionClose
	request := self basicGetHTTP10Keepalive.
	self deny: request wantsConnectionClose! !

!HTTPRequestTest methodsFor: 'testing-other' stamp: ' 14/4/07 23:10'!
testConnection
	request := self fullGet.
	self assert: request connection = 'Keep-Alive'! !

!HTTPRequestTest methodsFor: 'testing-other' stamp: ' 14/4/07 23:10'!
testHeaderAtIfPresent
	request := self basicGet.
	self assert: (request headers 
				fieldOfClass: HTTPIfRangeField
				ifPresent: [:header | header == (request headers fieldOfClass: HTTPIfRangeField)]
				ifAbsent: [true]).
	self assert: (request headers 
				fieldOfClass: HTTPHostField
				ifPresent: [:header | header == (request headers fieldOfClass: HTTPHostField)]
				ifAbsent: [false])! !

!HTTPRequestTest methodsFor: 'testing-other' stamp: ' 14/4/07 23:10'!
testNo11ConnectionClose
	request := self basicGet.
	self deny: request wantsConnectionClose! !

!HTTPRequestTest methodsFor: 'testing-other' stamp: ' 10/7/07 18:48'!
testNoEqualsQueries
	"The last assert here used to check that 'request queryAt: 'WSDL'' is nil, but a test for an empty string is more consistent with query argument formats."

	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET /test/typed.asmx?WSDL HTTP/1.1';
		nextPutLine: 'Host: foo.com:8888';
		crlf.
	request := HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents).
	self assert: (request includesQuery: 'WSDL').
	self assert: (request queryAt: 'WSDL') isEmpty! !

!HTTPRequestTest methodsFor: 'testing-other' stamp: ' 14/4/07 23:10'!
testReferer
	request := self fullGet.
	self 
		assert: request referer asString = 'http://www.bar.com/takeMeThere.html'! !

!HTTPRequestTest methodsFor: 'testing-other' stamp: 'mivsek 7/21/2007 22:46'!
testRequestWithCRButNoLF

"	| requestStream result |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutAll: 'GET / HTTP/1.1';
		cr.
	result := SpExceptionContext 
				for: [HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)]
				on: SpError
				do: [:ex | ex].
	self assert: result class == SwazooHTTPParseError.
	^self"! !

!HTTPRequestTest methodsFor: 'testing-other' stamp: ' 14/4/07 23:10'!
testUserAgent
	request := self fullGet.
	self 
		assert: request userAgent = 'Mozilla/4.72 [en] (X11; I; Linux 2.3.51 i686)'! !


!HTTPRequestTest methodsFor: 'testing-gets' stamp: 'mivsek 12/31/2007 13:50'!
testBasicGet
	request := self basicGet.
	self assert: request isGet.
	self assert: request isHttp11.
	self deny: request isHead.
	self deny: request isPost.
	self deny: request isPut! !

!HTTPRequestTest methodsFor: 'testing-gets' stamp: 'mivsek 12/31/2007 13:51'!
testBasicGetHTTP10
	request := self basicGetHTTP10.
	self assert: request isGet.
	self assert: request isHttp10.
	self deny: request isHead.
	self deny: request isPost.
	self deny: request isPut! !

!HTTPRequestTest methodsFor: 'testing-gets' stamp: ' 10/7/07 17:21'!
testBasicGetHost
	request := self basicGet.
	self assert: request host = 'foo.com'! !

!HTTPRequestTest methodsFor: 'testing-gets' stamp: ' 10/7/07 17:21'!
testBasicGetPort
	request := self basicGet.
	self assert: request port = 80! !

!HTTPRequestTest methodsFor: 'testing-gets' stamp: ' 10/7/07 17:21'!
testBasicHead
	request := self basicHead.
	self assert: request isHead.
	self deny: request isGet.
	self deny: request isPost.
	self deny: request isPut! !

!HTTPRequestTest methodsFor: 'testing-gets' stamp: 'janko 8/28/2013 18:42'!
testGetMultiValueHeader
	| header |
	request := self getMultiValueHeader.
	header := request headerAt: 'Content-Type' ifAbsent: [nil].
	self assert: header mediaType = 'multipart/form-data'.
	self assert: (header transferCodings at: 'boundary') = '--boundary'.
	self assert: header valuesAsString = 'multipart/form-data; boundary=--boundary'.

" 'Content-Type: multipart/form-data; boundary= --boundary'; "! !

!HTTPRequestTest methodsFor: 'testing-gets' stamp: ' 10/7/07 17:21'!
testPortedGetPort
	request := self portedGet.
	self assert: request port = 8888! !


TestCase subclass: #HTTPResponseTest
	instanceVariableNames: 'response'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!HTTPResponseTest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
crlf
	^String with: Character cr with: Character lf! !


!HTTPResponseTest methodsFor: 'testing' stamp: 'mivsek 7/19/2007 19:28'!
testInternalServerError
	| ws rs |
	response := HTTPResponse internalServerError.
	ws := SwazooStream on: String new.
	response printStatusOn: ws.
	rs := SwazooStream on: ws writeBuffer contents.
	self assert: rs nextLine = 'HTTP/1.1 500 Internal Server Error'! !

!HTTPResponseTest methodsFor: 'testing' stamp: 'mivsek 7/19/2007 19:28'!
testOK
	| ws rs |
	response := HTTPResponse ok.
	ws := SwazooStream on: String new.
	response printStatusOn: ws.
	rs := SwazooStream on: ws writeBuffer contents.
	self assert: rs nextLine = 'HTTP/1.1 200 OK'! !

!HTTPResponseTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testResponseTypes
	self assert: (HTTPResponse badRequest) isBadRequest.
	self assert: (HTTPResponse found) isFound.
	self assert: (HTTPResponse internalServerError) isInternalServerError.
	self assert: (HTTPResponse movedPermanently) isMovedPermanently.
	self assert: (HTTPResponse notFound) isNotFound.
	self assert: (HTTPResponse notImplemented) isNotImplemented.
	self assert: (HTTPResponse notModified) isNotModified.
	self assert: (HTTPResponse ok) isOk.
	self assert: (HTTPResponse redirectLink) isRedirectLink.
	self assert: (HTTPResponse seeOther) isSeeOther.! !


TestCase subclass: #HTTPServerTest
	instanceVariableNames: 'server stream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!HTTPServerTest methodsFor: 'running' stamp: 'JM 4/16/2007 22:52'!
setUp
	| socket |
	(Delay forMilliseconds: 100) wait.
	server := HTTPServer new.
	[server ip: 'localhost'; port: 8123.
	server start]
		fork.
	(Delay forMilliseconds: 100) wait.
" 	stream := (SocketAccessor newTCPclientToHost: 'localhost' port: 8123) 
				readAppendStream"
	socket := SpSocket connectToServerOnHost:  'localhost' port: 8123.
	stream := SwazooStream socket: socket ! !

!HTTPServerTest methodsFor: 'running' stamp: 'JM 4/16/2007 22:57'!
tearDown
	server stop.
	stream close.
	stream := nil.
	Delay forMilliseconds: 500.
! !


!HTTPServerTest methodsFor: 'tests' stamp: ' 14/4/07 23:10'!
testServing
	self assert: server isServing! !

!HTTPServerTest methodsFor: 'tests' stamp: ' 14/4/07 23:10'!
testStopServing
	server stop.
	self deny: server isServing! !


TestCase subclass: #HeaderFieldTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!HeaderFieldTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testCombine
	"Entity tags must be quoted strings - RFC 2616 3.11"

	| header1 header2 header3 |
	header1 := HeaderField fromLine: 'If-Match: "a"'.
	header2 := HeaderField fromLine: 'If-Match: "b","c"'.
	header3 := HeaderField fromLine: 'If-Match: "d"'.
	header1 combineWith: header2.
	self assert: header1 valuesAsString = '"a","b","c"'.
	header1 combineWith: header3.
	self assert: header1 valuesAsString = '"a","b","c","d"'! !

!HeaderFieldTest methodsFor: 'testing' stamp: 'mivsek 7/19/2007 19:28'!
testContentTypeMultiple
	"   HTTP/1.1 header field values can be folded onto multiple lines if the
   continuation line begins with a space or horizontal tab. All linear
   white space, including folding, has the same semantics as SP. A
   recipient MAY replace any linear white space with a single SP before
   interpreting the field value or forwarding the message downstream.

       LWS            = [CRLF] 1*( SP | HT )"

	| requestStream request field |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET / HTTP/1.1';
		nextPutLine: 'Host: 127.0.0.1';
		nextPutLine: 'Content-Type: text/html; ';
		nextPutLine: ' charset=iso-8859-1';
		crlf.
	request := HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents).
	field := request headers fieldNamed: 'content-type'.
	self assert: field name = 'Content-Type'.
	self assert: field mediaType = 'text/html'.
	self assert: (field transferCodings at: 'charset') = 'iso-8859-1'! !

!HeaderFieldTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testValues
	"Entity tags are held internally as simple strings.  Any necessary leading and trailing double quotes are added by the header fields as needed.  Note that it is OK to have a comma in an entity tag - see the second of the group of 3 tags below."

	| header |
	header := HeaderField fromLine: 'If-Match: "xyzzy" '.
	self assert: header name = 'If-Match'.
	self assert: header entityTags first = 'xyzzy'.
	header := HeaderField 
				fromLine: 'If-Match: "xyzzy", "r2d2,xxxx", "c3piozzzz" '.
	self assert: header name = 'If-Match'.
	self assert: header entityTags first = 'xyzzy'.
	self assert: (header entityTags at: 2) = 'r2d2,xxxx'.
	self assert: header entityTags last = 'c3piozzzz'! !


TestCase subclass: #HelloWorldResourceTest
	instanceVariableNames: 'hello'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!HelloWorldResourceTest methodsFor: 'running' stamp: 'JM 4/18/2007 18:00'!
setUp
	hello := HelloWorldResource uriPattern: 'hello.html'! !


!HelloWorldResourceTest methodsFor: 'testing'!
testResponse
	| request response |
	request := HTTPGet request: 'hello.html'.
	response := URIResolution resolveRequest: request startingAt: hello.
	self assert: response statusCode = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'hello.html'! !


TestCase subclass: #HomeResourceTest
	instanceVariableNames: 'resource'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!HomeResourceTest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
setUp
	resource := HomeResource uriPattern: '/' filePath: 'home'! !

!HomeResourceTest methodsFor: 'running' stamp: 'mivsek 8/16/2007 22:21'!
testRootFileFor
	| request |
	request := HTTPGet request: '/~someUser'.
	URIResolution new initializeRequest: request.
	self assert: (resource rootFileFor: request) asString 
				= (((SpFilename named: 'home') construct: 'someUser') construct: 'html') asString! !

!HomeResourceTest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
testValidateHomePath
	self assert: (resource validateHomePath: '~somebody').
	self assert: (resource validateHomePath: '~somebodyElse').
	self deny: (resource validateHomePath: 'someplace').
	self deny: (resource validateHomePath: 'some~body')! !


TestCase subclass: #RedirectionResourceTest
	instanceVariableNames: 'resource'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!RedirectionResourceTest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
setUp
	resource := RedirectionResource uriPattern: 'foo'
				targetUri: 'http://abc.def.com'! !


!RedirectionResourceTest methodsFor: 'testing'!
testGetResource
	| request response |
	request := HTTPGet request: 'foo'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 301.
	self assert: (response headers fieldNamed: 'Location') uri asString 
				= 'http://abc.def.com'.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'foo'! !


TestCase subclass: #ResourceTest
	instanceVariableNames: 'resource'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!ResourceTest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
basicGet: uri
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'GET ', uri, ' HTTP/1.1'.
	self crlfOn: ws.
	ws nextPutAll: 'Host: swazoo.org'.
	self crlfOn: ws.
	self crlfOn: ws.
	^HTTPRequest readFrom: (ReadStream on: ws contents)! !

!ResourceTest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
basicGetUri: uriString
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'GET ' , uriString , ' HTTP/1.1'.
	self crlfOn: ws.
	ws nextPutAll: 'Host: swazoo.org'.
	self crlfOn: ws.
	self crlfOn: ws.
	^HTTPRequest readFrom: (ReadStream on: ws contents)! !

!ResourceTest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
basicGetUri: uriString host: hostname port: port 
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'GET ' , uriString , ' HTTP/1.1'.
	self crlfOn: ws.
	ws nextPutAll: 'Host: ' , hostname.
	port notNil 
		ifTrue: 
			[ws
				nextPut: $:;
				print: port].
	self crlfOn: ws.
	self crlfOn: ws.
	^HTTPRequest readFrom: (ReadStream on: ws contents)! !

!ResourceTest methodsFor: 'private' stamp: ' 14/4/07 23:10'!
crlfOn: aStream 
	aStream
		nextPut: Character cr;
		nextPut: Character lf! !


!ResourceTest methodsFor: 'running' stamp: 'jm 2/8/2009 13:51'!
setUp
	resource := SwazooResource uriPattern: 'foo'! !


!ResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testEmptyURIPatternInvalid
	resource uriPattern: ''.
	self deny: resource isValidlyConfigured! !

!ResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testEnabledByDefault
	self assert: resource isEnabled! !

!ResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testNilURIPatternDoesNothing
	| pattern |
	pattern := resource uriPattern.
	resource uriPattern: nil.
	self assert: resource uriPattern = pattern! !

!ResourceTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testValidlyConfigured
	self assert: resource isValidlyConfigured! !


TestCase subclass: #SiteIdentifierTest
	instanceVariableNames: 'identifier'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SiteIdentifierTest methodsFor: 'running' stamp: ' 10/7/07 17:21'!
setUp
	identifier := SiteIdentifier 
				host: 'localhost'
				ip: '127.0.0.1'
				port: 80! !


!SiteIdentifierTest methodsFor: 'testing' stamp: ' 10/7/07 17:21'!
testCaseInsensitiveMatch
	| another |
	another := SiteIdentifier 
				host: 'lOCaLhOST'
				ip: '127.0.0.1'
				port: 80.
	self assert: (identifier match: another)! !

!SiteIdentifierTest methodsFor: 'testing' stamp: ' 10/7/07 17:21'!
testCurrentUrl
	self assert: identifier currentUrl = 'http://localhost'.
		identifier := SiteIdentifier 
				host: 'localhost'
				ip: '127.0.0.1'
				port: 81.
	self assert: identifier currentUrl = 'http://localhost:81'! !

!SiteIdentifierTest methodsFor: 'testing' stamp: ' 10/7/07 17:21'!
testHostMismatch
	| another |
	another := SiteIdentifier 
				host: 'thisIsMyMachine'
				ip: '127.0.0.1'
				port: 80.
	self deny: (identifier match: another)! !

!SiteIdentifierTest methodsFor: 'testing' stamp: ' 10/7/07 17:21'!
testIPMismatch
	| another |
	another := SiteIdentifier 
				host: 'localhost'
				ip: '127.0.0.2'
				port: 80.
	self deny: (identifier match: another)! !

!SiteIdentifierTest methodsFor: 'testing' stamp: ' 10/7/07 17:21'!
testMatch
	| another |
	another := SiteIdentifier 
				host: 'localhost'
				ip: '127.0.0.1'
				port: 80.
	self assert: (identifier match: another)! !

!SiteIdentifierTest methodsFor: 'testing' stamp: ' 10/7/07 17:21'!
testPortMismatch
	| another |
	another := SiteIdentifier 
				host: 'localhost'
				ip: '127.0.0.1'
				port: 81.
	self deny: (identifier match: another)! !


TestCase subclass: #SiteTest
	instanceVariableNames: 'site'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SiteTest methodsFor: 'running' stamp: ' 10/7/07 17:21'!
addSecondAlias
	site addAlias: (SiteIdentifier 
				host: 'swazoo2.org'
				ip: '127.0.0.2'
				port: 8202).! !

!SiteTest methodsFor: 'running' stamp: 'jm 2/8/2009 13:52'!
setUp
	super setUp.
	site := SwazooSite new.
	site addAlias: (SiteIdentifier 
				host: 'swazoo.org'
				ip: '127.0.0.1'
				port: 8200)! !


!SiteTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testCurrentUrl
	site currentUrl = 'http://swazoo.org:8200'.
	self addSecondAlias.
	site currentUrl = 'http://swazoo.org:8200'.! !

!SiteTest methodsFor: 'testing' stamp: 'jm 2/8/2009 13:52'!
testCurrentUrl80
	| aSite |
	aSite := SwazooSite new.
	aSite addAlias: (SiteIdentifier
			host: 'swazoo.org'
			ip: '127.0.0.1'
			port: 80).
	aSite currentUrl = 'http://swazoo.org'.
	aSite currentUrl = 'http://swazoo.org'! !


TestCase subclass: #SwazooBaseExtensionsTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SwazooBaseExtensionsTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testCharacterArrayTrimBlanks
	self 
		assert: (HTTPString trimBlanksFrom: '   a b c d e f g') = 'a b c d e f g'.
	self assert: (HTTPString trimBlanksFrom: 'no blanks') = 'no blanks'.
	self assert: (HTTPString trimBlanksFrom: ' leading') = 'leading'.
	self assert: (HTTPString trimBlanksFrom: 'trailing ') = 'trailing'.
	self assert: (HTTPString trimBlanksFrom: '') = ''.
	self 
		assert: (HTTPString 
				trimBlanksFrom: (String with: Character cr with: Character lf)) isEmpty! !

!SwazooBaseExtensionsTest methodsFor: 'testing' stamp: 'mivsek 8/16/2007 22:13'!
testFilenameEtag
	"The filename etag is a simple string and does not contain double quotes.  Header fields apply double quotes as necessary when writing themselves."

	| fn etag1 etag2 |
	fn := SpFilename named: 'etagTest'.
	[fn writeStream nextPut: $-; close. "create file"
	etag1 := fn etag.
	(Delay forSeconds: 1) wait.
	fn appendStream nextPut: $-; close. "modify file"
	etag2 := fn etag.

	self assert: (etag1 isKindOf: String).
	self assert: (etag2 isKindOf: String).
	self deny: etag1 = etag2] 
		ensure: [fn delete]! !

!SwazooBaseExtensionsTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testStringNewRandom
	| sizes strings |
	sizes := #(5 20 6127 2 100).
	strings := sizes collect: [:each |  HTTPString newRandomString: each].
	strings with: sizes do: [:string :size | self assert: string size = size]! !


Object subclass: #SwazooBenchmarks
	instanceVariableNames: 'server content'
	classVariableNames: 'Singleton'
	poolDictionaries: ''
	category: 'Swazoo-Tests'!
!SwazooBenchmarks commentStamp: '<historical>' prior: 0!
SwazooBenchmarks stores several benchmarks and performance routines

!


!SwazooBenchmarks methodsFor: 'accessing' stamp: ' 7/5/08 11:08'!
content
	"test content to be writen to the socket"
	content isNil ifTrue: [self initContent].
	^content! !

!SwazooBenchmarks methodsFor: 'accessing' stamp: ' 7/5/08 11:08'!
content: aByteArray
	content := aByteArray! !

!SwazooBenchmarks methodsFor: 'accessing' stamp: ' 7/5/08 11:08'!
server
	"TCP server loop"
	^server! !

!SwazooBenchmarks methodsFor: 'accessing' stamp: ' 7/5/08 11:08'!
server: aProcess
	"TCP server loop"
	server := aProcess! !


!SwazooBenchmarks methodsFor: 'initialize-release' stamp: 'janko 5/8/2008 01:09'!
contentSize
	^4! !

!SwazooBenchmarks methodsFor: 'initialize-release' stamp: ' 7/5/08 11:08'!
initContent
	| response ws |
	response := HTTPResponse ok.
	response entity: (ByteArray new: self contentSize withAll: 16r55).
	ws := SwazooStream on: String new.
	response writeTo: ws.
	content := ws writeBuffer contents.! !


!SwazooBenchmarks methodsFor: 'socket performance' stamp: 'janko 5/8/2008 13:58'!
serverLoop
	| socket clientSocket |
	socket := SpSocket newTCPSocket.
	socket
		setAddressReuse: true;
		bindSocketAddress: (SpIPAddress hostName: 'localhost' port: 9999).
	[	socket listenBackloggingUpTo: 50.
		[true] whileTrue: 
			[ 	clientSocket := socket accept.
				[ [true] whileTrue: 
					[clientSocket underlyingSocket waitForData.
					clientSocket read: 60. "HTTP request"
					clientSocket write: self content] ]
				on: Error "probably connection close by peer"
				do: [:ex | "nothing"]
			]
	] ensure: [clientSocket notNil ifTrue: [clientSocket close]. socket close]! !

!SwazooBenchmarks methodsFor: 'socket performance' stamp: ' 7/5/08 11:08'!
startSocketServer
	"SwazooBenchmarks singleton startSocketServer"
	"SwazooBenchmarks singleton stopSocketServer"
	"testing raw socket performance.
	it will start a server on localhost:9999 to receive a request 
      and respond with 10K response as drirectly as possible."

	self stopSocketServer. 
	self server: [self serverLoop] fork.! !

!SwazooBenchmarks methodsFor: 'socket performance' stamp: 'janko 5/7/2008 14:14'!
stopSocketServer
	"SwazooBenchmarks singleton stopSocketServer"
	self server notNil ifTrue: [self server terminate. self server: nil].
	self content: nil.
	(Delay forMilliseconds: 1000) wait.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooBenchmarks class
	instanceVariableNames: ''!

!SwazooBenchmarks class methodsFor: 'accessing' stamp: ' 7/5/08 11:08'!
singleton
	Singleton isNil ifTrue: [Singleton := self new].
	^Singleton! !


TestCase subclass: #SwazooBufferTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SwazooBufferTest methodsFor: 'testing-mime boundary' stamp: 'janko 7/26/2008 15:31'!
testBoundaryFull
	| boundary buffer |
	boundary := '--boundary--'.
	buffer := SwazooBuffer on: 'just--boundary--something'.  "full boundary"
	self assert: (buffer signsOfBoundary: boundary) = boundary size.! !

!SwazooBufferTest methodsFor: 'testing-mime boundary' stamp: 'janko 7/26/2008 15:31'!
testBoundaryMixed
	| boundary buffer |
	boundary := '--boundary--'.
	buffer := SwazooBuffer on: 'yes,--just--boundary--something'.  "partial, later full boundary"
	self assert: (buffer signsOfBoundary: boundary) = boundary size.! !

!SwazooBufferTest methodsFor: 'testing-mime boundary' stamp: 'janko 7/26/2008 15:31'!
testBoundaryOnEdge
	"part of boundary at the end of this buffer, remaining probably in the next"
	| boundary buffer |
	boundary := '--boundary--'.
	buffer := SwazooBuffer on: 'just something-'.  "just first char of boundary"
	self assert: (buffer signsOfBoundary: boundary) = 1.
	buffer := SwazooBuffer on: 'just something--'.  "two chars"
	self assert: (buffer signsOfBoundary: boundary) = 2.
	buffer := SwazooBuffer on: 'just something--bound'.  "half"
	self assert: (buffer signsOfBoundary: boundary) = 7.
	buffer := SwazooBuffer on: 'just something--boundary--'.  "full boundary at the edge"
	self assert: (buffer signsOfBoundary: boundary) = boundary size.! !

!SwazooBufferTest methodsFor: 'testing-mime boundary' stamp: 'janko 7/26/2008 15:32'!
testBoundaryOnEdgeMixed
	"signs of boundary in the middle part at the end of this buffer, remaining probably in the next"
	| boundary buffer |
	boundary := '--boundary--'.
	buffer := SwazooBuffer on: 'just-something-'.  "sign in the middle, one char at the end"
	self assert: (buffer signsOfBoundary: boundary) = 1.
	buffer := SwazooBuffer on: 'just-something--'.  "two chars"
	self assert: (buffer signsOfBoundary: boundary) = 2.
	buffer := SwazooBuffer on: 'just-so--mething--bound'.  "even more mixed case"
	self assert: (buffer signsOfBoundary: boundary) = 7.! !

!SwazooBufferTest methodsFor: 'testing-mime boundary' stamp: 'janko 7/26/2008 15:32'!
testBoundarySimple
	| boundary buffer |
	boundary := '--boundary--'.
	buffer := SwazooBuffer on: 'just something'.  "no boundary"
	self assert: (buffer signsOfBoundary: boundary) = 0.
	buffer := SwazooBuffer on: 'just-something'.  "sign of boundary"
	self assert: (buffer signsOfBoundary: boundary) = 0.
	buffer := SwazooBuffer on: 'just--something'.  "more sign of boundary"
	self assert: (buffer signsOfBoundary: boundary) = 0.
	buffer := SwazooBuffer on: 'just--boundary--something'.  "full boundary"
	self assert: (buffer signsOfBoundary: boundary) = boundary size.! !

!SwazooBufferTest methodsFor: 'testing-mime boundary' stamp: 'janko 7/26/2008 15:32'!
testIndexOfBoundary
	"index of start of boundary in buffer, both full or partial at the edge/end of buffer"
	| boundary buffer |
	boundary := '--boundary--'.
	buffer := SwazooBuffer on: 'just something'.  "no boundary"
	self assert: (buffer indexOfBoundary: boundary) = 0.
	buffer := SwazooBuffer on: 'just--boundary--something-'.  "full boundary"
	self assert: (buffer indexOfBoundary: boundary) = 5.
	buffer := SwazooBuffer on: 'just something--boun'.  "partial boundary at the edge"
	self assert: (buffer indexOfBoundary: boundary) = 15.
	buffer := SwazooBuffer on: 'just something-'.  "partial boundary, one char only"
	self assert: (buffer indexOfBoundary: boundary) = 15.
	buffer := SwazooBuffer on: 'just-som--ething--boun'.  "mixed case with partial at the edge"
	self assert: (buffer indexOfBoundary: boundary) = 17.! !


TestCase subclass: #SwazooCacheControlTest
	instanceVariableNames: 'resource cacheTarget request cacheControl'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SwazooCacheControlTest methodsFor: 'running' stamp: 'mivsek 8/16/2007 21:47'!
setUp
	| directory firstFile ws |
	directory := SpFilename named: 'fResTest'.
	directory exists ifFalse: [directory makeDirectory].
	firstFile := directory construct: 'abc.html'.
	ws := firstFile writeStream.
	[ws nextPutAll: 'hello'] ensure: [ws close].
	resource := FileResource uriPattern: 'foo' filePath: 'fResTest'.
	request := HTTPGet request: 'foo/abc.html'.
	URIResolution resolveRequest: request startingAt: resource.
	cacheControl := SwazooCacheControl new request: request
				cacheTarget: (cacheTarget := resource fileFor: request)! !

!SwazooCacheControlTest methodsFor: 'running' stamp: 'mivsek 8/16/2007 22:07'!
tearDown
	((SpFilename named: 'fResTest') construct: 'abc.html') delete.
	(SpFilename named: 'fResTest') delete! !


!SwazooCacheControlTest methodsFor: 'testing' stamp: 'JM 4/18/2007 16:39'!
testIfModifiedSinceModified
	| response timestampInThePast |
	request := HTTPGet request: 'foo/abc.html'.
	timestampInThePast := SpTimestamp fromDate: (Date today subtractDays: 1)
				andTime: Time now.
	request headers addField: (HTTPIfModifiedSinceField new 
				valueFrom: timestampInThePast asRFC1123String).
	cacheControl := SwazooCacheControl new request: request
				cacheTarget: cacheTarget.
	self assert: cacheControl isNotModified not.
	self assert: cacheControl isIfModifiedSince.
	response := HTTPResponse ok.
	cacheControl addResponseHeaders: response.
	self 
		assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
				= cacheTarget lastModified! !

!SwazooCacheControlTest methodsFor: 'testing' stamp: 'JM 4/18/2007 16:40'!
testIfModifiedSinceNot
	| response |
	request headers addField: (HTTPIfModifiedSinceField new 
				valueFrom: cacheTarget lastModified asRFC1123String).
	self assert: cacheControl isNotModified.
	self assert: cacheControl isIfModifiedSince not.
	response := HTTPResponse notModified.
	cacheControl addResponseHeaders: response.
	self 
		assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
				= cacheTarget lastModified! !

!SwazooCacheControlTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testIfNoneMatchHeaderMatch
	"same etag"

	| response |
	request headers addField: (HTTPIfNoneMatchField new addEntityTag: cacheTarget etag).
	self assert: cacheControl isNotModified.
	self deny: cacheControl isIfNoneMatch.

	"do NOT include last-modified"
	response := HTTPResponse notModified.
	cacheControl addResponseHeaders: response.
	self assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified' ifNone: [nil])  isNil! !

!SwazooCacheControlTest methodsFor: 'testing' stamp: 'JM 4/18/2007 16:40'!
testIfNoneMatchHeaderNone
	"same etag"

	| response |
	request := HTTPGet request: 'foo/abc.html'.
	request headers addField: (HTTPIfNoneMatchField new valueFrom: 'blah').
	cacheControl := SwazooCacheControl new request: request
				cacheTarget: cacheTarget.
	self assert: cacheControl isNotModified not.
	self assert: cacheControl isIfNoneMatch.
	response := HTTPResponse ok.
	cacheControl addResponseHeaders: response.
	self 
		assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
				= cacheTarget lastModified! !

!SwazooCacheControlTest methodsFor: 'testing' stamp: 'JM 4/18/2007 16:42'!
testNoHeaders
	| response |
	self assert: cacheControl isNotModified not.
	self assert: cacheControl isIfNoneMatch.
	self assert: cacheControl isIfModifiedSince.

	"add both"
	response := HTTPResponse ok.
	cacheControl addResponseHeaders: response.
	self 
		assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
				= cacheTarget lastModified! !


TestCase subclass: #SwazooCompilerTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SwazooCompilerTest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
testEvaluate
	self assert: (SwazooCompiler evaluate: '1 + 2 * 3') = 9! !

!SwazooCompilerTest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
testEvaluateReceiver
	self assert: (SwazooCompiler evaluate: 'self + 2 * 3' receiver: 1) = 9! !


TestCase subclass: #SwazooConfigurationTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SwazooConfigurationTest methodsFor: 'testing' stamp: 'jm 2/8/2009 13:56'!
testCompositeResourceSite
	| rs site composite howdy duh hithere |
	rs := ReadStream 
				on: '<Site>
 <CompositeResource uriPattern: ''/''>
  <HelloWorldResource uriPattern: ''howdy''>
  <CompositeResource uriPattern: ''duh''>
   <HelloWorldResource uriPattern: ''hithere''>
  </CompositeResource>
 </CompositeResource>
</Site>'.
	site := SwazooSite new readFrom: rs.
	self assert: site children size = 1.
	composite := site children first.
	self assert: composite class == CompositeResource.
	self assert: composite uriPattern = '/'.
	self assert: composite children size = 2.
	self assert: composite parent == site.
	howdy := composite children first.
	self assert: (howdy class == HelloWorldResource).
	self assert: howdy uriPattern = 'howdy'.
	self assert: howdy parent == composite.
	duh := composite children last.
	self assert: duh children size = 1.
	self assert: duh class == CompositeResource.
	self assert: duh uriPattern = 'duh'.
	self assert: duh parent == composite.
	hithere := duh children first.
	self assert: hithere class == HelloWorldResource.
	self assert: hithere uriPattern = 'hithere'.
	self assert: hithere parent == duh.! !

!SwazooConfigurationTest methodsFor: 'testing'!
testEmptySite
	| rs site alias |
	rs := ReadStream 
				on: '<Site>
 <SiteIdentifier host: ''swazoo.org'' ip: ''192.168.1.66'' port: 80>
</Site>'.
	site := SwazooSite new readFrom: rs.
	self assert: site aliases size = 1.
	self assert: site currentUrl = 'http://swazoo.org/'.
	alias := site aliases first.
	self assert: alias host = 'swazoo.org'.
	self assert: alias ip = '192.168.1.66'.
	self assert: alias port = 80! !

!SwazooConfigurationTest methodsFor: 'testing'!
testFileResourceSite
	| rs site resource |
	rs := ReadStream 
				on: '<Site>
<SiteIdentifier host: ''swazoo.org'' ip: ''192.168.1.66'' port: 80>
 <FileResource uriPattern: ''/'' filePath: ''files''>
</Site>'.
	site := SwazooSite new readFrom: rs.
	self assert: site children size = 1.
	resource := site children first.
	self assert: resource class == FileResource.
	self assert: resource uriPattern = '/'.
	self assert: resource filePath = 'files'.
	self assert: resource parent == site.
	self assert: resource currentUrl = 'http://swazoo.org/'.! !

!SwazooConfigurationTest methodsFor: 'testing' stamp: 'jm 2/8/2009 13:53'!
testMultipleResourcesSite
	| rs site resource1 resource2 |
	rs := ReadStream 
				on: '<Site>
 <HelloWorldResource uriPattern: ''/''>
 <HelloWorldResource uriPattern: ''/''>
</Site>'.
	site := SwazooSite new readFrom: rs.
	self assert: site children size = 2.
	resource1 := site children first.
	self assert: (resource1 class == HelloWorldResource).
	self assert: resource1 uriPattern = '/'.
	resource2 := site children last.
	self assert: resource2 class == HelloWorldResource.
	self assert: resource2 uriPattern = '/'! !

!SwazooConfigurationTest methodsFor: 'testing'!
testMultipleSites
	| rs sites site alias1 alias2 |
	rs := ReadStream 
				on: '<Site>
 <SiteIdentifier host: ''swazoo.org'' ip: ''192.168.1.66'' port: 80>
 <SiteIdentifier host: ''swazoo.org'' ip: ''192.168.1.66'' port: 81>
</Site>
<Site>
</Site>'.
	sites := SwazooServer readSitesFrom: rs.
	self assert: sites size = 2.
	site := sites first.
	self assert: site aliases size = 2.
	alias1 := site aliases first.
	self assert: alias1 host = 'swazoo.org'.
	self assert: alias1 ip = '192.168.1.66'.
	self assert: alias1 port = 80.
	alias2 := site aliases last.
	self assert: alias2 host = 'swazoo.org'.
	self assert: alias2 ip = '192.168.1.66'.
	self assert: alias2 port = 81! !

!SwazooConfigurationTest methodsFor: 'testing'!
testSingleResourceSite
	| rs site resource |
	rs := ReadStream on: '<Site>
<SiteIdentifier host: ''swazoo.org'' ip: ''192.168.1.66'' port: 80>
 <HelloWorldResource uriPattern: ''/''>
</Site>'.
	site := SwazooSite new readFrom: rs.
	self assert: site children size = 1.
	resource := site children first.
	self assert: resource class == HelloWorldResource.
	self assert: resource uriPattern = '/'.
	self assert: resource parent == site.
	self assert: resource currentUrl = 'http://swazoo.org/'.! !

!SwazooConfigurationTest methodsFor: 'testing' stamp: 'jm 2/8/2009 13:54'!
testSiteTag
	| rs config tag |
	rs := ReadStream on: '  <Site>  

</Site>   '.
	config := SwazooSite new.
	tag := config nextTagFrom: rs.
	self assert: tag = 'Site'.
	tag := config nextTagFrom: rs.
	self assert: tag = '/Site'.
	self assert: (config nextTagFrom: rs) isNil! !


TestCase subclass: #SwazooServerTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SwazooServerTest methodsFor: 'support' stamp: 'lr 12/4/2009 15:29'!
removeTestSiteIfAny
	
	| site |
	site := SwazooServer siteNamed: self testSiteName.
	site notNil ifTrue: [SwazooServer singleton removeSite: site]! !

!SwazooServerTest methodsFor: 'support' stamp: ' 8/2/09 22:22'!
testSiteName
	
	^'aaabbcc987'! !


!SwazooServerTest methodsFor: 'testing' stamp: 'lr 12/4/2009 15:29'!
testAccessingSite
	
	| site |
	self removeTestSiteIfAny.
	site := (SwazooSite new)
		name: self testSiteName;
		host: 'test.org' ip: 'localhost' port: 8543.
	[SwazooServer singleton addSite: site.
	self assert: (SwazooServer siteNamed: self testSiteName) notNil.
	site := SwazooServer siteNamed: self testSiteName.
	self assert: site name = self testSiteName.
	self assert: (SwazooServer siteHostnamed: 'test.org') notNil.
	site := SwazooServer siteHostnamed: 'test.org'.
	self assert: site host = 'test.org']
		ensure: [SwazooServer singleton removeSite: site]! !

!SwazooServerTest methodsFor: 'testing' stamp: 'lr 12/4/2009 15:29'!
testStartingOnAPort
	"and all ip interfaces, any host"
	
	| site server nrServers |
	server := SwazooServer singleton.
	nrServers := server servers size.
	[site := server startOn: 4924.
	self assert: site isServing.
	self assert: server servers size = (nrServers + 1).
	server stopOn: 4924.
	self assert: site isServing not.
	self assert: server servers size = nrServers]
		ensure:
			[site stop.
			server removeSite: site]! !

!SwazooServerTest methodsFor: 'testing' stamp: 'lr 12/4/2009 15:29'!
testStartingOnTwoPorts
	"and all ip interfaces, any host"
	
	| server nrServers site1 site2 |
	server := SwazooServer singleton.
	nrServers := server servers size.
	[site1 := server startOn: 4924.
	site2 := server startOn: 4925.
	self assert: site1 isServing.
	self assert: site2 isServing.
	self assert: server servers size = (nrServers + 2).
	server stopOn: 4924.
	server stopOn: 4925.
	self assert: site1 isServing not.
	self assert: site2 isServing not.
	self assert: server servers size = nrServers]
		ensure:
			[site1 stop.
			site2 stop.
			server
				removeSite: site1;
				removeSite: site2]! !

!SwazooServerTest methodsFor: 'testing' stamp: 'lr 12/4/2009 15:29'!
testStartingSite
	
	| site server nrServers |
	self removeTestSiteIfAny.
	server := SwazooServer singleton.
	nrServers := server servers size.
	site := (SwazooSite new)
		name: self testSiteName;
		host: 'test.org' ip: 'localhost' port: 8765.
	[server addSite: site.
	self assert: site isServing not.
	SwazooServer startSite: self testSiteName.
	self assert: server servers size = (nrServers + 1).
	self assert: site isServing.
	SwazooServer stopSite: self testSiteName.
	self assert: site isServing not.
	self assert: server servers size = nrServers]
		ensure:
			[site stop.
			server removeSite: site]! !


!SwazooServerTest methodsFor: 'testing-adding sites' stamp: 'lr 12/4/2009 15:29'!
testAddingAllInterfacesSite
	"site to listen on all IP interfaces but on specified port"
	
	| site server |
	self removeTestSiteIfAny.
	server := SwazooServer singleton.
	self assert: (server siteNamed: self testSiteName) isNil.
	site := (SwazooSite new)
		name: self testSiteName;
		host: '*' ip: '*' port: 7261.
	[server addSite: site.
	self assert: (server siteNamed: self testSiteName) notNil]
		ensure: [server removeSite: site]! !

!SwazooServerTest methodsFor: 'testing-adding sites' stamp: 'lr 12/4/2009 15:29'!
testAddingSite
	
	| site server nrSites |
	self removeTestSiteIfAny.
	server := SwazooServer singleton.
	nrSites := server sites size.
	self assert: (server siteNamed: self testSiteName) isNil.
	self assert: (server siteHostnamed: self testSiteName) isNil.
	site := (SwazooSite new)
		name: self testSiteName;
		host: 'test.org' ip: 'localhost' port: 5798.
	server addSite: site.
	self assert: (server siteNamed: self testSiteName) notNil.
	self assert: (server siteHostnamed: 'test.org') notNil.
	server removeSite: site.
	self assert: server sites size = nrSites! !

!SwazooServerTest methodsFor: 'testing-adding sites' stamp: 'lr 12/4/2009 15:29'!
testAllInterfacesTwoPortSites
	"two sites can run on all IP interfaces and different port"
	
	| server site1 site2 |
	server := SwazooServer singleton.
	site1 := (SwazooSite new)
		name: 'allInterfaces1';
		host: '*' ip: '*' port: 7261.
	site2 := (SwazooSite new)
		name: 'allInterfaces2';
		host: '*' ip: '*' port: 7262.
	[server addSite: site1.
	self
		shouldnt: [server addSite: site2]
		raise: Error]
		ensure:
			[server
				removeSite: site1;
				removeSite: site2]! !

!SwazooServerTest methodsFor: 'testing-adding sites' stamp: 'lr 12/4/2009 15:29'!
testAllStarsThenExactOnOtherPort
	
	| server site1 site2 |
	server := SwazooServer singleton.
	site1 := (SwazooSite new)
		name: 'allstar232';
		host: '*' ip: '*' port: 7261.
	site2 := (SwazooSite new)
		name: 'exactdfdf';
		host: 'localhost' ip: 'localhost' port: 7262.
	[server addSite: site1.
	self
		shouldnt:
			[server
				addSite: site2;
				removeSite: site2]
		raise: Error] ensure: [server removeSite: site1]! !

!SwazooServerTest methodsFor: 'testing-adding sites' stamp: 'lr 12/4/2009 15:29'!
testDuplicateAllInterfacesSite
	"two sites cannot run on all IP interfaces and same port"
	
	| server site1 site2 |
	server := SwazooServer singleton.
	site1 := (SwazooSite new)
		name: 'allInterfaces1';
		host: '*' ip: '*' port: 7261.
	site2 := (SwazooSite new)
		name: 'allInterfaces2';
		host: '*' ip: '*' port: 7261.
	[server addSite: site1.
	self
		should: [server addSite: site2]
		raise: Error] ensure: [server removeSite: site1]! !

!SwazooServerTest methodsFor: 'testing-adding sites' stamp: 'lr 12/4/2009 15:29'!
testDuplicateNames
	
	| site server |
	self removeTestSiteIfAny.
	server := SwazooServer singleton.
	site := (SwazooSite new)
		name: self testSiteName;
		host: 'test.org' ip: 'localhost' port: 6376.
	[server addSite: site.
	self
		should: [site name: self testSiteName]
		raise: Error.
	self
		shouldnt: [site host: 'test.org']
		raise: Error.
	self
		should:
			[(SwazooSite new)
				name: self testSiteName;
				host: 'test.org' ip: 'localhost' port: 6376]
		raise: Error] ensure: [server removeSite: site]! !


TestCase subclass: #SwazooSocketTest
	instanceVariableNames: 'input output'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SwazooSocketTest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
setUp
	| pair |
	pair := SwazooSocket connectedPair.
	input := pair first.
	output := pair last! !

!SwazooSocketTest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
tearDown
	input close.
	output close! !


!SwazooSocketTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testConnectedPair
	(Array with: input with: output) 
		do: [:each | self assert: (each isKindOf: SwazooSocket)]! !

!SwazooSocketTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testNetworkConnection
	| server sem |
	input close.
	output close.
	sem := Semaphore new.
	
	[server := SwazooSocket serverOnIP: '127.0.0.1' port: 65423.
	server listenFor: 50.
	
	[input := server accept.
	sem signal] fork.
	output := SwazooSocket connectTo: 'localhost' port: 65423.
	sem wait.
	self testReadWrite] 
			ensure: [server close]! !

!SwazooSocketTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testPartialRead
	| bytes |
	bytes := ByteArray withAll: #(5 4 3).
	self assert: (input write: bytes) = 3.
	self assert: (output read: 5) = bytes! !

!SwazooSocketTest methodsFor: 'testing' stamp: 'janko 7/26/2008 14:59'!
testReadTimeout
	"on Squeak doesn't come back, and also we don't need it for now !!"
"	input write: (ByteArray withAll: #(1 2 3)).
	self assert: (output read: 3 timeout: 40) = (ByteArray withAll: #(1 2 3)).
	self assert: (output read: 3 timeout: 40) = ByteArray new
"! !

!SwazooSocketTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testReadWrite
	| bytes |
	bytes := ByteArray withAll: #(1 2 3 4 5).
	self assert: (input write: bytes) = 5.
	self assert: (output read: 5) = bytes.
	bytes := ByteArray with: 4.
	self assert: (input write: bytes) = 1.
	self assert: (output read: 1) = bytes! !


TestCase subclass: #SwazooStreamTest
	instanceVariableNames: 'input output'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SwazooStreamTest methodsFor: 'running' stamp: 'mivsek 7/19/2007 19:26'!
crlfOn: aSwazooStream
	aSwazooStream
		nextPut: Character cr;
		nextPut: Character lf! !

!SwazooStreamTest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
setUp
	| pair |
	pair := SwazooStream connectedPair.
	input := pair first.
	output := pair last! !

!SwazooStreamTest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
tearDown
	input close.
	output close! !


!SwazooStreamTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testConnectedPair
	(Array with: input with: output) 
		do: [:each | self assert: (each isKindOf: SwazooStream)]! !

!SwazooStreamTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testErrorOnInputClose
	self should: 
			[input close.
			output next]
		raise: Error! !

!SwazooStreamTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testNextPut
	#($A $M $Y $b $r $z) do: 
			[:each | 
			self assert: (input nextPut: each) = each. 
			input flush.
			self assert: output next = each]! !

!SwazooStreamTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testNextPutAll
	#('123' 'abc' 'swazoo') do: 
			[:each | 
			self assert: (input nextPutAll: each) = each. 
			input flush.
			self assert: (output next: each size) = each]! !

!SwazooStreamTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testNextPutByte
	| bytes |
	bytes := ByteArray 
				with: 6
				with: 5
				with: 0
				with: 2.
	bytes do: 
			[:each | 
			self assert: (input nextPutByte: each) = each. 
			input flush.
			self assert: output nextByte = each]! !

!SwazooStreamTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testNextPutBytes
	| bytes1 bytes2 bytes3 |
	bytes1 := ByteArray withAll: #(1 2 3 4).
	bytes2 := ByteArray withAll: #(5 4 3 2 1).
	bytes3 := ByteArray withAll: #(1 1 2 3 5).
	(Array 
		with: bytes1
		with: bytes2
		with: bytes3) do: 
				[:each | 
				self assert: (input nextPutBytes: each) = each.
				input flush.
				self assert: (output nextBytes: each size) = each]! !

!SwazooStreamTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testPeek
	#($K $J $D $j $m $z) do: 
			[:each | 
			input nextPut: each.
			input flush.
			self assert: output peek = each.
			output next]! !

!SwazooStreamTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testPeekByte
	| bytes |
	bytes := ByteArray withAll: #(5 2 8 4 11 231).
	bytes do: 
			[:each | 
			input nextPutByte: each.
			input flush.
			self assert: output peekByte = each.
			output nextByte]! !


!SwazooStreamTest methodsFor: 'testing-lines' stamp: 'mivsek 7/19/2007 19:27'!
testLinesWithDoubleCRLF
	| ws rs comparisonString |
	comparisonString := 'abcd'.
	ws := SwazooStream on: String new.
	ws nextPutAll: comparisonString.
	self crlfOn: ws.
	self crlfOn: ws.
	rs := SwazooStream on: ws writeBuffer contents.
	self assert: rs nextLine = comparisonString.
	self assert: rs nextLine = ''! !

!SwazooStreamTest methodsFor: 'testing-lines' stamp: 'mivsek 7/19/2007 19:27'!
testSingleLineWithCR
	| ws rs comparisonString errored |
	comparisonString := 'abcd' , (String with: Character cr) , 'efg'.
	ws := SwazooStream on: String new.
	ws nextPutAll: comparisonString.
	ws nextPut: Character cr.
	rs := SwazooStream on: ws writeBuffer contents.
	errored := false.
	SpExceptionContext 
		for: [rs nextLine]
		on: SpError
		do: [:ex | errored := true].
	self assert: errored! !

!SwazooStreamTest methodsFor: 'testing-lines' stamp: 'mivsek 7/19/2007 19:27'!
testSingleLineWithCRLF
	| ws rs comparisonString |
	comparisonString := 'abcd'.
	ws := SwazooStream on: String new.
	ws nextPutAll: comparisonString.
	self crlfOn: ws.
	rs := SwazooStream on: ws writeBuffer contents.
	self assert: rs nextLine = comparisonString! !


TestCase subclass: #SwazooURITest
	instanceVariableNames: 'fooURI barURI queryURI'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!SwazooURITest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
setUp
	fooURI := SwazooURI fromString: 'www.foo.com/index.html'.
	queryURI := SwazooURI fromString: 'www.foo.com/index.html?foo=1&bar=hi'.
	barURI := SwazooURI fromString: 'www.bar.com:8080/files/'! !

!SwazooURITest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
testHostname
	self assert: fooURI hostname = 'www.foo.com'.
	self assert: queryURI hostname = 'www.foo.com'.
	self assert: barURI hostname = 'www.bar.com'! !

!SwazooURITest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
testIdentifier
	self assert: fooURI identifier = '/index.html'.
	self assert: queryURI identifier = '/index.html'.
	self assert: barURI identifier = '/files/'! !

!SwazooURITest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
testIdentifierPath
	self assert: fooURI identifierPath 
				= (OrderedCollection with: '/' with: 'index.html').
	self assert: queryURI identifierPath 
				= (OrderedCollection with: '/' with: 'index.html').
	self 
		assert: barURI identifierPath = (OrderedCollection with: '/' with: 'files')! !

!SwazooURITest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
testIsDirectory
	self deny: fooURI isDirectory.
	self deny: queryURI isDirectory.
	self assert: barURI isDirectory! !

!SwazooURITest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
testPort
	self assert: fooURI port = 80.
	self assert: queryURI port = 80.
	self assert: barURI port = 8080! !

!SwazooURITest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
testQueries
	self deny: (queryURI includesQuery: 'hi').
	self assert: (queryURI includesQuery: 'foo').
	self assert: (queryURI includesQuery: 'bar').
	self assert: (queryURI queryAt: 'foo') = '1'.
	self assert: (queryURI queryAt: 'bar') = 'hi'! !

!SwazooURITest methodsFor: 'running' stamp: ' 14/4/07 23:10'!
testValue
	self assert: fooURI value = 'http://www.foo.com/index.html'.
	self assert: queryURI value = 'http://www.foo.com/index.html?foo=1&bar=hi'.
	self assert: barURI value = 'http://www.bar.com:8080/files/'! !


Object subclass: #TestPseudoSocket
	instanceVariableNames: 'byteStreamToServer byteStreamFromServer clientWaitSemaphore serverWaitSemaphore ipAddress'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!
!TestPseudoSocket commentStamp: '<historical>' prior: 0!
TestPseudoSocket is a drop in replacement for a SwazooSocket that can be used during testing to feed bytes into a running SwazooHTTPServer and grab the responses without having to start a real socket pair.

So, to the HTTP server it must look like a server socket.  To the tester it must look like a write stream (to send bytes to the HTTP server) and a read stream (to read the HTTP responses).!


!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
acceptRetryingIfTransientErrors
	"^another TestSocketThing
	The sender expects me to block until a request comes in 'over the socket'.  What I really do is wait for someone to ask me to 'send in' a Byte array and then I return myself.  Note that I will only handle one request at a time!!"

	self serverWaitSemaphore wait.
	^self! !

!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
bindSocketAddress: anOSkIPAddress 
	"^self
This is a no-op for me."

	ipAddress := anOSkIPAddress.
	^self! !

!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
close
	"^self
The server has finished with us at this point, so we signal the semaphore to give the client end chance to grab the response."

	self clientWaitSemaphore signal.
	^self! !

!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
flush
	^self! !

!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
getPeerName
	^ipAddress! !

!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
getSocketName
	^ipAddress! !

!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
isActive
	"^self
I am pretending to be a socket, and the sender wants to know if I am active.  Of course I am!!."

	^true! !

!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
listenBackloggingUpTo: anInteger 
	"^self
This is a no-op for me."

	^self! !

!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
listenFor: anInteger 
	"^self
This is a no-op for now."

	^self! !

!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
setAddressReuse: aBoolean 
	"^self
This is a no-op for me."

	^self! !

!TestPseudoSocket methodsFor: 'socket stuff' stamp: ' 14/4/07 23:10'!
stream
	"^self
I have to pretend to be a socket stream too."

	^self! !


!TestPseudoSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
byteStreamFromServer
	^byteStreamFromServer! !

!TestPseudoSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
byteStreamFromServer: aByteStream 
	byteStreamFromServer := aByteStream.
	^self! !

!TestPseudoSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
byteStreamToServer
	^byteStreamToServer! !

!TestPseudoSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
byteStreamToServer: aByteStream 
	byteStreamToServer := aByteStream.
	^self! !

!TestPseudoSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
clientWaitSemaphore
	"^a Semaphore
I return the semaphore I use to control 'client' activity."

	clientWaitSemaphore isNil ifTrue: [clientWaitSemaphore := Semaphore new].
	^clientWaitSemaphore! !

!TestPseudoSocket methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
serverWaitSemaphore
	"^a Semaphore
I return the semaphore I use to control 'server' activity."

	serverWaitSemaphore isNil ifTrue: [serverWaitSemaphore := Semaphore new].
	^serverWaitSemaphore! !


!TestPseudoSocket methodsFor: 'stream-toServer' stamp: ' 14/4/07 23:10'!
next
	^self byteStreamToServer next! !

!TestPseudoSocket methodsFor: 'stream-toServer' stamp: ' 14/4/07 23:10'!
peek
	"^a Character
It seems that the HTTP server is expecting Characters not Bytes - this will have to change."

	^byteStreamToServer isNil 
		ifTrue: [nil]
		ifFalse: [self byteStreamToServer peek asCharacter]! !

!TestPseudoSocket methodsFor: 'stream-toServer' stamp: ' 14/4/07 23:10'!
read: integerNumberOfBytes 
	"^a ByteArray
I read the next numberOfBytes from my underlying stream."

	^byteStreamToServer isNil 
		ifTrue: [ByteArray new]
		ifFalse: [self byteStreamToServer nextAvailable: integerNumberOfBytes]! !

!TestPseudoSocket methodsFor: 'stream-toServer' stamp: ' 14/4/07 23:10'!
socket
	"^self
I am being asked this as if I am a socket stream.  I return myself because I'm pretending to be both the socket and the socket stream."

	^self! !

!TestPseudoSocket methodsFor: 'stream-toServer' stamp: ' 14/4/07 23:10'!
upTo: aCharacter 
	"a ByteString
For some reason, we have to look for a character in a ByteStream - this is a Swazoo thing."

	^(self byteStreamToServer upTo: aCharacter asInteger) asByteString! !


!TestPseudoSocket methodsFor: 'stream-fromServer' stamp: ' 14/4/07 23:10'!
nextPut: aCharacter 
	self byteStreamFromServer nextPut: aCharacter asInteger! !

!TestPseudoSocket methodsFor: 'stream-fromServer' stamp: ' 14/4/07 23:10'!
nextPutAll: aCollection 
	"^self
At present it seems that aCollection will always be a string of chacters."

	^self byteStreamFromServer nextPutAll: aCollection asByteArray! !

!TestPseudoSocket methodsFor: 'stream-fromServer' stamp: ' 14/4/07 23:10'!
nextPutBytes: aByteArray 
	self byteStreamFromServer nextPutAll: aByteArray! !

!TestPseudoSocket methodsFor: 'stream-fromServer' stamp: ' 14/4/07 23:10'!
print: anObject 
	self nextPutAll: anObject printString asByteArray.
	^self! !

!TestPseudoSocket methodsFor: 'stream-fromServer' stamp: ' 14/4/07 23:10'!
space
	self nextPut: Character space.
	^self! !

!TestPseudoSocket methodsFor: 'stream-fromServer' stamp: ' 14/4/07 23:10'!
write: aByteArray 
	"^an Integer
	I write the contents of the sourceByteArray to my underlying Socket.
	I return the number of bytes written."

	self byteStreamFromServer nextPutAll: aByteArray.
	^aByteArray size! !


!TestPseudoSocket methodsFor: 'actions-client' stamp: ' 14/4/07 23:10'!
writeBytesToServer: aByteArray 
	"^self
This is where we make the bytes available over the pseudo socket.  Unlike a socket this is a one off thing (at least in this implementation of the pseudo socket).  Once the bytes are written, control passes to the server and stays there until the server sends a close to what it thinks is the client socket, but is really me."

	| results |
	self byteStreamToServer: (ReadStream on: aByteArray).
	self byteStreamFromServer: (WriteStream on: (ByteArray new: 1000)).
	self serverWaitSemaphore signal.
	self clientWaitSemaphore wait.
	results := self byteStreamFromServer contents.
	self byteStreamToServer: nil.
	self byteStreamFromServer: nil.
	^results! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

TestPseudoSocket class
	instanceVariableNames: ''!

!TestPseudoSocket class methodsFor: 'instance creation' stamp: ' 14/4/07 23:10'!
newTCPSocket
	"^a TestPseudoSocket
I simply return a new instance of myself."

	^self new! !

!TestPseudoSocket class methodsFor: 'instance creation' stamp: ' 14/4/07 23:10'!
serverOnIP: host port: port 
	"^self
I'm only pretending to be a socket class, so I ignore the host and port."

	^self new! !


TestCase subclass: #URIParsingTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!URIParsingTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
test05SimpleFullURI

|uri|
uri := SwazooURI fromString: 'http://abc.com:8080/smith/home.html'.
self assert: (uri protocol = 'http').
self assert: (uri hostname = 'abc.com'). 
self assert: (uri port = 8080).
self assert: (uri identifier = '/smith/home.html').
self assert: (uri asString = 'http://abc.com:8080/smith/home.html').! !

!URIParsingTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
test10SimpleFullURIWithQuery

|uri|
uri := SwazooURI fromString: 'http://abc.com:8080/smith/home.html?a=1&b=2'.
self assert: (uri protocol = 'http').
self assert: (uri hostname = 'abc.com'). 
self assert: (uri port = 8080).
self assert: (uri identifier = '/smith/home.html').
self assert: (uri asString = 'http://abc.com:8080/smith/home.html?a=1&b=2').! !

!URIParsingTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
test15SimpleFullURIWithPort80

|uri|
uri := SwazooURI fromString: 'http://abc.com:80/smith/home.html?a=1&b=2'.
self assert: (uri protocol = 'http').
self assert: (uri hostname = 'abc.com'). 
self assert: (uri port = 80).
self assert: (uri identifier = '/smith/home.html').
self assert: (uri asString = 'http://abc.com/smith/home.html?a=1&b=2').! !

!URIParsingTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
test20SimpleFullURIWithNoPort

|uri|
uri := SwazooURI fromString: 'http://abc.com/smith/home.html?a=1&b=2'.
self assert: (uri protocol = 'http').
self assert: (uri hostname = 'abc.com'). 
self assert: (uri port = 80).
self assert: (uri identifier = '/smith/home.html').
self assert: (uri asString = 'http://abc.com/smith/home.html?a=1&b=2').! !


TestCase subclass: #URIResolutionTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!URIResolutionTest methodsFor: 'testing'!
testCompositeAnswer
	| resource request response |
	resource := CompositeResource uriPattern: 'base'.
	resource addResource: (HelloWorldResource uriPattern: 'hi').
	request := HTTPGet request: 'base/hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 200.
	self assert: request resourcePath size = 2.
	self assert: request resourcePath first = 'base'.
	self assert: request resourcePath last = 'hi'! !

!URIResolutionTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testCompositeItselfCannotAnswer
	| resource request response |
	resource := CompositeResource uriPattern: 'base'.
	request := HTTPGet request: 'base'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil! !

!URIResolutionTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testCompositeNoAnswer
	| resource request response |
	resource := CompositeResource uriPattern: 'base'.
	resource addResource: (HelloWorldResource uriPattern: 'hi').
	request := HTTPGet request: 'tail/hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil! !

!URIResolutionTest methodsFor: 'testing'!
testLeafAnswer
	| resource request response |
	resource := HelloWorldResource uriPattern: 'hi'.
	request := HTTPGet request: 'hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'hi'! !

!URIResolutionTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testNoAnswerWhenDisabled
	| resource request response |
	resource := HelloWorldResource uriPattern: 'hi'.
	resource disable.
	request := HTTPGet request: 'hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil! !

!URIResolutionTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testResourcePath
	| request resolution |
	request := HTTPGet 
				request: 'foo/bar/baz/quux'
				from: 'localhost:1234'
				at: '1.2.3.4'.
	resolution := URIResolution new initializeRequest: request.
	self assert: resolution resourcePath = #('foo') asOrderedCollection.
	resolution advance.
	self assert: resolution resourcePath = #('foo' 'bar') asOrderedCollection.
	resolution advance.
	self 
		assert: resolution resourcePath = #('foo' 'bar' 'baz') asOrderedCollection.
	resolution advance.
	self assert: resolution resourcePath = #('foo' 'bar' 'baz' 'quux') asOrderedCollection! !

!URIResolutionTest methodsFor: 'testing'!
testSiteAnswer
	| resource request response |
	resource := SwazooSite new host: 'foo.com' ip: '1.2.3.4' port: 80.
	resource addResource: (HelloWorldResource uriPattern: '/').
	request := HTTPGet
				request: '/'
				from: 'foo.com'
				at: '1.2.3.4'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response statusCode = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = '/'! !

!URIResolutionTest methodsFor: 'testing' stamp: 'jm 2/8/2009 13:59'!
testSiteMatch
	| request site visitor |
	request := HTTPGet 
				request: 'foo'
				from: 'myhosthost:1234'
				at: '1.2.3.4'.
	visitor := URIResolution new initializeRequest: request.
	site := SwazooSite new host: 'myhosthost' ip: '1.2.3.4' port: 1234.
	self assert: (visitor siteMatch: site)! !

!URIResolutionTest methodsFor: 'testing' stamp: 'jm 2/8/2009 13:59'!
testSiteMismatch
	| request site visitor |
	request := HTTPGet 
				request: 'foo'
				from: 'localhost:1234'
				at: '1.2.3.4'.
	visitor := URIResolution new initializeRequest: request.
	site := SwazooSite new host: 'remotehost' ip: '1.2.3.4' port: 1234.
	self deny: (visitor siteMatch: site)! !

!URIResolutionTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testStringMatch
	| request visitor resource |
	request := HTTPGet request: 'foo'.
	visitor := URIResolution new initializeRequest: request.
	resource := HelloWorldResource uriPattern: 'foo'.
	self assert: (visitor stringMatch: resource)! !

!URIResolutionTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testStringMismatch
	| request visitor resource |
	request := HTTPGet request: 'foo'.
	visitor := URIResolution new initializeRequest: request.
	resource := HelloWorldResource uriPattern: 'Foo'.
	self deny: (visitor stringMatch: resource)! !

!URIResolutionTest methodsFor: 'testing' stamp: ' 14/4/07 23:10'!
testTailPath
	| request resolution |
	request := HTTPGet 
				request: 'foo/bar/baz/quux'
				from: 'localhost:1234'
				at: '1.2.3.4'.
	resolution := URIResolution new initializeRequest: request.
	self 
		assert: resolution tailPath = #('bar' 'baz' 'quux') asOrderedCollection.
	resolution advance.
	self assert: resolution tailPath = #('baz' 'quux') asOrderedCollection.
	resolution advance.
	self assert: resolution tailPath = #('quux') asOrderedCollection.
	resolution advance.
	self assert: resolution tailPath isEmpty! !


TestCase subclass: #WebSocketTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Tests'!

!WebSocketTest methodsFor: 'support' stamp: 'jm 11/29/2010 15:32'!
arrayFromHexString: aString
	| array stream lookup |
	lookup := '123456789ABCDEF'.
	array := ByteArray new: aString size // 2.
	stream := aString readStream.
	1 to: array size do: [ :i || h l |
		h := stream next.
		h := h = $0 ifTrue: [0] ifFalse: [lookup indexOf: h].
		l := stream next.
		l := l = $0 ifTrue: [0] ifFalse: [lookup indexOf: l].
		array at: i put: ((h bitShift: 4) bitOr: l) ].
	^array! !

!WebSocketTest methodsFor: 'support'!
challengeRequest
	"to test challenge calculation"
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET / HTTP/1.1';
		nextPutLine: 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==';
		crlf.
	^HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)! !

!WebSocketTest methodsFor: 'support' stamp: 'hmm 6/6/2012 12:54'!
upgradeRequest
	"first request is a HTTP one to upgrade connection from HTTP to WebSocket protocol"
	"exact request from protocol standard https://tools.ietf.org/html/rfc6455"
	| requestStream request |
	requestStream := SwazooStream on: String new.
	requestStream
		nextPutLine: 'GET /chat HTTP/1.1';
		nextPutLine: 'Host: server.example.com';
		nextPutLine: 'Upgrade: websocket';
		nextPutLine: 'Connection: Upgrade';
		nextPutLine: 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==';
		nextPutLine: 'Origin: http://example.com';
		nextPutLine: 'Sec-WebSocket-Protocol: chat, superchat';
		nextPutLine: 'Sec-WebSocket-Version: 13';
		crlf.
	request := HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents).
	request task: (SwazooTask newOn: request).
	request task connection: HTTPConnection new.
	^request! !


!WebSocketTest methodsFor: 'testing-internals'!
testChallengeCalculation
	| challenge |
	challenge  := SwazooWebSocket new calculateAcceptValueFrom: self challengeRequest.
	self assert: challenge = 's3pPLMBiTxaQ9kYGzzhZRbK+xOo='! !

!WebSocketTest methodsFor: 'testing-internals'!
testConnectionUpgrade
	| connection |
	connection := HTTPConnection new.
	connection upgradeToWebSocket.
	self assert: connection isWebSocketConnection.! !

!WebSocketTest methodsFor: 'testing-internals' stamp: 'hmm 6/6/2012 15:47'!
testFraming
	| connection frame |
	connection := WebSocketConnection new.
	frame := connection frameString: '1234'.
	self assert: frame = ((String with: 16r81 asCharacter with: 4 asCharacter), '1234')! !

!WebSocketTest methodsFor: 'testing-internals'!
testHandshake
	| response |
	response := SwazooWebSocket new answerTo: self upgradeRequest.
	self assert: response isWebSocketHandshake.
	self assert: response statusLine = '101 WebSocket Protocol Handshake'.
	self assert: (response headerValueAt: 'Upgrade') = 'websocket'.
	self assert: (response headerValueAt: 'Connection') connectionToken = 'Upgrade'.! !


!WebSocketTest methodsFor: 'testing'!
testWebSocket
	"Shows a most common usage. More on http://www.swazoo.org/websocket"
	| request webSocket response |
	request := self upgradeRequest.
	request isWebSocketRequest ifTrue:
		["put here a check if allowed to upgrade, if not: ^HTTPResponse unauthorized"
		webSocket := request webSocket.
		response := webSocket answerTo: request].

	self assert: request isWebSocketRequest.
	self assert: response isWebSocketHandshake.! !
