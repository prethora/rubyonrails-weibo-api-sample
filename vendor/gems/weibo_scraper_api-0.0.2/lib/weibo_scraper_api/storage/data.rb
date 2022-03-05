require 'fileutils'
require 'date'

class WSAPI
    module Storage
        class Data
            attr_accessor :data_path
            attr_accessor :data_accounts_path

            def initialize(data_path)
                @data_path = data_path
                @data_accounts_path = File.join(@data_path,"accounts")
                @data_logs_path = File.join(@data_path,"logs")

                begin
                    FileUtils.mkdir_p(@data_accounts_path)                    
                rescue
                    raise IOError.new("the configured data path is invalid - unable to create the accounts directory")
                end

                begin
                    FileUtils.mkdir_p(@data_logs_path)                    
                rescue
                    raise IOError.new("the configured data path is invalid - unable to create the logs directory")
                end
            end

            def get_accounts                
                Dir.entries(@data_accounts_path).select { |f| WSAPI::Util::Storage::ConcurrentFile.concurrent_file?(File.join(@data_accounts_path,f)) && !(/^[a-zA-Z0-9\._-]+$/ =~ f).nil? }.sort
            end

            def get_account_path(name)
                File.join(@data_accounts_path,name)
            end

            def get_log_path(name)
                File.join(@data_logs_path,name)
            end

            def create_log(exception,method_name,log_content)
                log_file_path = get_log_path("#{DateTime.now.to_s}-#{method_name}-#{exception.class.name}.log")
                File.open(log_file_path,"w:UTF-8") {|f| f.write(log_content)}
            end
        end
    end
end