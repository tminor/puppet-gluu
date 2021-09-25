module PuppetX::Gluu::CoreExtensions::String
  refine String do
    # Converts a camel or Pascal cased string to snake case.
    def snakecase
      match?(%r{([A-Z][^A-Z]+)+}) ? gsub(/((?<=[a-z])[A-Z])/, '_\1').downcase : self
    end

    def camelcase
      match?(%r{([a-z]+_?)+}) ? split('_').map(&:capitalize).join.uncapitalize : self
    end

    def uncapitalize
      self[0, 1].downcase + self[1..-1]
    end

    # Convert a string to a boolean value.
    #
    # "False" or "false" returns false, all other values return true.
    def to_bool
      !(self.match? %r{[Ff]alse})
    end
  end
end
