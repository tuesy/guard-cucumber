guard :rspec do
  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{spec/.+_spec.rb})
  watch(%r{lib/(.+).rb})       { |m| "spec/#{ m[1] }_spec.rb" }
end

guard :bundler do
  watch('Gemfile')
  # Uncomment next line if your Gemfile contains the `gemspec' command.
  watch(/^.+\.gemspec/)
end
