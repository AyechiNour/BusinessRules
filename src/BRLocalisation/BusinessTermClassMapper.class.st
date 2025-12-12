"
This class is used to analyze comments and return a list of AnalysedComment objects.
"
Class {
	#name : 'BusinessTermClassMapper',
	#superclass : 'Object',
	#instVars : [
		'businessClassses'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'accessing' }
BusinessTermClassMapper >> businessClassses [

	^businessClassses
]

{ #category : 'accessing' }
BusinessTermClassMapper >> businessClassses: aCollection [

	businessClassses := aCollection
]

{ #category : 'as yet unclassified' }
BusinessTermClassMapper >> intialize [

	super initialize.
	businessClassses := OrderedCollection new.


]

{ #category : 'accessing' }
BusinessTermClassMapper >> start: commentCollection [

	| client listOfAnalysedComment |
	
	listOfAnalysedComment := OrderedCollection new.
	
	client := (Client new).
	client url: 'http://127.0.0.1:5000/data'.
	commentCollection collect: [ :commentCleaner |
		
		| response termsClassesFinder analysedComment |

		client contents: (commentCleaner commentSourceText).
		client sendRequest.
		response := client response.
		termsClassesFinder := TermsClassesFinder new.
		termsClassesFinder businessClassses: businessClassses.
		termsClassesFinder terms: response.
		
		analysedComment := AnalysedComment new.
		analysedComment comment: (commentCleaner commentSourceText).
		analysedComment terms: response.
		analysedComment classesToTerms: (termsClassesFinder mapClassesToTerms).
		listOfAnalysedComment add: analysedComment.
	].

	^listOfAnalysedComment
]
