require "./core/twitter/twitter.rb"
require "./core/logger/log.rb"

threads = []
#Twitter refollow observer thread
threads.push(Thread.new do
  twitter = TwitterClient.new
  while (true)
    sleep 60
    follows = twitter.refollow
    follows.each do |follow|
      sleep 10
      reply_text = <<"EOS"
@#{follow.screen_name}
はじめましてっ！
ムーニャと言います(๑•̀ㅂ•́)و✧
helpでリプライすると使い方がわかるよっ(•ө•)♡
EOS
      twitter.send_text(reply_text)
      sleep 10
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
