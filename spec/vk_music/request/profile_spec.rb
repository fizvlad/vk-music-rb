# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Request::Profile, :vcr do
  let(:client) { logged_in_client }
  let(:instance) { described_class.new(profile_custom_path: path) }
  let(:path) { '' }

  context 'when user' do
    let(:path) { 'spoontamer' }

    it :aggregate_failures do
      expect(instance.id).to eq(10050301)
      expect(instance.name).to eq('name')
    end
  end

  context 'when club' do
    let(:path) { 'mashup' }

    it :aggregate_failures do
      expect(instance.id).to eq(-39786657)
      expect(instance.name).to eq('name')
    end
  end
end
