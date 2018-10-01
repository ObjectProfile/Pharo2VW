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
     at: 2 put: ((Array new: 2)
           at: 1 put: ''Foo'' asSymbol;
           at: 2 put: self class name asSymbol;
           yourself);
     yourself' replaceAll: Character cr with: Character lf)
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
	| inst a b |
	inst := Pharo2VWExamples new.
	inst exampleExportPackageBasic.
	self parseGeneratedXML.
	a := self xPathFor: '//methods'.
	b := (RPackageOrganizer default packageNamed: 'Moose-TestResources-LAN') classes
			flatCollect: [:cls | 
				cls methods, 
				(cls isTrait ifTrue: [ #() ] ifFalse: [ cls class methods ])
			] as: OrderedCollection.
	self
		assert: a size
		equals: b size.
	rootPath := '/st-source/methods[1]/'. 
	self
		testValues:
			{('class-id' -> 'MySpaceInVW.TLANInterface').
			('category' -> 'as yet unclassified').
			('body'
				->
					'originate
  | dialogModel dialogBuilder returnVal packet dialogOriginator dialogAddressee dialogContents |
  "the next three lines create ValueHolders to support the three dialog widgets"
  dialogOriginator := nil asValue.
  dialogAddressee := nil asValue.
  dialogContents := String new asValue.
  
  "next two lines create a new SimpleDialog object and retrieves the builder"dialogModel := Smalltalk at: #SimpleDialog new.
  dialogBuilder := dialogModel builder.
  
  "the following lines connect  the widgets of the interface with the ValueHolders created"dialogBuilder aspectAt: #originator put: dialogOriginator.
  dialogBuilder aspectAt: #addressee put: dialogAddressee.
  dialogBuilder aspectAt: #contents put: dialogContents.
  
  "the following lines ask the LANInterface for the originators and outputters menus.  
	You will write these next, so select proceed when VisualWorks when VisualWorks indicates that they are new messages."returnVal := dialogModel openFor: self interface: #originateDialog.
  
  "returnvalue will be true if the user selected Accept, otherwise it will be false"returnVal ifTrue: [ packet := LANPacket new
           addressee: (LANSingleDestinationAddress new id: dialogAddressee value name);
           contents: dialogContents value.
        dialogOriginator value originate: packet ]')} asDictionary
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

{ #category : #helpers }
Pharo2VWExporterTest >> testValues: aDict [
	aDict
		keysAndValuesDo: [ :key :value | self assert: (self xPathFor: key) stringValue equals: value ]
]

{ #category : #helpers }
Pharo2VWExporterTest >> xPathFor: aString [
	^ XPath for: rootPath, aString in: parsedXML
]
