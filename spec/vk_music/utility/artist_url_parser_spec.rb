# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Utility::ArtistUrlParser do
  let(:url) { '' }
  let(:result) { described_class.call(url) }

  context 'when gibberish' do
    let(:url) { 'asdasdasd' }

    it { expect(result).to be_nil }
  end

  context 'when feed' do
    let(:url) { 'vk.com/feed' }

    it { expect(result).to be_nil }
  end

  context 'when artist' do
    let(:url) { 'https://vk.com/artist/komsomolsk' }

    it { expect(result).to eq('komsomolsk') }
  end

  context 'when top audios' do
    let(:url) { 'https://vk.com/artist/komsomolsk/top_audios' }

    it { expect(result).to eq('komsomolsk') }
  end
end
