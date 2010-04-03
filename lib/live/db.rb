require 'sequel'
#require 'facets/hash/rekey'

module Live

  #
  def self.connect_database(options={})
    options = options.inject({}){ |h,(k,v)| h[k.to_sym] = v; h }
    
    adapter   = options[:adapter] || 'mysql'
    dbname    = options[:database]
    host      = options[:host] || 'localhost'
    username  = options[:username] || ENV['LIVE_USERNAME']
    password  = options[:password] || ENV['LIVE_PASSWORD']

    $database = Sequel.connect(:adapter=>adapter, :host=>host, :database=>dbname, :user=>username, :password=>password)
  end

  #
  def database
    $database
  end

end

