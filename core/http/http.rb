require "net/http"

class Http
  def self.get(url)
    return Net::HTTP.get(URI.parse(url))
  end
end
