RSpec.describe Guard::CucumberVersion do
  describe "VERSION" do
    it "defines the version" do
      expect(Guard::CucumberVersion::VERSION).to match /\d+.\d+.\d+/
    end
  end
end
