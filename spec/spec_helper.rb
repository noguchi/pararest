require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  SimpleCov::Formatter::RcovFormatter
)
SimpleCov.start do
  add_filter '/spec/'
end

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  #    c.default_cassette_options = {
  #      :match_requests_on => [:method,
  #      VCR.request_matchers.uri_without_param(:appid)]
  #    }
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end
