require "thread"
require "./core/config/config.rb"
require "./core/logger/log.rb"
require "./core/http/http.rb"
require "./core/parser/parser.rb"
require "./core/db/mongodb.rb"

#Initialize Queues
crawler_queue = Queue.new
observer_queue = Queue.new

threads = []
#Initialize configurations
conf = Config.load
#Initialize logger
log = Log.new
#Initialize mongodb driver
mongodb = MongoDb.new

#Crawler thread
threads.push(Thread.new do
  #Initialize variables
  url = "#{conf['http']['base_url']}#{conf['http']['trade_url']}#{conf['http']['target_server']}"
  cache_ids = []

  while (true)
    sleep 10
    cached_count = 0

    #Get the html
    html = Http.get(url)

    #Parse html document and get the entries
    parser = Parser.new(html)
    entries = parser.get_entries

    #Check caches and save queue
    entries.each do |entry|
      next if cache_ids.include?(entry["trade_id"])
      #Push queue
      crawler_queue.push entry
      #Save cache
      cache_ids.push entry["trade_id"]
      cached_count += 1
    end

    cache_ids.sort!
    cache_ids.delete_at(0) if cache_ids.count > 20
    log.info "#{cached_count}件の記事をキューに格納しました！" if cached_count > 0
  end
end)

#Writer thread
Thread.new do
  while (true)
    sleep 1
    entry = crawler_queue.pop
    log.info entry
    if mongodb.collect_entry(entry)
      log.info "記事をストレージへ保存しました！"
      observer_queue.push entry
    end
  end
end

#Entry observer thread
Thread.new do
  while (true)
    sleep 1
    entry = observer_queue.pop
    log.info "Observerが検知しました"
    #キーワード検索
  end
end

#Twitter observer thread
Thread.new do
end

begin
  threads.each do |t|
    t.join
  end
rescue Interrupt
  log.info "Process was interrupted! Bye (=w=)ﾉ"
end