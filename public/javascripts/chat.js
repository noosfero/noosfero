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
     bosh_service: $bosh_service,
     muc_domain: $muc_domain,
     muc_supported: false,
     presence_status: '',
     conversation_prefix: 'conversation-',
     jids: {},
     rooms: {},

     template: function(selector) {
       return $('#chat #chat-templates '+selector).clone().html();
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

     insert_or_update_user: function (list, item, jid, name, presence, template, type) {
        var jid_id = Jabber.jid_to_id(jid);
        var identifier = Strophe.getNodeFromJid(jid);
        var html = template
           .replace('%{jid_id}', jid_id)
           .replace(/%{presence_status}/g, presence)
           .replace('%{avatar}', getAvatar(identifier))
           .replace('%{name}', name);

        $(item).parent().remove();
        $(list).append(html);
        Jabber.jids[jid_id] = {jid: jid, name: name, type: type, presence: presence};
     },
     insert_or_update_group: function (jid, presence) {
        var jid_id = Jabber.jid_to_id(jid);
        var list = $('#buddy-list .buddies .online');
        var item = $('#' + jid_id);
        presence = presence || ($(item).length > 0 ? $(item).parent('li').attr('class') : 'offline');
        log('adding or updating contact ' + jid + ' as ' + presence);
        Jabber.insert_or_update_user(list, item, jid, Jabber.name_of(jid_id), presence, Jabber.template('.buddy-item'), 'groupchat');
        $("#chat-window .tab a[href='#"+ Jabber.conversation_prefix + jid_id +"']")
           .removeClass()
           .addClass('icon-menu-' + presence + '-11');
     },
     insert_or_update_contact: function (jid, name, presence) {
        var jid_id = Jabber.jid_to_id(jid);
        var item = $('#' + jid_id);
        presence = presence || ($(item).length > 0 ? $(item).parent('li').attr('class') : 'offline');
        var list = $('#buddy-list .buddies ' + (presence=='offline' ? '.offline' : '.online'));

        log('adding or updating contact ' + jid + ' as ' + presence);
        Jabber.insert_or_update_user(list, item, jid, name, presence, Jabber.template('.buddy-item'), 'chat');
        $("#chat-window .tab a[href='#"+ Jabber.conversation_prefix + jid_id +"']")
           .removeClass()
           .addClass('icon-menu-' + presence + '-11');
     },
     insert_or_update_occupant: function (jid, name, presence, room_jid) {
        log('adding or updating occupant ' + jid + ' as ' + presence);
        var jid_id = Jabber.jid_to_id(jid);
        var list = $('#' + Jabber.conversation_prefix + Jabber.jid_to_id(room_jid) + ' .occupants ul');
        var item = $(list).find('a[data-id='+ jid_id +']');
        Jabber.insert_or_update_user(list, item, jid, name, presence, Jabber.template('.occupant-item'), 'chat');
        if (Jabber.rooms[Jabber.jid_to_id(room_jid)] === undefined) {
           Jabber.rooms[Jabber.jid_to_id(room_jid)] = {};
        }
        Jabber.rooms[Jabber.jid_to_id(room_jid)][name] = jid;
        list.parents('.occupants').find('.occupants-online').text(list.find('li').length);
     },

     remove_contact: function(jid) {
        var jid_id = Jabber.jid_to_id(jid)
        log('Removing contact ' + jid);
        $('#' + jid_id).parent('li').remove();
     },

     render_body_message: function(body) {
        body = body.replace(/\r?\n/g, '<br>');
        body = $().emoticon(body);
        body = linkify(body, {
           callback: function(text, href) {
              return href ? '<a href="' + href + '" title="' + href + '" target="_blank">' + text + '</a>' : text;
           }
        });
        return body;
     },

     show_message: function (jid, name, body, who, identifier, time, offset) {
        if(!offset) offset = 0;
         if (body) {
            body = Jabber.render_body_message(body);
            var jid_id = Jabber.jid_to_id(jid);
            var tab_id = '#' + Jabber.conversation_prefix + jid_id;
            var history = $(tab_id).find('.history');

            var offset_container = $('#chat-offset-container-'+offset);
            if(offset_container.length == 0)
	      offset_container = $('<div id="chat-offset-container-'+offset+'"></div>').prependTo(history);

            if (offset_container.find('.message:last').attr('data-who') == who) {
               offset_container.find('.message:last .content').append('<p>' + body + '</p>');
            }
            else {
               if (time==undefined) {
                  time = new Date().toISOString();
               }
               var message_html = Jabber.template('.message')
                 .replace('%{message}', body)
                 .replace(/%{who}/g, who)
                 .replace('%{time}', time)
                 .replace('%{name}', name)
                 .replace('%{avatar}', getAvatar(identifier));
               offset_container.append(message_html);
               $(".message span.time").timeago();
            }
            if(offset == 0) history.scrollTo({top:'100%', left:'0%'});
            else history.scrollTo(offset_container.height());
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
           .addClass('icon-menu-' + (presence || 'offline'));
        $('#buddy-list #user-status img.avatar').replaceWith(getMyAvatar());
        $.get('/chat/update_presence_status', { status: {chat_status: presence, last_chat_status: presence} });
     },

     send_availability_status: function(presence) {
        log('send availability status ' + presence);
        Jabber.connection.send($pres().c('show').t(presence).up());
        Jabber.show_status(presence);
     },

     enter_room: function(room_jid) {
        Jabber.connection.send(
           $pres({to: room_jid + '/' + $own_name}).c('x', {xmlns: Strophe.NS.MUC}).c('history', {maxchars: 0})
        );
        Jabber.insert_or_update_group(room_jid, 'group');
        Jabber.update_chat_title();
     },

     leave_room: function(room_jid) {
        Jabber.connection.send($pres({from: Jabber.connection.jid, to: room_jid + '/' + $own_name, type: 'unavailable'}))
        //FIXME remove group
     },

     update_chat_title: function () {
        var friends_online = $('#buddy-list #friends .buddy-list.online li').length;
        $('#friends-online').text(friends_online);
        var friends_offline = $('#buddy-list #friends .buddy-list.offline li').length;
        $('#friends-offline').text(friends_offline);
        var groups_online = $('#buddy-list #rooms .buddy-list li').length;
        $('#groups-online').text(groups_online);
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
              $('#buddy-list ul.buddy-list, .occupants ul.occupant-list').html('');
              Jabber.update_chat_title();
              $('#buddy-list .toolbar').removeClass('small-loading-dark');
              $('textarea').prop('disabled', 'disabled');
              break;
           case Strophe.Status.CONNECTED:
              log('connected');
           case Strophe.Status.ATTACHED:
              log('XMPP/BOSH session attached');
              $('#buddy-list .toolbar').removeClass('small-loading-dark');
              $('textarea').prop('disabled', '');
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
           if ($(stanza).find('x[xmlns="'+ Strophe.NS.MUC_USER +'"]').length > 0) {
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
                 if(presence.show=='offline') {
                   console.log(Jabber.presence_status);
                   Jabber.send_availability_status(Jabber.presence_status);
                 }
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
        Jabber.show_message(jid, name, escape_html(message.body), 'other', Strophe.getNodeFromJid(jid));
	notifyMessage(message);
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
           Jabber.show_message(message.from, name, escape_html(message.body), name, Strophe.getNodeFromJid(jid));
        }
	notifyMessage(message);
        return true;
     },

     on_message_error: function (message) {
        message = Jabber.parse(message)
        var jid = Strophe.getBareJidFromJid(message.from);
        log('Receiving error message from ' + jid);
        var body = Jabber.template('.error-message').replace('%{text}', message.error);
        Jabber.show_message(jid, Jabber.name_of(Jabber.jid_to_id(jid)), body, 'other', Strophe.getNodeFromJid(jid));
        return true;
     },

     on_muc_support: function(iq) {
        if ($(iq).find('identity[category=conference]').length > 0 && $(iq).find('feature[var="'+ Strophe.NS.MUC +'"]').length > 0) {
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
        Jabber.show_message(jid, $own_name, escape_html(body), 'self', Strophe.getNodeFromJid(Jabber.connection.jid));
     },

     is_a_room: function(jid_id) {
        return Jabber.type_of(jid_id) == 'groupchat';
     },

     show_notice: function(jid_id, msg) {
        var tab_id = '#' + Jabber.conversation_prefix + jid_id;
        $(tab_id).find('.history').append("<span class='notice'>" + msg + "</span>");
     }
   };

   $('#chat-connect').live('click', function() {
      Jabber.presence_status = 'chat';
      Jabber.connect();
   });

   $('#chat-disconnect').click(function() {
      disconnect();
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
   $('#chat').bind('opengroup', function(ev, anchor) {
      var full_jid = anchor.replace('#', '');
      var jid = Strophe.getBareJidFromJid(full_jid);
      var name = Strophe.getResourceFromJid(full_jid);
      var jid_id = Jabber.jid_to_id(full_jid);
      if (full_jid) {
         if (Strophe.getDomainFromJid(jid) == Jabber.muc_domain) {
            if (Jabber.muc_supported) {
               log('opening groupchat with ' + jid);
               Jabber.jids[jid_id] = {jid: jid, name: name, type: 'groupchat'};
               Jabber.enter_room(jid);
               var conversation = create_conversation_tab(name, jid_id);
               conversation.find('.conversation').show();
               recent_messages(jid);
            }
         }
         else {
            log('opening chat with ' + jid);
            var conversation = create_conversation_tab(name, jid_id);
            conversation.find('.conversation').show();
            recent_messages(jid);
         }
	 conversation.find('.input').focus();
      }
   });

   $('.conversation textarea').live('keydown', function(e) {
     if (e.keyCode == 13) {
        var jid = $(this).attr('data-to');
        var body = $(this).val();
        body = body.stripScripts();
        save_message(jid, body);
        Jabber.deliver_message(jid, body);
        $(this).val('');
        return false;
     }
   });

   function save_message(jid, body) {
      $.post('/chat/save_message', {
        to: getIdentifier(jid),
        body: body
      });
   }

   // open new conversation or change to already opened tab
   $('#buddy-list .buddies li a').live('click', function() {
      var jid_id = $(this).attr('id');
      var name = Jabber.name_of(jid_id);
      var conversation = create_conversation_tab(name, jid_id);

      conversation.find('.conversation').show();
      count_unread_messages(jid_id, true);
      recent_messages(Jabber.jid_of(jid_id));
      conversation.find('.conversation .input-div textarea.input').focus();
   });

   // put name into text area when click in one occupant
   $('.occupants .occupant-list li a').live('click', function() {
      var jid_id = $(this).attr('data-id');
      var name = Jabber.name_of(jid_id);
      var val = $('.conversation textarea:visible').val();
      $('.conversation textarea:visible').focus().val(val + name + ', ');
   });

   $('#chat .conversation .history').live('click', function() {
      $('.conversation textarea:visible').focus();
   });

   $('#chat .conversation .back').live('click', function() {
      $('#chat #chat-window .conversation').hide();
   });

   $('#chat .toolbar .back').live('click', function() {
      $('#chat').hide('fast');
   });

   function create_conversation_tab(title, jid_id) {
      var conversation_id = Jabber.conversation_prefix + jid_id;
      var conversation = $('#' + conversation_id);
      if (conversation.length > 0) {
         return conversation;
      }

      var jid = Jabber.jid_of(jid_id);
      var identifier = getIdentifier(jid);

      // opening chat with selected online friend
      var panel = $('<div id="'+conversation_id +'"></div>').appendTo($conversations);
      panel.append(Jabber.template('.conversation-template'));
      panel.find('.chat-target .avatar').replaceWith(getAvatar(identifier));
      panel.find('.chat-target .other-name').html(title);
      $('#chat .history').perfectScrollbar();

      panel.find('.history').scroll(function(){
        if($(this).scrollTop() == 0){
          var offset = panel.find('.message p').size();
          recent_messages(jid, offset);
        }
      });

      var textarea = panel.find('textarea');
      textarea.attr('name', panel.id);

      if (Jabber.is_a_room(jid_id)) {
          panel.find('.conversation').append(Jabber.template('.occupant-list-template'));
          panel.find('.history').addClass('room');
          $('#chat .occupants .occupant-list').perfectScrollbar();
      }
      textarea.attr('data-to', jid);

      return panel;
   }

   function ensure_scroll(jid, offset) {
     var jid_id = Jabber.jid_to_id(jid);
     var history = jQuery('#conversation-'+jid_id+' .history');
     // Load more messages if was not enough to show the scroll
     if(history.prop('scrollHeight') - history.prop('clientHeight') <= 0){
       var offset = history.find('.message p').size();
       recent_messages(jid, offset);
     }
   }

   function recent_messages(jid, offset) {
     if(!offset) offset = 0;
     start_fetching('.history');
     $.getJSON('/chat/recent_messages', {identifier: getIdentifier(jid), offset: offset}, function(data) {
       //TODO Register if no more messages returned and stop trying to load
       //     more messages in the future.
       $.each(data, function(i, message) {
         var body = message['body'];
         var from = message['from'];
         var to = message['to'];
         var date = message['created_at'];
         var who = from['id']==getCurrentIdentifier() ? 'self' : from['id']

         Jabber.show_message(jid, from['name'], body, who, from['id'], date, offset);
       });
       stop_fetching('.history');
       ensure_scroll(jid, offset);
     });
   }

   function count_unread_messages(jid_id, hide) {
      var unread = $('.buddies #'+jid_id+ ' .unread-messages');
      if (hide) {
         unread.hide();
         Jabber.unread_messages_of(jid_id, 0);
         unread.text('');
      }
      else {
         unread.show();
         var unread_messages = Jabber.unread_messages_of(jid_id) || 0;
         Jabber.unread_messages_of(jid_id, ++unread_messages);
         unread.text(unread_messages);
      }
      update_total_unread_messages();
   }

   function update_total_unread_messages() {
      var total_unread = $('#openchat .unread-messages');
      var sum = 0;
      $('.buddies .unread-messages').each(function() {
         sum += Number($(this).text());
      });
      if(sum>0) {
        total_unread.text(sum);
      } else {
        total_unread.text('');
      }
   }

   var $conversations = $('#chat-window #conversations');

   function log(msg) {
      if(Jabber.debug && window.console && window.console.log) {
         var time = new Date();
         window.console.log('['+ time.toTimeString() +'] ' + msg);
      }
   }

   function escape_html(body) {
      return body
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
   }

   function getCurrentIdentifier() {
     return getIdentifier(Jabber.connection.jid);
   }

   function getIdentifier(jid) {
     return Strophe.getNodeFromJid(jid);
   }

   function getMyAvatar() {
     return getAvatar(getCurrentIdentifier());
   }

   function getAvatar(identifier) {
     return '<img class="avatar" src="/chat/avatar/' + identifier + '">';
   }

   function disconnect() {
      log('disconnect');
      if (Jabber.connection && Jabber.connection.connected) {
         Jabber.connection.disconnect();
      }
      Jabber.presence_status = 'offline';
      Jabber.show_status('offline');
   }

   function notifyMessage(message) {
     var jid = Strophe.getBareJidFromJid(message.from);
     var jid_id = Jabber.jid_to_id(jid);
     var name = Jabber.name_of(jid_id);
     var identifier = Strophe.getNodeFromJid(jid);
     var avatar = "/chat/avatar/"+identifier
     if(!$('#chat').is(':visible') || window.isHidden()) {
       var options = {body: message.body, icon: avatar, tag: jid_id};
       notifyMe(name, options).onclick = function(){
         jQuery('#chat').show('fast');
         jQuery('a#'+jid_id).click();
       };
       $.sound.play('/sounds/receive.wav');
     }
   }

   $('.title-bar a').click(function() {
     $(this).parents('.status-group').find('.buddies').toggle('fast');
   });
   $('#chat').on('click', '.occupants a', function() {
     $(this).siblings('.occupant-list').toggle('fast');
     $(this).toggleClass('up');
   });

   //restore connection if user was connected
   if($presence=='' || $presence == 'chat') {
      $('#chat-connect').trigger('click');
   } else if($presence == 'dnd') {
      $('#chat-busy').trigger('click');
   }

   $('#chat #buddy-list .buddies').perfectScrollbar();

  // custom css expression for a case-insensitive contains()
  jQuery.expr[':'].Contains = function(a,i,m){
      return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase())>=0;
  };

  $('#chat .search').change( function () {
    var filter = $(this).val();
    var list = $('#buddy-list .buddies a');
    if(filter) {
      // this finds all links in a list that contain the input,
      // and hide the ones not containing the input while showing the ones that do
      $(list).find("span:not(:Contains(" + filter + "))").parent().hide();
      $(list).find("span:Contains(" + filter + ")").parent().show();
    } else {
      $(list).show();
    }
    return false;
  }).keyup( function () {
    // fire the above change event after every letter
    $(this).change();
  });

  $('#chat .buddies a').live('click', function(){
    $('#chat .search').val('').change();
  });
});
