"
This class is used to send requests to the server.
"
Class {
	#name : 'Client',
	#superclass : 'Object',
	#instVars : [
		'url',
		'contents',
		'response'
	],
	#category : 'BRLocalisation',
	#package : 'BRLocalisation'
}

{ #category : 'accessing' }
Client >> contents [

	^contents
]

{ #category : 'accessing' }
Client >> contents: aString [

	contents := aString
]

{ #category : 'initialization' }
Client >> initialize [

	super initialize.
	url := ''.
	contents := ''.
	response := nil.
]

{ #category : 'accessing' }
Client >> response [

	^response
]

{ #category : 'accessing' }
Client >> response: aString [

	response := aString
]

{ #category : 'sending message' }
Client >> sendRequest [

	| resp json |

	resp := ZnClient new
    			url: url;
    			accept: 'application/json';
    			method: 'POST';
    			contents: contents;
    			execute.
			
	json := NeoJSONReader fromString: resp contents.
	
	response := json at: 'result'
]

{ #category : 'accessing' }
Client >> url [

	^url
]

{ #category : 'accessing' }
Client >> url: aString [

	url := aString
]
