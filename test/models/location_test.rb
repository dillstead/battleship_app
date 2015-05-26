require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  def setup
    board = boards(:new_board)
    @new_location = board.locations.build(ship: "A-2", x: 0, y: 0, hit: false, 
      coordinate: "A-1")
  end
  
  test "state_should_be_hit" do
    @new_location.hit = true
    assert_equal "hit", @new_location.state
  end
  
  test "state_should_be_miss" do
    @new_location.hit = true
    @new_location.ship = ""
    assert_equal "miss", @new_location.state
  end
  
  test "state_should_be_open" do
    @new_location.ship = ""
    assert_equal "open", @new_location.state
  end
  
  test "state_should_be_ship" do
    assert_equal "ship", @new_location.state
  end
  
  test "should_be_valid" do
    assert @new_location.valid?
  end
  
  test "board_id_should_be_present" do
    @new_location.board_id = nil
    assert_not @new_location.valid?
  end
  
  test "coordinate_should_be_valid" do
    # Coordinates range from [A - J]-[1 - 10]
    @new_location.coordinate = "K-1"
    assert_not @new_location.valid?
    @new_location.coordinate = "A-11"
    assert_not @new_location.valid?
    @new_location.coordinate = "A-0"
    assert_not @new_location.valid?
  end
  
  test "ship_should_be_valid" do
    # Ships range from [A - E]-[2 - 5]
    @new_location.ship = "F-2"
    assert_not @new_location.valid?
    @new_location.ship = "A-1"
    assert_not @new_location.valid?
    @new_location.ship = "A-6"
    assert_not @new_location.valid?
  end
  
  test "x_should_be_valid" do
    # X ranges from 0 - 9
    @new_location.x = -1
    assert_not @new_location.valid?
    @new_location.x = 10
    assert_not @new_location.valid?
  end
  
  test "y_should_be_valid" do
    # Y ranges from 0 - 9
    @new_location.y = -1
    assert_not @new_location.valid?
    @new_location.y = 10
    assert_not @new_location.valid?
  end
end
