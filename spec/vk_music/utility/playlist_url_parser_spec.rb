# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Utility::PlaylistUrlParser do
  let(:url) { '' }
  let(:result) { described_class.call(url) }
  let(:result_owner_id) { result[0] }
  let(:result_playlist_id) { result[1] }
  let(:result_access_hash) { result[2] }

  context 'when from search' do
    let(:url) { '/audio?act=audio_playlist-2000176862_6176862&access_hash=96bf45836ffa1675f6' }

    it :aggregate_failures do
      expect(result_owner_id).to eq(-2000176862)
      expect(result_playlist_id).to eq(6176862)
      expect(result_access_hash).to eq('96bf45836ffa1675f6')
    end
  end

  context 'when desktop link' do
    let(:url) { 'https://vk.com/audio?z=audio_playlist-37661843_1/0e420c32c8b69e6637' }

    it :aggregate_failures do
      expect(result_owner_id).to eq(-37661843)
      expect(result_playlist_id).to eq(1)
      expect(result_access_hash).to eq('0e420c32c8b69e6637')
    end
  end

  context 'when desktop link v2' do
    let(:url) { 'https://vk.com/music/album/19198851_39318804_6c2b34085c37213dfb' }

    it :aggregate_failures do
      expect(result_owner_id).to eq(19198851)
      expect(result_playlist_id).to eq(39318804)
      expect(result_access_hash).to eq('6c2b34085c37213dfb')
    end
  end

  context 'when no access hash' do
    let(:url) { 'https://vk.com/music/playlist/-137903314_248' }

    it :aggregate_failures do
      expect(result_owner_id).to eq(-137903314)
      expect(result_playlist_id).to eq(248)
      expect(result_access_hash).to be_nil
    end
  end

  context 'when from separate page' do
    let(:url) { 'https://vk.com/audios437727675?section=playlists&z=audio_playlist437727675_2' }

    it :aggregate_failures do
      expect(result_owner_id).to eq(437727675)
      expect(result_playlist_id).to eq(2)
      expect(result_access_hash).to be_nil
    end
  end
end
