"
I am a mapper between the Pharo class names and the VW ones
"
Class {
	#name : #Pharo2VWClassNameMapper,
	#superclass : #Object,
	#instVars : [
		'classNameMapping'
	],
	#category : #'Pharo2VW-Core'
}

{ #category : #accessing }
Pharo2VWClassNameMapper >> at: class put: association [
	self classNameMapping at: class put: association
]

{ #category : #accessing }
Pharo2VWClassNameMapper >> at: class putName: string namespace: namespace [
	self classNameMapping at: class put: namespace -> string
]

{ #category : #accessing }
Pharo2VWClassNameMapper >> at: class putNamespace: namespace [
	self classNameMapping at: class put: namespace -> class name
]

{ #category : #accessing }
Pharo2VWClassNameMapper >> classNameMapping [
	^ classNameMapping ifNil: [ classNameMapping := 
		{TestCase -> ('Smalltalk.SUnit'->'TestCase').
		Object -> ('Core'->'Object').
		TBehavior -> ('Core'->'Behavior').
		Color -> ('Core'->'ColorValue').
		RBProgramNodeVisitor -> ('Refactory.Browser' -> 'RBProgramNodeVisitor').
		} asDictionary]
]

{ #category : #'double dispatch' }
Pharo2VWClassNameMapper >> fullNameForClass: class [
	^ self classNameMapping at: class 
		ifPresent: [ :a | a key,'.',a value ]
		ifAbsent: [ class name ]
]

{ #category : #'double dispatch' }
Pharo2VWClassNameMapper >> nameForClass: class [
	^ self classNameMapping at: class 
		ifPresent: [ :a | a value ]
		ifAbsent: [ class name ]
]

{ #category : #'instance creation' }
Pharo2VWClassNameMapper >> on: aClass [ 
	^ self nameForClass: aClass
]
