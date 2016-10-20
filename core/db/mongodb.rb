require "mongo"
require "./core/config/config.rb"

class MongoDb
  @client = nil

  def initialize
    conf = Config.load
    host = conf["db"]["host"]
    db = conf["db"]["database"]
    @client = Mongo::Client.new([host], :database => db)
  end

  def collect_entries(entries)
    entries.each do |entry|
      collect_entry(entry)
    end
  end

  def collect_entry(entry)
    collection = @client[:trade_entry]
    if collection.find(trade_id: entry["trade_id"]).first.nil?
      entry["checked"] = false
      collection.insert_one(entry)
    end
  end
end
