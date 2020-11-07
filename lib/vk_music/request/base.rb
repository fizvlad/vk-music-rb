# frozen_string_literal: true

module VkMusic
  module Request
    # Base class for most of requests
    class Base
      # @return [String]
      attr_reader :path
      # @return [Hash]
      attr_reader :data
      # @return [String]
      attr_reader :method
      # @return [Hash]
      attr_reader :headers
      # @return [Mechanize::File?]
      attr_reader :response

      # Initialize new request
      # @param path [String]
      # @param data [Hash]
      # @param method [String]
      # @param headers [Hash]
      def initialize(path, data = {}, method = 'GET', headers = {})
        @path = path
        @data = data
        @method = method.upcase
        @headers = headers

        @response = nil
      end

      # @param agent [Mechanize]
      # @return [Mechanize::Page]
      def call(agent)
        @response = case method
        when 'GET' then get(agent)
        when 'POST' then post(agent)
        else raise(ArgumentError, "unsupported method #{method}")
        end
      end

      private

      def get(agent)
        uri = URI(path)
        uri.query = URI.encode_www_form(data)
        agent.get(uri, [], nil, headers)
      end

      def post(agent)
        uri = URI(path)
        agent.post(uri, data, headers)
      end
    end
  end
end
