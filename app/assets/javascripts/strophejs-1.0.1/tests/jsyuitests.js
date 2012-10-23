YUI.add('strophe.test', function (Y) {
    Y.namespace("strophe.test");
    var R = Y.namespace("strophe.test.Runner");

    R.add = function (suite) {
        for (var i = 0; i < suite.items.length; i++) {
            TestCase(suite.items[i].name, suite.items[i]);
        }
    };
}, '1.0', {requires: ['test']});

YUI().use("test", "strophe.test", function (Y) {
    var Assert = Y.Assert;

    var suite = new Y.Test.Suite("Strophe Tests");
    suite.add(new Y.Test.Case({
        name: "JIDs",

        testNormalJid: function () {
            var jid = "darcy@pemberley.lit/library";

            Assert.areSame("darcy", Strophe.getNodeFromJid(jid));
            Assert.areSame("pemberley.lit", Strophe.getDomainFromJid(jid));
            Assert.areSame("library", Strophe.getResourceFromJid(jid));
            Assert.areSame("darcy@pemberley.lit",
                           Strophe.getBareJidFromJid(jid));
        }
    }));

    Y.strophe.test.Runner.add(suite);
});
