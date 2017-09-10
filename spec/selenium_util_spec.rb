require "spec_helper"

RSpec.describe SeleniumUtil do
  it "has a version number" do
    expect(SeleniumUtil::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
