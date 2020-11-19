# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Audio do
  let(:data) do
    {
      id: 123, owner_id: 456, secret1: secret, secret2: secret,
      artist: 'artist', title: 'title', duration: 120,
      url_encoded: url_encoded, url: url, client_id: 1
    }
  end
  let(:secret) { 'text' }
  let(:url_encoded) { nil }
  let(:url) { nil }
  let(:instance) { described_class.new(**data) }

  describe '.new' do
    it 'allows creation based on big data set' do
      expect(instance).to be_a(described_class)
    end
  end

  describe '#full_id' do
    let(:result) { instance.full_id }

    it { expect(result).to eq('123_456_text_text') }

    context 'when no secrets' do
      let(:secret) { nil }

      it { expect(result).to be_nil }
    end
  end

  describe '#url_accessable?' do
    let(:result) { instance.url_accessable? }

    it { expect(result).to be(true) }

    context 'when no secrets' do
      let(:secret) { nil }

      it { expect(result).to be(false) }
    end
  end

  describe '#url_available?' do
    let(:result) { instance.url_available? }

    it { expect(result).to be(false) }

    context 'when with url_encoded' do
      let(:url_encoded) { 'url' }

      it { expect(result).to be(true) }
    end
  end

  describe '#url_cached?' do
    let(:result) { instance.url_cached? }

    context 'when no url' do
      let(:url) { nil }

      it { expect(result).to be(false) }
    end

    context 'when with url' do
      let(:url) { 'url' }

      it { expect(result).to be(true) }
    end
  end
end
