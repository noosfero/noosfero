/*The easing code was provided by George Smith. Please check out his site
as without him this would look really horrible!
http://gsgd.co.uk/sandbox/jquery/easing/
*/

jQuery.easing.jswing = jQuery.swing;
jQuery.extend( jQuery.easing,
{
	def: 'easeOutCubic',
	swing: function (x, t, b, c, d) {
		return jQuery.easing[jQuery.easing.def](x, t, b, c, d);
	},
	easeOutCubic: function (x, t, b, c, d) {
		return c*((t=t/d-1)*t*t + 1) + b;
	}
});

/*     
	12/20/08
	SliderJS
	Jquery plugin for smooth and pretty sliding divs
	Copyright (C) 2008 Jeremy Fry

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


jQuery.iSliderJS = {
	build : function(user_options)
	{
		var defaults = {
			direction:"horizontal",
			list_width: 6740,
			window_width: 500,
			window_height: 350,
			pikachoose: false
		};
		return $(this).each(function(){
			//declare variables. God knows I've missed half of them I'll use
			var options = $.extend(defaults, user_options); 
			var acceleration = 0;
			var initx = 0; //intial
			var inity = 0;
			var movex = [];
			var downtime = 0;
				
			//wrap the list in a sliderjs div.
			$(this).wrap("<div class='sliderjs'></div>");
			var $sliderul = $(this);
			var $sliderjs = $(this).parent("<div>");
			var divcss = {
				width: options.window_width+"px",
				height: options.window_height+"px",
				overflow:"hidden",
				position:"relative"
			};
			var ulcss = {
				position: "relative",
				width: options.list_width+"px"
			};
			$sliderjs.css(divcss);
			$sliderul.css(ulcss);
			//TODO:add a scroll bar and buttons maybe.
			if($.browser.msie){
				//$sliderjs.children().mousedown(function(){ return true;});
				$sliderul.children().mousedown(function(){
				return false;});
				$sliderul.children().children().mousedown(function(){
				return false;});
			}
			
			//mouse fucntions for tosses
			$sliderjs.bind('selectstart', function() {
                    return false;
                });
			$sliderjs.bind("mousedown", function(e){
				$sliderul.stop();
				$sliderul.dequeue();
				movex.splice(0);
				initx = e.pageX;
				var date = new Date();
				downtime = date.getTime();
				var xlen = 0;
				var ulinitx =  $sliderul.position().left;
				$().bind("mousemove", function(e){
					//track the mouse movements
					//duplicates cause some issues. Though moving only one direction would
					//cause this. it tends to be unintentional
					if(movex[xlen-1]!=e.pageX){
						xlen = movex.push(e.pageX);
					}
					
					//keep trimming our array
					if(xlen>10){
						movex.splice(0,6);
						xlen = movex.push(e.pageX);
					}
					
					//track direction of last three movements. if directions changes reset time
					if(movex.length>3){
						if((movex[xlen-3]>=movex[xlen-2]) &&(movex[xlen-2]>=movex[xlen-1])){
						}else if((movex[xlen-3]<=movex[xlen-2]) &&(movex[xlen-2]<=movex[xlen-1])){
						}else{
							//if we made it here the user has changed direction so now we need to reset the time
							//downtime = date.getTime();
						}
					}
					
					//move the list around well the mouse is pressed
					var newleft = parseInt(ulinitx, 10)+parseInt((e.pageX-initx)/1.5, 10);
					if(newleft<((options.list_width*-1)+parseInt(options.window_width, 10)-50)){
						newleft=((options.list_width*-1)+parseInt(options.window_width, 10)-50);
					}
					if(newleft>50){newleft=50;}
					//$('.pika_navigation').html(newleft);
					$sliderul.css("left",newleft+"px");
				});
				$().bind("mouseup", MeatAndPatatos);
				return false;
			});
				
			function Animate(xvalue){
				$sliderul.stop();
				$sliderul.dequeue();
				$sliderul.animate({
					left:xvalue+"px"
				},1500,"easeOutCubic");
			}
			
			//TODO: find a better name for this func... nevermind I like it
			function MeatAndPatatos(e){
				$().unbind("mousemove");
				$().unbind("mouseup", MeatAndPatatos);
				var date = new Date();
				var uptime = date.getTime();
				
				//calculate velocity... did math class just pay off?
				var velocity = (movex[movex.length-1]*100-movex[movex.length-2]*100)/(uptime-downtime);
				var distance = movex[movex.length-1]-movex[movex.length-2];
				var negative = 1;
				//they're both negative when they get multiplied together we're going to end up with a positive
				if(distance<0){
					negative = -1;
				}
				var ulinitx =  $sliderul.position().left;
				var animateleft =  parseInt(ulinitx, 10)+(velocity * distance * negative)/2;
				if(animateleft<(options.list_width*-1)+parseInt(options.window_width, 10)){
					animateleft=(options.list_width*-1)+parseInt(options.window_width, 10);
				}
				//alert(animateleft);
				if(animateleft>0){animateleft=0;}
				//now that we have velocity figure out the distance to go and the time
				if(isNaN(animateleft)){}else{
					Animate(animateleft);
				}
				
			}
			
			

			function MoveToLi(){
				var pos = $(this).parent('li').position();
				var width = $(this).css("width").slice(0,-2);
				var lileft = pos.left;
				var liright = parseInt(pos.left, 10)+parseInt(width, 10);
				var ulleft = $sliderul.position().left;
				//find out if the li is inside the viewable area
				//first find range of viewable values
				var low = ulleft*-1;
				var high = low+options.window_width;
				//is my li in that?
				if((lileft>=low)&&(liright<=high)){
					//viewable we're gravy
					return;
				}else{
					//uh oh! not viewable lets slide
					//find how far outside view we are
					var slide =0;
					if(lileft<low){
						//i know it seems like we should subtract.. however we have
						//negatives people! (I'm really writing this for me so I don't change
						//it later. :(
						slide = parseInt(lileft, 10)*-1;
					}else{
						slide = ((liright-high)*-1)+parseInt(ulleft, 10);
					}
					
					Animate(slide);
				}
			
			}
		
			if(options.pikachoose){
				var $lis = $sliderul.children('li');
				$lis.children().bind("click", MoveToLi);
				
			}
		});
		
	}
};
jQuery.fn.SliderJS = jQuery.iSliderJS.build;