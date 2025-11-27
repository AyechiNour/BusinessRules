Class {
	#name : 'PreliminarySteps',
	#superclass : 'Object',
	#instVars : [
		'businessClasses',
		'serviceClasses',
		'filteredServiceMethods',
		'filteredBusinessComments',
		'currentModel'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'accessing' }
PreliminarySteps >> businessClasses [

	^businessClasses
]

{ #category : 'accessing' }
PreliminarySteps >> businessClasses: classesCollection [

	businessClasses := classesCollection
]

{ #category : 'accessing' }
PreliminarySteps >> currentModel [

	^ currentModel
]

{ #category : 'accessing' }
PreliminarySteps >> currentModel: aModel [

	currentModel := aModel
]

{ #category : 'accessing' }
PreliminarySteps >> filteredBusinessComments [

	^filteredBusinessComments
]

{ #category : 'accessing' }
PreliminarySteps >> filteredBusinessComments: classesCollection [

	filteredBusinessComments := classesCollection
]

{ #category : 'accessing' }
PreliminarySteps >> filteredServiceMethods [

	^filteredServiceMethods
]

{ #category : 'accessing' }
PreliminarySteps >> filteredServiceMethods: classesCollection [

	filteredServiceMethods := classesCollection
]

{ #category : 'initialization' }
PreliminarySteps >> initialize [

	super initialize.
	businessClasses := OrderedCollection new.
	serviceClasses := OrderedCollection new.
	filteredServiceMethods := OrderedCollection new.
	filteredBusinessComments := OrderedCollection new.
	currentModel := nil.
]

{ #category : 'filters' }
PreliminarySteps >> selectBusinessClasses [

	businessClasses := currentModel allModelClasses select: [ :c | 
		(c superclassHierarchy anySatisfy: [ :class | class name = 'EntitePersistanteAbstract' ]) and: [ 
			c methods anySatisfy: [ :m | 
				(m name includesSubstring: 'mapperOR' caseSensitive: false ) and: [ m numberOfStatements > 0 ] ] 
					]   
        		].
]

{ #category : 'filters' }
PreliminarySteps >> selectServiceClasses [
	
	serviceClasses := currentModel allModelClasses select: [ :c | c superclassHierarchy anySatisfy: [ :class | class name = 'ServiceAbstract' ] ]
]

{ #category : 'accessing' }
PreliminarySteps >> serviceClasses [

	^serviceClasses
]

{ #category : 'accessing' }
PreliminarySteps >> serviceClasses: classesCollection [

	serviceClasses := classesCollection
]
