# This file overrides the fast_xs.so extension provided by hpricot. That breaks
# Builder, cfe. https://github.com/hpricot/hpricot/issues/53
class String
  alias :fast_xs :to_xs
end
