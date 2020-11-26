# frozen_string_literal: true

module VkMusic
  module Request
    # Base class for most of requests
    class Base
      extend Forwardable

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
      # @return [self]
      def call(agent)
        before_call

        log
        @response = case method
        when 'GET' then get(agent)
        when 'POST' then post(agent)
        else raise(ArgumentError, "unsupported method #{method}")
        end

        after_call

        self
      end

      private

      def log
        VkMusic.log.debug('request') do
          "#{method} to '#{path}', with data: #{data}, headers: #{headers}"
        end
      end

      def get(agent)
        uri = URI(path)
        uri.query = URI.encode_www_form(data)
        agent.get(uri, [], nil, headers)
      end

      def post(agent)
        uri = URI(path)
        agent.post(uri, data, headers)
      end

      def before_call; end

      def after_call; end
    end
  end
end
