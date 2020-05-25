Object subclass: #Role
	instanceVariableNames: 'name party relatedParty other'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Roles'!
!Role commentStamp: '<historical>' prior: 0!
Role is abstract class to show the role one party has in relationship with another, like this person is an employee to that company.

!


!Role methodsFor: 'initialize-release' stamp: 'janko 8/8/2011 18:09'!
initOther
	other := Dictionary new.! !


!Role methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isCustomerRole
	^false! !

!Role methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isDeputyRole
	^false! !

!Role methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isEmployeeRole
	^false! !

!Role methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isFormerEmployeeRole
	^false! !

!Role methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isJobRole
	^false! !

!Role methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isMemberRole
	^false! !

!Role methodsFor: 'testing'!
isPerson
	^false! !

!Role methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isRole
	^true! !

!Role methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isRoleGroup
	^false! !

!Role methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isSupplierRole
	^false! !


!Role methodsFor: 'private' stamp: ' 10/1/08 16:41'!
migrateToUnicode
	"from iso8859-2"
	name notNil ifTrue: [name := name ensureUnicodeSloveneChars].! !

!Role methodsFor: 'private' stamp: 'janko 8/8/2011 18:07'!
other
	^other! !

!Role methodsFor: 'private' stamp: 'janko 8/8/2011 18:07'!
otherAt: aSymbol
	"other values"
	^self otherAt: aSymbol ifAbsent: [nil]! !

!Role methodsFor: 'private' stamp: 'janko 8/8/2011 18:08'!
otherAt: aSymbol ifAbsent: aBlock
	"other values"
	self other isNil ifTrue: [^aBlock value].
	^self other at: aSymbol ifAbsent: aBlock! !

!Role methodsFor: 'private' stamp: 'janko 8/8/2011 18:08'!
otherAt: aSymbol ifAbsentPut: aBlock
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol ifAbsent: [self other at: aSymbol put: aBlock value]! !

!Role methodsFor: 'private' stamp: 'janko 8/8/2011 18:08'!
otherAt: aSymbol put: anObject
	self other isNil ifTrue: [self initOther].
	^self other at: aSymbol put: anObject! !

!Role methodsFor: 'private' stamp: ' 10/1/08 16:41'!
printString
	^'aRole ', self name! !


!Role methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
name
	^name! !

!Role methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
name: aString
	name := aString.! !

!Role methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
nameToDisplay
	^self name! !

!Role methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
party
	^party! !

!Role methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
party: aParty
	party := aParty.! !

!Role methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
relatedParty
	^relatedParty! !

!Role methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
relatedParty: aParty
	relatedParty := aParty.! !

!Role methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
uuid
	"some unique identifier. Hash for now, probably unique enough!! "
	^self hash printString! !


Role subclass: #MemberRole
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Roles'!
!MemberRole commentStamp: '<historical>' prior: 0!
MemberRole for a person becoming a member of some organizational unit.
!


!MemberRole methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isEmployeeRole
	^true! !

!MemberRole methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isMemberRole
	^true! !


!MemberRole methodsFor: 'private' stamp: ' 10/1/08 16:41'!
printString
	^'aMemberRole ', self name! !


Object subclass: #RoleGroup
	instanceVariableNames: 'name subroles'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Roles'!
!RoleGroup commentStamp: '<historical>' prior: 0!
To group more roles or other groups together. to build a hierarchy of roles. If you use somewhere RoleGroup instead of Role, then you access all Roles together.

Instance Variables:
	name	<String> name of role group
	subroles	<Role | RoleGroup>	group of roles or other role groups

!


!RoleGroup methodsFor: 'adding-removing' stamp: ' 10/1/08 16:41'!
add: aRoleOrGroup
	(self subroles includes: aRoleOrGroup) ifFalse: [self subroles add: aRoleOrGroup]! !

!RoleGroup methodsFor: 'adding-removing' stamp: ' 10/1/08 16:41'!
includes: aRoleOrGroup
	^self subroles includes: aRoleOrGroup! !

!RoleGroup methodsFor: 'adding-removing' stamp: ' 10/1/08 16:41'!
remove: aRoleOrGroup
	(self subroles includes: aRoleOrGroup) ifTrue: [self subroles remove: aRoleOrGroup]! !


!RoleGroup methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
allPersonsWithJobRoles
	"collect all persons holding job roles as part of that role group"
	^self allRoles inject: Set new into: [:set :role | set addAll: role allPersons; yourself].! !

!RoleGroup methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
allRoleGroups
	^self subroles select: [:each | each isRoleGroup]! !

!RoleGroup methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
allRoles
	^self subroles select: [:each | each isRole]! !

!RoleGroup methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
name
	^name! !

!RoleGroup methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
name: aString
	name := aString.! !

!RoleGroup methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
nameToDisplay
	^name! !

!RoleGroup methodsFor: 'accessing' stamp: ' 10/1/08 16:41'!
uuid
	"some unique identifier. Hash for now, probably unique enough!! "
	^self hash printString! !


!RoleGroup methodsFor: 'private' stamp: ' 10/1/08 16:41'!
initSubroles
	subroles := OrderedCollection new.! !

!RoleGroup methodsFor: 'private' stamp: ' 10/1/08 16:41'!
migrateToUnicode
	"from iso8859-2"
	name notNil ifTrue: [name := name ensureUnicodeSloveneChars].! !

!RoleGroup methodsFor: 'private' stamp: ' 10/1/08 16:41'!
printString
	^'aRoleGroup ', self name! !

!RoleGroup methodsFor: 'private' stamp: ' 10/1/08 16:41'!
subroles
	subroles isNil ifTrue: [self initSubroles].
	^subroles! !


!RoleGroup methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isPerson
	^false! !

!RoleGroup methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isRole
	^false! !

!RoleGroup methodsFor: 'testing' stamp: ' 10/1/08 16:41'!
isRoleGroup
	^true! !


Role subclass: #WebSiteOwnerRole
	instanceVariableNames: 'webSite'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Roles'!
!WebSiteOwnerRole commentStamp: '<historical>' prior: 0!
WebSiteOwnerRole for a person owning certain website!



Role subclass: #WebUserRole
	instanceVariableNames: 'username password'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Aida-Roles'!
!WebUserRole commentStamp: '<historical>' prior: 0!
WebUserRole for a person being an user registered on certain website
!


!WebUserRole methodsFor: 'private' stamp: ' 10/1/08 16:41'!
printString
	^'aWebUserRole ', self name! !
