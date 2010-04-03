require 'open-uri'

module Live
  # TODO: Use XDG directory standard
  CACHE = ENV['LIVE_CACHE'] || File.expand_path('~/.config/live')
  URI   = "http://facetslive.org/require/"
end

module Kernel

  def live(path)
    local = File.join(Live::CACHE, path)
    if File.exist?(local)
      require(local)
    else
      File.open(local, 'wb') do |f|
        f << open_uri(File.join(Live::URI, path)).read
      end
      require(local)
    end
  end

end

