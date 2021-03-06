# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Request::Login, :vcr do
  let(:agent) { Mechanize.new }
  let(:login) { '' }
  let(:password) { '' }
  let(:instance) { described_class.new }
  let(:result) do
    instance.call(agent)
    instance.send_form(login, password, agent)
    instance.success?
  end

  it { expect(result).to be(false) }

  context 'with correct login and password' do
    let(:login) { ENV['VK_LOGIN'] }
    let(:password) { ENV['VK_PASSWORD'] }

    it { expect(result).to be(true) }
  end
end
