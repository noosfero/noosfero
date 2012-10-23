var DojoPing = {
    BOSH_SERVICE: '/xmpp-httpbind',
    TARGET: 'jabber.org',
    connection: null
};

dojo.addOnLoad(function () {
    dojo.connect(dojo.byId('connect'), "click", function (e) {
        var jid = dojo.attr(dojo.byId('jid'), 'value');
        var pass_node = dojo.byId('pass');
        var pass = dojo.attr(pass_node, 'value');
        dojo.attr(pass_node, 'value', '');
        
        DojoPing.connection = new Strophe.Connection(DojoPing.BOSH_SERVICE);
        
        dojo.place("<p>Connecting...</p>", "log");

        DojoPing.connection.connect(jid, pass, function (status) {
            if (status === Strophe.Status.CONNECTED) {
                dojo.publish('connected');
            } else if (status === Strophe.Status.DISCONNECTED) {
                dojo.publish('disconnected');
            }
        });
    });

    dojo.subscribe('connected', function () {
        dojo.place("<p>Connected.</p>", "log");

        var ping = $iq({to: DojoPing.TARGET, type: 'get'})
            .c('query', {xmlns: Strophe.NS.DISCO_ITEMS});

        var sent_stamp = new Date();
        DojoPing.connection.sendIQ(ping, function (iq) {
            var elapsed = new Date() - sent_stamp;

            // use dojo.query on incoming stanza
            var items = dojo.query('items', iq);
            console.log(items);

            dojo.place("<p>Disco#items response received after " +
                       elapsed + "ms." + DojoPing.TARGET + " reports " +
                       "it has " + items + " disco items.</p>", "log");

            DojoPing.connection.disconnect();
        });

        DojoPing.connection.send(ping);
        
        dojo.place("<p>Ping sent to " + DojoPing.TARGET + ".</p>", "log");
    });

    dojo.subscribe('disconnected', function () {
        dojo.place("<p>Disconnected.</p>", "log");        
    });
});