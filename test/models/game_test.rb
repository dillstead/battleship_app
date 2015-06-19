require 'test_helper'

class GameTest < ActiveSupport::TestCase
  def setup
    @new_board = Array.new(10) { Array.new(10, "") }
    @new_player = players(:new_player)
    @new_game = Game.create
    @finished_game = games(:finished_game)
    @waiting_game = games(:waiting_game)
    @waiting_player = players(:waiting_player)
    @playing_game = games(:playing_game)
    @player_1 = players(:playing_player_1)
    @player_2 = players(:playing_player_2)
    @winning_player = players(:winning_player)
    @losing_player = players(:losing_player)
  end
  
  test "should_be_valid" do
    assert @new_game.valid?
  end
  
  test "state_should_be_valid" do
    @new_game.state = "moving"
    assert_not @new_game.valid?
  end

  test "should_start_game" do
    assert_difference('Board.count', 1) do
      id = @new_game.start(@new_player, @new_board)
      assert_equal @new_game.id, id
      assert_equal "waiting", @new_game.state
      assert_equal @new_player.id, @new_game.turn_id
    end
  end
  
  test "should_not_start_with_bad_ship" do
    @new_board[5][5] = "A-8"
    assert_no_difference('Game.count') do
      assert_raises(ArgumentError) { @new_game.start @new_player, @new_board }
    end
  end
  
  test "should_not_start_waiting_game" do
    assert_raises(ArgumentError) { @waiting_game.start @new_player, @new_board }
  end
  
  test "should_not_start_playing_game" do
    assert_raises(ArgumentError) { @playing_game.start @new_player, @new_board }
  end
  
  test "should_not_start_finished_game" do
    assert_raises(ArgumentError) { @finished_game.start @new_player, @new_board }
  end
  
  test "should_join_game" do
    assert_difference('Board.count', 1) do
      id = @waiting_game.join(@new_player, @new_board)
      assert_equal @waiting_game.id, id
      assert_equal "playing", @waiting_game.state
      assert_equal @waiting_player.id, @waiting_game.turn_id
    end
  end
  
  test "should_not_join_with_bad_ship" do
    @new_board[5][5] = "A-8"
    assert_no_difference('Board.count') do
      assert_raises(ArgumentError) { @waiting_game.join @new_player, @new_board }
    end
  end

  test "should_not_join_new_game" do
    assert_no_difference('Board.count') do
      assert_raises(ArgumentError) { @new_game.join @new_player, @new_board }
    end
  end
  
  test "should_not_join_playing_game" do
    assert_no_difference('Board.count') do
      assert_raises(ArgumentError) { @playing_game.join @waiting_player, @new_board }
    end
  end
  
  test "should_not_join_finished_game" do
    assert_no_difference('Board.count') do
      assert_raises(ArgumentError) { @finished_game.join @new_player, @new_board }
    end
  end
  
  test "should_not_join_game_started" do
    assert_no_difference('Board.count') do
      assert_raises(ArgumentError) { @waiting_game.join @waiting_player, @new_board }
    end
  end
  
  test "fire_should_hit" do
    assert_difference('Location.where(hit: true, coordinate: "D-1").count', 1) do
      id, hit, sunk = @playing_game.fire(@player_2, "D-1")
      assert_equal @playing_game.id, id
      assert hit
      assert_equal 0, sunk
      assert_equal @player_1.id, @playing_game.turn_id
      assert_equal nil, @playing_game.winner_id
      assert_equal "playing", @playing_game.state
    end
  end
  
  test "fire_should_hit_and_sink" do
    assert_difference('Location.where(hit: true, coordinate: "C-1").count', 1) do
      id, hit, sunk = @playing_game.fire(@player_2, "C-1")
      assert_equal @playing_game.id, id
      assert hit
      assert_equal 3, sunk
      assert_equal @player_1.id, @playing_game.turn_id
      assert_equal nil, @playing_game.winner_id
      assert_equal "playing", @playing_game.state
    end
  end
  
  test "fire_should_miss" do
    assert_difference('Location.where(hit: true, coordinate: "D-7").count', 1) do
      id, hit, sunk = @playing_game.fire(@player_2, "D-7")
      assert_equal @playing_game.id, id
      assert_not hit
      assert_equal 0, sunk
      assert_equal @player_1.id, @playing_game.turn_id
      assert_equal nil, @playing_game.winner_id
      assert_equal "playing", @playing_game.state
    end
  end
  
  test "fire_should_win" do
    # Switch to player 1, as player 1 has one more shot to win the game.
    @playing_game.turn_id = @player_1.id
    # Now take the final shot as player 2.
    assert_difference('Location.where(hit: true, coordinate: "A-2").count', 1) do
      id, hit, sunk = @playing_game.fire(@player_1, "A-2")
      assert_equal @playing_game.id, id
      assert hit
      assert_equal 2, sunk
      assert_equal "finished", @playing_game.state
      assert_equal @player_1.id, @playing_game.winner_id
    end
  end
  
  test "should_not_fire_at_bad_location" do
    assert_no_difference('Location.where(hit: true).count') do
      assert_raises(ArgumentError) { @playing_game.fire @player_1, "A-55" }
    end
  end
  
  test "should_not_fire_on_new_game" do
    assert_no_difference('Location.where(hit: true).count') do
      assert_raises(ArgumentError) { @new_game.fire @player_1, "D-7" }
    end
  end
  
  test "should_not_fire_on_waiting_game" do
    assert_no_difference('Location.where(hit: true).count') do
      assert_raises(ArgumentError) { @waiting_game.fire @player_1, "D-7" }
    end
  end
  
  test "should_not_fire_on_finished_game" do
    assert_no_difference('Location.where(hit: true).count') do
      assert_raises(ArgumentError) { @finished_game.fire @player_1, "D-7" }
    end
  end
  
  test "should_not_fire_in_other_game" do
    assert_no_difference('Location.where(hit: true).count') do
      assert_raises(ArgumentError) { @playing_game.fire @waiting_player, "D-7" }
    end
  end
  
  test "should_not_fire_if_not_turn" do
    assert_no_difference('Location.where(hit: true).count') do
      assert_raises(ArgumentError) { @playing_game.fire @player_1, "D-7" }
    end
  end
  
  test "should_get_waiting_status" do
    id, status, my_turn = @waiting_game.status(@waiting_player)
    assert_equal @waiting_game.id, id
    assert_equal "waiting", status
    assert my_turn
  end
  
  test "should_get_playing_status_when_my_turn" do
    id, status, my_turn = @playing_game.status(@player_2)
    assert_equal @playing_game.id, id
    assert_equal "playing", status
    assert my_turn
  end
    
  test "should_get_playing_status_when_not_my_turn" do
    id, status, my_turn = @playing_game.status(@player_1)
    assert_equal @playing_game.id, id
    assert_equal "playing", status
    assert_not my_turn
  end

  test "should_get_winning_status" do
    id, status, my_turn = @finished_game.status(@winning_player)
    assert_equal @finished_game.id, id
    assert_equal "won", status
    assert my_turn
  end

  test "should_get_losing_status" do
    id, status, my_turn = @finished_game.status(@losing_player)
    assert_equal @finished_game.id, id
    assert_equal "lost", status
    assert_not my_turn
  end
  
  test "should_not_get_new_game_status" do
    assert_raises(ArgumentError) { @new_game.status @new_player }
  end
  
  test "should_not_get_status_not_in_game" do
    assert_raises(ArgumentError) { @playing_game.status @waiting_player }
  end

end
