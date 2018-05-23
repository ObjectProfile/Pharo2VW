examples
exampleExportPacakgeBasic
	"This creates a new files MySpaceInVW.st a file with all the sourcecode of the packages"
	Pharo2VW exporter
		environment: 'MySpaceInVW';
		package: 'Pharo2VW';
		export.