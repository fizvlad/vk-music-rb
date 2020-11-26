# frozen_string_literal: true

module VkMusic
  module WebParser
    # Login page parser
    class Login < Base
      # @return [Mechanize::Form]
      def login_form
        node.forms.find { |f| f.action.start_with?('https://login.vk.com') }
      end
    end
  end
end
