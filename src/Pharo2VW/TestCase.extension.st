Extension { #name : #TestCase }

{ #category : #'*Pharo2VW-Core' }
TestCase class >> visualworksNameOn: mapper [
	^ mapper nameForClass: self
]
