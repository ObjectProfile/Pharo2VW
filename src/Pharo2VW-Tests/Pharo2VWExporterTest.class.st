"
A Pharo2VWExporterTest is a test class for testing the behavior of Pharo2VWExporter
"
Class {
	#name : #Pharo2VWExporterTest,
	#superclass : #TestCase,
	#instVars : [
		'parsedXML',
		'rootPath'
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
Pharo2VWExporterTest >> testBasicExport [
	| inst |
	inst := Pharo2VW exporter.
	self
		assert: inst externalNamespaces class equals: Array;
		assert: inst externalNamespaces isEmpty;
		assert: inst directory equals: FileSystem disk workingDirectory;
		assert: inst environment isNil.
	
]

{ #category : #tests }
Pharo2VWExporterTest >> testCurlyBracesConversion [
	| methodsContents curlyBraced |
	Pharo2VW exporter
		environment: 'MySpaceInVW';
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
     at: 2 put: ((Array new: 2)
           at: 1 put: ''Foo'' asSymbol;
           at: 2 put: self class name asSymbol;
           yourself);
     yourself' replaceAll: Character cr with: Character lf)
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportLan [
	Pharo2VW exporter
		environment: 'MySpaceInVW';
		package: 'Moose-TestResources-LAN';
		export.
	self parseGeneratedXML.
	self assert: false
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportPackageBasicClasses [
	| inst |
	inst := Pharo2VWExamples new.
	inst exampleExportPackageBasic.
	self parseGeneratedXML.
	self
		assert: (self xPathFor: '//class') size
		equals:
			((RPackageOrganizer default packageNamed: 'Moose-TestResources-LAN') classes select: #isClass)
				size.
	rootPath := '/st-source/class[1]/'.
	self
		testValues:
			{('name' -> 'LANPool').
			('environment' -> 'MySpaceInVW').
			('super' -> 'SharedPool').
			('private' -> 'false').
			('indexed-type' -> 'none').
			('inst-vars' -> '').
			('class-inst-vars' -> '').
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
	originator	&lt;ValueHolder&gt;	description of originator

' replaceAll: Character cr with: Character lf))} asDictionary
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportPackageBasicMethods [
	| inst |
	inst := Pharo2VWExamples new.
	inst exampleExportPackageBasic.
	self parseGeneratedXML.
	self
		assert: (self xPathFor: '//methods') size
		equals:
			((RPackageOrganizer default packageNamed: 'Moose-TestResources-LAN') classes
				select: #isClass
				thenCollect: #methods) flatten size.
	rootPath := '/st-source/methods[1]/'.
	self
		testValues:
			{('class-id' -> 'MySpaceInVW.LANAbstractDestinationAddress').
			('category' -> 'comparing').
			('body'
				->
					'isDestinationFor: aNodeAddress 
	 
	^self subclassResponsibility')} asDictionary
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
Pharo2VWExporterTest >> testExampleExportRoassalDisplayMethodsWithArray [
	| inst |
	self skip.
	inst := Pharo2VWExamples new.
	inst exampleExportRoassalDisplayMethodsWithArray.
	self assert: false
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportRoassalWithoutSomeMethods [
	| inst |
	self skip.
	inst := Pharo2VWExamples new.
	inst exampleExportRoassalWithoutSomeMethods.
	self assert: false
]

{ #category : #helpers }
Pharo2VWExporterTest >> testValues: aDict [
	aDict
		keysAndValuesDo: [ :key :value | self assert: (self xPathFor: key) stringValue equals: value ]
]

{ #category : #helpers }
Pharo2VWExporterTest >> xPathFor: aString [
	^ XPath for: rootPath, aString in: parsedXML
]
