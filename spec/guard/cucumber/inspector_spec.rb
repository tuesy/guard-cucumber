require "spec_helper"

describe Guard::Cucumber::Inspector do

  let(:inspector) { Guard::Cucumber::Inspector }

  describe ".clean" do
    context "with the standard feature set" do
      before do
        allow(Dir).to receive(:glob).
          and_return(%w(features/a.feature features/subfolder/b.feature))
      end

      it "removes non-feature files" do
        expect(inspector.clean(%w(features/a.feature b.rb), %w(features))).
          to eq(%w(features/a.feature))
      end

      it "removes non-existing feature files" do
        expect(inspector.clean(
          %w(features/a.feature features/x.feature),
          %w(features))).
            to eq(%w(features/a.feature))
      end

      it "keeps a feature folder" do
        expect(inspector.clean(
          %w(features/a.feature features/subfolder),
          %w(features)
        )).to eq(%w(features/a.feature features/subfolder))
      end

      it "removes duplicate paths" do
        expect(inspector.clean(
          %w(features features),
          %w(features))).to eq(%w(features))
      end

      it "removes individual feature tests if the path is already "\
        "in paths to run" do
        expect(inspector.clean(
          %w( features/a.feature features/a.feature:10),
          %w(features))).to eq(%w(features/a.feature))
      end

      it "removes feature folders included in other feature folders" do
        expect(inspector.clean(
          %w(features/subfolder features),
          %w(features))).to eq(%w(features))
      end

      it "removes feature files includes in feature folder" do
        expect(inspector.clean(
          %w(features/subfolder/b.feature features),
          %w(features))).to eq(%w(features))
      end
    end

    context "with an additional feature set" do
      before do
        allow(Dir).to receive(:glob).
        and_return(%w(
          feature_set_1/a.feature
          feature_set_1/subfolder/b.feature
          feature_set_2/c.feature
          feature_set_2/subfolder/d.feature))
      end

      it "removes non-feature files" do
        expect(inspector.clean(
          %w(feature_set_1/a.feature feature_set_2/c.feature b.rb),
          %w(feature_set_1, feature_set_2))).
          to eq(%w(feature_set_1/a.feature feature_set_2/c.feature))
      end

      it "removes non-existing feature files" do
        expect(inspector.clean(
          %w(
            feature_set_1/a.feature
            feature_set_1/x.feature
            feature_set_2/c.feature
            feature_set_2/y.feature),
          %w(feature_set_1 feature_set_2))).
            to eq(%w(feature_set_1/a.feature feature_set_2/c.feature))
      end

      it "keeps the feature folders" do
        expect(inspector.clean(
          %w(
            feature_set_1/a.feature
            feature_set_1/subfolder
            feature_set_2/c.feature
            feature_set_2/subfolder),
          %w(feature_set_1 feature_set_2))).
            to eq(%w(
              feature_set_1/a.feature
              feature_set_1/subfolder
              feature_set_2/c.feature
              feature_set_2/subfolder))
      end

      it "removes duplicate paths" do
        expect(inspector.clean(
          %w(
            feature_set_1
            feature_set_1
            feature_set_2
            feature_set_2),
          %w(feature_set_1 feature_set_2))).
            to eq(%w(feature_set_1 feature_set_2))
      end

      it "removes individual feature tests if the path is already "\
        "in paths to run" do
        expect(inspector.clean(
        %w(
          feature_set_1/a.feature
          feature_set_1/a.feature:10
          feature_set_2/c.feature
          feature_set_2/c.feature:25),
        %w(features feature_set_2))).
          to eq(%w(feature_set_1/a.feature feature_set_2/c.feature))
      end

      it "removes feature folders included in other feature folders" do
        expect(inspector.clean(
          %w(
            feature_set_1/subfolder
            feature_set_1
            feature_set_2/subfolder
            feature_set_2),
          %w(feature_set_1 feature_set_2))).
            to eq(%w(feature_set_1 feature_set_2))

        expect(inspector.clean(
          %w(feature_set_1 feature_set_2/subfolder),
          %w(feature_set_1 feature_set_2))).
            to eq(%w(feature_set_1 feature_set_2/subfolder))

        expect(inspector.clean(
          %w(feature_set_2 feature_set_1/subfolder),
          %w(feature_set_1 feature_set_2))).
            to eq(%w(feature_set_2 feature_set_1/subfolder))
      end

      it "removes feature files includes in feature folder" do
        a = %w(
          feature_set_1/subfolder/b.feature
          feature_set_1
          feature_set_2/subfolder/c.feature feature_set_2)

        b = %w( feature_set_1 feature_set_2)
        c = %w(feature_set_1 feature_set_2)

        expect(inspector.clean(a, b)).to eq(c)

        expect(inspector.clean(
          %w(feature_set_1/subfolder/b.feature feature_set_2),

          %w(feature_set_1 feature_set_2))).
        to eq(%w(feature_set_1/subfolder/b.feature feature_set_2))

        expect(inspector.clean(
          %w(feature_set_2/subfolder/d.feature feature_set_1),
          %w(feature_set_1 feature_set_2))).
        to eq(%w( feature_set_2/subfolder/d.feature feature_set_1))
      end
    end
  end
end
