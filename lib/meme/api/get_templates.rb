module Meme
  module Api
    class GetTemplates
      def self.call
        s3 = Aws::S3::Resource.new({ client: Aws::S3::Client.new })
        body = Faraday.get('https://api.imgflip.com/get_memes').body

        body.each do |meme|
          unless Template.find_by(external_id: meme['id'])
            file = File.new(open(meme['url']))
            obj = s3.bucket(ENV["MINIO_BUCKET"]).object(meme['name'])
            # не понимаю почему не аплодятся файлы расположеные локально
            #@todo надо как то проверить успешность upload_file
            obj.upload_file(file)

            if obj
              Template.create(
                  external_id: meme['id'].to_i,
                  name: meme['name'],
                  url: meme['url'],
                  width: meme['width'],
                  height: meme['height'],
                  box_count: meme['box_count']
              )
            end
          end
        end

        true
      end
    end
  end
end