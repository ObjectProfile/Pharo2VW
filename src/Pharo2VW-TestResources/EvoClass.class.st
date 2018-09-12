Class {
	#name : #EvoClass,
	#superclass : #Object,
	#category : #'Pharo2VW-TestResources'
}

{ #category : #initialization }
EvoClass class >> initialize [
	data := 3.1416
]

{ #category : #accessing }
EvoClass >> data [
	^ data
]

{ #category : #accessing }
EvoClass >> methodWithCurlyBraces [
	 { #RGMetaclassDefinition . { 'Foo' asSymbol . self class name asSymbol } }
]

{ #category : #accessing }
EvoClass >> methodWithCurlyBracesEquivalent [
	((Array new: 2) 
		at: 1 put: (#RGMetaclassDefinition);
		at: 2 put: ((Array new: 2) at: 1 put: ('Foo' asSymbol) ; at: 2  put: (self class name asSymbol); yourself); yourself)
]

{ #category : #accessing }
EvoClass >> methodWithCurlyBracesEquivalentPrettyPrinted [
	(Array new: 2)
		at: 1 put: #RGMetaclassDefinition;
		at: 2
			put:
			((Array new: 2)
				at: 1 put: 'Foo' asSymbol;
				at: 2 put: self class name asSymbol;
				yourself);
		yourself
]
