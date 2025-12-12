"
This class is used to find the relationships between classes.
"
Class {
	#name : 'ClassRelationAnalyzer',
	#superclass : 'Object',
	#instVars : [
		'modelClasses',
		'classGraph',
		'isolatedClasses',
		'relationGraph',
		'relationGroups'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'helpers' }
ClassRelationAnalyzer >> addIsolatedClassesAsGroups [

   isolatedClasses collect: [:cls |
       relationGroups add: (Set with: (
           Dictionary new
               at: #classe put: cls;
               at: #attribut put: nil;
               at: #distance put: 0;
               yourself))
	].
]

{ #category : 'as yet unclassified' }
ClassRelationAnalyzer >> bfsFrom: startClass [

    | queue connected distances |
    queue := OrderedCollection with: startClass.
    connected := Set new.
    distances := Dictionary new.
    distances at: startClass put: 0.

    [queue isEmpty] whileFalse: [
        | current currentDist neighbors |
        current := queue removeFirst.
        currentDist := distances at: current.

        (connected includes: current) ifFalse: [
            connected add: current.
            neighbors := (classGraph at: current) copy.
            neighbors addAll: (classGraph keys select: [:k | (classGraph at: k) includes: current]).
            neighbors do: [:n |
                (distances includesKey: n) ifFalse: [
                    distances at: n put: currentDist + 1.
                    queue add: n]
					]
				]
			].

    ^Dictionary new
        at: #connected put: connected;
        at: #distances put: distances;
        yourself.
]

{ #category : 'as yet unclassified' }
ClassRelationAnalyzer >> buildClassGraph [

    modelClasses do: [:cls | classGraph at: cls put: (Set new)].
    modelClasses do: [:cls |
        cls attributes do: [:attr |
            | target |
            target := attr declaredType.
            (modelClasses includes: target) ifTrue: [
                (classGraph at: cls) add: target
				]
			]
		].
]

{ #category : 'starting' }
ClassRelationAnalyzer >> buildClassRelationGraph [
 
    self buildClassGraph.
    self findIsolatedClasses.
    self computeConnectedComponents.
    self addIsolatedClassesAsGroups.
    self buildRelationGraph.
]

{ #category : 'helpers' }
ClassRelationAnalyzer >> buildRelationGraph [

    relationGroups do: [:relSet |
        relSet do: [:rel |
            | c a |
            c := rel at: #classe.
            a := rel at: #attribut.
            (c notNil and: [a notNil]) ifTrue: [
                (relationGraph at: c ifAbsentPut: [OrderedCollection new]) add: {a. rel}
					]
				]
			].
]

{ #category : 'accessing' }
ClassRelationAnalyzer >> classGraph [

	^classGraph
]

{ #category : 'accessing' }
ClassRelationAnalyzer >> classGraph: aGraph [

	classGraph := aGraph
]

{ #category : 'as yet unclassified' }
ClassRelationAnalyzer >> computeConnectedComponents [

	 | visited |
    visited := Set new.

    (modelClasses reject: [:c | isolatedClasses includes: c]) do: [:cls |
        (visited includes: cls) ifFalse: [
            | component distances relationSet bfsResult |
            bfsResult := self bfsFrom: cls.
				component := bfsResult at: #connected.
				distances := bfsResult at: #distances.
            visited addAll: component.

            "Build the relationships with distance"
            relationSet := Set new.
            component do: [:cl |
                (classGraph at: cl) do: [:attrCls |
                    (component includes: attrCls) ifTrue: [
                        | relDict dist |
                        relDict := Dictionary new.
                        relDict at: #classe put: cl.
                        relDict at: #attribut put: attrCls.
                        dist := distances at: attrCls.
                        relDict at: #distance put: dist.
                        (relationSet includes: relDict) ifFalse: [relationSet add: relDict]
							].
						].
					].
				
				relationGroups add: relationSet.
				
				].  
			].
]

{ #category : 'as yet unclassified' }
ClassRelationAnalyzer >> distanceBetween: classA and: classB [

    | rels |

    rels := relationGraph at: classA ifAbsent: [OrderedCollection new].
    rels do: [:pair |
        | target relDict |
        target := pair first.
        relDict := pair second.
        (target = classB) ifTrue: [^ relDict at: #distance].
    ].

	 rels := relationGraph at: classB ifAbsent: [OrderedCollection new].
    rels do: [:pair |
        | target relDict |
        target := pair first.
        relDict := pair second.
        (target = classA) ifTrue: [^ relDict at: #distance].
    ].

    ^ nil "no relation found"
]

{ #category : 'as yet unclassified' }
ClassRelationAnalyzer >> findIsolatedClasses [

    modelClasses do: [:cls |
        | out in |
        out := classGraph at: cls.
        in := classGraph keys select: [:k | (classGraph at: k) includes: cls].
        (out isEmpty and: [in isEmpty]) ifTrue: [isolatedClasses add: cls]].
]

{ #category : 'initialization' }
ClassRelationAnalyzer >> initialize [

	super initialize.
	modelClasses := nil.
	classGraph := Dictionary new.
	isolatedClasses := Set new.
	relationGraph := Dictionary new.
	relationGroups := OrderedCollection new.
]

{ #category : 'accessing' }
ClassRelationAnalyzer >> isolatedClasses [

	^isolatedClasses
]

{ #category : 'accessing' }
ClassRelationAnalyzer >> isolatedClasses: classes [

	isolatedClasses := classes
]

{ #category : 'accessing' }
ClassRelationAnalyzer >> modelClasses [

	^modelClasses
]

{ #category : 'accessing' }
ClassRelationAnalyzer >> modelClasses: classes [

	modelClasses := classes
]

{ #category : 'accessing' }
ClassRelationAnalyzer >> relationGraph [

	^relationGraph
]

{ #category : 'accessing' }
ClassRelationAnalyzer >> relationGraph: aGraph [

	relationGraph := aGraph
]
