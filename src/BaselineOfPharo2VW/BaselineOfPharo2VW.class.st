Class {
	#name : #BaselineOfPharo2VW,
	#superclass : #BaselineOf,
	#category : #BaselineOfPharo2VW
}

{ #category : #baselines }
BaselineOfPharo2VW >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				package: #Pharo2VW with: [ spec requires: #('XMLWriter' 'Pharo2VW') ];
				package: #'Pharo2VW-Tests' with: [ spec requires: #('FAMIX' 'Pharo2VW') ];
				project: 'FAMIX'
					with: [ spec repository: 'http://smalltalkhub.com/mc/Moose/Moose/main'.
					spec loads: #('Resources') ];
				project: 'XMLWriter'
					with: [ spec repository: 'http://smalltalkhub.com/mc/PharoExtras/XMLWriter/main' ].
			spec
				group: 'default' with: #('core' 'tests');
				group: 'core' with: #('Pharo2VW');
				group: 'tests' with: #('Pharo2VW-Tests') ]
]
