"
This class serves as the entry point. It prepares the objects required for the entire process — those that should be created once and for all at the beginning.
"
Class {
	#name : 'PreliminarySteps',
	#superclass : 'Object',
	#instVars : [
		'businessClasses',
		'serviceClasses',
		'filteredServiceMethods',
		'filteredBusinessComments',
		'currentModel',
		'classRelationsGraph',
		'methodTypes'
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
PreliminarySteps >> classRelationsGraph [

	^classRelationsGraph
]

{ #category : 'accessing' }
PreliminarySteps >> classRelationsGraph: aCollection [

	classRelationsGraph := aCollection
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
	
	"Retrieve comments from service methods"
	serviceComments := filteredServiceMethods flatCollect: #comments.	

	"Select the comments located above the method"
	serviceComments := serviceComments select: [:com | 
		(com commentedEntity sourceAnchor startLine) > (com sourceAnchor startLine)
	].

	"Select the JavaDocs"
	serviceComments := serviceComments select: [ :com | com sourceText beginsWith: '/**' ].

	"Remove the TODOs"
	serviceComments := serviceComments reject: [ :com | com sourceText includesSubstring: 'todo' caseSensitive: false ].

	"Remove short comments (less than 20 characters)"
	serviceComments := (serviceComments reject: [ :com | com sourceText size < 20 ]).
	
	"Prendre un petit nombre des commentaires"
	serviceComments := serviceComments select: [ :com | com sourceText includesSubstring: 'OBLIGATOIRE' ].
	
	commentsCollection := OrderedCollection new.

	commentsCollection := serviceComments collect: [ :com |
   		((CommentCleaner new) comment: com) cleanComment.
	].

	"Remove empty comments after cleaning"
	commentsCollection := commentsCollection reject: [ :com | com commentSourceText isEmpty ].
	
	"Remove comments that are identical to the method names"
	commentsCollection := commentsCollection reject: [ :com | com commentSourceText isEmpty = com commentedEntity name ].

	"Select the tagged methods"
	filteredBusinessComments := commentsCollection select: [ :com | com commentedEntity isTagged ].
]

{ #category : 'filters' }
PreliminarySteps >> filterServiceMethods [
	
	| serviceMethods |
	
	serviceMethods := serviceClasses flatCollect: #methods.
	
	"Remove the constructors"
	serviceMethods := serviceMethods reject: [ :m | m isConstructor ].

	"Remove the getters"
	serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'get' ].

	"Remove the setters"
	serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'set' ].

	"Remove the initialization methods <Initializer>, initialiser*, initialisation*, initialise*"
	serviceMethods := serviceMethods reject: [ :m | (m name = '<Initializer>') or: [ m name beginsWith: 'initiali' ] ].

	"Remove the methods fournir fournit"
	serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'fou' ].

	"Remove the search methods"
	serviceMethods := serviceMethods reject: [ :m | (m name beginsWith: 'chercher') or: [ m name beginsWith: 'recherche' ] ].

	"Remove methods whose cyclomatic complexity is less than 4"
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
	currentModel := FamixJavaModel new.
]

{ #category : 'accessing' }
PreliminarySteps >> methodTypes [

	^methodTypes
]

{ #category : 'accessing' }
PreliminarySteps >> methodTypes: aCollection [

	methodTypes := aCollection
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

{ #category : 'starting' }
PreliminarySteps >> start: aModel [

	"This method represents the entry point"
	currentModel := aModel.
	self selectBusinessClasses.
	self selectServiceClasses.
	self filterServiceMethods.
	self filterServiceComments.
	classRelationsGraph := ((ClassRelationAnalyzer new) modelClasses: businessClasses) buildClassRelationGraph.
	methodTypes := ((MethodAnalyser new) serviceMethods: filteredServiceMethods) analyse.
]
