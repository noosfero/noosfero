/* XMPP/Jabber chat related functions */

jQuery(function($) {
   var Jabber = {
     debug: false,
     connection: null,
     bosh_service: '/http-bind',
     presence_status: '',
     tab_prefix: 'conversation-', // used to compose jQuery UI tabs and anchors to select then

     templates: {
        buddy_item: "<li class='%{presence_status}'><a id='%{jid_id}' class='icon-menu-%{presence_status}-11' href='#'>%{name}</a></li>",
        message: "<div class='message %{who}'><img class='avatar' src='%{avatar_url}'/><h5 class='%{who}-name'>%{name}</h5><span class='time'>%{time}</span><p>%{message}</p></div>"
     },

     jid_to_id: function (jid) {
        return Strophe.getBareJidFromJid(jid).replace(/@/g, "-").replace(/\./g, "-");
     },

     insert_or_update_contact: function (jid, name) {
        log('Adding or updating ' + jid);
        var jid_id = Jabber.jid_to_id(jid);
        var contact_html = Jabber.templates.buddy_item
           .replace('%{jid_id}', jid_id)
           .replace('%{name}', name);
        if ($('#' + jid_id).length > 0) {
           var presence = $('#' + jid_id).parent('li').attr('class');
           contact_html = contact_html.replace(/%{presence_status}/g, presence);
           $('#' + jid_id).parent('li').replaceWith(contact_html);
        } else {
           contact_html = contact_html.replace(/%{presence_status}/g, 'offline');
           $('#buddy-list .buddy-list').append(contact_html);
        }
        $('#' + jid_id).data('jid', jid);
        $('#' + jid_id).data('name', name);
     },

     update_contact_presence_status: function(jid, presence) {
        var icon_class = 'icon-menu-' + presence + '-11';
        var jid_id = Jabber.jid_to_id(jid);
        $('#' + jid_id + ", #chat-window .tab a[href='#" + Jabber.tab_prefix + jid_id + "']")
           .removeClass()
           .addClass(icon_class);
        $('#' + jid_id).parent('li').attr('class', presence);
     },

     remove_contact: function(jid) {
        var jid_id = Jabber.jid_to_id(jid)
        log('Removing contact ' + jid);
        $('#' + jid_id).parent('li').remove();
     },

     render_body_message: function(body) {
        body = $().emoticon(body);
        body = linkify(body, {
           callback: function(text, href) {
              return href ? '<a href="' + href + '" title="' + href + '" target="_blank">' + text + '</a>' : text;
           }
        });
        return body;
     },

     show_message: function (jid, body, who) {
         jid_id = Jabber.jid_to_id(jid);
         if (body) {
            var tab_id = '#' + Jabber.tab_prefix + jid_id;
            body = Jabber.render_body_message(body);
            if ($(tab_id).find('.message').length > 0 && $(tab_id).find('.message:last').hasClass(who)) {
               $(tab_id).find('.history').find('.message:last').append('<p>' + body + '</p>');
            }
            else {
               var time = new Date();
               time = time.getHours() + ':' + time.getMinutes();
               name = $('#' + jid_id).html();
               identifier = Strophe.getNodeFromJid(jid);
               if (who === "self") {
                  name = $own_name;
                  identifier = Strophe.getNodeFromJid(Jabber.connection.jid);
               }
               var message_html = Jabber.templates.message
                 .replace('%{message}', body)
                 .replace(/%{who}/g, who)
                 .replace('%{time}', time)
                 .replace('%{name}', name)
                 .replace('%{avatar_url}', '/chat/avatar/' + identifier);
               $('#' + Jabber.tab_prefix + jid_id).find('.history').append(message_html);
            }
            $(tab_id).find('.history').scrollTo({top:'100%', left:'0%'});
            if (who === "other" && $(tab_id).find('.history:visible').length == 0) {
               count_unread_messages(jid_id);
            }
         }
     },

     show_presence_status: function(presence) {
        log('Changing my presence status to: ' + presence);
        $('#buddy-list .user-status .simplemenu-trigger')
           .removeClass('icon-menu-chat')
           .removeClass('icon-menu-offline')
           .removeClass('icon-menu-dnd')
           .addClass('icon-menu-' + (presence || 'offline'))
           .find('span').html($presence_status_label[presence]);
     },

     send_presence_status: function(presence) {
        Jabber.connection.send($pres().c('show').t(presence).up());
        Jabber.show_presence_status(presence);
     },

     update_chat_title: function () {
        var friends_online = $('#buddy-list li:visible').length;
        $('#friends-online').text(friends_online);
        document.title = $('#title-bar .title').text();
     },

     on_connect: function (status) {
        log('Handler on_connect, status = ' + status);
        switch (status) {
           case Strophe.Status.CONNECTING:
              log('Strophe is connecting.');
              break;
           case Strophe.Status.CONNFAIL:
              log('Strophe failed to connect.');
              break;
           case Strophe.Status.DISCONNECTING:
              log('Strophe is disconnecting.');
              $('#buddy-list .toolbar').addClass('small-loading-dark');
              break;
           case Strophe.Status.DISCONNECTED:
              log('Strophe is disconnected.');
              $('#buddy-list .toolbar').removeClass('small-loading-dark');
              Jabber.show_presence_status('');
              $('#buddy-list ul.buddy-list').html('');
              $('#chat-window .tab a').removeClass().addClass('icon-menu-offline-11');
              break;
           case Strophe.Status.CONNECTED:
              log('Strophe is connected.');
           case Strophe.Status.ATTACHED:
              log('Strophe is attached.');
              $('#buddy-list .toolbar').removeClass('small-loading-dark');
              break;
        }
     },

     on_roster: function (iq) {
        log('Receiving roster...');
        $(iq).find('item').each(function () {
           var jid = jQuery(this).attr('jid');
           var name = jQuery(this).attr('name') || jid;
           var jid_id = Jabber.jid_to_id(jid);
           Jabber.insert_or_update_contact(jid, name);
        });
        // set up presence handler and send initial presence
        Jabber.connection.addHandler(Jabber.on_presence, null, "presence");
        Jabber.send_presence_status(Jabber.presence_status);
     },

     on_presence: function (presence) {
        var ptype = $(presence).attr('type');
        var full_jid = $(presence).attr('from');
        var jid_id = Jabber.jid_to_id(full_jid);
        var jid = Strophe.getBareJidFromJid(full_jid);
        log('Receiving presence...');
        if (ptype !== 'error') {
           if (ptype === 'unavailable') {
              Jabber.update_contact_presence_status(full_jid, 'offline');
           } else {
              var show = $(presence).find("show").text();
              log('Presence status received from ' + jid + ' with status ' + show);
              if (show === "" || show === "chat") {
                 Jabber.update_contact_presence_status(full_jid, 'chat');
              }
              else if (show === "dnd" || show === "xa") {
                 Jabber.update_contact_presence_status(full_jid, 'dnd');
              }
              else {
                 Jabber.update_contact_presence_status(full_jid, 'away');
              }

              // TODO get photo from vcard
              // var avatar_hash = $(presence).find('x[xmlns=vcard-temp:x:update] photo');
              // if (avatar_hash.length > 0) {
              //    log('> this contact has an vcard avatar');
              //    Jabber.get_avatar(jid, avatar_hash);
              // }

           }
           Jabber.update_chat_title();
        }
        return true;
     },

     // TODO get photo from vcard
     // get_avatar: function(jid, avatar_hash) {
     //    var vcard_iq = $iq({type: 'get', from: Jabber.own_jid, to: jid}).c('vCard').attrs({xmlns: 'vcard-temp'});
     //    log('> sending iq stanza to get avatar:' + vcard_iq.toString());
     //    Jabber.connection.sendIQ(vcard_iq,
     //        function(iq) {
     //           log('Receiving vcard...');
     //        },
     //        function(iq) {
     //           log('Error on receive vcard!');
     //           log('> error code = ' + $(iq).find('error').attr('code'));
     //        }
     //    );
     // },

     on_roster_changed: function (iq) {
        log('Recenving roster changed...');
        $(iq).find('item').each(function () {
           var sub = $(this).attr('subscription');
           var jid = $(this).attr('jid');
           var name = $(this).attr('name') || jid;
           if (sub === 'remove') {
              // contact is being removed
              Jabber.remove_contact(jid);
           } else {
              // contact is being added or modified
              Jabber.insert_or_update_contact(jid, name);
           }
        });
        return true;
     },

     on_message: function (message) {
        var full_jid = $(message).attr('from');
        var jid = Strophe.getBareJidFromJid(full_jid);
        var jid_id = Jabber.jid_to_id(jid);
        var body = $(message).find('body').text();
        log('Receiving message from ' + jid);
        log('> ' + body);
        var name = $('#' + jid_id).data('name');
        create_conversation_tab(name, jid_id);
        Jabber.show_message(jid, body, 'other');
        return true;
     },

     attach_connection: function(data) {
        // create the connection and attach it
        Jabber.connection = new Strophe.Connection(Jabber.bosh_service);

        // uncomment for extra debugging
        // Strophe.log = function (lvl, msg) { log(msg); };
        Jabber.connection.attach(data.jid, data.sid, data.rid, Jabber.on_connect);

        // handle get roster list (buddy list)
        Jabber.connection.sendIQ($iq({type: 'get'}).c('query', {xmlns: Strophe.NS.ROSTER}), Jabber.on_roster);

        // handle presence updates in roster list
        Jabber.connection.addHandler(Jabber.on_roster_changed, 'jabber:iq:roster', 'iq', 'set');

        // Handle messages
        Jabber.connection.addHandler(Jabber.on_message, null, "message", "chat");
     },

     connect: function() {
        if (Jabber.connection && Jabber.connection.connected) {
           Jabber.send_presence_status(Jabber.presence_status);
        }
        else {
           log('Starting BOSH session...');
           $('#buddy-list .toolbar').removeClass('small-loading-dark').addClass('small-loading-dark');
           $('.dialog-error').hide();
           $.ajax({
             url: '/chat/start_session',
             dataType: 'json',
             success: function(data) {
                Jabber.attach_connection(data)
                $.get('/chat/update_presence_status', { presence_status: Jabber.presence_status });
             },
             error: function(error) {
                $('#buddy-list .toolbar').removeClass('small-loading-dark');
                $('#buddy-list .dialog-error')
                   .html(error.responseText)
                   .show('highlight')
                   .unbind('click')
                   .click(function() { $(this).hide('highlight'); });
             }
           });
        }
     }
   };

   $('#chat-connect,.chat-connect').live('click', function() {
      Jabber.presence_status = 'chat';
      Jabber.connect();
   });

   $('#chat-disconnect').click(function() {
      if (Jabber.connection && Jabber.connection.connected) {
         Jabber.connection.disconnect();
         $.get('/chat/update_presence_status', { presence_status: '' });
      }
   });

   $('#chat-busy').click(function() {
      Jabber.presence_status = 'dnd';
      Jabber.connect();
   });

   // save presence_status as offline in Noosfero database when close or reload chat window
   $(window).unload(function() {
      $.get('/chat/update_presence_status', { presence_status: '', closing_window: true });
   });

   jQuery(function() {
      if (Jabber.debug)
         $('body').append("<div id='log'></div>");
   });

   $('.conversation textarea').live('keydown', function(e) {
     if (e.keyCode == 13) {
        var jid = $(this).attr('data-to');
        var body = $(this).val();
        var message = $msg({to: jid, "type": "chat"})
            .c('body').t(body).up()
            .c('active', {xmlns: "http://jabber.org/protocol/chatstates"});
        Jabber.connection.send(message);
        Jabber.show_message(jid, body, 'self');
        $(this).val('');
        return false;
     }
   });

   function create_conversation_tab(title, id) {
      if (! $('#' + Jabber.tab_prefix + id).length > 0) {
         // opening chat with selected online friend
         var tab = $tabs.tabs('add', '#' + Jabber.tab_prefix + id, title);
         var jid = $('#' + id).data('jid');
         $("a[href='#" + Jabber.tab_prefix + id + "']").addClass($('#' + id).attr('class'));
         $('#' + Jabber.tab_prefix + id).find('textarea').attr('data-to', jid);
      }
   }

   function count_unread_messages(jid_id, clear) {
      if (clear) {
         $('a[href=#conversation-' + jid_id + ']').find('.unread-messages').hide();
         $('#' + jid_id).data('unread_messages', 0);
         $('a[href=#conversation-' + jid_id + ']').find('.unread-messages').text('');
         document.alert_title = null;
      }
      else {
         $('a[href=#conversation-' + jid_id + ']').find('.unread-messages').show();
         var unread_messages = $('#' + jid_id).data('unread_messages') || 0;
         $('#' + jid_id).data('unread_messages', ++unread_messages);
         $('a[href=#conversation-' + jid_id + ']').find('.unread-messages').text(unread_messages);
         var name = jQuery('#' + jid_id).data('name');
         document.alert_title =  '*' + name + '* ' + document.title;
      }
   }

   // open new conversation or change to already opened tab
   $('#buddy-list .buddy-list li').find('a').live('click', function() {
      var tab_title = $(this).data('name');
      var tab_identifier = $(this).attr('id');
      create_conversation_tab(tab_title, tab_identifier);
      // immediately select tab
      $tabs.tabs('select', '#conversation-' + tab_identifier);
   });

   // creating tabs
   var $tabs = $('#chat-window #tabs').tabs({
      tabTemplate: '<li class="tab"><a href="#{href}"><span class="unread-messages" style="display:none"></span>#{label}</a><span class="ui-icon ui-icon-close">Remove Tab</span></li>',
      panelTemplate: "<div class='conversation'><div class='history'></div><div class='input-div'><div class='icon-chat'></div><textarea class='input'></textarea></div></div>",
      add: function(event, ui) {
         $(ui.panel).find('.history').append("<span class='notify'>" + $starting_chat_notify.replace('%{name}', $(ui.tab).html()) + "</span>");
         // define textarea name as '<TAB_ID>'
         $(ui.panel).find('textarea').attr('name', ui.panel.id);
      },
      remove: function(event, ui) {
         // TODO notify window close
      },
      show: function(event, ui) {
         $(ui.panel).find('.history').scrollTo({top:'100%', left:'0%'});
         $(ui.panel).find('textarea').focus();
         var jid_id = ui.panel.id.replace('conversation-', '');
         count_unread_messages(jid_id, true);
      }
   }).scrollabletab();

   // remove some unnecessary css classes to apply style for tabs in bottom
   $(".tabs-bottom .ui-tabs-nav, .tabs-bottom .ui-tabs-nav > *")
      .removeClass("ui-corner-all ui-corner-top ui-helper-clearfix");
   $('#chat-window #tabs').removeClass("ui-corner-all ui-widget-content");

   // positionting scrollabletab wrapper at bottom and tabs next/prev buttons
   $('#stTabswrapper,#tabs').css('position', 'absolute').css('top', 0).css('bottom', 0).css('left', 0).css('right', 0);
   $('.stNavWrapper').css('position', 'absolute').css('bottom', 0).css('left', 0).css('right', 0)
      .find('.stNav').css('top', null).css('bottom', '12px').css('height', '22px')
      .find('.ui-icon').css('margin-top', '2px');
   $('.webkit .stNavWrapper .stNav').css('height', '20px');

   // close icon: removing the tab on click
   $('.tabs-bottom span.ui-icon-close').live('click', function() {
      var index = $('li', $tabs).index($(this).parent());
      $tabs.tabs('remove', index);
   });

   // blink window title alerting about new unread messages
   $(window).load(function() {
      $(document).blur(function() {
         setTimeout(function() {
            window.blinkInterval = setInterval(function() {
               if (document.title.match(/\*.+\* .+/)) {
                  document.title = document.title.replace(/\*.+\* /g, '');
               }
               else if (document.alert_title) {
                  document.title = document.alert_title;
               }}, 2000
            );
         }, 2000);
      }, false);
      $(document).focus(function() {
         clearInterval(window.blinkInterval);
         document.alert_title = null;
         document.title = document.title.replace(/\*.+\* /g, '');
      }, false);
   });

});
