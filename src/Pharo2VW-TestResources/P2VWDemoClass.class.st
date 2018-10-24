"
I am just a resource for test propouses
"
Class {
	#name : #P2VWDemoClass,
	#superclass : #Object,
	#category : #'Pharo2VW-TestResources'
}

{ #category : #'as yet unclassified' }
P2VWDemoClass >> methodWithCurlyBraces [
	{ #RGMetaclassDefinition. { 'Foo' asSymbol. self class name asSymbol }  }
]

{ #category : #'as yet unclassified' }
P2VWDemoClass >> methodWithDoubleXMLEscaping [
	^ 1 < 2 > 3
]
