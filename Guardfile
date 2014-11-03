group :spec, halt_on_failure: true do
  guard :bundler do
    watch('Gemfile')
    # Uncomment next line if your Gemfile contains the `gemspec' command.
    watch(/^.+\.gemspec/)
  end

  guard :rspec do
    watch('spec/spec_helper.rb') { 'spec' }
    watch(%r{spec/.+_spec.rb})
    watch(%r{lib/(.+).rb})       { |m| "spec/#{ m[1] }_spec.rb" }
  end

  guard :rubocop do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end
