###!
sarine.viewer.clarity - v0.1.0 -  Thursday, November 9th, 2017, 3:40:42 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###
class Clarity extends Viewer
	
	defaultDragText = "Drag Me To Compare"

	iconCss = null
	beforeImage = null
	afterImage = null
	baseUrl = ""
	dragText = ""
	constructor: (options) -> 		
		
		# for dev only
		stones[0].viewers.clarityView = {
			before : "https://static.pexels.com/photos/66997/pexels-photo-66997.jpeg",
			after : "https://static.pexels.com/photos/51373/utah-mountain-sky-nature-51373.jpeg"};

		super(options)	
		# get from config the drag icon color
		clarityConfig = (window.configuration.experiences.filter((i)-> return i.atom == 'clarityView'))[0]		
		iconCss = if clarityConfig.iconCss then clarityConfig.iconCss else "default-theme"
		
		#get drag text from reource data
		dragText = options.element.data().dataDragText

		if (dragText == "")
			dragText = defaultDragText

		# external resources - 2 images
		beforeImage = stones[0].viewers.clarityView.before
		afterImage = stones[0].viewers.clarityView.after
		baseUrl = options.baseUrl + "atomic/v1/assets/"
	convertElement : () ->
		@element		

	first_init : ()->
		defer = $.Deferred()
		_t = @

		@loadImage(beforeImage).then((img)->
			imageElement = $(img)
			if(!imageElement.hasClass('no_stone'))
				_t.element.append("<div class=\'cq-beforeafter\'>
										<img class='cq-beforeafter-img' src='#{beforeImage}'>
										<div class='cq-beforeafter-resize'>
											<img class='cq-beforeafter-img' src='#{afterImage}'>
										</div>
										<span class='cq-beforeafter-handle'>
											<i class='entypo-icon entypo-icon-code #{iconCss}' title='#{dragText}'></i> 
										</span>
									</div>")
				# load plugin assets
				assets = [
					{element:'script',src:baseUrl + 'tooltipster/jquery.tooltipster.min.js'},
					{element:'script',src:baseUrl + 'beforeafter/jquery.mobile.custom.min.js'},
					{element:'script',src:baseUrl + 'beforeafter/init.min.js'},
					{element:'link',src:baseUrl + 'beforeafter/style.css'},
					{element:'link',src:baseUrl + 'tooltipster/tooltipster.css'}
				]
				
				_t.loadAssets(assets,()->defer.resolve(_t))
			else
				defer.resolve(_t)
		)

		defer

	full_init : ()-> 
		defer = $.Deferred()				
		defer.resolve(@)
		defer
	play : () -> return		
	stop : () -> return	
@Clarity = Clarity
		
