tests
test01Examples
	| inst |
	inst := Pharo2VWExamples new.
	Pharo2VWExamples methods do: [ :met | inst perform: met selector ].