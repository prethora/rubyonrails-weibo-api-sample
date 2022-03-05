class WSAPI
    module Exceptions
        class UserNotFound < StandardError
            def initialize(uid)
                super("User with uid '#{uid}' does not exist")
            end
        end
    end
end