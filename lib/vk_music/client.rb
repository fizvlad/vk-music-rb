module VkMusic

  class Client
  
    # TODO: Must store user id and cookies, but NOT log/pass
  
    def initialize(options)
      # Arguments check
      raise ArgumentError, "Username is not provided", caller unless options.has_key?(:username)
      raise ArgumentError, "Password is not provided", caller unless options.has_key?(:password)
      
      # TODO
    end
    
    def find_audio(query)
      # TODO
    end
    
    def get_playlist(url)
      # TODO
    end
    
    private
    def login
      # TODO
    end
    
    def unmask_link(link)
      # TODO
    end
  
  end
  
end