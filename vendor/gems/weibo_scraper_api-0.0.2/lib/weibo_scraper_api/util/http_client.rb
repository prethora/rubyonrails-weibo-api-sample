require 'faraday'
require 'faraday/net_http'
require 'faraday-cookie_jar'
require 'faraday_middleware'
require 'http/cookie_jar'
require 'logger'

Faraday.default_adapter = :net_http

class WSAPI
    module Util
        class HttpClient
            def initialize(jar: HTTP::CookieJar.new,user_agent: nil,follow_redirects: false,log: false,logger: nil,timeout: 15.0,retries: 0)
                @jar = jar
                @follow_redirects = follow_redirects
                @timeout = timeout
                @retries = retries
                @logger = nil
                if log
                    @logger = logger.nil? ? Logger.new($stdout) : logger
                end
                @baseHeaders = {
                    "pragma" => "no-cache",
                    "cache-control" => "no-cache",
                    "sec-ch-ua" => "\"Chromium\";v=\"94\", \"Google Chrome\";v=\"94\", \";Not A Brand\";v=\"99\"",
                    "sec-ch-ua-mobile" => "?0",
                    "sec-ch-ua-platform" => "\"Linux\"",
                    "upgrade-insecure-requests" => "1",
                    "user-agent" => !user_agent.nil? ? user_agent : "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36",
                    "accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
                    "sec-fetch-site" => "none",
                    "sec-fetch-mode" => "navigate",
                    "sec-fetch-user" => "?1",
                    "sec-fetch-dest" => "document",
                    "accept-language" => "en-US,en;q=0.9,fr-FR;q=0.8,fr;q=0.7,es;q=0.6",
                }
            end

            def get(url,headers: {},logger: nil)
                logger = @logger if logger.nil?

                def log_info(logger,message)
                    logger.info(message) if !logger.nil?
                end

                conn = Faraday.new do |builder|
                    builder.options.timeout = @timeout
                    builder.use FaradayMiddleware::FollowRedirects if @follow_redirects
                    builder.use :cookie_jar,jar: @jar
                    builder.response :logger,logger,{headers: true,bodies: true} if !logger.nil?
                    builder.adapter Faraday.default_adapter
                end                  

                log_info(logger,"HTTP_CLIENT: METHOD(GET) URL(#{url}) HEADERS(#{headers}) TIMEOUT(#{@timeout}) RETRIES(#{@retries})")
                headers = @baseHeaders.merge(headers)
                for i in 1..@retries+1
                    begin
                        response = conn.get(url,{},headers)
                        return response if response.status>=200 && response.status<500
                        return response if i==@retries+1
                        log_info(logger,"HTTP_CLIENT: cause for retrial: status: #{response.status}")
                    rescue => e
                        if i==@retries+1
                            request = {"method" => "get","url" => url}
                            if e.wrapped_exception && e.wrapped_exception.class==SocketError
                                raise WSAPI::Exceptions::ConnectionSocketError.new(request,e.wrapped_exception)
                            elsif e.wrapped_exception && e.wrapped_exception.class==Net::OpenTimeout
                                raise WSAPI::Exceptions::ConnectionTimeoutError.new(request,e.wrapped_exception)
                            else
                                raise WSAPI::Exceptions::ConnectionUnknownError.new(request,e.wrapped_exception)
                            end
                        end
                        log_info(logger,"HTTP_CLIENT: cause for retrial: #{e}")
                    end
                    log_info(logger,"HTTP_CLIENT: retrial #{i} of #{@retries}")
                end
            end
        end
    end
end