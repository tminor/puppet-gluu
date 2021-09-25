require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gluu_api/gluu_api'))

class Puppet::Provider::GluuConfiguration::GluuConfiguration < Puppet::Provider::GluuProvider::SingletonProvider
  using PuppetX::Gluu::CoreExtensions

  def get(context)
    Puppet.debug('Fetching Gluu Server configuration from LDAP')
    res = super(
      context,
      attribute: 'ou',
      value: context.type.attributes[:ou][:default]
    )
    # ret = ldap_to_puppet(config, context)
    # namevar = context.type.namevars.first
    # ret[namevar] = context.type.attributes[namevar][:default]
    # ret[:ensure] = 'present'
    # [ret]
  end

  def set(context, changes)
    ldap = PuppetX::Gluu::Helpers::Ldap.bind(passwords[:ldap_admin_pass])

    changes.each do |_name, change|
      next if change[:is] == change[:should]

      diffs = puppet_to_ldap(change[:is].diff(change[:should]), context)

      diffs.each do |attr, value|
        result = ldap.replace_attribute(
          'ou=configuration,o=gluu',
          attr.to_sym,
          value,
        )
        Puppet.err("Error while replacing LDAP attribute #{ldap_attribute}") unless result
      end
    end
  end

  # For use with the Resource API's canonicalize feature.
  #
  # This is probably an abuse of this feature, but here's what we're
  # doing:
  #   - Make sure this resource isn't defined twice (it's already
  #     defined in init.pp)
  #   - Register the various transport configurations with base
  #     provider as class instance variables (which may be used in a
  #     scenario where, e.g., an API provider needs to interact with
  #     LDAP, etc.)
  #   - Set the transport configurations in the base provider
  def canonicalize(context, resources)
    super
    resources.each do |r|
      config_params = context.type.attributes.select { |_, v| v[:behaviour] == :init_only }

      register_transport_configs(config_params.keys)

      r.select { |k, _| config_params.member? k }.each do |name, _|
        conf = {}.merge(r[name])
        send("#{name}=", conf.canonicalize { |h| h.map { |k, v| [k.to_sym, v] } })
      end
    end
  end
end
