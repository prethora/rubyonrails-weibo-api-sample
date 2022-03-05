class WSAPI
    module Exceptions
        class ConnectionError < StandardError
            attr_reader :request
            attr_reader :wrapped_exception

            def initialize(message,request,wrapped_exception)
                super("#{message} (method: #{request["method"]}, url: #{request["url"]})")
                @request = request
                @wrapped_exception = wrapped_exception;
            end
        end
    end
end