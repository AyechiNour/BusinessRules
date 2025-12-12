"
This class is used to find the relationships between the classes associated with the terms of a single comment.
"
Class {
	#name : 'AnalysedCommentRelationAnalyzer',
	#superclass : 'Object',
	#instVars : [
		'analysedComment',
		'relations',
		'classRelationsGraph'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'accessing' }
AnalysedCommentRelationAnalyzer >> analysedComment [

	^analysedComment
]

{ #category : 'accessing' }
AnalysedCommentRelationAnalyzer >> analysedComment: anAnalysedComment [

	analysedComment := anAnalysedComment
]

{ #category : 'accessing' }
AnalysedCommentRelationAnalyzer >> classRelationsGraph [

	^classRelationsGraph
]

{ #category : 'accessing' }
AnalysedCommentRelationAnalyzer >> classRelationsGraph: aCollection [

	classRelationsGraph := aCollection
]

{ #category : 'as yet unclassified' }
AnalysedCommentRelationAnalyzer >> extractRelationsBetween: termClasses1 and: termClasses2 [

	| relations |
	
	relations := OrderedCollection new.

	(termClasses1 classes) do: [ :class1 |
		(termClasses2 classes) do:[ :class2 |
			
			relations add: {
                termClasses1 name. "ou classA si tu veux l'objet complet"
                termClasses2 name.
                
            }.
			
			
			
			]
		]
]

{ #category : 'initialization' }
AnalysedCommentRelationAnalyzer >> initialize [

	super initialize.
	analysedComment := AnalysedComment new.
	relations := OrderedCollection new.
	classRelationsGraph := OrderedCollection new.
]

{ #category : 'accessing' }
AnalysedCommentRelationAnalyzer >> relations [

	^relations
]

{ #category : 'accessing' }
AnalysedCommentRelationAnalyzer >> relations: aCollection [

	relations := aCollection
]
