require 'minitest/autorun'
require '../lib/nhl_hockey.rb'

class TestTeam < MiniTest::Test

  def setup
    @team = NHL::Team.new("SJS", season: '20092010')
  end

  def test_is_a_team
    assert_equal(NHL::Team, @team.class)
  end

  def test_season
    assert_equal('20092010', @team.season)
  end

  def test_name
    assert_equal('San Jose Sharks', @team.name)
  end

  def test_get
    all_nhl_hash = NHL::Team.get
    assert_equal(all_nhl_hash.length, NHL::NUMBER_OF_TEAMS)

    single_team_nhl_hash = NHL::Team.get(abbreviation: 'ANA', season: '20132014')[0]
    assert_equal(single_team_nhl_hash[NHL::Team::NHL_API_TRANSLATIONS['name']], 'Anaheim Ducks')
    assert_equal(single_team_nhl_hash[NHL::Team::NHL_API_TRANSLATIONS['wins']], 54)
  end
  
end
