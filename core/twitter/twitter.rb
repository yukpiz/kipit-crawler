require "twitter"
require "tweetstream"
require "./core/config/config.rb"

class TwitterClient
  attr_accessor :stream

  @client = nil
  @stream = nil
  @conf = nil
  def initialize
    @conf = Config.load
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV[@conf['twitter']['consumer_key']]
      config.consumer_secret = ENV[@conf['twitter']['consumer_secret']]
      config.access_token = ENV[@conf['twitter']['access_token']]
      config.access_token_secret = ENV[@conf['twitter']['access_token_secret']]
    end

    TweetStream.configure do |config|
      config.consumer_key = ENV[@conf['twitter']['consumer_key']]
      config.consumer_secret = ENV[@conf['twitter']['consumer_secret']]
      config.oauth_token = ENV[@conf['twitter']['access_token']]
      config.oauth_token_secret = ENV[@conf['twitter']['access_token_secret']]
      config.auth_method = :oauth
    end
    @stream = TweetStream::Client.new
  end

  def get_follower_ids
    @client.follower_ids(@conf['twitter']['screen_name']).to_a
  end

  def get_follow_ids
    @client.follow_ids(@conf['twitter']['screen_name']).to_a
  end

  def refollow
    follower_ids = get_follower_ids
    @client.follow(follower_ids)
  end

  def send_text(text)
    @client.update(text)
  end
end
