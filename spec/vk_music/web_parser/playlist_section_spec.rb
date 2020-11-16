# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::WebParser::PlaylistSection do
  let(:data) { spec_data('playlist_section') }
  let(:instance) { described_class.new(data) }

  describe '#audios' do
    let(:result) { instance.audios }

    it :aggregate_failures do
      expect(result).to be_a(Array)
      expect(result).to all(be_an(VkMusic::Audio))
      expect(result.size).to be >= 5
    end
  end

  describe '#title' do
    let(:result) { instance.title }

    it :aggregate_failures do
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end
  end

  describe '#subtitle' do
    let(:result) { instance.subtitle }

    it :aggregate_failures do
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end
  end

  describe '#real_size' do
    let(:result) { instance.real_size }

    it :aggregate_failures do
      expect(result).to be_a(Integer)
      expect(result).to be >= 100
    end
  end
end
