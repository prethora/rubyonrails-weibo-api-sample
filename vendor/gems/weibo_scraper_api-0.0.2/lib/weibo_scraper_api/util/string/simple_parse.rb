class WSAPI
    module Util
        module String
            def self.simple_parse(str,open,close)
                b = str.index(open)
                return nil if b.nil?
                b+= open.length
                e = str.index(close,b)
                return nil if e.nil?
                str[b..e-1]
            end
        end
    end
end