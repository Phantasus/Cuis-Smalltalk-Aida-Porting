Error subclass: #SpAbstractError
	instanceVariableNames: 'parameter'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Exceptions'!

!SpAbstractError methodsFor: 'accessing' stamp: 'BB 1/25/2006 21:52'!
errorString
	^self messageText! !

!SpAbstractError methodsFor: 'accessing' stamp: 'BB 1/23/2006 22:03'!
parameter
	^parameter ! !

!SpAbstractError methodsFor: 'accessing' stamp: 'BB 1/23/2006 22:03'!
parameter: anObject 
	parameter := anObject! !


!SpAbstractError methodsFor: 'priv handling' stamp: 'BB 1/23/2006 22:16'!
isResumable
	"Determine whether an exception is resumable."

	^self class mayResume! !


!SpAbstractError methodsFor: 'signalling' stamp: 'BB 1/23/2006 22:11'!
raiseSignal
	"Raise an an exception."
	^ self signal! !

!SpAbstractError methodsFor: 'signalling' stamp: 'BB 1/25/2006 22:02'!
raiseSignal: aString 
	"Raise an an exception."
	^ self signal: aString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpAbstractError class
	instanceVariableNames: ''!

!SpAbstractError class methodsFor: 'testing' stamp: 'BB 1/23/2006 22:17'!
mayResume

	^false! !


!SpAbstractError class methodsFor: 'signalling' stamp: 'BB 1/23/2006 22:08'!
raiseSignal
	"Raise an an exception."
	^ self signal! !

!SpAbstractError class methodsFor: 'signalling' stamp: 'BB 1/23/2006 21:24'!
raiseSignal: aString 
	"Raise an an exception."
	^ self signal: aString! !


SpAbstractError subclass: #SpError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Exceptions'!


Object subclass: #SpExceptionContext
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Exceptions'!
!SpExceptionContext commentStamp: '<historical>' prior: 0!
Exceptions vary quite a bit between Smalltalk implementaions, despite the presence of the ANSI Smalltalk specification.  This class representss a portable exception context in which a block can be executed, exceptions trapped and handlers defined.!


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpExceptionContext class
	instanceVariableNames: ''!

!SpExceptionContext class methodsFor: 'native exceptions' stamp: 'JM 4/14/2007 18:41'!
brokenPipeException
	"I return the exception that get's thrown when a socket connection gets
	broken."

	^ProtocolClientError! !


!SpExceptionContext class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 18:42'!
for: aBlock on: anException do: exceptionBlock
	"^an Object
	I return the result of evaluating aBlock. In VisualWorks and other
	Smalltalks which are ANSI compliant, I delegate to aBlock."

	^aBlock on: anException do: exceptionBlock! !

!SpExceptionContext class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 18:42'!
for: aBlock onAnyExceptionDo: exceptionBlock	
	"^an Object
	I execute aBlock and if there is any exception I evaluate exceptionBlock.  
	Essentially, I look out for the most abstract kind of exception which , 
	of course, will vary between Smalltalk implementations."
	
	^aBlock on: Exception do: exceptionBlock! !
