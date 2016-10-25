require "twitter"
require "./core/config/config.rb"

class TwitterClient
  @client = nil
  @conf = nil
  def initialize
    @conf = Config.load
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV[@conf['twitter']['consumer_key']]
      config.consumer_secret = ENV[@conf['twitter']['consumer_secret']]
      config.access_token = ENV[@conf['twitter']['access_token']]
      config.access_token_secret = ENV[@conf['twitter']['access_token_secret']]
    end
  end

  def get_followers
    @client.followers(@conf['twitter']['screen_name'])
  end

  def get_follows
    @client.friends(@conf['twitter']['screen_name'])
  end

  def refollow
    followers = get_followers
    follows = []
    followers.each do |follower|
      follow = @client.follow(follower.id)
      follows.push(follow.shift) if follow.count > 0
    end
    return follows
  end

  def send_text(text)
    @client.update(text)
  end
end
