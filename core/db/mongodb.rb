require "mongo"
require "./core/logger/log.rb"
require "./core/config/config.rb"

class MongoDb
  @log = nil
  @client = nil

  def initialize
    @log = Log.new
    conf = Config.load
    host = conf["db"]["host"]
    db = conf["db"]["database"]
    @client = Mongo::Client.new([host], :database => db)
  end

  def collect_entries(entries)
    @counter = 0
    entries.each do |entry|
      collect_entry(entry)
    end

    @log.info("#{@counter}件の記事が追加されました(=w=)b") if @counter > 0
  end

  def collect_entry(entry)
    collection = @client[:trade_entry]
    if collection.find(trade_id: entry["trade_id"]).first.nil?
      entry["checked"] = false
      collection.insert_one(entry)
      @counter += 1
    end
  end
end
