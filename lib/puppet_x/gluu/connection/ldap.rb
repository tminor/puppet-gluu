require 'as/notifications'

module PuppetX::Gluu::Connection
  # See: Puppet::Transport::GluuServer
  class Ldap < PuppetX::Gluu::BaseConnection
    attr_reader :connection
    attr_accessor :events

    def initialize(opts)
      connections[:ldap] = bind(opts)
      @events = []
    end

    def search(**query)
      filter = Net::LDAP::Filter.eq(query[:attribute], query[:value])
      suppress_output do
        connections[:ldap].search(
          {}.tap do |h|
            h[:filter] = filter
            h[:base] = query[:base] unless query[:base].nil?
          end,
        )
      end.map(&:to_h)
    end

    private

    def bind(opts)
      debug(/read/)

      ldap = Net::LDAP.new(
        encryption: {
          method: :simple_tls,
          tls_options: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
        },
        base: 'o=gluu',
        auth: {
          method: :simple,
          username: opts[:username],
          password: opts[:password].unwrap,
        },
        host: 'localhost',
        port: 1636,
        instrumentation_service: AS::Notifications
      )

      suppress_output { ldap.bind }

      ldap
    end

    def debug(event)
      @events ||= []
      AS::Notifications.subscribe('read.net_ldap_connection') { |*args| @events << AS::Notifications::Event.new(*args) }
    end

    def suppress_output
      original_stderr = $stderr.clone
      original_stdout = $stdout.clone
      $stderr.reopen(File.new('/dev/null', 'w'))
      $stdout.reopen(File.new('/dev/null', 'w'))
      yield
    ensure
      $stdout.reopen(original_stdout)
      $stderr.reopen(original_stderr)
    end
  end
end
