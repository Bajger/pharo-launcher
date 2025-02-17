Class {
	#name : #PhLImageCreateCliCommandTest,
	#superclass : #PhLImageCliCommandTest,
	#category : #'PharoLauncher-CLI-Tests'
}

{ #category : #utility }
PhLImageCreateCliCommandTest >> addLocalTemplateNamed: aName [ 
	^ self launcherModel templateRepository createLocalTemplateNamed: aName
	
]

{ #category : #accessing }
PhLImageCreateCliCommandTest >> localTemplatesGroup [
	^ context templateRepository localTemplatesGroup
]

{ #category : #running }
PhLImageCreateCliCommandTest >> setUp [
	super setUp.
	self launcherModel
		templateRepository: PhLTemplateTestRepository new
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testCreateImageShouldSucceed [
	self addImageNamed: 'myImage1'.
	self addImageNamed: 'myImage2'.
	self addLocalTemplateNamed: 'fakeTemplate'.
	
	self runCommand: {'launcher' . 'image' . 'create' . 'myImage3' . '--templateName'. 'fakeTemplate' . '--templateCategory' . self templateRepository localTemplatesGroupName}.
	 
	self assertSuccess.  
	self assert: self imageRepository imagesName equals: #( 'myImage1' 'myImage3' 'myImage2' ) asSet. 
	self assert: (self imageRepository imageNamed: 'myimage3') isLaunched
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testCreateImageWithDevFlagUsesDevImage [
	| template devTemplate |
	self addTemplateCategoryNamed: self defaultTemplateCategoryName.
	self addTemplateNamed: 'Pharo 9 64bit stable' inCategory: self defaultTemplateCategoryName.
	devTemplate := self addTemplateNamed: 'Pharo 10 64bit (development version, latest)' inCategory: self defaultTemplateCategoryName.
	context arguments: #('launcher' 'image' 'create' '--dev' 'myImage').
	
	template := context command findTemplate.
	 
	self assert: template equals: devTemplate
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testCreateImageWithNoFlagUsesDefaultImage [
	| template stableTemplate |
	self addTemplateCategoryNamed: self defaultTemplateCategoryName.
	stableTemplate := self addTemplateNamed: 'Pharo 9 64bit stable' inCategory: self defaultTemplateCategoryName.
	self addTemplateNamed: 'Pharo 10 64bit (development version)' inCategory: self defaultTemplateCategoryName.
	context arguments: {'launcher' . 'image' . 'create' . 'myImage'}.
	
	template := context command findTemplate.
	 
	self assert: template equals: stableTemplate
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testCreateImageWithNoFlagUsesUserDefaultImageWhenSpecified [
	| template devTemplate |

	context pharoLauncherModel configuration: 
		(context pharoLauncherModel configuration
			defaultTemplate: #dev;
			yourself).
	self addTemplateCategoryNamed: self defaultTemplateCategoryName.
	self addTemplateNamed: 'Pharo 9 64bit stable' inCategory: self defaultTemplateCategoryName.
	devTemplate := self addTemplateNamed: 'Pharo 10 64bit (development version, latest)' inCategory: self defaultTemplateCategoryName.
	context arguments: {'launcher' . 'image' . 'create' . 'myImage'}.
	
	template := context command findTemplate.
	 
	self assert: template equals: devTemplate
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testCreateImageWithNoLaunchFlagShouldNotLaunchImage [
	self addLocalTemplateNamed: 'fakeTemplate'.
	
	self runCommand: {'launcher' . 'image' . 'create' . 'myImage' . '--no-launch' . '--templateName'. 'fakeTemplate' . '--templateCategory' . self templateRepository localTemplatesGroupName}.
	 
	self assertSuccess.  
	self deny: (self imageRepository imageNamed: 'myimage') isLaunched
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testCreateImageWithTooManyArgumentShouldRaiseError [

	self addImageNamed: 'myImage1'.
	self addImageNamed: 'myImage2'.
	self addTemplateCategoryNamed: self defaultTemplateCategoryName.
	self addTemplateNamed: 'fakeTemplate' inCategory: self defaultTemplateCategoryName.
	self addTemplateNamed: 'Pharo 9 64bit stable' inCategory: self defaultTemplateCategoryName.
	
	self runCommand: {'launcher' . 'image' . 'create' . 'myImage3' . 'templateName' . 'tooManyArguments'}.	 
	
	self assertFailure.
	"standard err stream should include error message for trailing unknown argument."
	self assert: (self errorString includesSubstring: 'tooManyArguments').
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testCreateImageWithWrongTemplateNameShouldGiveErrorMessage [

	self addImageNamed: 'myImage1'.
	self addImageNamed: 'myImage2'.
	self addTemplateCategoryNamed: self defaultTemplateCategoryName.
	
	self runCommand: #('launcher' 'image' 'create' 'myImage3' '--templateName' 'aRandomTemplateName').
	self assertFailure.
		"standard err stream should include error message for unknown template."
	self assert: (self errorString includesSubstring: 'aRandomTemplateName not found')
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testCreateImageWithoutImageNameShouldGiveError [
		
	self runCommand: {'launcher' . 'image' . 'create' }.
	 
	self assertFailure.
	"standard err stream should include error message for missing image name."
	self assert: (self errorString includesSubstring: 'specify the name for the new Pharo image')
	
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testCreateImageWithoutTemplateArgumentShouldSucceed [
	self addImageNamed: 'myImage1'.
	self addImageNamed: 'myImage2'.
	self addTemplateCategoryNamed: self defaultTemplateCategoryName.
	self addTemplateNamed: 'fakeTemplate' inCategory: self defaultTemplateCategoryName.
	self addTemplateNamed: 'Pharo 9 64bit stable' inCategory: self defaultTemplateCategoryName.
	
	self runCommand: {'launcher' . 'image' . 'create' . 'myImage3' }.
	 
	self assertSuccess.  
	self assert: self imageRepository imagesName equals: #( 'myImage1' 'myImage3' 'myImage2' ) asSet. 
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testCreateImageWrongCategoryNameShouldRaiseError [

	self addImageNamed: 'myImage1'.
	self addImageNamed: 'myImage2'.
	self addLocalTemplateNamed: 'fakeTemplate'.
	
	self runCommand: {'launcher' . 'image' . 'create' . 'myImage3' . '--templateName'. 'fakeTemplate' . '--templateCategory' . 'wrong category name'}.
	self assertFailure.
	 
	self assert: (self errorString includesSubstring: 'wrong category name not found'). 
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testTemplateCanBeFoundByShortName [

	| createdTemplate foundTemplate |

	self addTemplateCategoryNamed: self defaultTemplateCategoryName.
	createdTemplate := self addTemplateNamed: 'fakeTemplate' shortName: 'foo' inCategory: self defaultTemplateCategoryName.
	context arguments: {'launcher' . 'image' . 'create' . 'myImage3' . '--templateName'. 'foo' }.
	context match.
	
	foundTemplate := context command findUserTemplate.
	
	self assert: foundTemplate equals: createdTemplate
]

{ #category : #tests }
PhLImageCreateCliCommandTest >> testTemplateIsFirstSearchByName [

	| createdTemplate foundTemplate |

	self addTemplateCategoryNamed: self defaultTemplateCategoryName.
	createdTemplate := self addTemplateNamed: 'fakeTemplate' shortName: 'foo' inCategory: self defaultTemplateCategoryName.
	self addTemplateNamed: 'foo' inCategory: self defaultTemplateCategoryName.
	context arguments: {'launcher' . 'image' . 'create' . 'myImage3' . '--templateName'. 'fakeTemplate' }.
	context match.
	
	foundTemplate := context command findUserTemplate.
	
	self assert: foundTemplate equals: createdTemplate
]
