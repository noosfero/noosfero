(function($) {
  "use strict";

  function notificationBar() {
    var completeMessage = $(".notification-bar").remove();
    $("#content-inner").before(completeMessage);
  }

  function closeNotification(){
    var notification = $(this).parent();
    var id = notification.attr("data-notification");

    $.ajax({
      url: noosfero_root()+"/admin/plugin/environment_notification/close_notification",
      type: "POST",
      data: {notification_id: id},
      success: function(response) {
        notification.fadeOut();
      }
    });
  }

  function hideNotification(){
    var notification = $(this).parent();
    var id = notification.attr("data-notification");

    $.ajax({
      url: noosfero_root()+"/admin/plugin/environment_notification/hide_notification",
      type: "POST",
      data: {notification_id: id},
      success: function(response) {
        notification.fadeOut();
      }
    });
  }

  function hideUserNotification(){
    var ids = $.cookie('hide_notifications');
    if(ids === null) {
      return null;
    }

    if(ids.startsWith('[') && ids.endsWith(']')){
      ids = ids.substring(1, ids.length - 1);
      ids = ids.split(",");

      for(var i = 0; i < ids.length; i++) {
        $('[data-notification="' + ids[i] + '"]').fadeOut();
      }
    }
  }

  function mceRestrict() {
    tinyMCE.init({
      menubar : false,
      selector: "textarea",
      plugins: [
          "autolink link"
      ],
      toolbar: "bold italic underline | link"
    });
  }

  function showPopup() {
    if($('.action-home-index').length > 0) {
      jQuery(function($){
        $.colorbox({href: noosfero_root()+'/plugin/environment_notification/public/notifications_with_popup?previous_path=home'});
      });
    }
    else {
      jQuery(function($){
        $.colorbox({href: noosfero_root()+'/plugin/environment_notification/public/notifications_with_popup'});
      });
    }
  }

  $(document).ready(function(){
    notificationBar();
    $(".notification-close").on("click", closeNotification);
    $(".notification-hide").on("click", hideNotification);

    if($('.environment-notification-plugin-message').length > 0){
      mceRestrict();
    }

    if($('.notification-bar').length > 0){
      hideUserNotification();
    }

    if($('[notification-display-popup="true"]').length > 0){
      showPopup();
    }
  });

})($);