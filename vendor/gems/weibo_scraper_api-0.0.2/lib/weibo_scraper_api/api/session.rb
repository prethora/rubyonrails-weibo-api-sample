require 'weibo_scraper_api'
require 'http/cookie_jar'
require 'json'
require 'yaml'

class WSAPI
    module API
        class Session
            attr_accessor :conn

            def initialize(config)
                @config = config
                @jar = HTTP::CookieJar.new                
                @conn = WSAPI::Util::HttpClient.new(jar:@jar,user_agent: config.user_agent,follow_redirects: true,timeout: config.request_timeout_seconds,retries: config.request_retries)
                yield self if block_given?
            end

            def is_active?(logger: nil)
                logger.info("SESSION#is_active") if !logger.nil?

                uid = internal_uid
                raise WSAPI::Exceptions::Unexpected.new("internal_id not found") if uid.nil?

                url = "https://weibo.com/ajax/profile/info?uid=#{uid}"
                headers = {"referer" => "https://weibo.com/u/#{uid}","accept" => "application/json, text/plain, */*"}
                response = @conn.get(url,headers: headers,logger: logger);
                raise WSAPI::Exceptions::Unexpected.new("UNEXP00024","status: #{response.status}") if response.status!=200

                begin
                    json_response = JSON.parse(response.body)
                rescue
                    raise WSAPI::Exceptions::Unexpected.new("UNEXP00025")
                end

                return false if json_response["data"].nil?
                return false if json_response["data"]["user"].nil?
                return false if json_response["data"]["user"]["id"].nil?
                return false if json_response["data"]["user"]["id"].to_s!=uid.to_s

                true
            end

            def renew(skip_initial_check: false,logger: nil)
                logger.info("SESSION#renew: skip_initial_check(#{skip_initial_check})") if !logger.nil?

                if !skip_initial_check
                    return false if is_active?(logger: logger)
                end

                url = "https://weibo.com"
                response = @conn.get(url,logger: logger);
                raise WSAPI::Exceptions::Unexpected.new("UNEXP00026","status: #{response.status}") if response.status!=200

                url = WSAPI::Util::String.simple_parse(response.body,'location.replace("','");')
                raise WSAPI::Exceptions::Unexpected.new("UNEXP00027") if url.nil?

                headers = {"referer" => "https://login.sina.com.cn/"}
                response = @conn.get(url,headers: headers,logger: logger);
                raise WSAPI::Exceptions::Unexpected.new("UNEXP00028","status: #{response.status}") if response.status!=200
                raise WSAPI::Exceptions::Unexpected.new("UNEXP00029") if !is_active?(logger: logger)
            
                return true
            end

            def load(readable)
                @jar.load(readable) if File.exist?(readable)
            end

            def save(writable)
                File.open(writable,"w") { |f| f.write(to_yaml) }
            end

            def to_yaml
                @jar.to_a.to_yaml
            end

            def internal_uid
                lookup_internal_cookie_value "uid"
            end

            private

            def lookup_internal_cookie_value(name)
                internal_cookie = @jar.cookies.filter {|cookie| cookie.name=="internal_#{name}" && cookie.domain=="wsapi.internal" }[0]
                internal_cookie&.value
            end

            def add_internal_cookie_value(name,value)
                internal_cookie = HTTP::Cookie.new("internal_#{name}",value.to_s,domain: "wsapi.internal",
                    for_domain: true,
                    path: "/",
                    max_age: 60*60*24*365*5)
                @jar.add(internal_cookie)
            end
        end
    end
end