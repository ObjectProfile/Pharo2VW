accessing
classes
	^ classes ifNil: [ classes := OrderedCollection new.
		self packagesTags do: [ :pkg | classes addAll: pkg classes ].
		classes ].