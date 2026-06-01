require "vcr"
require "webmock/rspec"

VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join("spec/fixtures/vcr_cassettes")
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = false

  c.filter_sensitive_data("<OPENAI_API_KEY>") { ENV["OPENAI_API_KEY"] }
  c.filter_sensitive_data("<ANTHROPIC_API_KEY>") { ENV["ANTHROPIC_API_KEY"] }
  c.filter_sensitive_data("<GEMINI_API_KEY>") { ENV["GEMINI_API_KEY"] }

  c.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri]
  }
end
