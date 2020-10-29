require 'rails_helper'

describe Meme::Api::Create do
  subject(:subject) { described_class.call(params) }

  let(:params) do
    {
        template_id: template_id,
        text1: text1,
        text2: text2
    }
  end
  let(:template_id) { 61585 }
  let(:text1) { 'lol' }
  let(:text2) { 'lel' }


  it 'отрабатывает успешно' do
    expect(subject).to be_truthy
  end
end