require 'weibo_scraper_api/exceptions/unknown_response'

class WSAPI
    module Exceptions
        class UnknownResponseStatus < UnknownResponse
            def initialize(response)
                super("Unknown response status: #{response["status"]}",response)
            end
        end
    end
end