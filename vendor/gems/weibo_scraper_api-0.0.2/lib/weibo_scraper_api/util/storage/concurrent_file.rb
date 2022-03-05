require 'fileutils'
require 'date'

class WSAPI
    module Util
        module Storage
            class ConcurrentFile
                attr_accessor :file_path

                def initialize(file_path)
                    @file_path = File.expand_path(file_path)
                    begin
                        FileUtils.mkdir_p(@file_path)
                    rescue
                        raise IOError.new("unable to create concurrent file '#{@file_path}', could not create containing directory")
                    end                    
                end

                def write(value)
                    temp_file_path = get_temp_file_path
                    begin
                        File.open(temp_file_path,"w") { |file| file.write(value) }
                    rescue
                        raise IOError.new("unable to create concurrent temp file '#{temp_file_path}', could not write to disk")
                    end

                    content_file_path = get_current_content_file_path                    
                    version = File.basename(content_file_path).split(".")[0]

                    begin
                        FileUtils.mv(temp_file_path,content_file_path)
                    rescue
                        raise IOError.new("unable to move concurrent temp file '#{temp_file_path}' to '#{content_file_path}', could not write to disk")
                    end

                    cleanup

                    return {"version" => version}
                end

                def get_current_version
                    entries = Dir.entries(@file_path).select {|f| !(/^[0-9]+\.content$/=~f).nil? && File.file?(File.join(@file_path,f)) }
                    return nil if entries.empty?
                    entries.sort! {|a,b| b.split(".")[0].to_i <=> a.split(".")[0].to_i }
                    return entries[0].split(".")[0].to_i
                end

                def read
                    version = get_current_version
                    return nil if version.nil?

                    content_file_path = File.join(@file_path,"#{version}.content")
                    begin
                        content = File.read(content_file_path)
                    rescue
                        raise IOError.new("unable to read from concurrent file '#{content_file_path}'")
                    end
                    
                    {"version" => version,"content" => content}                    
                end

                def info
                    version = get_current_version
                    return nil if version.nil?

                    content_file_path = File.join(@file_path,"#{version}.content")
                    
                    [version,content_file_path]
                end

                def self.concurrent_file?(file_path)                    
                    !(Dir[File.join(File.expand_path(file_path),"*.content")].select { |f| File.file?(f) && !(/^[0-9]+\.content$/=~File.basename(f)).nil? }).empty?
                end

                private

                def cleanup                                        
                    entries = Dir.entries(@file_path).select {|f| !(/^[0-9]+\.content$/=~f).nil? && File.file?(File.join(@file_path,f)) }
                    return if entries.length<3
                    entries.sort! {|a,b| b.split(".")[0].to_i <=> a.split(".")[0].to_i }
                    mid_timestamp = entries[1].split(".")[0].to_i
                    now_timestamp = DateTime.now.strftime('%Q').to_i
                    timespan_seconds = (now_timestamp-mid_timestamp)/1000
                    return if timespan_seconds<3

                    entries[2..-1].each do |f|
                        FileUtils.rm(File.join(@file_path,f),force: true)
                    end
                end                

                def get_temp_file_path
                    while File.exist? (temp_file_path=File.join(@file_path,WSAPI::Util::String.gen_random_key)) do; end
                    temp_file_path
                end

                def get_current_content_file_path
                    timestamp = DateTime.now.strftime('%Q')
                    File.join(@file_path,"#{timestamp}.content")
                end
            end
        end
    end
end