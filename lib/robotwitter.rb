require 'rubygems'
require 'twitter'
require 'twitter/error/unauthorized'
require 'open-uri'
require 'yaml'
require 'sqlite3'
require 'logger'

require 'robotwitter/db'
require 'robotwitter/version'

module Robotwitter
  class Robot
    attr_reader :path

    # getter should be a lambda - function
    # which returns string
    # example of getter
    #
    #  SQLITE_GETTER = lambda do
    #    db = SQLite3::Database.new("database.db")
    #    db.get_first_row( "select * from table" )
    #  end
    def initialize(path, section, &getter)
      @getter, @path, @followers_ids, @following_ids = getter, path, nil, nil

      @logger = Logger.new('tweelog.txt', 'weekly')


      path ||= ''
      path += '/' if path != ''

      yml = YAML.load_file(path + "settings.yml")
      Twitter.configure do |config|
        config.consumer_key       = yml[section]['consumer_key']
        config.consumer_secret    = yml[section]['consumer_secret']
        config.oauth_token        = yml[section]['oauth_token']
        config.oauth_token_secret = yml[section]['oauth_token_secret']
      end
      @client = Twitter::Client.new
      @search_client = Twitter
    end

    # follow who follows me
    def follow_all_back
      follow_them = get_followers_ids - get_following_ids
      follow_them.each do |id|
        @client.follow(id)
        @logger.info 'following' + id.to_s
      end
    end

    # string '_msg_ somth'
    def send_message(pattern)
      phrase = get_phrase
      return if phrase == ''
      send = pattern.gsub('_msg_', phrase)
      @client.update(send)
      @logger.info(send)
    end

    def retweet_about(word)
      search = search_users_tweets_about(word, 2)
      init_db
      search.each do |result|
        next if @db.retweeted?(result)
        retweet(result)
        @db.save_retweet(result)
        @logger.info(result['id'])
      end
    end

    # follow who tweet about word
    def follow_users_tweets_about(word)
      users = search_users_tweets_about(word)

      get_followers_ids
      get_following_ids
      @logger.info(users)
      users.each do |user|
        id = user['from_user_id']
        name = user['from_user']
        if (not @followers_ids.include?(id)) and (not @following_ids.include?(id))
          @client.follow(name)
          @logger.info(name)
        end
      end
    end

    #unfollow who not following me
    def unfollow_users
      unfollow_them = get_following_ids - get_followers_ids
      unfollow_them.each do |id|
        @client.unfollow(id)
        @logger.info(id)
      end
    end

    protected

    def init_db
      @db ||= Robotwitter::Db.new('tweets', @path)
    end

    # get phrase from internal resource
    def get_phrase
      @getter.call(self)
    rescue
      ""
    end

    # search for users tweets about
    def search_users_tweets_about(word, count = 5)
      @search_client.search(word, :locale => 'ru', :result_type => 'resent', :rpp => count)
    end

    # get follower ids
    def get_followers_ids
      if @followers_ids.nil?
        @followers_ids = @client.follower_ids['ids']
      end
      @followers_ids
    end

    # get following ids
    def get_following_ids
      if @following_ids.nil?
        @following_ids = @client.friend_ids['ids']
      end
      @following_ids
    end

    # retweet
    # result - hash от поиска
    def retweet(result)
      @client.retweet(result['id'])
    rescue => detail
      @logger.error(detail)
    end

    def rate_limit
      @logger.error(@client.rate_limit_status.remaining_hits.to_s + ' Twitter API request(s) remaining this hour')
    end
  end
end