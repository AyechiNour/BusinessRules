Class {
	#name : 'CommentCleaner',
	#superclass : 'Object',
	#instVars : [
		'comment',
		'commentSourceText',
		'commentedEntity'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'helper methods' }
CommentCleaner >> cleanAngleBrackets [

	 "Cette méthode supprime les mots entre < >"

    | stack i char startIndex |

    stack := OrderedCollection new.
    i := 1.
    [i <= commentSourceText size] whileTrue: [
			char := commentSourceText at: i.
         (char asciiValue = 60) ifTrue: [stack add: i].
         (char asciiValue = 62) ifTrue: [
				(stack isEmpty) ifFalse: [
					startIndex := stack removeLast.
             	"Supprime de la dernière ouvrante jusqu'au '>' inclus"
             	commentSourceText := (commentSourceText copyFrom: 1 to: startIndex - 1), (commentSourceText copyFrom: i + 1 to: commentSourceText size).
             	"On ajuste i pour continuer correctement après suppression"
             	i := startIndex - 1.
				].
			].
         i := i + 1.
	 ].

]

{ #category : 'as yet unclassified' }
CommentCleaner >> cleanComment [

	 "Remove the explicitly mentioned parameters"
	 self deleteBeforeAnyOf: '@param'.

	 "Remove the explicitly mentioned return type"
	 self deleteBeforeAnyOf: '@return'.

	 "Remove the explicitly mentioned exceptions in the comments"
	 self deleteBeforeAnyOf: '@throw'.

	 "Remove the code sections described in the comments"
	 self deleteBeforeAnyOf: 'Algo'.
	 self deleteBeforeAnyOf: 'algo'.
	 
	 "Remove the parts of the string after #"
	 self deleteBeforeAnyOf: '#'.
	
	 "Remove the parts of the string after $"
	 self deleteBeforeAnyOf: '$'.

	 "Supprimer les mots entre < >"
	 self cleanAngleBrackets.
	
	 "Enlever quelques annotations"
	 self deleteFromComment: '@link'.
	 self deleteFromComment: '@type'.
	 self deleteFromComment: '@Type'.
	
	 "Enlever quelques caractères"
	 self deleteFromComment: '/'.
	 self deleteFromComment: '\'.
	 self deleteFromComment: '*'.
	 self deleteFromComment: '['.
	 self deleteFromComment: ']'.
    self deleteFromComment: '{'.
	 self deleteFromComment: '}'.
	 self deleteFromComment: '-'.
	 self deleteFromComment: '!'.
	 self deleteFromComment: '""'. 
	 self deleteFromComment: '«'. 
	 self deleteFromComment: '»'. 
	 self deleteFromComment: '@'. 
	 self deleteFromComment: 'ï¿½'.
	 self deleteFromComment: ')'. 
	 self deleteFromComment: ':'.
	
	 "Delete unuseful spaces"
	 self deleteSpaces.
	 
	 "flatten comment"
	 self flattenComment.
]

{ #category : 'accessing' }
CommentCleaner >> comment [

	^comment
]

{ #category : 'accessing' }
CommentCleaner >> comment: aComment [

	comment := aComment.
	commentSourceText := aComment sourceText.
	commentedEntity := aComment commentedEntity.
]

{ #category : 'accessing' }
CommentCleaner >> commentSourceText [

	^commentSourceText
]

{ #category : 'accessing' }
CommentCleaner >> commentSourceText: aString [

	commentSourceText := aString.
]

{ #category : 'accessing' }
CommentCleaner >> commentedEntity [

	^commentedEntity
]

{ #category : 'accessing' }
CommentCleaner >> commentedEntity: anEntity [

	commentedEntity := anEntity
]

{ #category : 'helper methods' }
CommentCleaner >> deleteBeforeAnyOf: marker [

	 | indexParam |
	 indexParam := commentSourceText indexOfSubCollection: marker.
    commentSourceText := (indexParam > 1)
       ifTrue: [ (commentSourceText copyFrom: 1 to: indexParam - 1)]
       ifFalse: [ commentSourceText ].
]

{ #category : 'helper methods' }
CommentCleaner >> deleteFromComment: sub [
	
	commentSourceText  := commentSourceText copyReplaceAll: sub with: ' '.
]

{ #category : 'helper methods' }
CommentCleaner >> deleteSpaces [

    | words |
    words := commentSourceText findTokens: ' '.
    commentSourceText := String streamContents: [:stream |
        							words do: [:word |
            							stream nextPutAll: word.
			   							(word = words last) ifFalse: [ 
											stream nextPutAll: ' '.
										].
        							].
								].
]

{ #category : 'helper methods' }
CommentCleaner >> flattenComment [
    "Convert a multi-line text into a single line, adding a space between each line"
    | lines oneLine |
    
    "Split the text into lines"
    lines := commentSourceText lines.
    
    "Create a single line"
    oneLine := String streamContents: [:stream |
        lines do: [:line |
            stream nextPutAll: (line trimBoth).
			   (line = lines last) ifFalse: [ 
					stream nextPutAll: ' '. "Add a space between lines"
				].
        ].
    ].
    
    commentSourceText :=  oneLine trimBoth.  "Remove the trailing space"
]

{ #category : 'initialization' }
CommentCleaner >> initialize [

	comment := nil.
	commentSourceText := ''.
]
