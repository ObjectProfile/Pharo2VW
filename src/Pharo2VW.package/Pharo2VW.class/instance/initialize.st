initialization
initialize
	super initialize.
	directory := FileSystem disk workingDirectory.
	environment := nil.
	externalNamespaces := #().
	checkForArrays := showMethodsWithArray := false