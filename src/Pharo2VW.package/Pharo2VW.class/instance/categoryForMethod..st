export helpers
categoryForMethod: method
	^ method category ifNil: [ 'as yet unclassified' ]