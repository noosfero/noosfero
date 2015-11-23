/*
*   jQuery.stickyPanel
*   ----------------------
*   version: 2.0.1
*   date: 3/13/13
*
*   Copyright (c) 2011 Donny Velazquez
*   http://donnyvblog.blogspot.com/
*   http://code.google.com/p/sticky-panel/
*   
*   Licensed under the Apache License 2.0
*
*   revisions
*   -----------------------
*   11/19/12 - re-architect plugin to use jquery.com best practices http://docs.jquery.com/Plugins/Authoring
*
*/
(function ($) {

    var methods = {

        options: {
            // Use this to set the top margin of the detached panel.
            topPadding: 0,

            // This class is applied when the panel detaches.
            afterDetachCSSClass: "",

            // When set to true the space where the panel was is kept open.
            savePanelSpace: false,

            // Event fires when panel is detached
            // function(detachedPanel, panelSpacer){....}
            onDetached: null,

            // Event fires when panel is reattached
            // function(detachedPanel){....}
            onReAttached: null,

            // Set this using any valid jquery selector to 
            // set the parent of the sticky panel.
            // If set to null then the window object will be used.
            parentSelector: null
        },
        init: function (options) {
            var options = $.extend({}, methods.options, options);

            return this.each(function () {
                var id = Math.ceil(Math.random() * 9999); /* Pick random number between 1 and 9999 */
                $(this).data("stickyPanel.state", {
                    stickyPanelId: id,
                    isDetached: false,
                    parentContainer: $((options.parentSelector ? options.parentSelector : window)),
                    options: options
                });

                if (options.parentSelector) {
                    var p = $(this).data("stickyPanel.state").parentContainer.css("position");
                    switch (p) {
                        case "inherit":
                        case "static":
                            $(this).data("stickyPanel.state").parentContainer.css("position", "relative");
                            break;
                    }
                }

                $(this).data("stickyPanel.state").parentContainer.bind("scroll.stickyPanel_" + id, {
                    selected: $(this)
                }, methods.scroll);
            });
        },
        scroll: function (event) {
            var node = event.data.selected;
            var o = node.data("stickyPanel.state").options//event.data.options;

            var parentContainer = node.data("stickyPanel.state").parentContainer;
            var parentHeight = parentContainer.height();
            var nodeHeight = node.outerHeight(true);
            var scrollTop = o.parentSelector ? parentContainer.scrollTop() : $(document).scrollTop();
            var docHeight = o.parentSelector ? parentContainer.height() : $(document).height();
            var HeightDiff = o.parentSelector ? parentHeight : (docHeight - parentHeight);

            var top = o.parentSelector ? node.position().top : node.offset().top;
            var topdiff = top - o.topPadding;
            var TopDiff = topdiff < 0 ? 0 : topdiff;

            // ** DEBUG **
            //console.log("scrollTop: " + scrollTop);
            //console.log("height: " + HeightDiff);
            //console.log("TopDiff: " + TopDiff);

            var isDetached = node.data("stickyPanel.state").isDetached;

            // when top of parent reaches the top of the panel detach
            if (scrollTop <= HeightDiff && // Fix for rubberband scrolling in Safari on Lion
        	    scrollTop > TopDiff &&
                !isDetached) {

                node.data("stickyPanel.state").isDetached = true;

                // topPadding
                var newNodeTop = 0;
                if (o.topPadding != "undefined") {
                    newNodeTop = newNodeTop + o.topPadding;
                }

                // get top & left before adding spacer
                var nodeLeft = o.parentSelector ? node.position().left : node.offset().left;
                var nodeTop = o.parentSelector ? node.position().top : node.offset().top;


                // save panels top
                node.data("PanelsTop", nodeTop - newNodeTop);

                // MOVED: savePanelSpace before afterDetachCSSClass to handle afterDetachCSSClass changing size of node
                // savePanelSpace
                var PanelSpacer = null;
                if (o.savePanelSpace == true) {
                    var nodeWidth = node.outerWidth(true);
                    var nodeCssfloat = node.css("float");
                    var nodeCssdisplay = node.css("display");
                    var randomNum = Math.ceil(Math.random() * 9999); /* Pick random number between 1 and 9999 */
                    node.data("stickyPanel.PanelSpaceID", "stickyPanelSpace" + randomNum);
                    PanelSpacer = $("<div id='" + node.data("stickyPanel.PanelSpaceID") + "' style='width:" +nodeWidth + "px;height:" + nodeHeight + "px;float:" + nodeCssfloat + ";display:" + nodeCssdisplay + ";'>&#20;</div>");
                    node.before(PanelSpacer);
                }

                // afterDetachCSSClass
                if (o.afterDetachCSSClass != "") {
                    node.addClass(o.afterDetachCSSClass);
                }

                // save inline css
                node.data("Original_Inline_CSS", (!node.attr("style") ? "" : node.attr("style")));

                // detach panel
                node.css({
                    "margin": 0,
                    "left": nodeLeft,
                    "top": newNodeTop,
                    "position": o.parentSelector ? "absolute" : "fixed",
					"width": node.outerWidth(false)
                });

                // fire detach event
                if (o.onDetached)
                    o.onDetached(node, PanelSpacer);

            }


            // Update top for div scrolling
            if (o.parentSelector && isDetached) {
                node.css({
                    "top": o.topPadding ? (scrollTop + o.topPadding) : scrollTop
                });
            }

            // ADDED: css top check to avoid continuous reattachment
            if (scrollTop <= node.data("PanelsTop") &&
                node.css("top") != "auto" &&
                isDetached) {

                methods.unstick(node);
            }
        },
        unstick: function (nodeRef) {
            var node = nodeRef ? nodeRef : this; ;
            node.data("stickyPanel.state").isDetached = false;

            var o = node.data("stickyPanel.state").options;

            if (o.savePanelSpace == true) {
                $("#" + node.data("stickyPanel.PanelSpaceID")).remove();
            }

            // attach panel
            node.attr("style", node.data("Original_Inline_CSS"));

            if (o.afterDetachCSSClass != "") {
                node.removeClass(o.afterDetachCSSClass);
            }

            // fire reattached event
            if (o.onReAttached)
                o.onReAttached(node);

            if (!nodeRef)
                methods._unstick(node);
        },
        _unstick: function (nodeRef) {
            nodeRef.data("stickyPanel.state").parentContainer.unbind("scroll.stickyPanel_" + nodeRef.data("stickyPanel.state").stickyPanelId);
        }
    };

    $.fn.stickyPanel = function (method) {
        // Method calling logic
        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.stickyPanel');
        }
    };

})(jQuery);
