# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Request::Playlist, :vcr do
  let(:client) { logged_in_client }
  let(:instance) { described_class.new(-137903314, 248, nil, client.id) }
  let(:owner_id) { -137903314 }
  let(:playlist_id) { 248 }
  let(:owner_id) { nil }

  it :aggregate_failures do
    instance.call(client.agent)

    expect(instance.audios).not_to be_empty
  end
end
