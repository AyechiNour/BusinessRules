"Récupérer la racine du modèle Moose"
wegf := MooseModel root at: 1.

"Analyser les classes metiers"
classesAnalyse := ClassesAnalyse new.
classesAnalyse getBusinessClassesFromMooseModel: wegf.

classesAnalyse analyzeClasses.

"Avoir une collection des objets ClasseRepresentation contenant des infos sur les classes metiers"
classesAnalyse businessClassesAnalysed.

"----------------------------------------------------------------------------------------------------------------------------------------------------------"

"Récupérer les méthodes des classes service"
serviceMethods := (wegf allModelClasses select: [ :c | c superclassHierarchy anySatisfy: [ :class | class name = 'ServiceAbstract' ] ]) flatCollect: #methods.

"Eliminer les constructeurs"
serviceMethods := serviceMethods reject: [ :m | m isConstructor ].

"Eliminer les getters"
serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'get' ].

"Eliminer les setters"
serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'set' ].

"Eliminer les méthodes d'initialisation <Initializer> initialiser* initialisation* initialise*"
serviceMethods := serviceMethods reject: [ :m | m name = '<Initializer>' ].

serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'initiali' ].

"Eliminer les méthodes fournir fournit fournier"
serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'fou' ].

"Eliminer les méthodes de recherche chercher et rechercher"
serviceMethods := serviceMethods reject: [ :m | (m name beginsWith: 'chercher') or: [ m name beginsWith: 'recherche' ] ].

"Eliminer les méthodes dont la complexité cyclomatique est inferieur à 4"
methodsService := serviceMethods reject: [ :m | m cyclomaticComplexity < 4 ].

"----------------------------------------------------------------------------------------------------------------------------------------------------------"

mem := methodsService collect: [ :m |
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

"----------------------------------------------------------------------------------------------------------------------------------------------------------"

"Définir l’URL du serveur de lemmalisation des classess metiers"
url1 := 'http://127.0.0.1:5000/data'.

"Lemmalisation de tous les mots avec le serveur du fichier lemmalisation.py"
(classesAnalyse businessClassesAnalysed) do: [ :classeRep |
	
	 phrase := ''.
	
	 (classeRep classeNameSplit) do: [:word |  
    		phrase := phrase = '' 
         ifTrue: [word] 
         ifFalse: [phrase , ' ' , word].
     ].

	 response := ZnClient new
    			url: url1;
    			accept: 'application/json';
    			method: 'POST';
    			contents: phrase;
    			execute.
			
	 "Lire la réponse JSON"
	 json := NeoJSONReader fromString: response contents.

	 classeRep classeNameSplit: (json at: 'resultat').

].

collection1 := (classesAnalyse businessClassesAnalysed).

collection1.

"----------------------------------------------------------------------------------------------------------------------------------------------------------"

"Définir l’URL du serveur d'analyse des commentaires"
url2 := 'http://127.0.0.1:5001/data'.

"----------------------------------------------------------------------------------------------------------------------------------------------------------"
"Choisir les commentaires"

"Récupérer les méthodes des classes service"
serviceMethods := (wegf allModelClasses select: [ :c | c superclassHierarchy anySatisfy: [ :class | class name = 'ServiceAbstract' ] ]) flatCollect: #methods.

"Eliminer les constructeurs"
serviceMethods := serviceMethods reject: [ :m | m isConstructor ].

"Eliminer les getters"
serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'get' ].

"Eliminer les setters"
serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'set' ].

"Eliminer les méthodes d'initialisation <Initializer> initialiser* initialisation* initialise*"
serviceMethods := serviceMethods reject: [ :m | m name = '<Initializer>' ].

serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'initiali' ].

"Eliminer les méthodes fournir fournit fournier"
serviceMethods := serviceMethods reject: [ :m | m name beginsWith: 'fou' ].

"Eliminer les méthodes de recherche chercher et rechercher"
serviceMethods := serviceMethods reject: [ :m | (m name beginsWith: 'chercher') or: [ m name beginsWith: 'recherche' ] ].

"Eliminer les méthodes dont la complexité cyclomatique est inferieur à 4"
serviceMethods := serviceMethods reject: [ :m | m cyclomaticComplexity < 4 ].

"Récupérer commentaires des méthodes service"
serviceComments := serviceMethods flatCollect: #comments.

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

	 nettoye := nettoye copyReplaceAll: '@link' with: ' '.
    nettoye := nettoye copyReplaceAll: '@type' with: ' '.
    nettoye := nettoye copyReplaceAll: '@Type' with: ' '.
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
	 nettoye := nettoye copyReplaceAll: '.' with: ' '.
	  
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

"----------------------------------------------------------------------------------------------------------------------------------------------------------"

firstComments := finalComments first:3.

collection2 := OrderedCollection new.

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
		
	 nettoye := nettoye copyReplaceAll: '@link' with: ' '.
    nettoye := nettoye copyReplaceAll: '@type' with: ' '.
    nettoye := nettoye copyReplaceAll: '@Type' with: ' '.
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
	 nettoye := nettoye copyReplaceAll: 'ï¿½' with: ''.
	 nettoye := nettoye copyReplaceAll: '(' with: ' '.
    nettoye := nettoye copyReplaceAll: ')' with: ' '.
	 nettoye := nettoye copyReplaceAll: ':' with: ' '.
	 nettoye := nettoye copyReplaceAll: '.' with: ' '.
	  
    "Découper le commentaire en lignes"
	 lines := nettoye lines.
			
	 "Créer une seule ligne"
	 oneLine := String streamContents: [:stream |
    	 lines do: [:line |
        	 stream
             nextPutAll: line trimBoth;
            	 nextPutAll: ' '
  		  	]
	  ].

	  cleanedOneLine := oneLine trimBoth.
	
	  cleanedOneLineSplit := Helpers smartSplit: cleanedOneLine.
	
	  cleanedOneLineAfterSplit := String streamContents: [:stream |
    	  cleanedOneLineSplit do: [:line |
        	 stream
             nextPutAll: line trimBoth;
            	 nextPutAll: ' '
  		  	]
	  ].

	  m := com commentedEntity.
		
	  "Envoyer la requête POST avec ZnClient"
	  client := ZnClient new.
	  client 
    		timeout: 800;
    		url: url2;
    		accept: 'application/json';
    		method: 'POST';
    		contents: cleanedOneLineAfterSplit.

		response := client execute.

	   "Lire la réponse JSON"
	   json := NeoJSONReader fromString: response contents.
		
		result := (json at: 'resultat').
			
		classes := OrderedCollection new.
		
		"Fonction pour comparer deux tableaux avec tolérance sur les chaînes"
		arraysSimilar := [ :arr1 :arr2 |
    		| similar i s1 s2 dist |
			similar := true.
    		(arr1 size = arr2 size) ifFalse: [ similar := false ]. "Tailles différentes"
		 	
			similar ifTrue: [ 
				1 to: arr1 size do: [:i |
        		s1 := arr1 at: i.
        		s2 := arr2 at: i.
        		dist := Helpers levenshteinDistanceBetween: s1 and: s2.
        		(dist > 1) ifTrue: [ similar := false ].
   		 		].
			].	
    		similar.
		].
	
		result do: [ :dict |
			
			| arrayWords |
			
			arrayWords := ((dict at: 'text') findTokens: ' ').
			
			collection1 do: [:classe |
        		| classeWords |
        		classeWords := classe classeNameSplit asArray.  "tableau de mots de la classe"

        		((arraysSimilar value: classeWords value: arrayWords asArray) ifTrue: [
            		classes add: {
						'id' -> (dict at: 'id').
                	'NounPhrase' -> arrayWords.
						'contains' -> (dict at: 'contains').
                	'classe' -> classe classe.
                	'classeNameSplit' -> classeWords.
            		} asDictionary.
        		]).
			].
		].
	
		nounPhrases := result collect: [ :dict | dict at: 'text' ].
	
		businessClasses := OrderedCollection new.
		
		idContains := classes flatCollect: [ :dict | dict at: 'contains' ].
		
		"Récupérer tous les ids présents dans les 'contains'"
		idsToRemove := classes flatCollect: [ :dict | 
    		| contains |
    		contains := dict at: 'contains'.
    		contains flatCollect: [ :id |
        		| parts |
        		parts := id findTokens: '_'.
        		parts size > 1
            		ifTrue: [ parts copyWith: id ]  "ajoute la chaîne composée aussi"
            		ifFalse: [ { id } ]  "sinon garde juste la chaîne normale"
    		]
		].
	
		Transcript show: idContains; cr.
		
		"Afficher la liste originale"
		Transcript show: 'Avant filtrage:'; cr.
		classes do: [:dict | 
    		Transcript show: (dict at: 'id') asString; cr
		].

		"Filtrer"
		filteredClasses := classes reject: [:dict |
    		| id isIncluded |
    		id := (dict at: 'id') asString.
    		isIncluded := idContains includes: id.

    		"Debug pour chaque élément testé"
    		Transcript show: 'Test id: '; show: id; show: ' => '; show: isIncluded; cr.

    		isIncluded
		].

		"Afficher la liste après filtrage"
		Transcript show: 'Après filtrage:'; cr.
		filteredClasses do: [:dict |
    		Transcript show: (dict at: 'id') asString; cr
		].

		filteredClasses collect: [ :dict |
			
			businessClasses add: (dict at: 'classe'). 
			
		].
	
		businessClasses := businessClasses asSet.
	
		classNames := (filteredClasses collect: [:dict | (dict at: 'classe') name]) asSet.

		"Le premier filtre selon les classes utilisées"
		rslt := mem select: [:assoc |
    		(classNames notEmpty) and: [
        		classNames allSatisfy: [:mot | (assoc value) includes: mot]
    		].
		].

		methodesResults := rslt collect: [ :assoc | assoc key ].
				
		resultDict := (Dictionary new
							 at: 'methode' put: m;
							 at: 'comment' put: cleanedOneLineAfterSplit;
							 at: 'nounPhrases' put: nounPhrases;
							 at: 'classes' put: classes;
							 at: 'filteredClasses' put: filteredClasses;
							 at: 'businessClasses' put: businessClasses;
							 at: 'methodesResult' put: methodesResults;
							 yourself).
							 
		collection2 add: resultDict.
		
].
	
collection2.
