require 'minitest/autorun'
require '../lib/nhl_hockey.rb'

class NHLTest < MiniTest::Test

  def setup
    @current_season = NHL.current_season
  end

  def test_current_season
    date = Time.now

    if date.month >= 10 # October
      assert_equal(@current_season, "#{date.year}#{date.year.to_i + 1}")
    else
      assert_equal(@current_season, "#{date.year.to_i - 1}#{date.year}")
    end
  end

  def test_teams
    teams = NHL.teams
    assert_equal(teams.length, NHL::NUMBER_OF_TEAMS)

    teams = NHL.teams(season: '20102011')
    assert_equal(teams[0].season, '20102011')
  end

end
