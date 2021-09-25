module PuppetX::Gluu::CoreExtensions
  constants.each do |c|
    include Kernel.const_get("PuppetX::Gluu::CoreExtensions::#{c}")
  end
end
