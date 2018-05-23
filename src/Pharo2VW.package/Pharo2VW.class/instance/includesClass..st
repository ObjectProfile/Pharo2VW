testing
includesClass: class
	| c |
	c := class isMeta ifTrue: [ class soleInstance ] ifFalse: [ class ].
	self packagesTags do: [ :pkg | (pkg includesClass: c) ifTrue: [ ^ true. ] ].
	^ false.