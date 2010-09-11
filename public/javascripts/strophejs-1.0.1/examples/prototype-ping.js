var ProtoPing = {
    BOSH_SERVICE: '/xmpp-httpbind',
    TARGET: 'jabber.org',
    connection: null
};

document.observe('dom:loaded', function () {
    var log = $('log');

    $('connect').observe('click', function () {
        var jid = $F('jid');
        var pass = $F('pass');
        Form.Element.setValue('pass', '');
        
        ProtoPing.connection = new Strophe.Connection(ProtoPing.BOSH_SERVICE);
        
       log.insert("<p>Connecting...</p>");

        ProtoPing.connection.connect(jid, pass, function (status) {
            if (status === Strophe.Status.CONNECTED) {
                document.fire('strophe:connected');
            } else if (status === Strophe.Status.DISCONNECTED) {
                document.fire('strophe:disconnected');
            }
        });
    });

    document.observe('strophe:connected', function () {
        log.insert('<p>Connected.</p>');

        var ping = $iq({to: ProtoPing.TARGET, type: 'get'})
            .c('query', {xmlns: Strophe.NS.DISCO_ITEMS});

        var sent_stamp = new Date();
        ProtoPing.connection.sendIQ(ping, function (iq) {
            var elapsed = new Date() - sent_stamp;

            // use Prototype's selectors to access XMPP stanza
            var items = Selector.findChildElements(iq, ['item']);

            log.insert("<p>Disco#items response received after " +
                       elapsed + "ms." + ProtoPing.TARGET + " reports " +
                       "it has " + items + " disco items.</p>");

            ProtoPing.connection.disconnect();
        });

        ProtoPing.connection.send(ping);
        
        log.insert("<p>Ping sent to " + ProtoPing.TARGET + ".</p>");
    });

    document.observe('strophe:disconnected', function () {
        log.insert('<p>Disconnected.</p>');
    });
});