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
    if proxy.host && proxy.port
      log "http_client", Net::HTTP.Proxy(proxy.host, proxy.port, proxy.user, proxy.password)
    else
      log "http_client", Net::HTTP
    end
  end

  def self.http_put(dest_url, data = nil)
    uri = URI.parse(dest_url)
    request = http_client.new(uri.host, uri.port)
    log "http_put", request.send_request('PUT', "#{ [uri.path, uri.query].compact.join('?') }", data.to_json, {'Content-type' => 'application/json'})
  end

  def self.http_get(dest_url)
    log "http_get", http_client.get_response(URI(dest_url))
  end

  def self.log(msg, retval)
    puts [msg,retval.to_s].join(":\n  ") if VERBOSE
    retval
  end
end
