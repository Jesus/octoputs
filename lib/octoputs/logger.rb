require 'singleton'

class Logger
  include Singleton

  def self.log(*args)
    instance.log(*args)
  end

  def log(event, details = nil)
    puts "%12s | %-16s%s" % [
      Time.now.strftime("%H:%M %S.%L"),
      event,
      details ? " | #{details}" : ""
    ]
  end
end
