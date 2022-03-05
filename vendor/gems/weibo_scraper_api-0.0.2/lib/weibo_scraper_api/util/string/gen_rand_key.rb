class WSAPI
    module Util
        module String
            def self.gen_random_key(len = 16)
                table = ('a'..'z').to_a + ('0'..'9').to_a
                (0...len).map { table[rand(table.length)] }.join
            end
        end
    end
end