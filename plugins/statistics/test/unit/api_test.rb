require_relative '../../../../test/api/test_helper'


class ApiTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
    login_api
    environment.enable_plugin(StatisticsPlugin)
  end

  AVAILABLE_ATTRIBUTES = StatisticsBlock::USER_COUNTERS + StatisticsBlock::COMMUNITY_COUNTERS + StatisticsBlock::ENTERPRISE_COUNTERS

  AVAILABLE_ATTRIBUTES.map do |counter_attr|
    counter_method = counter_attr.to_s.gsub('_counter','').pluralize.to_sym
    define_method "test_should_return_#{counter_method}_attribute_in_statistics_block_if_#{counter_attr} is true" do
      person.boxes.destroy_all
      box = Box.create!(:owner => person)
      block = StatisticsBlock.create!(:box_id => box.id)
      block.send("#{counter_attr}=", true)
      block.save
      StatisticsBlock.any_instance.stubs(counter_method).returns(20)
      get "/api/v1/profiles/#{person.id}/boxes?#{params.to_query}"
      json = JSON.parse(last_response.body)
      statistics = json['boxes'].first['blocks'].first['statistics']
      statistic_for_method = statistics.select {|statistic| statistic if statistic['name'].eql? counter_method.to_s }
      assert_equal statistic_for_method.first['quantity'], 20
    end

    define_method "test_should_not_return_#{counter_method}_attribute_in_statistics_block_if_#{counter_attr} is false" do
      person.boxes.destroy_all
      box = Box.create!(:owner => person)
      block = StatisticsBlock.create!(:box_id => box.id)
      block.send("#{counter_attr}=", false)
      block.save
      StatisticsBlock.any_instance.stubs(counter_method).returns(20)
      get "/api/v1/profiles/#{person.id}/boxes?#{params.to_query}"
      json = JSON.parse(last_response.body)
      statistics = json['boxes'].first['blocks'].first['statistics']
      statistic_for_method = statistics.select {|statistic| statistic if statistic['name'].eql? counter_method.to_s }
      assert_nil statistic_for_method.first["quantity"]
    end
  end

end
