Extension { #name : #TestCase }

{ #category : #'*Pharo2VW-Core' }
TestCase class >> visualworksName [
	^ self == TestCase ifTrue: ['Smalltalk.SUnit.TestCase'] ifFalse: [self name]
]
