require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  test "should get status" do
    get :status
    assert_response :success
  end

  test "should get fire" do
    get :fire
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get join" do
    get :join
    assert_response :success
  end

end
