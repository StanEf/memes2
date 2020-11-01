# frozen_string_literal: true

require 'rails_helper'

describe 'Meme::Api::Create.contract' do
  subject(:subject) { Meme::Api::Create.contract(params) }

  let(:params) do
    {
      template: template.attributes,
      text0: text0,
      text1: text1,
      box_count: box_count,
      boxes: boxes
    }
  end
  let(:template) do
    build(:template,
          external_id: 61_585,
          name: 'Bad Luck Brian',
          link: 'https://i.imgflip.com/1bip.jpg',
          width: 475,
          height: 562,
          box_count: 2)
  end
  let(:text0) { 'lol' }
  let(:text1) { 'lel' }
  let(:box_count) { 2 }
  let(:boxes) { [] }

  it 'отрабатывает успешно' do
    expect(subject).to be_truthy
  end

  context 'must not be transmitted simultaneously' do
    let(:boxes) do
      [
        {
          text: 'lol',
          x: 100,
          y: 100,
          width: 100,
          height: 100,
          color: '#fff',
          outline_color: '#ccc'
        }
      ]
    end

    context 'text0, boxes' do
      it do
        expect(subject.errors.to_h[nil])
          .to include('text0, boxes must not be transmitted simultaneously')
      end
    end

    context 'text1, boxes' do
      it do
        expect(subject.errors.to_h[nil])
          .to include('text1, boxes must not be transmitted simultaneously')
      end
    end
  end

  context 'text0 must be exist if boxes empty and box_count <= 2' do
    let(:text0) { '' }

    it do
      expect(subject.errors.to_h[nil])
        .to include('text0 must be exist if boxes empty and box_count <= 2')
    end
  end

  context 'text1 must be not empty if boxes empty and box_count == 2' do
    let(:text1) { '' }

    it do
      expect(subject.errors.to_h[nil])
        .to include('text1 must be not empty if boxes empty and box_count == 2')
    end
  end

  context 'text0 and text1 must not be transmitted if box_count > 2' do
    let(:text0) { '' }
    let(:text1) { '' }
    let(:box_count) { 3 }
    it do
      expect(subject.errors.to_h[nil])
        .to include('text0 and text1 must not be transmitted if box_count > 2')
    end
  end

  context 'boxes must be inside template by width' do
    let(:boxes) do
      [
        {
          text: 'lol',
          x: 100,
          y: 100,
          width: 380,
          height: 100,
          color: '#fff',
          outline_color: '#ccc'
        }
      ]
    end
    it do
      expect(subject.errors.to_h[nil])
        .to include('boxes must be inside template by width')
    end
  end

  context 'boxes must be inside template by height' do
    let(:boxes) do
      [
        {
          text: 'lol',
          x: 100,
          y: 100,
          width: 280,
          height: 500,
          color: '#fff',
          outline_color: '#ccc'
        }
      ]
    end
    it do
      expect(subject.errors.to_h[nil])
        .to include('boxes must be inside template by height')
    end
  end

  context 'boxes cant intersected' do
    let(:boxes) do
      [
        {
          text: 'lol',
          x: 100,
          y: 100,
          width: 100,
          height: 100,
          color: '#fff',
          outline_color: '#ccc'
        },
        {
          text: 'lol2',
          x: 150,
          y: 100,
          width: 200,
          height: 100,
          color: '#fff',
          outline_color: '#ccc'
        }
      ]
    end

    it do
      expect(subject.errors.to_h[nil])
        .to include('boxes cant intersected')
    end
  end
end
