"
I am a simple dummy class
"
Class {
	#name : #EvoClass,
	#superclass : #Object,
	#classVars : [
		'data'
	],
	#category : 'Pharo2VW-Tests'
}

{ #category : #initialization }
EvoClass class >> initialize [
	data := 3.1416
]

{ #category : #accessing }
EvoClass >> data [
	^ data
]
