require 'minitest/autorun'
require_relative '../lib/nhl_hockey.rb'

class PlayerTest < MiniTest::Test
  def setup
    @player = NHL::Player.new(name: 'Joe Pavelski', season: '20152016')
  end

  def test_new
    player = NHL::Player.new(name: 'Patrick Kane', season: '20142015', team: 'CHI')
    (invalid_player = NHL::Player.new(name: 'Patrick Kane', season: '20142015', team: 'SJS') rescue nil)
    assert_equal('Patrick Kane', player.name)
    assert_equal('20142015', player.season)
    assert_nil(invalid_player)
  end
end
