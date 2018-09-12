"
I am a mapper between the Pharo class names and the VW ones
"
Class {
	#name : #Pharo2VWClassNameMapper,
	#superclass : #Object,
	#category : #'Pharo2VW-Core'
}

{ #category : #accessing }
Pharo2VWClassNameMapper >> classNameMapping [
	^ {TestCase -> 'Smalltalk.SUnit.TestCase'.
	Object -> 'Core.Object'.
	TBehavior -> 'Core.Behavior' .
	Color -> 'ColorValue'
	} asDictionary
]

{ #category : #testing }
Pharo2VWClassNameMapper >> isSeasideClass: aClass [
	^ (#('WA' 'SU' 'CT') includes: (aClass name copyFrom: 1 to: 2))
]

{ #category : #'double dispatch' }
Pharo2VWClassNameMapper >> nameForBehaviorClass: class [
	^ (self isSeasideClass: class)
		ifTrue: [ self nameForSeaside: class ]
		ifFalse: [ class name ]
]

{ #category : #'double dispatch' }
Pharo2VWClassNameMapper >> nameForClass: class [
	^ self classNameMapping at: class ifAbsent: [ class name ]
]

{ #category : #'double dispatch' }
Pharo2VWClassNameMapper >> nameForObjectClass: class [
	(self isSeasideClass: class)
		ifTrue: [ ^ self nameForSeaside: class ].
	^ self nameForClass: class
]

{ #category : #'double dispatch' }
Pharo2VWClassNameMapper >> nameForSeaside: aClass [
	^ 'Seaside.' , aClass name
]

{ #category : #'instance creation' }
Pharo2VWClassNameMapper >> on: aClass [ 
	^ aClass visualworksNameOn: self
]
