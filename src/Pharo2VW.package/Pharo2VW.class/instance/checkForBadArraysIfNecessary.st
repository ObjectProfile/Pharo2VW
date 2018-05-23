testing
checkForBadArraysIfNecessary
	| list  |
	self shouldCheckForArrays ifFalse: [ ^ self ].
	list := OrderedCollection new.
	self methods do: [ :met | 
		(self methodsBlacklist includes: met) ifFalse: [  
			(self hasArray: met) ifTrue: [ list add: met ] ] ]
		displayingProgress: 'Checking methods'.
	list isEmpty ifTrue: [ ^ self ]. 
	self showMethodsWithArray 
		ifTrue: [ list do: [ :met | met browse ]. self error: 'Please check this methods!' ]
		ifFalse: [ self error: 'You have: ', list size asString, ' methods with {} please check' ].