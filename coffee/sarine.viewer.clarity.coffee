
class Clarity extends Viewer
	
	clarityConfig = null
	defaultDragText = "Drag Me To Compare"
	iconCss = null
	type = null
	plottingImage = ""
	diamondImage = ""
	markingSvg = ""
	baseUrl = ""
	dragText = ""
	
	constructor: (options) -> 		
		super(options)	
		
		@atomVersion = options.atomVersion
		@clarityTimeoutIds = {
			left : null,
			right : null,
			mid : null
		}
		# get from config the drag icon color
		configArray = window.configuration.experiences.filter((i)-> return i.atom == 'clarityView')		
		if (configArray.length != 0)
			clarityConfig = configArray[0]
		
		iconCss = if clarityConfig? and clarityConfig.iconCss then clarityConfig.iconCss else "default-theme"
		type = if clarityConfig? and clarityConfig.type then clarityConfig.type else "accurate"
		
		#get drag text from reource data
		dragText = options.element.data().dataDragText

		if (dragText == "" || dragText == undefined)
			dragText = defaultDragText

		# external resources - 2 images + svg
		if type == 'halo'
			markingSvg = stones[0].viewers.resources["clarityHaloMarkingSVG"]
			plottingImage = stones[0].viewers.resources['clarityDiamondImageDark']
		else 
			markingSvg = stones[0].viewers.resources["clarityAccurateMarkingSVG"]
			plottingImage = if markingSvg then stones[0].viewers.resources['clarityMeshImage'] else stones[0].viewers.resources['clarityMeshFinalPlottingImage']
		
		diamondImage = stones[0].viewers.resources["clarityDiamondImage"]
		
		if (!diamondImage)
			diamondImage = ""		
		if (!markingSvg)
			markingSvg = ""
		if (!plottingImage)
			plottingImage = ""		

		baseUrl = options.baseUrl + "atomic/v1/assets/"
	convertElement : () ->
		@element		

	first_init : ()->
		defer = $.Deferred()
		_t = @

		if (plottingImage && diamondImage && (type == "halo" && markingSvg || type == "accurate"))
			_t.loadImage(plottingImage).then((img)->
				imageElement = $(img)
				if(!imageElement.hasClass('no_stone'))
					_t.element.append("<div class=\'cq-beforeafter\'>
											<img class='cq-beforeafter-img' src='#{diamondImage}'>
											<div class='cq-beforeafter-resize'>
												<img class='cq-beforeafter-img' src='#{plottingImage}'>											
											</div>
											<span class='cq-beforeafter-handle'>
												<i class='entypo-icon entypo-icon-code #{iconCss}' title='#{dragText}'>
													<svg version='1.1' xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24'>
														<path d='M14.578 16.594l4.641-4.594-4.641-4.594 1.406-1.406 6 6-6 6zM9.422 16.594l-1.406 1.406-6-6 6-6 1.406 1.406-4.641 4.594z'></path>
													</svg>
												</i> 
											</span>
										</div>")
					
					if (markingSvg)
						$('.cq-beforeafter-resize').append $('<div>')
						$('.cq-beforeafter-resize div').load markingSvg, (svg)->
							$('.cq-beforeafter-resize svg').css
								'position': 'absolute'
								'top': 0
							$('.cq-beforeafter-resize svg g').attr
								'fill': if clarityConfig? and clarityConfig.fillcolor then clarityConfig.fillcolor else "IndianRed",
								'fill-opacity': if clarityConfig? and clarityConfig.filltransparency then clarityConfig.filltransparency else "0.3",
								'stroke': if clarityConfig? and clarityConfig.bordercolor then clarityConfig.bordercolor else "Yellow",
								'stroke-width': if clarityConfig? and clarityConfig.borderwidth then clarityConfig.borderwidth else "1",								
								'stroke-opacity': if clarityConfig? and clarityConfig.bordertransparency then clarityConfig.bordertransparency else "0.2"
							
							_t.loadPluginAssets(_t, defer)	
					else
						_t.loadPluginAssets(_t, defer)					
				else
					_t.loadNoStoneImage(_t)
					defer.resolve(_t)
			)
		else
			_t.loadNoStoneImage(_t)
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
		
		return
	loadPluginAssets : (_t, defer)->
		# load plugin assets
		assets = [
			{element:'script',src:baseUrl + 'tooltipster/jquery.tooltipster.min.js'},
			{element:'script',src:baseUrl + 'beforeafter/jquery.mobile.custom.min.js'},
			{element:'link',src:baseUrl + 'beforeafter/style.css'},
			{element:'link',src:baseUrl + 'tooltipster/tooltipster.css'}
		]
		
		_t.loadAssets(assets,()->
			beforeAfter = [{element:'script',src:baseUrl + 'clarity/sarine.init.min.js'}]
			_t.loadAssets(beforeAfter,()->
				# Hide the tool tip on load, in widget it causes display issue.
				# $(".cq-beforeafter i").tooltipster('hide')
				$(".tooltipster-base").hide()							

				# register events for external use (widget, viewer creator..)
				_t.registerAnimateEvent(_t)
				_t.registerAutoAnimateEvent(_t)
				_t.registerClearAnimationEvent(_t)
				_t.registerDraggingEvent(_t)
				defer.resolve(_t)
			,_t.atomVersion
			)
		)

		return
	# allow animation of the atom for a specified position
	registerAnimateEvent:(_t)->
		$curElement = $('.viewer.clarityView')
		$imageContainer = $curElement.find('.cq-beforeafter')

		$curElement.on("animateClarity",(event,data) ->
			positionToAnimate = 0
		
			switch data.direction
				when "left" then positionToAnimate = 0
				when "middle" then positionToAnimate = $imageContainer.width() / 2
				when "right" then positionToAnimate = $imageContainer.width()

			_t.animateAtom(positionToAnimate,data.speed,false,$curElement)
		)

		return
	# dragging events - when drag accrues, when you get the the edges and middle.
	registerDraggingEvent:(_t)->
		$curElement = _t.element
		$imageContainer = $curElement.find('.cq-beforeafter')

		# all these events are triggered by the plugin
		$imageContainer.on("dragging",()->
			$curElement.trigger('dragging')
		)
		
		$imageContainer.on("leftEdge",()->
			$curElement.trigger('leftEdge')
		)

		$imageContainer.on("rightEdge",()->
			$curElement.trigger('rightEdge')
		)

		$imageContainer.on("middle",()->
			$curElement.trigger('middle')
		)

		return
	# auto animate the atom to the left, right and mid
	registerAutoAnimateEvent:(_t)->
		$curElement = $('.viewer.clarityView')
		$imageContainer = $curElement.find(".cq-beforeafter")

		$curElement.on("autoAnimateClarity",() ->
			_t.clarityTimeoutIds.right = setTimeout(()->
				_t.animateAtom($imageContainer.width(),800,true,$curElement,()-> # move to the right
					$curElement.trigger('rightEdge')
					_t.clarityTimeoutIds.left = setTimeout(()->
						_t.animateAtom(0,500,true,$curElement,()-> # move to the left
							$curElement.trigger('leftEdge')
							_t.clarityTimeoutIds.mid = setTimeout(()->
								_t.animateAtom($imageContainer.width() / 2,250,true,$curElement,() -> # move to the middle
									setTimeout(() ->
										_t.clearTimeoutsEvents()
										$curElement.trigger('middle')
										return
									, 500)
								)
								return
							,500)
							return
						)
						return
					,1000)
					return
				)
				return
			,1000)
			return
		)

		return

	registerClearAnimationEvent:()->
		# Clear all animations / tooltips
		_t = @
		$curElement = _t.element

		$curElement.on("updateTooltip",(event,action) ->
			$tooltip = $curElement.find("i")
			if($tooltip)
				$tooltip.tooltipster(action)
		)

		return

	clearTimeoutsEvents: () ->
		_t = @
		$curElement = _t.element
		# Stop any animation in prograss
		$curElement.find('.cq-beforeafter .cq-beforeafter-handle').finish()
		clearTimeout(_t.clarityTimeoutIds.left)
		clearTimeout(_t.clarityTimeoutIds.right)
		clearTimeout(_t.clarityTimeoutIds.mid)
		# Prevent the tooltip from appearing when on other experiences
		$curElement.find(".cq-beforeafter i").tooltipster('hide')
		return

	# Excecute the animation
	animateAtom:(position,duration,isAutoAnimate,$element,completeCallback)->
		$tooltip = $element.find("i")
		$handle = $element.find(".cq-beforeafter-handle")
		$resize = $element.find('.cq-beforeafter-resize')

		$handle.animate({
			'left': position},{
			duration: duration,
			step: (now)->
				$resize.css('width', now)
				if($tooltip and isAutoAnimate)
					$tooltip.tooltipster('reposition')
					$(".tooltipster-base").show()
					$tooltip.tooltipster('show')
			,
			complete:completeCallback})
		
		return

@Clarity = Clarity
		
