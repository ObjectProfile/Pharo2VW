export
packageNameForMethod: aMethodReference
	^ (self includesClass: aMethodReference realClass)
		ifTrue: [self packageNameForClass: aMethodReference realClass]
		ifFalse: [ self environment,'-Extensions']