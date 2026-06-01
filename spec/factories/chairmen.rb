FactoryBot.define do
  factory :chairman do
    focus_group
    llm_model { "claude-opus-4-7" }
    role { "moderator-analityk badań jakościowych" }
  end
end
