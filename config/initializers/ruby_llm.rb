require "ruby_llm/schema"

RubyLLM.configure do |config|
  config.openai_api_key    = ENV.fetch("OPENAI_API_KEY", nil)
  config.anthropic_api_key = ENV.fetch("ANTHROPIC_API_KEY", nil)
  config.gemini_api_key    = ENV.fetch("GEMINI_API_KEY", nil)
  config.mistral_api_key   = ENV.fetch("MISTRAL_API_KEY", nil)
  config.deepseek_api_key  = ENV.fetch("DEEPSEEK_API_KEY", nil)
  config.xai_api_key       = ENV.fetch("XAI_API_KEY", nil)

  config.request_timeout = 120
  config.max_retries = 2
end
