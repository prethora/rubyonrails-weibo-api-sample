class WSAPI
    module Util
        module Validations
            module Integer
                def self.positive_integer?(value,name)
                    raise ArgumentError.new("argument '#{name}' is required") if value.nil?
                    raise ArgumentError.new("argument '#{name}' is expected to be an integer") if !value.is_a?(1.class)
                    raise ArgumentError.new("argument '#{name}' is expected to be a positive integer") if value<=0
                    value
                end
            end
        end
    end
end