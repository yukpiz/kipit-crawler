require "./core/config/config.rb"
require "./core/logger/log.rb"
require "./core/http/http.rb"
require "./core/parser/parser.rb"
require "./core/db/mongodb.rb"

class Crawler
  @conf = nil
  @log = nil

  @html = nil
  @entries = nil
  def self.start
    begin
      @conf = Config.load
      @log = Log.new
      while (true)
        sleep 5
        self.get() #Get Trade Lists
        self.parse() #Parse By HTML
        self.collect() #Collection The Entries
      end
    rescue Interrupt
      puts "Processing was interrupted! Bye(=w=)"
    end
  end

  def self.get
    url = "#{@conf['http']['base_url']}#{@conf['http']['trade_url']}#{@conf['http']['target_server']}"
    @html = Http.get(url)
  end

  def self.parse
    parser = Parser.new(@html)
    @entries = parser.get_entries
  end

  def self.collect
    mongodb = MongoDb.new()
    mongodb.collect_entries(@entries)
  end
end
