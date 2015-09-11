;(function($, undefined) {
  "use strict";

  /*
  * All global data that are used in the stars feature.
  */
  var DATA = {
    selected_rate: 0, // The actual selected star when the user click on a star
    maximum_stars: 5, // (const) The maximum number of allowed stars
    minimum_stars: 1, // (const) The minimum number of allowed stars
    DATA_RATE_ATTRIBUTE: "data-star-rate", // (const) The data attribute with the star rate
    NOT_SELECTED_VALUE: 0 // (const) The value when there is no selected rate
  }


  /*
  * Prepare the global data that are variable.
  * If the user already rated the organization, set the selected_rate as the rated value
  */
  function set_global_data() {
    var selected_rate = parseInt($("#selected-star-rate").val());
    var minimum_stars = parseInt($("#minimum_stars").val());
    DATA.selected_rate = selected_rate;
    DATA.minimum_stars = minimum_stars;
  }


  /*
  * Given a start rate, an end rate and the elements, it makes a regex that filter
  * the elements by the given range and returns it.
  */
  function star_filter(start, end, elements) {
    var test_regex = undefined;

    // Verify if it is a valid range and makes its range regex: /[start-end]/
    if (end >= start) {
      test_regex = new RegExp("["+(start)+"-"+(end)+"]");
    } else {
      // If the range is invalid, make a regex that will return no element
      test_regex = new RegExp("[]");
    }

    // Filter the elements that are in the given range
    var result = elements.filter(function(i, element) {
      var rate = parseInt(element.getAttribute(DATA.DATA_RATE_ATTRIBUTE));

      return test_regex.test(rate);
    });

    return result;
  }


  /*
  * Show or hide the stars depending on the mouse position and the limit rate.
  * Given the mouseover rate, the limit rate and the css classes to be swapped,
  *
  * It verify if the user already selected a star rate:
  * If true:
  *   It swap the css classes from the selected star up to the given limit rate
  * If false:
  *   It swap the css classes from the minimum rate up to the mouseover rate
  */
  function change_stars_class(rate_mouseover, limit_rate, remove_class, add_class) {
    var previous_stars = undefined;

    // The default not selected rate value is 0 and minimum is 1.
    if (DATA.selected_rate >= DATA.minimum_stars) {
      previous_stars = star_filter(DATA.selected_rate+1, limit_rate, $("."+remove_class));
    } else {
      previous_stars = star_filter(DATA.minimum_stars, rate_mouseover, $("."+remove_class));
    }

    previous_stars.switchClass(remove_class, add_class);
  }


  /*
  * Sets the stars mouse events.
  */
  function set_star_hover_actions() {
    $(".star-negative, .star-positive")
      .on("mouseover", function() { // On mouse over, show the current rate star
        var rate_mouseover = parseInt(this.getAttribute(DATA.DATA_RATE_ATTRIBUTE));

        change_stars_class(rate_mouseover, rate_mouseover, "star-negative", "star-positive");
      })

      .on("mouseout", function() { // On mouse out, hide the stars
        var rate_mouseover = parseInt(this.getAttribute(DATA.DATA_RATE_ATTRIBUTE));

        change_stars_class(rate_mouseover, DATA.maximum_stars, "star-positive", "star-negative");
      })

      .on("click", function() { // On mouse click, set the selected star rate
        var rate_mouseover = parseInt(this.getAttribute(DATA.DATA_RATE_ATTRIBUTE));

        // If the new rate is different from actual, update it
        if (rate_mouseover !== DATA.selected_rate && rate_mouseover > DATA.minimum_stars) {
          DATA.selected_rate = rate_mouseover;
        } else { // or else, uncheck it
          DATA.selected_rate = DATA.minimum_stars;
        }

        // Mark the selected_rate
        $("#selected-star-rate").val(DATA.selected_rate);

        var star_notice = $(".star-notice");
        star_notice.find("span").html(DATA.selected_rate);
        star_notice.removeClass("star-hide");
      });
  }


  /*
  * When the page DOM is ready, set all the stars events
  */
  $(document).ready(function() {
    set_global_data();
    set_star_hover_actions();
  });
}) (jQuery);
