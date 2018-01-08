require 'test_helper'

class ProShopControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get pro_shop_show_url
    assert_response :success
  end

end
