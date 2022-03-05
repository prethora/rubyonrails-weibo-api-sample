class WSAPI
    module Util
        module Validations
            module String
                def self.not_empty?(value,name,optional: false)
                    return value if value.nil? && optional
                    raise ArgumentError.new("argument '#{name}' is required") if value.nil?
                    raise ArgumentError.new("argument '#{name}' is expected to be a string") if !value.is_a?("".class)
                    value.strip!
                    raise ArgumentError.new("argument '#{name}' is expected to be a non-empty string") if value.empty?
                    value
                end

                def self.positive_integer?(value,name,optional: false)
                    return value if value.nil? && optional
                    raise ArgumentError.new("argument '#{name}' is required") if value.nil?
                    raise ArgumentError.new("argument '#{name}' is expected to be a string or integer") if !value.is_a?(1.class) && !value.is_a?("".class)
                    if value.is_a?(1.class)
                        raise ArgumentError.new("argument '#{name}' is expected to be a positive integer") if value<=0
                        value
                    else #is_a?(String)
                        value.strip!
                        error_message = "argument '#{name}' is expected to be a positive integer or string representation of a positive integer"
                        raise ArgumentError.new(error_message) if (/^[0-9]+$/=~value).nil?
                        value = value.to_i
                        raise ArgumentError.new(error_message) if value<=0
                        value
                    end
                end

                def self.matches?(value,regex,name,optional: false)
                    return value if value.nil? && optional
                    raise ArgumentError.new("argument '#{name}' is required") if value.nil?
                    raise ArgumentError.new("argument '#{name}' is expected to be a string") if !value.is_a?("".class)
                    value.strip!                    
                    raise ArgumentError.new("argument '#{name}' is not in the expected format") if (regex =~ value).nil?
                    value
                end
            end
        end
    end
end