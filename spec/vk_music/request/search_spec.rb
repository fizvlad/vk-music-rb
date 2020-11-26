# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Request::Search, :vcr do
  let(:client) { logged_in_client }
  let(:instance) { described_class.new(query, client.id) }
  let(:query) { 'test' }

  context 'when valid search query' do
    let(:query) { 'test' }

    it :aggregate_failures do
      instance.call(client.agent)

      expect(instance.audios).not_to be_empty
    end
  end
end
