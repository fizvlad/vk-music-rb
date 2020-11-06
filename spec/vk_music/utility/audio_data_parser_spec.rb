# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Utility::AudioDataParser do
  let(:data) { JSON.parse(spec_data('load_section__single_data_array')) }
  let(:result) { described_class.call(data, 1) }

  it 'returns audio' do
    expect(result).to be_a(VkMusic::Audio)
  end
end
