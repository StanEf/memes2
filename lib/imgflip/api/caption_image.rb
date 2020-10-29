# Imgflip::Api::CaptionImage.call({
#         template_id: 61585,
#         text1: 'sf',
#         text2: 'afadf'
#     })

module Imgflip
  module Api
    class CaptionImage
      class << self
        def call(params)
          post_params = {
              username: Figaro.env.imgflip_username,
              password: Figaro.env.imgflip_password
          }.merge(params)

          response = Net::HTTP.post_form(URI.parse('https://api.imgflip.com/caption_image'),
                                         post_params)
          response_json = JSON.parse(response.body)

          raise response_json['error_message'] unless response_json['success'] == true

          response_json['data']['url']
        end
      end
    end
  end
end