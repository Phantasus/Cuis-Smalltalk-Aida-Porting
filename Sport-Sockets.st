Object subclass: #SpSocket
	instanceVariableNames: 'underlyingSocket socketAddress'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Sockets'!

!SpSocket methodsFor: 'services-status' stamp: 'JM 4/14/2007 21:14'!
accept
	"^a SpSocket
	I accept the next connection made to the server socket I represent.
	This is a *blocking* request. That is, this method will not exit until
	an inbound socket connection is made. When that happens the new
	socket connected to the client (not the server socket) will be returned."
	^ SpExceptionContext
		for: [| clientSpecificSocket |
			[(clientSpecificSocket := self underlyingSocket
				waitForAcceptFor: 1
				ifTimedOut: [nil]) isNil] whileTrue.
			self class onNativeclientSocket: clientSpecificSocket for: self]
		on: Error
		do: [:ex | SpSocketError new 
			parameter: ex;
			raiseSignal: 'Error while trying to accept a socket connection.']! !

!SpSocket methodsFor: 'services-status' stamp: 'JM 4/14/2007 21:15'!
acceptRetryingIfTransientErrors

	"^a SpSocket
	I try to do an accept.  If I get an exception which is 'transient' I retry.
	For now in Squeak, I just do the accept"

	"^SpExceptionContext
		for: [self accept]
		on: OSErrorHolder transientErrorSignal
		do: [:ex | ex restart]"

	^self accept! !

!SpSocket methodsFor: 'services-status' stamp: 'JM 4/14/2007 21:15'!
bindSocketAddress: aSocketAddress
	"^self
	Equivalent of: bind(int sockfd, struct sockaddr *my_addr, socklen_t	addrlen); 
	see man bind. Bind the socket to aSocketAddress.	It seems that Squeak merges 
	the 'bind' and the 'listen', so here I'll just	remember the socket address and 
	use it when I get the listen request."
	
	socketAddress := aSocketAddress.
	^self! !

!SpSocket methodsFor: 'services-status' stamp: 'mivsek 9/5/2007 23:12'!
close
	"^self
	The same as the close() posix function."
	
	self underlyingSocket closeAndDestroy! !

!SpSocket methodsFor: 'services-status' stamp: 'JM 4/14/2007 21:16'!
connectTo: aSocketAddress	
	"^self
	I instruct my underlying socket to connect to aSocketAddress."
	
	self underlyingSocket 
		connectTo: aSocketAddress hostAddress 
		port: aSocketAddress portNumber! !

!SpSocket methodsFor: 'services-status' stamp: 'JM 4/14/2007 21:18'!
listenBackloggingUpTo: aNumberOfConnections
	"^self
	I set the socket I represent listening for incomming connections,
	allowing a 	backlog of up to aNumberOfConnections.
	Note that Squeak combines bind and listen so I noted the socket address
	when I was asked to bind - and I use that now.
	OK - I really wanter to be able to specify the interface, but that seems
	to be broken - I get a primitive error when I try to use it"
	
	self underlyingSocket
		listenOn: socketAddress portNumber
		backlogSize: aNumberOfConnections
"		interface: socketAddress hostAddress".
 	^self! !


!SpSocket methodsFor: 'services-accessing' stamp: 'JM 4/14/2007 21:01'!
getPeerName
	"^a SpSocketAddress
	see man getpeername.
	I return the socket address of the other/remote/peer end of the socket I represent."
	
	^ SpIPAddress 
		host: self underlyingSocket remoteAddress 
		port: self underlyingSocket remotePort! !

!SpSocket methodsFor: 'services-accessing' stamp: 'JM 4/14/2007 21:02'!
getSocketName	
	"^a SpSocketAddress
	see: man getsockname
	I rreturn my local socket address which may be any subclass of SpSocketAddress."
	
	^ SpIPAddress 
		host: self underlyingSocket localAddress 
		port: self underlyingSocket localPort! !


!SpSocket methodsFor: 'testing' stamp: 'JM 4/14/2007 21:19'!
isActive	
	"^a Boolean
	In Squeak there is no simple >>isActive test, it seems."
	
	^self underlyingSocket isConnected
		or: [self underlyingSocket isWaitingForConnection]! !


!SpSocket methodsFor: 'private' stamp: 'JM 4/14/2007 21:19'!
onNativeclientSocket: aNativeSocket for: aServerSocket
	"^self
	I initialize myself with the same properties as aServerSocket and with
	aNativeSocket as my underlying socket."
	
"	communicationDomain := aServerSocket communicationDomain.
	socketType := aServerSocket socketType.
	protocolNumber := aServerSocket protocolNumber."
	
	underlyingSocket := aNativeSocket.
	^self! !

!SpSocket methodsFor: 'private' stamp: 'JM 4/14/2007 21:20'!
underlyingSocket
	^underlyingSocket! !


!SpSocket methodsFor: 'initialize-release' stamp: 'JM 4/14/2007 21:00'!
onUnderlyingSocket: aSocket
	underlyingSocket := aSocket.
	^self! !


!SpSocket methodsFor: 'services-io' stamp: 'JM 4/14/2007 21:05'!
read: targetNumberOfBytes 
	"^a ByteArray
	I attempt to read the targetNumberOfBytes from my underlying socket.
	If the targetNumberOfBytes	are not available, I return what I can get."
				
	| targetByteArray numberOfBytesActuallyRead |
	^ SpExceptionContext
		for: 
			[targetByteArray := ByteArray new: targetNumberOfBytes.
			numberOfBytesActuallyRead := self underlyingSocket 
				receiveDataInto: targetByteArray.
			targetByteArray copyFrom: 1 to: numberOfBytesActuallyRead]
		on: Error
		do: [:ex | SpSocketError raiseSignal: ex]! !

!SpSocket methodsFor: 'services-io' stamp: 'JM 4/14/2007 21:06'!
readInto: aByteArray startingAt: startIndex for: aNumberOfBytes
	"^an Integer
	I return the number of bytes actually read.	In Squeak it seems we can not specify the
	number of bytes to be read.	We get what its there no matter how much their is!!"
	| actuallyRead |
	actuallyRead := self underlyingSocket receiveDataInto: aByteArray startingAt: startIndex.
	actuallyRead > aNumberOfBytes
		ifTrue: [1 halt].
	^ actuallyRead! !

!SpSocket methodsFor: 'services-io' stamp: 'JM 4/14/2007 21:06'!
readyForRead
	"^a Boolean
	I return true if a read operation will return some number of bytes."
	
	^self underlyingSocket dataAvailable! !

!SpSocket methodsFor: 'services-io' stamp: 'JM 4/14/2007 21:08'!
waitForReadDataUpToMs: aNumberOfMilliseconds 
	"^a Boolean
	I return true if we think data became available within
	aNumberOfMilliseconds, and false if we timed out.
	Squeak wants a timeout in seconds, so I convert it here."
	
	| aNumberOfSeconds |
	aNumberOfSeconds := (aNumberOfMilliseconds / 1000) ceiling.
	self underlyingSocket
		waitForDataFor: aNumberOfSeconds
		ifClosed: [SpError signal: 'Socket closed while waiting for data'. ^false]
		ifTimedOut: [^false].
	^true! !

!SpSocket methodsFor: 'services-io' stamp: 'JM 4/14/2007 21:09'!
write: sourceByteArray	
	"^an Integer
	I write the contents of the sourceByteArray to my underlying Socket.
	I return the number of bytes written."
	
	^SpExceptionContext
		for: [self underlyingSocket sendSomeData: sourceByteArray]
		on: Error
		do: [:ex | SpSocketError raiseSignal: ex]! !

!SpSocket methodsFor: 'services-io' stamp: 'mivsek 7/22/2007 19:04'!
writeFrom: aByteArray startingAt: startIndex for: length
	"^an Integer
	I return the number of bytes actually written."
	
	^SpExceptionContext
		for: [self underlyingSocket
			sendSomeData: aByteArray
			startIndex: startIndex
			count: length]
		on: Error
		do: [:ex | SpSocketError raiseSignal: ex]
! !


!SpSocket methodsFor: 'services-options' stamp: 'JM 4/14/2007 21:10'!
setAddressReuse: aBoolean	
	"^self
	c.f. self class >>socketOptions and self >>setOptionForLevel:optionID:value:
	If a boolean is true, I set address reuse on, otherwise I set address reuse	off. "
		
	"self underlyingSocket setOption: 'SO_REUSEADDR' value: aBoolean"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpSocket class
	instanceVariableNames: ''!

!SpSocket class methodsFor: 'instance creation' stamp: 'JM 4/16/2007 22:40'!
connectToServerOnHost: hostName port: portNumber 
	"^a SpSocket
	I return a new instance of myself which represents a socket connecter
	to a server listening on portNumber at hostName."
	| newSocket |
	newSocket := self newTCPSocket.
	newSocket
		connectTo: (SpIPAddress hostName: hostName port: portNumber).
	^ newSocket! !

!SpSocket class methodsFor: 'instance creation' stamp: 'JM 4/17/2007 12:44'!
newSocketPair
	"I return an array containing two SpSockets each representing one end of a
	TCP connection. Port is fixed (for now)!! "
	"SpSocket newSocketPair"
	| s1 s2 s3 |
	[s1 := self newTCPSocket
		setAddressReuse: true; 
		bindSocketAddress: (SpIPAddress hostName: 'localhost' port: 3523);
		listenBackloggingUpTo: 50.
	s2 := SpSocket connectToServerOnHost: 'localhost' port: 3523.
	s3 := s1 accept]
		ifCurtailed: 	[s1 close. s2 close].
	s1 close.
	^Array with: s3 with: s2! !

!SpSocket class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:49'!
newTCPSocket
	"^a SpSocket
	I return a new instance of myself that represents an unconfigured TCP socket."
	
	Socket initializeNetwork.
	^self new onUnderlyingSocket: Socket newTCP! !


!SpSocket class methodsFor: 'private' stamp: 'JM 4/14/2007 19:50'!
onNativeclientSocket: aNativeSocket for: aServerSocket
	"^a SpSocket
	I create a new instance of my self at the request of aServerSocket  where
	this new instance will be a connected client socket (connected via aNativeSoket)."
	
	^self new onNativeclientSocket: aNativeSocket for: aServerSocket! !


Object subclass: #SpSocketAddress
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Sockets'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpSocketAddress class
	instanceVariableNames: ''!

!SpSocketAddress class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:47'!
on: subjectAddress for: aSocket 
	"^a SpSocketAddress
	Well, in the future there may be more than one kind of socket address,
	but for now there is just SpIPAddress, so I return one of those on the 
	details embodied in the subjectAddress. 
	No use is made of aSocket as yet, but it will be useful when there
	are more kinds of socket address supported."
	
	^SpIPAddress host: subjectAddress hostAddress port: subjectAddress port! !


SpSocketAddress subclass: #SpIPAddress
	instanceVariableNames: 'hostAddress portNumber'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Sockets'!

!SpIPAddress methodsFor: 'initialize-release' stamp: 'JM 4/14/2007 19:44'!
host: aHostAddress port: aPortNumber 
	hostAddress := aHostAddress.
	portNumber := aPortNumber! !


!SpIPAddress methodsFor: 'accessing' stamp: 'JM 4/14/2007 19:44'!
hostAddress
	^ hostAddress! !

!SpIPAddress methodsFor: 'accessing' stamp: 'JM 4/14/2007 19:45'!
portNumber
	^ portNumber! !


!SpIPAddress methodsFor: 'printing' stamp: 'JM 4/14/2007 19:46'!
hostAddressString
	| targetStream |
	targetStream := String new writeStream.

	targetStream
		nextPutAll: (self hostAddress at: 1) printString;
		nextPut: $.;
		nextPutAll: (self hostAddress at: 2) printString;
		nextPut: $.;
		nextPutAll: (self hostAddress at: 3) printString;
		nextPut: $.;
		nextPutAll: (self hostAddress at: 4) printString.
	^targetStream contents! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpIPAddress class
	instanceVariableNames: ''!

!SpIPAddress class methodsFor: 'instance creation' stamp: 'mivsek 8/17/2007 16:24'!
connectToServerOnHost: hostName port: portNumber
	"^an OSkSocket 
	I return a new instance of myself which represents a socket connector
	to a server listening on portNumber at hostName."
	| newSocket |
	newSocket := self newTCPSocket.
	newSocket connectTo: (SpIPAddress hostName: hostName port: portNumber).
	^ newSocket! !

!SpIPAddress class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:41'!
host: aHostAddress port: aPortNumber
	"^a SpSocketAddress
	I create a new instance of myself which represents an IP address/port
	combination (a TCP/IP address, really). Note that aHostAddress must be a
	four element byte array (e.g. #[127 0 0 1]) ."
	
	^ self new host: aHostAddress port: aPortNumber! !

!SpIPAddress class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 19:42'!
hostName: aHostNameString port: aPortNumber
	"^a SpSocketAddress
	I translate aHostNameString to an IP address and then create
	a new instance of myself with >>host:port:"	
		
	^ self
		host: (NetNameResolver addressForName: aHostNameString)
		port: aPortNumber! !


SpError subclass: #SpSocketError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Sockets'!
