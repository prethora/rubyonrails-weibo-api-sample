require 'weibo_scraper_api/exceptions/connection_error'

class WSAPI
    module Exceptions
        class ConnectionUnknownError < ConnectionError
            def initialize(request,wrapped_exception)
                super("Unknown connection error",request,wrapped_exception)
            end
        end
    end
end