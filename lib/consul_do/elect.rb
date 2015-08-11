require 'json'

module ConsulDo
  class Elect

    def initialize(key, options = {})
      @key = key
      host = options['host'] || "localhost"
      port = options['port'] || "8500"
      @base_url = "http://#{host}:#{port}"
      @verbose = options['verbose']
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
      unless response.kind_of?(Net::HTTPSuccess)
        raise "Could not create session: #{response.code} - #{response.message} (#{response.body})"
      end
      ConsulDo.log "create_session", JSON.parse(response.body)['ID']
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
      ConsulDo.log "get_lock", ConsulDo.http_put(url, {'updated' => Time.now})
    end

    def is_leader?
        get_lock
        leader_session = get_key['Session']

        # NOTE in the executable we can check this retval against #session to determine wether or not to #delete_session
        if (get_session_info(leader_session)['Node'] == get_session_info(session)['Node'])
          leader_session
        else
          false
        end
    end

  end
end
