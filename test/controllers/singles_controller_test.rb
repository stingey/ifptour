require 'test_helper'

class SinglesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get singles_index_url
    assert_response :success
  end

end
