# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Client, :vcr do
  let(:instance) { logged_in_client }

  describe '.new' do
    it :aggregate_failures do
      expect(instance.id).to be_a(Integer)
      expect(instance.name).to be_a(String)
    end

    context 'when password incorrect' do
      let(:instance) { VkMusic::Client.new(login: '+79991234567', password: 'ae') }

      it { expect { instance }.to raise_error(RuntimeError) }
    end
  end

  describe '#find' do
    let(:query) { '' }
    let(:type) { :audio }
    let(:result) { instance.find(query, type: type) }

    context 'when searching for audios' do
      let(:type) { :audio }

      context 'when empty query' do
        let(:query) { '' }

        it { expect(result).to be_empty }
      end

      context 'when OK query' do
        let(:query) { 'test' }

        it :aggregate_failures do
          expect(result).to all(be_a(VkMusic::Audio))
          expect(result).not_to be_empty
        end
      end

      context 'when big ugly query' do
        let(:query) { '0cun89012  ru0 9238yv09u rn0802938uyv02938vn09v4y09234ynv89072ryn0278yhv7823hf98723r' }

        it { expect(result).to be_empty }
      end
    end

    context 'when searching for playlists' do
      let(:type) { :playlist }

      context 'when empty query' do
        let(:query) { '' }

        it { expect(result).to be_empty }
      end

      context 'when OK query' do
        let(:query) { 'test' }

        it :aggregate_failures do
          expect(result).to all(be_a(VkMusic::Playlist))
          expect(result).not_to be_empty
        end
      end

      context 'when big ugly query' do
        let(:query) { '0cun89012  ru0 9238yv09u rn0802938uyv02938vn09v4y09234ynv89072ryn0278yhv7823hf98723r' }

        it { expect(result).to be_empty }
      end
    end

    context 'when searching for gibberish' do
      let(:type) { :gibberish }
      let(:query) { '' }

      it { expect(result).to be_empty }
    end
  end

  describe '#playlist' do
    let(:url) { '' }
    let(:up_to) { 10_000 }
    let(:result) { instance.playlist(url: url, up_to: up_to) }

    context 'when playlist' do
      let(:url) { 'https://vk.com/music/playlist/19198851_39318804_6c2b34085c37213dfb' }

      it :aggregate_failures do
        expect(result).to be_a(VkMusic::Playlist)
        expect(result.size).to eq(6)
        expect(result.real_size).to eq(6)
        expect(result.title).to eq('Klooe - Electrify The Love [EP]')
      end

      context 'when private playlist without access hash' do
        let(:url) { 'https://vk.com/music/playlist/-37661843_1' }

        it :aggregate_failures do
          expect(result).to be_nil
        end
      end

      context 'when playlist got disabled audios' do
        let(:url) { 'https://vk.com/music/playlist/-33507639_58254888_0d3aabf63b6a016fc2' }

        it :aggregate_failures do
          expect(result).to be_a(VkMusic::Playlist)
          expect(result.size).to eq(15)
          expect(result.real_size).to eq(15)
          expect(result.map(&:to_s).uniq.size).to eq(15)
        end
      end
    end

    context 'when album' do
      let(:url) { 'https://vk.com/music/album/-2000637322_637322_e677ea2eab62dc17a8' }

      it :aggregate_failures do
        expect(result).to be_a(VkMusic::Playlist)
        expect(result.size).to eq(30)
        expect(result.real_size).to eq(30)
        expect(result.title).to eq('La La Land Original Motion Picture Score')
      end
    end

    context 'when large playlist' do
      let(:url) { 'https://vk.com/music/playlist/274274487_57' }

      it :aggregate_failures do
        expect(result).to be_a(VkMusic::Playlist)
        expect(result.size).to be >= 1000
        expect(result.real_size).to be >= 1000
      end

      context 'when up_to specified' do
        let(:up_to) { 120 }

        it { expect(result.size).to eq(120) }
      end
    end

    context 'when gibberish' do
      let(:url) { 'https://vk.com/music/playlist/11111_22222' }

      it { expect(result).to be_nil }
    end

    context 'when 404' do
      let(:url) { 'https://vk.com/a' }

      it { expect(result).to be_nil }
    end

    context 'when feed' do
      let(:url) { 'https://vk.com/feed' }

      it { expect(result).to be_nil }
    end
  end

  describe '#audios' do
    let(:url) { '' }
    let(:up_to) { 10_000 }
    let(:result) { instance.audios(url: url, up_to: up_to) }

    context 'when user' do
      let(:url) { 'https://vk.com/id8024985' }

      it :aggregate_failures do
        expect(result).to be_a(VkMusic::Playlist)
        expect(result.size).to be >= 2000
        expect(result.real_size).to be >= 2000
        expect(result.title).to eq('музыка Святослава Комиссарова')
      end

      context 'when audios page' do
        let(:url) { 'https://vk.com/audios8024985' }

        it :aggregate_failures do
          expect(result).to be_a(VkMusic::Playlist)
          expect(result.size).to be >= 2000
          expect(result.real_size).to be >= 2000
          expect(result.title).to eq('музыка Святослава Комиссарова')
        end
      end

      context 'when user with closed profile' do
        let(:url) { 'https://vk.com/id15' }

        it :aggregate_failures do
          expect(result).to be_nil
        end
      end

      context 'when user with closed audios' do
        let(:url) { 'https://vk.com/id18' }

        it :aggregate_failures do
          expect(result).to be_nil
        end
      end
    end

    context 'when group' do
      let(:url) { 'https://vk.com/mashup' }

      it :aggregate_failures do
        expect(result).to be_a(VkMusic::Playlist)
        expect(result.size).to be >= 2000
        expect(result.real_size).to be >= 2000
        expect(result.title).to eq('Музыка сообщества #mashup')
      end

      context 'when audios page' do
        let(:url) { 'https://vk.com/audios-39786657' }

        it :aggregate_failures do
          expect(result).to be_a(VkMusic::Playlist)
          expect(result.size).to be >= 2000
          expect(result.real_size).to be >= 2000
          expect(result.title).to eq('Музыка сообщества #mashup')
        end
      end

      context 'when closed group' do
        let(:url) { 'https://vk.com/vkappdevelopers' }

        it :aggregate_failures do
          expect(result).to be_nil
        end
      end

      context 'when group with closed audios' do
        let(:url) { 'https://vk.com/overhearspbsu' }

        it :aggregate_failures do
          expect(result).to be_nil
        end
      end
    end

    context 'when 404' do
      let(:url) { 'https://vk.com/a' }

      it { expect(result).to be_nil }
    end

    context 'when feed' do
      let(:url) { 'https://vk.com/a' }

      it { expect(result).to be_nil }
    end
  end

  describe '#wall' do
    let(:url) { '' }
    let(:up_to) { 100 }
    let(:result) { instance.wall(url: url) }

    context 'when user with empty wall' do
      let(:url) { 'https://vk.com/id1' }

      it :aggregate_failures do
        expect(result).to be_nil
      end
    end

    context 'when group' do
      let(:url) { 'https://vk.com/mashup' }

      it :aggregate_failures do
        expect(result).to be_a(VkMusic::Playlist)
        expect(result.size).to be >= 80
        expect(result.title).to eq('музыка со стены #mashup')
      end

      context 'when owner_id specified' do
        let(:result) { instance.wall(owner_id: -39786657) }

        it :aggregate_failures do
          expect(result).to be_a(VkMusic::Playlist)
          expect(result.size).to be >= 80
          expect(result.title).to eq('музыка со стены #mashup')
        end
      end

      context 'when owner_id and post_id are specified' do
        let(:result) { instance.wall(owner_id: -39786657, post_id: 398228) }

        it :aggregate_failures do
          expect(result).to be_a(VkMusic::Playlist)
          expect(result.size).to eq(100)
          expect(result.title).to eq('музыка со стены #mashup')
        end
      end

      context 'when owner_id and post_id are specified in url' do
        let(:result) { instance.wall(url: 'https://vk.com/wall-39786657_398228') }

        it :aggregate_failures do
          expect(result).to be_a(VkMusic::Playlist)
          expect(result.size).to eq(100)
          expect(result.title).to eq('музыка со стены #mashup')
        end
      end
    end

    context 'when 404' do
      let(:url) { 'https://vk.com/a' }

      it :aggregate_failures do
        expect(result).to be_nil
      end
    end

    context 'when feed' do
      let(:url) { 'https://vk.com/feed' }

      it :aggregate_failures do
        expect(result).to be_nil
      end
    end
  end

  describe '#post' do
    let(:url) { '' }
    let(:result) { instance.post(url: url) }

    context 'when post with audio' do
      let(:url) { 'https://vk.com/wall-39786657_399071' }

      it :aggregate_failures do
        expect(result).to be_a(Array)
        expect(result.size).to eq(1)
        expect(result.first).to be_a(VkMusic::Audio)
        expect(result.first.artist).to eq('sektorjazza')
        expect(result.first.title).to eq('супертрек из брата 2 forever young сергей бодров 1997-2002 r.i.p.')
        expect(result.first.duration).to eq(253)
        expect(result.first).to be_url_accessable
      end
    end

    context 'when reply' do
      let(:url) { 'https://vk.com/wall-39786657_399073' }

      it 'returnes audios from post', :aggregate_failures do
        expect(result).to be_a(Array)
        expect(result.size).to eq(1)
        expect(result.first).to be_a(VkMusic::Audio)
        expect(result.first.artist).to eq('sektorjazza')
        expect(result.first.title).to eq('супертрек из брата 2 forever young сергей бодров 1997-2002 r.i.p.')
        expect(result.first.duration).to eq(253)
        expect(result.first).to be_url_accessable
      end
    end

    context 'when not wall' do
      let(:url) { 'https://vk.com/feed' }

      it :aggregate_failures do
        expect(result).to be_empty
      end
    end

    context 'when 404' do
      let(:url) { 'https://vk.com/a' }

      it :aggregate_failures do
        expect(result).to be_empty
      end
    end

    context 'when playlist attached' do
      let(:url) { 'https://vk.com/wall-39786657_398918' }

      it :aggregate_failures do
        expect(result).to be_empty
      end
    end

    context 'when repost' do
      let(:url) { 'https://vk.com/wall-39786657_399552' }

      it :aggregate_failures do
        expect(result).to be_empty
      end
    end
  end

  describe '#artist' do
    let(:url) { '' }
    let(:result) { instance.artist(url: url) }

    context 'when artist page' do
      let(:url) { 'https://vk.com/artist/komsomolsk' }

      it { expect(result).not_to be_empty }
    end

    context 'when with ref' do
      let(:url) { 'https://vk.com/artist/poroxerdtsa?ref=artist_related' }

      it { expect(result).not_to be_empty }
    end

    context 'when feed' do
      let(:url) { 'https://vk.com/feed' }

      it { expect(result).to be_empty }
    end

    context 'when artist do not exist' do
      let(:url) { 'https://vk.com/artist/1' }

      it { expect(result).to be_empty }
    end

    context 'when gibberish' do
      let(:url) { 'asfasfafa' }

      it { expect(result).to be_empty }
    end
  end

  describe '#get_urls' do
    let(:audios) { [] }
    let(:result) { instance.get_urls(audios) }

    it { expect(result).to be_empty }

    context 'when from find' do
      let(:audios) { instance.find('test', type: :audio) }

      it :aggregate_failures do
        expect(result).to be_a(Array)
        expect(result.size).to eq(6)
        expect(result).to all(be_a(VkMusic::Audio))
        expect(result).to all(be_url_available)
      end
    end

    context 'when from playlist' do
      let(:url) { 'https://vk.com/music/playlist/19198851_39318804_6c2b34085c37213dfb' }
      let(:audios) { instance.playlist(url: url).audios }

      it :aggregate_failures do
        expect(result).to be_a(Array)
        expect(result.size).to eq(6)
        expect(result).to all(be_a(VkMusic::Audio))
        expect(result).to all(be_url_available)
      end

      context 'playlist with unavailable audios and array of strings is provided' do
        let(:url) { 'https://vk.com/music/playlist/-33507639_58254888_0d3aabf63b6a016fc2' }
        let(:audios) { instance.playlist(url: url).audios.map(&:full_id) }

        it :aggregate_failures do
          expect(result).to be_a(Array)
          expect(result.size).to eq(15)
          expect(result).to include(nil)
          expect(result.compact.size).to eq(13)
        end
      end
    end

    context 'when from audios' do
      let(:audios) { instance.audios(url: 'vk.com/id8024985', up_to: 50).audios }

      it :aggregate_failures do
        expect(result).to be_a(Array)
        expect(result.size).to eq(50)
        expect(result).to all(be_a(VkMusic::Audio))
        expect(result).to all(be_url_available)
      end
    end

    context 'when from wall' do
      let(:audios) { instance.wall(url: 'https://vk.com/mashup').audios.first(10) }

      it :aggregate_failures do
        expect(result).to be_a(Array)
        expect(result.size).to eq(10)
        expect(result).to all(be_a(VkMusic::Audio))
        expect(result).to all(be_url_available)
      end
    end

    context 'when from post' do
      let(:audios) { instance.post(url: 'https://vk.com/wall-39786657_399071') }

      it :aggregate_failures do
        expect(result).to be_a(Array)
        expect(result.size).to eq(1)
        expect(result.first).to be_a(VkMusic::Audio)
        expect(result.first).to be_url_available
      end
    end

    context 'when only unavailable audios' do
      let(:url) { 'https://vk.com/music/playlist/-33507639_58254888_0d3aabf63b6a016fc2' }
      let(:audios) { instance.playlist(url: url).audios.reject(&:url_accessable?) }

      it :aggregate_failures do
        expect(result).to be_a(Array)
        expect(result.size).to eq(2)
        expect(result.first).not_to be_url_available
        expect(result.last).not_to be_url_available
      end
    end
  end

  describe '#update_urls' do
    let(:audios) { [] }
    let(:call) { instance.update_urls(audios) }

    context 'when from find' do
      let(:audios) { instance.audios(url: 'vk.com/id8024985', up_to: 50).audios }

      it :aggregate_failures do
        call
        expect(audios).to be_a(Array)
        expect(audios.size).to eq(50)
        expect(audios).to all(be_a(VkMusic::Audio))
        expect(audios).to all(be_url_accessable)
      end
    end
  end
end
