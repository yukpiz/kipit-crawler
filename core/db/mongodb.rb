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

  def collect_entry(entry)
    collection = @client[:trade_entry]
    if collection.find(trade_id: entry["trade_id"]).limit(1).first.nil?
      entry["checked"] = false
      collection.insert_one(entry)
      return true
    end
    return false
  end
end
