require "spec_helper"

describe "Robotwitter" do

  context "with nil POSTER" do

    POSTER = nil

    before(:each) do
      settings_path = File.expand_path('../../../example', __FILE__)
      @client = Robotwitter::Robot.new "#{settings_path}/settings.yaml", 'test_login', &POSTER
    end

    it "should creates new object on right init params" do
      @client.class.to_s.should eq("Robotwitter::Robot")
    end

    it "should follows those who follows me" do

    end

    it "should tweet a message" do

    end

    it "should retweet about word" do

    end

    it "should follow users tweets about" do

    end

    it "should unfollow users who did not following me" do

    end
  end


end