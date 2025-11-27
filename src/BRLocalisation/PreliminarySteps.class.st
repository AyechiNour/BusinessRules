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

{ #category : 'helper methods' }
PreliminarySteps >> cleanAngleBrackets: aString [

	 "Cette méthode supprime les mots entre < >"

    | cleanedString stack i char startIndex |

	 cleanedString := aString.
    stack := OrderedCollection new.
    i := 1.
    [i <= cleanedString size] whileTrue: [
			char := cleanedString at: i.
         (char asciiValue = 60) ifTrue: [stack add: i].
         (char asciiValue = 62) ifTrue: [
				(stack isEmpty) ifFalse: [
					startIndex := stack removeLast.
             	"Supprime de la dernière ouvrante jusqu'au '>' inclus"
             	cleanedString := (cleanedString copyFrom: 1 to: startIndex - 1), (cleanedString copyFrom: i + 1 to: cleanedString size).
             	"On ajuste i pour continuer correctement après suppression"
             	i := startIndex - 1.
				].
			].
         i := i + 1.
	 ].

    ^cleanedString

]

{ #category : 'helper methods' }
PreliminarySteps >> cleanComment: aComment [

	 | sourceText indexParam nettoye indexReturn indexThrow indexHash indexLiteral indexAlgo lines oneLine dict|
    
	 "Récupérer le contenu du commenatire"
    sourceText := aComment sourceText.

	 "Supprimer les paramètres explicitement mentionnés"
    indexParam := sourceText indexOfSubCollection: '@param'.
    nettoye := (indexParam > 1)
       ifTrue: [ (sourceText copyFrom: 1 to: indexParam - 1), String cr ]
       ifFalse: [ sourceText ].

	 "Supprimer le type de retour explicitement mentionné"
	 indexReturn := nettoye indexOfSubCollection: '@return'.
	 nettoye := (indexReturn > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexReturn - 1), String cr ]
       ifFalse: [ nettoye ].

	 "Supprimer les exceptions explicitement mentionnées dans les commentaires"
	 indexThrow := nettoye indexOfSubCollection: '@throws'.
	 nettoye := (indexThrow > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexThrow - 1), String cr ]
       ifFalse: [ nettoye ].

	 "Supprimer les sections de code décrites dans les commentaires"
	 indexAlgo := nettoye indexOfSubCollection: 'Algo'.
	 nettoye := (indexAlgo > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexAlgo - 1), String cr ]
       ifFalse: [ nettoye ].
	
	 indexAlgo := nettoye indexOfSubCollection: 'algo'.
	 nettoye := (indexAlgo > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexAlgo - 1), String cr ]
       ifFalse: [ nettoye ].

	 indexHash := nettoye indexOfSubCollection: '#'.
	 nettoye := (indexHash > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexHash - 1), String cr ]
       ifFalse: [ nettoye ].

	 indexLiteral := nettoye indexOfSubCollection: '$'.
	 nettoye := (indexLiteral > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexLiteral - 1), String cr ]
       ifFalse: [ nettoye ].

	 "Supprimer les mots entre < >"
	 nettoye := self cleanAngleBrackets: nettoye.
	
	 "Enlever quelques annotations"
	 nettoye := nettoye copyReplaceAll: '@link' with: ''.
    nettoye := nettoye copyReplaceAll: '@type' with: ''.
    nettoye := nettoye copyReplaceAll: '@Type' with: ''.
	
	 "Enlever quelques caractères"
	 nettoye := nettoye copyReplaceAll: '/' with: ' '.
    nettoye := nettoye copyReplaceAll: '\' with: ' '.
	 nettoye := nettoye copyReplaceAll: '*' with: ' '.
	 nettoye := nettoye copyReplaceAll: '[' with: ' '.
	 nettoye := nettoye copyReplaceAll: ']' with: ' '.
	 nettoye := nettoye copyReplaceAll: '{' with: ' '.
	 nettoye := nettoye copyReplaceAll: '}' with: ' '.
    nettoye := nettoye copyReplaceAll: '-' with: ' '.
    nettoye := nettoye copyReplaceAll: '!' with: ' '.	 
    nettoye := nettoye copyReplaceAll: '""' with: ' '.
    nettoye := nettoye copyReplaceAll: '«' with: ' '.	 	 
    nettoye := nettoye copyReplaceAll: '»' with: ' '.	
	 nettoye := nettoye copyReplaceAll: '@' with: ' '.
	 nettoye := nettoye copyReplaceAll: 'ï¿½' with: ' '.
	 nettoye := nettoye copyReplaceAll: '(' with: ' '.
    nettoye := nettoye copyReplaceAll: ')' with: ' '.
	 nettoye := nettoye copyReplaceAll: ':' with: ' '.
	  
    "Découper le commentaire en lignes"
	 lines := nettoye lines.
			
	 "Créer une seule ligne"
	 oneLine := String streamContents: [:stream |
    	 lines do: [:line |
        	 stream
             nextPutAll: line trimBoth;
            	 nextPutAll: ' '
    	]].

	 dict := (Dictionary new
					at: 'comment' put: aComment;
					at: 'modifiedComment' put: oneLine trimBoth;
      	 			yourself).
				
	 ^dict

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
