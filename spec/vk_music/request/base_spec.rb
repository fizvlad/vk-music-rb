# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VkMusic::Request::Base do
  let(:agent) { Mechanize.new }
  let(:url) { "https://postman-echo.com/#{path}" }
  let(:path) { '' }
  let(:data) { {} }
  let(:method) { 'GET' }
  let(:headers) { {} }
  let(:request) { described_class.new(url, data, method, headers) }
  let(:result) { request.call(agent) }
  let(:parsed_result) { JSON.parse(result.body) }

  context 'GET request' do
    let(:path) { 'get' }
    let(:method) { 'GET' }
    let(:data) { { getarg1: 'getval1', getarg2: nil, getarg3: '' } }
    let(:headers) { { 'x-requested-with' => 'XMLHttpRequest' } }

    it :aggregate_failures do
      expect(result).to be_a(Mechanize::File)
      expect(parsed_result['args']).to eq({ 'getarg1' => 'getval1', 'getarg2' => '', 'getarg3' => '' })
      expect(parsed_result['headers']).to include({ 'x-requested-with' => 'XMLHttpRequest' })
    end
  end

  context 'POST request' do
    let(:path) { 'post' }
    let(:method) { 'POST' }
    let(:data) { { postarg1: 'postval1', postarg2: nil, postarg3: '', postarr: [1, 2, 3] } }
    let(:headers) { { 'x-requested-with' => 'XMLHttpRequest' } }

    it do
      expect(result).to be_a(Mechanize::File)
      expect(parsed_result['form']).to eq({
        'postarg1' => 'postval1',
        'postarg2' => '',
        'postarg3' => '',
        'postarr' => %w[1 2 3]
      })
      expect(parsed_result['headers']).to include({ 'x-requested-with' => 'XMLHttpRequest' })
    end
  end
end