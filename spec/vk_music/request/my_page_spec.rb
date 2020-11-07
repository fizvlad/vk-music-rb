# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Request::MyPage do
  let(:agent) { logged_in_agent }
  let(:instance) { described_class.new }

  it :aggregate_failures do
    instance.call(agent)

    expect(instance.id).to be_a(Integer)
    expect(instance.name).to be_a(String)
  end
end
