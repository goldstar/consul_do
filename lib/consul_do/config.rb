require 'optparse'

module ConsulDo
  class Config

    def initialize
    end

    def opts
      @opts ||= parse
    end

    def parse
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: consul-do OPTIONS"
        opts.on("-k", "--key KEY", "Coordination key"){ |v| options['key'] = v }
        opts.on("-h", "--consul-host HOST", "Consul hostname"){ |v| options['host'] = v }
        opts.on("-p", "--consul-port PORT", "Consul port"){ |v| options['port'] = v }
        opts.on("--http_proxy http://HOST:PORT", "Use supplied proxy instead of ENV "){ |v| options['http_proxy'] = v }
        opts.on("-v", "--verbose", "Consul port"){ |v| options['verbose'] = v}
      end.parse!
      #raise "foo"
      options = merge_defaults(options)
      validate(options)
    end

    def proxy
      proxy = opts['http_proxy'] || ENV['http_proxy'] || ENV['HTTP_PROXY']
      begin
        URI.parse(proxy)
      rescue URI::InvalidURIError
        URI::Generic.new(nil,nil,nil,nil,nil,nil,nil,nil,nil)
      end
    end

    def merge_defaults(options)
      {
        'host' => 'localhost',
        'port' => '8500'
      }.merge(options)
    end

    def required_opts
      %w{key}
    end

    def validate(options)
      missing_opts = required_opts - options.keys
      if !missing_opts.empty?
        raise "Required options not found: (#{missing_opts.join(', ')})"
      end
      options
    end
  end
end
