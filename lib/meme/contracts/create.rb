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
module Meme
  module Contracts
    class Create < ApplicationContract
      params do
        required(:template).value(:integer)
        required(:box_count).value(:integer)

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

      rule(:text0, :boxes) do
        key.failure('must not be transmitted simultaneously') if key?(:boxes) && key?(:text0)
      end

      rule(:text1, :boxes) do
        key.failure('must not be transmitted simultaneously') if key?(:boxes) && key?(:text1)
      end

      rule(:text0, :box_count, :boxes, ) do
        if key?(:text0) && !key?(:boxes) && [1, 2].include?(values[:box_count])
          key.failure('text0 must be exist')
        end
      end

      rule(:text1, :box_count, :boxes, ) do
        if key?(:text1) && !key?(:boxes) && values[:box_count] == 2
          key.failure('text1 must be exist')
        end
      end

      rule(:text0, :text1, :box_count, ) do
        if values[:box_count] > 2 && (key?(:text0) || key?(:text1))
          key.failure('text0 and text1 must not be transmitted simultaneously if box_count > 2')
        end
      end

      rule(:box_count, :boxes, ) do
        if key?(:boxes) && values[:box_count] != values[:boxes].count
          key.failure('box_count != boxes.count')
        end
      end

    # box.x + box.width <= template.width
    # box.y + box.height <= template.height
    # color != outline_color
    # текст с заданым шрифтом и размером шрифта должен влезать в бокс
    #
    end
  end
end