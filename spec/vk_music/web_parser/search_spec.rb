# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::WebParser::Search do
  let(:html) { spec_data('mobile_ajax_search__html') }
  let(:node) { Nokogiri::HTML.fragment(html) }
  let(:instance) { described_class.new(node) }

  describe '#audios' do
    let(:result) { instance.audios }

    it :aggregate_failures do
      expect(result).to be_a(Array)
      expect(result).to all(be_an(VkMusic::Audio))
      expect(result.size).to be >= 5
    end
  end

  describe '#audios_all_path' do
    let(:result) { instance.audios_all_path }

    it :aggregate_failures do
      expect(result).to be_a(String)
      expect(result).to start_with('/audio?act=block&block=')
    end
  end

  describe '#playlists_all_path' do
    let(:result) { instance.playlists_all_path }

    it :aggregate_failures do
      expect(result).to be_a(String)
      expect(result).to start_with('/audio?act=block&block=')
    end
  end
end
