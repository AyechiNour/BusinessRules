"
This class identifies, for each term in a list of terms extracted from a single sentence, the classes whose names contain that term.
"
Class {
	#name : 'TermsClassesFinder',
	#superclass : 'Object',
	#instVars : [
		'businessClassses',
		'terms',
		'termsClassesList'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'accessing' }
TermsClassesFinder >> businessClassses [

	^businessClassses
]

{ #category : 'accessing' }
TermsClassesFinder >> businessClassses: aCollection [

	businessClassses := aCollection
]

{ #category : 'initialization' }
TermsClassesFinder >> initialize [

	super initialize.
	terms := OrderedCollection new.
	termsClassesList := OrderedCollection new.
	businessClassses := OrderedCollection new.
]

{ #category : 'mapping' }
TermsClassesFinder >> mapClassesToTerm: aTerm [

	| termClasses |
	
	termClasses := (TermClasses new).
	termClasses term: aTerm.
	termClasses classes: (businessClassses select: [ :c |
		( c name asLowercase) includesSubstring: (aTerm asLowercase)
		]).
	
	^termClasses
]

{ #category : 'mapping' }
TermsClassesFinder >> mapClassesToTerms [

	terms collect: [ :aTerm | 
		
		| termClasses|
		
		termClasses := self mapClassesToTerm: aTerm.
		termsClassesList add: termClasses.
		
		].
	
	^termsClassesList
]

{ #category : 'accessing' }
TermsClassesFinder >> terms [

	^terms
]

{ #category : 'accessing' }
TermsClassesFinder >> terms: aCollection [

	terms := aCollection
]

{ #category : 'accessing' }
TermsClassesFinder >> termsClassesList [

	^termsClassesList
]

{ #category : 'accessing' }
TermsClassesFinder >> termsClassesList: aCollection [

	termsClassesList := aCollection
]
