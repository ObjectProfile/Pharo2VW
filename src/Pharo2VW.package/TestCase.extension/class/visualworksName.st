*Pharo2VW-Core
visualworksName
	^ self == TestCase ifTrue: ['Smalltalk.SUnit.TestCase'] ifFalse: [self name]