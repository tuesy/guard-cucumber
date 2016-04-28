require "guard/compat/test/helper"
require "guard/cucumber"

RSpec.describe Guard::Cucumber do
  subject { Guard::Cucumber.new(options) }

  let(:options) { {} }
  let(:runner) { Guard::Cucumber::Runner }
  let(:msg_opts) { { message: "Running all features" } }

  before do
    allow(Dir).to receive(:glob).
      and_return ["features/a.feature", "features/subfolder/b.feature"]
  end

  let(:default_options) do
    {
      all_after_pass: true,
      all_on_start: true,
      keep_failed: true,
      cmd: "cucumber",
      cmd_additional_args: "--no-profile --color --format progress --strict",
      feature_sets: ["features"]
    }
  end

  describe "#initialize" do
    context "when no options are provided" do
      let(:options) { {} }

      it "sets a default :all_after_pass option" do
        expect(subject.options[:all_after_pass]).to be_truthy
      end

      it "sets a default :all_on_start option" do
        expect(subject.options[:all_on_start]).to be_truthy
      end

      it "sets a default :keep_failed option" do
        expect(subject.options[:keep_failed]).to be_truthy
      end

      it "sets a default :cmd_additional_args option" do
        expect(subject.options[:cmd_additional_args]).
          to eql "--no-profile --color --format progress --strict"
      end

      it "sets a default :feature_sets option" do
        expect(subject.options[:feature_sets]).to eql ["features"]
      end
    end

    context "with other options than the default ones" do
      let(:options) do
        { all_after_pass: false,
          all_on_start: false,
          keep_failed: false,
          cmd_additional_args: "--color",
          feature_sets: ["feature_set_a", "feature_set_b"],
          focus_on: "@focus" }
      end

      it "sets the provided :all_after_pass option" do
        expect(subject.options[:all_after_pass]).to be_falsey
      end

      it "sets the provided :all_on_start option" do
        expect(subject.options[:all_on_start]).to be_falsey
      end

      it "sets the provided :keep_failed option" do
        expect(subject.options[:keep_failed]).to be_falsey
      end

      it "sets the provided :cmd_additional_args option" do
        expect(subject.options[:cmd_additional_args]).to eql "--color"
      end

      it "sets the provided :feature_sets option" do
        expect(subject.options[:feature_sets]).
          to eql ["feature_set_a", "feature_set_b"]
      end

      it "sets the provided :focus_on option" do
        expect(subject.options[:focus_on]).to eql "@focus"
      end
    end

    context "when unknown options are provided" do
      before do
        allow(Guard::Compat::UI).to receive(:warning)
      end

      let(:options) { { foobar: false } }
      it "warns about unknown options" do
        expect(Guard::Compat::UI).to receive(:warning).
          with("Unknown guard-cucumber option: :foobar")
        subject
      end
    end
  end

  describe "#start" do
    it "calls #run_all" do
      expect(runner).to receive(:run).
        with(["features"], default_options.merge(msg_opts)).and_return(true)
      subject.start
    end

    context "with the :all_on_start option is false" do
      let(:options) { { all_on_start: false } }

      it "does not call #run_all" do
        expect(runner).not_to receive(:run).
          with(["features"], default_options.merge(all_on_start: false,
                                                   message: "Running all
                                                   features"))
        subject.start
      end
    end
  end

  describe "#run_all" do
    it "runs all features" do
      expect(runner).to receive(:run).
        with(["features"], default_options.merge(msg_opts)).and_return(true)
      subject.run_all
    end

    it "cleans failed memory if passed" do
      expect(runner).to receive(:run).
        with(["features/foo"], default_options).and_return(false)

      expect do
        subject.run_on_modifications(["features/foo"])
      end.to throw_symbol :task_has_failed

      expect(runner).to receive(:run).
        with(["features"], default_options.merge(msg_opts)).and_return(true)

      expect(runner).to receive(:run).
        with(["features/bar"], default_options).and_return(true)

      subject.run_on_modifications(["features/bar"])
    end

    it "saves failed features" do
      expect(runner).to receive(:run).
        with(["features"], default_options.merge(msg_opts)).and_return(false)
      expect(File).to receive(:exist?).
        with("rerun.txt").and_return true
      file = double("file")
      expect(file).to receive(:read).and_return "features/foo"
      allow(File).to receive(:open).and_yield file
      expect(File).to receive(:delete).with("rerun.txt")
      expect { subject.run_all }.to throw_symbol :task_has_failed

      expect(runner).to receive(:run).
        with(["features/bar", "features/foo"], default_options).and_return(true)
      expect(runner).to receive(:run).
        with(["features"], default_options.merge(msg_opts)).and_return(true)
      subject.run_on_modifications(["features/bar"])
    end

    context "with the :feature_sets option" do
      non_standard_feature_set = ["a_non_standard_feature_set"]
      let(:options) { { feature_sets: non_standard_feature_set } }

      it "passes the feature sets as paths to runner" do
        expect(runner).to receive(:run).
          with(non_standard_feature_set, anything).and_return(true)

        subject.run_all
      end
    end

    context "with the :cmd_additional_args option" do
      let(:options) { { cmd_additional_args: "--color" } }

      it "directly passes :cmd_additional_args option to runner" do
        msg = "Running all features"
        opts = default_options.merge(cmd_additional_args: "--color",
                                     message: msg)

        expect(runner).to receive(:run).with(["features"], opts).
          and_return(true)
        subject.run_all
      end
    end

    context "when the :keep_failed option is false" do
      let(:options) { { keep_failed: false } }
      let(:run_options) { default_options.merge keep_failed: false }

      it "does not save failed features if keep_failed is disabled" do
        expect(runner).to receive(:run).
          with(["features"], run_options.merge(msg_opts)).and_return(false)

        expect(File).not_to receive(:exist?).with("rerun.txt")

        expect { subject.run_all }.to throw_symbol :task_has_failed

        expect(runner).to receive(:run).
          with(["features/bar"], run_options).and_return(true)

        expect(runner).to receive(:run).
          with(["features"], run_options.merge(msg_opts)).and_return(true)

        subject.run_on_modifications(["features/bar"])
      end
    end

    context "with a :run_all option" do
      let(:options) do
        {
          cmd_additional_args: "--color",
          run_all: { cmd_additional_args: "--format progress" }
        }
      end

      it "allows the :run_all options to override the default_options" do
        expect(runner).to receive(:run).
          with(
            anything,
            hash_including(cmd_additional_args: "--format progress")
          ).and_return(true)

        subject.run_all
      end
    end
  end

  describe "#reload" do
    it "clears failed_path" do
      expect(runner).to receive(:run).
        with(["features/foo"], default_options).and_return(false)

      expect do
        subject.run_on_modifications(["features/foo"])
      end.to throw_symbol :task_has_failed

      subject.reload

      expect(runner).to receive(:run).
        with(["features/bar"], default_options).and_return(true)

      opts = default_options.merge(msg_opts)

      expect(runner).to receive(:run).
        with(["features"], opts).and_return(true)
      subject.run_on_modifications(["features/bar"])
    end
  end

  describe "#run_on_modifications" do
    it "runs cucumber with all features" do
      expect(runner).to receive(:run).
        with(["features"], default_options.merge(msg_opts)).and_return(true)
      subject.run_on_modifications(["features"])
    end

    it "runs cucumber with single feature" do
      expect(runner).to receive(:run).
        with(["features/a.feature"], default_options).and_return(true)
      subject.run_on_modifications(["features/a.feature"])
    end

    it "passes the matched paths to the inspector for cleanup" do
      allow(runner).to receive(:run).and_return(true)
      expect(Guard::Cucumber::Inspector).to receive(:clean).
        with(["features"], ["features"]).and_return ["features"]
      subject.run_on_modifications(["features"])
    end

    it "calls #run_all if the changed specs pass after failing" do
      expect(runner).to receive(:run).
        with(["features/foo"], default_options).and_return(false, true)

      opts = default_options.merge(msg_opts)
      expect(runner).to receive(:run).
        with(["features"], opts).and_return(true)

      expect do
        subject.run_on_modifications(["features/foo"])
      end.to throw_symbol :task_has_failed
      subject.run_on_modifications(["features/foo"])
    end

    it "does not call #run_all if the changed specs pass without failing" do
      expect(runner).to receive(:run).
        with(["features/foo"], default_options).and_return(true)

      expect(runner).not_to receive(:run).
        with(["features"], default_options.merge(msg_opts))

      subject.run_on_modifications(["features/foo"])
    end

    context "with a :cmd_additional_args option" do
      let(:options) { { cmd_additional_args: "--color" } }

      it "directly passes the :cmd_additional_args option to the runner" do
        opts = default_options.merge(cmd_additional_args: "--color")
        opts.merge!(msg_opts)

        expect(runner).to receive(:run).
          with(["features"], opts).and_return(true)
        subject.run_on_modifications(["features"])
      end
    end

    context "when the :all_after_pass option is false" do
      let(:options) { { all_after_pass: false } }

      it "does not call #run_all if the changed specs pass after failing "\
        "but the :all_after_pass option is false" do
        expect(runner).to receive(:run).
          with(["features/foo"], default_options.merge(all_after_pass: false)).
          and_return(false, true)

        opts = default_options.merge(all_after_pass: false).merge(msg_opts)
        expect(runner).not_to receive(:run).
          with(["features"], opts)

        expect do
          subject.run_on_modifications(["features/foo"])
        end.to throw_symbol :task_has_failed

        subject.run_on_modifications(["features/foo"])
      end
    end

    context "with a rerun.txt file" do
      before do
        file = double("file")
        allow(file).to receive(:read).and_return "features/foo"
        allow(File).to receive(:open).and_yield file
      end

      it "keeps failed spec and rerun later" do
        expect(runner).to receive(:run).
          with(["features/foo"], default_options).and_return(false)
        expect(File).to receive(:exist?).
          with("rerun.txt").and_return true
        expect(File).to receive(:delete).
          with("rerun.txt")

        expect do
          subject.run_on_modifications(["features/foo"])
        end.to throw_symbol :task_has_failed

        expect(runner).to receive(:run).
          with(["features/bar", "features/foo"], default_options).
          and_return(true)

        expect(runner).to receive(:run).
          with(["features"], default_options.merge(msg_opts)).and_return(true)

        subject.run_on_modifications(["features/bar"])

        expect(runner).to receive(:run).
          with(["features/bar"], default_options).and_return(true)

        subject.run_on_modifications(["features/bar"])
      end
    end
  end
end
