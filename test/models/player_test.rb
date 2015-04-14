require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  def setup
    @new_player = Player.new(name: "John")
  end
  
  test "should_be_valid" do
    assert @new_player.valid?
  end
  
  test "name_should_be_valid" do
    # Name has to exist.
    @new_player.name = nil
    assert_not @new_player.valid?
    # Characters have to be valid.
    @new_player.name = "*&^%$*"
    assert_not @new_player.valid?
    # Name has to be unique.
    @new_player.name = "New"
    assert_not @new_player.valid?
    # Name can't be too short.
    @new_player.name = "a"
    assert_not @new_player.valid?
    # Name can't be too long.
    @new_player.name = "a" * 50
    assert_not @new_player.valid?
  end
end
