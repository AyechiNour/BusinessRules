|EssaiMethods EssaiMethods1 relationGraph essaiComments1 parentTypes filteredMethods filteredComments|

"Récupérer la racine du modèle Moose"
wegf := MooseModel root at: 1.

"Récupérer les méthodes des classes service"
serviceMethods := (wegf allModelClasses select: [ :c | c superclassHierarchy anySatisfy: [ :class | class name = 'ServiceAbstract' ] ]) flatCollect: #methods.

Transcript show: '1' ; cr.
Transcript show: serviceMethods size ; cr.

"Eliminer les constructeurs"
serviceMethods := serviceMethods reject: [ :m | m isConstructor ].

Transcript show: '2' ; cr.
Transcript show: serviceMethods size ; cr.

"Eliminer les getters"
serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'get' ].

Transcript show: '3' ; cr.
Transcript show: serviceMethods size ; cr.

"Eliminer les setters"
serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'set' ].

Transcript show: '4' ; cr.
Transcript show: serviceMethods size ; cr.

"Eliminer les méthodes d'initialisation <Initializer> initialiser* initialisation* initialise*"
serviceMethods := serviceMethods reject: [ :m | m name = '<Initializer>' ].

Transcript show: '5' ; cr.
Transcript show: serviceMethods size ; cr.

serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'initiali' ].

Transcript show: '6' ; cr.
Transcript show: serviceMethods size ; cr.

"Eliminer les méthodes fournir fournit fournier"
serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'fou' ].

Transcript show: '7' ; cr.
Transcript show: serviceMethods size ; cr.

"Eliminer les méthodes de recherche chercher et rechercher"
serviceMethods := serviceMethods reject: [ :m | (m name beginsWith: 'chercher') or: [ m name beginsWith: 'recherche' ] ].

Transcript show: '8' ; cr.
Transcript show: serviceMethods size ; cr.

"Eliminer les méthodes dont la complexité cyclomatique est inferieur à 4"
serviceMethods := serviceMethods reject: [ :m | m cyclomaticComplexity < 4 ].

Transcript show: '9' ; cr.
Transcript show: serviceMethods size ; cr.

"Récupérer commentaires des méthodes service"
serviceComments := serviceMethods flatCollect: #comments.

Transcript show: '10' ; cr.
Transcript show: serviceComments size ; cr.

"Choisir les commentaires qui se trouvent au dessus de la methode"
serviceComments := serviceComments select: [:com | 
		  (com commentedEntity sourceAnchor startLine) > (com sourceAnchor startLine)
].

Transcript show: '11' ; cr.
Transcript show: serviceComments size ; cr.

"Choisir les javaDoc"
serviceComments := serviceComments select: [ :com | com sourceText beginsWith: '/**' ].

Transcript show: '12' ; cr.
Transcript show: serviceComments size ; cr.

"Eliminer les TODO"
serviceComments := serviceComments reject: [ :com | com sourceText includesSubstring: 'todo' caseSensitive: false ].

Transcript show: '13' ; cr.
Transcript show: serviceComments size ; cr.

"Eliminer les commentaires courts ( moins de 20 caractères )"
serviceComments := (serviceComments reject: [ :com | com sourceText size < 20 ]).

Transcript show: '14' ; cr.
Transcript show: serviceComments size ; cr.

"Collection des dictionnaires méthode-commentaire"
collection := OrderedCollection new.

serviceComments := serviceComments collect: [:com | 
    | sourceText indexParam nettoye indexReturn indexBaliseOuvrante indexBaliseFermante indexThrow indexHash indexLiteral indexAlgo lines oneLine dict|
    
    sourceText := com sourceText.

    indexParam := sourceText indexOfSubCollection: '@param'.
    
    nettoye := (indexParam > 1)
       ifTrue: [ (sourceText copyFrom: 1 to: indexParam - 1), String cr ]
       ifFalse: [ sourceText ].

	 indexReturn := nettoye indexOfSubCollection: '@return'.
	
	 nettoye := (indexReturn > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexReturn - 1), String cr ]
       ifFalse: [ nettoye ].

	 indexBaliseOuvrante := nettoye indexOfSubCollection: '<'.
	
	 indexBaliseFermante := nettoye indexOfSubCollection: '>'.
	
	 (indexBaliseFermante > 1)
	    ifTrue: [ 
			nettoye := (indexBaliseOuvrante > 1)
       		ifTrue: [ (nettoye copyFrom: 1 to: indexBaliseOuvrante - 1), String cr ]
       		ifFalse: [ nettoye ]. 
	 	 ].
       
	 indexThrow := nettoye indexOfSubCollection: '@throws'.
	 nettoye := (indexThrow > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexThrow - 1), String cr ]
       ifFalse: [ nettoye ].

    indexHash := nettoye indexOfSubCollection: '#'.
	 nettoye := (indexHash > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexHash - 1), String cr ]
       ifFalse: [ nettoye ].

	 indexLiteral := nettoye indexOfSubCollection: '$'.
	 nettoye := (indexLiteral > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexLiteral - 1), String cr ]
       ifFalse: [ nettoye ].

	 indexAlgo := nettoye indexOfSubCollection: 'Algo'.
	 nettoye := (indexAlgo > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexAlgo - 1), String cr ]
       ifFalse: [ nettoye ].

	 nettoye := nettoye copyReplaceAll: '@link' with: ''.
    nettoye := nettoye copyReplaceAll: '@type' with: ''.
    nettoye := nettoye copyReplaceAll: '@Type' with: ''.
	 nettoye := nettoye copyReplaceAll: '/' with: ''.
    nettoye := nettoye copyReplaceAll: '\' with: ''.
	 nettoye := nettoye copyReplaceAll: '*' with: ''.
	 nettoye := nettoye copyReplaceAll: '[' with: ''.
	 nettoye := nettoye copyReplaceAll: ']' with: ''.
	 nettoye := nettoye copyReplaceAll: '{' with: ''.
	 nettoye := nettoye copyReplaceAll: '}' with: ''.
    nettoye := nettoye copyReplaceAll: '-' with: ''.
    nettoye := nettoye copyReplaceAll: '!' with: ''.	 
    nettoye := nettoye copyReplaceAll: '""' with: ' '.
    nettoye := nettoye copyReplaceAll: '«' with: ' '.	 	 
    nettoye := nettoye copyReplaceAll: '»' with: ' '.	
	 nettoye := nettoye copyReplaceAll: '@' with: ' '.
	 nettoye := nettoye copyReplaceAll: 'ï¿½' with: ''.
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
					at: 'methode' put: com commentedEntity;
					at: 'comment' put: com;
					at: 'modifiedComment' put: oneLine trimBoth;
      	 			yourself).
	 
	 collection add: dict.
].

"Eliminer les commentaires vides"
collection := collection reject: [ :dict | (dict at: 'modifiedComment') isEmpty ].

"Eliminer les commentaires egaux au noms des méthodes"
collection := collection reject: [ :dict | (dict at: 'modifiedComment') = (dict at: 'methode') name ].

"Choisir les méthodes tagées"
collection := collection select: [ :dict | (dict at: 'methode') isTagged ].

"Selectionner les commentaires"
finalComments := collection collect: [ :dict | dict at: 'comment' ].


"<----------------------------Construire les set des relations entre les classe --------------------------------->"

"2. Sélection des classes pertinentes"
modelClasses := (wegf allModelClasses
    select: [:c | 
        c superclassHierarchy anySatisfy: [:class | class name = 'EntitePersistanteAbstract']
    ])
    select: [:c |
        c methods anySatisfy: [:m | (m name includesSubstring: 'mapperOr' caseSensitive: false) and: [ m numberOfStatements > 0 ]]
    ].

"3. Création du graphe orienté classe -> attribut"
classGraph := Dictionary new.
modelClasses do: [:cls |
    classGraph at: cls put: Set new
].
modelClasses do: [:cls |
    cls attributes do: [:attr |
        | targetClass |
        targetClass := attr declaredType.
        (modelClasses includes: targetClass) ifTrue: [
            (classGraph at: cls) add: targetClass
        ].
    ]
].

"4. Identifier les classes totalement isolées (ni sortantes ni entrantes)"
isolatedClasses := Set new.
modelClasses do: [:cls |
    | outRelations inRelations |
    outRelations := (classGraph at: cls).
    inRelations := (classGraph keys select: [:k | (classGraph at: k) includes: cls]).
    (outRelations isEmpty and: [inRelations isEmpty]) ifTrue: [
        isolatedClasses add: cls
    ]
].

"5. Trouver les composantes connexes faibles en ignorant les classes isolées"
relationGroups := OrderedCollection new.
visited := Set new.

(modelClasses asOrderedCollection reject: [:cls | isolatedClasses includes: cls]) do: [:cls |
    (visited includes: cls) ifFalse: [
        | queue connectedClasses relationSet neighbors |
        queue := OrderedCollection with: cls.
        connectedClasses := Set new.

        [queue isEmpty] whileFalse: [
            | current |
            current := queue removeFirst.
            (connectedClasses includes: current) ifFalse: [
                connectedClasses add: current.
                visited add: current.

                neighbors := (classGraph at: current) copy.
                neighbors addAll: (classGraph keys select: [:k | (classGraph at: k) includes: current]).

                neighbors do: [:neighbor |
                    (connectedClasses includes: neighbor) ifFalse: [
                        queue add: neighbor
                    ]
                ].
            ]
        ].

        "Construire le set des relations pour ce groupe"
        relationSet := Set new.
        connectedClasses do: [:cl |
            (classGraph at: cl) do: [:attrCls |
                (connectedClasses includes: attrCls) ifTrue: [
                    | relDict |
                    relDict := Dictionary new.
                    relDict at: #classe put: cl.
                    relDict at: #attribut put: attrCls.
                    (relationSet includes: relDict) ifFalse: [relationSet add: relDict]
                ]
            ]
        ].

        relationGroups add: relationSet
    ]
].

"6. Ajouter les classes isolées dans leur propre set avec attribut nil"
isolatedClasses do: [:cls |
    relationGroups add: (Set with: (Dictionary new
        at: #classe put: cls;
        at: #attribut put: nil;
        yourself))
].

"7. Retour"
"^ relationGroups"

relationGraph := Dictionary new.

	relationGroups do: [:relSet |
		relSet do: [:rel |
			| c a |
			c := rel at: #classe.
			a := rel at: #attribut.
			(c notNil and: [a notNil]) ifTrue: [
				(relationGraph at: c ifAbsentPut: [OrderedCollection new]) add: {a. rel}.
			].
		].
	].



"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"


EssaiMethods := wegf allModelMethods select: [ :m | (((((((((m name = 'controler_RG_APAE092') or: [ m name = 'controler_RG_APAE117et118' ]) or: [ m name = 'controler_RG_HistoriqueAPAE113' ]) or: [ m name = 'controler_RG_CP_OP127' ]) or: [ m name = 'controlerRegleDeGestionPJCMERG_040' ]) or: [ m name = 'controler_RG_APAE090' ]) or: [ m name = 'controler_RG_OperationDInvestissement128' ]) or: [ m name = 'controler_RG_Engagement244' ]) or: [ m name = 'controler_RG_APAE084' ]) or: [ m name = 'controler_RG_RepartitionCP115' ] ].

EssaiMethods1 := (wegf allModelMethods select: [ :m | ((m name = 'modifierTypologieCoordonneeCom')) ]) select: [ :m | m comments anySatisfy: [ :com | com sourceText beginsWith: '/**' ] ].

"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

methodsService := ((wegf allModelClasses
	select: [ :c | c superclassHierarchy anySatisfy: [ :class | class name = 'ServiceAbstract' ] ])
	flatCollect: #methods).

methodsService := ((((wegf allModelClasses
	select: [ :c | c superclassHierarchy anySatisfy: [ :class | class name = 'ServiceAbstract' ] ])
	flatCollect: #methods)
	reject: [ :m | (((((m isConstructor or: [ m isPureAccessor ]) or: [ m name = '<Initializer>' ]) or: [ m name = 'getInstance' ] ) or: [ m name includesSubstring: 'fourni' ]) or: [ m cyclomaticComplexity < 4 ]) or: [ (m name includesSubstring: 'chercher') or: [ m name includesSubstring: 'recherche' ] ] ])).
		
methodsService := wegf allModelMethods select: [ :m | m isTagged ].
	

"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"



"mem := methodsService collect: [ :m | 
					| parameters localVars parameterTypes localVarsTypes types entityPersistante getters |

					parameters := m parameters.
					localVars := m localVariables.

					parameterTypes := (parameters collect: [ :p | p declaredType ]) select: #notNil.
	
					localVarsTypes := (localVars collect: [ :lv | lv declaredType ]) select: #notNil.

					types := parameterTypes , localVarsTypes.

					types := (((types collect: [ :type | (type isParametricEntity) ifTrue: [ type concreteParameters ] ifFalse: [ type ] ])
					flatCollect: [ :each |
    				(each isCollection and: [ each isString not ]) 
        			ifTrue: [ each asArray ]
        			ifFalse: [ { each } ].
					]) asSet).
	
					getters := (((((m outgoingInvocations flatCollect: [ :oinv | 
						oinv candidates]) select: [ :cand | 
							cand isPureAccessor ] ) collect: [ :meth | 
								meth declaredType 	]) select: [ :c | 
									c isStub not ]) select: [ :c | 
										c superclassHierarchy anySatisfy: [ :class | 
											class name = 'EntitePersistanteAbstract'  ] ]) asSet.

					types := types , getters.
	
					types := types collect: [ :t | t name ].
	
					m -> types.
				]."
			
mem := serviceMethods collect: [ :m |
	| visited typesStack resultTypes |

	visited := IdentitySet new.
	typesStack := OrderedCollection new.
	resultTypes := OrderedCollection new.

	typesStack add: m.

	[ typesStack isEmpty not ] whileTrue: [
		| currentMethod parameters localVars parameterTypes localVarsTypes currentTypes getters calledMethods |

		currentMethod := typesStack removeLast.

		(visited includes: currentMethod) ifFalse: [
			visited add: currentMethod.

			"Paramètres et variables locales"
			parameters := currentMethod parameters.
			localVars := currentMethod localVariables.

			parameterTypes := (parameters collect: [ :p | p declaredType ]) select: #notNil.
			localVarsTypes := (localVars collect: [ :lv | lv declaredType ]) select: #notNil.

			currentTypes := parameterTypes , localVarsTypes.

			"Traiter les types paramétriques"
			currentTypes := (((currentTypes collect: [ :type | 
				(type isParametricEntity) 
					ifTrue: [ type concreteParameters ] 
					ifFalse: [ type ] ]) 
				flatCollect: [ :each | 
					(each isCollection and: [ each isString not ]) 
						ifTrue: [ each asArray ] 
						ifFalse: [ { each } ] ])) asSet.

			"Types récupérés via les getters"
			getters := (((((currentMethod outgoingInvocations flatCollect: [ :oinv | 
				oinv candidates ]) 
				select: [ :cand | cand isPureAccessor ]) 
				collect: [ :meth | meth declaredType ]) 
				select: [ :c | c isStub not ]) 
				select: [ :c | c superclassHierarchy anySatisfy: [ :class | class name = 'EntitePersistanteAbstract' ] ]) asSet.

			currentTypes := currentTypes , getters.

			"Ajouter au résultat"
			currentTypes do: [ :t | resultTypes add: t ].

			"Ajouter les méthodes appelées à la pile"
			calledMethods := currentMethod outgoingInvocations flatCollect: [ :oinv | oinv candidates ].
			calledMethods do: [ :called |
				(visited includes: called) ifFalse: [ typesStack add: called ].
			].
		].
	].

	m -> (resultTypes asSet collect: [ :t | t name ]).
].



"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"


resultats := OrderedCollection new.

"Définir l’URL du serveur Flask"
url := 'http://127.0.0.1:5000/data'.
	
comments := ((((methodsService select: [ :m | m isTagged ]) flatCollect: #comments) select: [ :com | com commentedEntity sourceAnchor startLine > com sourceAnchor startLine ]) select: [ :com | (com sourceText beginsWith: '/**') ]) reject: [ :com | com sourceText includesSubstring: 'todo' caseSensitive: false ].

essaiComments := (((EssaiMethods flatCollect: #comments) select: [ :com | com commentedEntity sourceAnchor startLine > com sourceAnchor startLine ]) select: [ :com | (com sourceText beginsWith: '/**') ]) reject: [ :com | com sourceText includesSubstring: 'todo' caseSensitive: false ]. 

essaiComments1 := (((EssaiMethods1 flatCollect: #comments) select: [ :com | com commentedEntity sourceAnchor startLine > com sourceAnchor startLine ]) select: [ :com | (com sourceText beginsWith: '/**') ]) reject: [ :com | com sourceText includesSubstring: 'todo' caseSensitive: false ]. 

finalComments collect: [ :com | 
	
		| wordss textModif insideTag sourceText indexParam nettoye indexReturn indexBaliseOuvrante indexBaliseFermante indexThrow indexHash indexLiteral indexAlgo lines oneLine dict text|
	
		sourceText := com sourceText.
		
		indexParam := sourceText indexOfSubCollection: '@param'.
    
    nettoye := (indexParam > 1)
       ifTrue: [ (sourceText copyFrom: 1 to: indexParam - 1), String cr ]
       ifFalse: [ sourceText ].

	 indexReturn := nettoye indexOfSubCollection: '@return'.
	
	 nettoye := (indexReturn > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexReturn - 1), String cr ]
       ifFalse: [ nettoye ].

		textModif := ''.
		insideTag := false.

		nettoye do: [:char |
    		char = $< ifTrue: [ insideTag := true ].
    		insideTag ifFalse: [ textModif := textModif , char asString ].
    		char = $> ifTrue: [ insideTag := false ].
		].
	
		nettoye := textModif.

	 indexBaliseOuvrante := nettoye indexOfSubCollection: '<'.
	
	 indexBaliseFermante := nettoye indexOfSubCollection: '>'.
	
	 (indexBaliseFermante > 1)
	    ifTrue: [ 
			nettoye := (indexBaliseOuvrante > 1)
       		ifTrue: [ (nettoye copyFrom: 1 to: indexBaliseOuvrante - 1), String cr ]
       		ifFalse: [ nettoye ]. 
	 	 ].
       
	 indexThrow := nettoye indexOfSubCollection: '@throws'.
	 nettoye := (indexThrow > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexThrow - 1), String cr ]
       ifFalse: [ nettoye ].

    indexHash := nettoye indexOfSubCollection: '#'.
	 nettoye := (indexHash > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexHash - 1), String cr ]
       ifFalse: [ nettoye ].

	 indexLiteral := nettoye indexOfSubCollection: '$'.
	 nettoye := (indexLiteral > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexLiteral - 1), String cr ]
       ifFalse: [ nettoye ].

	 indexAlgo := nettoye indexOfSubCollection: 'Algo'.
	 nettoye := (indexAlgo > 1)
       ifTrue: [ (nettoye copyFrom: 1 to: indexAlgo - 1), String cr ]
       ifFalse: [ nettoye ].

			
		"1. Supprimer tous les symboles '/' , '*' , '<' , '>' , '[' , ']' et '-' "
		
		nettoye := nettoye copyReplaceAll: '@link' with: ''.
    nettoye := nettoye copyReplaceAll: '@type' with: ''.
    nettoye := nettoye copyReplaceAll: '@Type' with: ''.
	 nettoye := nettoye copyReplaceAll: '/' with: ''.
    nettoye := nettoye copyReplaceAll: '\' with: ''.
	 nettoye := nettoye copyReplaceAll: '*' with: ''.
	 nettoye := nettoye copyReplaceAll: '[' with: ''.
	 nettoye := nettoye copyReplaceAll: ']' with: ''.
	 nettoye := nettoye copyReplaceAll: '{' with: ''.
	 nettoye := nettoye copyReplaceAll: '}' with: ''.
    nettoye := nettoye copyReplaceAll: '-' with: ''.
    nettoye := nettoye copyReplaceAll: '!' with: ''.	 
    nettoye := nettoye copyReplaceAll: '""' with: ' '.
    nettoye := nettoye copyReplaceAll: '«' with: ' '.	 	 
    nettoye := nettoye copyReplaceAll: '»' with: ' '.	
	 nettoye := nettoye copyReplaceAll: '@' with: ' '.
	 nettoye := nettoye copyReplaceAll: 'ï¿½' with: ''.
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

		cleanedOneLine := oneLine trimBoth.
		
		m := com commentedEntity.
		
		"Envoyer la requête POST avec ZnClient"
		response := ZnClient new
    			url: url;
    			accept: 'application/json';
    			method: 'POST';
    			contents: cleanedOneLine;
    			execute.

		"Lire la réponse JSON"
		json := NeoJSONReader fromString: response contents.
				
		"wordss := (json at: 'resultat') select: [ :aWord | aWord size > 2 ]."
				
		WordsInput words: (json at: 'resultat').

		allClasses := OrderedCollection new.

		ClassesRepository classes: modelClasses.

		analysedClasses := (AnalysedClasses new) mapWordsToClasses.
		
		analysedClasses appropriateClasses.

		nbAnalysedClasses := analysedClasses analysedClasses size.

		analysedClasses analysedClasses do: [:analysedClass |
  			allClasses addAll: analysedClass relatedClasses.
		].
	
		finalClasses := OrderedCollection new.

		(nbAnalysedClasses = 1) 
			ifTrue: [ 
		
				finalClasses addAll: (ClassesMatcher closestClass: (analysedClasses analysedClasses first)).
	
			] ifFalse: [ 
			
				|pairs sortedPairs|
		
				nbAnalysedClassesHasClasses := 0.
		
				analysedClasses analysedClasses do: [:analysedClass |
  					(analysedClass relatedClasses size > 0) ifTrue: [ 
						nbAnalysedClassesHasClasses := nbAnalysedClassesHasClasses + 1.
		 			]
				].
	
				nbAnalysedClassesHasClasses.
		
				"Étape 1 : construire une map Classe → Liste de AnalysedClass"
				classToAnalysed := Dictionary new.

				analysedClasses analysedClasses do: [:ac |
    				ac relatedClasses do: [:cls |
        				(classToAnalysed at: cls ifAbsentPut: [OrderedCollection new]) add: ac.
    				].
				].
	
				"ordonner classToAnalysed"
				
				pairs := classToAnalysed associations.
				
				sortedPairs := pairs sorted: [:a :b |
    				| sizeA sizeB |
    				sizeA := (a value collect: [:ac | ac relatedClasses size]) inject: 0 into: [:sum :each | sum + each].
					sizeB := (b value collect: [:ac | ac relatedClasses size]) inject: 0 into: [:sum :each | sum + each].

				    sizeA > sizeB
				].

	
				(1 to: sortedPairs size) do: [:i |
				
					| cls acs pair analysedToRemove |
					
					Transcript show: 'dans la boucle: (1 to: sortedPairs size)'; cr.
				
    				pair := sortedPairs at: i.
    				cls := pair key.
    				acs := pair value.
				
					"Disons que tu identifies certaines analysedClasses à supprimer, par ex. :"
    				analysedToRemove := OrderedCollection new.

    				(acs size > 1) ifTrue: [
        				| bestAC minRemainder acNames clsName included |
				
						Transcript show: 'dans la boucle: (acs size > 1)'; cr.

	        			clsName := cls name asLowercase.
 	       			acNames := acs collect: [:ac | ac name asLowercase].

	        			"Cas 1 : Inclusion directe"
 	       			included := acs detect: [:ac1 |
  	          			acs anySatisfy: [:ac2 |
   		            			(ac1 ~= ac2) and: [(ac2 name asLowercase includesSubstring: ac1 name asLowercase)]
     	       			]
        				] ifNone: [nil].

		        		included ifNotNil: [

  		          		"On garde uniquement l'analysedClass incluse"
  			       		classToAnalysed at: cls put: (OrderedCollection with: included).
							Transcript show: 'dans la condition: included ifNotNil:'; cr.

        				] ifNil: [

	            			"Cas 2 : Concaténation approximative des noms des analysedClasses"
 	           			| combinedLength diff |
				
							Transcript show: 'dans la condition: included ] ifNil: ['; cr.
							
  	          			combinedLength := (acNames inject: '' into: [:res :n | res , n]) size.
	   	         			diff := (clsName size - combinedLength) abs.
					
							Transcript show: 'clsName' ; cr.	
							Transcript show: clsName ; cr.	
							Transcript show: 'diff' ; cr.
							Transcript show: diff ; cr.
							Transcript show: 'acNames size' ; cr.
							Transcript show: (acNames size) ; cr.
							Transcript show: 'diff <= (acNames size)' ; cr.				
							Transcript show: (diff <= (acNames size)) ; cr.

	            			(diff <= (acNames size)) ifTrue: [
  		              		"Ajouter la classe à la collection finale"
 	  	 						finalClasses add: cls.

	    						"Supprimer toutes les analysedClasses concernées"
 		   						acs do: [:ac |
   		     						analysedClasses analysedClasses remove: ac ifAbsent: [].
									analysedToRemove add: ac.
    							].

							"Maintenant, supprimer ces analysedClasses dans les paires suivantes"
    						((i + 1) to: (sortedPairs size)) do: [:j |
        						| nextPair nextAcs |
        						nextPair := sortedPairs at: j.
        						nextAcs := nextPair value.
        						analysedToRemove do: [:ac | nextAcs remove: ac ifAbsent: []].
    						].

    						"Retirer cette classe de la map"
    						classToAnalysed removeKey: cls ifAbsent: [].
						

            			] ifFalse: [

                		"Cas 3 : comparer le reste du nom après soustraction"
                		minRemainder := 9999.
                		bestAC := nil.

		               acs do: [:ac |
                    		| acName remainder |
                    		acName := ac name asLowercase.
                    		remainder := clsName copyReplaceAll: acName with: ''.
                    		(remainder size < minRemainder) ifTrue: [
                        		bestAC := ac.
                        		minRemainder := remainder size.
                    		].
                		].

                		"Supprimer cls des autres analysedClasses"
                		acs do: [:ac |
                    		ac ~= bestAC ifTrue: [
                        		ac relatedClasses remove: cls.
                    		].
                		].

                		classToAnalysed at: cls put: (OrderedCollection with: bestAC).
            			].
        			].
    			].
			].

			"Étape 2 : pour chaque classe présente dans plusieurs analysedClasses"
			classToAnalysed keysAndValuesDo: [:cls :acs |
    			acs size > 1 ifTrue: [
        			"Comparer les noms et choisir le meilleur"
        			| best bestDistance |
	        		best := nil.
	        		bestDistance := 9999.

	        		acs do: [:ac |
 	           		| dist |
  	          		dist := analysedClasses levenshteinDistanceBetween: ac name asLowercase and: cls name asLowercase.

	            		(dist < bestDistance) ifTrue: [
 		               	best := ac.
   		             	bestDistance := dist.
     	       		].
      		  		].

	        		"Retirer cette classe des autres analysedClasses"
 	       		acs do: [:ac |
  	          		ac ~= best ifTrue: [
   		            		(ac relatedClasses includes: cls) ifTrue: [
    							ac relatedClasses remove: cls
							].
	            		].
 	       		].
  		  		].
			].
		
		"Tester si finalClasses has changed"		
		(finalClasses size = 0) ifTrue: [ 

			analysedClasses analysedClasses do: [:analysedClass |
  				allClasses addAll: analysedClass relatedClasses.
			].
		
			allClasses.
		
			"1. Construire les paires de classes dans un même AnalysedClass"
			sameGroupPairs := Set new.
			analysedClasses analysedClasses do: [:analysedClass |
   		 		| related |
    			related := analysedClass relatedClasses.
    			related do: [:c1 |
       	 		related do: [:c2 |
        	    		(c1 ~= c2) ifTrue: [
         		       	sameGroupPairs add: (Set with: c1 with: c2).
           	 		].
        			].
    			].
			].

			sameGroupPairs.
		
			"2. Calculer les distances utiles uniquement"
			allDistances := Dictionary new.
			allClasses do: [:c1 |
   		 		allClasses do: [:c2 |
     		   		(c1 ~= c2) ifTrue: [
       	     		| distance pair |
        	    		distance := AnalysedClasses distanceBetween: c1 and: c2 withRelationGraph: relationGraph.
         		   		pair := (Set with: c1 with: c2).

	            		((distance first ~= 5000) and: [(sameGroupPairs includes: pair) not]) ifTrue: [
	                	enrichedResult := Dictionary new.
	                	enrichedResult at: #distance put: distance first.
 		               	enrichedResult at: #path put: distance second.
   		             	enrichedResult at: #classe1 put: c1.
     		           	enrichedResult at: #classe2 put: c2.
                
       		         	allDistances at: pair put: enrichedResult.
            		
						].
        			].
    			].
			].
		
			filteredDistances := allDistances select: [ :dict | (dict at: #distance) < 3 ].
		
			((filteredDistances select: [ :dict | (dict at: #distance) = 1 ]) size = 1 )
				ifTrue: [ 
				
					finalClasses add: ((filteredDistances detect: [ :dict | (dict at: #distance) = 1 ]) at: #classe1).
				
					finalClasses add: ((filteredDistances detect: [ :dict | (dict at: #distance) = 1 ]) at: #classe2).
				
					finalClasses
				
				 ]
				ifFalse: [ 
				
					(((filteredDistances select: [ :dict | (dict at: #distance) = 1 ]) size = 0 ) and: [ ((filteredDistances select: [ :dict | (dict at: #distance) = 2 ]) size = 1 ) ])
				
						ifTrue: [ 
				
							finalClasses add: ((filteredDistances detect: [ :dict | (dict at: #distance) = 2 ]) at: #classe1).
				
							finalClasses add: ((filteredDistances detect: [ :dict | (dict at: #distance) = 2 ]) at: #classe2).
				
				 		]
				
						ifFalse: [ 
						
							classesAfterFilter := OrderedCollection new.
						
							filteredDistances collect: [ :dict |
							
								classesAfterFilter add: (dict at: #classe1).
							
								classesAfterFilter add: (dict at: #classe2).
							
							].

							classesAfterFilter := classesAfterFilter asSet.
						
							analysedClasses analysedClasses do: [:analysedClass |
  		  						| filteredRelated |
    							filteredRelated := (analysedClass relatedClasses) select: [:cls | 	classesAfterFilter includes: cls].
    							analysedClass relatedClasses: filteredRelated.
							].

							analysedClasses analysedClasses.
					
							"<-------------------------- Filtrer les classes restantes -------------------------->"
						
							matchingClasses := OrderedCollection new.

							analysedClasses analysedClasses: (analysedClasses analysedClasses reject: [:analysedClass |
								| targetName relatedClasses exactMatches |
								targetName := analysedClass name asLowercase.
								relatedClasses := analysedClass relatedClasses.

								exactMatches := relatedClasses select: [:cls |
								cls name asLowercase = targetName
							].

								matchingClasses addAll: exactMatches.

								exactMatches isNotEmpty
							]).
					
							analysedClasses analysedClasses.
						

							(matchingClasses size > 0) 
							
								ifTrue: [ 
								
									| newAnalysedClasses |
								
									allClasses := OrderedCollection new.
					
									finalClasses addAll: matchingClasses.
								
									analysedClasses analysedClasses.
								
									analysedClasses analysedClasses do: [:analysedClass |
  										allClasses addAll: analysedClass relatedClasses.
									].
								
									filteredDistances.
								
									filteredClasses := filteredDistances select: [:dict | 
										((dict at: #distance) = 1) 
											and: [
												((finalClasses includes: (dict at: #classe1))and: [allClasses includes: (dict at: #classe2)])
											or: [
												(finalClasses includes: (dict at: #classe2)) and: [allClasses includes: (dict at: #classe1)]
												]
											]
									].
							
									filteredClasses.
								
									classesInFiltresClasses := OrderedCollection new.
								
									filteredClasses collect: [ :dict | 
									
										classesInFiltresClasses add: (dict at: #classe1).
										classesInFiltresClasses add: (dict at: #classe2).
									].
								
									classesInFiltresClasses.
							
									analysedClasses analysedClasses.
								
									newAnalysedClasses := analysedClasses analysedClasses collect: [:analysedClasse | 
    									| filteredRelated |
    									filteredRelated := (analysedClasse relatedClasses select: [:cls | classesInFiltresClasses includes: cls ]).
								
    									analysedClasse relatedClasses: filteredRelated.
    									analysedClasse
									].
							
									analysedClasses analysedClasses: newAnalysedClasses.
								
									analysedClasses analysedClasses.
								
									analysedClasses analysedClasses: ( analysedClasses analysedClasses 
										select: 	[:analysedClasse | 
    										analysedClasse relatedClasses size > 0.
										]).
								
									analysedClasses analysedClasses do: [:analysedClasse | 
    									| name relatedClasses closestClass minDistance |

	    								name := analysedClasse name.
 		   								relatedClasses := analysedClasse relatedClasses.

	    								minDistance := Float infinity.
 		   								closestClass := nil.

	    								relatedClasses do: [:classe |
 	       								| distance selfChars otherChars commonCount |
        
  		      								"Calcul distance personnalisée directement ici"
        									selfChars := classe name asLowercase asSortedCollection.
        									otherChars := name asLowercase asSortedCollection.
        
        									commonCount := 0.
        									selfChars do: [:char |
          	  								(otherChars includes: char)
           		     							ifTrue: [
             	       							commonCount := commonCount + 1.
              		      							otherChars remove: char.
                								]
												].
        
        									distance := (classe name size + name size) - 2 * commonCount.

								        	distance < minDistance ifTrue: [
 	           								minDistance := distance.
  	          								closestClass := classe.
   		     								]
										].

    									"On remplace relatedClasses par un seul élément : la classe la plus proche"
    									analysedClasse relatedClasses: {closestClass}.

									].
							
									analysedClasses analysedClasses.
								
									analysedClasses analysedClasses collect: [ :analysedClass |
									
										(finalClasses includes: (analysedClass relatedClasses first))
									
											ifFalse: [ 	
										
												finalClasses add: analysedClass relatedClasses first. 
										
											]
										].
								
									finalClasses.
							
								] ifFalse: [ 
								
									analysedClasses analysedClasses do: [:analysedClasse | 
    									| name relatedClasses closestClass minDistance |

	    								name := analysedClasse name.
 		   								relatedClasses := analysedClasse relatedClasses.
	
 		   								minDistance := Float infinity.
   		 								closestClass := nil.

	    								relatedClasses do: [:classe |
 	       								| distance selfChars otherChars commonCount |
        
  		      								"Calcul distance personnalisée directement ici"
	        								selfChars := classe name asLowercase asSortedCollection.
 	       								otherChars := name asLowercase asSortedCollection.
        
  		      								commonCount := 0.
    	    								selfChars do: [:char |
     	       								(otherChars includes: char)
      		          							ifTrue: [
        		            							commonCount := commonCount + 1.
          	          							otherChars remove: char.
           		     							]
												].
        
        									distance := (classe name size + name size) - 2 * commonCount.

							        		distance < minDistance ifTrue: [
            									minDistance := distance.
            									closestClass := classe.
        									]
										].

    									"On remplace relatedClasses par un seul élément : la classe la plus proche"
	    								analysedClasse relatedClasses: {closestClass}.

									].
							
									allClasses := OrderedCollection new.
								
									analysedClasses analysedClasses do: [:analysedClass |
  										allClasses addAll: analysedClass relatedClasses.
									].
								
									finalClasses addAll: matchingClasses.
								
									finalClasses.
								]
							]
						]
					].
			 	].
			
				(finalClasses size = 0) ifTrue: [ 
					analysedClasses analysedClassesNotModified do: [:analysedClass |
  						finalClasses addAll: analysedClass relatedClasses.
					]
				].
			
				classNames := finalClasses collect: [:each | each name].

				"Le premier filtre selon les classes utilisées"
				rsltF1 := mem select: [ :assoc | 
					classNames allSatisfy: [:mot | (assoc value) includes: mot].
				].

				methodesResults := rsltF1 collect: [ :assoc | assoc key ].
				
				dict := (Dictionary new
								at: 'methode' put: m;
								at: 'comment' put: cleanedOneLine;
								at: 'nbMethods' put: methodesResults size;
								at: 'methods' put: methodesResults;
								at: 'resultNLP' put: (json at: 'resultat');
								at: 'appropriateClasses' put: finalClasses;
      	 						yourself).
						
				resultats add: dict.
].

resultats
