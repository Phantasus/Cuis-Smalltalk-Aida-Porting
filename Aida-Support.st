Object subclass: #AdvancedSearch
	instanceVariableNames: 'criteria results colMap'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Support'!
!AdvancedSearch commentStamp: '<historical>' prior: 0!
AdvancedSearch is used for set up a search criteria and also for generic search against collection of any objects.
Search criteria:
	- by default search string must be start part of an element in collection to come in results
	- use * before search string to search in the middle of strings 
      - "search string" for exact match (except case)

any method call open a new criteria in a dictionary

Instance Variables:
	criteria	<Dictionary>	 key is aspect, value is search key

!


!AdvancedSearch methodsFor: 'private'!
alignCriteria: aCriteriaDict aspect: aSymbol with: anObject
	"adjust type of search field with those in object's aspect"
	| objValue |
	objValue := anObject perform: aSymbol.
	(objValue isKindOf: Number) ifTrue: 
		[aCriteriaDict at: aSymbol put: (aCriteriaDict at: aSymbol) asNumber]! !

!AdvancedSearch methodsFor: 'private'!
colMap: anArrayOfSymbols
	colMap := anArrayOfSymbols! !

!AdvancedSearch methodsFor: 'private'!
colMapAt: anAspect ifAbsent: aBlock
	^self colMap detect: [:each | each first = anAspect] ifNone: aBlock! !

!AdvancedSearch methodsFor: 'private'!
criteria
	criteria isNil ifTrue: [self initCriteria].
	^criteria! !

!AdvancedSearch methodsFor: 'private'!
doesNotUnderstand: aMessage
	| aspect |
	aspect := (aMessage selector asString copyUpTo: $: ) asSymbol.
	(self criteria includesKey: aspect) ifFalse: [self criteria at: aspect put: ''].
	aMessage arguments notEmpty ifTrue: "mutator"
		[self criteria at: aspect put: aMessage arguments first].
	^self criteria at: aspect! !

!AdvancedSearch methodsFor: 'private'!
isExactMatchRequested: aString
	" if string is in quotation "
	aString isEmpty ifTrue: [^false].
	^aString trimBlanks first = $" and: [aString trimBlanks last = $" ]! !

!AdvancedSearch methodsFor: 'private'!
object: anObject match: aCriteria
	| objValue |
	aCriteria associationsDo: [:assoc | 
		(anObject class canUnderstand: assoc key) ifTrue:
			[objValue := anObject perform: assoc key.
			(objValue isKindOf: String) 
				ifTrue: 
					[(assoc value match: objValue) ifFalse: [^false] ] 
				ifFalse:  "numbers, dates etc."
					["self alignCriteria: aCriteria aspect: assoc key with: anObject."
					(assoc value match: objValue printString) ifFalse: [^false] ] ] ].
	^true! !

!AdvancedSearch methodsFor: 'private'!
preparedCriteria
	"just search fields, which are not empty"
	| dict |
	dict := Dictionary new.
	self criteria keysAndValuesDo: 
		[:key :value | 
			value trimBlanks notEmpty ifTrue:
				[(self isExactMatchRequested: value)
					ifTrue: [dict at: key put: (self withoutQuotation: value trimBlanks)]
					ifFalse: [dict at: key put: (value, '*')] ] ].
	^dict! !

!AdvancedSearch methodsFor: 'private'!
withoutQuotation: aString
	^aString copyFrom: 2 to: aString size -1! !


!AdvancedSearch methodsFor: 'column mappings'!
alignFor: anAspectSymbol
	"column align for that field. nil if not defined"
	^(self colMapAt: anAspectSymbol ifAbsent: [^nil])
		at: 5! !

!AdvancedSearch methodsFor: 'column mappings'!
colAligns
	"for auto columns in search results"
	^self colAlignsWithout: #()! !

!AdvancedSearch methodsFor: 'column mappings'!
colAlignsWithout: anArrayOfAspects
	"for auto columns in search results"
	| collection |
	collection := OrderedCollection new.
	(self colAspectsWithout: anArrayOfAspects) do: [:aspect || map |
		map := self colMapAt: aspect ifAbsent: [nil].
		collection add: (map notNil ifTrue: [map at: 5 "align" ifAbsent: [nil]]) ].
	^collection! !

!AdvancedSearch methodsFor: 'column mappings'!
colAspects
	"for auto columns in search results"
	| aspects sorted |
	aspects := self searchedAspects asSet.
	sorted := OrderedCollection new.
	self colMap do: [:map | (aspects includes: map first) ifTrue: [sorted add: map first]]. "sort by order in colMap"
	^sorted! !

!AdvancedSearch methodsFor: 'column mappings'!
colAspectsWithout: anArrayOfAspects
	"for auto columns in search results"
	^self colAspects select: [:each | (anArrayOfAspects includes: each) not]! !

!AdvancedSearch methodsFor: 'column mappings'!
colFilters
	"for auto columns in search results"
	^self colFiltersWithout: #()! !

!AdvancedSearch methodsFor: 'column mappings'!
colFiltersWithout: anArrayOfAspects
	"for auto columns in search results"
	| collection |
	collection := OrderedCollection new.
	(self colAspectsWithout: anArrayOfAspects) do: [:aspect || map |
		map := self colMapAt: aspect ifAbsent: [nil].
		collection add: (map notNil ifTrue: [map at: 4 "filter" ifAbsent: [nil]]) ].
	^collection! !

!AdvancedSearch methodsFor: 'column mappings'!
colMap
	"map of columns in results table, used also for search form"
	"#( (aspect,  title, size, filter align) (...) )"
	^colMap! !

!AdvancedSearch methodsFor: 'column mappings'!
colNames
	"for auto columns in search results"
	^self colNamesWithout: #()! !

!AdvancedSearch methodsFor: 'column mappings'!
colNamesWithout: anArrayOfAspects
	"for auto columns in search results"
	| collection |
	collection := OrderedCollection new.
	(self colAspectsWithout: anArrayOfAspects) do: [:aspect || map |
		map := self colMapAt: aspect ifAbsent: [nil].
		collection add: (map notNil ifTrue: [map at: 2 "title" ifAbsent: [nil]]) ].
	^collection! !

!AdvancedSearch methodsFor: 'column mappings'!
filterFor: anAspectSymbol
	"column filter yes/no/size for that field"
	^(self colMapAt: anAspectSymbol ifAbsent: [^nil])
		at: 4! !

!AdvancedSearch methodsFor: 'column mappings'!
nameFor: anAspectSymbol
	"column name/title for that field"
	^(self colMapAt: anAspectSymbol ifAbsent: [^nil])
		at: 2! !

!AdvancedSearch methodsFor: 'column mappings'!
sizeFor: anAspectSymbol
	"size for that field"
	^(self colMapAt: anAspectSymbol ifAbsent: [^nil])
		at: 3! !


!AdvancedSearch methodsFor: 'accessing'!
allAspects
	"all aspects from colMap"
	^self colMap collect: [:map | map first]! !

!AdvancedSearch methodsFor: 'accessing'!
aspects
	"all search aspects, with criteria set or not"
	^self criteria keys! !

!AdvancedSearch methodsFor: 'accessing'!
clear
	"clear all search fields"
	self criteria keysAndValuesDo: [:key :value | self criteria at: key put: ''].! !

!AdvancedSearch methodsFor: 'accessing'!
searchedAspects
	"aspect symbols, which have a search criteria set"
	^self preparedCriteria keys! !


!AdvancedSearch methodsFor: 'search form'!
allFieldsExcept: anExcludeAttrNameCollection to: anElement
	"build a search form for all aspects (accessors) of searched objects, except those in 
       exclude collection"
	| excludeSet |
	excludeSet := ((self colMap select: [:each | anExcludeAttrNameCollection includes: (each at: 2)])
		collect: [:each | each first]) 
			asSet.
	^self 
		fields: (self allAspects reject: [:each | excludeSet includes: each])
		to: anElement! !

!AdvancedSearch methodsFor: 'search form'!
allFieldsTo: anElement
	"build a search form for all aspects (accessors) of searched objects"
	^self fields: self allAspects to: anElement! !

!AdvancedSearch methodsFor: 'search form'!
fields: anArrayOfAspects to: anElement
	"build a search form for defined aspects (accessors) of searched objects"
	anArrayOfAspects do: [:aspect || name size |
		name := self nameFor: aspect.
		name last ~= $: ifTrue: [name := name, ':'].
		anElement cell addText: name.
		size := (self sizeFor: aspect) notNil ifTrue: [self sizeFor: aspect] ifFalse: [8].
		anElement newCell addInputFieldAspect: aspect for: self size: size.
		aspect ~= anArrayOfAspects last 
			ifTrue: [anElement newRow] ].! !


!AdvancedSearch methodsFor: 'initialize-release'!
initCriteria
	criteria := Dictionary new.! !

!AdvancedSearch methodsFor: 'initialize-release'!
initResults
	results := OrderedCollection new.! !


!AdvancedSearch methodsFor: 'search'!
results
	results isNil ifTrue: [self initResults].
	^results! !

!AdvancedSearch methodsFor: 'search'!
searchFrom: aCollection
	| preparedCriteria |
	preparedCriteria := self preparedCriteria.
	results := aCollection select: [:each | self object: each match: preparedCriteria].
	^self results! !


Object subclass: #DailyCollection
	instanceVariableNames: 'days'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Support'!
!DailyCollection commentStamp: '<historical>' prior: 0!
DailyCollection is a handy for domain model to store values in collections, one per a day. Used as kind of index for faster access to historical data, which is usally accessed newer mostly while older less and less.

Typical usage:
	aDailyCollection 
		add: aSomething onDate: Date today;
		allDated: Date today;
		allThisYear;
		allLastMonth;
		...!


!DailyCollection methodsFor: 'adding-removing' stamp: ' 21/4/07 22:07'!
add: newObject

	self add: newObject onDate: newObject date! !

!DailyCollection methodsFor: 'adding-removing' stamp: ' 21/4/07 22:07'!
add: newObject onDate: aDate
	(self includes: newObject onDate: aDate) ifTrue: [^nil].
	self existCheckDate: aDate.
	(self days at: aDate asDays) add: newObject.
	^newObject! !

!DailyCollection methodsFor: 'adding-removing' stamp: ' 21/4/07 22:07'!
addAll: aCollection 

	aCollection do: [:each | self add: each].
	^aCollection! !

!DailyCollection methodsFor: 'adding-removing' stamp: ' 21/4/07 22:07'!
addAll: aCollection onDate: aDate

	self existCheckDate: aDate.
	^aCollection do: [:each | 	self add: each onDate: aDate].! !

!DailyCollection methodsFor: 'adding-removing' stamp: 'JM 4/26/2007 21:29'!
addFirst: newObject inYear: aYear
	"put in first place at 1st jan of this year"
	| date |
	date := SpDate newDay: 1 month: 1 year: aYear.
	(self includes: newObject onDate: date) ifTrue: [^nil].
	self existCheckDate: date.
	(self days at: date asDays) addFirst: newObject.
	^newObject! !

!DailyCollection methodsFor: 'adding-removing' stamp: 'JM 4/26/2007 21:29'!
addLast: newObject inYear: aYear
	"put in first place at 1st jan of this year"
	| date |
	date := SpDate newDay: 31 month: 12 year: aYear.
	(self includes: newObject onDate: date) ifTrue: [^nil].
	self existCheckDate: date.
	(self days at: date asDays) addLast: newObject.
	^newObject! !

!DailyCollection methodsFor: 'adding-removing' stamp: ' 21/4/07 22:07'!
move: anObject fromDate: aDate toDate: aNewDate
	| collection |
	collection := self days at: aDate asDays.
	collection remove: anObject.
	self add: anObject onDate: aNewDate! !

!DailyCollection methodsFor: 'adding-removing' stamp: ' 21/4/07 22:07'!
remove: oldObject 
	^self remove: oldObject ifAbsent: [self notFoundError]! !

!DailyCollection methodsFor: 'adding-removing'!
remove: oldObject ifAbsent: anExceptionBlock
	| result |
	result := self remove: oldObject onDate: oldObject date.
	result isNil ifTrue: [^anExceptionBlock value].! !

!DailyCollection methodsFor: 'adding-removing'!
remove: oldObject onDate: aDate
	"remove if exist on that date, otherwise return nil"
	| collection |
	collection := self days at: oldObject date asDays ifAbsent: [^nil].
	collection remove: oldObject ifAbsent: [^nil].
	^oldObject! !

!DailyCollection methodsFor: 'adding-removing' stamp: ' 21/4/07 22:07'!
removeAll: aCollection 
	"Remove each element of aCollection from the receiver.  If successful for each,
	answer aCollection."
	aCollection do: [:each | self remove: each].
	^aCollection! !

!DailyCollection methodsFor: 'adding-removing'!
removeAnywhere: oldObject 
	"First find the right day then remove it. Use tham method if an object's date was changed later"
	self days values do: [:collection | 
		(collection includes: oldObject) ifTrue: 
			[collection remove: oldObject. 
			^true] ].
	^false! !


!DailyCollection methodsFor: 'private-accessing'!
all
	"sorted by recent first"
	| dayCol |
	dayCol := SortedCollection
		withAll: self days keys
		sortBlock: [:a :b | a > b].
	^dayCol 
		inject: OrderedCollection new 
		into: [:col :each | 
			col 
				addAll: (self days at: each) reverse; 
				yourself ].! !

!DailyCollection methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
allDays
	"all day numbers on which something exist"
	^self days keys! !

!DailyCollection methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
allDaysForKindOf: aClass
	"all day numbers on which something of that class exist"
	^self days keys select: [:day | 
		(self days at: day) contains: [:each | each isKindOf: aClass] ].! !

!DailyCollection methodsFor: 'private-accessing' stamp: 'janko 8/3/2011 20:34'!
allYearsForKindOf: aClass
	"all years on which something of that class exist"
	| allDays year years skipToDay |
	allDays := self days keys asSortedCollection. allDays isEmpty ifTrue: [^#()].
	years := Set new. skipToDay := 0.
	allDays do: [:day |
		day >= skipToDay ifTrue:
			[((self days at: day) contains: [:entry | entry isKindOf: aClass]) ifTrue:
				[year := (Date fromDays: day) year.
				years add: year. 
				skipToDay := (Date newDay: 1 monthNumber: 1 year: year+1) asDays] ] ].
	^years asSortedCollection asOrderedCollection

"DailyCollection allInstances last allYearsForKindOf: Invoice "! !


!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allDated: aDate

	^(self days at: aDate asDays ifAbsent: [^#()] ) copy! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allDates
	"all dates on which something exist"
	^self allDays collect: [:each | Date fromDays: each]! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allFromDate: aStartDate to: anEndDate
	| startDay endDay daysInRange |
	startDay := aStartDate asDays. endDay := anEndDate asDays.
	daysInRange := self allDays select: [:each | each >= startDay and: [each <= endDay] ].
	daysInRange := daysInRange asSortedCollection. 
	^daysInRange inject: OrderedCollection new into: [:col :each | col addAll: (self days at: each). col]

"DailyCollection allInstances last allFromDate: (Date readSloFrom: '1.1.2004' readStream) 
  	to: (Date readSloFrom: '31.12.2006' readStream)"! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allLastMonth
	^self allMonthly: Date today - Date today day! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allLastWeek
	^self allWeekly: Date today - 7! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allLastYear
	^self allYear: Date today year - 1! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allMonthly: aDate
	^self 
		allFromDate: aDate firstDayOfMonth
		to: aDate firstDayInMonth + aDate daysInMonth - 1! !

!DailyCollection methodsFor: 'accessing' stamp: 'np 3/29/2008 05:18'!
allSinceDate: aDate
	^self allFromDate: aDate to: SpDate today! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allThisMonth
	^self allMonthly: Date today! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allThisWeek
	^self allWeekly: Date today! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allThisYear
	^self allYear: Date today year! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allToday
	^self allDated: Date today! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allWeekly: aDate
	^self 
		allFromDate: aDate - aDate weekdayIndex + 1
		to: aDate - aDate weekdayIndex + 1 + 7! !

!DailyCollection methodsFor: 'accessing' stamp: 'JM 4/26/2007 21:30'!
allYear: aNumber
	^self 
		allFromDate: (SpDate newDay: 1 month: 1 year: aNumber)
		to: (SpDate newDay: 31 month: 12 year: aNumber)! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allYears
	"all years on which something exist"
	^SortedCollection 
		withAll: (self allDates inject: Set new into: [:set :each | set add: each year. set])
		sortBlock: [:a :b | a < b]

"DailyCollection allInstances last allYears"! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allYesterday
	^self allDated: Date today - 1! !

!DailyCollection methodsFor: 'accessing'!
first
	"find the oldest value"
	self isEmpty ifTrue: [^nil].
	^(self first: 1) first! !

!DailyCollection methodsFor: 'accessing'!
first: aNumber
	"find first (oldest) number of values, starting from first day on. Oldest first!!"
	| collection dayColl |
	collection := OrderedCollection new.
	dayColl := SortedCollection withAll: self days keys sortBlock: [:a :b | a < b].
	dayColl do: [:day || coll |
		coll := (self days at: day) copy.
		collection addAll: (coll copyFrom: 1 to: ((aNumber - collection size) min: coll size) ).
		collection size = aNumber ifTrue: [^collection] ].
	^collection

"LogisticSystem default owner events size last: 1000"! !

!DailyCollection methodsFor: 'accessing'!
firstDayInYear: aYear
	"on 1 januar of that year"
	^self allDated: (Date newDay: 1 monthNumber: 1 year: aYear).! !

!DailyCollection methodsFor: 'accessing'!
firstInYear: aYear
	"on 1st january of that year"
	| col |
	col := self firstDayInYear: aYear.
	col isEmpty ifTrue: [^nil].
	^col first! !

!DailyCollection methodsFor: 'accessing'!
last
	"find last values, starting from today and back in past. Most recent first!!"
	self isEmpty ifTrue: [^nil].
	^(self last: 1) first! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
last: aNumber
	"find last number of values, starting from today and back in past. Most recent first!!"
	| collection dayColl |
	collection := OrderedCollection new.
	dayColl := SortedCollection withAll: self days keys sortBlock: [:a :b | a > b].
	dayColl do: [:day || coll |
		coll := (self days at: day) copy reverse.
		collection addAll: (coll copyFrom: 1 to: ((aNumber - collection size) min: coll size) ).
		collection size = aNumber ifTrue: [^collection] ].
	^collection

"LogisticSystem default owner events size last: 1000"! !

!DailyCollection methodsFor: 'accessing' stamp: 'JM 4/26/2007 21:31'!
lastDayInYear: aYear
	"on 31 december of that year"
	^self allDated: (SpDate newDay: 31 month: 12 year: aYear).! !

!DailyCollection methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
size
	days isNil ifTrue: [^0].
	^self days values inject: 0 into: [:sum :each | sum + each size].! !


!DailyCollection methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
contains: aBlock 
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Answer true if aBlock ever evaluates to true, otherwise answer false."

	self detect: aBlock ifNone: [^false].
	^true! !

!DailyCollection methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
includes: anObject
	"Answer whether anObject is one of the receiver's elements."

	self days values do: [:each | (each includes: anObject) ifTrue: [^true]].
	^false! !

!DailyCollection methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
includes: anObject onDate: aDate
	| values |
	values := self days at: aDate asDays ifAbsent: [^false].
	^values includes: anObject! !

!DailyCollection methodsFor: 'testing'!
includesYear: aNumber
	"anything on that year?"
	| start end |
	self isEmpty ifTrue: [^false].
	start := (Date newDay: 1 monthNumber: 1 year: aNumber) asDays.
	end := (Date newDay: 31 monthNumber: 12 year: aNumber) asDays.
	^self allDays contains: [:day | day between: start and: end]! !

!DailyCollection methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isEmpty
	"Answer whether the receiver contains any elements."

	^self size = 0! !


!DailyCollection methodsFor: 'private' stamp: ' 21/4/07 22:07'!
days
	days isNil ifTrue: [self initDays].
	^days! !

!DailyCollection methodsFor: 'private' stamp: ' 21/4/07 22:07'!
existCheckDate: aDate

	(self days includesKey: aDate asDays) ifFalse:
		[self days at: aDate asDays put: OrderedCollection new].! !

!DailyCollection methodsFor: 'private' stamp: ' 21/4/07 22:07'!
initDays
	days := Dictionary new.! !


Object subclass: #DailyValues
	instanceVariableNames: 'days'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Support'!
!DailyValues commentStamp: '<historical>' prior: 0!
DailyValues is a handy for domain model to store values, one per a day. Used as kind of index for faster access to historical data, which is usally accessed newer mostly while older less and less. 

Typical usage:
	aDailyValue 
		at: Date today put: 1234;
		at: Date today add: 10;  "adds to previous value"
		allFromDate: Date doday -5 to: Date today;
		allThisWeek;
		allLastMonth;
		...
!


!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allDates
	"all dates on which something exist"
	^self days keys collect: [:each | Date fromDays: each]! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allFromDate: aStartDate to: anEndDate

	| collection |
	collection := OrderedCollection new: 100.
	aStartDate to: anEndDate do: [:date |
		collection add: (self at: date) ].
	^collection! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allLastMonth
	^self allMonthly: Date today - Date today day! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allLastWeek
	^self allWeekly: Date today - 7! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allMonthly: aDate
	^self 
		allFromDate: aDate firstDayOfMonth
		to: aDate firstDayInMonth + aDate daysInMonth - 1! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allThisMonth
	^self allMonthly: Date today! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allThisWeek
	^self allWeekly: Date today! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
allWeekly: aDate
	^self 
		allFromDate: aDate - aDate weekdayIndex + 1
		to: aDate - aDate weekdayIndex + 1 + 7! !

!DailyValues methodsFor: 'accessing'!
current
	"return current value"
	^self atOrLastFrom: Date today! !

!DailyValues methodsFor: 'accessing' stamp: 'jm 8/1/2010 11:13'!
last
	"return value on last (most future) date entered"
	^self at: self lastDate! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
last: aNumber
	"find last number of values, starting from today and back in past. Most recent first!!"
	| collection |
	collection := OrderedCollection new.
	1 to: aNumber do: [:inx | collection add: (self at: Date today - inx + 1)].
	^collection! !

!DailyValues methodsFor: 'accessing'!
lastDate
	"return date on last (most future) value entered"
	| coll |
	coll := self days keys asSortedCollection.  "not very optimized way for big colections!! "
	coll isEmpty ifTrue: [^nil].
	^Date fromDays: coll last! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
size
	^self days values size! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
sumFromDate: aStartDate to: anEndDate

	^(self allFromDate: aStartDate to: anEndDate)
		inject: 0
		into: [:sum :each | sum + each]! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
sumLast: aNumber
	"sum values of aNumber of days, starting from today and back"

	^(self last: aNumber)
		inject: 0
		into: [:sum :each | sum + each]! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
sumMonthly: aDate

	^(self allMonthly: aDate)
		inject: 0
		into: [:sum :each | sum + each]! !

!DailyValues methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
sumWeekly: aDate

	^(self allWeekly: aDate)
		inject: 0
		into: [:sum :each | sum + each]! !


!DailyValues methodsFor: 'adding-removing'!
at: aDate
	^self at: aDate ifAbsent: [self defaultValue]! !

!DailyValues methodsFor: 'adding-removing'!
at: aDate add: aValue 
	self existCheckDate: aDate.
	^self days at: aDate asDays put: (self at: aDate) + aValue! !

!DailyValues methodsFor: 'adding-removing'!
at: aDate ifAbsent: aBlock
	^self days at: aDate asDays ifAbsent: [aBlock value]! !

!DailyValues methodsFor: 'adding-removing'!
at: aDate put: aValue
	self existCheckDate: aDate.
	^self days at: aDate asDays put: aValue! !

!DailyValues methodsFor: 'adding-removing'!
at: aDate subtract: aValue
	self existCheckDate: aDate.
	^self days at: aDate asDays put: (self at: aDate) - aValue! !

!DailyValues methodsFor: 'adding-removing'!
atOrLastFrom: aDate
	"return value on that date or last date when some value exist"
	^self at: aDate ifAbsent: [self lastFrom: aDate]! !

!DailyValues methodsFor: 'adding-removing'!
resetAt: aDate
	"put default value at this date"
	^self at: aDate put: self defaultValue! !


!DailyValues methodsFor: 'private' stamp: ' 21/4/07 22:07'!
days
	days isNil ifTrue: [self initDays].
	^days! !

!DailyValues methodsFor: 'private' stamp: ' 21/4/07 22:07'!
defaultValue
	^0! !

!DailyValues methodsFor: 'private' stamp: ' 21/4/07 22:07'!
existCheckDate: aDate

	(self days includesKey: aDate asDays) ifFalse:
		[self days at: aDate asDays put: self defaultValue].! !

!DailyValues methodsFor: 'private' stamp: ' 21/4/07 22:07'!
initDays
	days := IdentityDictionary new.! !

!DailyValues methodsFor: 'private' stamp: ' 21/8/07 09:38'!
lastDateFrom: aDate
	"search back in time for some date on which a value exist and return that date"
	| start |
	start := aDate asDays.
	self days keys asSortedCollection reverse do:  "not very optimized way for big colections!! "
		[:day | day <= start ifTrue: [^Date fromDays: day] ].
	^nil! !

!DailyValues methodsFor: 'private' stamp: ' 21/8/07 09:38'!
lastFrom: aDate
	"search back in time for some date on which a value exist and return it"
	| start |
	start := aDate asDays.
	self days keys asSortedCollection reverse do:  "not very optimized way for big colections!! "
		[:day | day <= start ifTrue: [^self days at: day] ].
	^nil! !


!DailyValues methodsFor: 'testing' stamp: ' 21/4/07 22:07'!
isEmpty
	"Answer whether the receiver contains any elements."

	^self size = 0! !


Object subclass: #DelimitedFile
	instanceVariableNames: 'filename delimiter codepage records'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Support'!
!DelimitedFile commentStamp: 'janko 7/8/2011 23:21' prior: 0!
DelimitedFile for reading and writing files in CSV format.

Example:
	records := (DelimitedFile new delimiter: $, ; codepage: #cp1250; readFrom: 'somedata.csv') records.
	records do: [:record | "do something on this array of fields"]

Default delimiter is $; and default codepage #UTF8. You can change it to, say,  #cp1250 (Central European) or others, see AIDASite class codepage converting for all possibilities


!


!DelimitedFile methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
codepage
	codepage isNil ifTrue: [self codepage: self defaultCodepage].
	^codepage! !

!DelimitedFile methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
codepage: aSymbol
	" #cp1250  #iso2 #'7bit'"
	codepage := aSymbol.! !

!DelimitedFile methodsFor: 'accessing'!
defaultCodepage
	^#UTF8
"	^#cp1250 " "Windows"! !

!DelimitedFile methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
defaultDelimiter
	"default delimiter is ; "

	^$;! !

!DelimitedFile methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
delimiter
	"delimiter is a character, which separate fields in a delimited file"
	delimiter isNil ifTrue: [self delimiter: self defaultDelimiter].
	^delimiter! !

!DelimitedFile methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
delimiter: aCharacter
	"delimiter is a character, which separate fields in a delimited file"
	delimiter := aCharacter.! !

!DelimitedFile methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
filename
	^filename! !

!DelimitedFile methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
filename: aFilename
	filename := aFilename.! !

!DelimitedFile methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
records
	"when aDelimitedFile is created on a existing file, all records (lines in a file) are 
	converted and stored in this ordered collection. Fields in each record are stored in 
	another ordered collection as objects of appropriate class (texts as Strings, 
	numbers as Integers or Floats, dates as Dates)"

	records isNil ifTrue: [self records:OrderedCollection new].
	^records! !

!DelimitedFile methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
records: aCollection
	records := aCollection.! !


!DelimitedFile methodsFor: 'private'!
crlf
	"return an cr-lf combination"

	^(Character cr) asSymbol , (Character lf) asSymbol.! !

!DelimitedFile methodsFor: 'private'!
endOfLine: aStream
	"return true if we are at the end of line (on cr or lf characters)"
	aStream peek isNil ifTrue: [^true].
	^(aStream peek asCharacter = Character cr or: [aStream peek asCharacter = Character lf]).! !

!DelimitedFile methodsFor: 'private' stamp: ' 21/4/07 22:07'!
newRecordFrom: aStream

	"read one line from delimited file, detect and separate fields and convert to
	appropriate objects into an ordered collection. return that collection"

	| collection field |
	collection := OrderedCollection new.
	[self endOfLine: aStream] whileFalse:
		[field := self readFieldFrom: aStream.
		collection add: field].
	self skipEndOfLine: aStream.
	^collection! !

!DelimitedFile methodsFor: 'private'!
readFieldFrom: aStream
	"read one field from delimited file, and convert to appropriate object. Return that object"
	| object stream |
	aStream peek asCharacter = $" ifTrue:  "start of a text field"
		[object := aStream upTo: $" asInteger; upTo: $" asInteger.
		(self endOfLine: aStream) ifFalse: [aStream upTo: self delimiter asInteger].
		^self codepage = #'7bit' 
			ifTrue: [AIDASite oldConvertToUnicode: (AIDASite returnCP852From7BitString: object asByteString)]
			ifFalse: [AIDASite convert: object asByteString fromCodepage: self codepage] ].
	stream := WriteStream on: ByteArray new.
	[aStream peek asCharacter = self delimiter or: [self endOfLine: aStream]] 
		whileFalse: [aStream peek isNil ifTrue: [^stream contents]. stream nextPut: aStream next].
	aStream peek asCharacter = self delimiter ifTrue: [aStream skip: 1].
	object := stream contents asByteString. stream close.
	^object
"
	(object includes: $. ) false
		ifTrue:
			[(Date readSloFrom: object readStream) notNil 
				ifTrue: [^Date readSloFrom: object readStream]
				ifFalse: [^object asInteger]]
		ifFalse: [^object asInteger].
"! !

!DelimitedFile methodsFor: 'private'!
skipEndOfLine: aStream

	"skip all cr and lf characters)"

	[aStream atEnd] whileFalse: 
		[(aStream peek asCharacter = Character cr or: [aStream peek asCharacter = Character lf]) 
			ifTrue:	[aStream skip: 1]
			ifFalse: [^self]
		].! !


!DelimitedFile methodsFor: 'initialize - release' stamp: ' 21/4/07 22:07'!
initialize! !


!DelimitedFile methodsFor: 'file reading'!
readFrom: aFilenameString
	"read a delimited file and convert content to object representation in 'records' collection"
	| stream | 
	self filename: (SpFilename named: aFilenameString).
	[stream :=  self filename readStream.
	self readFromStream: stream] 
		ensure: [stream close].

"DelimitedFile readFrom: 'm:\geoplin\tarifni\exports\ddnevnik.txt' "! !

!DelimitedFile methodsFor: 'file reading'!
readFromStream: aBinaryStream
	"read a delimited file and convert content to object representation in 'records' collection"
	[aBinaryStream atEnd] whileFalse: [self records add: (self newRecordFrom: aBinaryStream)]! !


!DelimitedFile methodsFor: 'file writing' stamp: ' 21/4/07 22:07'!
writeRecord: anArray to: aStream

	| dm data1 |
	dm := false.
	anArray do: [:data |
		dm ifTrue: [aStream nextPut: self delimiter].
		(data isKindOf: Integer) ifTrue: [aStream nextPutAll: data printString].
		(data isKindOf: String) ifTrue: 
			[data1 := AIDASite returnCSZFromCP852String:  data.
			data1 := data1 select: [:ch | ch asInteger <=255].
			aStream nextPutAll: '"',data1,'"'].
		(data isKindOf: FixedPoint) ifTrue: 
			[data1 := data printDotString select: [:ch | ch ~= $. ].
			aStream nextPutAll: data1].
		dm := true].
	aStream nextPutAll: self crlf.! !

!DelimitedFile methodsFor: 'file writing' stamp: ' 21/4/07 22:07'!
writeToFile
	self writeToFile: self filename.
"
|dmFile|
dmFile := DelimitedFile fileToWrite: 'test.dat'.
dmFile records 
	add: (Array with: 123 with: 'abcd' with: 345);
	add: (Array with: 234 with: 'CDE' with: 567).
dmFile writeToFile
"! !

!DelimitedFile methodsFor: 'file writing' stamp: ' 21/4/07 22:07'!
writeToFile: aFilenameString
	"export all records to delimited file"
	| stream | 
	self filename: aFilenameString asFilename.
	[stream :=  self filename writeStream.
	records do: [:record | self writeRecord: record to: stream] ]
		ensure: [stream close].
"
|dmFile|
dmFile := DelimitedFile new.
dmFile records 
	add: (Array with: 123 with: 'abcd' with: 345);
	add: (Array with: 234 with: 'CDE' with: 567).
dmFile writeToFile: 'test.dat'
"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

DelimitedFile class
	instanceVariableNames: ''!

!DelimitedFile class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
fileToWrite: aFilenameString

	"create a new instance on a specified (empty) file to write. After you fill records attribute with all
	data, call writeToFile method to do actual exporting to this file"

	| instance |
	instance := self new.
	instance filename: aFilenameString asFilename.
	^instance.! !

!DelimitedFile class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !

!DelimitedFile class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
readFrom: aFilenameString

	"read a specified delimited file and store records in a records attribute. Use default delimiter
	for field separator (character ; )"

	| instance |
	instance := self new.
	instance readFrom: aFilenameString.
	^instance.

"DelimitedFile readFrom: 'i:\projekti\dare\proizvod.txt' "! !


Object subclass: #EMailMessenger
	instanceVariableNames: 'repository queue sendingLoop client mailbox receivingLoop'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Support'!
!EMailMessenger commentStamp: '<historical>' prior: 0!
For sending and receiving e-mails

Port from VW, not yet finished!!!


!EMailMessenger methodsFor: 'private-sending'!
adapt: aString
	"correct some characters to suit the emailer and its bugs"
	"EMailMessenger new adapt: 'BOZ^IC^' convertToSloveneChars"
	| win in out ch |
	win := true. "SpEnvironment onWindows."
	in := aString readStream.
	out := WriteStream on: aString class new.
	[in atEnd] whileFalse:
		[ch := in next.
		win ifTrue: [ch = AIDASite charC ifTrue: [ch := $C] ].  "problem with SMTPClient on Windows"
		out nextPut: ch].
	^out contents! !

!EMailMessenger methodsFor: 'private-sending'!
privSendMessage: aRFC822Message reportError: aReportSymbol
	| errorText |
	[aRFC822Message fromSendStrings isEmpty 
		ifTrue: [aRFC822Message from: self repository adminEMail].
	self client 
		connect;
		useAuthentication: false; "for now"
		login;
		sendMessage: aRFC822Message;
		quit.
	self reportMailSend: aRFC822Message]
			on: Error
			do: [:ex | errorText := ex class name, ': ', ex errorString.
				Transcript cr; show: 'e-mail sending on ', self repository site name, ' failed: ', errorText; cr.
				(Delay forMilliseconds: 1000) wait.
				aReportSymbol = #repeat ifTrue:
					[Transcript show: 'repeating: '.
					self privSendMessage: aRFC822Message reportError: #report].
				aReportSymbol = #report ifTrue:
					[self notifyError: errorText toSenderOf: aRFC822Message] ].
	(Delay forMilliseconds: 200) wait.! !

!EMailMessenger methodsFor: 'private-sending'!
reportMailSend: aRFC822Message
	| receiver subject |
	receiver := aRFC822Message toSendStrings first.
	(receiver includes: $<) ifTrue: [receiver := receiver readStream upTo: $<; upTo: $>].
	subject := aRFC822Message subject asSloveneWithoutCircumflexes contractTo: 40.
	Transcript cr; show: 'e-mail sent to: ', receiver, ' ', subject
		.! !

!EMailMessenger methodsFor: 'private-sending'!
senderProcess
	[ [true] whileTrue: 
		[self 
			privSendMessage: self queue next 
			reportError: #repeat] 
	] 
		on: Error 
		do: [:ex | self halt]. "to find the cause of termination"! !

!EMailMessenger methodsFor: 'private-sending'!
sendingLoop
	"sender process"
	^sendingLoop! !

!EMailMessenger methodsFor: 'private-sending'!
sendingLoop: aProcess
	sendingLoop := aProcess! !


!EMailMessenger methodsFor: 'receiving'!
anyNewMail
	^self mailbox deliveryQueue notEmpty! !

!EMailMessenger methodsFor: 'receiving' stamp: 'janko 8/8/2011 19:12'!
startReceiving
	"start receiving documents from e-mail account"
	| block doc |
"	self mailbox startFetchingMail. "
"temporary off, not yet migrated!! "	
"	self receivingLoop notNil ifTrue: [self stopReceiving].
	block := 
		[ [true] whileTrue: 
			[doc := self getMailDocument.
			self dealWithDocument: doc] ].
	self receivingLoop: block fork."! !


!EMailMessenger methodsFor: 'private'!
client
	"a SMTP client"
	client isNil ifTrue: [self initClient].
	^client! !

!EMailMessenger methodsFor: 'private'!
emailAddressFor: aPersonOrCollection
	"one or more email addresses, separated with comma"
	| collection |
	(aPersonOrCollection isKindOf: String) ifTrue: [^(self adapt: aPersonOrCollection)].
	collection := (aPersonOrCollection isKindOf: Collection) 
		ifTrue: [aPersonOrCollection] ifFalse: [Array with: aPersonOrCollection].
	collection := collection select: [:each | each notNil and: [each email isValidEMailAddress]].
	collection isEmpty ifTrue: [^'User has no email!! <info@eranova.si>'].
	^self adapt: (collection inject: '' into: [:string :each |    "no full name, just plain address!! "
				(string = '' ifTrue: [''] ifFalse: [string, ', ']), each email])
"	^self adapt: (collection inject: '' into: [:string :each |
				(string = '' ifTrue: [''] ifFalse: [string, ', ']), '""', each nameSurname, '"" <', each email, '>'])
					ensureUnicodeSloveneChars
"! !

!EMailMessenger methodsFor: 'private'!
repository: aRepository
	repository := aRepository! !

!EMailMessenger methodsFor: 'private'!
site: anAIDASite
	self repository: anAIDASite repository "temporary, to more easy migrate"! !


!EMailMessenger methodsFor: 'examples' stamp: 'jm 11/10/2010 15:03'!
exampleICalMeeting
	| event calendar |
	event := ICEvent summary: 'Example meeting'.
	event 
"		textualDescription: (self url, (String with: Character cr), self agendaText); "
		uid: ICSqueakUUIDStrategy new generateUid;
		start: (SpTimestamp now addSeconds: 24*3600)  asSqueakDateAndTime;
		end: (SpTimestamp now addSeconds: 25*3600)  asSqueakDateAndTime;
		organizer: (ICUser new
				commonName: 'Janko'; 
				emailAddress: 'janko@eranova.si');
		location: 'Room 123';
		beMediumPriority; 
		beOpaque;
		beConfirmed. 
	calendar := ICCalendar name: 'aida'.
	calendar method: ICCalendar methodRequest.
	calendar addEvent: event.
 	^(ICCalendarExporter calendar: calendar) 
		export dataStream contents copyReplaceAll: String crlf with: (String with: Character cr)! !

!EMailMessenger methodsFor: 'examples'!
receiveExample
	"(AIDASite named: 'biart') repository messenger receiveExample"
	"returns an email message if received, otherwise nil"
	"Setup POP3 server, username and password first in repository settings!!"
	self startReceiving.
	self anyNewMail ifFalse: [^nil].
	^self getMail! !

!EMailMessenger methodsFor: 'examples'!
sendExample
	"(AIDASite named: 'aidademo') repository messenger sendExample"
	"Setup SMTP server first in repository settings!!"
	| body from to |
	body := 'Emailing test'.
	from := Person new email: 'aida@eranova.si'.
	to := Person new email: 'janko@eranova.si'.
	self 
		sendSubject: 'Aida Emailer test' body: body 
		from: from to: to! !

!EMailMessenger methodsFor: 'examples'!
sendICalExample
	"(AIDASite named: 'aidademo') repository messenger sendICalExample"
	"Setup SMTP server first in repository settings!!"
	| body from to |
	body := 'Test meeting call'.
	from := Person new email: 'aida@eranova.si'.
	to := Person new email: 'janko.testni@eranova.si'.
	self 
		sendSubject: 'Aida Meeting call test' body: body 
		icalName: 'meeting.ics'
		content: self exampleICalMeeting
		from: from to: to! !


!EMailMessenger methodsFor: 'initialize-release'!
initClient
	client := self class smtpClientClass host: self repository emailSMTPServer.
	self repository emailSMTPUsername trimBlanks notEmpty ifTrue:
		[client username: self repository emailSMTPUsername.
		client user password: self repository emailSMTPPassword.]! !

!EMailMessenger methodsFor: 'initialize-release'!
initMailbox
	mailbox notNil ifTrue: [mailbox stopFetchingMail].
	mailbox := AIDA.Mailbox new.
	mailbox 
		username: self repository emailPOP3Username;
		password: self repository emailPOP3Password;
		server: self repository emailPOP3Server.
	mailbox 	startFetchingMail! !

!EMailMessenger methodsFor: 'initialize-release'!
initQueue
	queue := SharedQueue new.
	self initSenderProcess.! !

!EMailMessenger methodsFor: 'initialize-release'!
initSenderProcess
	self sendingLoop ifNotNil: 
		[self sendingLoop terminate].
	self sendingLoop: 
		([self senderProcess] 
			forkAt: Processor userBackgroundPriority).! !


!EMailMessenger methodsFor: 'sending'!
isSendingStarted
	^self sendingLoop notNil! !

!EMailMessenger methodsFor: 'sending' stamp: 'jm 8/2/2010 13:39'!
sendSubject: aSubjectString body: aBodyString attachFile: aFilenameString content: aContentString from: aPerson to: aPersonOrCollection
	"VW specific!!"
	| message receiverAddresses body attachment |
	receiverAddresses := self emailAddressFor: aPersonOrCollection.
	receiverAddresses isEmpty ifTrue: [^nil].
	message := MailMessage newTextPlain. 
	body := "ObjectMemory versionId at: 5" true >= 76 "7.6?" 
		ifTrue: [aBodyString copyReplaceAll: (String with: Character cr) with: String crlf ] "why after 7.6?"
		ifFalse: [aBodyString].
	message 
		charset: 'UTF-8'; headerCharset: 'UTF-8'; 
		from: (self emailAddressFor: aPerson); 
		to: receiverAddresses; 
		subject: (self adapt: aSubjectString convertToSloveneChars);
		text: (self adapt: body convertToSloveneChars ensureUnicodeSloveneChars).
 	message addContentTransferEncoding: '8bit'.
	aFilenameString notNil ifTrue:
		["attachment := MimeEntity new."
		attachment fileName: aFilenameString; 
			contentType: ("MimeEntity mimeTypeForFile: aFilenameString" true).
		attachment body source: aContentString readStream. 
		attachment addContentTransferEncoding: '8bit'.
		message addPart: attachment].
	self queue nextPut: message.! !

!EMailMessenger methodsFor: 'sending'!
sendSubject: aSubjectString body: aBodyString attachFile: aFilename from: aPerson to: aPersonOrCollection
	"VW specific"
	| message receiverAddresses body |
	receiverAddresses := self emailAddressFor: aPersonOrCollection.
	receiverAddresses isEmpty ifTrue: [^nil].
	message := Net.MailMessage newTextPlain. 
	body := (ObjectMemory versionId at: 5) >= 76 "7.6?" 
		ifTrue: [aBodyString copyReplaceAll: (String with: Character cr) with: String crlf ] "why after 7.6?"
		ifFalse: [aBodyString].
	message 
		charset: 'UTF-8'; headerCharset: 'UTF-8'; 
		from: (self emailAddressFor: aPerson); 
		to: receiverAddresses; 
		subject: (self adapt: aSubjectString convertToSloveneChars);
		text: (self adapt: body convertToSloveneChars ensureUnicodeSloveneChars).
 	message addContentTransferEncoding: '8bit'.
	message addFileAttachment: aFilename .
	self queue nextPut: message.! !

!EMailMessenger methodsFor: 'sending'!
sendSubject: aSubjectString body: aBodyString from: aPerson to: aPersonOrCollection
	^self 
		sendSubject: aSubjectString body: aBodyString 
		attachFile: nil content: nil 
		from: aPerson to: aPersonOrCollection! !

!EMailMessenger methodsFor: 'sending'!
sendSubject: aSubjectString body: aBodyString icalName: anICalNameString content: anICalString from: aPerson to: aPersonOrCollection
	"VW specific"
	| message receiverAddresses body iCalString attachment |
	receiverAddresses := self emailAddressFor: aPersonOrCollection.
	receiverAddresses isEmpty ifTrue: [^nil].
	body := (ObjectMemory versionId at: 5) >= 76 "7.6?"  
			"SystemUtils version"  " SystemUtils.SystemVersionName"
		ifTrue: [aBodyString copyReplaceAll: (String with: Character cr) with: String crlf ] "why after 7.6?"
		ifFalse: [aBodyString].
	message := Net.MailMessage new. 
	message 
		charset: 'UTF-8'; headerCharset: 'UTF-8'; 
		from: (self emailAddressFor: aPerson); 
		to: receiverAddresses; 
		subject: (self adapt: aSubjectString convertToSloveneChars);
		text: (self adapt: body convertToSloveneChars ensureUnicodeSloveneChars).
 	message addContentTransferEncoding: 'base64' "'8bit'".
	anICalNameString notNil ifTrue:
		[attachment := Net.MimeEntity new.
		attachment 
"			fileName: anICalNameString; "
			contentType: ('text/calendar; method=REQUEST; charset=UTF-8; name=', 
				anICalNameString);
"			contentDisposition: 'attachment'. "
			contentDisposition: 'inline'. "Lotus Notes 6.5 requests inline, does not recognize attachment!! "
		iCalString := (ObjectMemory versionId at: 5) >= 76 "7.6?" 
			ifTrue: [anICalString copyReplaceAll: (String with: Character cr) with: String crlf ] "why after 7.6?"
			ifFalse: [anICalString].
		attachment body source: iCalString readStream. 
		attachment addContentTransferEncoding: '7bit'.
		message addPart: attachment].
	self queue nextPut: message.! !


!EMailMessenger methodsFor: 'accessing'!
mailbox
	mailbox isNil ifTrue: [self initMailbox].
	^mailbox! !

!EMailMessenger methodsFor: 'accessing'!
queue
	queue ifNil: [self initQueue].
	^queue.! !

!EMailMessenger methodsFor: 'accessing'!
repository
	^repository! !

!EMailMessenger methodsFor: 'accessing'!
site
	^self repository site "temporary"! !


!EMailMessenger methodsFor: 'private-error reports'!
messageForError: anErrorString for: aRFC822Message
	| text |
	text := 'Napaka pri pos^iljanju e-pos^te

	', anErrorString, '

prejemnik: ', aRFC822Message to first.

	text := text, '  

To je samodejno sporoc^ilo iz informacijskega portala sistema kakovosti BiArt.'.

	^text! !

!EMailMessenger methodsFor: 'private-error reports'!
notifyError: anErrorString toSenderOf: aRFC822Message
	"VW specific"
	| msg address |
	msg := Net.MailMessage newTextPlain.
	address := aRFC822Message from notEmpty
		ifTrue: [aRFC822Message from first]
		ifFalse: [''].
	msg 
		subject: 'BiArt: Napaka pri dostavljanju e-pos^te';
		text:  (self messageForError: anErrorString for: aRFC822Message);
		from: address; to: address.
	self privSendMessage: msg reportError: #nomore "try to send only once!! "! !


!EMailMessenger methodsFor: 'private-receiving'!
receivingLoop
	"doc receiving process"
	^receivingLoop! !

!EMailMessenger methodsFor: 'private-receiving'!
receivingLoop: aProcess
	"doc receiving process"
	receivingLoop := aProcess! !


!EMailMessenger methodsFor: 'start/stop'!
startSending
	self initClient.
	self initSenderProcess.! !

!EMailMessenger methodsFor: 'start/stop'!
stopReceiving
	self mailbox terminate! !

!EMailMessenger methodsFor: 'start/stop'!
stopSending
	self sendingLoop ifNotNil: 
		[self sendingLoop terminate. 
		self sendingLoop: nil].
	client := nil.
"	queue := nil."! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

EMailMessenger class
	instanceVariableNames: ''!

!EMailMessenger class methodsFor: 'instance creation' stamp: 'janko 8/8/2011 16:47'!
newOn: anAIDASite
	^super basicNew 
		site: anAIDASite! !


Object subclass: #HistoryOfValue
	instanceVariableNames: 'dates values changedDates authors comments historyCollection'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Support'!
!HistoryOfValue commentStamp: '<historical>' prior: 0!
HistoryOfValue track some value through the time. You can go back on any date and get a value valid on that time. 

Example usage: a price, which changes from time to time.!


!HistoryOfValue methodsFor: 'private-history arrays' stamp: ' 21/4/07 22:07'!
activeFromArray: anArray

	"return a active flag from entries in history array"

	^anArray at: 5! !

!HistoryOfValue methodsFor: 'private-history arrays' stamp: ' 21/4/07 22:07'!
arrayWithDate: aDate time: aTime value: aValue active: aBoolean

	"return a array with argument vaules for entry to history collection"

	| array |
	array := Array new: 5.
	array 
		at: 1 put: aDate year;
		at: 2 put: aDate day;
		at: 3 put: (aTime notNil ifTrue: [aTime asSeconds] ifFalse: [0]);
		at: 4 put: aValue;
		at: 5 put: aBoolean.
	^array! !

!HistoryOfValue methodsFor: 'private-history arrays' stamp: ' 21/4/07 22:07'!
dateFromArray: anArray

	"return a date from entries in history array"

	^Date
		newDay: (anArray at: 2)
		year: (anArray at: 1)! !

!HistoryOfValue methodsFor: 'private-history arrays' stamp: ' 21/4/07 22:07'!
migrateHistoryCollection

	"migrate from historyCollection to bunch of collections. Remove duplicates"

	| date |
	date := nil.
	self initialize.
	self historyCollection reverseDo: [:array |
		date = (self dateFromArray: array)
			ifFalse: 
				[self 
					value: (self valueFromArray: array)
					dated: (self dateFromArray: array)
					author: ('')
					comment: ('').
				date := self dateFromArray: array] ].


"
Janko := History selectFromOdb select: [:h | h historyCollection size > 10].
(Janko at: 3) migrateHistoryCollection
Janko do: [:each | each migrateHistoryCollection].
Janko  select: [:h | h dates size > 3].
"! !

!HistoryOfValue methodsFor: 'private-history arrays' stamp: ' 21/4/07 22:07'!
timeFromArray: anArray

	"return a time from entries in history array"

	^Time fromSeconds: (anArray at: 3)! !

!HistoryOfValue methodsFor: 'private-history arrays' stamp: ' 21/4/07 22:07'!
valueFromArray: anArray

	"return a value from entries in history array"

	^anArray at: 4! !


!HistoryOfValue methodsFor: 'private-adding-removing' stamp: ' 21/4/07 22:07'!
addValue: aValue dated: aDate author: aString comment: aCommentString
	"adds data, which is newer than any existing one"
	self dates add: aDate asDays.
	self values add: aValue.
	self changedDates add: Date today asDays.
	self authors add: aString.
	self comments add: aString.! !

!HistoryOfValue methodsFor: 'private-adding-removing'!
changeValue: aValue author: aString comment: aCommentString onIndex: anIndexNumber
	"change data in a specified index"
	self values at: anIndexNumber put: aValue.
	self changedDates at: anIndexNumber put: Date today asDays.
	self authors at: anIndexNumber put: aString.
	self comments at: anIndexNumber put: aString.! !

!HistoryOfValue methodsFor: 'private-adding-removing' stamp: ' 21/4/07 22:07'!
hasDuplicateDates

	"maintenance - check if more than one entry with the same date exist"

	| unique |
	unique := Set new.
	self dates do: [: date | (unique includes: date)
		ifTrue: [^true]
		ifFalse: [unique add: date] ].
	^false! !

!HistoryOfValue methodsFor: 'private-adding-removing' stamp: ' 21/4/07 22:07'!
insertValue: aValue dated: aDate author: aString comment: aCommentString beforeIndex: anIndex
	"adds data in position before specified index"
	self dates add: aDate asDays beforeIndex: anIndex.
	self values add: aValue beforeIndex: anIndex.
	self changedDates add: Date today asDays beforeIndex: anIndex.
	self authors add: aString beforeIndex: anIndex.
	self comments add: aString beforeIndex: anIndex.! !

!HistoryOfValue methodsFor: 'private-adding-removing' stamp: ' 21/4/07 22:07'!
removeAllNils
	"REPARING BAD HISTORIES - remove all nil entries. Initialize if no more entries"

	2 to: self values size do: [:index |
		(self values at: index) isNil ifTrue: 
			[self removeIndex: index. ^self removeAllNils] ]! !

!HistoryOfValue methodsFor: 'private-adding-removing' stamp: ' 21/4/07 22:07'!
removeDuplicateDates

	"maintenance - remove all duplicate entries with same dates. Live last one"

	| date index |
	self hasDuplicateDates ifTrue: 
		[date := 0. index := nil.
		1 to: self dates size do: 
			[:inx | 
				(self dates at: inx) = date ifTrue: [index := inx].
				date := self dates at: inx].
		index notNil 
			ifTrue: 
				[self removeIndex: index-1.
				self removeDuplicateDates].
		 ].! !

!HistoryOfValue methodsFor: 'private-adding-removing' stamp: ' 21/4/07 22:07'!
removeIndex: aNumber
	"remove all entries on specified index"
	self dates removeIndex: aNumber.
	self values removeIndex: aNumber.
	self changedDates removeIndex: aNumber.
	self authors removeIndex: aNumber.
	self comments removeIndex: aNumber.! !

!HistoryOfValue methodsFor: 'private-adding-removing' stamp: ' 21/4/07 22:07'!
removeLastNil
	"REPARING BAD HISTORIES - remove last entry if value nil. Initialize if no more entries"
	self values isEmpty 
		ifTrue: 
			[self initialize. self values removeLast; addLast: true.
			Transcript cr; show: 'init, true']
		ifFalse: [self values last isNil ifTrue: 
			[self removeIndex: (self dates size).
			self removeLastNil] ]! !


!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
authors
	" a collection of authors, which made changes, (as a String or reference to a WebUser)"
	^authors! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
changedDates
	" a collection of dates, when value was changed in asDays format"
	^changedDates! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
comments
	" a collection of comments about changes"
	^comments! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
dates
	" a collection of dates of changes in asDays format"
	^dates! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
historyCollection
	"this is an ordered collection of array with year, day in year, time, value, active flag. 
	Collection is ordered from oldest to newest version of value. Active flag is used to 
	'delete' some version from history, but you can still have a trace, who/when some 
	change occured.

	3.11.98 NOT USED anymore. Here just for migration!!"


	historyCollection isNil ifTrue: [self initHistoryCollection].
	^historyCollection! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
indexForDate: aDate

	"return index of entry in dates collection, which fits most to the specified date. If no direct 
	entry on a specified date exist, then entry for previous date is used. If aDate is older than
	any date in collection, nil is returned!!"


	| first last days mdays index |

	first := 1. last := self dates size.
	last = 0 ifTrue: [^nil].
	days := aDate asDays.
	days >= self dates last ifTrue: [^last].
	days < self dates first ifTrue: [^nil].
	[last >= first] whileTrue: 	
		[ "(first = last and: [days = (self dates at: first)]) ifTrue: [^first].  " " not needed!! "
		index := (first + last) // 2.
		mdays := self dates at: index.
		days = mdays ifTrue: [^index].
		days < mdays
			ifTrue: [last := index - 1.]
			ifFalse: [first := index + 1.]].
"2.11.98 Sivec prej :
		^1 max: index - 1.
"
	index := (first + last) // 2.
	^1 max: index.




"
| h |
h := History new.
h dates
	add: (Date today) asDays;
	add: (Date today + 1) asDays;
	add: (Date today + 3) asDays;
	add: (Date today + 4) asDays.
Transcript cr;show: (h indexForDate: Date today - 1) printString.
Transcript cr;show: (h indexForDate: Date today + 1) printString.
Transcript cr;show: (h indexForDate: Date today + 2) printString.
Transcript cr;show: (h indexForDate: Date today + 3) printString.
h inspect.
"





"
	self historyCollection keysAndValuesDo: [:index :array |
		(self activeFromArray: array) 
			ifTrue:
				[(self dateFromArray: array) < (aDate + 1)
					ifTrue: [prevIndex := index]
					ifFalse: [^prevIndex]	] ].
	^prevIndex
"! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
initHistoryCollection
	historyCollection := OrderedCollection new.! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
newestDate

	"return a date of newest version of value"

	self dates isEmpty
		ifTrue: [^nil]
		ifFalse: 	[^Date fromDays: self dates last]

"History new newestDate"! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
newestValue

	"return a newest version of value in historyCollection."

	self values isEmpty
		ifTrue: [^nil]
		ifFalse: 	[^self values last]
	

"History new newestValue"! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
oldestDate

	"return a date of oldest version of value"

	self dates isEmpty
		ifTrue: [^nil]
		ifFalse: 	[^self dates first]
	

"History new oldestDate"! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
oldestValue

	"return a oldest version of value"

	self values isEmpty
		ifTrue: [^nil]
		ifFalse: 	[^self values last]
	

"History new oldestValue"! !

!HistoryOfValue methodsFor: 'private-accessing' stamp: ' 21/4/07 22:07'!
values
	" a collection of values, each valid from date in dates at the same index"
	^values! !


!HistoryOfValue methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
historyOfChanges

	"return a history of all changes of value. It is returned as ordered collection of collections, each with:
	valid from date
	valid to date (for last change: nil)
	new value
	date of change
	author of change
	comment of change	

Returned collection has the oldest change (by valied from date) as first, the newest as last. "! !

!HistoryOfValue methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
value
	"get the curently valid value"

	^self valueDated: Date today

"History new value"! !

!HistoryOfValue methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
value: aValue author: aString comment: aCommentString 
	"change a value of time series, which will be valid immediately - today. You should state author and a short comment about changes. see other methods for detailed explanation"

	self value: aValue
		dated: Date today
		author: aString
		comment: aCommentString! !

!HistoryOfValue methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
value: aValue dated: aDate author: aString comment: aCommentString 
	""

	| index |

	index := self indexForDate: aDate. 
	index isNil   "older than any existing or first" 
		ifTrue: 
			[self 
				insertValue: aValue 
				dated: aDate
				author: aString 
				comment: aCommentString
				beforeIndex: 1.
			^self].

"Sprememba 18.11.1998 Sivec, prej 'index >= self dates  size'."
	index > self dates  size  "newer than any existing"
		ifTrue: 
			[self addValue: aValue dated: aDate author: aString comment: aCommentString. ^self].


	(index ~= 0 and: [(self dates at: index) = aDate asDays]) "already exists"
		ifTrue: 
			[self 
				changeValue: aValue 
				author: aString 
				comment: aCommentString 
				onIndex: index.
			^self].

		self    "insert new somewhere in the middle"
			insertValue: aValue 
			dated: aDate
			author: aString 
			comment: aCommentString
			beforeIndex: index+1.



"History new value: 1234 dated: Date today author: 'Janko' comment: 'test'"! !

!HistoryOfValue methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
valueDated: aDate 
	"get the value from history, which was valid on specified date. Returns nil if aDate is older from 
	oldest entry in history"

	
	| index |
	index := self indexForDate: aDate.
	index = 0 ifTrue: [^nil].
	index = nil ifTrue: [^nil].
	^self values at: index.! !


!HistoryOfValue methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initAuthors
	authors := OrderedCollection new.! !

!HistoryOfValue methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initChangedDates
	changedDates := OrderedCollection new.! !

!HistoryOfValue methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initComments
	comments := OrderedCollection new.! !

!HistoryOfValue methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initDates
	"adds default entry: 1.1.1901"
	dates := OrderedCollection new.! !

!HistoryOfValue methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initValues
	values := OrderedCollection new.! !

!HistoryOfValue methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initialize
	"2.11.1998 all inits do not add default values anymore"

	self initDates.
	self initValues.
	self initChangedDates.
	self initAuthors.
	self initComments.! !


!HistoryOfValue methodsFor: 'private' stamp: ' 21/4/07 22:07'!
printString

	^('aHistory: ', self value printString)! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HistoryOfValue class
	instanceVariableNames: ''!

!HistoryOfValue class methodsFor: 'odb specific' stamp: ' 21/4/07 22:07'!
instancesAreForwarders
	"Gemstone"

	^false! !


!HistoryOfValue class methodsFor: 'instance creation' stamp: ' 21/4/07 22:07'!
new
	^super new initialize! !


!HistoryOfValue class methodsFor: 'examples' stamp: 'jm 11/16/2010 17:19'!
tests
	"some test of histories. Use it directly from code with doIt/printIt/inspectIt "

	| history |
	history := HistoryOfValue new.
	history value: 0 dated: (Date today ) author: '' comment: ''.
	history value: -2000 dated: (Date today - (365*100) -2) author: '' comment: ''.
	history value: -3 dated: (Date today -3) author: '' comment: ''.
	history value: -1 dated: (Date today -1) author: '' comment: ''.
	history value: 2 dated: (Date today +2) author: '' comment: ''.
	history value: 1 dated: (Date today +1) author: '' comment: ''.! !


Object subclass: #Numberer
	instanceVariableNames: 'counters'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Support'!
!Numberer commentStamp: '<historical>' prior: 0!
Numberer is used to provide counters for things like invoice numbers

Instance Variables:
	counters	<Dictionary>	 counters for different purposes

!


!Numberer methodsFor: 'private' stamp: ' 21/4/07 22:07'!
counters
	counters isNil ifTrue: [self initCounters].
	^counters! !

!Numberer methodsFor: 'private' stamp: ' 21/4/07 22:07'!
decrementCounter: aSymbol
	"get next number and increment this counter"
	^self counters at: aSymbol put: (((self currentCounter: aSymbol) - 1) max: 0)! !

!Numberer methodsFor: 'private' stamp: ' 21/4/07 22:07'!
setCounter: aSymbol to: aNumber
	"use it sparingly!!"
	^self counters at: aSymbol put: aNumber! !


!Numberer methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
currentCounter: aSymbol
	"get curent (last nextCounter) number"
	(self counters includesKey: aSymbol) ifFalse: [self resetCounter: aSymbol].
	^self counters at: aSymbol! !

!Numberer methodsFor: 'accessing'!
decreaseCounter: aSymbol
	"decrease a current number, for instance if you deleted something with last number"
	(self currentCounter: aSymbol) = 0 ifTrue: [^nil].
	^self counters at: aSymbol put: (self currentCounter: aSymbol) - 1! !

!Numberer methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
nextCounter: aSymbol
	"get next number and increment this counter"
	^self counters at: aSymbol put: (self peekCounter: aSymbol)! !

!Numberer methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
peekCounter: aSymbol
	"get next number but not increment it"
	(self counters includesKey: aSymbol) ifFalse: [self resetCounter: aSymbol].
	^(self counters at: aSymbol) + 1! !

!Numberer methodsFor: 'accessing' stamp: ' 21/4/07 22:07'!
resetCounter: aSymbol
	"put counter to 0, peekCounter will then return 1"
	self counters at: aSymbol put: 0! !


!Numberer methodsFor: 'initialize-release' stamp: ' 21/4/07 22:07'!
initCounters
	counters := Dictionary new! !
