"
A Pharo2VWExporterTest is a test class for testing the behavior of Pharo2VWExporter
"
Class {
	#name : #Pharo2VWExporterTest,
	#superclass : #TestCase,
	#instVars : [
		'rootPath',
		'parsedXML'
	],
	#category : #'Pharo2VW-Tests'
}

{ #category : #running }
Pharo2VWExporterTest >> exportedFile [
	^ 'MySpaceInVW.st' asFileReference
]

{ #category : #initialization }
Pharo2VWExporterTest >> initialize [
	rootPath := ''
]

{ #category : #helpers }
Pharo2VWExporterTest >> parseGeneratedXML [
	self
		shouldnt: [ parsedXML := XMLDOMParser parse: self exportedFile contents ]
		raise: XMLException
]

{ #category : #running }
Pharo2VWExporterTest >> tearDown [
	self exportedFile ensureDelete
]

{ #category : #tests }
Pharo2VWExporterTest >> testAddInitializer [
	 | methods exporter classes |
	exporter := Pharo2VW exporter.
	exporter
		namespace: 'MySpaceInVW';
		package: 'Moose-TestResources-LAN';
		addNewInitializerToSuperclasses: true;
		export.
	self parseGeneratedXML.
	classes := exporter superclasses 
		reject: [ :cls | cls class includesSelector: #new ].
	
	methods := self xPathFor: '//methods'.
	self assert: methods size equals: exporter methods size + classes size.
	self assert: (methods last // 'body') stringValue equals:  'new
	^ super new initialize'.
]

{ #category : #tests }
Pharo2VWExporterTest >> testBasicExport [
	| inst |
	inst := Pharo2VW exporter.
	self
		assert: inst externalNamespaces class equals: Array;
		assert: inst externalNamespaces isEmpty;
		assert: inst directory equals: FileSystem disk workingDirectory;
		assert: inst namespace isNil.
	
]

{ #category : #tests }
Pharo2VWExporterTest >> testClassNameMapper [
	| exporter classes |
	exporter := Pharo2VW exporter.
	exporter
		namespace: 'MySpaceInVW';
		package: 'Moose-TestResources-LAN';
		classNameMapperDo: [ :m |
			m at: Model putName: 'MyTestModel' namespace: 'MySystemModel'];
		export.
	self assert: (exporter classNameMapper nameForClass: Model) equals: 'MyTestModel'.
	self assert: (exporter classNameMapper fullNameForClass: Model) equals: 'MySystemModel.MyTestModel'.
	self parseGeneratedXML.
	
	classes := (1 to: exporter classes size) 
		collect: [ :i |XPath for: '/st-source/class[', i asString, ']' in: parsedXML.]
		thenSelect: [:class | 
			(class // 'super') stringValue = 'MySystemModel.MyTestModel'.
		].
	self assert: (classes first // 'name') stringValue equals: 'LANNode'.
]

{ #category : #tests }
Pharo2VWExporterTest >> testCurlyBracesConversion [
	| methodsContents curlyBraced |
	Pharo2VW exporter
		namespace: 'MySpaceInVW';
		package: 'Pharo2VW-TestResources';
		export.
	self parseGeneratedXML.
	methodsContents := self xPathFor: '//methods/body'.
	curlyBraced := methodsContents detect: [ :node | node nodes first beginsWith: 'methodWithCurlyBraces' ].
	self
		assert: curlyBraced nodes first asString
		equals:
			('methodWithCurlyBraces
	(Array new: 2)
		at: 1 put: #RGMetaclassDefinition;
		at: 2
			put:
			((Array new: 2)
				at: 1 put: ''Foo'' asSymbol;
				at: 2 put: self class name asSymbol;
				yourself);
		yourself' replaceAll: Character cr with: Character lf)
]

{ #category : #tests }
Pharo2VWExporterTest >> testDoubleXMLEscaping [
	
	| methodsContents doubleXML |
	Pharo2VW exporter
		namespace: 'MySpaceInVW';
		package: 'Pharo2VW-TestResources';
		export.
	self parseGeneratedXML.
	methodsContents := self xPathFor: '//methods/body'.
	doubleXML := methodsContents detect: [ :node | node nodes first beginsWith: 'methodWithDoubleXMLEscaping' ].
	self
		assert: doubleXML nodes first asString 
		equals: 'methodWithDoubleXMLEscaping
	^ 1 < 2 > 3'.
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportLan [
	Pharo2VW exporter
		namespace: 'MySpaceInVW';
		package: 'Moose-TestResources-LAN';
		export.
	self parseGeneratedXML.
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportOnlyClassesNotTraits [
	| inst classes traits allClasses xclasses |
	inst := Pharo2VWExamples new.
	inst exampleExportPackageBasic.
	classes := inst exampleExportPackageBasic classes.
	self parseGeneratedXML.
	xclasses := self xPathFor: '//class'.
	self assert: xclasses size equals: classes size.
	rootPath := '/st-source/class[1]/'.
	allClasses := (RPackageOrganizer default
		packageNamed: 'Moose-TestResources-LAN') classes.
	traits := allClasses select: [ :cls | cls isTrait ].
	self
		assert: xclasses size + traits size
		equals: allClasses size
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportPackageBasicClasses [
	| inst classes |
	inst := Pharo2VWExamples new.
	classes := (inst exampleExportPackageBasic) classes.
	self parseGeneratedXML.
	self
		assert: (self xPathFor: '//class') size
		equals: classes size.
	rootPath := '/st-source/class[1]/'.
	classes := Class superclassOrder: classes copy.
	self
		testValues:
			{('name' -> classes first name).
			('environment' -> 'MySpaceInVW').
			('private' -> 'false').
			('indexed-type' -> 'none').
			('inst-vars' -> classes first instanceVariablesString).
			('imports' -> '').
			('category' -> 'Moose-TestResources-LAN').
			('attributes/package' -> 'Moose-TestResources-LAN')} asDictionary
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportPackageBasicComment [
	| inst |
	inst := Pharo2VWExamples new.
	inst exampleExportPackageBasic.
	self parseGeneratedXML.
	rootPath := '/st-source/comment/'.
	self
		testValues:
			{('class-id' -> 'MySpaceInVW.LANInterface').
			('body'
				->
					('LAN Interface comments for testing purposes.

Instance Variables:
	addressee	&lt;ValueHolder&gt;	description of addressee
	contents	&lt;ValueHolder&gt;	description of contents
	deviceNameMenu	&lt;ValueModel&gt;	description of deviceNameMenu
	nextNode	&lt;ValueHolder&gt;	description of nextNode
	nodeList	&lt;SelectionInList&gt;	description of nodeList
	nodeName	&lt;ValueHolder&gt;	description of nodeName
	originator	&lt;ValueHolder&gt;	description of originator' replaceAll: Character cr with: Character lf))} asDictionary
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportPackageBasicMethods [
	| exporter a methods |
	exporter := Pharo2VWExamples new exampleExportPackageBasic.
	methods := exporter methods.
	self parseGeneratedXML.
	a := self xPathFor: '//methods'.
	self
		assert: a size
		equals: methods size.
	rootPath := '/st-source/methods[1]/'.
	self
		testValues:
			{('class-id' -> ('MySpaceInVW.', methods first realClass name)).
			('category' -> methods first category). } asDictionary
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportPackageBasicNamespace [
	| inst |
	inst := Pharo2VWExamples new.
	inst exampleExportPackageBasic.
	self parseGeneratedXML.
	rootPath := '/st-source/name-space/'.
	self
		testValues:
			{('name' -> 'MySpaceInVW').
			('environment' -> 'Smalltalk').
			('private' -> 'false').
			('imports' -> 'private Smalltalk.*')} asDictionary
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportPackageBasicSharedVariables [
	| inst |
	inst := Pharo2VWExamples new.
	inst exampleExportPackageBasic.
	self parseGeneratedXML.
	rootPath := '/st-source/shared-variable/'.
	self
		testValues:
			{('name' -> 'LANEditor').
			('environment' -> 'MySpaceInVW.LANPool').
			('private' -> 'false').
			('constant' -> 'false').
			('category' -> 'class variables').
			('initializer' -> 'nil').
			('attributes/package' -> 'Moose-TestResources-LAN')} asDictionary
]

{ #category : #tests }
Pharo2VWExporterTest >> testExportMethodsForUserofTraits [
	| exporter classes xclasses traits methods |
	exporter := Pharo2VW exporter.
	exporter 
		namespace: 'MySpaceInVW';
		package: 'Moose-TestResources-LAN';
		export.
	self parseGeneratedXML.
	classes := exporter classes.
	methods := self xPathFor: '//methods'.
	xclasses := self xPathFor: '//class'.
	self assert: classes size equals: xclasses size.
	traits := exporter traits.
	self deny: traits isEmpty.
	traits do: [ :trait |
		trait users do: [ :cls | | name mets |
			name := exporter fullyQualifiedClassNameFor: cls.
			mets := methods select: [ :m | (m // 'class-id') stringValue = name ].
			self assert: cls methods size equals: mets size.
			 ] ].
	
	
	
]

{ #category : #helpers }
Pharo2VWExporterTest >> testValues: aDict [
	aDict
		keysAndValuesDo: [ :key :value | self assert: (self xPathFor: key) stringValue trimBoth equals: value ]
]

{ #category : #helpers }
Pharo2VWExporterTest >> xPathFor: aString [
	^ XPath for: rootPath, aString in: parsedXML
]
