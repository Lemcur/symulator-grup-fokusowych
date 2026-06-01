class LlmClient
  PROVIDER_BY_MODEL = {
    "gpt-4o-mini"        => :openai,
    "gpt-4o"             => :openai,
    "claude-haiku-4-5"   => :anthropic,
    "claude-sonnet-4-6"  => :anthropic
  }.freeze

  class UnknownModelError < StandardError; end

  attr_reader :model, :provider

  def initialize(model:)
    @model = model
    @provider = PROVIDER_BY_MODEL.fetch(model) do
      raise UnknownModelError, "Brak mapowania providera dla modelu: #{model.inspect}"
    end
  end

  def ask(prompt, schema: nil)
    chat = RubyLLM.chat(model: @model, provider: @provider)
    chat = chat.with_schema(schema) if schema
    chat.ask(prompt).content
  end
end
