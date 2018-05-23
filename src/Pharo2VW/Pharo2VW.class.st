"
I am pharo exporter for visual works, please check my examples in order to know how to use me
"
Class {
	#name : #Pharo2VW,
	#superclass : #Object,
	#instVars : [
		'directory',
		'environment',
		'externalNamespaces',
		'packagesTags',
		'classes',
		'methods',
		'stream',
		'methodsBlacklist',
		'checkForArrays',
		'showMethodsWithArray'
	],
	#category : #'Pharo2VW-Core'
}

{ #category : #'instance creation' }
Pharo2VW class >> exporter [
	^ self new
]

{ #category : #'export helpers' }
Pharo2VW >> categoryForMethod: method [
	^ method category ifNil: [ 'as yet unclassified' ]
]

{ #category : #public }
Pharo2VW >> checkForArrays [
	checkForArrays := true
]

{ #category : #checking }
Pharo2VW >> checkForBadArraysIfNecessary [
	| list  |
	self shouldCheckForArrays ifFalse: [ ^ self ].
	list := OrderedCollection new.
	self methods do: [ :met | 
		(self methodsBlacklist includes: met) ifFalse: [  
			(self hasArray: met) ifTrue: [ list add: met ] ] ]
		displayingProgress: 'Checking methods'.
	list isEmpty ifTrue: [ ^ self ]. 
	self showMethodsWithArray 
		ifTrue: [ list do: [ :met | met browse ]. self error: 'Please check this methods!' ]
		ifFalse: [ self error: 'You have: ', list size asString, ' methods with {} please check' ].
]

{ #category : #accessing }
Pharo2VW >> classes [
	^ classes ifNil: [ classes := OrderedCollection new.
		self packagesTags do: [ :pkg | classes addAll: pkg classes ].
		classes ].
]

{ #category : #accessing }
Pharo2VW >> directory [
	^ directory
]

{ #category : #accessing }
Pharo2VW >> directory: aNewDirectory [
	directory := aNewDirectory
]

{ #category : #accessing }
Pharo2VW >> environment [
	^ environment
]

{ #category : #accessing }
Pharo2VW >> environment: aString [
	environment := aString
]

{ #category : #public }
Pharo2VW >> export [
	| filename |
	self checkForBadArraysIfNecessary.
	filename := self directory / (self environment , '.st').
	filename exists
		ifTrue: [ filename delete ].
	stream := filename writeStream.
	[ stream
		nextPutAll: '<?xml version="1.0"?>';
		cr;
		cr.
	self
		tag: 'st-source'
		do: [ self fileOutTimeStamp.
			self fileOutNameSpace.
			self fileOutClassDefinitions.
			self fileOutMethods.
			self fileOutInitializers ] ]
		ensure: [ stream close ]
]

{ #category : #accessing }
Pharo2VW >> externalNamespaces [
	^ externalNamespaces ifNil: [ externalNamespaces := #() ].
]

{ #category : #accessing }
Pharo2VW >> externalNamespaces: array [
	externalNamespaces := array.
]

{ #category : #export }
Pharo2VW >> fileOutClassCommentForClass: aClass [
	
	aClass hasComment ifFalse: [^self].
	stream cr.
	self tag: 'comment' do: [
		self tag: 'class-id' with: (self fullyQualifiedClassNameFor: aClass).
		self tag: 'body' with:  (((aClass comment asString copyReplaceAll: '&' with: '&amp;') copyReplaceAll: '<' with:  '&lt;' ) copyReplaceAll:  '>' with:  '&gt;').
	]
]

{ #category : #export }
Pharo2VW >> fileOutClassDefinition: aClass [
	stream cr.
	
	self tag: 'class' do: [
		self tag: 'name' with: aClass name.
		self tag: 'environment' with: self environment.
		self tag: 'super' with: (self fullyQualifiedClassNameFor: aClass superclass).
		self tag: 'private' with: 'false'.
		self tag: 'indexed-type' with: (self mapType: aClass typeOfClass).
		self tag: 'inst-vars' with: aClass instanceVariablesString.
		self tag: 'class-inst-vars' with: aClass class instanceVariablesString.
		self tag: 'imports' with: ''.
		self tag: 'category' with: aClass category.
		self tag: 'attributes' do: [
			self tag: 'package' with: (self packageNameForClass: aClass).
		]
	].

	aClass classPool keys do: [:ea | self fileOutClassVariable: ea class: aClass].
	
	self fileOutClassCommentForClass: aClass
]

{ #category : #export }
Pharo2VW >> fileOutClassDefinitions [
	(Class superclassOrder: self classes)
		do: [:ea | self fileOutClassDefinition: ea]
		displayingProgress: 'Filing out classes...'
]

{ #category : #export }
Pharo2VW >> fileOutClassVariable: aSymbol class: aClass [
	stream cr; cr.
	
	self tag: 'shared-variable' do: [
		self tag: 'name' with: aSymbol.
		self tag: 'environment' with: (self fullyQualifiedClassNameFor: aClass).
		self tag: 'private' with: 'false'.
		self tag: 'constant' with: 'false'.
		self tag: 'category' with: 'class variables'.
		self tag: 'initializer' with: 'nil'.
		self tag: 'attributes' do: [
			self tag: 'package' with: (self packageNameForClass: aClass).
		]
	]
]

{ #category : #export }
Pharo2VW >> fileOutInitializerForClass: aClass [
	self tag: 'initialize' do: [
		self tag: 'class-id' with: (self fullyQualifiedClassNameFor: aClass)
	]
]

{ #category : #export }
Pharo2VW >> fileOutInitializers [		
	(self classes select: [:c | c class includesSelector: #initialize])
		do: [:class | self fileOutInitializerForClass: class].
]

{ #category : #export }
Pharo2VW >> fileOutMethod: aMethodReference [
	self tag: 'methods' do: [
		self
			tag: 'class-id' 
			with: (self fullyQualifiedClassNameFor: aMethodReference realClass).
		self tag: 'category' with: (self categoryForMethod: aMethodReference).
		self fileOutMethodBody: aMethodReference.
	]
]

{ #category : #export }
Pharo2VW >> fileOutMethodBody: aMethodReference [
	| ref methodString |
	methodString := self prettyPrint: aMethodReference sourceCode asString.

	"See if an extension method includes a reference to some of our classes"
	ref := self getClassNamesUsedIn: aMethodReference.
	"Prefix the class names with the target namespace"
	ref do: 
		[:className |
		methodString := methodString
				copyReplaceTokens: className 
				with: self environment , '.' , className].

	stream
		nextPutAll: '<body package="';
		nextPutAll: (self packageNameForMethod: aMethodReference);
		nextPutAll: '">';
		nextPutAll: (((methodString copyReplaceAll: '&' with: '&amp;') copyReplaceAll: '<' with:  '&lt;' ) copyReplaceAll:  '>' with:  '&gt;');
		nextPutAll: '</body>';
		cr
]

{ #category : #export }
Pharo2VW >> fileOutMethods [
	self methods
		do: [:ea |
			(self methodsBlacklist includes: ea) 
				ifFalse: [ self fileOutMethod: ea] ]
		displayingProgress: 'Filing out methods...'
]

{ #category : #export }
Pharo2VW >> fileOutNameSpace [

	self tag: 'name-space' do: [
		self tag: 'name' with: self environment.
		self tag: 'environment' with: 'Smalltalk'.
		self tag: 'private' with: 'false'.
		self tag: 'imports' do: [
			stream nextPutAll: self nameSpaceImports; cr.
		].
		self tag: 'category' with: self environment.
		self tag: 'attributes' do: [
			self tag: 'package' with: self environment.
		].
	]
]

{ #category : #export }
Pharo2VW >> fileOutTimeStamp [
	self tag: 'time-stamp'
		with: 'From ', Smalltalk version, ' on ', Date today printString, ' at ', Time now printString.
]

{ #category : #export }
Pharo2VW >> fullyQualifiedClassNameFor: aClass [

	^ (self includesClass: aClass)
		ifTrue: [self environment, '.', aClass name]
		ifFalse: [ | pkg |
			pkg := self packageFor: aClass.
			pkg ifNil: [ aClass visualworksName]
			ifNotNil: [ pkg name, '.', aClass name ]
			].
]

{ #category : #export }
Pharo2VW >> getClassNamesUsedIn: aMethodReference [ 
	"Answers the names of those of our classes that are referenced
	an extension method"
	(self classes includes: aMethodReference realClass theNonMetaClass)
		ifTrue: ["Not an extension method"
			^ #()].
	^ (aMethodReference literals
		select: [:lit | lit class == GlobalVariable
				and: [lit value isBehavior
						and: [lit key == lit value name
								and: [self mustBeQualified: lit value]]]])
		collect: [:lit | lit key]
]

{ #category : #testing }
Pharo2VW >> hasArray: met [
	^ self hasRBArray: met ast.
	
]

{ #category : #testing }
Pharo2VW >> hasRBArray: node [
	node class = RBArrayNode ifTrue: [ ^ true ].
	node children do: [ :child |
		(self hasRBArray: child) ifTrue: [ ^ true ].
		 ].
	^ false.
	
]

{ #category : #testing }
Pharo2VW >> includesClass: class [
	| c |
	c := class isMeta ifTrue: [ class soleInstance ] ifFalse: [ class ].
	self packagesTags do: [ :pkg | (pkg includesClass: c) ifTrue: [ ^ true. ] ].
	^ false.
]

{ #category : #initialization }
Pharo2VW >> initialize [
	super initialize.
	directory := FileSystem disk workingDirectory.
	environment := nil.
	externalNamespaces := #().
	checkForArrays := showMethodsWithArray := false
]

{ #category : #export }
Pharo2VW >> mapType: aSymbol [
	aSymbol == #normal ifTrue: [^ #none].
	aSymbol == #variable ifTrue: [^ #objects].
	^ aSymbol

]

{ #category : #accessing }
Pharo2VW >> methods [
	^ methods ifNil: [ 
		methods := OrderedCollection new.
		self packagesTags do: [ :pkg | 
			methods addAll: (pkg package extensionsForTag: pkg).
			pkg classes do: [ :cls | 
				methods addAll: cls class methods.
				methods addAll: cls methods ] ].
		methods ].
]

{ #category : #accessing }
Pharo2VW >> methodsBlacklist [
	^ methodsBlacklist ifNil: [ methodsBlacklist := #() ].
]

{ #category : #accessing }
Pharo2VW >> methodsBlacklist: list [
	methodsBlacklist := list
]

{ #category : #export }
Pharo2VW >> mustBeQualified: aClass [
	"Answer true if namespace must be qualified with namespace"
	aClass = Color ifTrue: [ ^ true ].
	^(self classes includes: aClass)
		or: [aClass name beginsWith: 'WA']
]

{ #category : #'export helpers' }
Pharo2VW >> nameSpaceImports [
	| imports result |
	imports := Set with: #Smalltalk.
	imports addAll: self externalNamespaces.
	self classes do: 
		[ :ea | 
		(ea name copyFrom: 1 to: 2) = 'WA' ifTrue: [ imports add: #Seaside ].
		(ea superclass name copyFrom: 1 to: 2) = 'WA' ifTrue: [ imports add: #Seaside ] ].
	imports remove: self environment asSymbol ifAbsent:["it was not there"].
	result := String new writeStream.
	imports do: 
		[ :ea | 
		result
			nextPutAll: 'private ';
			nextPutAll: ea;
			nextPutAll: '.*' ]
		separatedBy: [ result space ].
	^ result contents
]

{ #category : #public }
Pharo2VW >> package: aString [
	self packages: (Array with: aString)
]

{ #category : #'export helpers' }
Pharo2VW >> packageFor: aClass [
	self externalNamespaces do: [ :name | | pkg |
		pkg := RPackageOrganizer default packageNamed: name.
		(pkg includesClass: aClass) ifTrue: [ ^ pkg ] ].
	^ nil.
]

{ #category : #export }
Pharo2VW >> packageNameForClass: aClass [
	^ aClass theNonMetaClass category
]

{ #category : #export }
Pharo2VW >> packageNameForMethod: aMethodReference [
	^ (self includesClass: aMethodReference realClass)
		ifTrue: [self packageNameForClass: aMethodReference realClass]
		ifFalse: [ self environment,'-Extensions']
]

{ #category : #public }
Pharo2VW >> packages: packages [
	self packages: packages  without: #().
]

{ #category : #public }
Pharo2VW >> packages: packages without: packageTags [
	| tags |
	tags := packages flatCollect: [ :n | | pkg |
		pkg := RPackageOrganizer default packageNamed: n.
		pkg classTags ].
	
	self packagesTags: (tags reject: [ :e | packageTags includes: e packageName,'-', e name ] )
]

{ #category : #accessing }
Pharo2VW >> packagesTags [
	^ packagesTags
]

{ #category : #accessing }
Pharo2VW >> packagesTags: ps [
	"a collection of packages tags"
	packagesTags := ps
]

{ #category : #export }
Pharo2VW >> prettyPrint: aString [ 
	"Replace _ with := unless it is preceded with $ or a single quote"
	| previousChar withinQuotes withinComments |
	previousChar := nil.
	withinQuotes := false.
	withinComments := false.
	^String
				streamContents: [:s | aString
						do: [:c | c = $" & withinQuotes not
								ifTrue: [withinComments := withinComments not.
									s nextPut: c.
									previousChar := nil]
								ifFalse: [c = $' & withinComments not
										ifTrue: [withinQuotes := withinQuotes not.
											s nextPut: c.
											previousChar := nil]
										ifFalse: [(c = $_
													and: [withinQuotes not
															and: [withinComments not
																	and: [(#($$ $' ) includes: previousChar) not]]])
												ifTrue: [s nextPutAll: '_']
												ifFalse: [s nextPut: c].
											previousChar := c]]]].
		

]

{ #category : #testing }
Pharo2VW >> shouldCheckForArrays [
	^ checkForArrays
]

{ #category : #testing }
Pharo2VW >> showMethodsWithArray [
	^ showMethodsWithArray
]

{ #category : #accessing }
Pharo2VW >> showMethodsWithArray: aBool [
	showMethodsWithArray := aBool
]

{ #category : #tags }
Pharo2VW >> tag: aString do: aBlock [
	stream
		nextPutAll: '<';
		nextPutAll: aString;
		nextPutAll: '>';
		cr.
		
	aBlock value.
	stream
		nextPutAll: '</';
		nextPutAll: aString;
		nextPutAll: '>';
		cr.
		
]

{ #category : #tags }
Pharo2VW >> tag: aString with: contentString [
	stream nextPutAll: '<';
		nextPutAll: aString;
		nextPutAll: '>';
		nextPutAll: contentString;
		nextPutAll: '</';
		nextPutAll: aString;
		nextPutAll: '>';
		cr.
]
