module PuppetX::Gluu::CoreExtensions::Hash
  refine Hash do
    # Sorts a hash by key and optionally transforms it if called with
    # a block.
    #
    # @yieldparam [Hash] hash self
    # @yieldreturn [Array] the result of an Enumerable method
    def canonicalize(&block)
      block ? ::Hash[block.call(self).sort] : ::Hash[sort]
    end

    def diff(compare)
      ::Hash[compare.to_a - to_a]
    end
  end
end
