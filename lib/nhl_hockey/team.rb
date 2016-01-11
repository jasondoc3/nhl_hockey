module NHL
  
  # The NHL::Team class
  # Maps an NHL::Team object to an NHL team obtained from the nhl.com API
  class Team

    # A Hash mapping the traditional NHL team abbrevations ("SJS")
    # to the team ids stored in their database
    ABBREVIATIONS_TO_NHL_SITE_IDS = Hash.new

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
      "name"                    => "teamFullName"
    }.freeze

    # Makes all the properties of the NHL::Team object obtained from nhl.com
    # accessible
    NHL_API_TRANSLATIONS.keys.each do |property|
      attr_reader "#{property.to_sym}"
    end

    # NHL::Team constructor
    # ==== Options
    #   * :season - The NHL season requested. Must be in the format of "20142015"
    #   * :nhl_hash - If you already have the Hash for this team, you can use it to save an HTTP request
    #
    # ==== Examples
    #   NHL::Team.new("SJS")
    #   NHL::Team.new("SJS", season: "20142015')
    #
    def initialize(abbreviation, options = {})
      raise ArgumentError, "The abbreviation you entered is invalid or does not match an NHL Team" unless self.class.abbreviations.include?(abbreviation.upcase)

      @abbreviation = abbreviation.upcase
      @season = options[:season] || NHL.current_season
      nhl_hash = options[:nhl_hash]
      nhl_hash ||= self.class.get({ abbreviation: @abbreviation }.merge(options))[0]
      set_instance_vars_from_nhl_hash(nhl_hash)
    end

    # Reload the data for this team from nhl.com
    def refresh
      nhl_hash = self.class.get(abbreviation: @abbreviation)[0]
      set_instance_vars_from_nhl_hash(nhl_hash)
      return true
    end

    # A prettier output
    # ==== Example
    #   irb(main):003:0> puts NHL::Team.new("SJS", season: "20082009")
    #   {
    #      games_played: 82
    #      faceoff_win_percentage: 0.5378
    #      goals_against: 199
    #      games_glayed: 82
    #      goals_for: 251
    #      losses: 18
    #      wins: 53
    #      ties: 0
    #      overtime_losses: 11
    #      power_play_percentage: 0.2416
    #      points: 117
    #      nhl_site_id: 28
    #      shots_against_per_game: 27.1707
    #      shots_for_per_game: 33.1707
    #      abbreviation: SJS
    #      name: San Jose Sharks
    #      season: 20082009
    #   }
    #   => nil
    #
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

    # Returns the team abbbrevations retrieved from nhl.com
    def self.abbreviations
      return ABBREVIATIONS_TO_NHL_SITE_IDS.keys
    end

    # Sets ABBREVIATIONS_TO_NHL_SITE_IDS after loading the data using ::get
    def self.set_abbreviations
      self.get.each { |team| ABBREVIATIONS_TO_NHL_SITE_IDS[ team[NHL_API_TRANSLATIONS["abbreviation"] ] ] = team[NHL_API_TRANSLATIONS["nhl_site_id"]] }
      ABBREVIATIONS_TO_NHL_SITE_IDS.freeze
    end

    # Gets data from nhl.com
    # If given a team abbreviation, returns the value for only one team
    # If not given a team abbreviation, returns stats for all teams
    # ==== Options
    #   * :season - The NHL season requested. Must be in the format of "20142015"
    #   * :abbreviation - The NHL team requested, unless all are wanted
    #
    # ==== Examples
    #   NHL::Team.get(season: "20142015")                      -> array
    #   NHL::Team.get(season: "20142015", abbreviation: "SJS") -> array
    #
    def self.get(options = {})
      url = "#{STAT_SUMMARY_URL}seasonId=#{options[:season] || NHL.current_season}"
      url << "+and+teamId=#{ABBREVIATIONS_TO_NHL_SITE_IDS[options[:abbreviation]]}" if options[:abbreviation]
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
