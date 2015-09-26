(function($) {
  "use strict";

  var environment_notification_plugin = {


    notificationBar: function() {
      var completeMessage = $(".environment-notification-plugin-notification-bar").remove();
      $("#content-inner").before(completeMessage);
    },

    closeNotification: function(){
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
    },

    hideNotification: function(){
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
    },

    hideUserNotification: function(){
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
    },

    mceRestrict: function() {
      tinyMCE.init({
        menubar : false,
        selector: "textarea",
        plugins: [
            "autolink link"
        ],
        toolbar: "bold italic underline | link"
      });
    },

    showPopup: function() {
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
    },
  };

  $(document).ready(function(){
    environment_notification_plugin.notificationBar();
    $(".environment-notification-plugin-notification-bar .notification-close").on("click", environment_notification_plugin.closeNotification);
    $(".environment-notification-plugin-notification-bar .notification-hide").on("click", environment_notification_plugin.hideNotification);

    if($('.environment-notification-plugin-message').length > 0){
      environment_notification_plugin.mceRestrict();
    }

    if($('.environment-notification-plugin-notification-bar').length > 0){
      environment_notification_plugin.hideUserNotification();
    }

    if($('.environment-notification-plugin-notification-bar [notification-display-popup="true"]').length > 0){
      environment_notification_plugin.showPopup();
    }
  });

})($);