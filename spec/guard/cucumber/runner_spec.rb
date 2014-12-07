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

    context "with a :rvm option" do
      it "executes cucumber through the rvm versions" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")
        expect(runner).to receive(:system).with(
          "rvm 1.8.7,1.9.2 exec bundle exec cucumber"\
          " --require #{ req }"\
          " --format Guard::Cucumber::NotificationFormatter"\
          " --out #{ null_device }"\
          " --require features features"
        )
        runner.run(["features"], rvm: ["1.8.7", "1.9.2"])
      end
    end

    context "with a :command_prefix option" do
      it "executes cucumber with the command_prefix option" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")
        expect(runner).to receive(:system).with(
          "xvfb-run bundle exec cucumber "\
          "--require #{ req } "\
          "--format Guard::Cucumber::NotificationFormatter "\
          "--out #{ null_device } "\
          "--require features features"
        )
        runner.run(["features"], command_prefix: "xvfb-run")
      end
    end

    context "with a :bundler option" do
      it "runs without bundler when false" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")
        expect(runner).to receive(:system).with(
          "cucumber"\
          " --require #{ req }"\
          " --format Guard::Cucumber::NotificationFormatter"\
          " --out #{ null_device }"\
          " --require features features"
        )
        runner.run(["features"], bundler: false)
      end
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

    describe ":binstubs" do
      it "runs without Bundler with binstubs option to true and "\
        "bundler option to false" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")
        expect(subject).to receive(:system).with(
          "bin/cucumber"\
          " --require #{ req }"\
          " --format Guard::Cucumber::NotificationFormatter"\
          " --out #{ null_device }"\
          " --require features features"
        ).and_return(true)
        subject.run(["features"], bundler: false, binstubs: true)
      end

      it "runs with Bundler and binstubs with bundler option to true "\
        "and binstubs option to true" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")
        expect(subject).to receive(:system).with(
          "bundle exec bin/cucumber"\
          " --require #{ req }"\
          " --format Guard::Cucumber::NotificationFormatter"\
          " --out #{ null_device }"\
          " --require features features"
        ).and_return(true)
        subject.run(["features"], bundler: true, binstubs: true)
      end

      it "runs with Bundler and binstubs with bundler option unset "\
        "and binstubs option to true" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")
        expect(subject).to receive(:system).with(
          "bundle exec bin/cucumber"\
          " --require #{ req } "\
          "--format Guard::Cucumber::NotificationFormatter "\
          "--out #{ null_device }"\
          " --require features features"
        ).and_return(true)
        subject.run(["features"], binstubs: true)
      end

      it "runs with Bundler and binstubs with bundler option unset, "\
        "binstubs option to true and all_after_pass option to true" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")
        expect(subject).to receive(:system).with(
          "bundle exec bin/cucumber"\
          " --require #{ req } "\
          "--format Guard::Cucumber::NotificationFormatter"\
          " --out #{ null_device }"\
          " --require features features"
        ).and_return(true)
        subject.run(["features"], binstubs: true, all_after_pass: true)
      end

      it "runs with Bundler and binstubs with bundler option unset, "\
        "binstubs option to true and all_on_start option to true" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")
        expect(subject).to receive(:system).with(
          "bundle exec bin/cucumber --require #{ req } "\
          "--format Guard::Cucumber::NotificationFormatter "\
          "--out #{ null_device } --require features features"
        ).and_return(true)
        subject.run(["features"], binstubs: true, all_on_start: true)
      end

      it "runs with Bundler and binstubs with bundler option unset, "\
        "binstubs option to true, all_on_start option to true and "\
        "all_after_pass option to true" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")

        expect(subject).to receive(:system).with(
          "bundle exec bin/cucumber --require #{ req } "\
          "--format Guard::Cucumber::NotificationFormatter "\
          "--out #{ null_device } --require features features"
        ).and_return(true)

        subject.run(
          ["features"],
          binstubs: true,
          all_after_pass: true,
          all_on_start: true)
      end
    end

    context "with a :cli option" do
      it "appends the cli arguments when calling cucumber" do
        req = @lib_path.join("guard/cucumber/notification_formatter.rb")
        expect(runner).to receive(:system).with(
          "bundle exec cucumber --custom command --require #{req} "\
          "--format Guard::Cucumber::NotificationFormatter "\
          "--out #{ null_device } --require features features")
        runner.run(["features"], cli: "--custom command")
      end
    end

    context "with a :notification option" do
      it "does not add the guard notification listener" do
        expect(runner).to receive(:system).with(
          "bundle exec cucumber features"
        )
        runner.run(["features"], notification: false)
      end
    end
  end
end
