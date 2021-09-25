# Autoloads Ruby code
module Loader
  require 'zeitwerk'
  require 'pry'

  require 'puppet'
  require 'puppet/settings'
  require 'puppet/util/autoload'
  require 'puppet/resource_api'

  loader = Zeitwerk::Loader.for_gem
  loader.setup

  puppet_autoloader = Puppet::Util::Autoload
  env = Puppet.lookup(:current_environment) if Puppet.respond_to? :lookup
  transports_path = "puppet/transport/schema"

  puppet_autoloader.files_to_load(transports_path, env).each do |file|
    name = file.chomp('.rb')
    puppet_autoloader.load_file(name, env)
  end
end
