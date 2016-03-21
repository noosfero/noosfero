(function($) {
  "use strict";

  var admin_notifications_plugin = {


    notificationBar: function() {
      var completeMessage = $(".notification-plugin-notification-bar").remove();
      $("#content-inner").before(completeMessage);
    },

    closeNotification: function(){
      var notification = $(this).parent();
      var id = notification.attr("data-notification");

      $.ajax({
        url: noosfero_root()+'/plugin/admin_notifications/public/close_notification',
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
        url: noosfero_root()+'/plugin/admin_notifications/public/hide_notification',
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

    showPopup: function() {
      if($('.action-home-index').length > 0) {
        jQuery(function($){
          $.colorbox({href: noosfero_root()+'/plugin/admin_notifications/public/notifications_with_popup?previous_path=home'});
        });
      }
      else {
        jQuery(function($){
          $.colorbox({href: noosfero_root()+'/plugin/admin_notifications/public/notifications_with_popup'});
        });
      }
    },
  };

  $(document).ready(function(){
    admin_notifications_plugin.notificationBar();
    $(".notification-plugin-notification-bar .notification-close").on("click", admin_notifications_plugin.closeNotification);
    $(".notification-plugin-notification-bar .notification-hide").on("click", admin_notifications_plugin.hideNotification);

    if($('.notification-plugin-notification-bar').length > 0){
      admin_notifications_plugin.hideUserNotification();
    }

    if($('.notification-plugin-notification-bar [notification-display-popup="true"]').length > 0){
      admin_notifications_plugin.showPopup();
    }
  });

})($);
