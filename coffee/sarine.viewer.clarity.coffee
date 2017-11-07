###!
sarine.viewer.clarity - v0.1.0 -  Tuesday, November 7th, 2017, 6:29:00 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###
class Clarity extends Viewer
	
	constructor: (options) -> 			
		super(options)		
		{@imagesArr, @borderRadius} = options	   	 	

	convertElement : () ->				
		@element		

	first_init : ()->
		alert("first init")
		defer = $.Deferred()				
		defer.resolve(@)
		defer

	full_init : ()-> 
		alert("full init")
		defer = $.Deferred()				
		defer.resolve(@)
		defer
	play : () -> return		
	stop : () -> return	
@Clarity = Clarity
		
