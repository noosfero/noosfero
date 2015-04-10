// based on http://gmaps-samples-v3.googlecode.com/svn/trunk/overlayview/custommarker.html

function CustomMarker(options) {
  this.options = options;
  this.element = options.element;
  this.map = options.map;
  this.position = options.position;
  this.positionFunction = options.positionFunction || function () {
    var point = this.getProjection().fromLatLngToDivPixel(this.position);
    if (point) {
      this.element.style.position = 'absolute';
      this.element.style.left = (point.x - jQuery(this.element).width()/2) + 'px';
      this.element.style.top = (point.y - jQuery(this.element).height()) + 'px';
      this.element.style.cursor = 'pointer';

    }
  };

  // Once the LatLng and text are set, add the overlay to the map.  This will
  // trigger a call to panes_changed which should in turn call draw.
  this.setMap(this.map);
}

CustomMarker.prototype = new google.maps.OverlayView();
CustomMarker.prototype.draw = function() {
  if (!this.div_) {
    this.getPanes().overlayImage.appendChild(this.element);
    this.div_ = this.element;
  }
  this.positionFunction();
};
CustomMarker.prototype.getPosition = function() {
  return this.position;
};
CustomMarker.prototype.setVisible = function(bool) {
  jQuery(this.element).toggle(bool);
};

