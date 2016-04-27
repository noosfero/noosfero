require_relative '../test_helper'

class ProfileDesignControllerTest < ActionController::TestCase

  def setup
    @controller       = ProfileDesignController.new
    @product_category = create ProductCategory

    @profile = @holder = create_user('designtestuser').person
    holder.save!

    @box1 = Box.new
    @box2 = Box.new
    @box3 = Box.new

    holder.boxes << @box1
    holder.boxes << @box2
    holder.boxes << @box3

  end
  attr_reader :holder

  should 'be able to edit ProductsBlock' do
    block = ProductsBlock.new

    enterprise = fast_create(Enterprise, name: "test", identifier: 'testenterprise')
    enterprise.boxes << Box.new
    p1 = enterprise.products.create!(name: 'product one', product_category: @product_category)
    p2 = enterprise.products.create!(name: 'product two', product_category: @product_category)
    enterprise.boxes.first.blocks << block
    enterprise.add_admin(holder)

    enterprise.blocks(true)
    @controller.stubs(:boxes_holder).returns(enterprise)
    login_as('designtestuser')

    get :edit, profile: 'testenterprise', id: block.id

    assert_response :success
    assert_tag tag: 'input', attributes: { name: "block[product_ids][]", value: p1.id.to_s }
    assert_tag tag: 'input', attributes: { name: "block[product_ids][]", value: p2.id.to_s }
  end

  should 'be able to save ProductsBlock' do
    block = ProductsBlock.new

    enterprise = fast_create(Enterprise, name: "test", identifier: 'testenterprise')
    enterprise.boxes << Box.new
    p1 = enterprise.products.create!(name: 'product one', product_category: @product_category)
    p2 = enterprise.products.create!(name: 'product two', product_category: @product_category)
    enterprise.boxes.first.blocks << block
    enterprise.add_admin(holder)

    enterprise.blocks(true)
    @controller.stubs(:boxes_holder).returns(enterprise)
    login_as('designtestuser')

    post :save, profile: 'testenterprise', id: block.id, block: { product_ids: [p1.id.to_s, p2.id.to_s ] }

    assert_response :redirect

    block.reload
    assert_equal [p1.id, p2.id], block.product_ids

  end

end
