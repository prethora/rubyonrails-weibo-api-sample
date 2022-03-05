require 'weibo_scraper_api/exceptions/unknown_response'

class WSAPI
    module Exceptions
        class UnknownResponseBody < UnknownResponse
            def initialize(response)
                super("Unknown response body",response)
            end
        end
    end
end