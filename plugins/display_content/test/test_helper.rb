require_relative "../../../test/test_helper"

def sort_by_data(array)
  return if array.blank?
  array.each {|el| el['children'] = sort_by_data(el['children']) }
  array.sort_by {|el| el['data']}
end

def assert_hash_equivalent(expected, response)
  assert_equal sort_by_data(expected), sort_by_data(response)
end
