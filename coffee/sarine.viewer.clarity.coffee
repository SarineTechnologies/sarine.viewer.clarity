###!
sarine.viewer.clarity - v0.1.0 -  Tuesday, November 14th, 2017, 5:23:39 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###
class Clarity extends Viewer
	
	defaultDragText = "Drag Me To Compare"
	iconCss = null
	plottingImage = ""
	diamondImage = ""
	baseUrl = ""
	dragText = ""
	constructor: (options) -> 		
		
		super(options)	
		# get from config the drag icon color
		clarityConfig = (window.configuration.experiences.filter((i)-> return i.atom == 'clarityView'))[0]		
		iconCss = if clarityConfig.iconCss then clarityConfig.iconCss else "default-theme"
		
		#get drag text from reource data
		dragText = options.element.data().dataDragText

		if (dragText == "")
			dragText = defaultDragText

		# external resources - 2 images
		plottingImage = stones[0].viewers.resources["clarityMeshFinalPlottingImage"] 
		if (!plottingImage)
			plottingImage = ""

		diamondImage = stones[0].viewers.resources["clarityDiamondImage"]
		if (!diamondImage)
			diamondImage = ""

		baseUrl = options.baseUrl + "atomic/v1/assets/"
	convertElement : () ->
		@element		

	first_init : ()->
		defer = $.Deferred()
		_t = @

		if (plottingImage && diamondImage)
			_t.loadImage(plottingImage).then((img)->
				imageElement = $(img)
				if(!imageElement.hasClass('no_stone'))
					_t.element.append("<div class=\'cq-beforeafter\'>
											<img class='cq-beforeafter-img' src='#{plottingImage}'>
											<div class='cq-beforeafter-resize'>
												<img class='cq-beforeafter-img' src='#{diamondImage}'>
											</div>
											<span class='cq-beforeafter-handle'>
												<i class='entypo-icon entypo-icon-code #{iconCss}' title='#{dragText}'>
													<svg version='1.1' xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24'>
														<path d='M14.578 16.594l4.641-4.594-4.641-4.594 1.406-1.406 6 6-6 6zM9.422 16.594l-1.406 1.406-6-6 6-6 1.406 1.406-4.641 4.594z'></path>
													</svg>
												</i> 
											</span>
										</div>")
					# load plugin assets
					assets = [
						{element:'script',src:baseUrl + 'tooltipster/jquery.tooltipster.min.js'},
						{element:'script',src:baseUrl + 'beforeafter/jquery.mobile.custom.min.js'},
						{element:'link',src:baseUrl + 'beforeafter/style.css'},
						{element:'link',src:baseUrl + 'tooltipster/tooltipster.css'}
					]
					
					_t.loadAssets(assets,()->
						beforeAfter = [{element:'script',src:baseUrl + 'beforeafter/sarine.init.min.js'}]
						_t.loadAssets(beforeAfter,()->
							$(".cq-beforeafter i").tooltipster('hide')
							defer.resolve(_t)
						)
					)
					
				else
					@loadNoStoneImage(_t)
					defer.resolve(_t)
			)
		else
			@loadNoStoneImage(_t)
			defer.resolve(_t)

		defer

	full_init : ()-> 
		defer = $.Deferred()
		if(@element.find('.no_stone').length > 0)				
			# notify the parent there are no assets - for hiding the buttons navigation for example
			@element.trigger('noStone')
		defer.resolve(@)
		defer
	play : () -> return		
	stop : () -> return
	loadNoStoneImage : (_t)->
		_t.loadImage(_t.callbackPic).then (img)->
			canvas = $("<canvas >")
			canvas.attr({"class": "no_stone" ,"width": img.width, "height": img.height}) 
			canvas[0].getContext("2d").drawImage(img, 0, 0, img.width, img.height)
			_t.element.append(canvas)

@Clarity = Clarity
		
