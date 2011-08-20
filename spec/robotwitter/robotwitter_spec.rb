require "spec_helper"

describe "Robotwitter" do

  before do
    FakeWeb.register_uri(:get, %r|https://api\.twitter\.com/1/followers/ids\.json|,
                         :body => %|{"ids": [1,2,3]}|)
    # GET https://api.twitter.com/1/friends/ids.json
    FakeWeb.register_uri(:get, %r|https://api\.twitter\.com/1/friends/ids\.json|,
                         :body => %|{"ids": [1,2,3]}|)
    # POST https://api.twitter.com/1/statuses/update.json
    FakeWeb.register_uri(:post, %r|https://api\.twitter\.com/1/statuses/update\.json|,
                         :body => '')
    # POST https://api.twitter.com/1/statuses/retweet/
    FakeWeb.register_uri(:post, %r|https://api\.twitter\.com/1/statuses/retweet|,
                         :body => '')
  end

  POSTER = lambda do |l|
    'some tweet'
  end

  before(:each) do
    @settings_path = File.expand_path('../../../example', __FILE__)
    @client = Robotwitter::Robot.new @settings_path, 'test_login', &POSTER
  end

  it "should create new object on right init params" do
    @client.class.to_s.should eq("Robotwitter::Robot")
  end

  it "should follows those who follows me" do
    @client.follow_all_back
  end

  it "should tweet a message" do
    @client.send_message('_msg_ #hash')
  end

  it "should retweet about word" do
    @client.retweet_about('something')
  end

  it "should follow users tweets about" do
    @client.follow_users_tweets_about('something')
  end

  it "should unfollow users who did not following me" do
    @client.unfollow_users
  end

  it "should not tweet if phrase is empty" do
    EMPTY = lambda do
      ""
    end

    client = Robotwitter::Robot.new @settings_path, 'test_login', &EMPTY
    client.send_message('_msg_ #hash')
  end
end