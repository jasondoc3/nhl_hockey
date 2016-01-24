require 'net/http'
require 'uri'
require 'json'

# A module for wrapping the nhl.com stat API into a ruby gem
module NHL

  # The number of teams in the NHL
  NUMBER_OF_TEAMS = 30

  # The part of the URL that every API call uses
  API_BASE_URL = "http://www.nhl.com/stats/rest".freeze

  # Returns an array of all the NHL teams
  # ==== Options
  #    * :season - The NHL season requested. Must be in the format of "20142015"
  def self.teams(options = {})
    Team.get.map do |nhl_hash|
      options[:nhl_hash] = nhl_hash
      Team.new(nhl_hash[Team::NHL_API_TRANSLATIONS["abbreviation"]], options)
    end
  end

  # Returns the current season in the format: "20142015"
  def self.current_season
    today = Time.now
  	if today.month >= 10 && today.month <= 12
      return "#{today.year}#{today.year + 1}"
    else
      return "#{today.year - 1}#{today.year}"
    end
  end
end

require_relative 'nhl_hockey/team.rb'
require_relative 'nhl_hockey/player.rb'
require_relative 'nhl_hockey/player_bio.rb'

begin
  NHL::Team.get
rescue => e
  puts "==============="
  puts "An error has occured while loading the nhl_hockey gem. Nhl.com might have changed their API."
  puts "==============="
  puts e.message
  puts e.backtrace
end
