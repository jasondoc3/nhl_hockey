require 'minitest/autorun'
require_relative '../lib/nhl_hockey.rb'

class TestTeam < MiniTest::Test

  def setup
    @team = NHL::Team.new(abbreviation: "SJS", season: '20092010')
  end

  def test_new
    team = NHL::Team.new(name: 'Sharks', season: '20092010')
    assert_equal('20092010', team.season)
    assert_equal('San Jose Sharks', team.name)

    team_two = NHL::Team.new(city: 'chicago', season: '20132014')
    assert_equal('20132014', team_two.season)
    assert_equal('Chicago Blackhawks', team_two.name)

    (team_three = NHL::Team.new(name: 'Farts') rescue nil)
    assert_nil(team_three)
  end

  def test_is_a_team
    assert_equal(NHL::Team, @team.class)
  end

  def test_abbreviations
    abbreviations = NHL::Team.abbreviations
    assert_includes(abbreviations, 'SJS')
    abbreviations = NHL::Team.abbreviations('20092010')
    assert_includes(abbreviations, 'ATL') # ATL isn't in the league anymore
  end

  def test_get
    all_nhl_hash = NHL::Team.get
    assert_equal(all_nhl_hash.length, NHL::NUMBER_OF_TEAMS) # this might change

    all_nhl_hash_two = NHL::Team.get(season: '20092010')
    assert_equal('20092010', all_nhl_hash_two.first[NHL::Team::NHL_API_TRANSLATIONS["season"]].to_s)
  end

  def test_players
    players = @team.players
    assert_equal(NHL::Player, players.last.class)
    assert_equal(players.first.season, '20092010')
    assert_includes(players.map(&:name), 'Ryane Clowe')
  end
end
