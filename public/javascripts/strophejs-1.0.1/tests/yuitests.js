YUI().use("test", "console", function (Y) {
    Y.namespace("strophe.test");
    var Assert = Y.Assert;

    Y.strophe.test.JIDTestCase = new Y.Test.Case({
        name: "JIDs",

        testNormalJid: function () {
            var jid = "darcy@pemberley.lit/library";

            Assert.areSame("darcy", Strophe.getNodeFromJid(jid));
            Assert.areSame("pemberley.lit", Strophe.getDomainFromJid(jid));
            Assert.areSame("library", Strophe.getResourceFromJid(jid));
            Assert.areSame("darcy@pemberley.lit",
                           Strophe.getBareJidFromJid(jid));
        }
    });

    Y.strophe.test.StropheSuite = new Y.Test.Suite("Strophe Suite");
    Y.strophe.test.StropheSuite.add(Y.strophe.test.JIDTestCase);

    new Y.Console({newestOnTop: false}).render('#console');

    Y.Test.Runner.add(Y.strophe.test.StropheSuite);
    Y.Test.Runner.run();
});
