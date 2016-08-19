/*
**  Noosfero's Video Channel specific client script
**  Released under the same Noosfero's license
*/

(function (exports, $) {
"use strict";

var vEl = document.createElement('video');
var canPlay = {
  webm: !!vEl.canPlayType('video/webm').replace(/no/,''),
  ogg:  !!vEl.canPlayType('video/ogg').replace(/no/,''),
  mp4:  !!vEl.canPlayType('video/mp4').replace(/no/,'')
};

exports.VideoChannel = function VideoChannel(baseEl) {
  this.baseEl = baseEl;
  if ($('.video-player', this.baseEl)[0]){
    this.player = new NoosferoVideoPlayer(this.baseEl, this);
    this.init();
  }
};

VideoChannel.prototype.init = function() {
  var me = this;
  $('.video-list-item', this.baseEl).each(
    function(num, item) {
      me.initItem(item);
    }
  );
  if ( $('.video-list li', this.baseEl)[0] ) {
    this.updatePlayer( $('li', this.baseEl).first() );
  } else {
    log.info('there is no playable video yet.');
    $('.video-player', this.baseEl).hide();
  }
};

VideoChannel.prototype.initItem = function(item) {
  var me = this;
  $(item).click(function(){ me.updatePlayer(item, true); });
  var link = $('a', item)[0];
  link.onclick = function(){ return false };
  link.nextFrame = VideoChannel.nextFrame;
  if ( !link.frameFade )
    link.frameFade = $('<div class="frame-fade"></div>').prependTo(link)[0];
  link.frameFade.style.backgroundImage = link.style.backgroundImage;
  link.addEventListener("animationend", function(){ link.nextFrame() }, false);
  link.addEventListener("webkitAnimationEnd", function(){ link.nextFrame() }, false);
  link.nextFrame();
};

VideoChannel.nextFrame = function(fade) {
  if ( !fade ) {
    this.frameFade.style.opacity = 0.0;
    this.frameFade.style.animationName = "";
    this.frameFade.style.MozAnimationName = "";
    this.frameFade.style.webkitAnimationName = "";
    if ( !this.bgYPos ) this.bgYPos = 0;
    this.style.backgroundPosition = "50% "+ ( this.bgYPos++ * -120 ) +"px";
    if ( this.bgYPos > 5 ) this.bgYPos = 0;
    this.frameFade.style.backgroundPosition = "50% "+ ( this.bgYPos * -120 ) +"px";
    var link = this;
    setTimeout( function(){ link.nextFrame(true) }, 10 );
  } else {
    this.frameFade.style.animationDuration = "1s";
    this.frameFade.style.animationName = "fadein";
    this.frameFade.style.MozAnimationDuration = "1s";
    this.frameFade.style.MozAnimationName = "fadein";
    this.frameFade.style.webkitAnimationDuration = "1s";
    this.frameFade.style.webkitAnimationName = "'fadein'";
  }
};

VideoChannel.prototype.updatePlayer = function(item, autoplay) {
  var json = $('a', item)[0].getAttribute("data-webversions");
  this.player.videoList = JSON.parse(json);
  this.player.selectWebVersion();
  this.player.update( this.getItemData(item), autoplay );
};

VideoChannel.prototype.getItemData = function(item) {
  var link = $('a', item)[0];
  var spans = $('span', item);
  var data = {};
  data.pageURL = link.href;
  data.videoURL = link.getAttribute('data-download');
  data.posterURL = link.getAttribute('data-poster');
  data.title = $(link).text();
  data.abstract = $('.abstract', item)[0].innerHTML;
  data.tags = $('.vli-data-tags > div', item)[0].innerHTML;
  return data;
};

///////////// Video Player /////////////////////////////////////////////////////

exports.NoosferoVideoPlayer = function NoosferoVideoPlayer(place, channel) {
  this.channel = channel;
  this.divBase = $('.video-player', place)[0];
  if(!this.divBase) return;
  this.info = {
    title      : $('h2',            this.divBase)[0],
    quality    : $('.quality ul',   this.divBase)[0],
    tags       : $('.tags div',     this.divBase)[0],
    abstract   : $('.abstract div', this.divBase)[0],
    videoCtrl  : $('.video-ctrl',   this.divBase)[0],
    downloadBt : $('.download-bt',  this.divBase)
      .button({ icons: { primary: "ui-icon-circle-arrow-s" } })[0]
  };
  this.videoBox = $('.video-box', this.divBase)[0];
  var me = this;
  this.zoomBt = $('<button class="zoom">Zoom</button>')
      .button({ icons: { primary: "ui-icon-zoomin" }, text: false })
      .click(function(){ me.toggleZoom() })
      .appendTo(this.info.videoCtrl);
  this.zoomBt[0].title = "Zoom in";
  this.videoEl = $('video', this.divBase)[0];
};

NoosferoVideoPlayer.prototype.update = function(data, autoplay) {
  this.info.title.innerHTML = data.title;
  this.videoEl.src = data.videoURL;
  this.videoEl.autoplay = autoplay;
  this.poster = data.posterURL;
  this.videoEl.load();
  var tags = data.tags || '<span class="empty">None</span>'
  $(this.info.tags).empty().append(tags);
  var desc = data.abstract || '<span class="empty">None</span>'
  $(this.info.abstract).empty().append(desc);
  this.info.downloadBt.href = data.videoURL;
};

NoosferoVideoPlayer.prototype.updateQualityOpts = function(type) {
  var me = this;
  $(this.info.quality).empty();
  for ( var size in this.videoList[type] ) {
    var videoData = this.videoList[type][size];
    log.info( 'Quality option:', videoData );
    if ( videoData.status == "done" ) {
      var txt = videoData.size_name;
      if ( !this.channel ) {
        txt = videoData.size.w +'x'+ videoData.size.h +
            ' <small>'+ videoData.vbrate +' KB/s</small>';
      }
      var bt = $(
        '<li data-path="'+videoData.path+'">'+ txt +'</li>')
        .button({ icons: { primary:"ui-icon-video" } })
        .click(function(){ me.load(this.video, true) })
        .appendTo(this.info.quality)[0];
      bt.video = videoData;
      videoData.qualityBt = bt;
    }
  }
};

NoosferoVideoPlayer.prototype.load = function (video, userSelection) {
  if ( this.currentVideo ) $(this.currentVideo.qualityBt).button().button("enable");
  $(video.qualityBt).button("disable");
  this.currentVideo = video;
  this.videoEl.src = video.path;
  this.videoEl.preload = "metadata";
  if ( userSelection )
    $.cookie( "video_quality", video.size_name, {path:'/'} );
  if ( $.cookie("video_zoom") == "true" ) this.zoomIn();
  else this.zoomOut();
};

NoosferoVideoPlayer.prototype.toggleZoom = function () {
  if ( $(this.divBase).hasClass("zoom-in") ) this.zoomOut();
  else this.zoomIn();
};

NoosferoVideoPlayer.prototype.zoomIn = function () {
  $.cookie( "video_zoom", "true", {path:'/'} );
  $(this.divBase).removeClass("zoom-out").addClass("zoom-in");
};

NoosferoVideoPlayer.prototype.zoomOut = function () {
  $.cookie( "video_zoom", "false", {path:'/'} );
  $(this.divBase).removeClass("zoom-in").addClass("zoom-out");
};

NoosferoVideoPlayer.prototype.selectWebVersion = function () {
  var video = null;
  var me = this;
  var q1 = $.cookie("video_quality") || "tiny";
  var q2 = ( q1 == "tiny" ) ? "nice" : "tiny";
  var type = canPlay.webm ? "WEBM" : canPlay.ogg ? "OGV" : "MP4";
  if (  (video = this.getVideoFromList(type, q1))
     || (video = this.getVideoFromList(type, q2))
     ) {
    this.updateQualityOpts(video.type);
    setTimeout( function(){ me.load(video) }, 10 );
  }
};

NoosferoVideoPlayer.prototype.getVideoFromList = function (type, quality) {
  log.info( 'Trying to getVideoFromList', type, quality );
  if (!this.videoList && !this.videoList) {
    log.info( 'The video list is empty' );
    return null;
  }
  if ( quality.toLowerCase() != "nice" ) quality = "tiny";
  var selected = this.videoList[type][quality];
  log.info( 'getVideoFromList find:', selected );
  if ( selected && selected.status == "done" ) {
    log.info( 'getVideoFromList success' );
    return selected;
  } else {
    log.info( 'getVideoFromList fail' );
    return null;
  }
};

}(window, jQuery));
