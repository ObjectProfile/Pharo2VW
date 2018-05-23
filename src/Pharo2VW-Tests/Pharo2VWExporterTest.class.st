"
A Pharo2VWExporterTest is a test class for testing the behavior of Pharo2VWExporter
"
Class {
	#name : #Pharo2VWExporterTest,
	#superclass : #TestCase,
	#category : 'Pharo2VW-Tests'
}

{ #category : #running }
Pharo2VWExporterTest >> exportedFile [
	^ 'MySpaceInVW.st' asFileReference
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
Pharo2VWExporterTest >> testExampleExportPackageBasic [
	| inst parsedXML |
	inst := Pharo2VWExamples new.
	inst exampleExportPackageBasic.
	self shouldnt: [ parsedXML := XMLDOMParser parse: self exportedFile contents ] raise: XMLException.
	self
		assert: (XPath for: '//class' in: parsedXML) size
		equals: ((RPackageOrganizer default packageNamed: 'Moose-TestResources-LAN') classes select: #isClass) size
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportRoassalDisplayMethodsWithArray [
	| inst |
	inst := Pharo2VWExamples new.
	inst exampleExportRoassalDisplayMethodsWithArray.
	self assert: false
]

{ #category : #tests }
Pharo2VWExporterTest >> testExampleExportRoassalWithoutSomeMethods [
	| inst |
	inst := Pharo2VWExamples new.
	inst exampleExportRoassalWithoutSomeMethods.
	self assert: false
]
