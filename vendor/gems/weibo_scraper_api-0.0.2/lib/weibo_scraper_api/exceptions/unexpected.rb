class WSAPI
    module Exceptions
        class Unexpected < StandardError
            def initialize(code,info = "none")
                super("unexpected error: #{code}; info: #{info} (please report this code to the developer)")
            end
        end
    end
end