module NHL
  class Entity

    # A prettier output
    def to_s
      output = "{\n"
      self.class::NHL_API_TRANSLATIONS.keys.each do |property|
        instance_var = "@#{property}"
        output << "  #{property}: #{self.instance_variable_get(instance_var)}\n"
      end

      output << "  season: #{@season}\n" if @season
      output << "}\n"
      return output
    end

    private

    # Sets the attributes of this intance from data retrieved
    # from nhl.com
    def set_instance_vars_from_nhl_hash(nhl_hash)
      self.class::NHL_API_TRANSLATIONS.each do |translation, property|
        nhl_hash[property] = nhl_hash[property].to_s if translation == 'season'
        instance_variable_set("@#{translation}", nhl_hash[property])
      end
    end
  end
end