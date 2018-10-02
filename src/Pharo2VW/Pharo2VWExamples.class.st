"
I have examples of how to use the Pharo2VWExporter
"
Class {
	#name : #Pharo2VWExamples,
	#superclass : #Object,
	#category : 'Pharo2VW-Examples'
}

{ #category : #examples }
Pharo2VWExamples >> exampleExportPackageBasic [
	"This creates a new files MySpaceInVW.st a file with all the sourcecode of the packages"
	^ Pharo2VW exporter
		namespace: 'MySpaceInVW';
		package: 'Moose-TestResources-LAN';
		classNameMapperDo: [ :m | 
			m at: TLANInterface put: 'LANPool' ];
		export;
		yourself
	
]

{ #category : #examples }
Pharo2VWExamples >> exampleExportRoassalWithoutSomeMethods [
	<script: 'self new exampleExportRoassalWithoutSomeMethods'>
	"This creates a new files MySpaceInVW.st a file with all the sourcecode of the packages"
	Pharo2VW exporter
		directory: FileSystem disk workingDirectory;
		environment: 'MySpaceInVW';
		externalNamespaces: {'Roassal2'};
		methodsBlacklist: {Pharo2VWExamples >> #exampleExportRoassalWithoutSomeMethods};
		package: 'Pharo2VW';
		export.
]
