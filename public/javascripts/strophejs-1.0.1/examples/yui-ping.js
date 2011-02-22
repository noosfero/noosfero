YUI().use('node', function (Y) {
    var BOSH_SERVICE = '/xmpp-httpbind';
    var connection = null;

    var log = Y.one('#log');

    Y.augment(Strophe.Connection, Y.EventTarget);

    Y.one('#connect').on('click', function (e) {
        var jid = Y.one('#jid').get('value');
        var pass_node = Y.one('#pass');
        var pass = pass_node.get('value');
        pass_node.set('value', '');
        
        connection = new Strophe.Connection(BOSH_SERVICE);

        log.append('<p>Connecting...</p>');

        connection.connect(jid, pass, function (status) {
            if (status === Strophe.Status.CONNECTED) {
                connection.fire('connected');
            } else if (status === Strophe.Status.DISCONNECTED) {
                connection.fire('disconnected');
            }
        });

        connection.on('connected', function () {
            log.append('<p>Connected.</p>');

            var ping = $iq({to: 'jabber.org', type: 'get'})
                .c('query', {xmlns: Strophe.NS.DISCO_ITEMS});

            var sent_stamp = new Date();
            connection.sendIQ(ping, function (iq) {
                var elapsed = new Date() - sent_stamp;

                // convert incoming XMPP stanza to a Node
                var stanza = Y.Selector.query('item', iq, null, true);
                window['stanza'] = iq;
                window['Y'] = Y;

                console.log(stanza);

                log.append("<p>Disco#items response received after " + 
                           elapsed + "ms. Jabber.org reports it has " +
                           items + " items.</p>");

                connection.disconnect();
            });

            log.append('<p>Ping sent.</p>');
        });

        connection.on('disconnected', function () {
            log.append('<p>Disconnected.</p>');
        });
    });
});