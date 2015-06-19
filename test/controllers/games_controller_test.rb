require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  def setup
    @new_player = players(:new_player)
    @new_board = Array.new(10) { Array.new(10, "") }
    @waiting_game = games(:waiting_game)
    @waiting_player = players(:waiting_player)
    @playing_game = games(:playing_game)
    @player_2 = players(:playing_player_2)
  end

  test "should_get_paginated_index" do
    get :index
    assert_response :success
    assert_template "games/index"
    assert_select "h1", "Games"
    assert_select "div.pagination"
    Game.where.not(state: nil).paginate(page: 1).each do |game|
        assert_select "a[href=?]", game_path(game) 
    end
  end
  
  test "should_show_game" do
    get :show, id: @playing_game.id
    assert_response :success
    assert_template "games/show"
    assert_select "h1", "Game"
    assert_select "#game-state", "playing"
    assert_select ".player-board", 2
    assert_select ".player-name", 2
    assert_select ".board", 2
    # Assert that each board has 11 rows and 11 columns.
    assert_select ".board" do |boards|
      boards.each do |board|
        assert_select board, ".board-row" , 11 do |rows|
          rows.each_with_index do |row, i|
            if i == 0
              assert_select row, ".header", 11
              assert_select row, ".board-col", 11
            else
              assert_select row, ".header", 1
              assert_select row, ".board-col", 11
            end
          end
        end
      end
    end
  end

  test "should_start_game" do
    # Even though using JSON parameters, must use the hash form for testing
    # since the server is mocked, not real.
    params = { "player" => @new_player.name, "board" => @new_board }
    assert_difference('Game.count', 1) do
      post :start, params
    end
    assert_response :success
    start_response = JSON.parse(response.body)
    assert_not_nil start_response["game_id"]
  end

  test "should_not_start_with_bad_ship" do
    @new_board[5][5] = "A-8"
    params = { "player" => @new_player.name, "board" => @new_board }
    assert_no_difference('Game.count') do
      post :start, params
    end
    assert_response :bad_request
  end
  
  test "should_join_game" do
    params = { "game_id" => @waiting_game.id, "player" => @new_player.name, "board" => @new_board }
    post :join, params
    assert_response :success
    join_response = JSON.parse(response.body)
    assert_equal @waiting_game.id, join_response["game_id"]
  end
  
  test "should_not_join_unknown_game" do
    params = { "game_id" => 0, "player" => @new_player.name, "board" => @new_board }
    post :join, params
    assert_response :bad_request
  end
  
  test "should_not_join_game_started" do
    params = { "game_id" => @waiting_game.id, "player" => @waiting_player.name, "board" => @new_board }
    post :join, params
    assert_response :bad_request
  end
  
  test "fire_should_hit" do
    params = { "game_id" => @playing_game.id, "player" => @player_2.name, "shot" => "D-1" }
    post :fire, params
    assert_response :success
    join_response = JSON.parse(response.body)
    assert_equal @playing_game.id, join_response["game_id"]
    assert join_response["hit"]
    assert_equal 0, join_response["sunk"]
  end
  
  test "should_not_fire_unknown_game" do
    params = { "game_id" => 0, "player" => @player_2.name, "shot" => "D-1" }
    post :fire, params
    assert_response :bad_request
  end
  
  test "should_not_fire_at_bad_location" do
    params = { "game_id" => @playing_game, "player" => @player_2.name, "shot" => "A-55" }
    post :fire, params
    assert_response :bad_request
  end
  
  test "should_get_status" do
    params = { "game_id" => @waiting_game.id, "player" => @waiting_player.name }
    get :status, params
    assert_response :success
    status_response = JSON.parse(response.body)
    assert_equal @waiting_game.id, status_response["game_id"]
    assert_equal "waiting", status_response["state"]
    assert status_response["my_turn"]
  end
  
  test "should_not_get_status_unknown_game" do
    params = { "game_id" => 0, "player" => @waiting_player.name }
    get :status, params
    assert_response :bad_request
  end
end
