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
    conversations_order: null,
    notification_sound: new Audio('/sounds/receive.wav'),
    notification_counter: 0,
    window_visibility: null,
    window_title: document.title,
    jids: {},
    rooms: {},
    no_more_messages: {},
    avatars: {},
    favico: new Favico({animation: 'popFade'}),

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
    presence_of: function(jid_id) {
      return Jabber.jids[jid_id].presence;
    },
    unread_messages_of: function(jid_id, value) {
      Jabber.jids[jid_id].unread_messages = (value == undefined ? Jabber.jids[jid_id].unread_messages : value);
      return Jabber.jids[jid_id].unread_messages;
    },

    insert_or_update_user: function (list, item, jid, name, presence, template, type, remove_on_offline) {
      var jid_id = Jabber.jid_to_id(jid);
      var identifier = Strophe.getNodeFromJid(jid);
      var html = template
      .replace('%{jid_id}', jid_id)
      .replace(/%{presence_status}/g, presence)
      .replace('%{avatar}', getAvatar(identifier))
      .replace('%{name}', name);

      $(item).parent().remove();
      if(presence != 'offline' || !remove_on_offline){
        $(list).append(html);
        sort_conversations();
      }
      Jabber.jids[jid_id] = {jid: jid, name: name, type: type, presence: presence};
    },
    insert_or_update_group: function (jid, presence) {
      var jid_id = Jabber.jid_to_id(jid);
      var list = $('#buddy-list .buddies ul.'+presence);
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
      var list = $('#buddy-list .buddies ul' + (presence=='offline' ? '.offline' : '.online'));

      log('adding or updating contact ' + jid + ' as ' + presence);
      Jabber.insert_or_update_user(list, item, jid, name, presence, Jabber.template('.buddy-item'), 'chat');
      $("#chat-window .tab a[href='#"+ Jabber.conversation_prefix + jid_id +"']")
      .removeClass()
      .addClass('icon-menu-' + presence + '-11');
    },
    insert_or_update_occupant: function (jid, name, presence, room_jid) {
      log('adding or updating occupant ' + jid + ' as ' + presence);
      var jid_id = Jabber.jid_to_id(jid);
      var room_jid_id = Jabber.jid_to_id(room_jid);
      var list = $('#' + Jabber.conversation_prefix + room_jid_id + ' .occupants ul');
      var item = $(list).find('a[data-id='+ jid_id +']');
      Jabber.insert_or_update_user(list, item, jid, name, presence, Jabber.template('.occupant-item'), 'chat', true);
      if (Jabber.rooms[room_jid_id] === undefined)
        Jabber.rooms[room_jid_id] = {};

      var room = Jabber.rooms[room_jid_id];
      if(presence == 'offline') {
        delete Jabber.rooms[room_jid_id][name];
      }
      else {
        Jabber.rooms[room_jid_id][name] = jid;
      }

      list.parents('.occupants').find('.occupants-online').text(Object.keys(Jabber.rooms[room_jid_id]).length);
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

        var offset_container = history.find('.chat-offset-container-'+offset);
        if(offset_container.length == 0)
          offset_container = $('<div class="chat-offset-container-'+offset+'"></div>').prependTo(history);

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

        if(offset == 0) history.scrollTo({top:'100%', left:'0%'});
        else history.scrollTo(offset_container.height());
        if (who != "self") {
          if ($(tab_id).find('.history:visible').length == 0 || !$('#chat').hasClass('opened')) {
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

    enter_room: function(jid, push) {
      if(push == undefined)
        push = true
      var jid_id = Jabber.jid_to_id(jid);
      var conversation_id = Jabber.conversation_prefix + jid_id;
      var button = $('#' + conversation_id + ' .join');
      button.hide();
      button.siblings('.leave').show();
      Jabber.connection.send(
        $pres({to: jid + '/' + $own_name}).c('x', {xmlns: Strophe.NS.MUC}).c('history', {maxchars: 0})
      );
      Jabber.insert_or_update_group(jid, 'online');
      Jabber.update_chat_title();
      sort_conversations();
      if(push)
        $.post('/chat/join', {room_id: jid});
    },

    leave_room: function(jid, push) {
      if(push == undefined)
        push = true
      var jid_id = Jabber.jid_to_id(jid);
      var conversation_id = Jabber.conversation_prefix + jid_id;
      var button = $('#' + conversation_id + ' .leave');
      button.hide();
      button.siblings('.join').show();
      Jabber.connection.send($pres({from: Jabber.connection.jid, to: jid + '/' + $own_name, type: 'unavailable'}))
      Jabber.insert_or_update_group(jid, 'offline');
      sort_conversations();
      if(push)
        $.post('/chat/leave', {room_id: jid});
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
          setTimeout(function(){Jabber.connect()}, 10000);
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
        if(Jabber.presence_status != 'offline')
          Jabber.connect();
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
      var profiles = [];
      var contacts_to_insert = {};
      var groups_to_insert = [];

      //FIXME User ejabberd roster when the username length limit bug is solved.
      // $(iq).find('item').each(function () {
      //   var jid = $(this).attr('jid');
      //   profiles.push(getIdentifier(jid));
      //   var name = $(this).attr('name') || jid;
      //   var jid_id = Jabber.jid_to_id(jid);
      //   contacts_to_insert[jid] = name;
      // });

      $.ajax({
        url: '/chat/rosters',
        dataType: 'json',
        success: function(data){
          $(data.friends).each(function(index, friend){
            var jid = friend.jid;
            profiles.push(getIdentifier(jid));
            var name = friend.name;
            var jid_id = Jabber.jid_to_id(jid);
            contacts_to_insert[jid] = name;
          });

          $(data.rooms).each(function(index, room){
            profiles.push(getIdentifier(room.jid));
            var jid_id = Jabber.jid_to_id(room.jid);
            Jabber.jids[jid_id] = {jid: room.jid, name: room.name, type: 'groupchat'};
            //FIXME This must check on session if the user is inside the room...
            groups_to_insert.push(room.jid);
          });

          $.post('/chat/avatars', {profiles: profiles}, function(data) {
            for(identifier in data)
              Jabber.avatars[identifier] = data[identifier];

            // Insert contacts
            for(contact_jid in contacts_to_insert)
              Jabber.insert_or_update_contact(contact_jid, contacts_to_insert[contact_jid]);

            // Insert groups
            for (var i = 0; i < groups_to_insert.length; i++)
            Jabber.insert_or_update_group(groups_to_insert[i], 'offline');

            $.getJSON('/chat/recent_conversations', {}, function(data) {
              Jabber.conversations_order = data;
              sort_conversations();
            });

            // set up presence handler and send initial presence
            Jabber.connection.addHandler(Jabber.on_presence, null, "presence");
            Jabber.send_availability_status(Jabber.presence_status);
            load_defaults();
            updateAvailabilities();
          }, 'json');
        },
        error: function(data, textStatus, jqXHR){
          console.log(data);
        },
      });
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
          setFriendStatus(jid, presence.show);
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
      renew_conversation_order(jid);
      notifyMessage(message);
      return true;
    },

    on_public_message: function (message) {
      message = Jabber.parse(message);
      log('receiving message from ' + message.from);
      var name = Strophe.getResourceFromJid(message.from);
      // is a message from the room itself
      if (! name) {
        // FIXME Ignoring message from room for now.
        // Jabber.show_notice(Jabber.jid_to_id(message.from), message.body);
      }
      // is a message from another user, not mine
      else if ($own_name != name) {
        var jid = Jabber.rooms[Jabber.jid_to_id(message.from)][name];
        Jabber.show_message(message.from, name, escape_html(message.body), name, Strophe.getNodeFromJid(jid));
        renew_conversation_order(jid);
        notifyMessage(message);
      }
      return true;
    },

    on_message_error: function (message) {
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
      if (("Notification" in window) && Notification.permission !== "granted" && Notification.permission !== "denied") {
        Notification.requestPermission(function (permission) {
          if (!('permission' in Notification)) {
            Notification.permission = permission;
          }
        });
      }

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
      var jid_id = Jabber.jid_to_id(jid);
      var type = Jabber.type_of(jid_id);
      var presence = Jabber.presence_of(jid_id);
      var message = $msg({to: jid, from: Jabber.connection.jid, "type": type})
      .c('body').t(body).up()
      .c('active', {xmlns: Strophe.NS.CHAT_STATES});
      Jabber.connection.send(message);
      Jabber.show_message(jid, $own_name, escape_html(body), 'self', Strophe.getNodeFromJid(Jabber.connection.jid));
      save_message(jid, body);
      renew_conversation_order(jid);
      move_conversation_to_the_top(jid);
      if (presence == 'offline')
        Jabber.show_notice(jid_id, $user_unavailable_error);
    },

    is_a_room: function(jid_id) {
      return Jabber.type_of(jid_id) == 'groupchat';
    },

    show_notice: function(jid_id, msg) {
      var tab_id = '#' + Jabber.conversation_prefix + jid_id;
      var history = $(tab_id).find('.history');
      var notice = $(tab_id).find('.history .notice');
      if (notice.length > 0)
        notice.html(msg)
      else
        $(tab_id).find('.history').append("<span class='notice'>" + msg + "</span>");
      history.scrollTo({top:'100%', left:'0%'});
    },

    remove_notice: function(jid_id) {
      var tab_id = '#' + Jabber.conversation_prefix + jid_id;
      var notice = $(tab_id).find('.history .notice').remove();
    },
  };

  $('#chat-connect').live('click', function() {
    Jabber.presence_status = 'chat';
    Jabber.connect();
    $('#chat .simplemenu-submenu').hide();
    return false;
  });

  $('#chat-disconnect').click(function() {
    disconnect();
    $('#chat .simplemenu-submenu').hide();
    return false;
  });

  $('#chat-busy').click(function() {
    Jabber.presence_status = 'dnd';
    Jabber.connect();
    $('#chat .simplemenu-submenu').hide();
    return false;
  });

  $('#chat-retry').live('click', function() {
    Jabber.presence_status = Jabber.presence_status || 'chat';
    Jabber.connect();
    return false;
  });

  $('.conversation textarea').live('keydown', function(e) {
    if (e.keyCode == 13) {
      var jid = $(this).attr('data-to');
      var body = $(this).val();
      body = $('<div>'+ body +'</div>').find('script,noscript,style').remove().end().html();
      Jabber.deliver_message(jid, body);
      $(this).val('');
      return false;
    }
  });

  function save_message(jid, body) {
    $.post('/chat/save_message', {
      to: getIdentifier(jid),
      body: body
    }, function(data){
      if(data.status > 0){
        console.log(data.message);
        if(data.backtrace) console.log(data.backtrace);
      }
    }).fail(function(){
      console.log('500 - Internal server error.')
    });
  }

  // open new conversation or change to already opened tab
  $('#buddy-list .buddies li a').live('click', function() {
    var jid = Jabber.jid_of($(this).attr('id'));
    open_conversation(jid);
    return false;
  });

  // put name into text area when click in one occupant
  $('.occupants .occupant-list li a').live('click', function() {
    var jid_id = $(this).attr('data-id');
    var name = Jabber.name_of(jid_id);
    var val = $('.conversation textarea:visible').val();
    $('.conversation textarea:visible').focus().val(val + name + ', ');
    return false;
  });

  $('#chat .conversation .history').live('click', function() {
    $('.conversation textarea:visible').focus();
  });

  function toggle_chat_window() {
    if(jQuery('#conversations .conversation').length == 0) jQuery('.buddies a').first().click();
    jQuery('#chat').toggleClass('opened');
    jQuery('#chat-label').toggleClass('opened');

    if($('#chat').hasClass('opened')) {
      var jid_id = $('#chat-window .conversation:visible').attr('id').replace(/^conversation-/, '');
      count_unread_messages(jid_id, true);
    }
  }

  function load_conversation(jid) {
    var jid_id = Jabber.jid_to_id(jid);
    var name = Jabber.name_of(jid_id);
    if (jid) {
      if (Strophe.getDomainFromJid(jid) == Jabber.muc_domain) {
        if (Jabber.muc_supported) {
          log('opening groupchat with ' + jid);
          Jabber.jids[jid_id] = {jid: jid, name: name, type: 'groupchat'};
          var conversation = create_conversation_tab(name, jid_id);
          Jabber.enter_room(jid);
          recent_messages(jid, 0, true);
          return conversation;
        }
      }
      else {
        log('opening chat with ' + jid);
        Jabber.jids[jid_id] = {jid: jid, name: name, type: 'chat'};
        var conversation = create_conversation_tab(name, jid_id);
        recent_messages(jid, 0, true);
        return conversation;
      }
    }
  }

  function update_notification_counter() {
    Jabber.notification_counter += 1;
    Jabber.favico.badge(Jabber.notification_counter);
    document.title = '(' + Jabber.notification_counter + ') ' +  Jabber.window_title;
  }

  function open_conversation(jid) {
    var conversation = load_conversation(jid);
    var jid_id = Jabber.jid_to_id(jid);

    $('.conversation').hide();
    conversation.show();
    conversation.find('.input').focus();
    $('#chat').addClass('opened');
    $('#chat-label').addClass('opened');
    $.post('/chat/tab', {tab_id: jid_id});
  }

  function create_conversation_tab(title, jid_id) {
    var conversation_id = Jabber.conversation_prefix + jid_id;
    var conversation = $('#' + conversation_id);
    if (conversation.length > 0) {
      return conversation;
    }

    var jid = Jabber.jid_of(jid_id);
    var identifier = getIdentifier(jid);

    var panel = $('#chat-templates .conversation').clone().appendTo($conversations).attr('id', conversation_id);
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
      panel.append(Jabber.template('.occupant-list-template'));
      panel.find('.history').addClass('room');
      var room_actions = $('#chat-templates .room-action').clone();
      room_actions.data('jid', jid);
      panel.find('.history').after(room_actions);
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

  function recent_messages(jid, offset, clear_unread) {
    if (Jabber.no_more_messages[jid]) return;

    if(!offset) offset = 0;
    start_fetching('.history');
    $.getJSON('/chat/recent_messages', {identifier: getIdentifier(jid), offset: offset}, function(data) {
      // Register if no more messages returned and stop trying to load
      // more messages in the future.
      if(data.length == 0)
        Jabber.no_more_messages[jid] = true;

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

      if(clear_unread){
        var jid_id = Jabber.jid_to_id(jid);
        count_unread_messages(jid_id, true);
      }
    });
  }

  function move_conversation_to_the_top(jid) {
    id = Jabber.jid_to_id(jid);
    var link = $('#'+id);
    var li = link.closest('li');
    var ul = link.closest('ul');
    ul.prepend(li);
  }

  function renew_conversation_order(jid){
    var i = Jabber.conversations_order.indexOf(jid);
    // Remove element from the list
    if(i >= 0) {
      var elem = Jabber.conversations_order[i];
      var a = Jabber.conversations_order.slice(0,i);
      var b = Jabber.conversations_order.slice(i+1, Jabber.conversations_order.length);
      Jabber.conversations_order = a.concat(b);
    } else
      var elem = jid;

    Jabber.conversations_order = Jabber.conversations_order.concat(elem);
  }

  function sort_conversations() {
    if(Jabber.conversations_order){
      for (var i = 0; i < Jabber.conversations_order.length; i++)
        move_conversation_to_the_top(Jabber.conversations_order[i]);
    }
  }

  function load_defaults() {
    $.getJSON('/chat/my_session', {}, function(data) {
      $.each(data.rooms, function(i, room_jid) {
        load_conversation(room_jid);
      })

      $('#'+data.tab_id).click();

      if(data.status == 'opened')
        toggle_chat_window();
    })
  }

  function count_unread_messages(jid_id, hide) {
    var unread = $('.buddies #'+jid_id+ ' .unread-messages');
    if (hide) {
      unread.hide();
      unread.siblings('img').show();
      Jabber.unread_messages_of(jid_id, 0);
      unread.text('');
    }
    else {
      unread.siblings('img').hide();
      unread.css('display', 'inline-block');
      var unread_messages = Jabber.unread_messages_of(jid_id) || 0;
      Jabber.unread_messages_of(jid_id, ++unread_messages);
      unread.text(unread_messages);
    }
    update_total_unread_messages();
  }

  function update_total_unread_messages() {
    var total_unread = $('#unread-messages');
    var sum = 0;
    $('#chat .unread-messages').each(function() {
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
    if(Jabber.avatars[identifier])
      var src = Jabber.avatars[identifier];
    else
      var src = "/chat/avatar/"+identifier;

    return '<img class="avatar" src="' + src + '">';
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
    if(!("Notification" in window))
      return null;
    var jid = Strophe.getBareJidFromJid(message.from);
    var jid_id = Jabber.jid_to_id(jid);
    var name = Jabber.name_of(jid_id);
    var identifier = Strophe.getNodeFromJid(jid);
    var avatar = "/chat/avatar/"+identifier

    if(window.isHidden() || !Jabber.window_visibility) {
      update_notification_counter();
    }

    if(!$('#chat').hasClass('opened') || window.isHidden() || !Jabber.window_visibility) {
      var options = {body: message.body, icon: avatar, tag: jid_id};
      $(notifyMe(name, options)).on('click', function(){
        open_conversation(jid);
      });
      Jabber.notification_sound.play();
    }
  }

  function setFriendStatus(jid, status) {
    if (jid != Jabber.connection.jid) {
      var jid_id = Jabber.jid_to_id(jid);
      var name = Jabber.name_of(jid_id);
      if(status == 'chat')
        Jabber.remove_notice(jid_id);
      Jabber.insert_or_update_contact(jid, name, status);
      Jabber.update_chat_title();
    }
    else {
      // why server sends presence from myself to me?
      log('ignoring presence from myself');
      if(status=='offline') {
        Jabber.send_availability_status(Jabber.presence_status);
      }
    }
  }

  $('.title-bar a').click(function() {
    $(this).parents('.status-group').find('.buddies').toggle('fast');
    return false;
  });
  $('#chat').on('click', '.occupants a', function() {
    $(this).siblings('.occupant-list').toggle('fast');
    $(this).toggleClass('up');
    return false;
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
    return false;
  });

  $('#chat-label').click(function(){
    toggle_chat_window();
    $.post('/chat/toggle');
  });

  $('.room-action.join').live('click', function(){
    var jid = $(this).data('jid');
    Jabber.enter_room(jid);
  });

  $('.room-action.leave').live('click', function(){
    var jid = $(this).data('jid');
    Jabber.leave_room(jid);
    return false;
  });

  $('.open-conversation').live('click', function(){
    open_conversation($(this).data('jid'));
    return false;
  });

  window.onfocus = function() {
    Jabber.window_visibility = true
    Jabber.favico.reset();
    Jabber.notification_counter = 0;
    document.title = Jabber.window_title;
  };
  window.onblur = function() {Jabber.window_visibility = false};

  //FIXME Workaround to solve availability problems
  function updateAvailabilities() {
    $.ajax({
      url: '/chat/availabilities',
      dataType: 'json',
      success: function(data){
        $(data).each(function(index, friend){
          var jid_id = Jabber.jid_to_id(friend.jid);
          if (Jabber.jids[jid_id].presence != friend.status)
            setFriendStatus(friend.jid, friend.status)
        });
      },
      complete: function(data){ setTimeout(updateAvailabilities, 10000) },
      error: function(data, textStatus, jqXHR){
        console.log(data);
      },
    });
  }
});
