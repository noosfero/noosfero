module PerformanceHelper

  # Testing blog page display. It should not present a linear increase in time
  # needed to display a blog page with the increase in number of posts.
  #
  # GOOD          BAD
  #
  # ^             ^     /
  # |             |    /
  # |   _____     |   /
  # |  /          |  /
  # | /           | /
  # |/            |/
  # +--------->   +--------->
  # 0  50  100    0  50  100
  #
  # On the travis/gitlab CI this can vary with servers' IO load, so
  # we soften to avoid failures
  #
  NON_LINEAR_FACTOR = unless ENV['CI'] then 1.8 else 1.0 end

end

