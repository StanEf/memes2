# frozen_string_literal: true

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
        required(:template).value(:hash) do
          required(:external_id).filled(:integer)
          required(:name).filled(:string)
          required(:link).filled(:string)
          required(:width).filled(:integer)
          required(:height).filled(:integer)
          required(:box_count).filled(:integer)
        end
        # может быть произвольным и != Template.box_count
        required(:box_count).value(:integer)
        optional(:text0).value(:string)
        optional(:text1).value(:string)
        optional(:font).value(:integer)
        optional(:max_font_size).value(:integer)

        # TODO: тут надо сделать валидацию если templates.box_count > 2 то поле обязательно
        # todo и boxes.count == templates.box_count
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
        base.failure('text0, boxes must not be transmitted simultaneously') if key?(:boxes) && key?(:text0)
      end

      rule(:text1, :boxes) do
        base.failure('text1, boxes must not be transmitted simultaneously') if key?(:boxes) && key?(:text1)
      end

      rule(:text0, :box_count, :boxes) do
        if !key?(:text0) && !key?(:boxes) && [1, 2].include?(values[:box_count])
          base.failure('text0 must be exist if boxes empty and box_count <= 2')
        end
      end

      rule(:text1, :box_count, :boxes) do
        if !key?(:text1) && !key?(:boxes) && values[:box_count] == 2
          base.failure('text1 must be not empty if boxes empty and box_count == 2')
        end
      end

      rule(:text0, :text1, :box_count) do
        if values[:box_count] > 2 && !key?(:text0) && !key?(:text1)
          base.failure('text0 and text1 must not be transmitted if box_count > 2')
        end
      end

      rule(:template, :boxes) do
        if key(:boxes)
          values[:boxes]&.each do |box|
            if box[:x] + box[:width] > values[:template][:width]
              base.failure('must be box.x + box.width <= template.width')
            end

            if box[:y] + box[:height] > values[:template][:height]
              base.failure('must be box.y + box.height <= template.height')
            end
          end
        end
      end

      rule(:template, :boxes) do
        if key(:boxes)
          values[:boxes]&.each do |box|
            if (box[:x] + box[:width] > values[:template][:width]) ||
               (box[:y] + box[:height] > values[:template][:height])
              base.failure('boxes must be inside template')
            end
          end
        end
      end

      rule(:template, :boxes) do
        # валидация красивая, но очень долгая
        if key(:boxes)
          template_map = {}
          (1..values[:template][:width]).each do |pixel_width|
            template_map[pixel_width] = {}
            (1..values[:template][:height]).each do |pixel_height|
              template_map[pixel_width][pixel_height] = 0
            end
          end

          values[:boxes]&.each do |box|
            (box[:x]..(box[:x] + box[:width])).each do |x|
              (box[:y]..(box[:y] + box[:height])).each do |y|
                if !template_map[x] || !template_map[x][y]
                  base.failure('boxes must be inside template')
                elsif template_map[x][y] == 1
                  base.failure('boxes cant intersected')
                else
                  template_map[x][y] = 1
                end
              end
            end
          end
        end
      end
      # color != outline_color
      # текст с заданым шрифтом и размером шрифта должен влезать в бокс
    end
  end
end
