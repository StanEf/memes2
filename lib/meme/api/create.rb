module Meme
  module Api
    class Create
      def call(params)
        # тут надо провалидировать все параметры

        Imgflip::Api::CaptionImage.call(params)
        # тут надо сохранить мем локально
        true
      end
    end
  end
end