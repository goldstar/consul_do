require 'json'
require 'net/http'

module Consul
  class Http
    def initialize(host="localhost", port=8500)
      @host = host
      @port = port
      @http_proxy = ENV['http_proxy'] || ENV['HTTP_PROXY']
    end

    def get(uri)
      request('get', uri)
    end

    def put(uri, data=nil)
      request('put', uri, data)
    end

    def request(method, uri, data=nil)
      response = http_client.send_request(method, [base_uri.path + uri.path, uri.query].compact.join('?'), data.to_json, {'Content-type' =>'application/json'})
      response.body
    end

    def proxy
      if @http_proxy
        URI.parse(http_proxy)
      else
        URI::Generic.new(nil,nil,nil,nil,nil,nil,nil,nil,nil)
      end
    end

    def http_client
      if proxy.host && proxy.port
        NET::HTTP.Proxy(proxy.host, proxy.port, proxy.user, proxy.password).new(base_uri.host, base_uri.port)
      else
        Net::HTTP.new(base_uri.host, base_uri.port)
      end
    end

    def base_uri
      URI.parse("http://#{@host}:#{@port}/v1")
    end
  end
  
  class Client

  end
end

class ConsulBag
  def self.read(key)

  end

  def self.write(key, value)

  end

  def self.lock(key)

  end

  def self.unlock(key)

  end

  def self.consul
    @@consulrequest ||= ConsulRequest.new
  end
end

class ConsulRequest
  def initialize

  end

end
