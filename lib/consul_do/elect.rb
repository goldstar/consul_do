require 'json'

module ConsulDo
  class Elect

    def initialize()
      @key = ConsulDo.config.opts['key']
      host = ConsulDo.config.opts['host']
      port = ConsulDo.config.opts['port']
      @base_url = "http://#{host}:#{port}"
    end

    def get_key
      url = "#{@base_url}/v1/kv/service/#{@key}/leader"
      response = ConsulDo.http_get(url)
      ConsulDo.log "get_key", JSON.parse(response.body).first
    end

    def get_session_info(session_id)
      url = "#{@base_url}/v1/session/info/#{session_id}"
      response = ConsulDo.http_get(url)
      ConsulDo.log "get_session_info", JSON.parse(response.body).first
    end

    def create_session
      url = "#{@base_url}/v1/session/create"
      response = ConsulDo.http_put(url, {"name" => "#{@key}_session"})
      case response
      when Net::HTTPSuccess
        ConsulDo.log "create_session", JSON.parse(response.body)['ID']
      when Net::HTTPError
        raise "Could not create session: #{response.code} - #{response.message} (#{response.body})"
      end
    end

    def session
      ConsulDo.log "session", @session ||= create_session
    end

    def delete_session
      url = "#{@base_url}/v1/session/destroy/#{session}"
      ConsulDo.log "delete_session", ConsulDo.http_put(url)
    end

    def get_lock
      url = "#{@base_url}/v1/kv/service/#{@key}/leader?acquire=#{session}"
      response = ConsulDo.http_put(url, {'updated' => Time.now})
      @has_lock = true if response.body == "true"
    end

    def is_leader?
      leader_session = get_key['Session']
      if (leader_session &&
          (@has_lock || get_session_info(leader_session)['Node'] == get_session_info(session)['Node']))
        ConsulDo.log "is_leader?", true
      else 
        ConsulDo.log "is_leader?", false
       end
    end

    def cleanup
      delete_session unless @has_lock
    end

  end
end
