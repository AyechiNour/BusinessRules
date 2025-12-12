"
This method extracts the types for a method and the methods it calls.
"
Class {
	#name : 'MethodAnalyser',
	#superclass : 'Object',
	#instVars : [
		'serviceMethods',
		'methodsTypes'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'starting' }
MethodAnalyser >> analyse [

	serviceMethods do: [ :m |
        methodsTypes at: m put: (self analyzeStartingFrom: m).
    ].
]

{ #category : 'as yet unclassified' }
MethodAnalyser >> analyzeStartingFrom: aMethod [

    | extractor visited stack aggregatedTypes |
    
    extractor := MethodTypeCollector new.
    visited := IdentitySet new.
    stack := OrderedCollection new.
    aggregatedTypes := OrderedCollection new.

    stack add: aMethod.

    [ stack isEmpty not ] whileTrue: [
        | currentMethod |
        currentMethod := stack removeLast.

        (visited includes: currentMethod) ifFalse: [
	
            visited add: currentMethod.
				extractor method: currentMethod.
            aggregatedTypes addAll: ((extractor startTypeNamesExtraction) typesNames).

            (self calledMethodsOf: currentMethod) do: [ :called |
                (visited includes: called) ifFalse: [
                    stack add: called
                ]
            ]
        ]
    ].

    ^ aggregatedTypes asSet
]

{ #category : 'as yet unclassified' }
MethodAnalyser >> calledMethodsOf: aMethod [

    ^ aMethod outgoingInvocations
        flatCollect: [ :inv | inv candidates ]
]

{ #category : 'initialization' }
MethodAnalyser >> initialize [

	super initialize.
	methodsTypes := Dictionary new.
]

{ #category : 'accessing' }
MethodAnalyser >> methodsTypes [

	^methodsTypes
]

{ #category : 'accessing' }
MethodAnalyser >> methodsTypes: aDictionary [

	methodsTypes := aDictionary.
]

{ #category : 'accessing' }
MethodAnalyser >> serviceMethods [

	^serviceMethods
]

{ #category : 'accessing' }
MethodAnalyser >> serviceMethods: aCollection [

	serviceMethods := aCollection
]
