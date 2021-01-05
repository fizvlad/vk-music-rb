# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Request::Artist, :vcr do
  let(:client) { logged_in_client }
  let(:instance) { described_class.new(name, client.id) }
  let(:name) { '' }

  context 'when artist' do
    let(:name) { 'komsomolsk' }

    it :aggregate_failures do
      instance.call(client.agent)
      expect(instance.audios).to be_a(Array)
      expect(instance.audios).to all(be_a(VkMusic::Audio))
      expect(instance.audios).to all(be_url_accessable)
      expect(instance.audios.size).to be >= 35
    end
  end

  context 'when artist A' do
    let(:name) { 'a' }

    it :aggregate_failures do
      instance.call(client.agent)
      expect(instance.audios).to be_a(Array)
      expect(instance.audios).to all(be_a(VkMusic::Audio))
      expect(instance.audios).to all(be_url_accessable)
      expect(instance.audios.size).to be >= 50
    end
  end
end
