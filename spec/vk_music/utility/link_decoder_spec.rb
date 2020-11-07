# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Utility::LinkDecoder do
  let(:encoded_url_and_id) { spec_data('encoded_url_and_id') }
  let(:link) { encoded_url_and_id.split("\n").first }
  let(:client_id) { Integer(encoded_url_and_id.split("\n").last, 10) }
  let(:result) { described_class.call(link, client_id) }

  it { expect(result).to start_with('https://m.vk.com/mp3/audio_api_unavailable.mp3?extra=') }
end
