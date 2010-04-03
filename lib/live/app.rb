require 'yaml'

module Live

  #
  def self.start(config)
    configure(config)
    Live::Server.run!
  end

  #
  def self.configure(config)
    require 'live/db'

    environment = ENV['LIVE_ENV'] || 'development'

    case config
    when File
      dbconfig = YAML.load(config)[environment]
    when String
      dbconfig = YAML.load(File.new(config))[environment]
    when Hash
      dbconfig = config
    else
      raise "Invalid configuration."
    end

    dbconfig['username'] ||= ENV['LIVE_USERNAME']
    dbconfig['password'] ||= ENV['LIVE_PASSWORD']

    connect_database(dbconfig)

    require 'live/models'
    require 'live/server'
  end

end

