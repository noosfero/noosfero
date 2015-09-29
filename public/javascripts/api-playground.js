// Create endpoint options
for (var endpoint,i=0; endpoint=endpoints[i]; i++) {
  jQuery('<option>'+endpoint.method+' '+endpoint.path+'</option>').appendTo('#api-form select');
}

var playground = {

  getToken: function() {
    return jQuery('#api-token input').val();
  },

  setToken: function(token) {
    jQuery('#api-token input').val(token);
  },

  getEndpoint: function() {
    var endpoint = jQuery('#api-form select').val().split(' ');
    return {
      method: endpoint[0],
      path: endpoint[1]
    };
  },

  selEndpoint: function() {
    var endpoint = this.getEndpoint();
    jQuery('#api-form .api-param').remove();
    if ( endpoint.path == prefix+'/v1/login' ) {
      this.addFormParam('login');
      this.addFormParam('password');
    }
    var pathParameters = endpoint.path.match(/:[^/]+/g);
    if ( pathParameters ) {
      for (var pathParam,i=0; pathParam=pathParameters[i]; i++) {
        this.addFormParam(pathParam.substr(1));
      }
    }
  },

  addFormParam: function(name) {
    if (!name) name = '';
    jQuery('<div class="api-param">'+
    '<label class="param-nane">name: <input name="name[]" value="'+name+'"></label>'+
    '<label class="param-value">value: <input name="value[]"></label>'+
    '</div>').appendTo('#api-form');
  },

  run: function() {
    var endpoint = this.getEndpoint();
    var rawData = jQuery('#api-form').serializeArray();
    var data = {};
    for (var i=1; i<rawData.length; i+=2) {
      data[ rawData[i].value ] = rawData[i+1].value;
    }
    if ( endpoint.path != prefix+'/v1/login' ) {
      data.private_token = this.getToken();
    }
    jQuery('#api-response').empty()[0].className = 'empty';
    var url = endpoint.path;
    var pathParameters = endpoint.path.match(/:[^/]+/g);
    if ( pathParameters ) {
      for (var pathParam,i=0; pathParam=pathParameters[i]; i++) {
        url = url.replace(pathParam, data[pathParam.substr(1)]);
      }
    }
    console.log('API Request', url, data);
    jQuery.ajax(url, {
      dataType: 'json',
      method: endpoint.method,
      data: data,
      success: function(data, textStatus, jqXHR) {
        jQuery('#api-response').text(
          JSON.stringify(data, null, '  ')
        )[0].className = 'full';
        if ( endpoint.path == prefix+'/v1/login' ) {
          playground.setToken(data.private_token)
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        jQuery('#api-response').html(
          '<h2>'+textStatus+'</h2>' +
          'Request to '+url+' fail.\n\n' + errorThrown
        )[0].className = 'fail';
      }
    });
  }

};

playground.selEndpoint(jQuery('#api-form select')[0]);
