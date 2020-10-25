require 'rails_helper'
support_file 'imgflip_get_memes_stuff'

describe Meme::Api::GetTemplates do
  include_context :imgflip_get_memes

  subject(:subject) { described_class.new.call(params) }

  let(:params) {
    imgflip_get_memes
  }


  it 'отрабатывает успешно' do
    expect(subject).to be_truthy
    expect(existed_images_in_local_aws).to be_truthy
  end
end