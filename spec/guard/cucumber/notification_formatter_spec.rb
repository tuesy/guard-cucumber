require "guard/cucumber/notification_formatter"

RSpec.describe Guard::Cucumber::NotificationFormatter do
  subject { described_class.new(mother, nil, {}) }
  let(:mother) { instance_double(Cucumber::Runtime) }

  context "after all features" do
    let(:step) { double("step") }

    before do
      allow(mother).to receive(:steps).with(:passed).and_return([step])
      allow(mother).to receive(:steps).with(:pending).and_return([step])
      allow(mother).to receive(:steps).with(:undefined).and_return([step])
      allow(mother).to receive(:steps).with(:skipped).and_return([step])
      allow(mother).to receive(:steps).with(:failed).and_return([step])
    end

    it "formats the notification" do
      allow(Guard::Compat::UI).to receive(:notify).
        with("1 failed step, 1 skipped step, 1 undefined step, 1 pending " +
             "step, 1 passed step", title: "Cucumber Results", image: :failed)

      subject.after_features(nil)
    end
  end

  describe "#step_name" do
    let(:step_match) { instance_double(Cucumber::StepMatch) }
    let(:feature) { instance_double(Cucumber::Core::Ast::Feature, name: "feature1") }

    before do
      subject.before_feature(feature)
      subject.before_background(background)
      allow(step_match).to receive(:format_args) do |block|
        block.call "step_name1"
      end
    end

    context "when failure is in a background step" do
      let(:background) { instance_double(Cucumber::Formatter::LegacyApi::Ast::Background, feature: feature) }

      it "notifies with a valid feature name" do
        expect(Guard::Compat::UI).to receive(:notify).with("*step_name1*", hash_including(title: "feature1"))
        subject.step_name(nil, step_match, :failed, nil, nil, nil)
      end
    end

    # workaround for: https://github.com/cucumber/gherkin/issues/334
    context "with a buggy Background implementation" do
      let(:background) { instance_double(Cucumber::Formatter::LegacyApi::Ast::Background, feature: nil) }

      it "correctly gets the feature name" do
        expect(Guard::Compat::UI).to receive(:notify).with("*step_name1*", hash_including(title: "feature1"))
        subject.step_name(nil, step_match, :failed, nil, nil, nil)
      end
    end
  end
end
