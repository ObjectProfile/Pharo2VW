Extension { #name : #TClass }

{ #category : #'*Pharo2VW-Core' }
TClass >> visualworksName [
	^ self == TBehavior 
		ifTrue: [ 'Core.Behavior' ]
		ifFalse: [ self name ]
]
