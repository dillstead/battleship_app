require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  def setup
    game = games(:new_game)
    player = players(:new_player)
    @new_board = game.boards.create(player_id: player.id)
    @player1_board = boards(:playing_board_1);
    @player2_board = boards(:playing_board_2);
    @raw_locations = Array.new(10) { Array.new(10, "") }
  end
  
  test "should_be_valid" do
    assert @new_board.valid?
  end
  
  test "player_id_should_be_present" do
    @new_board.player_id = nil
    assert_not @new_board.valid?
  end
  
  test "game_id_should_be_present" do
    @new_board.game_id = nil
    assert_not @new_board.valid?
  end
  
  test "should_add_locations" do
    assert_difference('Location.count', 100) do
      @new_board.add_locations @raw_locations
    end
  end
  
  test "should_not_add_too_many_rows" do
    bad_locations = Array.new(11) { Array.new(10, "") }
    assert_no_difference('Location.count') do
      assert_raises(ArgumentError) { @new_board.add_locations bad_locations }
    end
  end
  
  test "should_not_add_too_many_columns" do
    bad_locations = Array.new(10) { Array.new(11, "") }
    assert_no_difference('Location.count') do
      assert_raises(ArgumentError) { @new_board.add_locations bad_locations }
    end
  end
  
  test "should_not_add_too_few_locations" do
    bad_locations = Array.new(3) { Array.new(7, "") }
    assert_no_difference('Location.count') do
      assert_raises(ArgumentError) { @new_board.add_locations bad_locations }
    end
  end
  
  test "should_not_add_invalid_ship" do
    @raw_locations[5][5] = "A-8"
    assert_no_difference('Location.count') do
      assert_raises(ArgumentError) { @new_board.add_locations @raw_locations }
    end
  end
  
  test "fire_should_hit" do
    assert_difference('Location.where(hit: true).count', 1) do
      hit, sunk, won = @player1_board.fire("D-1")
      assert hit
      assert_equal 0, sunk
      assert_not won
    end
  end
  
  test "fire_should_hit_and_sink" do
    assert_difference('Location.where(hit: true).count', 1) do
      hit, sunk, won = @player1_board.fire("C-1")
      assert hit
      assert_equal 3, sunk
      assert_not won
    end
  end
  
  test "fire_should_miss" do
    assert_difference('Location.where(hit: true).count', 1) do
      hit, sunk, won = @player1_board.fire("D-7")
      assert_not hit
      assert_equal 0, sunk
      assert_not won
    end
  end
  
  test "fire_should_win" do
    assert_difference('Location.where(hit: true).count', 1) do
      hit, sunk, won = @player2_board.fire("A-2")
      assert hit
      assert_equal 2, sunk
      assert won
    end
  end

end
