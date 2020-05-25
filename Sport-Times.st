Object subclass: #SpDate
	instanceVariableNames: 'underlyingDate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Times'!

!SpDate methodsFor: 'comparing' stamp: 'JM 4/26/2007 21:38'!
< anotherSpDate 
	"^a Boolean
	Answer true if anotherSpDate is less (i.e. earlier) than me."
	^self underlyingDate < anotherSpDate underlyingDate! !

!SpDate methodsFor: 'comparing' stamp: 'mivsek 8/17/2007 16:07'!
<= anotherOSkDate 
	"^a Boolean
	Answer true if anotherOSkDate is greater (i.e. later) than me."

	^self underlyingDate <= anotherOSkDate underlyingDate! !

!SpDate methodsFor: 'comparing' stamp: 'mivsek 8/17/2007 16:07'!
= anotherOSkDate 
	"^a Boolean
	Answer true if anotherOSkDate is equivalent to me."
	^self underlyingDate = anotherOSkDate underlyingDate! !

!SpDate methodsFor: 'comparing' stamp: 'JM 4/14/2007 18:50'!
> anotherOSkDate 
	"^a Boolean
	Answer true if anotherOSkDate is greater (i.e. later) than me."
	^self underlyingDate > anotherOSkDate underlyingDate! !

!SpDate methodsFor: 'comparing' stamp: 'mivsek 8/17/2007 16:07'!
>= anotherOSkDate 
	"^a Boolean
	Answer true if anotherOSkDate is greater (i.e. later) than me."

	^self underlyingDate >= anotherOSkDate underlyingDate! !

!SpDate methodsFor: 'comparing' stamp: 'JM 4/14/2007 18:50'!
hash
	"^an Object"
	^self underlyingDate hash! !

!SpDate methodsFor: 'comparing' stamp: 'mivsek 8/17/2007 16:07'!
max: anSpDate 
	^self > anSpDate ifTrue: [self] ifFalse: [anSpDate]! !

!SpDate methodsFor: 'comparing' stamp: 'mivsek 8/17/2007 16:08'!
min: anSpDate 
	^self < anSpDate ifTrue: [self] ifFalse: [anSpDate]! !


!SpDate methodsFor: 'services' stamp: 'JM 4/26/2007 21:24'!
addDays: anInteger 
	"^a SpDate
	I don't change the date I represent.  Rather, I create a new date which represents
	my date offset by anInteger days."
	^SpDate fromDays: self asDays + anInteger! !

!SpDate methodsFor: 'services' stamp: 'JM 4/26/2007 21:31'!
addYears: anInteger 	
	"^an OSkDate
	I don't change the date I represent.  Rather, I create a new date which represents my 
	date offset by anInteger years."
	^SpDate onDate: 
		(Date newDay: self underlyingDate dayOfMonth
		 	month: self underlyingDate monthIndex
			year: self underlyingDate year + anInteger)! !

!SpDate methodsFor: 'services' stamp: 'JM 4/26/2007 21:25'!
subtractDays: anInteger 
	"^a SpDate
	I don't change the date I represent.  Rather, I create a new date which represents
	my date offset by anInteger days."
	^SpDate fromDays: self asDays - anInteger! !


!SpDate methodsFor: 'converting' stamp: 'JM 4/26/2007 21:19'!
asDays	
	"^an Integer
	I return the integer number of days between January 1, 1901 and
	the date I represent. "
	^self underlyingDate asSeconds / (3600*24)! !


!SpDate methodsFor: 'printing' stamp: 'JM 4/14/2007 18:51'!
asISO8610String 
	|targetStream|
	targetStream := WriteStream on: String new.
	self asISO8610StringOn: targetStream.
	^targetStream contents! !

!SpDate methodsFor: 'printing' stamp: 'JM 4/14/2007 18:52'!
asISO8610StringOn: aStream 	
	aStream
		nextPutAll: self underlyingDate year printString;
		nextPut: $-.
	self underlyingDate monthIndex < 10 ifTrue: [aStream nextPut: $0].
	aStream
		nextPutAll: self underlyingDate monthIndex printString;
		nextPut: $-.
	self underlyingDate dayOfMonth < 10 ifTrue: [aStream nextPut: $0].
	aStream nextPutAll: self underlyingDate dayOfMonth printString.
	^self! !

!SpDate methodsFor: 'printing' stamp: 'JM 4/26/2007 21:06'!
printOn: aStream
	self underlyingDate printOn: aStream! !


!SpDate methodsFor: 'accessing' stamp: 'JM 4/25/2007 21:24'!
day
	^self underlyingDate day! !

!SpDate methodsFor: 'accessing' stamp: 'JM 4/26/2007 21:37'!
daysInMonth
	^self underlyingDate daysInMonth! !

!SpDate methodsFor: 'accessing' stamp: 'JM 4/26/2007 21:22'!
monthIndex
	^self underlyingDate monthIndex! !

!SpDate methodsFor: 'accessing' stamp: 'JM 4/26/2007 21:27'!
weekdayIndex
	"Sunday=1, ... , Saturday=7"
	^self underlyingDate weekdayIndex
! !

!SpDate methodsFor: 'accessing' stamp: 'JM 4/25/2007 21:23'!
year
	^self underlyingDate year! !


!SpDate methodsFor: 'initialize-release' stamp: 'JM 4/14/2007 18:51'!
onDate: aDate 
	underlyingDate := aDate.
	^self! !


!SpDate methodsFor: 'private' stamp: 'JM 4/14/2007 18:49'!
underlyingDate
	^underlyingDate! !


!SpDate methodsFor: '*Swazoo' stamp: 'janko 8/26/2013 15:35'!
dayOfYear
	^self underlyingDate dayOfYear! !


!SpDate methodsFor: '*Aida' stamp: 'JM 4/22/2007 19:01'!
+ aNumber 
	^self addDays: aNumber! !

!SpDate methodsFor: '*Aida' stamp: 'JM 4/22/2007 19:01'!
- aNumber 
	"subtract number of days from a date."
	^self subtractDays: aNumber! !

!SpDate methodsFor: '*Aida' stamp: 'np 10/22/2008 23:36'!
currentMonth
	^self currentYear and: [self monthIndex = SpDate today monthIndex]! !

!SpDate methodsFor: '*Aida' stamp: 'np 10/22/2008 23:37'!
currentYear
	^self year = SpDate today year! !

!SpDate methodsFor: '*Aida' stamp: 'np 10/22/2008 23:37'!
firstDayInMonth
	^SpDate newDay: 1 month: self monthIndex year: self year! !

!SpDate methodsFor: '*Aida' stamp: 'np 10/22/2008 23:38'!
firstDayInNextMonth
	^SpDate 
		newDay: 1 
		month: (self lastDayInMonth addDays: 1) monthIndex
		year: (self lastDayInMonth addDays: 1) year! !

!SpDate methodsFor: '*Aida' stamp: 'np 10/22/2008 23:38'!
firstDayInNextYear
	^SpDate 
		newDay: 1
		month: self firstDayInMonth monthIndex
		year: self firstDayInMonth year + 1! !

!SpDate methodsFor: '*Aida' stamp: 'np 10/22/2008 23:38'!
firstDayInPreviousMonth
	^SpDate 
		newDay: 1
		month: (self firstDayInMonth subtractDays: 1) monthIndex
		year: (self firstDayInMonth subtractDays: 1) year! !

!SpDate methodsFor: '*Aida' stamp: 'np 10/22/2008 23:38'!
firstDayInPreviousYear
	^SpDate 
		newDay: 1
		month: self firstDayInMonth monthIndex
		year: self firstDayInMonth year + 1! !

!SpDate methodsFor: '*Aida' stamp: 'np 10/22/2008 23:39'!
lastDayInMonth
	^SpDate newDay: self daysInMonth month: self monthIndex year: self year! !

!SpDate methodsFor: '*Aida' stamp: 'np 1/22/2008 12:20'!
monthAndDayString
	"with leading zeros, example: 05-16 for 16may"
	^(self monthIndex < 10 ifTrue: ['0'] ifFalse: ['']), self monthIndex printString, '-',
	 	(self underlyingDate dayOfMonth < 10 ifTrue: ['0'] ifFalse: ['']), self underlyingDate dayOfMonth printString

"SpDate today monthAndDayString"! !

!SpDate methodsFor: '*Aida' stamp: 'JM 4/22/2007 19:02'!
printISOString
	^self year printString, 
		(self monthIndex < 10 ifTrue: ['0'] ifFalse: ['']), self monthIndex printString,
		(self dayOfMonth < 10 ifTrue: ['0'] ifFalse: ['']), self dayOfMonth printString

"Date today printISOString   "! !

!SpDate methodsFor: '*Aida' stamp: 'JM 4/26/2007 19:56'!
shortPrintSloString
	^self underlyingDate dayOfMonth printString, '.', 
		self underlyingDate monthIndex printString, '.', self year printString.

"SpDate today shortPrintSloString"! !

!SpDate methodsFor: '*Aida' stamp: 'janko 9/30/2011 10:13'!
shorterPrintSloString
	"year in two digits only"
	| yeart |
	yeart := (self year \\ 100) printString. yeart size = 1 ifTrue: [yeart := '0', yeart].
	^self underlyingDate dayOfMonth printString, '.', self monthIndex printString, '.', yeart.

"Date today shorterPrintSloString"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpDate class
	instanceVariableNames: ''!

!SpDate class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 18:45'!
fromDays: anInteger
	^self new onDate: (Date fromDays: anInteger)! !

!SpDate class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 18:45'!
fromISO8610Stream: aStream 	
	| date |
	date := SpExceptionContext
		for: [self parseDateFromISO8601Stream: aStream]
		on: SpError
		do: [:ex | nil].
	^date isNil ifTrue: [nil] ifFalse: [self onDate: date]! !

!SpDate class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 18:44'!
fromISO8610String: aString
	^aString size == 10
		ifFalse: [nil]
		ifTrue: [self fromISO8610Stream: aString readStream]! !

!SpDate class methodsFor: 'instance creation' stamp: 'JM 4/26/2007 21:05'!
newDay: day month: month year: year 
	^self new onDate: (Date newDay: day month: month year: year) ! !

!SpDate class methodsFor: 'instance creation' stamp: 'JM 4/26/2007 21:28'!
newDay: day monthNumber: month year: year 
	^self new onDate: (Date newDay: day month: month year: year) ! !

!SpDate class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 18:44'!
onDate: aDate
	^self new onDate: aDate! !

!SpDate class methodsFor: 'instance creation' stamp: 'JM 4/14/2007 18:43'!
today
	^self onDate: Date today! !


!SpDate class methodsFor: 'private' stamp: 'JM 4/14/2007 18:46'!
integerOfLength: aLength FromString: aString
	"^an Integer or nil
	I parse an integer from aString, if I have problems I return nil.  I make sure
	the string form of the integer is exactly aLength characters long."
	"SpDate integerOfLength: 4 FromString: '2004'"
	^(aString size == aLength and: 
		[(aString asOrderedCollection select: [:aDigit | aDigit isDigit not]) isEmpty])
			ifFalse: [nil]
			ifTrue: [aString asNumber]! !

!SpDate class methodsFor: 'private' stamp: 'JM 4/26/2007 21:32'!
parseDateFromISO8601Stream: sourceStream	
	"^a Date or nil
	I parse an ISO 8601 date from sourceStream.  If there are any parsing
	problems, I return nil."
	| yyyy mm dd |
	yyyy := self integerOfLength: 4 FromString: (sourceStream upTo: $-).
	mm := self integerOfLength: 2 FromString: (sourceStream upTo: $-).
	dd := self integerOfLength: 2 FromString: (sourceStream next: 2).
	(yyyy isNil or: [mm isNil or: [dd isNil]]) ifTrue: [^nil].
	^SpExceptionContext 
		for: [Date newDay: dd month: mm year: yyyy]
		on: SpError
		do: [:ex | nil]! !


Object subclass: #SpTimestamp
	instanceVariableNames: 'underlyingTimestamp'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sport-Times'!

!SpTimestamp methodsFor: 'comparing' stamp: 'JM 4/26/2007 17:50'!
< aSpTimeStamp
	^self underlyingTimestamp < aSpTimeStamp underlyingTimestamp! !

!SpTimestamp methodsFor: 'comparing' stamp: 'JM 4/26/2007 17:50'!
= aSpTimeStamp
	^self underlyingTimestamp = aSpTimeStamp underlyingTimestamp! !

!SpTimestamp methodsFor: 'comparing' stamp: 'JM 4/26/2007 17:50'!
> aSpTimeStamp
	^self underlyingTimestamp > aSpTimeStamp underlyingTimestamp! !

!SpTimestamp methodsFor: 'comparing' stamp: 'JM 4/14/2007 18:55'!
hash
	^self underlyingTimestamp hash! !


!SpTimestamp methodsFor: 'converting' stamp: 'JM 4/18/2007 17:39'!
asDate
	^SpDate onDate: (self underlyingTimestamp asDate)! !

!SpTimestamp methodsFor: 'converting' stamp: 'JM 4/14/2007 18:58'!
asRFC1123String	
	"^a String
	c.f  >>asRFC1123StringOn: "

	| targetStream |
	targetStream := String new writeStream.
	self asRFC1123StringOn: targetStream.
	^targetStream contents! !

!SpTimestamp methodsFor: 'converting' stamp: 'JM 4/14/2007 19:00'!
asRFC1123StringOn: targetStream 
	"^self
	Code taken from Swazoo Timestamp extenton with the following comment: FIXME: Assumes 
	server's clock is GMT. Should convert server's clock to GMT if it is not. Besides that, 
	this whole method is really ugly."
	targetStream nextPutAll: (self underlyingTimestamp asDate weekday copyFrom: 1 to: 3);
		nextPutAll: ', '.
	self underlyingTimestamp day < 10 ifTrue: [targetStream nextPut: $0].
	self underlyingTimestamp asDate printOn: targetStream format: #(1 2 3 $  2 1).	
	targetStream space.
	self underlyingTimestamp printHMSOn: targetStream.
	targetStream nextPutAll: ' GMT'! !

!SpTimestamp methodsFor: 'converting' stamp: 'JM 4/14/2007 19:00'!
asSeconds
	"^an Integer
	I return the timestamp as a number of seconds."
	^self underlyingTimestamp asSeconds! !

!SpTimestamp methodsFor: 'converting' stamp: 'JM 4/26/2007 15:43'!
asSpTimestamp
	^self! !

!SpTimestamp methodsFor: 'converting' stamp: 'JM 4/25/2007 21:27'!
asTime
	^self underlyingTimestamp asTime! !


!SpTimestamp methodsFor: 'initialize-release' stamp: 'JM 4/14/2007 18:56'!
asNowUTC
	"^self
	Cheat for now and assumen that Timestamp>>now is UTC."
	underlyingTimestamp := TimeStamp now.
	^self! !

!SpTimestamp methodsFor: 'initialize-release' stamp: 'JM 4/18/2007 16:39'!
fromDate: aDate andTime: aTime
	"^self
	Initialize myself on the basis of aDate and aTime."
	underlyingTimestamp := TimeStamp date: aDate time: aTime.
	^self! !

!SpTimestamp methodsFor: 'initialize-release' stamp: 'JM 4/14/2007 18:57'!
fromSeconds: anInteger 
	"^a SpTimestamp
	I return an instance of myself that represents anInteger number of seconds 
	since January 1, 1901 0:00:00.000.  BTW, negative values of anInteger are fine."
	
	underlyingTimestamp := TimeStamp fromSeconds: anInteger.
	^self! !


!SpTimestamp methodsFor: 'private' stamp: 'mivsek 8/17/2007 16:16'!
printString
	^self underlyingTimestamp printString! !

!SpTimestamp methodsFor: 'private' stamp: 'JM 4/14/2007 19:00'!
underlyingTimestamp
	^underlyingTimestamp! !


!SpTimestamp methodsFor: '*Swazoo'!
asMilliseconds
	^self underlyingTimestamp 
		asMilliseconds! !

!SpTimestamp methodsFor: '*Swazoo' stamp: 'jmivsek 5/24/2020 17:32'!
fromMilliseconds: anInteger
	underlyingTimestamp :=
		TimeStamp fromMilliseconds: anInteger.
	^self
! !

!SpTimestamp methodsFor: '*Swazoo' stamp: 'janko 10/30/2012 10:54'!
milliseconds
	"Squeak specific"
	^self underlyingTimestamp nanoSecond // 1000
			
"SpTimestamp now milliseconds"! !


!SpTimestamp methodsFor: '*Aida' stamp: 'jm 2/7/2011 13:04'!
>= anOSkTimeStamp 
	^self underlyingTimestamp >= anOSkTimeStamp underlyingTimestamp! !

!SpTimestamp methodsFor: '*Aida' stamp: 'jm 2/4/2011 21:26'!
printSloString
	^self asDate shortPrintSloString, ' ', self asTime printSloString
! !

!SpTimestamp methodsFor: '*Aida' stamp: 'JM 4/22/2007 15:33'!
sendOver: aStream 
	"from Wiki rendering"
	self printOn: aStream
"
	TimestampPrintPolicy 
		print: (TimeZone default convertToGMT: self asSeconds
				do: [:date :seconds | Timestamp fromDate: date andTime: (Time fromSeconds: seconds)])
		on: aStream
		using: 'ddd, dd mmm yyyy hh:mm:ss GMT'
"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SpTimestamp class
	instanceVariableNames: ''!

!SpTimestamp class methodsFor: 'instance creation' stamp: 'JM 4/18/2007 17:15'!
fromDate: aDate andTime: aTime 
	^self new fromDate: aDate andTime: aTime! !

!SpTimestamp class methodsFor: 'instance creation' stamp: 'JM 4/18/2007 17:17'!
fromRFC1123String: aString
	"^a SpTimestamp"
	| sourceStream dd mmm yyyy time |
	^SpExceptionContext for:
		[sourceStream := ReadStream on: aString.
		sourceStream upTo: Character space.
		dd := sourceStream upTo: Character space.
		mmm := sourceStream upTo: Character space.
		yyyy := sourceStream upTo: Character space.
		time := sourceStream upTo: Character space.
		self fromDate: (Date 
				newDay: dd asNumber
				month: mmm
				year: yyyy asNumber)
			andTime: (Time readFrom: (ReadStream on: time))]
		onAnyExceptionDo: 
			[:exception | 
				SpError raiseSignal: 'Error parsing RFC1123 date: ' , aString]! !

!SpTimestamp class methodsFor: 'instance creation' stamp: 'JM 4/18/2007 17:18'!
fromSeconds: anInteger
	"^a SpTimestamp
	I return an instance of myself that represents anInteger number of seconds since..."
	^self new fromSeconds: anInteger! !

!SpTimestamp class methodsFor: 'instance creation' stamp: 'JM 4/18/2007 17:20'!
fromTimeStamp: aTimeStamp
	"^a SpTimestamp, from a Squeak TimeStamp"
	^self fromDate: aTimeStamp asDate andTime: aTimeStamp asTime! !

!SpTimestamp class methodsFor: 'instance creation' stamp: 'JM 4/18/2007 17:18'!
now
	"^a SpTimestamp
	I return a new instance of myself which represents the time now in the
	UTC (GMT ish) time zone."
	^self new asNowUTC! !


!SpTimestamp class methodsFor: '*Swazoo' stamp: 'jmivsek 5/24/2020 17:33'!
fromMilliseconds: anInteger 
	^self new
		fromMilliseconds: anInteger.
! !
