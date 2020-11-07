# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Utility::PlaylistUrlParser do
  let(:url) { '' }
  let(:result) { described_class.call(url) }
  let(:result_owner_id) { result[0] }
  let(:result_playlist_id) { result[1] }
  let(:result_access_hash) { result[2] }

  context 'when from search' do
    let(:url) { '/audio?act=audio_playlist-2000176862_6176862&from=search_global_albums&access_hash=96bf45836ffa1675f6&back_url=%2Faudio%3Fq%3Dtest' }

    it :aggregate_failures do
      expect(result_owner_id).to eq(-2000176862)
      expect(result_playlist_id).to eq(6176862)
      expect(result_access_hash).to eq('96bf45836ffa1675f6')
    end
  end
end
