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

{ #category : 'filters' }
PreliminarySteps >> filterServiceComments [

	| serviceComments commentsCollection |
	
	"Récupérer commentaires des méthodes service"
	serviceComments := filteredServiceMethods flatCollect: #comments.	

	"Choisir les commentaires qui se trouvent au dessus de la methode"
	serviceComments := serviceComments select: [:com | 
		(com commentedEntity sourceAnchor startLine) > (com sourceAnchor startLine)
	].

	"Choisir les javaDoc"
	serviceComments := serviceComments select: [ :com | com sourceText beginsWith: '/**' ].

	"Eliminer les TODO"
	serviceComments := serviceComments reject: [ :com | com sourceText includesSubstring: 'todo' caseSensitive: false ].

	"Eliminer les commentaires courts ( moins de 20 caractères )"
	serviceComments := (serviceComments reject: [ :com | com sourceText size < 20 ]).
	
	commentsCollection := OrderedCollection new.

	commentsCollection := serviceComments collect: [ :com |
   		((CommentCleaner new) comment: com) cleanComment.
	].

	"Eliminer les commentaires vides apres le cleaning"
	commentsCollection := commentsCollection reject: [ :com | com commentSourceText isEmpty ].
	
	"Eliminer les commentaires egaux au noms des méthodes"
	commentsCollection := commentsCollection reject: [ :com | com commentSourceText isEmpty = com commentedEntity name ].

	"Choisir les méthodes tagées"
	filteredBusinessComments := commentsCollection select: [ :com | com commentedEntity isTagged ].
]

{ #category : 'filters' }
PreliminarySteps >> filterServiceMethods [
	
	| serviceMethods |
	
	serviceMethods := serviceClasses flatCollect: #methods.
	
	"Eliminer les constructeurs"
	serviceMethods := serviceMethods reject: [ :m | m isConstructor ].

	"Eliminer les getters"
	serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'get' ].

	"Eliminer les setters"
	serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'set' ].

	"Eliminer les méthodes d'initialisation <Initializer> initialiser* initialisation* initialise*"
	serviceMethods := serviceMethods reject: [ :m | (m name = '<Initializer>') or: [ m name beginsWith: 'initiali' ] ].

	"Eliminer les méthodes fournir fournit fournier"
	serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'fou' ].

	"Eliminer les méthodes de recherche chercher et rechercher"
	serviceMethods := serviceMethods reject: [ :m | (m name beginsWith: 'chercher') or: [ m name beginsWith: 'recherche' ] ].

	"Eliminer les méthodes dont la complexité cyclomatique est inferieur à 4"
	serviceMethods := serviceMethods reject: [ :m | m cyclomaticComplexity < 4 ].
	
	filteredServiceMethods := serviceMethods.
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

{ #category : 'initialization' }
PreliminarySteps >> start: aModel [

	"Cette méthode représente le point d'entrée"
	|classRelationsGraph methodTypes|
	
	currentModel := aModel.
	self selectBusinessClasses.
	self selectServiceClasses.
	self filterServiceMethods.
	self filterServiceComments.
	classRelationsGraph := ((ClassRelationAnalyzer new) modelClasses: businessClasses) buildClassRelationGraph.
	methodTypes := ((MethodAnalyser new) serviceMethods: filteredServiceMethods) analyse.
	methodTypes inspect.
]
