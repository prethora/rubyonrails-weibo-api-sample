require 'weibo_scraper_api/exceptions/connection_error'

class WSAPI
    module Exceptions
        class ConnectionSocketError < ConnectionError
            def initialize(request,wrapped_exception)
                super("Connection socket error",request,wrapped_exception)
            end
        end
    end
end