require 'optparse'

module ConsulDo
  class Config

    attr_accessor :key, :host, :port, :http_proxy, :verbose, :token

    def initialize
      @host = 'localhost'
      @port = '8500'
      @key = 'consul_do'
      @http_proxy = ENV['http_proxy'] || ENV['HTTP_PROXY']
      parse
    end

    def parse
      OptionParser.new do |opts|
        opts.banner = "Usage: consul-do OPTIONS"
        opts.on("-k", "--key KEY=consul_do", "Coordination key"){ |v| self.key = v }
        opts.on("-h", "--consul-host HOST=localhost", "Consul hostname"){ |v| self.host = v }
        opts.on("-p", "--consul-port PORT=8500", "Consul port"){ |v| self.port = v }
        opts.on("-t", "--token TOKEN", "ACL Token"){ |v| self.token = v }
        opts.on("--http_proxy http://HOST:PORT", "Use supplied proxy instead of ENV "){ |v| self.http_proxy = v }
        opts.on("-v", "--verbose", "Consul port"){ |v| self.verbose = v }
      end.parse!
    end

    def proxy
      begin
        URI.parse(http_proxy)
      rescue URI::InvalidURIError
        URI::Generic.new(nil,nil,nil,nil,nil,nil,nil,nil,nil)
      end
    end

    def session_name
      "consul-do_#{key}_session"
    end

    def net_http_proxy
      Net::HTTP.Proxy(proxy.host, proxy.port, proxy.user, proxy.password)
    end

    def http_client
      if proxy.host && proxy.port
        ConsulDo.log "http_client", net_http_proxy
      else
        ConsulDo.log "http_client", Net::HTTP
      end
    end

  end
end
