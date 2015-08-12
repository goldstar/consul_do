require "consul_do/version"
require "consul_do/elect"
require "consul_do/config"
require 'net/http'
require 'json'

module ConsulDo
  def self.config
    @config ||= Config.new
  end

  def self.http_client
    if config.proxy.host && config.proxy.port
      log "http_client", Net::HTTP.Proxy(config.proxy.host, config.proxy.port, config.proxy.user, config.proxy.password)
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
    puts [msg,retval.to_s].join(":\n  ") if config.opts['verbose']
    retval
  end
end
