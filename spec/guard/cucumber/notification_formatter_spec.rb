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
      allow(Guard::Notifier).to receive(:notify).
        with("1 failed step, 1 skipped step, 1 undefined step, 1 pending " +
             "step, 1 passed step", title: "Cucumber Results", image: :failed)

      subject.after_features(nil)
    end
  end
end
