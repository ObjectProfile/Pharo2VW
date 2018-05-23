"
I have examples of how to use the Pharo2VWExporter
"
Class {
	#name : #Pharo2VWExamples,
	#superclass : #Object,
	#category : 'Pharo2VW-Examples'
}

{ #category : #examples }
Pharo2VWExamples >> exampleExportPacakgeBasic [
	"This creates a new files MySpaceInVW.st a file with all the sourcecode of the packages"
	Pharo2VW exporter
		environment: 'MySpaceInVW';
		package: 'Pharo2VW';
		export.
]

{ #category : #examples }
Pharo2VWExamples >> exampleExportRoassalDisplayMethodsWithArray [
	"This creates a new files MySpaceInVW.st a file with all the sourcecode of the packages"
	Pharo2VW exporter
		environment: 'MySpaceInVW';
		externalNamespaces: {'Roassal2'};
		methodsBlacklist: {Pharo2VWExamples >> #example03. Pharo2VWExamples >> #example02};
		package: 'Pharo2VW';
		showMethodsWithArray: true;
		"checkForArrays;" "For test all ok but not with hapao"
		export.
]

{ #category : #examples }
Pharo2VWExamples >> exampleExportRoassalWithoutSomeMethods [
	"This creates a new files MySpaceInVW.st a file with all the sourcecode of the packages"
	Pharo2VW exporter
		directory: FileSystem disk workingDirectory;
		environment: 'MySpaceInVW';
		externalNamespaces: {'Roassal2'};
		methodsBlacklist: {Pharo2VWExamples >> #example02};
		package: 'Pharo2VW';
		export.
]
