# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Utility::DurationParser do
  let(:string) { '00:00:13' }
  let(:result) { described_class.call(string) }

  it { expect(result).to eq(13) }

  context 'when minutes specified' do
    let(:string) { '00:10:13' }

    it { expect(result).to eq(613) }
  end

  context 'when hours specified' do
    let(:string) { '01:00:13' }

    it { expect(result).to eq(3613) }
  end

  context 'when short form' do
    let(:string) { '10:13' }

    it { expect(result).to eq(613) }
  end
end
