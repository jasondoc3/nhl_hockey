require 'date'

module NHL
  class Player
    class Bio
      URL = "#{PLAYER_BASE_URL}/bios?cayenneExp=gameTypeId=2+and+".freeze

      NHL_API_TRANSLATIONS = {
        "name"                => "playerName",
        "city"                => "playerBirthCity",
        "state_or_province"   => "playerBirthStateProvince",
        "country"             => "playerBirthCountry",
        "nationality"         => "playerNationality",
        "birthday"            => "playerBirthDate",
        "team_number"         => "playerCurrentSweaterNumber",
        "draft_pick_number"   => "playerDraftOverallPickNo",
        "draft_round"         => "playerDraftRoundNo",
        "draft_year"          => "playerDraftYear",
        "handedness"          => "playerShootsCatches",
        "weight"              => "playerWeight",
        "height"              => "playerHeight",
        "age"                 => "age"
      }.freeze

      # Makes all the properties of the NHL::Player::Bio object obtained from nhl.com
      # accessible
      NHL_API_TRANSLATIONS.keys.each do |property|
        attr_reader "#{property}".to_sym
      end

      attr_reader :nhl_player_site_id
      attr_reader :age

      def initialize(player)
        @nhl_player_site_id = player.nhl_site_id
        nhl_hash = self.class.get(nhl_player_site_id: @nhl_player_site_id, season: player.season)[0]
        set_instance_vars_from_nhl_hash(nhl_hash)
        set_age
      end

      # A prettier output
      def to_s
        output = "{\n"
        NHL_API_TRANSLATIONS.keys.each do |property|
          instance_var = "@#{property}"
          output << "  #{property}: #{self.instance_variable_get(instance_var)}\n"
        end

        if @season
          output << "  season: #{@season}\n"
        end
          
        output << "}\n"
        return output
      end

      def self.get(options = {})
        url = "#{URL}seasonId=#{options[:season] || NHL.current_season}"
        url << "+and+playerId=#{options[:nhl_player_site_id]}" if options[:nhl_player_site_id]
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

      # Contains logic to set the age instance variable for this bio
      def set_age
        birthday = Date.parse(@birthday)
        today = Date.today

        if (birthday.month == today.month && birthday.day <= today.day) || (birthday.month < today.month)
          @age = today.year - birthday.year
        else
          @age = today.year - birthday.year - 1
        end
      end
    end
  end
end
