require "spec_helper"

describe "Robotwitter" do

  context "with nil POSTER" do

    POSTER = nil

    before(:each) do
      settings_path = File.expand_path('../../../example', __FILE__)
      Robotwitter::Path.base = settings_path
      @client = Robotwitter::Robot.new 'test_login', &POSTER
    end

    it "should create new object on right init params" do
      @client.class.to_s.should eq("Robotwitter::Robot")
    end

    it "should follows those who follows me" do
      pending "get the mock for twitter" do
        @client.follow_all_back
          a_request(:get, "https://search.twitter.com/search.json").
            with(:query => {:q => "twitter"}).
            should have_been_made
      end
    end

    it "should tweet a message" do
       pending("get the mock for twitter")
    end

    it "should retweet about word" do

    end

    it "should follow users tweets about" do

    end

    it "should unfollow users who did not following me" do

    end
  end


end