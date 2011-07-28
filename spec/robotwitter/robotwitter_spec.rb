require "spec_helper"

describe "Robotwitter" do

  before do
    FakeWeb.register_uri(:get, %r|https://api\.twitter\.com/1/followers/ids\.json|,
                         :body => %|{"ids": [1,2,3]}|)
    # GET https://api.twitter.com/1/friends/ids.json
    FakeWeb.register_uri(:get, %r|https://api\.twitter\.com/1/friends/ids\.json|,
                         :body => %|{"ids": [1,2,3]}|)
  end

  context "with nil POSTER" do

    POSTER = nil

    before(:each) do
      settings_path = File.expand_path('../../../example', __FILE__)
      @client = Robotwitter::Robot.new settings_path, 'test_login', &POSTER
    end

    it "should create new object on right init params" do
      @client.class.to_s.should eq("Robotwitter::Robot")
    end

    it "should follows those who follows me" do
      @client.follow_all_back
    end

    it "should tweet a message"

    it "should retweet about word"

    it "should follow users tweets about"

    it "should unfollow users who did not following me"
  end

end