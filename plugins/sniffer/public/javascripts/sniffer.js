sniffer = {

  search: {

    filters: { __categoryIds: [], distance: 0, circle: undefined, homePosition: undefined },

    loadSearchInput: function (options) {
      var input = jQuery(".sniffer-search-input");
      input.hint();
      input.autocomplete({
        source: options.sourceUrl,
        focus: function(event, ui) {
            input.val(ui.item.label);
            return false;
        },
        select: function (event, ui) {
          category = {id: ui.item.value, name: ui.item.label, interest_type: 'supplier'};
          if (sniffer.search.category.exists(category.id))
            sniffer.search.category.updateInterestType(category.id);
          else
            sniffer.search.category.append([category]);
          // Add new map marks:
          jQuery.ajax(options.addUrl.replace('_id_', category.id), {
            dataType: 'json',
            error: function( jqXHR, textStatus, errorThrown ) {
              var contextTxt = 'Ajax request to add new map marks fail.';
              log.error( contextTxt, textStatus, errorThrown );
              alert( contextTxt +'\n\n'+ textStatus );
            },
            success: function (data) {
              for (var profile,i=0; profile=data.enterprises[i]; i++) {
                if (profile.id != currentProfile.id){
                  var marker = sniffer.search.map.marker.add(profile);
                  sniffer.search.map.marker.index(data.productCategory.id, marker);
                }
              }
            }
          });
          input.val('');
          if (jQuery('#sniffer-product-search .hidden-pane').length > 0) {
            sniffer.search.showFilters();
            searchBoxTimeout = setTimeout(function(){ sniffer.search.hideFilters(); }, 1000);
          };
          return false;
        },
      });
    },

    filter: function () {
      // Creates a new boundary based on home position
      var bounds = new google.maps.LatLngBounds(sniffer.search.filters.homePosition);
      var visibleCount = 0;
      jQuery.each(sniffer.search.map.markerList, function(index, marker) {
        var visible = (
           !sniffer.search.filters.distance ||
            sniffer.search.filters.distance >= marker.profile.sniffer_plugin_distance
          ) && sniffer.search.category.matchFilters(marker);
        marker.setVisible(visible);
        // If marker is visible, expands boundary to fit new marker
        if (visible) {
          bounds.extend(marker.getPosition());
          visibleCount++;
        }
      });
      // Set bounds to fit all markers
      mapBounds = bounds;
      return visibleCount;
    },

    showFilters: function (event) {
      if (event) {
        clearTimeout(searchBoxTimeout);
      };
      jQuery('#sniffer-product-search .focus-pane')[0].classList.remove('hidden-pane');
      jQuery('#sniffer-product-search .legend')[0].classList.remove('hidden-pane');
    },
    hideFilters: function (event) {
      jQuery('#sniffer-product-search .focus-pane')[0].classList.add('hidden-pane');
      jQuery('#sniffer-product-search .legend')[0].classList.add('hidden-pane');
    },

    updateDistField: function (input) {
      var distance = parseInt(input.value);
      var label = jQuery(input.parentNode.parentNode);
      label.removeClass('disabled');
      if (isNaN(distance)) distance = 0;
      if (distance == 0) {
        label.addClass('disabled');
        input.value = '';
      }
      else input.value = distance;
      this.maxDistance(distance);
    },

    maxDistance: function (distance) {
      distance = parseInt(distance);
      sniffer.search.filters.distance = distance > 0 ? distance : undefined;
      var visibleMarkersCount = sniffer.search.filter();
      sniffer.search.setCircleRadius(distance);
      sniffer.search.setSubtitle(distance, visibleMarkersCount);
    },

    setCircleRadius: function (distance) {
      if (distance > 0) {
        sniffer.search.filters.circle.setRadius(distance * 1000);
        mapBounds = sniffer.search.filters.circle.getBounds();
      } else {
        sniffer.search.filters.circle.setRadius(0);
      };
      mapCenter();
    },

    setSubtitle: function (distance, count) {
      if (distance > 0) {
        jQuery('#sniffer-title .sniffer-subtitle').show();
        jQuery('#sniffer-title-distance').html(distance);
        jQuery('#sniffer-title-results').html(count);
      } else {
        jQuery('#sniffer-title .sniffer-subtitle').hide();
      };
    },

    profile: {

      findMarker: function (id) {
        var marker;
        jQuery.each(sniffer.search.map.markerList, function(index, m) {
          if (m.profile.id == id)
            marker = m;
        });
        return marker;
      },

    },

    category: {

      matchFilters: function (marker) {
        var match = false,
            markerIndex = sniffer.search.map.markerIndex,
            categoryIds = sniffer.search.filters.__categoryIds;
        for (var categoryId,i=0; categoryId=categoryIds[i]; i++) {
          match = match || !!(markerIndex[categoryId] &&
                            markerIndex[categoryId].indexOf(marker) > -1);
        }
        return match;
      },

      toggleFilter: function (input) {
        var id = parseInt(jQuery(input).attr('name'));
        if (input.checked)
          sniffer.search.category.applyFilter(id);
        else
          sniffer.search.category.unapplyFilter(id);
      },
      applyFilter: function (categoryId) {
        var categoryIds = sniffer.search.filters.__categoryIds;
        categoryIds.push(categoryId);
        categoryIds = _.uniq(categoryIds);
        sniffer.search.filters.__categoryIds = categoryIds;
        sniffer.search.filter();
      },
      unapplyFilter: function (categoryId) {
        var categoryIds = sniffer.search.filters.__categoryIds;
        categoryIds = _.without(categoryIds, categoryId);
        sniffer.search.filters.__categoryIds = categoryIds;
        sniffer.search.filter();
      },

      updateCount: function () {
        _.each(['consumers','suppliers','both'], function(item) {
          // We search for entries of type item (singular) in the category
          // table.
          var count = jQuery('#categories-table .'+item.replace(/s$/,'')).length;
          if (count > 0)
            jQuery('#sniffer-product-search .legend .'+item+' .count')[0].innerHTML = '('+count+')';
          else
            jQuery('#sniffer-product-search .legend .'+item+' .count')[0].innerHTML = '';
        });
      },

      exists: function (id) {
        var find = jQuery('#categories-table input[name='+id+']');
        return find.length > 0;
      },

      updateInterestType: function (id) {
        var row = jQuery('#categories-table input[name='+id+']');
        row = row.closest('tr').find('.consumer')
        if (row.length > 0) {
          row[0].classList.remove('consumer');
          row[0].classList.add('both');
        }
        sniffer.search.category.updateCount();
      },

      template: function (categories) {
        var template = jQuery('#sniffer-category-add-template');
        return _.map(categories, function (category) {
          if (sniffer.search.category.exists(category.id)) return;
          return _.template(template.html(), {category: category});
        }).join('');
      },
      append: function (categories) {
        var target = jQuery('#categories-table');
        var template = sniffer.search.category.template(categories);
        target.append(template);
        sniffer.search.category.updateCount();
      },

    },

    map: {

      markerIndex: [],
      markerList: [],

      homeIcon: "/plugins/sniffer/images/marker_home.png",
      suppliersIcon: "/plugins/sniffer/images/marker_suppliers.png",
      consumersIcon: "/plugins/sniffer/images/marker_consumers.png",
      bothIcon: "/plugins/sniffer/images/marker_both.png",

      marker: {

        create: function (lat, lng, title, icon, url_or_function) {
          var point_str = lat + ":" + lng;
          if (mapPoints[point_str]) {
            lng += (Math.random() - 0.5) * 0.02;
            lat += (Math.random() - 0.5) * 0.02;
          } else {
            mapPoints[point_str] = true;
          }

          var template = jQuery('#marker-template');
          var element = jQuery(_.template(template.html(), {icon: icon, title: title})).get(0);
          var point = new google.maps.LatLng(lat, lng);
          var marker = new CustomMarker({map: map, element: element, position: point});

          jQuery(marker.element).click(function() { url_or_function(marker); });
          mapBounds.extend(point);

          return marker;
        },

        add: function(profile, filtered) {
          if (filtered == undefined)
            filtered = true;

          var sp = profile.suppliersProducts;
          var cp = profile.consumersProducts;

          var marker = sniffer.search.profile.findMarker(profile.id);
          if (marker) {
            [].push.apply(sp, marker.profile.suppliersProducts);
            sp = _.uniq(sp, function(product) { return product.id; });
            [].push.apply(cp, marker.profile.consumersProducts);
            cp = _.uniq(cp, function(product) { return product.id; });
          }

          if (_.size(sp) > 0 && _.size(cp) > 0)
            icon = sniffer.search.map.bothIcon;
          else if (_.size(sp) > 0)
            icon = sniffer.search.map.suppliersIcon;
          else
            icon = sniffer.search.map.consumersIcon;

          if (profile.icon) icon = profile.icon;

          if (marker) {
            marker.setOptions({ icon: icon });
          } else {
            marker = sniffer.search.map.marker.create(
                       profile.lat, profile.lng, profile.name, icon,
                       sniffer.search.map.balloon.fill
                     );
          }
          marker.profile = profile;
          marker.cachedData = null;

          if (filtered) {
            sniffer.search.map.markerList.push(marker);
          }

          // Add circle overlay and bind to marker
          if (profile.id == currentProfile.id){
            sniffer.search.filters['circle'] = new google.maps.Circle({
              map: map,
              radius: sniffer.search.filters.distance * 1000, // in meters
              fillColor: '#e50000',
              strokeColor: '#5c0000',
              strokeWeight: 1
            });
            sniffer.search.filters.circle.bindTo('center', marker, 'position');
          }

          return marker;
        },

        index: function (product_category_id, marker) {
          var makersForCategory = sniffer.search.map.markerIndex[product_category_id];
          if (!makersForCategory) makersForCategory = [];
          if ( makersForCategory.indexOf(marker) == -1 )
            makersForCategory.push(marker);
          sniffer.search.map.markerIndex[product_category_id] = makersForCategory;
          sniffer.search.category.applyFilter(product_category_id);
        },
      },

      balloon: {

        open: function (marker, html) {
          marker.infoBox = new InfoBox({boxStyle: {width: null}, closeBoxURL: ""});
          marker.infoBox.setPosition(marker.getPosition());
          marker.infoBox.setContent(html);
          marker.infoBox.open(map, marker);
        },

        fill: function (marker) {
          // close all opened markers before opening a new one
          jQuery.each(sniffer.search.map.markerList, function(index, marker) {
            if (!(typeof marker.infoBox === 'undefined'))
              marker.infoBox.close();
          });
          var balloonJQ = jQuery(
            '<div class="sniffer-balloon-wrap">'+
            '<div class="sniffer-balloon loading"></div>'+
            '</div>'
          );
          sniffer.search.map.balloon.open(marker, balloonJQ[0]);
          var fillBalloon = function () {
            balloonJQ.find('.sniffer-balloon').removeClass('loading').prepend(marker.cachedData);
            closeBt = jQuery('.sniffer-balloon-close', balloonJQ)[0];
            marker.infoBox.closeListener_ = google.maps.event.addDomListener(closeBt, 'click',
                function(){
                  marker.infoBox.close();
                  google.maps.event.trigger(marker.infoBox, "closeclick");
            });
          }
          if (marker.cachedData)
            fillBalloon();
          else
            jQuery.ajax(marker.profile.balloonUrl, {
              type: 'POST',
              data: marker.profile,
              success: function (data) {
                marker.cachedData = jQuery(data).html();
                fillBalloon();
              },
              error: function (jqXHR, textStatus, errorThrown) {
                log.error('balloon.fill()', errorThrown);
                marker.cachedData = '<div class="error">'+
                  '<strong>'+textStatus+'</strong><br>'+errorThrown+'</div>';
                fillBalloon();
              }

            });
        },
      },

      resize: function () {
        var wrap = jQuery('#sniffer-search-wrap');
        var map = jQuery('#map');
        var legend = jQuery('#legend-wrap');

        wrap.css('height', jQuery(window).height() - wrap.offset().top);
        map.css('height', wrap.outerHeight() - legend.outerHeight(true));
      },

      load: function (options) {
        jQuery(window).load(sniffer.search.map.resize);
        jQuery(window).resize(sniffer.search.map.resize);
        mapLoad(options.zoom);

        var myProfile = currentProfile;
        myProfile.balloonUrl = options.myBalloonUrl;
        myProfile.icon = sniffer.search.map.homeIcon;
        var marker = sniffer.search.map.marker.add(myProfile, false);

        sniffer.search.filters.homePosition = marker.getPosition();

        _.each(options.profiles, function (profile) {
          var sp = profile.suppliersProducts;
          var cp = profile.consumersProducts;

          profile.balloonUrl = options.balloonUrl.replace('_id_', profile.id);
          var marker = sniffer.search.map.marker.add(profile);
          _.each(_.union(sp, cp), function (p) {
            sniffer.search.map.marker.index(p.product_category_id, marker);
          });
        });

        sniffer.search.filter();
        mapCenter();
      },

    },
  },
};

// underscore use of <@ instead of <%
_.templateSettings = {
  interpolate: /\<\@\=(.+?)\@\>/gim,
  evaluate: /\<\@(.+?)\@\>/gim
};

// from http://stackoverflow.com/questions/17033397/javascript-strings-with-keyword-parameters
String.prototype.format = function(obj) {
  return this.replace(/%\{([^}]+)\}/g,function(_,k){ return obj[k] });
};

var searchBoxTimeout;
