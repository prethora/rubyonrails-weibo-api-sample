class WSAPI
    module Exceptions
        class UnknownResponse < StandardError
            attr_reader :response

            def initialize(message,response)
                super(message)
                @response = response
            end
        end
    end
end