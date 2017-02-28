# module Jekyll
#   class MediaGenerator < Generator
#     safe true
#
#     def generate(_site)
#       create_json_files media_dir
#       create_json_files model_dir
#     end
#
#     private
#
#     def save(filename, content)
#       filename = "#{filename}.json"
#       File.open(filename, 'w') do |f|
#         f.write(JSON.pretty_generate(content))
#       end
#     end
#
#     def create_json_files(folder)
#       sub_folders = Dir.entries( "#{folder}/" ).select { |entry| File.directory? File.join(folder, entry) and !(entry == '.' || entry == '..') }
#       if sub_folders.empty?
#         json = Dir[File.join(folder, '*.json')].map { |f| JSON.parse File.read(f) }.flatten
#         file = folder.split('/')[-1]
#         save file, json
#       else
#         sub_folders.each do |file|
#           json = Dir[File.join(folder, file, '*.json')].map { |f| JSON.parse File.read(f) }.flatten
#           save file, json
#         end
#       end
#     end
#
#     def model_dir
#       File.expand_path(File.join(Dir.pwd, '_data', '_models'))
#     end
#
#     def media_dir
#       File.expand_path(File.join(Dir.pwd, '_assets', 'image_data'))
#     end
#   end
# end



#------------------------------------------------------------------------------
#
# This plugin read all the media individual .json files and
# merge them to a single file.
#
# As well same for model instances. All model instance files read and
# merge them to a single file.
#
# When jekyll server running all these files will be created and
# updated accordingly.
#
#---------------------------------------------------------------------------------------------------------------

module Jekyll
  class MediaGenerator < Generator
    safe true

    def generate(_site)
      create_json_files media_dir
      create_json_files model_dir, 'models'
    end

    private

    def save(filename, content)
      filename = "#{filename}.json"
      File.open(filename, 'w') do |f|
        f.write(JSON.pretty_generate(content))
      end
    end

    def create_json_files(folder, file_name = 'models')
      return unless File.directory? folder
      sub_folders = Dir.entries("#{folder}/").select { |entry| File.directory? File.join(folder, entry) and !(entry == '.' || entry == '..') }
      if sub_folders.empty?
        json = Dir[File.join(folder, '*.json')].map { |f| JSON.parse File.read(f) }.flatten
        file = folder.split('/')[-1]
        save file, json
      else
        hash = Hash.new { |h, k| h[k] = [] }
        sub_folders.each do |file|
          Dir[File.join(folder, file, '*.json')].map do |f|
            data = JSON.parse File.read(f)
            hash[file.to_s] << [name: data['name'], file: File.basename(f)]
          end
        end
        save file_name, hash
      end
    end

    def model_dir
      File.expand_path(File.join(Dir.pwd, '_data', '_models'))
    end

    def media_dir
      File.expand_path(File.join(Dir.pwd, '_assets', 'image_data'))
    end
  end
end
