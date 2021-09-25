module PuppetX::Gluu::Transports::Api
  class Authentication
    include PuppetX::Gluu::Helpers::Ldap

    def self.configure(key_pass, ldap_pass)
      return if File.exist? '/opt/gluu-server/etc/certs/api_key_info.json'

      # Fetch an allowed API key from LDAP.
      api_key = get_api_key('RS256', ldap_pass)
      # Get oxTrust's client ID from LDAP.
      oxtrust_client_id = get_oxtrust_client_id(ldap_pass)
      api_key['oxtrust_client_id'] = oxtrust_client_id
      # Save the key info and client ID to a JSON file.
      save_api_key_info(api_key)
      # Generate a keystore from which we can extract and create a PEM
      # formatted private key.
      create_keystore(api_key['kid'], key_pass, api_key)
      # Create the private key and save it.
      create_private_key(key_pass)
      restart_identity
    end

    def self.puppet_error(err)
      Puppet.warning("Encountered an error while configuring Gluu API: #{err}")
    end

    def self.run_container_command(cmd)
      login = <<~LOGIN
        /usr/bin/ssh -o IdentityFile=/etc/gluu/keys/gluu-console \
          -o Port=60022 \
          -o LogLevel=QUIET \
          -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          -o PubkeyAuthentication=yes \
          -q \
          root@localhost \
          "#{cmd}"
      LOGIN

      stdout, stderr, exit_status = Open3.capture3(login)
      raise stderr unless exit_status.to_i.zero?

      stdout
    end

    # Generates auth keys (as JSON).
    def self.generate_auth_keys(key_pass)
      cmd = <<~CMD
      /opt/jre/bin/java -jar /opt/dist/gluu/oxauth-client-jar-with-dependencies.jar \
        -keystore /etc/certs/api-rp.jks \
        -sig_keys RS256 RS384 RS512 ES256 ES384 ES512 PS256 PS384 PS512 RSA1_5 \
        -keypasswd secret \
        -enc_keys RSA1_5 RSA-OAEP \
        -dnname "CN=oxAuth Ca Certificates" \
        -expiration 365000
    CMD

      JSON.parse(run_container_command(cmd))['keys']
    end

    def self.save_auth_keys_ldap(auth_keys, ldap_pass)
      ldap = PuppetX::Gluu::Helpers::Ldap.bind(ldap_pass)
      keys = auth_keys.to_json.gsub("\n", '')
      json_keys = "{\"keys\":#{keys}}"
      ldap.replace_attribute(
        "inum=#{get_oxtrust_client_id(ldap_pass)},ou=clients,o=gluu",
        :oxauthjwks,
        json_keys,
      )
    end

    def self.get_api_key(key_alg, ldap_pass)
      auth_keys = generate_auth_keys(ldap_pass)
      save_auth_keys_ldap(auth_keys, ldap_pass)
      auth_keys.find { |key| key['alg'] == key_alg }
    end

    def self.create_keystore(key_id, key_pass, api_key)
      key_id = api_key['kid']
      cmd = <<~CMD
      /opt/jre/bin/keytool -importkeystore \
        -srckeystore /etc/certs/api-rp.jks \
        -srcstorepass secret \
        -srckeypass secret \
        -srcalias #{key_id} \
        -destalias #{key_id} \
        -destkeystore /etc/certs/api-rp.pkcs12 \
        -deststoretype PKCS12 \
        -deststorepass #{key_pass} \
        -destkeypass #{key_pass}
    CMD

      run_container_command(cmd)
    end

    def self.create_private_key(key_pass)
      cmd = <<~CMD
      openssl pkcs12 \
        -in /etc/certs/api-rp.pkcs12 \
        -nodes \
        -out /etc/certs/api-key.pem \
        -nocerts \
        -passin pass:#{key_pass}
    CMD

      run_container_command(cmd)
    end

    def self.get_oxtrust_client_id(ldap_pass)
      ldap = PuppetX::Gluu::Helpers::Ldap.bind(ldap_pass)
      filter = Net::LDAP::Filter.eq('displayName', 'API Requesting Party Client')
      ldap.search(filter: filter).first.inum.first
    end

    def self.save_api_key_info(key_info)
      path = '/opt/gluu-server/etc/certs/api_key_info.json'
      File.open(path, 'w') { |f| JSON.dump(key_info, f) } unless File.exist? path
    end

    def self.restart_identity
      run_container_command('/bin/systemctl restart oxauth identity')
    end
  end
end
