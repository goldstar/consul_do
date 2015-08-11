require "consul_do/version"
require "consul_do/elect"
require 'net/http'
require 'json'

module ConsulDo

  def self.proxy
    proxy = ENV['http_proxy'] || ENV['HTTP_PROXY']
    begin
      URI.parse(proxy)
    rescue URI::InvalidURIError
      URI::Generic.new(nil,nil,nil,nil,nil,nil,nil,nil,nil)
    end

  end

  def self.http_client
    return Net::HTTP.Proxy(proxy.host, proxy.port, proxy.user, proxy.password) if proxy.host && proxy.port
    Net::HTTP
  end

  def self.http_put(dest_url, data = nil)
    uri = URI.parse(dest_url)
    request = http_client.new(uri.host, uri.port)
    request.send_request('PUT', "#{ [uri.path, uri.query].compact.join('?') }", data.to_json, {'Content-type' => 'application/json'})
  end

  def self.http_get(dest_url)
    http_client.get_response(URI(dest_url))
  end

end
