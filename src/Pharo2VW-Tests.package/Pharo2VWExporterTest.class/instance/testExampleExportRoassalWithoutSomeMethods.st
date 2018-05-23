tests
testExampleExportRoassalWithoutSomeMethods
	| inst |
	inst := Pharo2VWExamples new.
	inst exampleExportRoassalWithoutSomeMethods.
	self assert: false