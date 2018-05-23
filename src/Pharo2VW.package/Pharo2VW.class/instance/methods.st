accessing
methods
	^ methods ifNil: [ 
		methods := OrderedCollection new.
		self packagesTags do: [ :pkg | 
			methods addAll: (pkg package extensionsForTag: pkg).
			pkg classes do: [ :cls | 
				methods addAll: cls class methods.
				methods addAll: cls methods ] ].
		methods ].