require 'json'

module ConsulDo
  class Elect

    def initialize()
      yield ConsulDo.configure! if block_given?
    end

    def base_url
      "http://#{ConsulDo.config.host}:#{ConsulDo.config.port}"
    end

    def get_key
      url = "#{base_url}/v1/kv/service/#{ConsulDo.config.key}/leader"
      response = ConsulDo.http_get(url)
      case response
      when Net::HTTPSuccess
        ConsulDo.log "get_key", JSON.parse(response.body).first
      else
        ConsulDo.log "get_key", {}
      end
    end

    def get_session_info(session_id)
      url = "#{base_url}/v1/session/info/#{session_id}"
      response = ConsulDo.http_get(url)
      if response.body == "null"
        raise "Invalid Session"
      else
        ConsulDo.log "get_session_info", JSON.parse(response.body).first
      end
    end

    def create_session
      url = "#{base_url}/v1/session/create"
      response = ConsulDo.http_put(url, {"name" => ConsulDo.config.session_name})
      case response
      when Net::HTTPSuccess
        ConsulDo.log "create_session", JSON.parse(response.body)['ID']
      else
        raise "Could not create session: #{response.code} - #{response.message} (#{response.body})"
      end
    end

    def session
      ConsulDo.log "session", @session ||= create_session
    end

    def delete_session(session_id = session)
      url = "#{base_url}/v1/session/destroy/#{session_id}"
      response = ConsulDo.http_put(url)
      case response
      when Net::HTTPSuccess
        @session = nil 
      else 
        raise "Could not delete session: #{response.code} - #{response.message} (#{response.body})"
      end

      response
    end

    def delete_sessions
      url = "#{base_url}/v1/session/node/#{get_session_info(session)['Node']}"
      response = ConsulDo.http_get(url)
      JSON.parse(response.body).each do |session_hash|
        if block_given?
          delete_session(session_hash['ID']) if yield session_hash['Name']
        else
          delete_session(session_hash['ID']) if session_hash['Name'] == ConsulDo.config.session_name
        end
      end
    end

    def get_lock
      url = "#{base_url}/v1/kv/service/#{ConsulDo.config.key}/leader?acquire=#{session}"
      response = ConsulDo.http_put(url, {'updated' => Time.now})
      @session_has_lock = true if response.body == "true"
    end

    def session_has_lock?
      @session_has_lock
    end

    def is_leader?
      leader_session = get_key['Session']
      if (leader_session &&
          (session_has_lock? || get_session_info(leader_session)['Node'] == get_session_info(session)['Node']))
        ConsulDo.log "is_leader?", true
      else 
        ConsulDo.log "is_leader?", false
      end
    end

    def cleanup
      delete_session unless session_has_lock?
    end

  end
end
