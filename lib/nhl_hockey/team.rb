module NHL
  
  # The NHL::Team class
  # Maps an NHL::Team object to an NHL team obtained from the nhl.com API
  class Team < Entity

    # A String containing the URL to access the nhl.com team API
    STAT_SUMMARY_URL = "#{API_BASE_URL}/grouped/teams/season/teamsummary?cayenneExp=gameTypeId=2+and+".freeze

    # A Hash mapping the attribute names in the NHL::Team class
    # to the attribute names used by nhl.com
    NHL_API_TRANSLATIONS = {
      "games_played"            => "gamesPlayed",
      "faceoff_win_percentage"  => "faceoffWinPctg",
      "goals_against"           => "goalsAgainst",
      "games_glayed"            => "gamesPlayed",
      "goals_for"               => "goalsFor",
      "losses"                  => "losses",
      "wins"                    => "wins",
      "ties"                    => "ties",
      "overtime_losses"         => "otLosses",
      "power_play_percentage"   => "ppPctg",
      "points"                  => "points",
      "nhl_site_id"             => "teamId",
      "shots_against_per_game"  => "shotsAgainstPerGame",
      "shots_for_per_game"      => "shotsForPerGame",
      "abbreviation"            => "teamAbbrev",
      "name"                    => "teamFullName",
      "season"                  => "seasonId"
    }.freeze

    # Makes all the properties of the NHL::Team object obtained from nhl.com
    # accessible
    NHL_API_TRANSLATIONS.keys.each do |property|
      attr_reader "#{property}".to_sym
    end

    # NHL::Team constructor
    # ==== Options
    #   * :season - The NHL season requested. Must be in the format of "20142015"
    #   * :nhl_hash - If you already have the Hash for this team, you can use it to save an HTTP request
    #   * :city - The city where the team is located
    #   * :name - The name of the team
    #   * :abbreviation - The team abbrevation i.e. 'SJS'
    #   * :nhl_site_id - The team_id stored in nhl.com's database
    #
    # ==== Examples
    #   NHL::Team.new(abbreviation: "SJS")
    #   NHL::Team.new(name: "Sharks" season: "20142015')
    #   NHL::Team.new(city: "San Jose")
    #
    def initialize(options = {})
      nhl_hash = options[:nhl_hash]
    
      unless nhl_hash

        if options[:nhl_site_id]
          nhl_hash = self.class.get(options)[0]
        else
          self.class.get(options).each do |team_hash|
            nhl_hash = team_hash and break if options[:name] && team_hash[NHL_API_TRANSLATIONS["name"]].downcase.include?(options[:name].downcase)
            nhl_hash = team_hash and break if options[:city] && team_hash[NHL_API_TRANSLATIONS["name"]].downcase.include?(options[:city].downcase)
            nhl_hash = team_hash and break if options[:abbreviation] && team_hash[NHL_API_TRANSLATIONS["abbreviation"]].upcase == options[:abbreviation].upcase
          end
        end
      end
      
      if nhl_hash
        set_instance_vars_from_nhl_hash(nhl_hash)
      else
        raise ArgumentError, "Could not find a team with the given parameters"
      end
    end

    # Reload the data for this team from nhl.com
    def refresh
      nhl_hash = self.class.get(abbreviation: @abbreviation)[0]
      set_instance_vars_from_nhl_hash(nhl_hash)

      if @players
        @players = nil
        self.players
      end

      return true
    end

    # Returns all the players of this NHL team object as NHL::Players
    def players
      @players ||= Player.get(nhl_site_team_id: @nhl_site_id, season: @season).map do |nhl_hash|
        Player.new(nhl_hash: nhl_hash)
      end
    end

    # Returns the team abbbrevations retrieved from nhl.com
    # 
    # ==== Arguments
    #   * season - Optional. Pass in a season like '20152016'
    def self.abbreviations(season = NHL.current_season)
      return self.get(season: season).map { |team| team[NHL_API_TRANSLATIONS["abbreviation"]] }
    end

    # Gets data from nhl.com
    # If given a team abbreviation, returns the value for only one team
    # If not given a team abbreviation, returns stats for all teams
    # ==== Options
    #   * :season - The NHL season requested. Must be in the format of "20142015"
    #   * :nhl_site_id - If you have it, the id of the team in nhl.com's databases
    #
    # ==== Examples
    #   NHL::Team.get(season: "20142015")                      -> array
    #   NHL::Team.get(season: "20142015", abbreviation: "SJS") -> array
    #
    def self.get(options = {})
      url = "#{STAT_SUMMARY_URL}seasonId=#{options[:season] || NHL.current_season}"
      url << "+and+teamId=#{options[:nhl_site_id]}" if options[:nhl_site_id]
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response_body = JSON.parse(response.body)["data"]
      return response_body
    end
  end
end
