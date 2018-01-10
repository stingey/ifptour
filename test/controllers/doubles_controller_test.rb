require 'test_helper'

class DoublesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get doubles_index_url
    assert_response :success
  end

end
