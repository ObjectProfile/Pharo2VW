public
export
	| filename |
	self checkForBadArraysIfNecessary.
	filename := self directory / (self environment , '.st').
	filename exists
		ifTrue: [ filename delete ].
	stream := filename writeStream.
	[ stream
		nextPutAll: '<?xml version="1.0"?>';
		cr;
		cr.
	self
		tag: 'st-source'
		do: [ self fileOutTimeStamp.
			self fileOutNameSpace.
			self fileOutClassDefinitions.
			self fileOutMethods.
			self fileOutInitializers ] ]
		ensure: [ stream close ]