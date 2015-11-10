require "guard/cucumber/runner"

RSpec.describe Guard::Cucumber::Runner do
  let(:runner) { Guard::Cucumber::Runner }
  let(:null_device) { RUBY_PLATFORM.index("mswin") ? "NUL" : "/dev/null" }

  before do
    allow(Guard::Compat::UI).to receive(:info)
    allow(runner).to receive(:system)
  end

  describe "#run" do
    context "when passed an empty paths list" do
      it "returns false" do
        expect(runner.run([])).to be_falsey
      end
    end

    context "with a paths argument" do
      it "runs the given paths" do
        expect(runner).to receive(:system).with(
          /features\/foo\.feature features\/bar\.feature$/
        )
        runner.run(["features/foo.feature", "features/bar.feature"])
      end
    end

    context "with a :feature_sets option" do
      it "requires each feature set" do
        feature_sets = ["feature_set_a", "feature_set_b"]

        expect(runner).to receive(:system).with(
          /--require feature_set_a --require feature_set_b/
        )
        runner.run(feature_sets, feature_sets: feature_sets)
      end
    end

    it "runs cucumber according to passed cmd option" do
      req = @lib_path.join("guard/cucumber/notification_formatter.rb")
      expect(runner).to receive(:system).with(
                          "xvfb-run bundle exec cucumber "\
                          "--require #{ req } "\
                          "--format Guard::Cucumber::NotificationFormatter "\
                          "--out #{ null_device } "\
                          "--require features features"
          )
      runner.run(["features"], cmd: "xvfb-run bundle exec cucumber")
    end
    
    context "with a :focus_on option" do
      it "passes the value in :focus_on to the Focuser" do
        paths = ["features"]
        focus_on_hash = {
          focus_on: "@focus"
        }

        expect(Guard::Cucumber::Focuser).to receive(:focus).with(
          paths, focus_on_hash[:focus_on]
        ).and_return(paths)

        runner.run(paths, focus_on_hash)
      end
    end

    context "with a :cmd_additional_args option" do
      it "appends the cli arguments when calling cucumber" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")
        expect(runner).to receive(:system).with(
          "cucumber --require #{req} "\
          "--format Guard::Cucumber::NotificationFormatter "\
          "--out #{ null_device } --require features "\
          "--custom command "\
          "features")
        runner.run(["features"], cmd_additional_args: "--custom command")
      end
    end

    context "with a :notification option" do
      it "does not add the guard notification listener" do
        expect(runner).to receive(:system).with(
          "cucumber features"
        )
        runner.run(["features"], notification: false)
      end
    end
  end
end
