"
I am a simple dummy class
"
Class {
	#name : #EvoClass,
	#superclass : #Object,
	#classVars : [
		'data'
	],
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
