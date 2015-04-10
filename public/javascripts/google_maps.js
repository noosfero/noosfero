var map;
var infoWindow;
var mapPoints = {};
var mapBounds;

function mapOpenBalloon(marker, html) {
  infoWindow.setPosition(marker.getPosition());
  infoWindow.setContent(html);
  infoWindow.open(map, marker);
}

function mapPutMarker(lat, lng, title, icon, url_or_function) {
  var point_str = lat + ":" + lng;

  if (mapPoints[point_str]) {
    lng += (Math.random() - 0.5) * 0.02;
    lat += (Math.random() - 0.5) * 0.02;
  } else {
    mapPoints[point_str] = true;
  }

  var point = new google.maps.LatLng(lat, lng);
  var options = { map: map, title: title, icon: icon, position: point };
  var marker = new google.maps.Marker(options);

  google.maps.event.addListener(marker, 'click', function() {
    if (!url_or_function)
      return;
    if (typeof(url_or_function) == "function")
      url_or_function(marker);
    else
      jQuery.ajax({url: url_or_function, success: function(data) { mapOpenBalloon(marker, jQuery(data).html()); } });
  });
  mapBounds.extend(point);

  return marker;
}

function mapLoad(initialZoom, centerPoint) {
  if (!initialZoom) initialZoom = 4;
  if (!centerPoint) centerPoint = new google.maps.LatLng(0, 0);

  map = new google.maps.Map(document.getElementById("map"), {
    zoom: initialZoom,
    center: centerPoint,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });

  mapBounds = new google.maps.LatLngBounds();
  infoWindow = new google.maps.InfoWindow({map: map});

  google.maps.event.addListener(map, 'click', function() {
    infoWindow.close();
  });
}

function mapCenter(latlng) {
  if (!latlng) map.fitBounds(mapBounds);
  map.setCenter(latlng ? latlng : mapBounds.getCenter());
}
