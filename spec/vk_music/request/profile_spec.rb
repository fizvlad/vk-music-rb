# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Request::Profile, :vcr do
  let(:client) { logged_in_client }
  let(:instance) { described_class.new(profile_custom_path: path) }
  let(:path) { '' }

  context 'when user' do
    let(:path) { 'spoontamer' }

    it :aggregate_failures do
      instance.call(client.agent)
      expect(instance.id).to eq(10050301)
      expect(instance.last_post_id).to be > 35_000
    end
  end

  context 'when club' do
    let(:path) { 'mashup' }

    it :aggregate_failures do
      instance.call(client.agent)
      expect(instance.id).to eq(-39786657)
      expect(instance.last_post_id).to be > 398_000
    end
  end
end
