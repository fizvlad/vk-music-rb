module VkMusic
  ##
  # @!group Logger

  ##
  # Default logger
  @@logger = Logger.new($LOG_FILE || STDOUT,
    formatter: Proc.new do |severity, datetime, progname, msg|
      "[#{datetime}] #{severity}#{progname ? " - #{progname}" : ""}:\t #{msg}\n"
    end
  )
  @@logger.level = $DEBUG ? Logger::DEBUG : Logger::INFO

  ##
  # Setup new logger.
  # @param new_logger [Logger, nil]
  def self.logger=(new_logger)
    @@logger = new_logger
  end
  ##
  # Access current logger.
  # @return [Logger, nil]
  def self.logger
    @@logger
  end

  ##
  # Log message.
  def self.log(severity, message = nil, progname = nil)
    @@logger.log(severity, message, progname) if @@logger
  end

  ##
  # Log warn message.
  def self.warn(message = nil, progname = nil)
    @@logger.log(Logger::WARN, message, progname)
  end
  ##
  # Log info message.
  def self.info(message = nil, progname = nil)
    @@logger.log(Logger::INFO, message, progname)
  end
  ##
  # Log debug message.
  def self.debug(message = nil, progname = nil)
    @@logger.log(Logger::DEBUG, message, progname)
  end

  ##
  # @!endgroup
end
