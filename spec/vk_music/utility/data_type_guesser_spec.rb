# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Utility::DataTypeGuesser do
  let(:result) { described_class.call(data) }
  let(:data) { '' }

  context 'when playlist' do
    context 'when long link' do
      let(:data) { 'https://vk.com/music/playlist/19198851_39318804_6c2b34085c37213dfb' }

      it { expect(result).to eq(:playlist) }
    end

    context 'when short link' do
      let(:data) { 'https://vk.com/music/playlist/-37661843_1' }

      it { expect(result).to eq(:playlist) }
    end

    context 'when album' do
      let(:data) { 'https://vk.com/music/album/-2000637322_637322_e677ea2eab62dc17a8' }

      it { expect(result).to eq(:playlist) }
    end

    context 'when modal' do
      let(:data) { 'https://vk.com/audios1111?z=audio_playlist121570739_7' }

      it { expect(result).to eq(:playlist) }
    end

    context 'when long mobile' do
      let(:data) { 'https://m.vk.com/audio?act=audio_playlist121570739_7&from=a&back_url=%2Faudios1&back_hash=a&ref=a' }

      it { expect(result).to eq(:playlist) }
    end
  end

  context 'when post' do
    context 'when direct link' do
      let(:data) { 'https://vk.com/wall-39786657_402054' }

      it { expect(result).to eq(:post) }
    end

    context 'when modal' do
      let(:data) { 'https://vk.com/mashup?w=wall-39786657_402054' }

      it { expect(result).to eq(:post) }
    end

    context 'when mobile' do
      let(:data) { 'https://m.vk.com/wall-39786657_402408' }

      it { expect(result).to eq(:post) }
    end
  end

  context 'when wall' do
    context 'when direct link' do
      let(:data) { 'https://vk.com/wall-39786657' }

      it { expect(result).to eq(:wall) }
    end

    context 'when with params' do
      let(:data) { 'https://vk.com/wall-39786657?offset=22920&own=1' }

      it { expect(result).to eq(:wall) }
    end

    context 'when mobile' do
      let(:data) { 'https://m.vk.com/wall-39786657' }

      it { expect(result).to eq(:wall) }
    end
  end

  context 'when audios' do
    context 'when direct link' do
      let(:data) { 'https://vk.com/audios-39786657' }

      it { expect(result).to eq(:audios) }
    end

    context 'when with params' do
      let(:data) { 'https://vk.com/audios-39786657?section=all' }

      it { expect(result).to eq(:audios) }
    end

    context 'when mobile' do
      let(:data) { 'https://m.vk.com/audios-39786657' }

      it { expect(result).to eq(:audios) }
    end
  end

  context 'when profile' do
    context 'when user' do
      let(:data) { 'https://vk.com/id1' }

      it { expect(result).to eq(:audios) }
    end

    context 'when club' do
      let(:data) { 'https://vk.com/club88005553535' }

      it { expect(result).to eq(:audios) }
    end

    context 'when custom url' do
      let(:data) { 'https://vk.com/mashup' }

      it { expect(result).to eq(:audios) }
    end

    context 'when with params' do
      let(:data) { 'https://vk.com/id1?section=all' }

      it { expect(result).to eq(:audios) }
    end

    context 'when mobile' do
      let(:data) { 'https://m.vk.com/id1' }

      it { expect(result).to eq(:audios) }
    end

    context 'when feed' do
      let(:data) { 'https://m.vk.com/feed' }

      it { expect(result).to eq(:audios) }
    end
  end

  context 'when search' do
    context 'when text' do
      let(:data) { 'text' }

      it { expect(result).to eq(:find) }
    end

    context 'when empty' do
      let(:data) { '' }

      it { expect(result).to eq(:find) }
    end
  end
end
