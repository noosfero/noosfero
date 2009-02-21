/**
 * jQuery (a)Slideshow plugin
 *
 * Copyright (c) 2008 Trent Foley
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * @author 	Anton Shevchuk AntonShevchuk@gmail.com
 * @version 0.5.5
 */
;(function($) {
    defaults  = {
        width:320,      // width in px
        height:240,     // height in px
        index:0,        // start from frame number N 
        time:3000,      // time out beetwen slides
        title:true,     // show title
        titleshow:false,// always show title
        panel:true,     // show controls panel
        play:false,     // play slideshow
        loop:true,
        effect:'fade',  // aviable fade, scrollUp/Down/Left/Right, zoom, zoomFade, growX, growY
        effecttime:1000,// aviable fast,slow,normal and any valid fx speed value
        filter:true,    // remove <br/>, empty <div>, <p> and other stuff
        nextclick:false,      // bind content click next slide
        playclick:false,      // bind content click play/stop
        playhover:false,      // bind content hover play/stop
        playhoverr:false,     // bind content hover stop/play (reverse of playhover)
        playframe:true,       // show frame "Play Now!"
        fullscreen:false,     // in full window size
        imgresize:false,      // resize image to slideshow window
        imgcenter:true,       // set image to center // TODO
        imgajax:true,         // load images from links
        linkajax:false,       // load html from links
        help:'Plugin homepage: <a href="http://slideshow.hohli.com">(a)Slideshow</a><br/>'+
                'Author homepage: <a href="http://anton.shevchuk.name">Anton Shevchuk</a>',

        controls :{         // show/hide controls elements
            'hide':true,    // show controls bar on mouse hover   
            'first':true,   // goto first frame
            'prev':true,    // goto previouse frame (if it first go to last)
            'play':true,    // play slideshow
            'next':true,    // goto next frame (if it last go to first)
            'last':true,    // goto last frame
            'help':true,    // show help message
            'counter':true  // show slide counter
        }
    };    
    /**
     * Create a new instance of slideshow.
     *
     * @classDescription	This class creates a new slideshow and manipulate it
     *
     * @return {Object}	Returns a new slideshow object.
     * @constructor	
     */
    $.fn.slideshow = function(settings) {

        var _slideshow = this;
        
		/*
		 * Construct
		 */
		this.each(function(){
		    
            var ext = $(this);
            
            this.playFlag = false;
            this.playId   = null;
            this.length   = 0;
            this.inited   = new Array();
            
            /**
             * Build Html
             * @method
             */
            this.build    = function () {
                var _self = this;
                
                ext.wrapInner('<div class="slideshow"><div class="slideshow-content"></div></div>');
                ext = ext.find('.slideshow');
                
                // filter content
                if (this.options.filter) {
                    ext.find('.slideshow-content > br').remove();
                    ext.find('.slideshow-content > p:empty').remove();
                    ext.find('.slideshow-content > div:empty').remove();                    
                }
                
                
                // fullscreen
                if (this.options.fullscreen) {
                    $('body').css({overflow:'hidden', padding:0});
                    
                    this.options.width  = $(window).width();
                    this.options.height = ($(window).height()>$(document).height())?$(window).height():$(document).height();
                    
//                    this.options.width  = this.options.width;
//                    this.options.height = this.options.height;
                    
                    ext.addClass('slideshow-fullscreen');
                }
                
                this.length = ext.find('.slideshow-content > *').length;
                
                // build title
                if (this.options.title) {
                    ext.prepend('<div class="slideshow-label-place"><div class="slideshow-label slideshow-opacity"></div></div>');
                    
                    if (!this.options.titleshow) {
                         ext.find('.slideshow-label-place').hover(function(){
                            $(this).find('.slideshow-label').fadeIn();
                        }, function() {
                            $(this).find('.slideshow-label').fadeOut();
                        });
                        ext.find('.slideshow-label').hide();
                    }
                    
                    
                    ext.find('.slideshow-label-place').css('width',  this.options.width);
                }
                
                // build panel
                if (this.options.panel) {
                    ext.append('<div class="slideshow-panel-place"><div class="slideshow-panel slideshow-opacity"></div></div>');
                    panel = ext.find('.slideshow-panel');
                    if (this.options.controls.first)
                        panel.append('<a class="first slideshowbutton" href="#first">First</a>');
                    
                    if (this.options.controls.prev)
                        panel.append('<a class="prev slideshowbutton"  href="#prev">Prev</a>');
                        
                    if (this.options.controls.play)
                        panel.append('<a class="play slideshowbutton"  href="#play">Play</a>');
                        
                    if (this.options.controls.next)
                        panel.append('<a class="next slideshowbutton"  href="#next">Next</a>');
                        
                    if (this.options.controls.last)
                        panel.append('<a class="last slideshowbutton"  href="#last">Last</a>');
                        
                    if (this.options.controls.help) {
                        panel.append('<a class="help slideshowbutton"  href="#help">Help</a>');
                        panel.prepend('<div class="slideshow-help">'+this.options.help+'</div>');   
                        
//                        panel.find('.slideshow-help').css('width',  this.options.width - 4  + 'px');
                    }
                    
                    
                    if (this.options.controls.counter) {
                        panel.append('<span class="counter">'+(this.options.index+1)+' / '+this.length+'</span>');
                    }
                
                    if (this.options.controls.hide) {
                        ext.find('.slideshow-panel-place').hover(function(){
                            $(this).find('.slideshow-panel').fadeIn();
                        }, function() {
                            $(this).find('.slideshow-panel').fadeOut();
                        });
                        panel.hide();
                    }
                    
                    
                    ext.find('.slideshow-panel-place').css('width',  this.options.width);
                }
                
                /**
                 * Set Size Options
                 */
                ext.css('width',    this.options.width + 'px');
//                    ext.css('height',   this.options.height + 'px');

                ext.find('.slideshow-content').css('width',  this.options.width);
                ext.find('.slideshow-content').css('height', this.options.height);
                
                /**
                 * Change children styles
                 */
                ext.find('.slideshow-content > *').each(function(){
                    _self._build($(this));
                });
                
                // init slide (replace by ajax etc)
                this.init(this.options.index);
                
                // hide all slides
                ext.find('.slideshow-content > *:not(:eq('+this.options.index+'))').hide();
                
                // show label
                this.label();
                
                // add playframe
                if (this.options.playframe) {
                    ext.find('.slideshow-content').append('<div class="slideshow-shadow slideshow-opacity"><div class="slideshow-frame"></div></div>');
                }
                
                // bind all events
                this.events();
                
                return true;
            };
            
            /**
             * Change CSS for every entity
             */
            this._build = function(el){            
                el.css({margin   :0,
                            position: 'absolute',
                            left: (this.options.width/2 - el.attr('width')/2),
                            top : (this.options.height/2 - el.attr('height')/2),
                            overflow:'hidden'
                            });
                
                if (el.is('img') && this.options.imgresize || el.is(':not(img)')){
                    el.css({width:'100%',height:'100%'});
                }
            };
                            
            /**
             * Bind Events
             */
            this.events = function() {
                
                var _self = this;
                
                /**
                 * Go to next slide on content click (optional)
                 */ 
                if (_self.options.nextclick)
                ext.find('.slideshow-content').click(function(){            
                    _self.stop();         
                    _self.next();
                    return false;
                });
                
                /**
                 * Goto first slide button
                 */ 
                if (this.options.controls.first)
                ext.find('a.first').click(function(){            
                    _self.stop();
                    _self.goSlide(0);
                    return false;
                });
                
                /**
                 * Goto previouse slide button
                 */ 
                if (this.options.controls.prev)
                ext.find('a.prev').click(function(){            
                    _self.stop();
                    _self.prev();
                    return false;
                });
                
                /**
                 * Play slideshow button
                 */ 
                if (this.options.controls.play)
                ext.find('a.play').click(function(){
                    if (_self.playFlag) {
                        _self.stop();
                    } else {
                        _self.play();
                    }
                    return false;
                });
        
                /**
                 * Goto next slide button
                 */ 
                if (this.options.controls.next)
                ext.find('a.next').click(function(){
                    _self.stop();         
                    _self.next();
                    return false;
                });
                
                /**
                 * Goto last slide button
                 */ 
                if (this.options.controls.last)
                ext.find('a.last').click(function(){
                    _self.stop();
                    _self.goSlide(_self.length-1);
                    return false;
                });
                
                /**
                 * Show help message
                 */ 
                if (this.options.controls.help)
                ext.find('a.help').click(function(){
                    _self.stop();
                    ext.find('.slideshow-help').slideToggle();
                    return false;
                });
                
                /**
                 * Show playframe
                 */
                if (this.options.playframe) 
                ext.find('.slideshow-frame').click(function(){
                    ext.find('.slideshow-frame').remove();
                    ext.find('.slideshow-shadow').remove();
                    
                    if (_self.options.playclick)
                        setTimeout(function(ms){ _self.play() }, _self.options.time);
                    return false;  
                });
                
                /**
                 * Play/stop on slideshow hover
                 */
                if (this.options.playhover)
                ext.hover(function(){
                    if (!_self.playFlag) {
                        _self.play();
                    }
                }, function(){
                    if (_self.playFlag) {
                        _self.stop();
                    }
                });
                
                
                /**
                 * Stop/Play on slideshow hover
                 */
                if (this.options.playhoverr)
                ext.hover(function(){
                    if (_self.playFlag) {
                        _self.stop();
                    }
                }, function(){
                    if (!_self.playFlag) {
                        _self.play();
                    }
                });
            };
            
            /**
             * Find and show label of slide
             * @method
             */
            this.label = function () {
                if (!this.options.title) return false;
                
                label = '';
                
                current = ext.find('.slideshow-content > *:eq('+this.options.index +')');
                
                if (current.attr('alt')) {
                    label = current.attr('alt');
                } else if (current.attr('title')) {
                    label = current.attr('title');
                }else if (current.find('label:first').length>0) {
                            current.find('label:first').hide();
                    label = current.find('label:first').html();
                }
                
                ext.find('.slideshow-label').html(label);
            };
            
            /**
             * Goto previous slide
             * @method
             */
            this.prev = function () {
                if (this.options.index == 0) {
                    i = (this.length-1);
                } else {
                    i = this.options.index - 1;
                }
    
                this.goSlide(i);
            };
                

            /**        
             * Play Slideshow
             * @method
             */
            this.play = function () {
                var _self = this;     
                this.playFlag = true;
                this.playId = setTimeout(function(ms){ _self._play() }, this.options.time);
                ext.find('a.play').addClass('stop');
            };
            
            /**        
             * Play Slideshow
             * @method
             */
            this._play = function () {  
                var _self = this;     
                this.next();
                if (this.playFlag) {
                    if (this.options.index == (this.length-1) && !this.options.loop) { this.stop();return false; }
                    this.playId = setTimeout(function(ms){ _self._play() }, this.options.time);
                }    
            };
            
            /**
             * Stop Slideshow
             * @method
             */
            this.stop = function () {            
                ext.find('a.play').removeClass('stop');
                this.playFlag = false;
                clearTimeout(this.playId);
            };
            
            /**
             * Goto next slide
             * @method
             */
            this.next = function () {
                if (this.options.index == (this.length-1)) {
                    i = 0;
                } else {
                    i = this.options.index + 1;
                }            
                this.goSlide(i);
            };
            
            /**        
             * Init N-slide
             * @method
             * @param {Integer} n
             */
            this.init = function (index) {
                // initialize only ones
                for (var i = 0, loopCnt = this.inited.length; i < loopCnt; i++) {
                    if (this.inited[i] === index) {
                        return true;
                    }
                }
                
                // index to inited stack
                this.inited.push(index);
                
                // current slide
                slide = ext.find('.slideshow-content > *:eq('+index+')');
                
                var _self = this; 
                /**
                 * Replace A to content from HREF
                 */
                if (slide.get(0).tagName == 'A') {
                    var href   = slide.attr('href');
                    
                    var title  = slide.attr('title');
                        title  = title.replace(/\"/i,'\'');   // if you use single quotes for tag attribs
                        
                    var domain = document.domain;
                        domain = domain.replace(/\./i,"\.");  // for strong check domain name
                    
                    var reimage = new RegExp("\.(png|gif|jpg|jpeg|svg)$", "i");
                    var relocal = new RegExp("^((https?:\/\/"+domain+")|(?!http:\/\/))", "i");
                    
                    
                    if (this.options.imgajax && reimage.test(href)) {
                        slide.replaceWith('<img src="'+href+'" alt="'+title+'"/>');                        
                    } else if (this.options.linkajax && relocal.test(href)) {
                        $.get(href, function(data){
                            slide.replaceWith('<div><label>'+title+'</label>'+data+'</div>');
                        });
                    } else { // nothing else
//                            slide.wrap('<p></p>');
                    }
                    
                    slide = ext.find('.slideshow-content > *:eq('+index+')');
                    
                    // reset css
                    this._build(slide);
                }
                
                /**
                 * Play/stop on content click (like image and other)
                 */
                if (this.options.playclick)
                $(slide).click(function(){
                    if (_self.playFlag) {
                        _self.stop();
                    } else {
                        _self.play();
                    }
                    return false;
                });
            };
            
            /**        
             * Goto N-slide
             * @method
             * @param {Integer} n
             */
            this.goSlide = function (n) {
                
                if (this.options.index == n) return;
                
                this.init(n);
                
                var next = ext.find('.slideshow-content > *:eq('+n+')');
                var prev = ext.find('.slideshow-content > *:eq('+this.options.index+')');
                
                // restore next slide after all effects, set z-index = 0 for prev slide
                prev.css({zIndex:0});
                if (this.options.imgresize) {
                  next.css({zIndex:1, top: 0, left: 0, opacity: 1, width: this.options.width, height: this.options.height});
                } else {
                  next.css({zIndex:1, top: (this.options.height/2 - next.attr('height')/2), left: (this.options.width/2 - next.attr('width')/2), opacity: 1});
                }
                
                this.options.index = n;
                
                if (this.options.effect == 'random' ) {
                    var r = Math.random();
                          r = Math.floor(r*12);
                } else {
                      r = -1;
                }
                // effect between slides
                switch (true) {
                    case (this.options.effect == 'scrollUp' || r == 0):
                        prev.css({width:'100%'});
                        next.css({top:0, height:0});
                        
                        prevAni = {height: 0, top:this.options.height};
                        break;
                    case (this.options.effect == 'scrollDown' || r == 1):
                        prev.css({width:'100%'});
                        next.css({top:this.options.height,height:0});
                        
                        prevAni = {height: 0, top:0};
                        break;
                    case (this.options.effect == 'scrollRight' || r == 2):
                        prev.css({right:0,left:'',height:'100%'});
                        next.css({right:'',left:0,height:'100%',width:'0%'});
                        
                        prevAni = {width: 0};
                        break;
                    case (this.options.effect == 'scrollLeft' || r == 3):
                        prev.css({right:'',left:0,height:'100%'});
                        next.css({right:0,left:'',height:'100%',width:'0%'});
                        
                        prevAni = {width: 0};
                        break;
                    case (this.options.effect == 'growX' || r == 4):
                        next.css({zIndex:2,opacity: 1,left: this.options.width/2, width: '0%', height:'100%'});
                        
                        prevAni = {opacity: 0.8};
                        break;
                        
                    case (this.options.effect == 'growY' || r == 5):
                        next.css({opacity: 1,top: this.options.height/2, width:'100%', height: '0%'});
                        
                        prevAni = {opacity: 0.8};
                        break;
                        
                    case (this.options.effect == 'zoom' || r == 6):
                        next.css({width: 0, height: 0, top: this.options.height/2, left: this.options.width/2});
                        
                        prevAni = {width: 0, height: 0, top: this.options.height/2, left: this.options.width/2};
                        break;
                        
                    case (this.options.effect == 'zoomFade' || r == 7):
                        next.css({zIndex:1, opacity: 0,width: 0, height: 0, top: this.options.height/2, left: this.options.width/2});
                        
                        prevAni = {opacity: 0, width: 0, height: 0, top: this.options.height/2, left: this.options.width/2};
                        break;
                        
                    case (this.options.effect == 'zoomTL' || r == 8):
                        next.css({zIndex:1, opacity: 0,width: this.options.width/2, height: this.options.height/2, top:0, left: 0});
                        
                        prevAni = {opacity: 0, width: 0, height: 0, top: this.options.height, left: this.options.width};
                        break;
                    case (this.options.effect == 'zoomBR' || r == 9):
                        next.css({zIndex:1, opacity: 0,width: this.options.width/2, height: this.options.height/2, top: this.options.height/2, left: this.options.width/2});
                        
                        prevAni = {opacity: 0, width: 0, height: 0, top: 0, left: 0};
                        break;
                    case (this.options.effect == 'fade' || r == 10):
                    default:
                        prev.css({zIndex:0, opacity: 1});
                        next.css({zIndex:1, opacity: 0});
                        
                        prevAni = {opacity: 0};
                        break;
                }
                
                var _self = this;
                
                prev.animate(prevAni,this.options.effecttime);
                
                // play next slide animation, hide prev slide, update label, update counter
                next.show().animate({opacity: 1}, this.options.effecttime, function () { prev.hide(); _self.label(); _self.counter(); });
            };
            
            /**
             * Update counter data
             * @method
             */
            this.counter = function () {
                if (this.options.controls.counter)
                    ext.find('.slideshow-panel span.counter').html((this.options.index+1) + ' / ' + this.length);
                
            };
    		
    		// Now initialize the slideshow
    		this.options = $.extend({}, defaults, settings);
    		
    		if (typeof(settings) != 'undefined') {
        		if (typeof(settings.controls) != 'undefined')
        		   this.options.controls = $.extend({}, defaults.controls,  settings.controls);
    		}

            this.build();
            
            /**
             * Show slideshow
             */
            ext.show();
            
            /**
             * Check play option
             */
            if (this.options.play) {
                this.play();
            }
                
            return ext;
		});
		
        /**
         * external functions - append to $
         */
        _slideshow.playSlide = function(){ _slideshow.each(function () { this.play(); }) };
        _slideshow.stopSlide = function(){ _slideshow.each(function () { this.stop(); }) };
        _slideshow.nextSlide = function(){ _slideshow.each(function () { this.next(); }) };
        _slideshow.prevSlide = function(){ _slideshow.each(function () { this.prev(); }) };
		
		return this;
    }
})(jQuery);
