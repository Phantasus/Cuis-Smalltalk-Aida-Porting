Object subclass: #Address
	instanceVariableNames: 'title firstName middleName lastName company street city stateProvince postalCode country phones fax emails web'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Parties'!
!Address commentStamp: '<historical>' prior: 0!
"ECML v1.1 definition of address (www.ecml.org)"

Instance Variables:
	city	<Object>	description of city
	company	<Object>	description of company
	country	<Object>	description of country
	emails	<Object>	description of emails
	firstName	<Object>	description of firstName
	lastName	<Object>	description of lastName
	middleName	<Object>	description of middleName
	phones	<Object>	description of phones
	postalCode	<Object>	description of postalCode
	stateProvince	<Object>	description of stateProvince
	street	<Object>	description of street
	title	<Object>	description of title

!


!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
city
	city isNil ifTrue: [^''].
	^city! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
city: aString
	city := aString.! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
company
	company isNil ifTrue: [^''].
	^company! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
company: aString
	company := aString.! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
country
	country isNil ifTrue: [^''].
	^country! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
country: aString
	country := aString.! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
email
	self emails size > 0 ifTrue: [^self emails at: 1].
	^' '! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
email: aString 
	self emails size > 0 ifTrue: [^self emails at: 1 put: aString].
	^self emails add: aString! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
emails
	emails isNil ifTrue: [self initEMails].
	^emails! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
fax
	fax isNil ifTrue: [^''].
	^fax! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
fax: aString
	fax := aString.! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
firstName
	firstName isNil ifTrue: [^''].
	^firstName! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
firstName: aString
	firstName := aString.! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
lastName
	lastName isNil ifTrue: [^''].
	^lastName! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
lastName: aString
	lastName := aString.! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
middleName
	middleName isNil ifTrue: [^''].
	^middleName! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
middleName: aString
	middleName := aString.! !

!Address methodsFor: 'accessing' stamp: 'janko 4/20/2012 17:10'!
mobile
	^self phones size > 1 
		ifTrue: [self phones at: 2]
		ifFalse: ['']! !

!Address methodsFor: 'accessing' stamp: 'janko 4/20/2012 17:11'!
mobile: aString
	self phones size > 1 ifTrue: [^self phones at: 2 put: aString].
	self phones size = 0 ifTrue: [self phones add: ''].
	^self phones add: aString! !

!Address methodsFor: 'accessing' stamp: 'janko 4/20/2012 17:11'!
phone
	^self phones size > 0 
		ifTrue: [self phones first]
		ifFalse: ['']! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
phone: aString
	self phones size > 0 ifTrue: [^self phones at: 1 put: aString].
	^self phones add: aString! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
phones
	phones isNil ifTrue: [self initPhones].
	^phones! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
post
	^self city! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
post: anObject
	self city: anObject! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
postalCode
	postalCode isNil ifTrue: [^''].
	^postalCode! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
postalCode: aString
	postalCode := aString.! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
stateProvince
	stateProvince isNil ifTrue: [^''].
	^stateProvince! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
stateProvince: aString
	stateProvince := aString.! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
street
	street isNil ifTrue: [^''].
	^street! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
street: aString
	street := aString.! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
title
	title isNil ifTrue: [^''].
	^title! !

!Address methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
title: aString
	title := aString.! !

!Address methodsFor: 'accessing'!
web
	"address of the website"
	web isNil ifTrue: [^''].
	^web! !

!Address methodsFor: 'accessing'!
web: aString
	"address of the website"
	web := aString! !


!Address methodsFor: 'initialize - release' stamp: ' 10/1/08 16:40'!
initEMails
	emails := OrderedCollection new.! !

!Address methodsFor: 'initialize - release' stamp: ' 10/1/08 16:40'!
initPhones
	phones := OrderedCollection new.
	phones add: ''.! !


!Address methodsFor: 'private' stamp: ' 10/1/08 16:40'!
migrateToUnicode
	"from iso8859-2"
	"Address allInstances do: [:each | each migrateToUnicode]"
	title notNil ifTrue: [title := title ensureUnicodeSloveneChars].
	firstName notNil ifTrue: [firstName := firstName ensureUnicodeSloveneChars].
	middleName notNil ifTrue: [middleName := middleName ensureUnicodeSloveneChars].
	lastName notNil ifTrue: [lastName := lastName ensureUnicodeSloveneChars].
	company notNil ifTrue: [company := company ensureUnicodeSloveneChars].
	street notNil ifTrue: [street := street ensureUnicodeSloveneChars].
	city notNil ifTrue: [city := city ensureUnicodeSloveneChars].
	country notNil ifTrue: [country := country ensureUnicodeSloveneChars].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Address class
	instanceVariableNames: ''!

!Address class methodsFor: 'odb specific' stamp: ' 10/1/08 16:40'!
replicationSpec
	"Gemstone"

	^super replicationSpec, 
		#(	(firstName replicate)
			(lastName replicate)
			(company replicate)
			(street replicate)
			(city replicate)
			(postalCode replicate)
			(country replicate)
			(phones max 4)
			(emails max 4)
		 )! !


Object subclass: #Party
	instanceVariableNames: 'id name description addresses roles relatedPartyRoles events relatedObjects other'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Parties'!
!Party commentStamp: '<historical>' prior: 0!
Party is abstract class for persons or companies, holding basic information, roels and relations to other parties (like this person is an employee to that company). It also registers all events related to that party.
!


!Party methodsFor: 'related objects' stamp: ' 10/1/08 16:40'!
addRelatedObject: anObject
	(self relatedObjects includes: anObject) ifFalse:
		[self relatedObjects add: anObject].! !

!Party methodsFor: 'related objects' stamp: ' 10/1/08 16:40'!
removeRelatedObject: anObject
	self relatedObjects remove: anObject ifAbsent: []! !


!Party methodsFor: 'private' stamp: ' 10/1/08 16:40'!
addRelatedPartyRole: aRole
	(self relatedPartyRoles includes: aRole) ifTrue: [^nil].
	self relatedPartyRoles add: aRole.! !

!Party methodsFor: 'private' stamp: ' 10/1/08 16:40'!
addRole: aRole
	(self roles includes: aRole) ifTrue: [^nil].
	self roles add: aRole.! !

!Party methodsFor: 'private' stamp: 'janko 8/6/2011 19:49'!
other
	^other! !

!Party methodsFor: 'private' stamp: 'janko 8/6/2011 19:43'!
otherAt: aString
	^self otherAt: aString ifAbsent: [nil]! !

!Party methodsFor: 'private' stamp: 'janko 8/6/2011 19:44'!
otherAt: aString ifAbsent: aBlock
	self other isNil ifTrue: [^aBlock value].
	^self other at: aString ifAbsent: [aBlock value]! !

!Party methodsFor: 'private' stamp: 'janko 8/6/2011 19:44'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOtherValues].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!Party methodsFor: 'private' stamp: 'janko 8/6/2011 19:44'!
otherAt: aString put: anObject
	self other isNil ifTrue: [self initOtherValues].
	^self other at: aString put: anObject! !

!Party methodsFor: 'private' stamp: ' 10/1/08 16:40'!
partialyConnectedRoles
	"roles, which are not correctly connected to related party and back"
	"not working well yet !!!!!! "
	| col |
	col := self roles reject: [:each | each relatedParty roles contains: [:role | role relatedParty == self] ].
	col addAll: (self relatedPartyRoles 
		reject: [:each | each relatedParty roles contains: [:role | role party == self] ]).
	^col

"Company allInstances select: [:each | each partialyConnectedRoles notEmpty]"! !

!Party methodsFor: 'private' stamp: ' 10/1/08 16:40'!
printString
	^'party: ', self name! !

!Party methodsFor: 'private' stamp: ' 10/1/08 16:40'!
reconnectEmployees
	"for debugging"
	self allEmployees do: [:each | self removeEmployee: each; addEmployee: each]! !


!Party methodsFor: 'role groups' stamp: ' 10/1/08 16:40'!
addRoleGroup: aRoleGroup
	(self roleGroups includes: aRoleGroup) ifFalse: [self roleGroups add: aRoleGroup]! !

!Party methodsFor: 'role groups' stamp: ' 10/1/08 16:40'!
allRoleGroups
	^self roleGroups copy! !

!Party methodsFor: 'role groups' stamp: ' 10/1/08 16:40'!
removeRoleGroup: aRoleGroup
	(self roleGroups includes: aRoleGroup) ifTrue: [self roleGroups remove: aRoleGroup]! !

!Party methodsFor: 'role groups' stamp: ' 10/1/08 16:40'!
roleGroupNamed: aString
	^self roleGroups detect: [:each | each name = aString] ifNone: [nil]! !

!Party methodsFor: 'role groups' stamp: ' 10/1/08 16:40'!
roleGroupWithUuid: aString
	^self roleGroups detect: [:each | each uuid = aString] ifNone: [nil]! !

!Party methodsFor: 'role groups' stamp: 'janko 8/6/2011 19:39'!
roleGroups
	(self otherAt: #roleGroups) isNil ifTrue: 
		[self otherAt: #roleGroups put: OrderedCollection new].
	^self otherAt: #roleGroups! !

!Party methodsFor: 'role groups' stamp: ' 10/1/08 16:40'!
roleGroupsIncludeRole: aRole
	^self roleGroups select: [:each | each includes: aRole]! !


!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
addresses
	addresses isNil ifTrue: [self initAddresses].
	^addresses! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
description
	description isNil ifTrue: [self description: ''].
	^description! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
description: aString
	description := aString! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
events
	events isNil ifTrue: [self initEvents].
	^events! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
id
	id isNil ifTrue: [self id: ''].
	^id! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
id: aString
	id := aString.! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
name
	name isNil ifTrue: [self name: ''].
	^name! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
name: aString
	name := aString trimBlanks.! !

!Party methodsFor: 'accessing'!
nameNonEmpty
	^self name trimBlanks notEmpty 
		ifTrue: [self name] 
		ifFalse: ['-- no name --'].! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
nameToDisplay
	"on web pages for instance"
	^self name! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
relatedObjects
	relatedObjects isNil ifTrue: [self initRelatedObjects].
	^relatedObjects! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
relatedPartyRoles
	relatedPartyRoles isNil ifTrue: [self initRelatedPartyRoles].
	^relatedPartyRoles! !

!Party methodsFor: 'accessing'!
roleNames
	"names of roles this party plays"
	^self roles collect: [:each | each name].! !

!Party methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
roles
	roles isNil ifTrue: [self initRoles].
	^roles! !

!Party methodsFor: 'accessing'!
rolesText
	"names of roles this party plays, in one string separated with commas"
	| text |
	text := ''.
	1 to: self roleNames size do: [:inx |
		text := text, (self roleNames at: inx).
		inx = self roleNames size ifFalse: [text := text, ', '] ].
	^text! !

!Party methodsFor: 'accessing' stamp: 'janko 8/6/2011 19:43'!
uuid
	"unique identifier "
	^self otherAt: #uuid ifAbsentPut: [(AIDASite random next * 1000000000) rounded printString]! !


!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
allCustomers
	"return all parties which are my customers, therefore I am a supplier to them"
	| parties |
	parties :=  (self roles select: [:role | role isSupplierRole]) 
		collect: [:each | each relatedParty].
	parties := parties addAll:
		((self relatedPartyRoles select: [:role | role isCustomerRole]) 
			collect: [:each | each party]);
		yourself.
	^parties asSet asOrderedCollection! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
allEmployees
	"all employees of that party"
	| parties |
	parties :=  (self roles select: [:role | role isEmployeeRole]) 
		collect: [:each | each relatedParty].
	parties := parties addAll:
		((self relatedPartyRoles select: [:role | role isEmployeeRole]) 
			collect: [:each | each party]);
		yourself.
	^parties asSet asOrderedCollection! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
allSuppliers
	"return all parties which supply goods to me, therefore I am a customer of them"
	| parties |
	parties :=  (self roles select: [:role | role isCustomerRole]) 
		collect: [:each | each relatedParty].
	parties := parties addAll:
		((self relatedPartyRoles select: [:role | role isSupplierRole]) 
			collect: [:each | each party]); 
		yourself.
	^parties asSet asOrderedCollection! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
becomeCustomerOf: aParty
	"I become a customer of related party, I buy goods from this party"
	| role |
	(self isCustomerOf: aParty) ifTrue: [^false].
	role := CustomerRole new.
	role name: 'customer role'.
	self newRole: role relatedTo: aParty! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
becomeSiteOwner
	"usual for Companies, SiteOwnerRole has a reference to his WebSite"! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
becomeSupplierTo: aParty 
	"I become a supplier to related party, I supply goods to this party"
	| role |
	(self isSupplierTo: aParty) ifTrue: [^false].
	role := SupplierRole new.
	role name: 'supplier role'.
	self newRole: role relatedTo: aParty! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
becomeWebUserTo: aWebSiteOwnerPary! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
isCustomerOf: aParty

	| isCustomer |
	isCustomer := self roles contains: [:role | role relatedParty == aParty and: [role isCustomerRole] ].
	isCustomer ifTrue: [^true].
	"check also a complementary role"
	^self relatedPartyRoles contains: [:role | role party == aParty and: [role isSupplierRole] ].! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
isSupplierTo: aParty

	| isSupplier |
	isSupplier := self roles contains: [:role | role relatedParty == aParty and: [role isSupplierRole] ].
	isSupplier ifTrue: [^true].
	"check also a complementary role"
	^self relatedPartyRoles contains: [:role | role party == aParty and: [role isCustomerRole] ].! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
noMoreCustomerOf: aParty 
	"no more a customer of related party"
	(self isCustomerOf: aParty) ifFalse: [^nil].
	self discontinueRole:
		(self roles detect: [:role | role relatedParty == aParty and: [role isCustomerRole] ] ifNone: [^nil])! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
noMoreSupplierTo: aParty 
	"no more a supplier to related party"
	(self isSupplierTo: aParty) ifFalse: [^nil].
	self discontinueRole:
		(self roles detect: [:role | role relatedParty == aParty and: [role isSupplierRole] ] ifNone: [^nil])! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
relatedParty
	"which party is the 'owner', e.g. doing business in elogis terms with that party"

	| thirdPLCustomers parties |
	thirdPLCustomers := LogisticSystem default owner all3PLCustomers.
	parties := thirdPLCustomers select: [:party | party isSupplierTo: self].
	^parties isEmpty 
		ifTrue: 
			[parties := thirdPLCustomers select: [:party | party isCustomerOf: self].
			parties isEmpty ifTrue: [^nil] ifFalse: [parties first] ]
		ifFalse: [parties first]! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
searchEmployeesWithSurname: aSurname name: aName
	| surname nme |
	surname := aSurname asLowercase, '*'. nme := aName asLowercase, '*'.
	^self allEmployees select: [:each | 
		(surname match: each surname asLowercase) and: [nme match: each name asLowercase] ]! !

!Party methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
searchEmployeesWithSurnameName: aString
	| string nm |
	string := aString asLowercase, '*'. 
	^self allEmployees select: [:each | 
		nm := each surnameName asLowercase.
		(string match: nm)].! !


!Party methodsFor: 'roles-basic' stamp: ' 10/1/08 16:40'!
allRelatedRolesFrom: aParty
	"return all roles this party has to me"
	^self relatedPartyRoles select: [:each | each party == aParty]! !

!Party methodsFor: 'roles-basic' stamp: ' 10/1/08 16:40'!
allRoles
	^self roles copy! !

!Party methodsFor: 'roles-basic' stamp: ' 10/1/08 16:40'!
allRolesTo: aParty
	"return all roles I have to this party"
	^self roles select: [:each | each relatedParty == aParty]! !

!Party methodsFor: 'roles-basic' stamp: ' 10/1/08 16:40'!
discontinueAllRoles
	self roles copy do: [:each | self discontinueRole: each].
	self relatedPartyRoles copy do: [:each | self discontinueRole: each]! !

!Party methodsFor: 'roles-basic' stamp: ' 10/1/08 16:40'!
discontinueAllRolesTo: aParty
	(self roles select: [:role | role relatedParty == aParty])
		do: [:each | self discontinueRole: each].! !

!Party methodsFor: 'roles-basic' stamp: ' 10/1/08 16:40'!
discontinueRole: aRole
	self roles remove: aRole ifAbsent: [].
	aRole relatedParty relatedPartyRoles remove: aRole ifAbsent: [].! !

!Party methodsFor: 'roles-basic'!
discontinueRoleNamed: aString
	| r |
	r := self roleNamed: aString.
	r notNil ifTrue: [self discontinueRole: r]! !

!Party methodsFor: 'roles-basic' stamp: ' 10/1/08 16:40'!
newRole: aRole
	"new role, but not in relationship with anyone"! !

!Party methodsFor: 'roles-basic' stamp: ' 10/1/08 16:40'!
newRole: aRole relatedTo: aParty
	"new role in relationship with other party"

	aRole party: self.
	aRole relatedParty: aParty.
	self addRole: aRole.
	aParty addRelatedPartyRole: aRole.! !

!Party methodsFor: 'roles-basic'!
newRoleNamed: aString
	"new role, but not in relationship with anyone"
	| new |
	(self roleNames includes: aString) ifTrue: [^self error: 'role with that name already exist'].
	new := Role new name: aString.
	self newRole: new! !

!Party methodsFor: 'roles-basic'!
newRoleNamed: aString relatedTo: aParty
	"new role in relationship with other party"
	| new |
	(self roleNames includes: aString) ifTrue: [^self error: 'role with that name already exist'].
	new := Role new name: aString.
	self newRole: new relatedTo: aParty! !

!Party methodsFor: 'roles-basic'!
roleNamed: aString
	"find a role with that name"
	^self roles detect: [:each | each name = aString] ifNone: [nil]! !


!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
city
	^self mainAddress city! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
city: aString
	self mainAddress city: aString! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
country
	^self mainAddress country! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
country: aString
	self mainAddress country: aString! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
email
	^self mainAddress email! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
email: aString
	self mainAddress email: aString! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
fax
	^self mainAddress fax! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
fax: aString
	self mainAddress fax: aString! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
mainAddress
	
	^self addresses 
		at: #MainAddress 
		ifAbsent: [self addresses at: #MainAddress put: Address new. self mainAddress].! !

!Party methodsFor: 'addresses' stamp: 'janko 4/20/2012 17:15'!
mobile
	^self mainAddress mobile! !

!Party methodsFor: 'addresses' stamp: 'janko 4/20/2012 17:16'!
mobile: aString
	self mainAddress mobile: aString! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
phone
	^self mainAddress phone! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
phone: aString
	self mainAddress phone: aString! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
post
	^self mainAddress post! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
post: anObject
	^self mainAddress post: anObject! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
postalCode
	^self mainAddress postalCode! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
postalCode: aString
	self mainAddress postalCode: aString! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
street
	^self mainAddress street! !

!Party methodsFor: 'addresses' stamp: ' 10/1/08 16:40'!
street: aString
	self mainAddress street: aString! !


!Party methodsFor: 'initialize - release' stamp: ' 10/1/08 16:40'!
initAddresses
	addresses := Dictionary new.! !

!Party methodsFor: 'initialize - release' stamp: ' 10/1/08 16:40'!
initEvents
	events := DailyCollection new.! !

!Party methodsFor: 'initialize - release' stamp: 'janko 8/6/2011 19:49'!
initOtherValues
	other := Dictionary new.! !

!Party methodsFor: 'initialize - release' stamp: ' 10/1/08 16:40'!
initRelatedObjects
	relatedObjects := OrderedCollection new.! !

!Party methodsFor: 'initialize - release' stamp: ' 10/1/08 16:40'!
initRelatedPartyRoles
	relatedPartyRoles := OrderedCollection new.! !

!Party methodsFor: 'initialize - release' stamp: ' 10/1/08 16:40'!
initRoles
	roles := OrderedCollection new.! !


!Party methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
isCompany
	^false! !

!Party methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
isOrganizationUnit
	^false! !

!Party methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
isPerson
	^false! !


!Party methodsFor: 'changing' stamp: ' 10/1/08 16:40'!
updateFrom: aParty
	self name: aParty name.
	self description: aParty description.
	self city: aParty city.
	self street: aParty street.
	self postalCode: aParty postalCode.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Party class
	instanceVariableNames: ''!

!Party class methodsFor: 'instance creation' stamp: ' 10/1/08 16:40'!
newCustomerOf: aParty

	^super new
		becomeCustomerOf: aParty! !

!Party class methodsFor: 'instance creation' stamp: ' 10/1/08 16:40'!
newSupplierTo: aParty

	^super new
		becomeSupplierTo: aParty! !


!Party class methodsFor: 'odb specific' stamp: ' 10/1/08 16:40'!
replicationSpec
	"Gemstone"
	^super replicationSpec , 
		#( 	(id 	replicate)
			(name replicate)
			(description replicate)
			(addresses max 4)
			(roles max 2)
			(relatedPartyRoles max 2)
			(events forwarder)
			(relatedObjects max 1) )! !


Party subclass: #OrganizationUnit
	instanceVariableNames: 'type parent units specialRoles'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Parties'!
!OrganizationUnit commentStamp: '<historical>' prior: 0!
OrganizationUnit for hierarchical modeling some organization like a company!


!OrganizationUnit methodsFor: 'job roles' stamp: 'janko 8/6/2011 19:38'!
addJobRoleNamed: aString
	(self existJobRoleNamed: aString) ifTrue: [^nil].
	self otherAt: #jobRoles ifAbsent: 
		[self otherAt: #jobRoles put: OrderedCollection new].
	(self otherAt: #jobRoles) add: (JobRole new name: aString)! !

!OrganizationUnit methodsFor: 'job roles' stamp: 'janko 8/6/2011 19:42'!
allJobRoles
	^self otherAt: #jobRoles ifAbsent: [^#()]! !

!OrganizationUnit methodsFor: 'job roles' stamp: ' 10/1/08 16:40'!
allPersonsWithJobRoles
	"collect all persons holding job roles in this org unit"
	^self allJobRoles inject: Set new into: [:set :role | set addAll: role allPersons; yourself].! !

!OrganizationUnit methodsFor: 'job roles' stamp: 'janko 8/6/2011 19:42'!
existJobRoleNamed: aString
	^(self otherAt: #jobRoles ifAbsent: [^false])
		contains: [:each | each name = aString]! !

!OrganizationUnit methodsFor: 'job roles' stamp: 'janko 8/6/2011 19:42'!
jobRoleNamed: aString
	^(self otherAt: #jobRoles ifAbsent: [^nil])
		detect: [:each | each name = aString] ifNone: [nil]! !

!OrganizationUnit methodsFor: 'job roles' stamp: 'janko 8/6/2011 19:39'!
removeJobRole: aJobRole
	self otherAt: #jobRoles ifAbsent: [^nil].
	(self otherAt: #jobRoles) remove: aJobRole ifAbsent: [^nil]! !

!OrganizationUnit methodsFor: 'job roles' stamp: 'janko 8/6/2011 19:39'!
removeJobRoleNamed: aString
	(self existJobRoleNamed: aString) ifFalse: [^nil].
	(self otherAt: #jobRoles) remove: (self jobRoleNamed: aString)! !


!OrganizationUnit methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
addMember: aPerson
	aPerson becomeMemberOf: self! !

!OrganizationUnit methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
addOrganizationUnit: anOrganizationUnit
	units isNil ifTrue: [self initUnits].
	(self units includes: anOrganizationUnit) ifFalse:
		[self units add: anOrganizationUnit. anOrganizationUnit parent: self]! !

!OrganizationUnit methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
addOrganizationUnitNamed: aString
	self addOrganizationUnit: (OrganizationUnit newNamed: aString)! !

!OrganizationUnit methodsFor: 'adding-removing'!
moveDownUnit: anOrganizationUnit
	self units moveDown: anOrganizationUnit.
	^anOrganizationUnit! !

!OrganizationUnit methodsFor: 'adding-removing'!
moveUpUnit: anOrganizationUnit
	self units moveUp: anOrganizationUnit.
	^anOrganizationUnit! !

!OrganizationUnit methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
removeMember: aPerson
	aPerson noMoreMemberOf: self! !

!OrganizationUnit methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
removeOrganizationUnit: anOrganizationUnit
	units isNil ifTrue: [^nil].
	(self units includes: anOrganizationUnit) ifTrue:
		[self units remove: anOrganizationUnit. anOrganizationUnit parent: nil]! !


!OrganizationUnit methodsFor: 'roles-special' stamp: ' 10/1/08 16:40'!
addSpecialRoleNamed: aName
	(self existSpecialRoleNamed: aName) ifFalse:
		[self specialRoles add: (Role new name: aName)]! !

!OrganizationUnit methodsFor: 'roles-special' stamp: ' 10/1/08 16:40'!
existSpecialRoleNamed: aName
	^(self specialRoleNamed: aName) notNil! !

!OrganizationUnit methodsFor: 'roles-special' stamp: ' 10/1/08 16:40'!
specialRoleCollection
	"all specail roles for that and parent org.units up in to the top of hierarchy.
	sorted by the top first!!"
	^(self parent notNil and: [self parent isKindOf: Party])
		ifTrue: [self parent specialRoleCollection addAll: self specialRoles; yourself]
		ifFalse: [self specialRoles]! !

!OrganizationUnit methodsFor: 'roles-special' stamp: ' 10/1/08 16:40'!
specialRoleNamed: aName
	^self specialRoles detect: [:each | each name = aName] ifNone: [nil]! !

!OrganizationUnit methodsFor: 'roles-special'!
specialRoles
	"a set of roles, special a for member of that org.unit, like aprover, tester etc"
	specialRoles isNil ifTrue: [self initSpecialRoles].
	^specialRoles! !


!OrganizationUnit methodsFor: 'accessing' stamp: 'np 10/20/2008 16:37'!
allJobRolesDownHierarchy
	"incudes me"
	^self allOrgUnits "down hierarchy"
		inject: Set new
		into: [:set :each | set addAll: each allJobRoles; yourself]! !

!OrganizationUnit methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
allOrgUnits
	"all units down in hierarchy, together with self"
	| collection |
	collection := OrderedCollection new.
	collection add: self.
	self units do: [:each | collection addAll: each allOrgUnits].
	^collection! !

!OrganizationUnit methodsFor: 'accessing'!
company
	"return a company whom belongs that org.unit"
	self parent ifNil: [^nil].
	^self parent company! !

!OrganizationUnit methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
jobRoleWithUuid: aString
	"search for this job role through hierarchy starting from self"
	| found |
	^self allJobRoles detect: [:each | each uuid = aString] ifNone:
		[self units do: [:each | found := each jobRoleWithUuid: aString. found notNil ifTrue: [^found] ].
		nil]! !

!OrganizationUnit methodsFor: 'accessing'!
level
	"org.unit position in hierarchy, 0 = top = company"
	^1 + self parent level! !

!OrganizationUnit methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
orgUnitWithName: aString
	"search for this org.unit through hierarchy starting from self"
	| found |
	self name = aString ifTrue: [^self].
	self units do: [:each | each name = aString ifTrue: [^each] ].
	self units do: [:each | 
		found := each orgUnitWithName: aString. found notNil ifTrue: [^found] ].
	^nil! !

!OrganizationUnit methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
orgUnitWithUuid: aString
	"search for this org.unit through hierarchy starting from self"
	| found |
	self uuid = aString ifTrue: [^self].
	self units do: [:each | each uuid = aString ifTrue: [^each] ].
	self units do: [:each | found := each orgUnitWithUuid: aString. found notNil ifTrue: [^found] ].
	^nil! !

!OrganizationUnit methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
parent
	^parent! !

!OrganizationUnit methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
repository
	self parent isNil ifTrue: [^nil].
	self parent class == Repository ifTrue: [^self parent].
	^self parent repository! !

!OrganizationUnit methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
type
	^type! !

!OrganizationUnit methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
type: aSymbol
	"kind of org.unit like #division #sector #group etc."
	type := aSymbol! !

!OrganizationUnit methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
units
	units isNil ifTrue: [^#()].
	^units! !


!OrganizationUnit methodsFor: 'roles-specific' stamp: ' 10/1/08 16:40'!
allMembers
	"all members of that org.unit"
	| parties |
	parties :=  (self roles select: [:role | role isMemberRole]) 
		collect: [:each | each relatedParty].
	parties := parties addAll:
		((self relatedPartyRoles select: [:role | role isMemberRole]) 
			collect: [:each | each party]);
		yourself.
	^parties asSet asOrderedCollection! !

!OrganizationUnit methodsFor: 'roles-specific'!
allMembersDownHierarchy
	"all members of that and all subunits down the hiearchy"
	^self allMembers asSet
		addAll:
			(self units 
				inject: Set new 
				into: [:set :unit | set addAll: unit allMembersDownHierarchy. set]);
		yourself! !

!OrganizationUnit methodsFor: 'roles-specific'!
numMembers
	"number of members of that org.unit"
	^self allMembers size! !

!OrganizationUnit methodsFor: 'roles-specific'!
numMembersDownHierarchy
	"number of members of that and all subunits down the hiearchy"
	^self allMembersDownHierarchy size! !


!OrganizationUnit methodsFor: 'initialize-release' stamp: ' 10/1/08 16:40'!
initSpecialRoles
	specialRoles := OrderedCollection new! !

!OrganizationUnit methodsFor: 'initialize-release' stamp: ' 10/1/08 16:40'!
initUnits
	units := OrderedCollection new! !


!OrganizationUnit methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
isOrganizationUnit
	^true! !


!OrganizationUnit methodsFor: 'private' stamp: ' 10/1/08 16:40'!
migrateToUnicode
	"from iso8859-2"
	"OrganizationUnit allInstances do: [:each | each migrateToUnicode]"
	super migrateToUnicode.! !

!OrganizationUnit methodsFor: 'private' stamp: ' 10/1/08 16:40'!
parent: anOrganizationUnit
	parent := anOrganizationUnit! !

!OrganizationUnit methodsFor: 'private' stamp: 'janko 3/19/2012 13:21'!
preferredUrl
	| nme |
	nme := self name trimBlanks asSloveneWithoutCircumflexes.
	^'/org-enota/', nme asHttpFriendly.

"OrganizationUnit allInstances do: [:each | 
	each repository notNil ifTrue: [each repository site urlResolver changeToPreferedURL: each] ]"! !

!OrganizationUnit methodsFor: 'private'!
printString
	^'orgUnit: ', self name! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

OrganizationUnit class
	instanceVariableNames: ''!

!OrganizationUnit class methodsFor: 'instance creation' stamp: ' 10/1/08 16:40'!
newNamed: aString
	^self new name: aString! !


!OrganizationUnit class methodsFor: 'odb specific' stamp: ' 10/1/08 16:40'!
replicationSpecaa
	"Gemstone"
	^super replicationSpec! !


OrganizationUnit subclass: #Company
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Parties'!
!Company commentStamp: '<historical>' prior: 0!
Company as a party with its roles and relashionships, employees, organizational units etc.
!


!Company methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
addEmployee: aPerson
	aPerson becomeEmployeeOf: self! !

!Company methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
removeEmployee: aPerson
	aPerson noMoreEmployeeOf: self.
	self allOrgUnits do: [:each | each removeMember: aPerson].
	aPerson removeJobRole! !


!Company methodsFor: 'accessing-events' stamp: ' 10/1/08 16:40'!
allEvents
	^self events all! !


!Company methodsFor: 'import-export' stamp: ' 10/1/08 16:40'!
autoEMailAddressesForPersons
	"Repository default company autoEMailAddressesForPersons"
	self allEmployees do: [:person |
		person email isValidEMailAddress ifFalse:  	
			[person email: (person name asSloveneWithoutCircumflexes asLowercase , '.',
			person surname asSloveneWithoutCircumflexes asLowercase, 
			'@salus.si')] ]! !

!Company methodsFor: 'import-export' stamp: ' 10/1/08 16:40'!
connectEmployeesToOrgUnits
	"salus"	
	"preimenuj zacasno org.enote brez sumnikov!! "
	"Repository default company connectEmployeesToOrgUnits"
	| orgUnit |
	self allEmployees do: [:each |
		orgUnit := self salusOrgUnitFor: each.
		orgUnit notNil ifTrue: [each allOrgUnits isEmpty ifTrue: [each becomeMemberOf: orgUnit] ]]! !

!Company methodsFor: 'import-export' stamp: ' 10/1/08 16:40'!
connectPersonsToWebUsers
	"Repository default company connectPersonsToWebUsers"
	self allEmployees do: [:each | 	AIDASite default securityManager addPerson: each]! !


!Company methodsFor: 'private' stamp: ' 10/1/08 16:40'!
cleanupEmployeeToOrgUnitsConnections
	"(AIDASite named: 'biart') repository company cleanupEmployeeToOrgUnitsConnections"
	| set employees |
	set := self allEmployees asSet.
	employees := self allOrgUnits "collect them through orgunits hierarchy"
		inject: Set new into: [:sett :each | sett addAll: each allMembers; yourself].
	(employees reject: [:each | set includes: each]) "those dangling"
		do: [:each | each becomeFormerEmployeeOf: self. each removeJobRole.
			self allOrgUnits do: [:unit | unit removeMember: each] ].
	employees := self allOrgUnits inject: Set new into: [:sett :each | 
		sett addAll: each allPersonsWithJobRoles; yourself].
	(employees reject: [:each | set includes: each])
		do: [: each | each removeJobRole].! !

!Company methodsFor: 'private'!
preferredUrl
	| nme |
	nme := (self name copyUpTo: $ ) trimBlanks asSloveneWithoutCircumflexes asHttpFriendly.
	^'/', nme! !

!Company methodsFor: 'private'!
printString
	^'company: ', self name! !


!Company methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
company
	^self! !

!Company methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
employeeNamed: aString
	^self allEmployees detect: [:each | aString = each name] ifNone: [nil]! !

!Company methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
employeeNamedSurnamed: aString
	^self allEmployees detect: [:each | aString = each nameSurname] ifNone: [nil]! !

!Company methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
employeeSurnamedNamed: aString
	^self allEmployees detect: [:each | aString = each surnameName] ifNone: [nil]! !

!Company methodsFor: 'accessing'!
level
	"company is a top level 0 of the org.unit hierarchy"
	^0! !


!Company methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
existEmployeeWithId: aString
	^self allEmployees contains: [:each | each id = aString].! !

!Company methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
existEmployeeWithName: aNameString surname: aSurnameString
	^self allEmployees contains: [:each | 
		(each name = aNameString) and: [each surname = aSurnameString]].! !

!Company methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
isCompany
	^true! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Company class
	instanceVariableNames: ''!

!Company class methodsFor: 'odb specific' stamp: ' 10/1/08 16:40'!
replicationSpecaa
	"Gemstone"
	^#( 	(id 	replicate)
			(name replicate)
			(description replicate)
			(addresses max 4)
			(roles max 2)
			(relatedPartyRoles max 2)
			(events forwarder)
			(relatedObjects max 1) )! !


Object subclass: #PartyCollection
	instanceVariableNames: 'parent parties'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Parties'!
!PartyCollection commentStamp: '<historical>' prior: 0!
PartyCollection is used for doing many things on mix of org.units, roles, rolegroups and persons. For instance, geting out all persons from above mix ...

Instance Variables:
	parent	<aParty>	a root party, containing that mix of parties (eg. a company)
	parties	<anOrderedCollection>	mix of parties (orgUniits, roles, roleGroups, persons)

!


!PartyCollection methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
add: aPartyOrRole
	"anOrganizationalUnit, aRole, aRoleGroup or aPerson"
	self parties add: aPartyOrRole! !

!PartyCollection methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
addAll: aPartyCollection
	aPartyCollection do: [:each | self add: each]! !

!PartyCollection methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
from: aPartyCollection
	self initParties.
	self addAll: aPartyCollection! !

!PartyCollection methodsFor: 'adding-removing' stamp: ' 10/1/08 16:40'!
remove: aPartyOrRole
	"anOrganizationalUnit, aRole, aRoleGroup or aPerson"
	self parties remove: aPartyOrRole! !


!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
all
	^self parties copy! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
allJobRoles
	^self parties select: [:each | each isKindOf: JobRole].! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
allOrgUnits
	^self parties select: [:each | each isKindOf: OrganizationUnit].! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
allPersons
	"both individual, from job roles and from org.units"
	| persons |
	persons := self onlyPersons asSet.
	persons := self allOrgUnits inject: persons into: [:set :each | set addAll: each allMembers; yourself].
	persons addAll: self allPersonsFromJobRoles.
	persons addAll: self allPersonsFromRoleGroups.
	^persons asOrderedCollection! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
allPersonsFromJobRoles
	| jobRoles  |
	jobRoles := self allJobRoles asSet.
	^self allParentPersons select: [:each |
		each jobRole notNil and: [jobRoles includes: each jobRole parentRole] ].

"	^self allJobRoles inject: Set new into: [:set :each | set addAll: each allPersons; yourself]."! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
allPersonsFromOrgUnit: anOrgUnit
	| members |
	members := anOrgUnit allMembers asSet.
	^self allPersons select: [:each | members includes: each]! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
allPersonsFromRoleGroups
	| jobRoles |
	jobRoles := self allRoleGroups inject: Set new into: [:set :each | set addAll: each allRoles; yourself].
	^self allParentPersons select: [:each |
		each jobRole notNil and: [jobRoles includes: each jobRole parentRole] ]! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
allRoleGroups
	^self parties select: [:each | each isKindOf: RoleGroup].! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
allSorted
	"org.unitss first, then role groups, roles, persons"
	| all |
	all := (SortedCollection withAll: self allOrgUnits sortBlock: [:a :b | a name < b name]) 
		asOrderedCollection.
	all addAll: (SortedCollection withAll: self allRoleGroups sortBlock: [:a :b | a name < b name]).
	all addAll: (SortedCollection withAll: self allJobRoles sortBlock: [:a :b | a name < b name]).
	all addAll: (SortedCollection withAll: self onlyPersons 
		sortBlock: [:a :b | a surnameName < b surnameName]).
	^all! !

!PartyCollection methodsFor: 'accessing'!
allSortedText
	"org.unitss first, then role groups, roles, persons, as text"
	| sorted text |
	sorted := self allSorted asOrderedCollection.
	text := ''.
	sorted do: [:each |
		(each isKindOf: Person) ifTrue: [text := text, each surnameName].
		(each isKindOf: OrganizationUnit) ifTrue: [text := text, each name].
		(each isKindOf: RoleGroup) ifTrue: [text := text, each name].
		each = sorted last ifFalse: [text := text, ', '] ].
	^text! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
onlyPersons
	"just individual persons"
	^self parties select: [:each | each isKindOf: Person]! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
parent
	^parent! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
parent: aCompany
	"a root company, containing those mix of parties"
	parent := aCompany! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
partyOrRoleNamed: aString
	^self parties detect: [:each | each nameToDisplay = aString] ifNone: [nil].! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
size
	^self parties size! !

!PartyCollection methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
sort
	"permanently sort a parties collection"
	self from: self allSorted! !


!PartyCollection methodsFor: 'accessing-parent' stamp: ' 10/1/08 16:40'!
allParentJobRoles
	^self parent allOrgUnits
		inject: OrderedCollection new into: [:col :each | col addAll: each allJobRoles; yourself]! !

!PartyCollection methodsFor: 'accessing-parent' stamp: ' 10/1/08 16:40'!
allParentOrgUnits
	^self parent allOrgUnits! !

!PartyCollection methodsFor: 'accessing-parent' stamp: ' 10/1/08 16:40'!
allParentOrgUnitsRolesPersons
	"sorted in that order.."
	| all |
	all := (SortedCollection withAll: self allParentOrgUnits sortBlock: [:a :b | a name < b name]) 
		asOrderedCollection.
	all addAll: (SortedCollection withAll: self allParentRoleGroups sortBlock: [:a :b | a name < b name]).
	all addAll: (SortedCollection withAll: self allParentJobRoles sortBlock: [:a :b | a name < b name]).
	all addAll: (SortedCollection withAll: self allParentPersons 
		sortBlock: [:a :b | a surnameName < b surnameName]).
	^all! !

!PartyCollection methodsFor: 'accessing-parent' stamp: ' 10/1/08 16:40'!
allParentPersons
	^self parent allEmployees! !

!PartyCollection methodsFor: 'accessing-parent' stamp: ' 10/1/08 16:40'!
allParentRoleGroups
	^self parent allRoleGroups! !

!PartyCollection methodsFor: 'accessing-parent' stamp: ' 10/1/08 16:40'!
parentPartyOrRoleNamed: aString
	(aString isNil or: [aString isEmpty]) ifTrue: [^nil].
	^self allParentOrgUnitsRolesPersons detect: [:each | each nameToDisplay = aString] ifNone: [nil].! !


!PartyCollection methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
includes: aPartyOrRole
	^self parties includes: aPartyOrRole! !

!PartyCollection methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
notEmpty
	^self parties notEmpty! !


!PartyCollection methodsFor: 'initialize-release' stamp: ' 10/1/08 16:40'!
initParties
	parties := OrderedCollection new.! !


!PartyCollection methodsFor: 'private' stamp: ' 10/1/08 16:40'!
parties
	parties isNil ifTrue: [self initParties].
	^parties! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

PartyCollection class
	instanceVariableNames: ''!

!PartyCollection class methodsFor: 'instance creation' stamp: ' 10/1/08 16:40'!
newOn: aCompany
	^super new parent: aCompany! !

!PartyCollection class methodsFor: 'instance creation' stamp: ' 10/1/08 16:40'!
newOn: aCompany from: aPartyCollection
	^(self newOn: aCompany) from: aPartyCollection! !


Party subclass: #Person
	instanceVariableNames: 'surname'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Parties'!
!Person commentStamp: '<historical>' prior: 0!
Person as a party, with his roles and relations to other parties. 

Note that aPerson has its corresponding aWebUser and vice versa. From historical reasons, hopefully soon those two clases will be merged into Person!!!


!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
allDeputies
	"all deputies of that person"
	^(self relatedPartyRoles select: [:role | role isDeputyRole]) collect: [:each | each party]! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
allDeputyOf
	"all persons to whom that person is deputy"
	^(self roles select: [:role | role isDeputyRole]) collect: [:each | each relatedParty]! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
allOrgUnits
	"all org.units where person is member"
	^((self roles select: [:role | role isMemberRole]) collect: [:role | role relatedParty]) asSet.! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
becomeDeputyOf: aPerson
	| role |
	(self isDeputyOf: aPerson) ifTrue: [^false].
	role := DeputyRole new.
	role name: 'deputy role'.
	self newRole: role relatedTo: aPerson.! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
becomeEmployeeOf: aParty 
	"I become an employee of that party"
	| role |
	(self isEmployeeOf: aParty) ifTrue: [^false].
	role := EmployeeRole new.
	role name: 'employee role'.
	self newRole: role relatedTo: aParty.

	self noMoreFormerEmployeeOf: aParty "if it was former before"! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
becomeFormerEmployeeOf: aParty 
	"I become an employee of that party"
	| role |
	(self isFormerEmployeeOf: aParty) ifTrue: [^false].
	role := FormerEmployeeRole new.
	role name: 'former employee role'.
	self newRole: role relatedTo: aParty! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
becomeMemberOf: anOrgUnit 
	"I become a member  of that org.unit"
	| role |
	(self isMemberOf: anOrgUnit) ifTrue: [^false].
	role := MemberRole new.
	role name: 'member role'.
	self newRole: role relatedTo: anOrgUnit! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
company
	"in which he is employeed"
	| parties |
	parties :=  (self roles select: [:role | role isEmployeeRole]) 
		collect: [:each | each relatedParty].
	parties := parties addAll:
		((self relatedPartyRoles select: [:role | role isEmployeeRole]) 
			collect: [:each | each party]);
		yourself.
	^parties isEmpty ifTrue: [nil] ifFalse: [parties first]! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
jobParentRole
	self jobRole isNil ifTrue: [^nil].
	^self jobRole parentRole.! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
jobRole
	^self roles detect: [:role | role isJobRole] ifNone: [^nil].! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
jobRoleName
	^self jobRole notNil ifTrue: [self jobRole name] ifFalse: [''].! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
jobRoleNamed: aString
	"org.unit should have this job role already defined!!"
	| parentRole |
	self organizationUnit isNil ifTrue: [^nil].
	parentRole := self organizationUnit jobRoleNamed: aString. parentRole isNil ifTrue: [^nil].
	self jobRole notNil ifTrue: [self removeJobRole].
	self newRole: parentRole newChildRole relatedTo: self company! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
noMoreDeputyOf: aPerson
	| role |
	role := self roles 
		detect: [:each | each relatedParty == aPerson and: [each isDeputyRole] ] ifNone: [nil].
	role notNil ifTrue: [self discontinueRole: role].
	role := aPerson relatedPartyRoles 
		detect: [:each | each relatedParty == self and: [each isDeputyRole] ] ifNone: [nil].
	role notNil ifTrue: [aPerson discontinueRole: role].! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
noMoreEmployeeOf: aParty 
	"no more an employee of related party"
	| role |
	role := self roles 
		detect: [:each | each relatedParty == aParty and: [each isEmployeeRole] ] ifNone: [nil].
	role notNil ifTrue: [self discontinueRole: role].
	role := aParty relatedPartyRoles 
		detect: [:each | each relatedParty == self and: [each isEmployeeRole] ] ifNone: [nil].
	role notNil ifTrue: [aParty discontinueRole: role].

	self becomeFormerEmployeeOf: aParty.! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
noMoreFormerEmployeeOf: aParty 
	| role |
	role := self roles 
		detect: [:each | each relatedParty == aParty and: [each isFormerEmployeeRole] ] ifNone: [nil].
	role notNil ifTrue: [self discontinueRole: role].
	role := aParty relatedPartyRoles 
		detect: [:each | each relatedParty == self and: [each isFormerEmployeeRole] ] ifNone: [nil].
	role notNil ifTrue: [aParty discontinueRole: role].! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
noMoreMemberOf: anOrgUnit 
	"no more a memebr of related party"
	(self isMemberOf: anOrgUnit) ifFalse: [^nil].
	self discontinueRole:
		(self roles detect: [:role | role relatedParty == anOrgUnit and: [role isMemberRole] ] ifNone: [^nil])! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
organizationUnit
	"in which he is a member"
	| parties |
	parties :=  (self roles select: [:role | role isMemberRole]) 
		collect: [:each | each relatedParty].
	parties := parties addAll:
		((self relatedPartyRoles select: [:role | role isMemberRole]) 
			collect: [:each | each party]);
		yourself.
	^parties isEmpty ifTrue: [nil] ifFalse: [parties first]! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
organizationUnit: anOrganizationUnit
	self allOrgUnits do: [:each | self noMoreMemberOf: each].
	anOrganizationUnit notNil ifTrue: [self becomeMemberOf: anOrganizationUnit]! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
organizationUnitName
	^self organizationUnit notNil ifTrue: [self organizationUnit name] ifFalse: ['']! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
removeJobRole
	self jobRole notNil ifTrue: [self discontinueRole: self jobRole].! !

!Person methodsFor: 'roles - specific' stamp: ' 10/1/08 16:40'!
specialRoleCollection
	"a set of additional roles by person's org.unit and org.hierarch up to the top"
	^self organizationUnit notNil
		ifTrue: [self organizationUnit specialRoleCollection]
		ifFalse: [self company notNil
			ifTrue: [self company specialRoleCollection]
			ifFalse: [OrderedCollection new] ].! !


!Person methodsFor: 'accessing' stamp: 'mivsek 1/10/2008 16:46'!
asICalUser
	^ICUser new
		commonName: self nameSurname  asSloveneWithoutCircumflexes "Outlook!!" ;
		emailAddress: self email! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
asPerson
	^self! !

!Person methodsFor: 'accessing' stamp: 'janko 8/6/2011 19:42'!
asWebUser
	"parallel WebUser object"
	^self otherAt: #WebUser ifAbsent: [^nil]! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
email
	^self asWebUser notNil 
		ifTrue: [self asWebUser email]
		ifFalse: [super email].! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
email: aString 
	self asWebUser notNil 
		ifTrue: [self asWebUser email: aString]
		ifFalse: [super email: aString].! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
menuName
	"in dropdown menus"
	^self surnameName! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
nameSurname
	^self name, ' ', self surname! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
nameToDisplay
	"on web pages for instance"
	^self surnameName! !

!Person methodsFor: 'accessing' stamp: 'janko 3/16/2008 17:00'!
password
	self asWebUser notNil ifTrue: [^self asWebUser password].
	^nil! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
password: aString 
	self asWebUser notNil ifTrue: [^self asWebUser password: aString trimBlanks].! !

!Person methodsFor: 'accessing' stamp: 'np 10/20/2008 16:38'!
passwordText
	"password is encripted/invisible anway, so return just empty "
	^''! !

!Person methodsFor: 'accessing' stamp: 'np 10/20/2008 16:38'!
passwordText: aString
	aString = self passwordText "all *****, this means that password was not changed"
		ifTrue: [^nil]. 
	aString trimBlanks isEmpty ifTrue: [^nil].
	^self password: aString! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
repository
	self organizationUnit notNil ifTrue: [^self organizationUnit repository].
	^self company notNil ifTrue: [self company repository] ifFalse: [nil].! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
surname
	surname isNil ifTrue: [self surname: ''].
	^surname! !

!Person methodsFor: 'accessing' stamp: 'janko 3/16/2008 17:00'!
surname: aString
	surname := aString trimBlanks! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
surnameName
	^self surname, ' ', self name! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
surnameName2
	^self surnameName trimBlanks notEmpty 
		ifTrue: [self surnameName]
		ifFalse: ['--brez priimka in imena---']! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
username
	self asWebUser notNil ifTrue: [^self asWebUser username].
	^nil! !

!Person methodsFor: 'accessing' stamp: ' 10/1/08 16:40'!
username: aString 
	self asWebUser notNil ifTrue: [^self asWebUser username: aString trimBlanks].! !

!Person methodsFor: 'accessing' stamp: 'janko 8/6/2011 19:38'!
webUser: aWebUser
	"a parallel WebUser for web server security etc."
	self otherAt: #WebUser put: aWebUser.
	(aWebUser otherAt: #Person) ~= self ifTrue: [aWebUser person: self].! !


!Person methodsFor: 'accessing-other'!
companyOwner
	"this person is owner of default company"
	^self otherValuesAt: #CompanyOwner ifAbsent: [false]! !

!Person methodsFor: 'accessing-other'!
companyOwner: aBoolean
	"this person is owner of default company"
	self otherValuesAt: #CompanyOwner put: aBoolean.! !

!Person methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:42'!
integratedWithOffice
	"WebDAV integration on MS IE"
	^self otherAt: #integratedWithOffice ifAbsent: [false]! !

!Person methodsFor: 'accessing-other' stamp: 'janko 8/6/2011 19:44'!
integratedWithOffice: aBoolean
	"WebDAV integration on MS IE"
	self otherAt: #integratedWithOffice put: aBoolean.! !


!Person methodsFor: 'testing'!
hasEMail 
	^self email ~= ''! !

!Person methodsFor: 'testing'!
hasValidEMail 
	^self hasEMail and: [self email isValidEMailAddress]! !

!Person methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
isPerson
	^true! !

!Person methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
isWebUser
	^false! !

!Person methodsFor: 'testing' stamp: ' 10/1/08 16:40'!
isWebUserGroup
	^false! !


!Person methodsFor: 'roles - testing' stamp: ' 10/1/08 16:40'!
haveDeputies
	^self relatedPartyRoles contains: [:role | role isDeputyRole].! !

!Person methodsFor: 'roles - testing'!
isCompanyOwner
	"this person is owner of default company"
	^self companyOwner! !

!Person methodsFor: 'roles - testing' stamp: ' 10/1/08 16:40'!
isDeputy
	^self roles contains: [:role | role isDeputyRole].! !

!Person methodsFor: 'roles - testing' stamp: ' 10/1/08 16:40'!
isDeputyOf: aPerson
	^self roles contains: [:role | role relatedParty == aPerson and: [role isDeputyRole] ].! !

!Person methodsFor: 'roles - testing' stamp: ' 10/1/08 16:40'!
isEmployeeOf: aParty
	| employee |
	employee := self roles contains: [:role | role relatedParty == aParty and: [role isEmployeeRole] ].
	employee ifTrue: [^true].
	"check also a complementary role"
	^self relatedPartyRoles contains: [:role | role party == aParty and: [role isEmployeeRole] ].! !

!Person methodsFor: 'roles - testing' stamp: ' 10/1/08 16:40'!
isFormerEmployeeOf: aParty
	| formerEmployee |
	formerEmployee := self roles contains: [:role | 
		role relatedParty == aParty and: [role isFormerEmployeeRole]].
	formerEmployee ifTrue: [^true].
	"check also a complementary role"
	^self relatedPartyRoles contains: [:role | role party == aParty and: [role isFormerEmployeeRole] ].! !

!Person methodsFor: 'roles - testing' stamp: ' 10/1/08 16:40'!
isMemberOf: anOrgUnit
	| isMember |
	isMember := self roles contains: [:role | role relatedParty == anOrgUnit and: [role isMemberRole] ].
	isMember ifTrue: [^true].
	"check also a complementary role"
	^self relatedPartyRoles contains: [:role | role party == anOrgUnit and: [role isMemberRole] ].! !


!Person methodsFor: 'private' stamp: ' 10/1/08 16:40'!
migrateToUnicode
	"from iso8859-2"
	"Person allInstances do: [:each | each migrateToUnicode]"
	super migrateToUnicode.
	surname notNil ifTrue: [surname := surname ensureUnicodeSloveneChars].! !

!Person methodsFor: 'private' stamp: 'janko 3/19/2012 13:21'!
preferredUrl
	| nme |
	nme := self surnameName trimBlanks asSloveneWithoutCircumflexes.
	^'/oseba/', nme asHttpFriendly.

"Person allInstances do: [:each | 
	each repository notNil ifTrue: [each repository site urlResolver changeToPreferedURL: each] ]"! !

!Person methodsFor: 'private' stamp: ' 10/1/08 16:40'!
printString
	^'Person: ', self name, ' ', self surname! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Person class
	instanceVariableNames: ''!

!Person class methodsFor: 'instance creation'!
newWithRelatedWebUserOn: anAIDASite
	| instance |
	instance := super new.
	instance webUser: (anAIDASite webUserClass new person: instance; parent: anAIDASite securityManager).
	^instance! !
