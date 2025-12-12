"
This class presents, for each term, the classes whose names contain that term.
"
Class {
	#name : 'TermClasses',
	#superclass : 'Object',
	#instVars : [
		'term',
		'classes'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'accessing' }
TermClasses >> classes [

	^classes
]

{ #category : 'accessing' }
TermClasses >> classes: aCollection [

	classes := aCollection
]

{ #category : 'initialization' }
TermClasses >> initialize [
	
	super initialize.
	term := ''.
	classes := OrderedCollection new.
]

{ #category : 'accessing' }
TermClasses >> term [

	^term
]

{ #category : 'accessing' }
TermClasses >> term: aString [

	term := aString
]
