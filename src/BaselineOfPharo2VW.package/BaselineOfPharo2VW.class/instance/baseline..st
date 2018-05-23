baselines
baseline: spec
	<baseline>
	spec
		for: #common
		do: [ spec
				package: #Pharo2VW;
				package: #'Pharo2VW-Tests' with: [ spec requires: #('Pharo2VW') ].
			spec
				group: 'default' with: #('core' 'tests');
				group: 'core' with: #('Pharo2VW');
				group: 'tests' with: #('Pharo2VW-Tests').
			spec
				configuration: 'FAMIX'
				with: [ spec
						repository: 'http://smalltalkhub.com/mc/Moose/Moose/main/';
						loads: #('Resources') ] ]