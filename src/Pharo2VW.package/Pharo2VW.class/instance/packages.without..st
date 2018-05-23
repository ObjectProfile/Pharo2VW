public
packages: packages without: packageTags
	| tags |
	tags := packages flatCollect: [ :n | | pkg |
		pkg := RPackageOrganizer default packageNamed: n.
		pkg classTags ].
	
	self packagesTags: (tags reject: [ :e | packageTags includes: e packageName,'-', e name ] )