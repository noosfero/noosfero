(function($) {
  "use strict";

  var VoteOnce = {
    init: function() {
      this.cacheDom();
      this.setEvents();
    },


    cacheDom: function() {
      this.$vote_once_checkbox = $("#environment_organization_ratings_vote_once");
      this.$hours_timer_input = $("#environment_organization_ratings_cooldown");
    },


    setEvents: function() {
      this.$vote_once_checkbox.on("click", this.verifyHoursTimerDisable.bind(this));
    },


    verifyHoursTimerDisable: function() {
      if (this.$vote_once_checkbox.is(":checked")) {
        this.$hours_timer_input.attr("disabled", "disabled");
      } else {
        this.$hours_timer_input.removeAttr("disabled");
      }
    }
  }


  $(document).ready(function() {
    VoteOnce.init();
  });
}) (jQuery);
