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
      url = "#{base_url}/v1/kv/service/#{ConsulDo.config.key}/leader?" + token_str
      response = ConsulDo.http_get(url)
      ConsulDo.log "get_key", parse_json(response.body, [{}]).first
    end

    def parse_json(json_blob, default_value)
      begin
        JSON.parse(json_blob)
      rescue JSON::ParserError, TypeError
        default_value
      end
    end

    def get_session_info(session_id)
      url = "#{base_url}/v1/session/info/#{session_id}"
      response = ConsulDo.http_get(url)
      ConsulDo.log "get_session_info", parse_json(response.body, []).first or raise "Invalid Session"
    end

    def create_session
      url = "#{base_url}/v1/session/create"
      response = ConsulDo.http_put(url, {'name' => ConsulDo.config.session_name})

      ConsulDo.log "create_session", parse_json(response.body, {})['ID'] or raise "Could not create session: #{response.code} - #{response.message} (#{response.body})"
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
      parse_json(response.body, []).each do |session_hash|
        if block_given?
          delete_session(session_hash['ID']) if yield session_hash['Name']
        else
          delete_session(session_hash['ID']) if session_hash['Name'] == ConsulDo.config.session_name
        end
      end
    end

    def token_str
      if ConsulDo.config.token
        "&token=#{ConsulDo.config.token}"
      else
        ""
      end
    end

    def get_lock
      url = "#{base_url}/v1/kv/service/#{ConsulDo.config.key}/leader?acquire=#{session}" + token_str
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
