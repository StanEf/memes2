module Meme
  module Contracts
    class Create < ApplicationContract
      params do
        required(:template_id).value(:integer)
        optional(:text0).value(:string)
        optional(:text1).value(:string)
        optional(:font).value(:integer)
        optional(:max_font_size).value(:integer)

        #todo тут надо сделать валидацию если templates.box_count > 2 то поле обязательно
        #todo и boxes.count == templates.box_count
        # надо еще прокидывать сюда параметры из шаблона
        optional(:boxes).value(:array, min_size?: 0).each do
          hash do
            required(:text).filled(:string)
            required(:x).filled(:integer)
            required(:y).filled(:integer)
            required(:width).filled(:integer)
            required(:height).filled(:integer)
            required(:color).filled(Types::Color)
            required(:outline_color).filled(Types::Color)
          end
        end
      end
    end
  end
end
# params =
#   {
#       template_id: 123123,
#       text0: 'lol',
#       text1: 'lel',
#       font: 12,
#       max_font_size: 234,
#       boxes: [
#           {
#               "text": "One does not simply",
#               "x": 10,
#               "y": 10,
#               "width": 548,
#               "height": 100,
#               "color": "#ffffff",
#               "outline_color": "#000000"
#           },
#           {
#               "text": "Make custom memes on the web via imgflip API",
#               "x": 10,
#               "y": 225,
#               "width": 548,
#               "height": 100,
#               "color": "#ffffff",
#               "outline_color": "#000000"
#           }
#       ]
#   }
# contract = Meme::Contracts::Create.new
# contract.call(params).errors.to_h