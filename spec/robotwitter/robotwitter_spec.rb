require "spec_helper"

describe "Robotwitter" do

  it "should creates new object on right init params" do
    POSTER = nil
    settings_path = File.expand_path('../../../example', __FILE__)
    client = Robotwitter::Robot.new "#{settings_path}/settings.yaml", 'test_login', &POSTER
    client.class.to_s.should == "Robotwitter::Robot"
  end

end