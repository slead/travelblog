require 'test_helper'

class GetpinsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get getpins_index_url
    assert_response :success
  end

end
