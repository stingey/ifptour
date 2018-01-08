require 'test_helper'

class HallOfFamesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get hall_of_fames_index_url
    assert_response :success
  end

end
