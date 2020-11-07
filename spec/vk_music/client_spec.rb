# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Client do
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
end
