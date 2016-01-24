module NHL

  # The NHL::Player class
  # Maps an NHL::Player object to an NHL team obtained from the nhl.com API
  class Player

    # The base Api url for player related nhl.com requests
    PLAYER_BASE_URL = "#{API_BASE_URL}/grouped/skaters/season".freeze

    # A String containing the URL to access the nhl.com player stats
    STAT_SUMMARY_URL = "#{PLAYER_BASE_URL}/skatersummary?cayenneExp=gameTypeId=2+and+".freeze

    # A Hash mapping the attribute names in the NHL::Player class
    # to the attribute names used by nhl.com
    NHL_API_TRANSLATIONS = {
      "assists"                 => "assists",
      "face_off_win_percentage" => "faceoffWinPctg",
      "game_winning_goals"      => "gameWinningGoals",
      "games_played"            => "gamesPlayed",
      "goals"                   => "goals",
      "overtime_goals"          => "otGoals",
      "penalty_minutes"         => "penaltyMinutes",
      "first_name"              => "playerFirstName",
      "last_name"               => "playerLastName",
      "nhl_site_id"             => "playerId",
      "name"                    => "playerName",
      "position"                => "playerPositionCode",
      "team_abbreviation"       => "playerTeamsPlayedFor",
      "plus_minus"              => "plusMinus",
      "points"                  => "points",
      "power_play_goals"        => "ppGoals",
      "power_play_points"       => "ppPoints",
      "shorthanded_goals"       => "shGoals",
      "shorthanded_points"      => "shPoints",
      "shifts_per_game"         => "shiftsPerGame",
      "shooting_percentage"     => "shootingPctg",
      "shots"                   => "shots",
      "time_on_ice_per_game"    => "timeOnIcePerGame",
      "season"                  => "seasonId"
    }.freeze

    # Makes all the properties of the NHL::Player object obtained from nhl.com
    # accessible
    NHL_API_TRANSLATIONS.keys.each do |property|
      attr_reader "#{property}".to_sym
    end

    # NHL::Player constructor
    # ==== Options
    #   * :season - The NHL season requested. Must be in the format of "20142015"
    #   * :nhl_hash - If you already have the Hash for this player, you can use it to save an HTTP request
    #   * :name - If you know the player name e.g. "Patrick Kane"
    #   * :nhl_site_id - If the nhl_site_id is known ahead of time
    #
    # ==== Examples
    #   NHL::Player.new(name: "Alex Ovechkin")
    #   NHL::Player.new(name: "Ben Smith", team: "CHI", season: "20141015")
    #
    def initialize(options = {})
      nhl_hash = options[:nhl_hash]

      unless nhl_hash
        if options[:nhl_site_id]
          nhl_hash = self.get(options)[0]
        elsif options[:name]
          self.class.get(options).each do |player_hash|
            name_matches = options[:name].downcase == player_hash[NHL_API_TRANSLATIONS["name"]].downcase

            if options[:team]
              team_matches = player_hash[NHL_API_TRANSLATIONS["team_abbreviation"]].upcase.include?(options[:team])
              nhl_hash = player_hash and break if name_matches && team_matches
            else
              nhl_hash = player_hash and break if name_matches
            end
          end
        end
      end

      if nhl_hash
        set_instance_vars_from_nhl_hash(nhl_hash)
      else
        raise raise ArgumentError, "Could not find a player with the given parameters"
      end
    end

    def bio
      @bio ||= Bio.new(self)
      return @bio
    end

    # A prettier output
    def to_s
      output = "{\n"
      NHL_API_TRANSLATIONS.keys.each do |property|
        instance_var = "@#{property}"
        output << "  #{property}: #{self.instance_variable_get(instance_var)}\n"
      end

      output << "  season: #{@season}\n"
      output << "}\n"
      return output
    end

    # Returns the team or teams that this player has played for the current season
    def teams
      return @teams if @teams

      @teams ||= @team_abbreviation.split(", ").map do |team_abbreviation|
        Team.new(team_abbreviation, season: @season)
      end

    end

    # Gets data from nhl.com
    # If no options are given, it gets every player's stats for the current nhl season
    # ==== Options
    #   * :season - The NHL season requested. Must be in the format of "20142015"
    #
    # ==== Examples
    #   NHL::Player.get(season: "20142015") -> array
    #
    def self.get(options = {})
      url = "#{STAT_SUMMARY_URL}seasonId=#{options[:season] || NHL.current_season}"
      url << "+and+teamId=#{options[:nhl_site_team_id]}" if options[:nhl_site_team_id]
      url << "+and+playerId=#{options[:nhl_site_id]}" if options[:nhl_site_id]
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response_body = JSON.parse(response.body)["data"]
      return response_body
    end

    private

    # Sets the attributes of this intance from data retrieved
    # from nhl.com
    def set_instance_vars_from_nhl_hash(nhl_hash)
      NHL_API_TRANSLATIONS.each do |translation, property|
        nhl_hash[property] = nhl_hash[property].to_s if translation == 'season'
        instance_variable_set("@#{translation}", nhl_hash[property])
      end
    end
  end

end