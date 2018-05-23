Extension { #name : #Object }

{ #category : #'*Pharo2VW-Core' }
Object class >> visualworksName [
	(#('WA' 'SU' 'CT') includes: (self name copyFrom: 1 to: 2))
		ifTrue: [^'Seaside.', self name].
	^ self == Object ifTrue: ['Core.Object'] ifFalse: [self name]
]
