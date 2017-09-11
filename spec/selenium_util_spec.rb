require "spec_helper"

RSpec.describe SeleniumUtil do
  it "has a version number" do
    expect(SeleniumUtil::VERSION).not_to be nil
  end

  it "initialize" do
    u = SeleniumUtil::Browser.new :chrome
    expect(u.class).to eq(SeleniumUtil::Browser)
    u.quit
  end
end
