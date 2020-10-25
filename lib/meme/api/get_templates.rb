module Meme
  module Api
    class GetTemplates
      def call(imgflip_get_memes)
        s3 = Aws::S3::Resource.new({client: Aws::S3::Client.new})
        # Imgflip.get_memes
        imgflip_get_memes.each do |meme|
          unless Template.find_by(external_id: meme['id'])
            file = File.new(open(meme['url']))
            obj = s3.bucket(ENV["MINIO_BUCKET"]).object(meme['name'])
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