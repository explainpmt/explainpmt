/*
 * Simplpan Admin Panel
 *
 * Copyright (c) 2011 Kasper Kismul
 *
 * http://themeforest.net/user/Kaasper/profile
 *
 * This file configures all the different jQuery scripts used in the Simplpan Admin Panel template. 
 *
 */

//-------------------------------------------------------------- */
// Inserts "v"'s for dropdowns before documment load
//-------------------------------------------------------------- */

// Inserts the "v" Icon
$("<span class='v'></span>").insertBefore("#userpanel ul.dropdown ul.subnav");
	
// Inserts the "v" Icon
$("<span class='v'></span>").insertAfter("ul#navigation.dropdown ul.subnav");

//-------------------------------------------------------------- */
// When document is loaded, load custom jQuery
//-------------------------------------------------------------- */

(function ($){
   $(document).ready(function() {

//-------------------------------------------------------------- */
//
// 	**** Graphs, Bars, Pie (Visualize) **** 
//
// 	For more information go to:
//	http://www.filamentgroup.com/lab/update_to_jquery_visualize_accessible_charts_with_html5_from_designing_with/
//
//-------------------------------------------------------------- */

	$('table.stats').each(function() {
		
		var $stats_table = $(this);

		// Gets width of box container
		if ($(this).parent('div').width() > "840") {	
			var $stats_width = "833";
		}
		else {
			var $stats_width = ($(this).parent('div').width()) - 100;
		}
		
		// If there is a tab, find the active
		if ($(this).parent().prev().children('ul.sorting').length) {
			
			// Sorting shortcut
			var $stats_sorting = $(this).parent().prev().children('ul.sorting');
			
			// Adds 
			$($stats_sorting).find('a').each(function() {
				
				// Finds the href and removes the #
				var $stats_type = $(this).attr('href').replace("#","");
				
				// If it active, then show it
				if ($(this).hasClass('active')) {
					

					if($stats_type == 'line' || $stats_type == 'pie') {		
						$($stats_table).hide().visualize({
							type: $stats_type,	// 'bar', 'area', 'pie', 'line'
							width: $stats_width,
							height: '240px',
							colors: ['#6fb9e8', '#ec8526', '#9dc453', '#ddd74c'],
							lineDots: 'double',
							interaction: true,
							multiHover: 15,
							tooltip: true,
							tooltiphtml: function(data) {
								var html ='';
								for(var i=0; i<data.point.length; i++){
									html += '<p class="stats_tooltip"><strong>'+data.point[i].value+'</strong> '+data.point[i].yLabels[0]+'</p>';
								}	
								return html;
							}
						}).addClass($stats_type);
					} else {
						$($stats_table).hide().visualize({
							type: $stats_type,	// 'bar', 'area', 'pie', 'line'
							width: $stats_width,
							height: '240px',
							colors: ['#6fb9e8', '#ec8526', '#9dc453', '#ddd74c']
						}).addClass($stats_type);
					};
					

				}
				
				// Else hide it
				else {
					
					if($stats_type == 'line' || $stats_type == 'pie') {		
						$($stats_table).hide().visualize({
							type: $stats_type,	// 'bar', 'area', 'pie', 'line'
							width: $stats_width,
							height: '240px',
							colors: ['#6fb9e8', '#ec8526', '#9dc453', '#ddd74c'],
							lineDots: 'double',
							interaction: true,
							multiHover: 15,
							tooltip: true,
							tooltiphtml: function(data) {
								var html ='';
								for(var i=0; i<data.point.length; i++){
									html += '<p class="stats_tooltip"><strong>'+data.point[i].value+'</strong> '+data.point[i].yLabels[0]+'</p>';
								}	
								return html;
							}
						}).hide().addClass($stats_type);
					} else {
						$($stats_table).hide().visualize({
							type: $stats_type,	// 'bar', 'area', 'pie', 'line'
							width: $stats_width,
							height: '240px',
							colors: ['#6fb9e8', '#ec8526', '#9dc453', '#ddd74c']
						}).hide().addClass($stats_type);
					};
					
				};
				
			});

			// When one of the tabs are clicked
			$($stats_sorting).children().children('a').click(function(){
				
				// The href without #
				var $stats_sorting_type = "." + $(this).attr('href').replace("#","");
				
				// Hides all
				$($stats_table).parent().find(".visualize").hide();
				
				// Fades inn the one thats clicked
				$($stats_table).parent().find($stats_sorting_type).fadeIn('slow');
				
				// Removes 'active' class
				$($stats_sorting).children().children('a').removeClass('active');
				
				// Adds active state to the one you clicked
				$(this).addClass('active');
				return false; //Prevent the browser jump to the link anchor
			}); 
			
		}
		// If there is no tabs
		else {
			if ($(this).hasClass('bar')) {
				var $stats_type = 'bar';
			}
			else if ($(this).hasClass('line')) {
				var $stats_type = 'line';
			}
			else if ($(this).hasClass('pie')) {
				var $stats_type = 'pie';
			}
			else if ($(this).hasClass('area')) {
				var $stats_type = 'area';
			}
			else {
				// Default stats type
				var $stats_type = 'line';
			};
			
			if($stats_type == 'line' || $stats_type == 'pie') {		
						$($stats_table).hide().visualize({
							type: $stats_type,	// 'bar', 'area', 'pie', 'line'
							width: $stats_width,
							height: '240px',
							colors: ['#6fb9e8', '#ec8526', '#9dc453', '#ddd74c'],
							lineDots: 'double',
							interaction: true,
							multiHover: 15,
							tooltip: true,
							tooltiphtml: function(data) {
								var html ='';
								for(var i=0; i<data.point.length; i++){
									html += '<p class="stats_tooltip"><strong>'+data.point[i].value+'</strong> '+data.point[i].yLabels[0]+'</p>';
								}	
								return html;
							}
						}).addClass($stats_type);
					} else {
						$($stats_table).hide().visualize({
							type: $stats_type,	// 'bar', 'area', 'pie', 'line'
							width: $stats_width,
							height: '240px',
							colors: ['#6fb9e8', '#ec8526', '#9dc453', '#ddd74c']
						}).addClass($stats_type);
				};
			
		};
		
	});
	
	/* IE Fix - Added in 1.1 */
	// Change inner color on mouseover intecation
	if(!$.browser.msie) { // IE is a bit slow, but is possible. Future versions may solve this problem
		var currentHoverPoint = null;
		// listen for hovering events
		$('table.stats')
			.bind('vizualizeOver',function(e,data){
				currentHoverPoint = data.point;
				$(data.point.elem).parents('table').trigger('visualizeRedraw');
			})
			.bind('vizualizeOut',function(e,data){
				currentHoverPoint = null;
				$(data.point.elem).parents('table').trigger('visualizeRedraw');
			});
	
		// Modify painting for hovering effect
		$('table.stats').bind('vizualizeBeforeDraw',function hoverBeforeDraw(e,data){
			if(currentHoverPoint) {
				var item,i,j,len = data.tableData.allItems.length;
				for(i=0;i<len;i+=1) { item = data.tableData.allItems[i];
					if(currentHoverPoint == item) {
						item.innerColor = item.color;
						// item.dotSize = item.dotSize*1.4;
						// item.dotInnerSize = item.dotInnerSize*1.4;
					}
				}
			}
		});
		
	};
	/* IE Fix End - Added in 1.1 */
	
//-------------------------------------------------------------- */
// Box Slider
//-------------------------------------------------------------- */

	// When top box is clicked, it slides up
	$(".box_top h2").click(function(){
		$(this).toggleClass("toggle_closed").parent().next().slideToggle("slow");
		return false; //Prevent the browser jump to the link anchor
	}); 

//-------------------------------------------------------------- */
//
// 	**** Accordion (jQuery UI) **** 
//
// 	For more information go to:
//	http://jqueryui.com/demos/
//
//-------------------------------------------------------------- */

	$( ".accordion" ).accordion();

//-------------------------------------------------------------- */
// Box Tabs
//-------------------------------------------------------------- */

	$('div.tabs').each(function() {
		

		var $tabs_name = $(this);
		
		// If there is a tab, find the active
		if ($(this).parent().prev().children('ul.sorting').length) {
			
			// Sorting shortcut
			var $tabs_tabs = $(this).parent().prev().children('ul.sorting');
			
			// If it active, then show it
			if ($($tabs_tabs).children().children('a').hasClass('active')) {
					
				// Finds the href and removes the #
				var $stats_type = $($tabs_tabs).children().find('.active').attr('href');
					
				$($tabs_tabs).children().children('a').each(function() {
					var $tab_names = $(this).attr('href');
					// Hides all
					$($tabs_name).find($tab_names).hide();
				});
					
				$($tabs_name).find($stats_type).show();
			};
	
			// When one of the tabs are clicked
			$($tabs_tabs).children().children('a').click(function(){
				
				$($tabs_tabs).children().children('a').each(function() {
					var $tab_names = $(this).attr('href');
					// Hides all
					$($tabs_name).find($tab_names).hide();
				});
				
				// The href without #
				var $tabs_tabs_type = $(this).attr('href');
				
				// Fades inn the one thats clicked
				$($tabs_name).parent().find($tabs_tabs_type).fadeIn('slow');
				
				// Removes 'active' class
				$($tabs_tabs).children().children('a').removeClass('active');
				
				// Adds active state to the one you clicked
				$(this).addClass('active');
				return false; //Prevent the browser jump to the link anchor
			}); 
		};	
		
	});

//-------------------------------------------------------------- */
//
// 	**** Table Sorting (DataTables) **** 
//
// 	For more information go to:
//	http://www.datatables.net/
//
//-------------------------------------------------------------- */

	// Table Sorting with every feature (search, pagination..)
	$('table.sorting').dataTable( {
		"sPaginationType": "full_numbers",
		"bAutoWidth": false
	} );
	
	// Table Sorting with only pagination
	$('table.simple_sorting').dataTable( {
		"sPaginationType": "full_numbers",
		"bFilter": false,
		"bLengthChange": false,
		"bSort": false,
		"bSortClasses": false,
		"bAutoWidth": false
	} );
	
	// Removes sorting information if there are table actions due to space issues
	if ($('.table_actions')) {
		$('.table_actions').each(function() {
			$(this).parent().find('.dataTables_info').hide();
		});	
	};

//-------------------------------------------------------------- */
//
// 	**** Popups (Facebox) **** 
//
// 	For more information go to:
//	http://defunkt.io/facebox/
//
//-------------------------------------------------------------- */

	$('.popup').facebox();

//-------------------------------------------------------------- */
//
// 	**** Tips (Poshytip) **** 
//
// 	For more information go to:
//	http://vadikom.com/demos/poshytip/
//
//-------------------------------------------------------------- */

	// Tip for home icon etc.
	$('.tip').poshytip({
		className: 'tip-theme',
		showTimeout: 1,
		alignTo: 'target',
		alignX: 'center',
		alignY: 'bottom',
		offsetX: 0,
		offsetY: 16,
		allowTipHover: false,
		fade: false,
		slide: false
	});
	
	// Tip that stays
	$('.tip-stay').poshytip({
		className: 'tip-theme',
		showOn:'focus',
		showTimeout: 1,
		alignTo: 'target',
		alignX: 'center',
		alignY: 'bottom',
		offsetX: 0,
		offsetY: 16,
		allowTipHover: false,
		fade: false,
		slide: false
	});

//-------------------------------------------------------------- */
// Removal of notice boxes when pressed
//-------------------------------------------------------------- */

	// When notice box is clicked
	$("div.notice, p.error, p.warning, p.info, p.note, p.success").click(function() { 
		$(this).fadeOut('slow');
	});   

//-------------------------------------------------------------- */
//
// 	**** Datepicker (jQuery UI) **** 
//
// 	For more information go to:
//	http://jqueryui.com/demos/
//
//-------------------------------------------------------------- */
	
	// Select date
	$("input.date").datepicker();
	
	// Inline date
	$(".inlinedate").datepicker();

//-------------------------------------------------------------- */
// Validation
//-------------------------------------------------------------- */

	// Validator function
	function validation(){

		// Does the validation on blur (when you go to off the input field)
		$(".validate").blur(function () {
			
			// If something is not typed, error icon
			if ($(this).val() === ""){
				$(this).removeClass("validate_success");
		    	$(this).addClass("validate_error");
		    	return false;
			}
			
			// If something is typed, success icon
			else {
				$(this).removeClass("validate_error");
		    	$(this).addClass("validate_success");
		    	return true;
			};
			
		});

	};

	// Calls the validator function when focusing on an input field
	$(".validate").focus(function () {
	      return validation();
	});
	

//-------------------------------------------------------------- */
// Drop Downs
//-------------------------------------------------------------- */

// User Panel Dropdown
	
	// When hovering over a ul element with "dropdown" class
	$("#userpanel ul.dropdown").hover(function() { 
	  
		// Sets the top text as active (the dropdown)
		$(this).find(".top").addClass("active");
		
		// Slides the "subnav" on hover
		$(this).find("ul.subnav").show();
		// Shows the white 'v'
		$(this).find("span.v").addClass("active");
	  
		// On hover off
		$(this).hover(function() {  
		}, function(){  
			
			// Hides the subnavigation when isn't on the "subnav" anymore
			$(this).find("ul.subnav").stop(false, true).hide(); 
			
			// Removes top text as active (the dropdown)
			$(this).find(".top").removeClass("active");
			
			// Hides the white 'v'
			$(this).find("span.v").removeClass("active");
		});  
	});  

// Navigation Dropdown

	// When hovering over a ul element with "dropdown" class
	$("ul#navigation.dropdown li.topnav").hover(function() { 
	
		// Copys the navigation name and the "v" icon to the top of the dropdown
		$(this).clone().prependTo("ul#navigation.dropdown .subnav");
		$("ul#navigation.dropdown .subnav .subnav").remove();	
		
		// Slides the "subnav" on hover
		$(this).find("ul.subnav").show();
		
		// On hover off
		$("ul#navigation.dropdown ul.subnav").parent().hover(function() {  
		}, function(){  
			
			// Hides the subnavigation when isn't on the "subnav" anymore
			$(this).find("ul.subnav").stop(false, true).hide(); 
			
			// Removes the top part to prevent duplication
			$("ul#navigation.dropdown .subnav .topnav").remove();
		});  
	});  
 
//-------------------------------------------------------------- */
// Gallery Actions
//-------------------------------------------------------------- */

	function galleryActions(){
		// When hovering over gallery li element
		$("ul.gallery li").hover(function() { 
		  
			var $image = (this);
			
			// Shows actions when hovering
			$(this).find(".actions").show();
			
			// If the "x" icon is pressed, show confirmation (#dialog-confirm)
			$(this).find(".actions .delete").click(function () {
				
				// Confirmation
				$( "#dialog-confirm" ).dialog({
					resizable: false,
					modal: true,
					minHeight: 0,
					draggable: false,
					buttons: {
						"Delete": function() {
							$( this ).dialog( "close" );
							
							// Removes image if delete is pressed
							$($image).fadeOut('slow', function() { 
								$($image).remove(); 
							});
							
						},
						
						// Removes dialog if cancel is pressed
						Cancel: function() {
							$( this ).dialog( "close" );
						}
					}
				});
				
				return false;
		    });

			
			// Changes opacity of the image
			$(this).find("img").css("opacity","0.5");
		  
			// On hover off
			$(this).hover(function() {  
			}, function(){  
				
				// Hides actions when hovering off
				$(this).find(".actions").hide();
				
				// Changes opacity of the image back to normal
				$(this).find("img").css("opacity","1");
				
			});  
		}); 
		
	};
	
	galleryActions();

//-------------------------------------------------------------- */
//
// 	**** Gallery Sorting (Quicksand) **** 
//
// 	For more information go to:
//	http://razorjack.net/quicksand/
//
//-------------------------------------------------------------- */

$('ul.gallery').each(function() {

	  // get the action filter option item on page load
	  var $fileringType = $("ul.sorting li.active a[data-type]").first().before(this);
	  var $filterType = $($fileringType).attr('data-id');
	  
	  var $gallerySorting = $(this).parent().prev().children('ul.sorting');
		
	  // get and assign the ourHolder element to the
	  // $holder varible for use later
	  var $holder = $(this);
	
	  // clone all items within the pre-assigned $holder element
	  var $data = $holder.clone();
	
	  // attempt to call Quicksand when a filter option
	  // item is clicked
	  $($gallerySorting).find("a[data-type]").click(function(e) {
	    // reset the active class on all the buttons
	    $($gallerySorting).find("a[data-type].active").removeClass('active');
	
	    // assign the class of the clicked filter option
	    // element to our $filterType variable
	    var $filterType = $(this).attr('data-type');
	    $(this).addClass('active');
	    if ($filterType == 'all') {
	      // assign all li items to the $filteredData var when
	      // the 'All' filter option is clicked
	      var $filteredData = $data.find('li');
	    }
	    else {
	      // find all li elements that have our required $filterType
	      // values for the data-type element
	      var $filteredData = $data.find('li[data-type=' + $filterType + ']');
	    }
	
	    // call quicksand and assign transition parameters
	    $holder.quicksand($filteredData, {
	    	duration: 800,
	    	easing: 'easeInOutQuad',
	    	useScaling: true,
	    	adjustHeight: 'auto'
	    }, function() { 
	    	// callback gallery actions
	    	$('.popup').facebox();
	    	galleryActions();
	  	});
	  	
	    return false;
	  });
  
  });


//-------------------------------------------------------------- */
//
// 	**** Wysiwyg (jWYSIWYG) **** 
//
// 	For more information go to:
//	http://plugins.jquery.com/project/jWYSIWYG
//
//-------------------------------------------------------------- */

$(".wysiwyg").wysiwyg();

//-------------------------------------------------------------- */
//
// 	**** Form Elements (uniform) **** 
//
// 	For more information go to:
//	http://uniformjs.com/
//
//-------------------------------------------------------------- */

$(".box_content select, .box_content input:checkbox, .box_content input:radio, .box_content input:file, .box_content button").uniform();

//-------------------------------------------------------------- */
// Check all checkboxes
//-------------------------------------------------------------- */

	$('.checkall').click(function () {
		var checkall =$(this).parents('.box_content:eq(0)').find(':checkbox').attr('checked', this.checked);
		$.uniform.update(checkall);
	});


// End jQuery
   });
})(jQuery);

//-------------------------------------------------------------- */
//
// 	**** Syntax Highlight (SyntaxHighlighter) **** 
//
// 	For more information go to:
//	http://code.google.com/p/syntaxhighlighter/
//
//-------------------------------------------------------------- */

dp.SyntaxHighlighter.ClipboardSwf = 'syntaxHighlighter/clipboard.swf';
dp.SyntaxHighlighter.HighlightAll('code');