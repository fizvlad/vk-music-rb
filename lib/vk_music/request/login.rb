# frozen_string_literal: true

module VkMusic
  module Request
    # Logging in request
    class Login < Base
      # Initialize new request
      def initialize
        super("#{VK_ROOT}/login", {}, 'GET', {})
        @success = false
      end

      # @return [Boolean]
      def success?
        !!@success
      end

      # Send login form
      def send_form(login, password, agent)
        form = @response.forms.find { |f| f.action.start_with?('https://login.vk.com') }
        form['email'] = login
        form['pass'] = password
        page = agent.submit(form)

        @success = (page.uri.to_s == 'https://m.vk.com/feed')
      end
    end
  end
end
