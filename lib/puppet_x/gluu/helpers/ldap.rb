module PuppetX::Gluu::Helpers::Ldap
  def ldap_to_puppet(obj, context)
    type_attrs = context.type.attributes
    to_puppet = {}
    obj.each do |k, v|
      attr, props = type_attrs.find { |key, _| type_attrs[key][:alias] == k.to_s }
      if attr
        value = case props[:type]
                when 'Boolean'
                  v.first == 'true'
                when %r{^Tuple}
                  v.to_a
                else
                  v.first
                end
        to_puppet[attr] = value
      elsif type_attrs[k.to_sym]
        to_puppet[k] = v.first
      end
    end

    to_puppet
  end

  def puppet_to_ldap(obj, context)
    type_attrs = context.type.attributes
    to_ldap = {}
    obj.each do |k, v|
      type = type_attrs[k][:type]
      if type_attrs[k][:alias]
        value = case type
                when %r{^Tuple}
                  v
                else
                  v.to_s
                end
        to_ldap[type_attrs[k][:alias].to_sym] = value
      else
        to_ldap[k.to_s] = v
      end
    end
    to_ldap.delete('ensure')

    to_ldap
  end

  def self.suppress_output
    original_stderr = $stderr.clone
    original_stdout = $stdout.clone
    $stderr.reopen(File.new('/dev/null', 'w'))
    $stdout.reopen(File.new('/dev/null', 'w'))
    yield
  ensure
    $stdout.reopen(original_stdout)
    $stderr.reopen(original_stderr)
  end

  def self.bind(ldap_pass)
    ldap = Net::LDAP.new(
      encryption: {
        method: :simple_tls,
        tls_options: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
      },
      base: 'o=gluu',
      auth: {
        method: :simple,
        username: 'cn=directory manager',
        password: ldap_pass,
      },
      host: 'localhost',
      port: 1636,
    )

    bind = suppress_output do
      ldap.bind
    end

    bind ? ldap : Puppet.err('Failed to bind to Gluu LDAP')
  end
end
