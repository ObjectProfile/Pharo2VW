examples
exampleExportRoassalWithoutSomeMethods
	"This creates a new files MySpaceInVW.st a file with all the sourcecode of the packages"
	Pharo2VW exporter
		directory: FileSystem disk workingDirectory;
		environment: 'MySpaceInVW';
		externalNamespaces: {'Roassal2'};
		methodsBlacklist: {Pharo2VWExamples >> #example02};
		package: 'Pharo2VW';
		export.