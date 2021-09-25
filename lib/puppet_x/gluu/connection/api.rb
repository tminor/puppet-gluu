module PuppetX::Gluu::Connection
  class Api < PuppetX::Gluu::BaseConnection
    require 'json'
    require 'jwt'
    require 'securerandom'
    require 'httparty'
    require 'openssl'
    require 'net/ldap'
    require 'puppet_x'
    require 'pry'

    HTTParty::Basement.default_options.update(verify: false)

    include PuppetX::Gluu::Helpers::Api
    using PuppetX::Gluu::CoreExtensions::Hash

    attr_reader :url, :host, :port, :protocol

    def key_info
      if File.exist? '/opt/gluu-server/etc/certs/api_key_info.json'
        JSON.parse(File.read('/opt/gluu-server/etc/certs/api_key_info.json'))
      end
    end

    def initialize(opts)
      Authentication.configure(
        opts[:passwords][:api],
        opts[:passwords][:ldap],
        opts[:passwords][:oxtrust],
      )

      @url = "#{opts[:protocol]}://#{opts[:host]}:#{opts[:port]}/identity/restv1/api/v1/#{endpoint}"
    end

    def search(**query)
      access_token = authenticate
      HTTParty.get(
        "#{@url}#{query[:endpoint]}",
        headers: {
          'Authorization' => "Bearer #{access_token}",
          'Content-Type' => 'application/json'
        },
      )
      data.map do |o|
        o[:ensure] = 'present'
        api_to_puppet(o, context)
      end
    end

    # Authenticate via Gluu's oAuth endpoint by sending a JSON web
    # token. The response contains an access token that will be stored
    # in a file with its expiration time.
    def authenticate
      get_new_access_token
    end

    # The first step of the authentication process involves retrieving a
    # ticket from an arbitrary API endpoint.
    def retrieve_ticket
      resp = HTTParty.get(@url)

      # TODO: Handle non-401 responses

      resp.headers['www-authenticate']
          .split(', ')
          .find { |e| e =~ %r{^ticket} }
          .split('=')[1]
    end

    # Loads a private key used to sign a JSON web token.
    def load_auth_key
      OpenSSL::PKey::RSA.new(
        File.read('/opt/gluu-server/etc/certs/api-key.pem'),
        key_info[:api_key_pass],
      )
    end

    # JSON web tokens require certain fields. The fields below specify
    # the type ('JWT'), the algorithm used to generate the key, and the
    # key ID. The algorithm and key ID are retrieved from configuration
    # stored in Gluu's LDAP.
    def jwt_headers
      {
        typ: 'JWT',
        alg: key_info['alg'],
               kid: key_info['kid']
             }
           end

           # Returns a JSON web token.
           def generate_json_web_token(time)
             JWT.encode(
               {
                 sub: key_info['oxtrust_client_id'],
                 iss: key_info['oxtrust_client_id'],
                 exp: time.to_i + 86_400,
                 iat: time.to_i,
                 jti: SecureRandom.hex(10),
                 aud: 'https://localhost/oxauth/restv1/token'
               },
               load_auth_key,
               'RS256',
               jwt_headers,
             )
           end

           # Checks if we have an access token writen to a file on disk and
           # validates whether it's expired.
           def valid_access_token?
             token_file = '/opt/gluu-server/etc/certs/api_token.json'
             return false unless File.exist? token_file

             token_config = JSON.parse(File.read(token_file))
             expired = token_config['exp'] < Time.now.to_i
             return false if expired

             return false unless token_config['token']

             true
           end

           # Retrieves a valid access token from a file on disk.
           def fetch_access_token
             JSON.parse(File.read('/opt/gluu-server/etc/certs/api_token.json'))['token']
           end

           # Fetches a new access token and writes it to disk.
           def get_new_access_token
             now = Time.now
             params = {
               body: {
                 grant_type: 'urn:ietf:params:oauth:grant-type:uma-ticket',
                 ticket: retrieve_ticket,
                 client_id: key_info['oxtrust_client_id'],
                 client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
                 client_assertion: generate_json_web_token(now),
                 scope: 'oxtrust-api-read oxtrust-api-write'
               }
             }
             req = HTTParty.post("#{@protocol}://#{@host}:#{@port}/oxauth/restv1/token", params)
             if req.code == 200
               token = req['access_token']
               save_access_token(token, now.to_i + 86_400)
               token
             else
               # TODO: Raise an error
               Puppet.err(
                 "Gluu API HTTP #{req.code}:  #{req['error_description']}",
               )
             end
           end

           # Saves an access token to disk.
           def save_access_token(token, now)
             File.open('/opt/gluu-server/etc/certs/api_token.json', 'w') do |f|
               JSON.dump(
                 {
                   token: token,
                   exp: now
                 },
                 f,
               )
             end
           end
         end
end
