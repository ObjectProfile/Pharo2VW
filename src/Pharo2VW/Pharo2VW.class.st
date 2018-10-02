"
I am pharo exporter for visual works, please check my examples in order to know how to use me
"
Class {
	#name : #Pharo2VW,
	#superclass : #Object,
	#instVars : [
		'directory',
		'namespace',
		'externalNamespaces',
		'packagesTags',
		'classes',
		'methods',
		'methodsBlacklist',
		'writer',
		'mapper'
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

{ #category : #accessing }
Pharo2VW >> classNameMapper [
	^ mapper ifNil: [ mapper := Pharo2VWClassNameMapper new]
]

{ #category : #accessing }
Pharo2VW >> classNameMapperDo: block [
	block value: self classNameMapper 
]

{ #category : #accessing }
Pharo2VW >> classes [
	^ classes ifNil: [ classes := self packagesTags flatCollect: [ :pkg | pkg classes ] as: OrderedCollection ]
]

{ #category : #'export helpers' }
Pharo2VW >> convertCurlyBraces: aCompiledMethod [
	| ast |
	ast := aCompiledMethod copy ast.
	Pharo2VWCurlyBracesConvertor new visitNode: ast.
	^ BISimpleFormatter format: ast
]

{ #category : #'export helpers' }
Pharo2VW >> convertToVisualworksName: aClass [
	^ self classNameMapper fullNameForClass: aClass
]

{ #category : #accessing }
Pharo2VW >> directory [
	^ directory
]

{ #category : #accessing }
Pharo2VW >> directory: aNewDirectory [
	directory := aNewDirectory
]

{ #category : #public }
Pharo2VW >> export [
	| filename stream |
	filename := self directory / (self namespace , '.st').
	filename exists
		ifTrue: [ filename delete ].
	stream := filename writeStream.
	writer := (XMLWriter on: stream)
		enablePrettyPrinting;
		yourself.
	[ writer xml.
	writer
		tag: 'st-source'
		with: [ self fileOutTimeStamp.
			self fileOutNameSpace.
			self fileOutClassDefinitions.
			self fileOutMethods.
			self fileOutInitializers ].
	writer write ]
		ensure: [ stream close ]
]

{ #category : #accessing }
Pharo2VW >> externalNamespaces [
	^ externalNamespaces
]

{ #category : #accessing }
Pharo2VW >> externalNamespaces: array [
	externalNamespaces := array.
]

{ #category : #export }
Pharo2VW >> fileOutClassCommentForClass: aClass [
	aClass hasComment
		ifFalse: [ ^ self ].
	writer
		tag: 'comment'
		with: [ writer tag: 'class-id' with: (self fullyQualifiedClassNameFor: aClass).
			writer tag: 'body' with: aClass comment asXMLEscapedString ]
]

{ #category : #export }
Pharo2VW >> fileOutClassDefinition: aClass [	
	writer tag: 'class' with: [
		writer tag: 'name' with: (self classNameMapper on: aClass).
		writer tag: 'environment' with: self namespace.
		writer tag: 'super' with: (self fullyQualifiedClassNameFor: aClass superclass).
		writer tag: 'private' with: 'false'.
		writer tag: 'indexed-type' with: (self mapType: aClass typeOfClass).
		writer tag: 'inst-vars' with: aClass instanceVariablesString.
		writer tag: 'class-inst-vars' with: aClass class instanceVariablesString.
		writer tag: 'imports' with: ''.
		writer tag: 'category' with: aClass category.
		writer tag: 'attributes' with: [
			writer tag: 'package' with: (self packageNameForClass: aClass).
		]
	].

	aClass classPool keys do: [:ea | 
		self fileOutClassVariable: ea class: aClass].
	
	self fileOutClassCommentForClass: aClass
]

{ #category : #export }
Pharo2VW >> fileOutClassDefinitions [
	((Class superclassOrder: self classes copy) select: #isClass)
		do: [:ea | self fileOutClassDefinition: ea]
		displayingProgress: 'Filing out classes...'
]

{ #category : #export }
Pharo2VW >> fileOutClassVariable: aSymbol class: aClass [	
	writer tag: 'shared-variable' with: [
		writer tag: 'name' with: aSymbol.
		writer tag: 'environment' with: (self fullyQualifiedClassNameFor: aClass).
		writer tag: 'private' with: 'false'.
		writer tag: 'constant' with: 'false'.
		writer tag: 'category' with: 'class variables'.
		writer tag: 'initializer' with: 'nil'.
		writer tag: 'attributes' with: [
			writer tag: 'package' with: (self packageNameForClass: aClass).
		]
	]
]

{ #category : #export }
Pharo2VW >> fileOutInitializerForClass: aClass [
	writer tag: 'initialize' with: [
		writer tag: 'class-id' with: (self fullyQualifiedClassNameFor: aClass)
	]
]

{ #category : #export }
Pharo2VW >> fileOutInitializers [		
	(self classes select: [:c | c class includesSelector: #initialize])
		do: [:class | self fileOutInitializerForClass: class].
]

{ #category : #export }
Pharo2VW >> fileOutMethod: aMethodReference [
	writer tag: 'methods' with: [
		writer
			tag: 'class-id' 
			with: (self fullyQualifiedClassNameFor: aMethodReference realClass).
		writer tag: 'category' with: (self categoryForMethod: aMethodReference).
		self fileOutMethodBody: aMethodReference.
	]
]

{ #category : #export }
Pharo2VW >> fileOutMethodBody: aMethodReference [
	| ref methodString sourceCode |
	sourceCode := self convertCurlyBraces: aMethodReference. "This conversion does not add new dependencies (except for Array , #new: #at:put: and #yourself. Which are already existing in VW)"
	methodString := self prettyPrint: sourceCode asString.

	"See if an extension method includes a reference to some of our classes"
	ref := self getClassNamesUsedIn: aMethodReference.
	"Prefix the class names with the target namespace"
	ref do: [ :className | methodString := methodString copyReplaceTokens: className with: self environment , '.' , className ].
	writer
		tag: 'body'
		attributes: {('package' -> (self packageNameForMethod: aMethodReference))} asDictionary
		with: methodString asXMLEscapedString
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
	writer
		tag: 'name-space'
		with: [ writer tag: 'name' with: self namespace.
			writer tag: 'environment' with: 'Smalltalk'.
			writer tag: 'private' with: 'false'.
			writer tag: 'imports' with: self nameSpaceImports ].
	writer tag: 'category' with: self namespace.
	writer tag: 'attributes' with: [ writer tag: 'package' with: self namespace ]
]

{ #category : #export }
Pharo2VW >> fileOutTimeStamp [
	writer tag: 'time-stamp'
		with: 'From ', Smalltalk version, ' on ', Date today printString, ' at ', Time now printString.
]

{ #category : #export }
Pharo2VW >> fullyQualifiedClassNameFor: aClass [
	aClass ifNil: [ ^ 'SharedPool' ].
	^ (self includesClass: aClass)
		ifTrue: [self namespace, '.', aClass name]
		ifFalse: [ | pkg |
			pkg := self packageFor: aClass.
			pkg ifNil: [ self convertToVisualworksName: aClass ]
			ifNotNil: [ pkg name, '.', aClass name ]
			].
]

{ #category : #export }
Pharo2VW >> getClassNamesUsedIn: aMethodReference [
	"Answers the names of those of our classes that are referenced
	an extension method"

	(self classes includes: aMethodReference realClass instanceSide)
		ifTrue: [ "Not an extension method" ^ #() ].
	^ (aMethodReference literals
		select: [ :lit | 
			lit class == GlobalVariable
				and: [ lit value isBehavior
						and:
							[ lit key == lit value name and: [ self mustBeQualified: lit value ] ] ] ])
		collect: [ :lit | lit key ]
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
	namespace := nil.
	externalNamespaces := #()
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
				cls isTrait ifFalse: [ 
					methods addAll: cls class methods ].
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
	| imports |
	imports := Set with: #Smalltalk.
	imports addAll: self externalNamespaces.
	
	imports remove: self namespace asSymbol ifAbsent: [ "it was not there" ].
	^ String
		streamContents: [ :stream | 
			imports
				do: [ :ea | 
					stream
						nextPutAll: 'private ';
						nextPutAll: ea;
						nextPutAll: '.*' ]
				separatedBy: [ stream space ] ]
]

{ #category : #accessing }
Pharo2VW >> namespace [
	^ namespace
]

{ #category : #accessing }
Pharo2VW >> namespace: aString [
	namespace := aString
]

{ #category : #public }
Pharo2VW >> package: aString [
	self packages: {aString}
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
	^ aClass instanceSide category
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

{ #category : #'export helpers' }
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
