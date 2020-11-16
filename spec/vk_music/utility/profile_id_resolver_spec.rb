# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Utility::ProfileIdResolver, :vcr do
  let(:client) { logged_in_client }
  let(:url) { 'vk.com/id0' }
  let(:result) { described_class.call(client.agent, url) }

  it { expect(result).to eq(0) }

  context 'when id is explicitly specified' do
    context 'when user' do
      let(:url) { 'vk.com/id12312412' }

      it { expect(result).to eq(12312412) }
    end

    context 'when club' do
      let(:url) { 'vk.com/club111' }

      it { expect(result).to eq(-111) }
    end

    context 'when group' do
      let(:url) { 'vk.com/group111' }

      it { expect(result).to eq(-111) }
    end

    context 'when public' do
      let(:url) { 'vk.com/public111' }

      it { expect(result).to eq(-111) }
    end

    context 'when event' do
      let(:url) { 'vk.com/event111' }

      it { expect(result).to eq(-111) }
    end
  end

  context 'when have to guess by custom path' do
    context 'when durov' do
      let(:url) { 'vk.com/durov' }

      it { expect(result).to eq(1) }
    end

    context 'when user' do
      let(:url) { 'vk.com/spoontamer' }

      it { expect(result).to eq(10050301) }
    end

    context 'when club' do
      let(:url) { 'vk.com/mashup' }

      it { expect(result).to eq(-39786657) }

      context 'when full url club' do
        let(:url) { 'https://vk.com/mashup' }

        it { expect(result).to eq(-39786657) }
      end
    end

    context 'when 404' do
      let(:url) { 'vk.com/a' }

      it { expect(result).to be_nil }
    end

    context 'when not a user page' do
      let(:url) { 'vk.com/feed' }

      it { expect(result).to be_nil }
    end
  end
end
