*Pharo2VW-Core
visualworksName
	^ self == TBehavior 
		ifTrue: [ 'Core.Behavior' ]
		ifFalse: [ self name ]