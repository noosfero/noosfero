var map;
var mapPoints = {};
var mapBounds;
var mapDefaultIcon = new GIcon(G_DEFAULT_ICON);
   
function mapPutMarker(lat, lng, title, _icon, url) {
  var point_str = lat + ":" + lng;

  var icon = _icon == null ? mapDefaultIcon : _icon;
   
  if (mapPoints[point_str]) {
    lng += (Math.random() - 0.5) * 0.02;
    lat += (Math.random() - 0.5) * 0.02;
  } else {
    mapPoints[point_str] = true;
  }
     
  var point = new GLatLng(lat, lng);
  var options = { 'title' : title, 'icon' : icon };
  var marker = new GMarker(point, options);
  map.addOverlay(marker);

  GEvent.addListener(marker, 'click', function() {
    if (url) {
      jQuery.ajax({url: url,
        success: function(data) {
          map.openInfoWindowHtml(point, jQuery(data).html());
        }
      });
    }
  });
  mapBounds.extend(point);

  return marker;
}

window.unload = function() {
  GUnload();
};

function mapLoad(initial_zoom) {
  if (GBrowserIsCompatible()) {
    map = new GMap2(document.getElementById("map"));

    new GKeyboardHandler(map);
    map.addControl(new GLargeMapControl());
    map.addControl(new GMapTypeControl());

    centerPoint = new GLatLng(-15.0, -50.1419);
    map.setCenter(centerPoint, initial_zoom);
    mapBounds = new GLatLngBounds();
  }
}

function mapCenter(latlng) {
  map.setZoom(map.getBoundsZoomLevel(mapBounds));
  map.setCenter(latlng ? latlng : mapBounds.getCenter());
}
