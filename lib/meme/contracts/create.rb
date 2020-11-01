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
        if key(:boxes)
          template_x_range = Range.new(0, values[:template][:width])
          template_y_range = Range.new(0, values[:template][:height])
          boxes_ranges = []
          values[:boxes]&.each do |box|
            box_ranges = {}
            box_ranges[:x_range] = Range.new(box[:x], (box[:x] + box[:width]))
            box_ranges[:y_range] = Range.new(box[:y], (box[:y] + box[:height]))
            boxes_ranges.push(box_ranges)
          end

          boxes_ranges&.each do |box_ranges1|
            boxes_ranges&.each do |box_ranges2|
              if box_ranges1 != box_ranges2 &&
                 box_ranges1[:y_range].intersection(box_ranges2[:y_range]).count.positive? &&
                 box_ranges1[:x_range].intersection(box_ranges2[:x_range]).count.positive?
                base.failure('boxes cant intersected')
              end
            end
          end

          boxes_ranges&.each do |box_ranges|
            if template_x_range.intersection(box_ranges[:x_range]) != box_ranges[:x_range]
              base.failure('boxes must be inside template by width')
            end

            if template_y_range.intersection(box_ranges[:y_range]) != box_ranges[:y_range]
              base.failure('boxes must be inside template by height')
            end
          end
        end
      end

      # color != outline_color
      # текст с заданым шрифтом и размером шрифта должен влезать в бокс
    end
  end
end
