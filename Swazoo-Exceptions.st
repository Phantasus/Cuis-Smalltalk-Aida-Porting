Error subclass: #HTTPException
	instanceVariableNames: 'response'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Exceptions'!
!HTTPException commentStamp: '<historical>' prior: 0!
HTTPException immediatelly returns attached HTTP response to client. That way it is easier to respond with different status codes (like 201 Created). Not only error ones!! You can respond somewhere deeply in code of your resource with raising that exception and adding a prepared HTTPResponse. 
This exception is non-resumable!!

Example of ways to raise http response (200 Ok):

	HTTPException raiseResponse: (HTTPResponse new code: 200).
	HTTPException raiseResponseCode: 200.
	HTTPException ok.

Instance Variables:
	response	<HTTPResponse>	a response to be sent to client

!


!HTTPException methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
response
	^response! !

!HTTPException methodsFor: 'accessing' stamp: ' 14/4/07 23:10'!
response: aHTTPResponse
	response := aHTTPResponse! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPException class
	instanceVariableNames: ''!

!HTTPException class methodsFor: 'responses-succesfull' stamp: ' 14/4/07 23:10'!
accepted
	^self raiseResponse: (HTTPResponse new code: 202)! !

!HTTPException class methodsFor: 'responses-succesfull' stamp: ' 14/4/07 23:10'!
created
	^self raiseResponse: (HTTPResponse new code: 201)! !

!HTTPException class methodsFor: 'responses-succesfull' stamp: ' 14/4/07 23:10'!
noContent
	^self raiseResponse: (HTTPResponse new code: 204)! !

!HTTPException class methodsFor: 'responses-succesfull' stamp: ' 14/4/07 23:10'!
nonAuthorativeInformation
	^self raiseResponse: (HTTPResponse new code: 203)! !

!HTTPException class methodsFor: 'responses-succesfull' stamp: ' 14/4/07 23:10'!
ok
	^self raiseResponse: HTTPResponse ok! !

!HTTPException class methodsFor: 'responses-succesfull' stamp: ' 14/4/07 23:10'!
partialContent
	^self raiseResponse: (HTTPResponse new code: 206)! !

!HTTPException class methodsFor: 'responses-succesfull' stamp: ' 14/4/07 23:10'!
resetContent
	^self raiseResponse: (HTTPResponse new code: 205)! !


!HTTPException class methodsFor: 'responses-server error' stamp: ' 14/4/07 23:10'!
badGateway
	^self raiseResponse: (HTTPResponse new code: 502)! !

!HTTPException class methodsFor: 'responses-server error' stamp: ' 14/4/07 23:10'!
gatewayTimeout
	^self raiseResponse: (HTTPResponse new code: 504)! !

!HTTPException class methodsFor: 'responses-server error' stamp: ' 14/4/07 23:10'!
httpVersionNotSupported
	^self raiseResponse: (HTTPResponse new code: 505)! !

!HTTPException class methodsFor: 'responses-server error' stamp: ' 14/4/07 23:10'!
internalServerError
	^self raiseResponse: (HTTPResponse new code: 500)! !

!HTTPException class methodsFor: 'responses-server error' stamp: ' 14/4/07 23:10'!
notImplemented
	^self raiseResponse: (HTTPResponse new code: 501)! !

!HTTPException class methodsFor: 'responses-server error' stamp: ' 14/4/07 23:10'!
serviceUnavailable
	^self raiseResponse: (HTTPResponse new code: 503)! !


!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
badRequest
	^self raiseResponse: (HTTPResponse new code: 400)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
conflict
	^self raiseResponse: (HTTPResponse new code: 409)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
expectationFailed
	^self raiseResponse: (HTTPResponse new code: 416)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
forbidden
	^self raiseResponse: (HTTPResponse new code: 403)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
gone
	^self raiseResponse: (HTTPResponse new code: 410)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
lengthRequired
	^self raiseResponse: (HTTPResponse new code: 411)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
methodNotAllowed
	^self raiseResponse: (HTTPResponse new code: 405)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
notAcceptable
	^self raiseResponse: (HTTPResponse new code: 406)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
notFound
	^self raiseResponse: (HTTPResponse new code: 404)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
paymentRequired
	^self raiseResponse: (HTTPResponse new code: 402)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
preconditionFailed
	^self raiseResponse: (HTTPResponse new code: 412)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
proxyAuthenticationRequired
	^self raiseResponse: (HTTPResponse new code: 407)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
requestEntityTooLarge
	^self raiseResponse: (HTTPResponse new code: 413)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
requestTimeout
	^self raiseResponse: (HTTPResponse new code: 408)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
requestURITooLong
	^self raiseResponse: (HTTPResponse new code: 414)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
requestedRangeNotSatisfiable
	^self raiseResponse: (HTTPResponse new code: 416)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
unathorized
	^self raiseResponse: (HTTPResponse new code: 401)! !

!HTTPException class methodsFor: 'responses-client error' stamp: ' 14/4/07 23:10'!
unsupportedMediaType
	^self raiseResponse: (HTTPResponse new code: 415)! !


!HTTPException class methodsFor: 'responses-informational' stamp: ' 14/4/07 23:10'!
continue
	^self raiseResponse: (HTTPResponse new code: 100)! !

!HTTPException class methodsFor: 'responses-informational' stamp: ' 14/4/07 23:10'!
switchingProtocols
	^self raiseResponse: (HTTPResponse new code: 101)! !


!HTTPException class methodsFor: 'responses-redirection' stamp: ' 14/4/07 23:10'!
found
	^self raiseResponse: (HTTPResponse new code: 302)! !

!HTTPException class methodsFor: 'responses-redirection' stamp: ' 14/4/07 23:10'!
movedPermanently
	^self raiseResponse: (HTTPResponse new code: 301)! !

!HTTPException class methodsFor: 'responses-redirection' stamp: ' 14/4/07 23:10'!
multipleChoices
	^self raiseResponse: (HTTPResponse new code: 300)! !

!HTTPException class methodsFor: 'responses-redirection' stamp: ' 14/4/07 23:10'!
notModified
	^self raiseResponse: (HTTPResponse new code: 304)! !

!HTTPException class methodsFor: 'responses-redirection' stamp: ' 14/4/07 23:10'!
seeOther
	^self raiseResponse: (HTTPResponse new code: 303)! !

!HTTPException class methodsFor: 'responses-redirection' stamp: ' 14/4/07 23:10'!
temporaryRedirect
	^self raiseResponse: (HTTPResponse new code: 307)! !

!HTTPException class methodsFor: 'responses-redirection' stamp: ' 14/4/07 23:10'!
useProxy
	^self raiseResponse: (HTTPResponse new code: 305)! !


!HTTPException class methodsFor: 'signalling' stamp: ' 14/4/07 23:10'!
raiseResponseCode: aNumber
	"Raise an exception to immediatelly return http response with that code"
	^self raiseResponse: (HTTPResponse new code: aNumber)! !


!HTTPException class methodsFor: '*Aida' stamp: 'mivsek 8/22/2007 11:24'!
raiseResponse: aHTTPResponse
	"Raise an exception to immediatelly return that response."
	"put that on Swazoo next version!!!!!!"
	^self new 
		response: aHTTPResponse;
		signal.! !


SpError subclass: #SwazooHTTPParseError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Exceptions'!


SpError subclass: #SwazooHTTPRequestError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Exceptions'!


SwazooHTTPRequestError subclass: #SwazooHTTPPostError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Exceptions'!


SwazooHTTPRequestError subclass: #SwazooHTTPPutError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Exceptions'!


SpError subclass: #SwazooHeaderFieldParseError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Exceptions'!


SpError subclass: #SwazooSiteError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Exceptions'!


SpError subclass: #SwazooStreamNoDataError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Exceptions'!
