tests
testExampleExportPacakgeBasic
	| inst |
	inst := Pharo2VWExamples new.
	inst exampleExportPacakgeBasic.
	self assert: false