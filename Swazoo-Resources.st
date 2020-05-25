SwazooResource subclass: #HelloWorldResource
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Resources'!
!HelloWorldResource commentStamp: '<historical>' prior: 0!
A HelloWorldResource is a simple example and for testing purposes!


!HelloWorldResource methodsFor: 'serving' stamp: 'janko 11/1/2012 19:27'!
answerTo: aRequest 
	| response |
	response := HTTPResponse ok.
	response
		contentType: 'text/html';
		entity: '<html><head><title>Hello World</title></head><body>Hello World!!</body></html>'.
	^response! !


SwazooResource subclass: #RedirectionResource
	instanceVariableNames: 'targetUri'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Resources'!

!RedirectionResource methodsFor: 'serving' stamp: ' 14/4/07 23:10'!
answerTo: aRequest 
	| answer |
	answer := HTTPResponse movedPermanently.
	answer headers addField: (HTTPLocationField new uriString: self targetUri).
	^answer! !


!RedirectionResource methodsFor: 'private-initialize' stamp: ' 14/4/07 23:10'!
targetUri
	^targetUri! !

!RedirectionResource methodsFor: 'private-initialize' stamp: ' 14/4/07 23:10'!
targetUri: aString 
	targetUri := aString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

RedirectionResource class
	instanceVariableNames: ''!

!RedirectionResource class methodsFor: 'instance creation' stamp: ' 14/4/07 23:10'!
uriPattern: aString targetUri: bString 
	^(self uriPattern: aString) targetUri: bString! !


Object subclass: #SwazooCompiler
	instanceVariableNames: 'accessor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Resources'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SwazooCompiler class
	instanceVariableNames: ''!

!SwazooCompiler class methodsFor: 'evaluation' stamp: 'janko 7/26/2008 13:54'!
evaluate: aString 
        ^SpEnvironment
            evaluate: aString
            receiver: SwazooCompiler
            in: self class environment! !

!SwazooCompiler class methodsFor: 'evaluation' stamp: ' 14/4/07 23:09'!
evaluate: aString receiver: anObject 
	^SpEnvironment 
		evaluate: aString
		receiver: anObject
		in: self class environment! !


SwazooSite subclass: #SwazooDemoSite
	instanceVariableNames: 'webSocket'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Swazoo-Resources'!

!SwazooDemoSite methodsFor: 'serving'!
answerTo: aRequest 
	aRequest urlString = '/websocket' ifTrue: [^self answerWebSocketTo: aRequest].
	^self answerToHelloWorld! !

!SwazooDemoSite methodsFor: 'serving'!
answerToHelloWorld
	| response |
	response := HTTPResponse ok.
	response
		contentType: 'text/html';
		entity: '<html><head><title>Hello World</title></head><body>Hello World!!</body></html>'.
	^response! !

!SwazooDemoSite methodsFor: 'serving'!
answerWebSocketTo: aRequest
	"upgrade HTTP connection to WebSocket to establish bidirectional messaging to and from browser"
	aRequest isWebSocketRequest ifFalse: [^HTTPResponse forbidden].
	self webSocket: aRequest webSocket.
	^webSocket answerTo: aRequest! !

!SwazooDemoSite methodsFor: 'serving' stamp: 'jm 11/30/2010 12:49'!
helpResolve: aResolution 
	(self canAnswer and: [aResolution siteMatch: self]) ifFalse: [^nil].
	^self answerTo: aResolution request! !


!SwazooDemoSite methodsFor: 'accessing'!
webSocket
	^webSocket! !

!SwazooDemoSite methodsFor: 'accessing'!
webSocket: aWebSocketResource
	webSocket := aWebSocketResource! !
