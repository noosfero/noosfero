(function($) {
  "use strict";

  var VoteOnce = {
    init: function() {
      this.cacheDom();
      this.setEvents();
    },


    cacheDom: function() {
      this.$vote_once_checkbox = $("#organization_ratings_config_vote_once");
      this.$hours_timer_input = $("#organization_ratings_config_cooldown");
    },


    setEvents: function() {
      this.$vote_once_checkbox.on("click", this.verifyHoursTimerDisable.bind(this));
    },


    verifyHoursTimerDisable: function() {
      if (this.$vote_once_checkbox.is(":checked")) {
        //this.$hours_timer_input.attr("disabled", "disabled");
        this.disableVoteOnce();
      } else {
        //this.$hours_timer_input.removeAttr("disabled");
        this.enableVoteOnce();
      }
    },


    enableVoteOnce: function() {
      this.$hours_timer_input.removeAttr("disabled");
    },


    disableVoteOnce: function() {
      this.$hours_timer_input.attr("disabled", "disabled");
    }
  }


  $(document).ready(function() {
    VoteOnce.init();
  });
}) (jQuery);
