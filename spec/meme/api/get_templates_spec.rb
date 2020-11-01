# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'
support_file 'imgflip_get_memes_stuff'

describe Meme::Api::GetTemplates, type: :feature, js: true do
  include_context :imgflip_get_memes

  subject(:subject) { described_class.call }

  let(:body) do
    [
      { 'id' => '181913649', 'name' => 'Drake Hotline Bling', 'url' => Rails.root.join('spec', 'support', 'imgflip_get_memes_stuff', '30b1gx.jpg'), 'width' => 1200, 'height' => 1200, 'box_count' => 2 },
      { 'id' => '112126428', 'name' => 'Distracted Boyfriend', 'url' => Rails.root.join('spec', 'support', 'imgflip_get_memes_stuff', '30b1gx.jpg'), 'width' => 1200, 'height' => 800, 'box_count' => 3 }
    ]
  end

  before do
    WebMock.stub_request(:get, 'https://api.imgflip.com/get_memes')
           .to_return(body: imgflip_get_memes)
  end

  it 'отрабатывает успешно' do
    expect(subject).to be_truthy
    expect(existed_images_in_local_aws).to be_truthy
    delete_existed_images_in_local_aws
  end
end
