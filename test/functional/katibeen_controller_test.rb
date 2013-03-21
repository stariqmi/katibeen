require 'test_helper'

class KatibeenControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get signup" do
    get :signup
    assert_response :success
  end

  test "should get performance" do
    get :performance
    assert_response :success
  end

end
