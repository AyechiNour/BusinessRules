"
This class is used to present a comment, its terms, and the classes associated with those terms.
"
Class {
	#name : 'AnalysedComment',
	#superclass : 'Object',
	#instVars : [
		'comment',
		'terms',
		'classesToTerms'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'accessing' }
AnalysedComment >> classesToTerms [

	^classesToTerms
]

{ #category : 'accessing' }
AnalysedComment >> classesToTerms: aCollection [

	classesToTerms := aCollection
]

{ #category : 'accessing' }
AnalysedComment >> comment [

	^comment
]

{ #category : 'accessing' }
AnalysedComment >> comment: aString [

	comment := aString
]

{ #category : 'initialization' }
AnalysedComment >> initialize [

	super initialize.
	comment := ''.
	terms := OrderedCollection new.
	classesToTerms := OrderedCollection new.
]

{ #category : 'accessing' }
AnalysedComment >> terms [

	^terms
]

{ #category : 'accessing' }
AnalysedComment >> terms: aCollection [

	terms := aCollection
]
