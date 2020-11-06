# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Audio do
  describe '.new' do
    let(:data) do
      {
        id: 123,
        owner_id: 456,
        secret1: 'text1',
        secret2: 'text2',
        artist: 'artist',
        title: 'title',
        duration: 120,
        url_encoded: nil,
        url: nil,
        client_id: 1
      }
    end
    let(:result) { described_class.new(**data) }

    it 'allows creation based on big data set' do
      expect(result).to be_a(described_class)
    end
  end
end
