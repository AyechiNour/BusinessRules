"
This class collects the object types of the business classes used by each method
"
Class {
	#name : 'MethodTypeCollector',
	#superclass : 'Object',
	#instVars : [
		'method',
		'types',
		'typesNames'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'extraction' }
MethodTypeCollector >> extractNamesFromTypes [

	typesNames := types collect: [ :t | t name ]
]

{ #category : 'filtering' }
MethodTypeCollector >> filterTypes [

	types := types select: [ :t | 
					(t isNotNil) and: [
						(t isStub not) and: [
							(t superclassHierarchy anySatisfy: [ :c | c name = 'EntitePersistanteAbstract' ]) and: [ 
								t methods anySatisfy: [ :m | 
									(m name includesSubstring: 'mapperOR' caseSensitive: false ) and: [ 
										m numberOfStatements > 0 ]]]]]].	
]

{ #category : 'extraction' }
MethodTypeCollector >> getIntermediaryObjectTypes [

	| accessors |

	accessors := (method outgoingInvocations flatCollect: [ :oinv | 
		oinv candidates ]) select: [ :cand | cand isPureAccessor ].
	
	types addAll: (accessors collect: [ :meth | meth declaredType ]).
]

{ #category : 'extraction' }
MethodTypeCollector >> getLocalVariablesType [

	types addAll: ((method localVariables collect: [ :lv | lv declaredType ]) select: #notNil).

	
]

{ #category : 'extraction' }
MethodTypeCollector >> getParametersTypes [

	types addAll: ((method parameters collect: [ :p | p declaredType ]) select: #notNil).

	
]

{ #category : 'extraction' }
MethodTypeCollector >> getReturnType [

	types add: (method declaredType).

	
]

{ #category : 'extraction' }
MethodTypeCollector >> getTypes [

	self getParametersTypes.
	self getLocalVariablesType.
	self getReturnType.
	self getIntermediaryObjectTypes.
	self getTypesFromParametricEntity.
	self filterTypes.
]

{ #category : 'extraction' }
MethodTypeCollector >> getTypesFromParametricEntity [

	types := ((types collect: [ :type | 
		
		((type isNotNil) and: [ type isParametricEntity ])
			ifTrue: [ type concreteParameters ]
			ifFalse: [ type ]
		
		]) flatCollect: [ :each |
			
			(each isCollection) 
				ifTrue: [ each asArray ] 
				ifFalse: [ { each } ] 
		 ]) asSet
]

{ #category : 'initialization' }
MethodTypeCollector >> initialize [

	super initialize.
	method := nil.
	types := OrderedCollection new.
	typesNames := OrderedCollection new.
]

{ #category : 'accessing' }
MethodTypeCollector >> method [

	^method
]

{ #category : 'accessing' }
MethodTypeCollector >> method: aMethod [

	method := aMethod
]

{ #category : 'starting' }
MethodTypeCollector >> startTypeNamesExtraction [

	self getTypes.
	self extractNamesFromTypes.
]

{ #category : 'accessing' }
MethodTypeCollector >> types [

	^types
]

{ #category : 'accessing' }
MethodTypeCollector >> types: aCollection [

	types := aCollection
]

{ #category : 'accessing' }
MethodTypeCollector >> typesNames [

	^typesNames
]

{ #category : 'accessing' }
MethodTypeCollector >> typesNames: aCollection [

	typesNames := aCollection
]
