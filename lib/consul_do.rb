require "consul_do/version"
require "consul_do/elect"
require "consul_do/config"
require 'net/http'
require 'json'

module ConsulDo
  def self.config
    @config ||= Config.new
  end

  def self.configure!
    @config = Config.new
    yield config
  end

  def self.elect
    @elect ||= Elect.new
  end

  def self.elect!
    @elect = Elect.new
  end

  def self.http_put(dest_url, data = nil)
    uri = URI.parse(dest_url)
    request = config.http_client.new(uri.host, uri.port)
    log "http_put", request.send_request('PUT', "#{ [uri.path, uri.query].compact.join('?') }", data.to_json, {'Content-type' => 'application/json'})
  end

  def self.http_get(dest_url)
    log "http_get", config.http_client.get_response(URI(dest_url))
  end

  def self.log(msg, retval)
    puts [msg,retval.to_s].join(":\n  ") if config.verbose
    retval
  end
end
