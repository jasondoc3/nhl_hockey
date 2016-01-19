module NHL

  class Player

    # A String containing the URL to access the nhl.com team API
    STAT_SUMMARY_URL = "#{API_BASE_URL}/grouped/skaters/season/skatersummary?cayenneExp=gameTypeId=2+and+".freeze

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
      "nhl_player_id"           => "playerId",
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
      "time_on_ice_per_game"    => "timeOnIcePerGame"
    }.freeze

    # Makes all the properties of the NHL::Player object obtained from nhl.com
    # accessible
    NHL_API_TRANSLATIONS.keys.each do |property|
      attr_reader "#{property}".to_sym
    end

    def initialize(options = {})
      @season = options[:season] || NHL.current_season
      nhl_hash = options[:nhl_hash]
      # nhl_hash ||= self.class.get({ abbreviation: @abbreviation }.merge(options))[0]
      set_instance_vars_from_nhl_hash(nhl_hash)
    end

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

    def teams
      return @teams if @teams

      @teams ||= @team_abbreviation.split(", ").map do |team_abbreviation|
        Team.new(team_abbreviation, season: @season)
      end

    end

    def self.get(options = {})
      url = "#{STAT_SUMMARY_URL}seasonId=#{options[:season] || NHL.current_season}"
      url << "+and+teamId=#{NHL::Team::ABBREVIATIONS_TO_NHL_SITE_IDS[options[:abbreviation]]}" if options[:abbreviation]
      url << "+and+teamId=#{options[:nhl_site_id]}" if options[:nhl_site_id]
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
        instance_variable_set("@#{translation}", nhl_hash[property])
      end
    end
  end

end