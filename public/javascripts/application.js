// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function noosfero_init() {
  // focus_first_field(); it is moving the page view when de form is down.
}

/* If applicable, find the first field in which the user can type and move the
 * keyboard focus to it.
 *
 * ToDo: focus only inside the view box to do not roll the page.
 */
function focus_first_field() {
  form = document.forms[0];
  if (form == undefined) {
    return;
  }

  for (var i = 0; i < form.elements.length; i++) {
    field = form.elements[i];
    if (field.type == 'text' || field.type == 'textarea') {
      try {
        field.focus();
        return;
      } catch(e) { }
    }
  }
}

/* * * Convert a string to a valid login name * * */
function convToValidLogin( str ) {
  return convToValidIdentifier(str, '')
}

/* * * Convert a string to a valid login name * * */
function convToValidIdentifier( str, sep ) {
  return str.toLowerCase()
            .replace( /@.*$/,     ""  )
            .replace( /á|à|ã|â/g, "a" )
            .replace( /é|ê/g,     "e" )
            .replace( /í/g,       "i" )
            .replace( /ó|ô|õ|ö/g, "o" )
            .replace( /ú|ũ|ü/g,   "u" )
            .replace( /ñ/g,       "n" )
            .replace( /ç/g,       "c" )
            .replace( /[^-_a-z0-9.]+/g, sep )
}

function updateUrlField(name_field, id) {
   url_field = $(id);
   old_url_value = url_field.value;
   new_url_value = convToValidIdentifier(name_field.value, "-");

   url_field.value = new_url_value;

   if (!/^\s*$/.test(old_url_value)
       && old_url_value != new_url_value
       ) {
     warn_value_change(url_field);
   }
}

function show_warning(field, message) {
   new Effect.Highlight(field, {duration:3});
   $(message).show();
}

function hide_warning(field) {
   $(field).hide();
}

function enable_button(button) {
   button.enable();
   button.removeClassName("disabled");
}

function disable_button(button) {
   button.disable();
   button.addClassName("disabled");
}

function toggleDisabled(enable, element) {
   if (enable) {
      enable_button(element);
   }
   else {
      disable_button(element);
   }
}

/* ICON SELECTOR - LinkListBlock */

function showIconSelector(main_div) {
   iconSelector = jQuery(main_div).children('.icon-selector')[0];
   jQuery(iconSelector).toggle();
}

function changeIcon(iconSelected, iconName) {
   iconSelector = iconSelected.parentNode;
   setTimeout('iconSelector.style.display = "none"', 100);
   main_div = iconSelector.parentNode;
   span = main_div.getElementsByTagName('span')[0];
   span.className = iconSelected.className;
   iconInput = main_div.getElementsByTagName('input')[0];
   iconInput.value = iconName;
}

function hideOthersIconSelector(current_div) {
   jQuery('.icon-selector').not(jQuery(current_div).children('.icon-selector')).hide();
}

function loading(element_id, message) {
   $(element_id).addClassName('loading');
   if (message) {
      $(element_id).update(message);
   }
}

function loading_done(element_id) {
   $(element_id).removeClassName('loading');
}

function open_loading(message) {
   jQuery('body').append("<div id='overlay_loading' class='ui-widget-overlay' style='display: none'/><div id='overlay_loading_modal' style='display: none'><p>"+message+"</p><img src='/images/loading-dark.gif'/></div>");
   jQuery('#overlay_loading').show();
   jQuery('#overlay_loading_modal').fadeIn('slow');
}
function close_loading() {
   jQuery('#overlay_loading_modal').fadeOut('slow', function() {
      jQuery('#overlay_loading_modal').remove();
      jQuery('#overlay_loading').remove();
   });
}
function update_loading(message) {
   jQuery('#overlay_loading_modal p').text(message);
}

function redirect_to(url) {
  document.location=url;
}

/* Products edition  */

function numbersonly(e, separator) {
  var key;
  var keychar;

  if (window.event) {
    key = window.event.keyCode;
  }
  else if (e) {
    key = e.which;
  }
  else {
    return true;
  }
  keychar = String.fromCharCode(key);

  if ((key==null) || (key==0) || (key==8) ||  (key==9) || (key==13) || (key==27) ) {
    return true;
  }
  else if ((("0123456789").indexOf(keychar) > -1)) {
    return true;
  }
  else if (keychar == separator) {
    return true;
  }
  else
    return false;
}

// transform all element with class ui_button in a jQuery UI button
function render_jquery_ui_buttons(element_id) {
   if (element_id) {
      element_id = '#' + element_id
      jQuery(element_id).button({
         icons: {
             primary: jQuery(element_id).attr('data-primary-icon'),
             secondary: jQuery(element_id).attr('data-secondary-icon')
            }
         }
      )
   }
   else {
      jQuery('.ui_button').each(function() {
         jQuery(this).button({
            icons: {
                primary: this.getAttribute('data-primary-icon'),
                secondary: this.getAttribute('data-secondary-icon')
               }
            }
         )
      })
   }
}

function expandCategory(block, id) {
  var link = jQuery('#block_' + block + '_category_' + id);
  if (category_expanded['block'] > 0 && category_expanded['category'] > 0 && category_expanded['block'] == block && category_expanded['category'] != id && link.hasClass('category-root')) {
    expandCategory(category_expanded['block'], category_expanded['category']);
    category_expanded['category'] = id;
    category_expanded['block'] = block;
  }
  if (category_expanded['block'] == 0) category_expanded['block'] = block;
  if (category_expanded['category'] == 0) category_expanded['category'] = id;
  jQuery('#block_' + block + '_category_content_' + id).slideToggle('slow');
  link.toggleClass('category-expanded');
  if (link.hasClass('category-expanded')) link.html(expanded_icon);
  else {
    link.html(collapsed_icon);
    if (link.hasClass('category-root')) {
      category_expanded['block'] = 0;
      category_expanded['category'] = 0;
    }
  }
}

function toggleSubmenu(trigger, title, link_list) {
  trigger.onclick = function() {
    var submenu = jQuery(trigger).siblings('.menu-submenu');
    var hide = false;
    if (submenu.length > 0 && submenu.is(':visible')) hide = true;
    hideAllSubmenus();
    // Hide or show this submenu if it already exists
    if (submenu.length > 0) {
      if (!hide) {
        var direction = 'down';
        if (submenu.hasClass('up')) direction = 'up';
        submenu.show('slide', { 'direction' : direction }, 'slow');
      }
    }
    return false;
  }

  hideAllSubmenus();
  // Build and show this submenu if it doesn't exist yet
  var direction = 'down';
  if (jQuery(trigger).hasClass('up')) direction = 'up';
  var submenu = jQuery('<div></div>').attr('class', 'menu-submenu ' + direction).attr('style', 'display: none');
  var header = jQuery('<div></div>').attr('class', 'menu-submenu-header');
  var content = jQuery('<div></div>').attr('class', 'menu-submenu-content');
  var list = jQuery('<ul></ul>').attr('class', 'menu-submenu-list');
  var footer = jQuery('<div></div>').attr('class', 'menu-submenu-footer');
  content.append('<h4>' + title + '</h4>');
  jQuery.each(link_list, function(index, link_hash) {
    for (label in link_hash) {
      list.append('<li><a href="' + link_hash[label] + '">' + label + '</a></li>');
    }
  });
  content.append(list);
  submenu.append(header).append(content).append(footer);
  jQuery(trigger).before(submenu);
  submenu.show('slide', { 'direction' : direction }, 'slow');
}

function hideAllSubmenus() {
  jQuery('.menu-submenu.up:visible').hide('slide', { 'direction' : 'up' }, 'slow');
  jQuery('.menu-submenu.down:visible').hide('slide', { 'direction' : 'down' }, 'slow');
}

// Hide visible ballons when clicked outside them
jQuery(document).ready(function() {
  jQuery('body').click(function() { hideAllSubmenus(); });
  jQuery('.menu-submenu-trigger').click(function(e) { e.stopPropagation(); });
});
