require "./core/twitter/twitter.rb"
require "./core/logger/log.rb"
require "./core/config/config.rb"

threads = []
#Initialize logger
log = Log.new
#Initialize configuration
conf = Config.load
#Initialize Twitter client
twitter = TwitterClient.new

#Twitter refollow observer thread
threads.push(Thread.new do
  while (true)
    sleep 60
    new_follows = twitter.refollow
    next if new_follows.empty?

    reply_text_template = conf['twitter']['texts']['refollow_text']
    new_follows.each do |new_follow|
      log.info("#{new_follow.screen_name} 新しいユーザーをフォローしました。")
      reply_text = "@#{new_follow.screen_name} #{reply_text_template}"
      twitter.send_text(reply_text)
    end
  end
end)

#Twitter reply ebserver thread
threads.push(Thread.new do
  twitter.stream.userstream do |status|
    next if not status.text =~ /^@#{conf['twitter']['screen_name']}\s*/
    if status.text =~ /\+.\s*/
      puts status.text.match(/\+ (.+)/)
    end
  end
end)

begin
  threads.each do |t|
    t.join
  end
rescue Interrupt
  log.info "Process was interrupted! Bye (=w=)ﾉ"
end
