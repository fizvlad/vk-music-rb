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
  end
end
