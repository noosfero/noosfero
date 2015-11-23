// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
/*
* third party libraries
*= require lodash.js
*= require jquery-2.1.1.min.js
*= require jquery-migrate-1.2.1.js
*= require jquery.cycle.all.min.js
*= require jquery.colorbox-min.js
*= require jquery-ui-1.10.4/js/jquery-ui-1.10.4.min.js
*= require jquery.scrollTo.js
*= require jquery.form.js
*= require jquery-validation/jquery.validate.js
*= require jquery.cookie.js
*= require jquery.ba-bbq.min.js
*= require jquery.tokeninput.js
*= require jquery-timepicker-addon/dist/jquery-ui-timepicker-addon.js
*= require inputosaurus.js
*= require reflection.js
*= require rails.js
*= require jrails.js
* noosfero libraries
*= require_self
*= require modal.js
*= require loading-overlay.js
*= require pagination.js
* views speficics
*= require add-and-join.js
*= require report-abuse.js
*= require manage-products.js
*= require catalog.js
*= require autogrow.js
*= require require_login.js
*/

// lodash configuration
_.templateSettings = {
  interpolate: /\{\{(.+?)\}\}/g,
};

// scope for noosfero stuff
noosfero = {
};

function noosfero_init() {
  // focus_first_field(); it is moving the page view when de form is down.
}

var __noosfero_root = null;
function noosfero_root() {
  if (__noosfero_root == null) {
    __noosfero_root = jQuery('meta[property="noosfero:root"]').attr("content") || '';
  }
  return __noosfero_root;
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
  if (str.indexOf('@') == -1)
    return convToValidUsername(str);
  else
    return convToValidEmail(str);
}

function convToValidUsername( str ) {
  return convToValidIdentifier(str, '');
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

function convToValidEmail( str ) {
  return str.toLowerCase()
            .replace( /á|à|ã|â/g, "a" )
            .replace( /é|ê/g,     "e" )
            .replace( /í/g,       "i" )
            .replace( /ó|ô|õ|ö/g, "o" )
            .replace( /ú|ũ|ü/g,   "u" )
            .replace( /ñ/g,       "n" )
            .replace( /ç/g,       "c" )
            .replace( /[^@a-z0-9!#$%&'*+-/=?^_`{|}~.]+/g, '' )
}

function updateUrlField(name_field, id) {
   url_field = jQuery('#'+id);
   old_url_value = url_field.val();
   new_url_value = convToValidIdentifier(name_field.value, "-");

   url_field.val(new_url_value);

   if (!/^\s*$/.test(old_url_value)
       && old_url_value != new_url_value
       ) {
     warn_value_change(url_field);
   }
}



jQuery.fn.centerInForm = function () {
  var $ = jQuery;
  var form = $(this).parent('form');
  this.css("position", "absolute");
  this.css("top", (form.height() - this.height())/ 2 + form.scrollTop() + "px");
  this.css("left", (form.width() - this.width()) / 2 + form.scrollLeft() + "px");
  this.css("width", form.width() + "px");
  this.css("height", form.height() + "px");
  return this;
}

jQuery.fn.center = function () {
  var $ = jQuery;
  this.css("position", "absolute");
  this.css("top", ($(window).height() - this.height())/ 2 + $(window).scrollTop() + "px");
  this.css("left", ($(window).width() - this.width()) / 2 + $(window).scrollLeft() + "px");
  return this;
}

function show_warning(field, message) {
  jQuery('#'+field).effect('highlight');
  jQuery('#'+message).show();
}

function hide_warning(field) {
   jQuery('#'+field).hide();
}

function enable_button(button) {
  button = jQuery(button)
  button.prop('disabled', false);
  button.removeClass("disabled");
}

function disable_button(button) {
  button = jQuery(button)
  button.prop('disabled', true);
  button.addClass("disabled");
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
   jQuery('#'+element_id).addClass('loading');
   if (message) {
      jQuery('#'+element_id).html(message);
   }
}
function small_loading(element_id, message) {
   $('#'+element_id).addClass('small-loading');
   if (message) {
      $('#'+element_id).text(message);
   }
}
function loading_done(element_id) {
   jQuery('#'+element_id).removeClass('loading');
   jQuery('#'+element_id).removeClass('small-loading');
   jQuery('#'+element_id).removeClass('small-loading-dark');
}
function open_loading(message) {
   jQuery('body').prepend("<div id='overlay_loading' class='ui-widget-overlay' style='display: none'/><div id='overlay_loading_modal' style='display: none'><p>"+message+"</p><img src='" + noosfero_root() + "/images/loading-dark.gif'/></div>");
   jQuery('#overlay_loading').show();
   jQuery('#overlay_loading_modal').center();
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
    if (e.target.value.indexOf(separator) > -1) {
      return false;
    }
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

function render_all_jquery_ui_widgets() {
  jQuery(function() {
    render_jquery_ui_buttons();
    jQuery('.ui-tabs').each(function(){
      jQuery(this).tabs({
        cookie: { name: this.id }
      });
    });
  });
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

function ieZIndexBugFix(trigger) {
  if (jQuery.browser.msie && parseInt(jQuery.browser.version) == 7) {
    jQuery('#navigation').css({ zIndex : 6 });
    jQuery('.box-2, .box-3').css({ zIndex : 5 });
    jQuery(trigger).parents('.box-2, .box-3').css({ zIndex : 11 });
  }
}

function toggleSubmenu(trigger, title, link_list) {
  ieZIndexBugFix(trigger);
  trigger.onclick = function() {
    ieZIndexBugFix(trigger);
    var submenu = jQuery(trigger).siblings('.menu-submenu');
    var hide = false;
    if (submenu.length > 0 && submenu.is(':visible')) hide = true;
    hideAllSubmenus();
    // Hide or show this submenu if it already exists
    if (submenu.length > 0) {
      if (!hide) {
        var direction = 'down';
        if (submenu.hasClass('up')) direction = 'up';
        jQuery(submenu).fadeIn();
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
      if(link_hash[label]!=null) {
        if(label=='link' && jQuery.type(link_hash[label])=="string") {
          list.append('<li>' + link_hash[label] + '</li>');
        } else {
          options = "";
          jQuery.each(link_hash[label], function(option, value){
            options += option +'="'+ value + '" ';
          })
          list.append('<li><a '+ options +'>' + label + '</a></li>');
        }
      }
    }
  });
  content.append(list);
  submenu.append(header).append(content).append(footer);
  jQuery(trigger).before(submenu);
  jQuery(submenu).fadeIn();
}

function toggleMenu(trigger) {
  jQuery(trigger).siblings('.simplemenu-submenu').toggle();
}

function hideAllSubmenus() {
  jQuery('.menu-submenu.up:visible').fadeOut('slow');
  jQuery('.simplemenu-submenu:visible').hide().toggleClass('opened');
  jQuery('.menu-submenu.down:visible').fadeOut('slow');
  jQuery('#chat-online-users-content').hide();
}

// Hide visible ballons when clicked outside them
jQuery(document).ready(function() {
  jQuery('body').live('click', function() { hideAllSubmenus(); });
  jQuery('.menu-submenu-trigger').live('click', function(e) { e.stopPropagation(); });
  jQuery('.simplemenu-trigger').live('click', function(e) { e.stopPropagation(); });
  jQuery('#chat-online-users').live('click', function(e) { e.stopPropagation(); });
});

function input_javascript_ordering_stuff() {
   jQuery(function() {
      jQuery(".input-list").sortable({
         placeholder: 'ui-state-highlight',
         axis: 'y',
         opacity: 0.8,
         tolerance: 'pointer',
         forcePlaceholderSize: true,
         update: function(event, ui) {
            jQuery.post(jQuery(this).next('.order-inputs').attr('href'), jQuery(this).sortable('serialize'));
         }
      });
      jQuery(".input-list li").disableSelection();

      jQuery(".input-list li").hover(
         function() {
            jQuery(this).addClass('editing-input');
            jQuery(this).css('cursor', 'move');
         },
         function() {
            jQuery(this).removeClass('editing-input');
            jQuery(this).css('cursor', 'pointer');
         }
      );

      jQuery("#display-add-input-button > .hint").show();
   });
}

function display_input_stuff() {
   jQuery(function() {
      jQuery("#add-input-button").click(function() {
        jQuery("#display-add-input-button").find('.loading-area').addClass('small-loading');
         url = jQuery(this).attr('href');
         jQuery.get(url, function(data){
            jQuery("#" + "new-product-input").html(data);
            jQuery("#display-add-input-button").find('.loading-area').removeClass('small-loading');
            jQuery("#add-input-button").hide();
         });
         return false;
      });
   });
}

function add_input_stuff() {
   jQuery(function() {
      jQuery(".cancel-add-input").click(function() {
         jQuery("#new-product-input").html('');
         jQuery("#add-input-button").show();
         return false;
      });
      jQuery("#input-category-form").submit(function() {
         id = "product-inputs";
         jQuery(this).find('.loading-area').addClass('small-loading');
         jQuery("#input-category-form,#input-category-form *").css('cursor', 'progress');
         jQuery.post(this.action, jQuery(this).serialize(), function(data) {
            jQuery("#" + id).html(data);
         });
         return false;
      });
      jQuery('body').scrollTo('50%', 500);
   });
}

function input_javascript_stuff(id) {
   jQuery(function() {
      id = 'input-' + id;
      jQuery("#add-"+ id +"-details,#edit-"+id).click(function() {
        target = '#' + id + '-form';

        jQuery('#' + id + ' ' + '.input-details').hide();
        jQuery(target).show();

        // make request only if the form is not loaded yet
        if (jQuery(target + ' form').length == 0) {
           small_loading(id);
           jQuery(target).load(jQuery(this).attr('href'), function() {
             loading_done(id);
             jQuery('#' + id + ' .input-informations').removeClass('input-form-closed').addClass('input-form-opened');
           });
        }
        else {
           jQuery('#' + id + ' .input-informations').removeClass('input-form-closed').addClass('input-form-opened');
        }

        return false;
      });
      jQuery("#remove-" + id).unbind('click').click(function() {
         if (confirm(jQuery(this).attr('data-confirm'))) {
            url = jQuery(this).attr('href');
            small_loading("product-inputs");
            jQuery.post(url, function(data){
              jQuery("#" + "product-inputs").html(data);
              loading_done("product-inputs");
            });
         }
         return false;
      });
    });
}

function edit_input_stuff(id, currency_separator) {
   id = "input-" + id;

   jQuery(function() {
      jQuery("#" + "edit-" + id + "-form").ajaxForm({
         target: "#" + id,
         beforeSubmit: function(a,f,o) {
           o.loading = small_loading('edit-' + id + '-form');
           o.loaded = loading_done(id);
         }
      });

      jQuery("#cancel-edit-" + id).click(function() {
         jQuery("#" + id + ' ' + '.input-details').show();
         jQuery("#" + id + '-form').hide();
         jQuery('#' + id + ' .input-informations').removeClass('input-form-opened').addClass('input-form-closed');
         return false;
      });

      jQuery(".numbers-only").keypress(function(event) {
         return numbersonly(event, currency_separator)
      });

      add_input_unit(id, jQuery("#" + id + " select :selected").val())

      jQuery("#" + id + ' select').change(function() {
         add_input_unit(id, jQuery("#" + id + " select :selected").val())
      });

      jQuery("#" + id).enableSelection();
   });
}

function add_input_unit(id, selected_unit) {
   if (selected_unit != '') {
      jQuery("#" + id + ' .price-by-unit').show();
      jQuery("#" + id + ' .selected-unit').text(jQuery("#" + id + " select :selected").text());
   } else {
      jQuery("#" + id + ' .price-by-unit').hide();
   }
}

function loading_for_button(selector) {
  jQuery(selector).append("<div class='small-loading' style='width:16px; height:16px; position:absolute; top:0; right:-20px;'></div>");
  jQuery(selector).css('cursor', 'progress');
}

function new_qualifier_row(selector, select_qualifiers, delete_button) {
  index = jQuery(selector + ' tr').size() - 1;
  jQuery(selector).append("<tr><td>" + select_qualifiers + "</td><td id='certifier-area-" + index + "'><select></select>" + delete_button + "</td></tr>");
}

function userDataCallback(data) {
  noosfero.user_data = data;
  if (data.login) {
    // logged in
    jQuery('head').append('<meta content="authenticity_token" name="csrf-param" />');
    jQuery('head').append('<meta content="'+jQuery.cookie("_noosfero_.XSRF-TOKEN")+'" name="csrf-token" />');
  }
  if (data.notice) {
    display_notice(data.notice);
    // clear notice so that it is not display again in the case this function is called again.
    data.notice = null;
  }
  // Bind this event to do more actions with the user data (for example, inside plugins)
  jQuery(window).trigger("userDataLoaded", data);
};

// controls the display of the login/logout stuff
jQuery(function($) {
  $.ajaxSetup({
    cache: false,
    headers: {
      'X-CSRF-Token': $.cookie("_noosfero_.XSRF-TOKEN")
    }
  });

  var user_data = noosfero_root() + '/account/user_data';
  $.getJSON(user_data, userDataCallback)

  $.ajaxSetup({ cache: false });
});

// controls the display of contact list
function check_contact_list(contact_list) {
  jQuery(function($) {
    var verify_url = $('#verify-contact-list').attr('href');
    var add_contacts_url = $('#add-contact-list').attr('href');
    var cancel_contacts_fetching_url = $('#cancel-fetching-emails').attr('href');
    var interval = setInterval(function() {
      $.getJSON(verify_url, function(data) {
        if (data.fetched) {
          clearInterval(interval);
          if (data.error) {
            $("#loading-dialog").dialog('close');
            $.get(cancel_contacts_fetching_url);
            redirect_to($('#invitation_back_button').attr('href'));
            display_notice(data.error);
          } else {
            $.get(add_contacts_url, function(data){
              $("#contacts-list").html(data);
            });
          };
          $("#loading-dialog").dialog('close');
        }
      });
    }, 5000);
    setTimeout(function() {
      clearInterval(interval);
      $("#loading-dialog").dialog('close');
      $.get(cancel_contacts_fetching_url);
      redirect_to($('#invitation_back_button').attr('href'));
    }, 600000);
  });
}

function display_notice(message) {
   var $noticeBox = jQuery('<div id="notice"></div>').html(message).appendTo('body').fadeTo('fast', 0.8);
   $noticeBox.click(function() { $(this).hide(); });
   setTimeout(function() { $noticeBox.fadeOut('fast'); }, 5000);
}

jQuery(function($) {
   /* Adds a class to "opera" to the body element if Opera browser detected.
    */
   if ( navigator.userAgent.indexOf("Opera") > -1 ) {
     $('body').addClass('opera');
   }

   /* Adds a class to "msie" to the body element if a Microsoft browser is
    * detected. This is needed to workaround several of their limitations.
    */
   else if ( navigator.appVersion.indexOf("MSIE") > -1 ) {
     document.body.className += " msie msie" +
       navigator.appVersion.replace(/^.*MSIE\s+([0-9]+).*$/, "$1");
   }

   /* Adds a class to "webkit" to the body element if a Webkit based browser
    * detected.
    */
   else if (window.devicePixelRatio) {
     $('body').addClass('webkit');
   }
});

function hide_and_show(hide_elements, show_elements) {
  for(i=0; i < hide_elements.length; i++){
    jQuery(hide_elements[i]).hide();
  }
  for(i=0; i < show_elements.length; i++){
    jQuery(show_elements[i]).show();
  }
}

function limited_text_area(textid, limit) {
  var text = jQuery('#' + textid).val();
  var textlength = text.length;
  jQuery('#' + textid + '_left span').html(limit - textlength);
  if (textlength > limit) {
    jQuery('#' + textid + '_left').hide();
    jQuery('#' + textid + '_limit').show();
    jQuery('#' + textid).val(text.substr(0,limit));
    return false;
  } else {
    jQuery('#' + textid + '_left').show();
    jQuery('#' + textid + '_limit').hide();
    return true;
  }
}

jQuery(function($) {
  $('.autogrow').autogrow();
});

jQuery(function($) {
  $('a').each(function() {
    if (this.href == document.location.href) {
      $(this).addClass('link-this-page');
    }
  });
});

jQuery(function($) {
  if ($.browser.msie) {
    $('.profile_link').click(function() {
      document.location.href = this.href;
    })
  }
  $('.manage-groups > a').live('click', function() {
    toggleMenu(this);
    return false;
  });
});

function add_comment_reply_form(button, comment_id) {
  //var container = jQuery(button).parents('.comment_reply');
  var container = jQuery('#comment_reply_to_'+comment_id);
  var f = container.find('.comment_form');
  if (f.length == 0) {
    comments_div = jQuery(button).parents('.comments');
    f = comments_div.find('.comment_form').first().clone();
    f.find('.errorExplanation').remove();
    f.append('<input type="hidden" name="comment[reply_of_id]" value="' + comment_id + '" />');
    container.append('<div class="page-comment-form"></div>');
    container.find('.page-comment-form').append(f);
  }
  if (container.hasClass('closed')) {
    container.removeClass('closed');
    container.addClass('opened');
    container.find('.comment_form input[type=text]:visible:first').focus();
  }
  jQuery('.display-comment-form').hide();
  return f;
}

function update_comment_count(element, new_count) {
  var $ = jQuery;
  var content = '';
  var parent_element = element.parent();

  write_out = parent_element.find('.comment-count-write-out');

  element.html(new_count);

  if(new_count == 0) {
    content = NO_COMMENT_YET;
    parent_element.addClass("no-comments-yet");
  } else if(new_count == 1) {
    parent_element.removeClass("no-comments-yet");
    content = ONE_COMMENT;
  } else {
    content = new_count + ' ' + COMMENT_PLURAL;
  }

  if(write_out){
    write_out.html(content);
  }

}

function remove_comment(button, url, msg) {
  var $ = jQuery;
  var $button = $(button);
  if (msg && !confirm(msg)) {
    $button.removeClass('comment-button-loading');
    return;
  }
  $button.addClass('comment-button-loading');
  $.post(url, function(data) {
    if (data.ok) {
      var $comment = $button.closest('.article-comment');
      var $replies = $comment.find('.comment-replies .article-comment');

      var $comments_div = $button.closest('.comments');

      var comments_removed = 1;
      $comment.slideUp(400, function() {
        if ($button.hasClass('remove-children')) {
          comments_removed = 1 + $replies.size();
        } else {
          $replies.appendTo('.article-comments-list');
        }

        $comments_div.find('.comment-count').add('#article-header .comment-count').each(function() {
          var count = parseInt($(this).html());
          update_comment_count($(this), count - comments_removed);
        });
        $(this).remove();
      });

    }else{
      $button.removeClass('comment-button-loading');
      return;
    }
  });
}

function remove_item_wall(button, item, url, msg) {
  var $ = jQuery;
  var $wall_item = $(button).closest(item);
  $wall_item.addClass('remove-item-loading');
  if (msg && !confirm(msg)) {
    $wall_item.removeClass('remove-item-loading');
    return;
  }
  $.post(url, function(data) {
    if (data.ok) {
      $wall_item.slideUp();
    } else {
      $wall_item.removeClass('remove-item-loading');
      window.location.replace(data.redirect);
    }
  });
}

function original_image_dimensions(src) {
  var img = new Image();
  img.src = src;
  return { 'width' : img.width, 'height' : img.height };
}

function gravatarCommentFailback(img) {
  var link = img.parentNode;
  link.href = "//www.gravatar.com";
  img.src = img.getAttribute("data-gravatar");
}

jQuery(function() {
  jQuery("#ajax-form").before("<div id='ajax-form-loading-area' style='display:block;width:16px;height:16px;'></div>");
  jQuery("#ajax-form").before("<div id='ajax-form-message-area'></div>");
  jQuery("#ajax-form").ajaxForm({
    beforeSubmit: function(a,f,o) {
      jQuery('#ajax-form-message-area').html('');
      o.loading = small_loading('ajax-form-loading-area');
    },
    success: function() {
      loading_done('ajax-form-loading-area');
    },
    target: "#ajax-form-message-area"
  })
});

// from http://jsfiddle.net/naveen/HkxJg/
// Function to get the Max value in Array
Array.max = function(array) {
  return Math.max.apply(Math, array);
};
// Function to get the Min value in Array
Array.min = function(array) {
  return Math.min.apply(Math, array);
};

function hideAndGetUrl(link) {
  document.body.style.cursor = 'wait';
  jQuery(link).hide();
  url = jQuery(link).attr('href');
  jQuery.get(url, function( data ) {
    document.body.style.cursor = 'default';
  });
}

jQuery(function($){
  $('.submit-with-keypress').live('keydown', function(e) {
     field = this;
     if (e.keyCode == 13) {
       e.preventDefault();
       var form = $(field).closest("form");
       $.ajax({
           url: form.attr("action"),
           data: form.serialize(),
           beforeSend: function() {
             loading_for_button($(field));
           },
           success: function(data) {
             var update = form.attr('data-update');
             $('#'+update).html(data);
             $(field).val($(field).attr('title'));
           }
       });
       return false;
     }
   });

  $('#content').delegate( '.view-all-comments a', 'click', function(e) {
     hideAndGetUrl(this);
     return false;
   });

  $('#content').delegate('.view-more-replies a', 'click', function(e) {
    hideAndGetUrl(this);
    return false;
  });

  $('#content').delegate('.view-more-comments a', 'click', function(e) {
    hideAndGetUrl(this);
    return false;
  });

  $('.focus-on-comment').live('click', function(e) {
     var link = this;
     $(link).parents('.profile-activity-item').find('textarea').focus();
     return false;
  });
});

/**
* @author Remy Sharp
* @url http://remysharp.com/2007/01/25/jquery-tutorial-text-box-hints/
*/

(function ($) {

$.fn.hint = function (blurClass) {
  if (!blurClass) {
    blurClass = 'blur';
  }

  return this.each(function () {
    // get jQuery version of 'this'
    var $input = $(this),

    // capture the rest of the variable to allow for reuse
      title = $input.attr('title'),
      $form = $(this.form),
      $win = $(window);

    function remove() {
      if ($input.val() === title && $input.hasClass(blurClass)) {
        $input.val('').removeClass(blurClass);
      }
    }

    // only apply logic if the element has the attribute
    if (title) {
      // on blur, set value to title attr if text is blank
      $input.blur(function () {
        if (this.value === '') {
          $input.val(title).addClass(blurClass);
        }
      }).focus(remove).blur(); // now change all inputs to title

      // clear the pre-defined text when form is submitted
      $form.submit(remove);
      $win.unload(remove); // handles Firefox's autocomplete
    }
  });
};

})(jQuery);

/*
 * altBeautify: put a styled tooltip on elements with
 * HTML on title and alt attributes.
 */

var altBeautify = jQuery('<div id="alt-beautify" style="display:none; position: absolute"/>')
  .append('<div class="alt-beautify-content"/>')
  .append('<div class="alt-beautify-arrow-border alt-beautify-arrow"/>')
  .append('<div class="alt-beautify-arrow-inner alt-beautify-arrow"/>');
var altTarget;
jQuery(document).ready(function () {
  jQuery('body').append(altBeautify);
});

function altTimeout() {
  if (!altTarget)
    return;
  altBeautify.css('top', jQuery(altTarget).offset().top + jQuery(altTarget).height());
  altBeautify.css('left', jQuery(altTarget).offset().left);
  altBeautify.find('.alt-beautify-content').html(jQuery(altTarget).attr('alt-beautify'));
  altBeautify.show();
}

function altHide() {
  altTarget = null;
  altBeautify.hide();
}

function altShow(e) {
  alt = jQuery(this).attr('title');
  if (alt != '') {
    jQuery(this).attr('alt-beautify', alt);
    jQuery(this).attr('title', '');
  }

  altTarget = this;
  setTimeout("altTimeout()", 500);
}

(function($) {

  jQuery.fn.altBeautify = function() {
    return this.each(function() {
      jQuery(this).bind('mouseover', altShow);
      jQuery(this).bind('mouseout', altHide);
      jQuery(this).bind('click', altHide);
    });
  }

})(jQuery);

// enable it generally
// jQuery('*[title]').live('mouseover', altShow);
// jQuery('*[title]').live('mouseout', altHide);
// jQuery('*[title]').live('click', altHide);
// jQuery('image[alt]').live('mouseover', altShow);
// jQuery('image[alt]').live('mouseout', altHide);
// jQuery('image[alt]').live('click', altHide);


function facet_options_toggle(id, url) {
  jQuery('#facet-menu-'+id+' .facet-menu-options').toggle('fast' , function () {
    more = jQuery('#facet-menu-'+id+' .facet-menu-more-options');
    console.log(more);
    if (more.is(':visible') && more.children().length == 0) {
      more.addClass('small-loading');
      more.load(url, function () {
        more.removeClass('small-loading');
      });
    }
  });
}

if ( !console ) console = {};
if ( !console.log ) console.log = function(){};

// Two ways to call it:
// log(mixin1[, mixin2[, ...]]);
// log('<type>', mixin1[, mixin2[, ...]]);
// Where <type> may be: log, info warn, or error
window.log = function log() {
  var type = arguments[0];
  var argsClone = jQuery.merge([], arguments); // cloning the read-only arguments array.
  if ( ['info', 'warn', 'error'].indexOf(type) == -1 ) {
    type = 'log';
  } else {
    argsClone.shift();
  }
  var method = type;
  if ( !console[method] ) method = 'log';
  console[method].apply( console, jQuery.merge([(new Date).toISOString()], argsClone) );
}

// Call log.info(mixin1[, mixin2[, ...]]);
log.info = function() {
  window.log.apply(window, jQuery.merge(['info'], arguments));
}

// Call log.warn(mixin1[, mixin2[, ...]]);
log.warn = function() {
  window.log.apply(window, jQuery.merge(['warn'], arguments));
}

// Call log.error(mixin1[, mixin2[, ...]]);
log.error = function() {
  window.log.apply(window, jQuery.merge(['error'], arguments));
}

function showHideTermsOfUse() {
  if( jQuery("#article_has_terms_of_use").attr("checked") )
    jQuery("#text_area_terms_of_use").show();
  else {
    jQuery("#text_area_terms_of_use").hide();
    jQuery("#article_terms_of_use").val("");
    jQuery("#article_terms_of_use_ifr").contents().find("body").html("");
  }
}

jQuery('.profiles-suggestions .explain-suggestion').live('click', function() {
  var clicked = jQuery(this);
  clicked.toggleClass('active');
  clicked.next('.extra_info').toggle();
  return false;
});

jQuery('.suggestions-block .block-subtitle').live('click', function() {
  var clicked = jQuery(this);
  clicked.next('.profiles-suggestions').toggle();
  clicked.nextAll('.more-suggestions').toggle();
  return false;
});

jQuery(document).ready(function(){
  showHideTermsOfUse();

  jQuery("#article_has_terms_of_use").click(function(){
    showHideTermsOfUse();
  });

  // Suggestions on search inputs
  (function($) {
    var suggestions_cache = {};
    $(".search-input-with-suggestions").autocomplete({
      minLength: 2,
      select: function(event, ui){
        $(this).val(ui.item.value);
        $(this).closest('form').submit();
      },
      source: function(request, response) {
        var term = request.term.toLowerCase();
        if (term in suggestions_cache) {
          response(suggestions_cache[term]);
          return;
        }
        request["asset"] = this.element.data("asset");
        $.getJSON("/search/suggestions", request, function(data, status, xhr) {
          suggestions_cache[term] = data;
          response(data);
        });
      }
    });
  })(jQuery);
});

function apply_zoom_to_images(zoom_text) {
  jQuery(function($) {
    $(window).load( function() {
      $('#article .article-body img:not(.disable-zoom)').each( function(index) {
        var original = original_image_dimensions($(this).attr('src'));
        if ($(this).width() < original['width'] || $(this).height() < original['height']) {
          $(this).wrap('<div class="zoomable-image" />');
          $(this).parent('.zoomable-image')
            .attr({style: $(this).attr('style')})
            .addClass(this.className)
            .css({
              width: $(this).width(),
              height: $(this).height(),
            });
          $(this).attr('style', '');
          $(this).after('<a href="' + $(this).attr('src') + '" class="zoomify-image"><span class="zoomify-text">'+zoom_text+'</span></a>');
        }
      });
      $('.zoomify-image').fancybox();
    });
  });
}

function notifyMe(title, options) {
  // This might be useful in the future
  //
  // Let's check if the browser supports notifications
  // if (!("Notification" in window)) {
  //   alert("This browser does not support desktop notification");
  // }

  // Let's check if the user is okay to get some notification
  var notification = null;
  if (Notification.permission === "granted") {
    // If it's okay let's create a notification
    notification = new Notification(title, options);
  }

  // Otherwise, we need to ask the user for permission
  // Note, Chrome does not implement the permission static property
  // So we have to check for NOT 'denied' instead of 'default'
  else if (Notification.permission !== 'denied') {
    Notification.requestPermission(function (permission) {
      // Whatever the user answers, we make sure we store the information
      if (!('permission' in Notification)) {
        Notification.permission = permission;
      }

      // If the user is okay, let's create a notification
      if (permission === "granted") {
        notification = new Notification(title, options);
      }
    });
  }

  setTimeout(function() {notification.close()}, 5000);
  notification.onclick = function(){
    notification.close();
    // Chromium tweak
    window.open().close();
    window.focus();
    this.cancel();
  };

  return notification;
  // At last, if the user already denied any notification, and you
  // want to be respectful there is no need to bother them any more.
}

function start_fetching(element){
  jQuery(element).append('<div class="fetching-overlay">Loading...</div>');
}

function stop_fetching(element){
  jQuery('.fetching-overlay', element).remove();
}

function add_new_file_fields() {
  var cloned = jQuery('#uploaded_files p:last').clone();
  cloned.find("input[type='file']").val('');
  cloned.appendTo('#uploaded_files');
  jQuery('body').scrollTo(cloned);
}

window.isHidden = function isHidden() { return (typeof(document.hidden) != 'undefined') ? document.hidden : !document.hasFocus() };

function $_GET(id){
    var a = new RegExp(id+"=([^&#=]*)");
    var result_of_search = a.exec(window.location.search)
    if(result_of_search != null){
      return decodeURIComponent(result_of_search[1]);
    }
}

var fullwidth=false;
function toggle_fullwidth(itemId){
  if(fullwidth){
    jQuery(itemId).removeClass("fullwidth");
    jQuery("#fullscreen-btn").show()
    jQuery("#exit-fullscreen-btn").hide()
    fullwidth = false;
  }
  else{
    jQuery(itemId).addClass("fullwidth");
    jQuery("#exit-fullscreen-btn").show()
    jQuery("#fullscreen-btn").hide()
    fullwidth = true;
  }
  jQuery(window).trigger("toggleFullwidth", fullwidth);
}

function fullscreenPageLoad(itemId){
  jQuery(document).ready(function(){

    if ($_GET('fullscreen') == 1){
      toggle_fullwidth(itemId);
    }
  });
}
