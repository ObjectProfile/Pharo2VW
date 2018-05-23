Extension { #name : #TBehavior }

{ #category : #'*Pharo2VW-Core' }
TBehavior >> visualworksName [
	^ (#('WA' 'SU' 'CT') includes: (self name copyFrom: 1 to: 2))
		ifTrue: ['Seaside.', self name]
		ifFalse: [self name]
]
