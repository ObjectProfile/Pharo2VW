examples
exampleExportRoassalDisplayMethodsWithArray
	"This creates a new files MySpaceInVW.st a file with all the sourcecode of the packages"
	Pharo2VW exporter
		environment: 'MySpaceInVW';
		externalNamespaces: {'Roassal2'};
		methodsBlacklist: {Pharo2VWExamples >> #example03. Pharo2VWExamples >> #example02};
		package: 'Pharo2VW';
		showMethodsWithArray: true;
		"checkForArrays;" "For test all ok but not with hapao"
		export.