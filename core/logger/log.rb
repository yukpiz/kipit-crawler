require "logger"

class Log
  @@log_path = "log/kipit.log"
  @@log_rotation = 7
  @logger = nil

  def initialize(log_path = nil, log_rotation = nil)
    @@log_path = log_path ? log_path : @@log_path
    @@log_rotation = log_rotation ? log_rotation : @@log_rotation
    @logger = Logger.new(@@log_path, @@log_rotation)
  end

  def error(msg)
    puts msg
    @logger.error(msg)
  end

  def debug(msg)
    puts msg
    @logger.debug(msg)
  end

  def fatal(msg)
    puts msg
    @logger.fatal(msg)
  end

  def info(msg)
    puts msg
    @logger.info(msg)
  end
end
