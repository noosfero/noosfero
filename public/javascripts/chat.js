/* XMPP/Jabber Noosfero's client

   XMPP Core:
   http://xmpp.org/rfcs/rfc3920.html

   MUC support:
   http://xmpp.org/extensions/xep-0045.html

   Messages and presence:
   http://xmpp.org/rfcs/rfc3921.html
*/

jQuery(function($) {
   // extending the current namespaces in Strophe.NS
   Strophe.addNamespace('MUC_USER', 'http://jabber.org/protocol/muc#user');
   Strophe.addNamespace('MUC_OWNER', 'http://jabber.org/protocol/muc#owner');
   Strophe.addNamespace('CHAT_STATES', 'http://jabber.org/protocol/chatstates');
   Strophe.addNamespace('DATA_FORMS', 'jabber:x:data');

   var Jabber = {
     debug: true,
     connection: null,
     bosh_service: '/http-bind',
     muc_domain: $muc_domain,
     muc_supported: false,
     presence_status: '',
     update_presence_status_every: $update_presence_status_every, // time in seconds of how often update presence status to Noosfero DB
     tab_prefix: 'conversation-', // used to compose jQuery UI tabs and anchors to select then
     jids: {},
     rooms: {},

     templates: {
        buddy_item: "<li class='%{presence_status}'><a id='%{jid_id}' class='icon-menu-%{presence_status}-11' href='#'>%{name}</a></li>",
        occupant_item: "<li class='%{presence_status}'><a data-id='%{jid_id}' class='icon-menu-%{presence_status}-11' href='#'>%{name}</a></li>",
        room_item: "<li class='room'><a id='%{jid_id}' class='icon-chat' href='#'>%{name}</a></li>",
        message: "<div data-who='%{who}' class='message %{who}'><img class='avatar' src='%{avatar_url}'/><h5 class='%{who}-name'>%{name}</h5><span class='time'>%{time}</span><p>%{message}</p></div>",
        error: "<span class='error'>%{text}</span>",
        occupant_list: "<div class='occupant-list'><ul class='occupant-list'></ul></div>"
     },

     jid_to_id: function (jid) {
        return Strophe.getBareJidFromJid(jid).replace(/@/g, "-").replace(/\./g, "-");
     },

     jid_of: function(jid_id) {
        return Jabber.jids[jid_id].jid;
     },
     name_of: function(jid_id) {
        return Jabber.jids[jid_id].name;
     },
     type_of: function(jid_id) {
        return Jabber.jids[jid_id].type;
     },
     unread_messages_of: function(jid_id, value) {
        Jabber.jids[jid_id].unread_messages = (value == undefined ? Jabber.jids[jid_id].unread_messages : value);
        return Jabber.jids[jid_id].unread_messages;
     },

     insert_or_update_user: function (list, item, jid, name, presence, template) {
        var jid_id = Jabber.jid_to_id(jid);
        var html = template
           .replace('%{jid_id}', jid_id)
           .replace(/%{presence_status}/g, presence)
           .replace('%{name}', name);
        if ($(item).length > 0) {
           $(item).parent('li').replaceWith(html);
        } else {
           $(list).append(html);
        }
        Jabber.jids[jid_id] = {jid: jid, name: name, type: 'chat', presence: presence};
     },
     insert_or_update_contact: function (jid, name, presence) {
        var jid_id = Jabber.jid_to_id(jid);
        var list = $('#buddy-list .buddy-list');
        var item = $('#' + jid_id);
        presence = presence || ($(item).length > 0 ? $(item).parent('li').attr('class') : 'offline');
        log('adding or updating contact ' + jid + ' as ' + presence);
        Jabber.insert_or_update_user(list, item, jid, name, presence, Jabber.templates.buddy_item);
        $("#chat-window .tab a[href='#"+ Jabber.tab_prefix + jid_id +"']")
           .removeClass()
           .addClass('icon-menu-' + presence + '-11');
     },
     insert_or_update_occupant: function (jid, name, presence, room_jid) {
        log('adding or updating occupant ' + jid + ' as ' + presence);
        var jid_id = Jabber.jid_to_id(jid);
        var list = $('#' + Jabber.tab_prefix + Jabber.jid_to_id(room_jid) + ' .occupant-list ul');
        var item = $(list).find('a[data-id='+ jid_id +']');
        Jabber.insert_or_update_user(list, item, jid, name, presence, Jabber.templates.occupant_item);
        if (Jabber.rooms[Jabber.jid_to_id(room_jid)] === undefined) {
           Jabber.rooms[Jabber.jid_to_id(room_jid)] = {};
        }
        Jabber.rooms[Jabber.jid_to_id(room_jid)][name] = jid;
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

     show_message: function (jid, name, body, who, identifier) {
         if (body) {
            body = Jabber.render_body_message(body);
            var jid_id = Jabber.jid_to_id(jid);
            var tab_id = '#' + Jabber.tab_prefix + jid_id;
            if ($(tab_id).find('.message').length > 0 && $(tab_id).find('.message:last').attr('data-who') == who) {
               $(tab_id).find('.history').find('.message:last').append('<p>' + body + '</p>');
            }
            else {
               var time = new Date();
               time = time.getHours() + ':' + checkTime(time.getMinutes());
               var message_html = Jabber.templates.message
                 .replace('%{message}', body)
                 .replace(/%{who}/g, who)
                 .replace('%{time}', time)
                 .replace('%{name}', name)
                 .replace('%{avatar_url}', '/chat/avatar/' + identifier);
               $('#' + Jabber.tab_prefix + jid_id).find('.history').append(message_html);
            }
            $(tab_id).find('.history').scrollTo({top:'100%', left:'0%'});
            if (who != "self") {
               if ($(tab_id).find('.history:visible').length == 0) {
                 count_unread_messages(jid_id);
               }
               document.alert_title = name;
            }
         }
     },

     show_status: function(presence) {
        log('changing my status to ' + presence);
        $('#buddy-list .user-status .simplemenu-trigger')
           .removeClass('icon-menu-chat')
           .removeClass('icon-menu-offline')
           .removeClass('icon-menu-dnd')
           .addClass('icon-menu-' + (presence || 'offline'))
           .find('span').html($presence_status_label[presence]);
        $.get('/chat/update_presence_status', { status: {chat_status: presence, last_chat_status: presence} });
     },

     send_availability_status: function(presence) {
        Jabber.connection.send($pres().c('show').t(presence).up());
        Jabber.show_status(presence);
     },

     enter_room: function(room_jid) {
        Jabber.connection.send(
           $pres({to: room_jid + '/' + $own_name}).c('x', {xmlns: Strophe.NS.MUC}).c('history', {maxchars: 0})
        );
     },

     leave_room: function(room_jid) {
        Jabber.connection.send($pres({from: Jabber.connection.jid, to: room_jid + '/' + $own_name, type: 'unavailable'}))
     },

     update_chat_title: function () {
        var friends_online = $('#buddy-list .buddy-list li:visible').length;
        $('#friends-online').text(friends_online);
        document.title = $('#title-bar .title').text();
     },

     on_connect: function (status) {
        switch (status) {
           case Strophe.Status.CONNECTING:
              log('connecting...');
              break;
           case Strophe.Status.CONNFAIL:
              log('failed to connect');
              break;
           case Strophe.Status.DISCONNECTING:
              log('disconnecting...');
              $('#buddy-list .toolbar').addClass('small-loading-dark');
              break;
           case Strophe.Status.DISCONNECTED:
              log('disconnected');
              Jabber.show_status('');
              $('#buddy-list ul.buddy-list, .occupant-list ul.occupant-list').html('');
              Jabber.update_chat_title();
              $('#chat-window .tab a').removeClass().addClass('icon-menu-offline-11');
              $('#buddy-list .toolbar').removeClass('small-loading-dark');
              $('textarea').attr('disabled', 'disabled');
              break;
           case Strophe.Status.CONNECTED:
              log('connected');
           case Strophe.Status.ATTACHED:
              log('XMPP/BOSH session attached');
              $('#buddy-list .toolbar').removeClass('small-loading-dark');
              $('textarea').attr('disabled', '');
              break;
        }
     },

     on_roster: function (iq) {
        log('receiving roster');
        $(iq).find('item').each(function () {
           var jid = $(this).attr('jid');
           var name = $(this).attr('name') || jid;
           var jid_id = Jabber.jid_to_id(jid);
           Jabber.insert_or_update_contact(jid, name);
        });
        // set up presence handler and send initial presence
        Jabber.connection.addHandler(Jabber.on_presence, null, "presence");
        Jabber.send_availability_status(Jabber.presence_status);
        // detect if chat was opened with anchor like #community@conference.jabber.colivre
        $(window).trigger('hashchange');
     },

     // NOTE: cause Noosfero store's rosters in database based on friendship relation between people
     // these event never occurs cause jabber service (ejabberd) didn't know when a roster was changed
     on_roster_changed: function (iq) {
        log('roster changed');
        $(iq).find('item').each(function () {
           var sub = $(this).attr('subscription');
           var jid = $(this).attr('jid');
           var name = $(this).attr('name') || jid;
           if (sub == 'remove') {
              // contact is being removed
              Jabber.remove_contact(jid);
           } else {
              // contact is being added or modified
              Jabber.insert_or_update_contact(jid, name);
           }
        });
        return true;
     },

     parse: function (stanza) {
        var result = {};
        if (Strophe.isTagEqual(stanza, 'presence')) {
           result.from = $(stanza).attr('from');
           result.type = $(stanza).attr('type');
           if (result.type == 'unavailable') {
              result.show = 'offline';
           } else {
              var show = $(stanza).find("show").text();
              if (show === "" || show == "chat") {
                 result.show = 'chat';
              }
              else if (show == "dnd" || show == "xa") {
                 result.show = 'dnd';
              }
              else {
                 result.show = 'away';
              }
           }
           if ($(stanza).find('x[xmlns='+ Strophe.NS.MUC_USER +']').length > 0) {
              result.is_from_room = true;
              result.from_user = $(stanza).find('x item').attr('jid');
              if ($(stanza).find('x item').attr('affiliation') == 'owner') {
                 result.awaiting_configuration = ($(stanza).find('x status').attr('code') == '201');
              }
           }
        }
        else if (Strophe.isTagEqual(stanza, 'message')) {
           result.from = $(stanza).attr('from');
           result.body = $(stanza).find('body').text();
           if ($(stanza).find('error').length > 0) {
              result.error = $(stanza).find('error text').text();
              if (!result.error && $(stanza).find('error').find('service-unavailable').length > 0) {
                 result.error = $user_unavailable_error;
              }
           }
        }
        return result;
     },

     on_presence: function (presence) {
        presence = Jabber.parse(presence);
        if (presence.type != 'error') {
           if (presence.is_from_room) {
              log('receiving room presence from ' + presence.from + ' as ' + presence.show);
              var name = Strophe.getResourceFromJid(presence.from);
              if (presence.from_user) {
                 Jabber.insert_or_update_occupant(presence.from_user, name, presence.show, presence.from);
              }
              else {
                 log('ooops! user jid not found in presence stanza');
              }
              if (presence.awaiting_configuration) {
                 log('sending instant room configuration to ' + Strophe.getBareJidFromJid(presence.from));
                 Jabber.connection.sendIQ(
                    $iq({type: 'set', to: Strophe.getBareJidFromJid(presence.from)})
                       .c('query', {xmlns: Strophe.NS.MUC_OWNER})
                       .c('x', {xmlns: Strophe.NS.DATA_FORMS, type: 'submit'})
                 );
              }
           }
           else {
              log('receiving contact presence from ' + presence.from + ' as ' + presence.show);
              var jid = Strophe.getBareJidFromJid(presence.from);
              if (jid != Jabber.connection.jid) {
                 var name = Jabber.name_of(Jabber.jid_to_id(jid));
                 Jabber.insert_or_update_contact(jid, name, presence.show);
                 Jabber.update_chat_title();
              }
              else {
                 // why server sends presence from myself to me?
                 log('ignoring presence from myself');
              }
           }
        }
        return true;
     },

     on_private_message: function (message) {
        message = Jabber.parse(message);
        log('receiving message from ' + message.from);
        var jid = Strophe.getBareJidFromJid(message.from);
        var jid_id = Jabber.jid_to_id(jid);
        var name = Jabber.name_of(jid_id);
        create_conversation_tab(name, jid_id);
        Jabber.show_message(jid, name, message.body, 'other', Strophe.getNodeFromJid(jid));
        $.sound.play('/sounds/receive.wav');
        return true;
     },

     on_public_message: function (message) {
        message = Jabber.parse(message);
        log('receiving message from ' + message.from);
        var name = Strophe.getResourceFromJid(message.from);
        // is a message from the room itself
        if (! name) {
           Jabber.show_notice(Jabber.jid_to_id(message.from), message.body);
        }
        // is a message from another user, not mine
        else if ($own_name != name) {
           var jid = Jabber.rooms[Jabber.jid_to_id(message.from)][name];
           Jabber.show_message(message.from, name, message.body, name, Strophe.getNodeFromJid(jid));
           $.sound.play('/sounds/receive.wav');
        }
        return true;
     },

     on_message_error: function (message) {
        message = Jabber.parse(message)
        var jid = Strophe.getBareJidFromJid(message.from);
        log('Receiving error message from ' + jid);
        var body = Jabber.templates.error.replace('%{text}', message.error);
        Jabber.show_message(jid, Jabber.name_of(Jabber.jid_to_id(jid)), body, 'other', Strophe.getNodeFromJid(jid));
        return true;
     },

     on_muc_support: function(iq) {
        if ($(iq).find('identity[category=conference]').length > 0 && $(iq).find('feature[var='+ Strophe.NS.MUC +']').length > 0) {
           var name = $(iq).find('identity[category=conference]').attr('name');
           log('muc support found with identity '+ name);
           Jabber.muc_supported = true;
        }
        else {
           log('muc support not found');
        }
     },

     attach_connection: function(data) {
        // create the connection and attach it
        Jabber.connection = new Strophe.Connection(Jabber.bosh_service);
        Jabber.connection.attach(data.jid, data.sid, data.rid, Jabber.on_connect);

        // handle get roster list (buddy list)
        Jabber.connection.sendIQ($iq({type: 'get'}).c('query', {xmlns: Strophe.NS.ROSTER}), Jabber.on_roster);

        // handle presence updates in roster list
        Jabber.connection.addHandler(Jabber.on_roster_changed, 'jabber:iq:roster', 'iq', 'set');

        // Handle messages
        Jabber.connection.addHandler(Jabber.on_private_message, null, "message", "chat");

        // Handle conference messages
        Jabber.connection.addHandler(Jabber.on_public_message, null, "message", "groupchat");

        // Handle message errors
        Jabber.connection.addHandler(Jabber.on_message_error, null, "message", "error");

        // discovering MUC support
        Jabber.connection.sendIQ(
           $iq({type: 'get', from: Jabber.connection.jid, to: Jabber.muc_domain})
              .c('query', {xmlns: Strophe.NS.DISCO_INFO}),
           Jabber.on_muc_support
        );

        // Timed handle to save presence status to Noosfero DB every (N) seconds
        Jabber.connection.addTimedHandler(Jabber.update_presence_status_every * 1000, function() {
           log('saving presence status to Noosfero DB');
           $.get('/chat/update_presence_status', { status: {chat_status: Jabber.presence_status} });
           return true;
        });

        // uncomment for extra debugging
        //Strophe.log = function (lvl, msg) { log(msg); };
     },

     connect: function() {
        if (Jabber.connection && Jabber.connection.connected) {
           Jabber.send_availability_status(Jabber.presence_status);
        }
        else {
           log('starting XMPP/BOSH session...');
           $('#buddy-list .toolbar').removeClass('small-loading-dark').addClass('small-loading-dark');
           $('.dialog-error').hide();
           $.ajax({
             url: '/chat/start_session',
             dataType: 'json',
             success: function(data) {
                Jabber.attach_connection(data)
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
     },

     deliver_message: function(jid, body) {
        var type = Jabber.type_of(Jabber.jid_to_id(jid));
        var message = $msg({to: jid, from: Jabber.connection.jid, "type": type})
            .c('body').t(body).up()
            .c('active', {xmlns: Strophe.NS.CHAT_STATES});
        Jabber.connection.send(message);
        Jabber.show_message(jid, $own_name, body, 'self', Strophe.getNodeFromJid(Jabber.connection.jid));
     },

     is_a_room: function(jid_id) {
        return Jabber.type_of(jid_id) == 'groupchat';
     },

     show_notice: function(jid_id, msg) {
        var tab_id = '#' + Jabber.tab_prefix + jid_id;
        $(tab_id).find('.history').append("<span class='notice'>" + msg + "</span>");
     }
   };

   $('#chat-connect').live('click', function() {
      Jabber.presence_status = 'chat';
      Jabber.connect();
   });

   $('#chat-disconnect').click(function() {
      if (Jabber.connection && Jabber.connection.connected) {
         Jabber.connection.disconnect();
      }
   });

   // save presence_status as offline in Noosfero database when close or reload chat window
   $(window).unload(function() {
      $.get('/chat/update_presence_status', { status: {chat_status: ''} });
   });

   $('#chat-busy').click(function() {
      Jabber.presence_status = 'dnd';
      Jabber.connect();
   });

   $('#chat-retry').live('click', function() {
      Jabber.presence_status = Jabber.presence_status || 'chat';
      Jabber.connect();
   });

   // detect when click in chat with a community or person in main window of Noosfero environment
   $(window).bind('hashchange', function() {
      if (window.location.hash) {
         var full_jid = window.location.hash.replace('#', '');
         var jid = Strophe.getBareJidFromJid(full_jid);
         var name = Strophe.getResourceFromJid(full_jid);
         var jid_id = Jabber.jid_to_id(full_jid);
         window.location.hash = '#';
         if (full_jid) {
            if (Strophe.getDomainFromJid(jid) == Jabber.muc_domain) {
               if (Jabber.muc_supported) {
                  log('opening groupchat with ' + jid);
                  Jabber.jids[jid_id] = {jid: jid, name: name, type: 'groupchat'};
                  Jabber.enter_room(jid);
                  create_conversation_tab(name, jid_id);
               }
            }
            else {
               log('opening chat with ' + jid);
               create_conversation_tab(name, jid_id);
            }
         }
      }
   });

   $('.conversation textarea').live('keydown', function(e) {
     if (e.keyCode == 13) {
        var jid = $(this).attr('data-to');
        var body = $(this).val();
        Jabber.deliver_message(jid, body);
        $(this).val('');
        return false;
     }
   });

   // open new conversation or change to already opened tab
   $('#buddy-list .buddy-list li a').live('click', function() {
      var jid_id = $(this).attr('id');
      var name = Jabber.name_of(jid_id);
      create_conversation_tab(name, jid_id);
   });

   // put name into text area when click in one occupant
   $('.occupant-list .occupant-list li a').live('click', function() {
      var jid_id = $(this).attr('data-id');
      var name = Jabber.name_of(jid_id);
      var val = $('.conversation textarea:visible').val();
      $('.conversation textarea:visible').val(val + name + ', ').focus();
   });

   $('.conversation .history').live('click', function() {
      $('.conversation textarea:visible').focus();
   });

   function create_conversation_tab(title, jid_id) {
      if (! $('#' + Jabber.tab_prefix + jid_id).length > 0) {
         // opening chat with selected online friend
         var tab = $tabs.tabs('add', '#' + Jabber.tab_prefix + jid_id, title);
         var jid = Jabber.jid_of(jid_id);
         $("a[href='#" + Jabber.tab_prefix + jid_id + "']").addClass($('#' + jid_id).attr('class') || 'icon-chat');
         $('#' + Jabber.tab_prefix + jid_id).find('textarea').attr('data-to', jid);
         $tabs.tabs('select', '#' + Jabber.tab_prefix + jid_id);
      }
   }

   function count_unread_messages(jid_id, hide) {
      if (hide) {
         $('a[href=#' + Jabber.tab_prefix + jid_id + ']').find('.unread-messages').hide();
         Jabber.unread_messages_of(jid_id, 0);
         $('a[href=#' + Jabber.tab_prefix + jid_id + ']').find('.unread-messages').text('');
      }
      else {
         $('a[href=#' + Jabber.tab_prefix + jid_id + ']').find('.unread-messages').show();
         var unread_messages = Jabber.unread_messages_of(jid_id) || 0;
         Jabber.unread_messages_of(jid_id, ++unread_messages);
         $('a[href=#' + Jabber.tab_prefix + jid_id + ']').find('.unread-messages').text(unread_messages);
      }
   }

   // creating tabs
   var $tabs = $('#chat-window #tabs').tabs({
      tabTemplate: '<li class="tab"><a href="#{href}"><span class="unread-messages" style="display:none"></span>#{label}</a></li>',
      panelTemplate: "<div class='conversation'><div class='history'></div><div class='input-div'><div class='icon-chat'></div><textarea class='input'></textarea></div></div>",
      add: function(event, ui) {
         var jid_id = ui.panel.id.replace(Jabber.tab_prefix, '');

         var notice = $starting_chat_notice.replace('%{name}', $(ui.tab).html());
         Jabber.show_notice(jid_id, notice);

         // define textarea name as '<TAB_ID>'
         $(ui.panel).find('textarea').attr('name', ui.panel.id);

         if (Jabber.is_a_room(jid_id)) {
             $(ui.panel).append(Jabber.templates.occupant_list);
             $(ui.panel).find('.history').addClass('room');
         }
      },
      show: function(event, ui) {
         $(ui.panel).find('.history').scrollTo({top:'100%', left:'0%'});
         $(ui.panel).find('textarea').focus();
         var jid_id = ui.panel.id.replace(Jabber.tab_prefix, '');
         count_unread_messages(jid_id, true);
      },
      remove: function(event, ui) {
         var jid_id = ui.panel.id.replace(Jabber.tab_prefix, '');
         if (Jabber.is_a_room(jid_id)) {
            // exiting from a chat room
            var jid = Jabber.jid_of(jid_id);
            log('leaving chatroom ' + jid);
            Jabber.leave_room(jid);
         }
         else {
            // TODO notify to friend when I close chat window
         }
      }
   }).scrollabletab({
      closable: true
   });

   // remove some unnecessary css classes to apply style for tabs in bottom
   $(".tabs-bottom .ui-tabs-nav, .tabs-bottom .ui-tabs-nav > *")
      .removeClass("ui-corner-all ui-corner-top ui-helper-clearfix");
   $('#chat-window #tabs').removeClass("ui-corner-all ui-widget-content");

   // positionting scrollabletab wrapper at bottom and tabs next/prev buttons
   $('#stTabswrapper,#tabs').css({'position':'absolute', 'top':0, 'bottom':0, 'left': 0, 'right': 0, 'width': 'auto'});
   $('.stNavWrapper').css('position', 'absolute').css('bottom', 0).css('left', 0).css('right', 0)
      .find('.stNav').css('top', null).css('bottom', '12px').css('height', '22px')
      .find('.ui-icon').css('margin-top', '2px');
   $('.webkit .stNavWrapper .stNav').css('height', '20px');

   // // blink window title alerting about new unread messages
   //
   // FIXME disabling window blinking for now
   //
   // $(window).blur(function() {
   //    setTimeout(function() {
   //       window.blinkInterval = setInterval(function() {
   //          if (document.title.match(/\*.+\* .+/)) {
   //             document.title = document.title.replace(/\*.+\* /g, '');
   //          }
   //          else if (document.alert_title) {
   //             document.title = '*'+ document.alert_title +'* '+ document.title.replace(/\*.+\* /g, '');
   //          }}, 2000
   //       );
   //    }, 2000);
   // }, false);
   // $(window).focus(function() {
   //    clearInterval(window.blinkInterval);
   //    document.alert_title = null;
   //    document.title = document.title.replace(/\*.+\* /g, '');
   // }, false);

   function log(msg) {
      if(Jabber.debug && window.console && window.console.log) {
         var time = new Date();
         window.console.log('['+ time.toTimeString() +'] ' + msg);
      }
   }

});

function checkTime(i) {
   if (i<10) {
      i="0" + i;
   }
   return i;
}
