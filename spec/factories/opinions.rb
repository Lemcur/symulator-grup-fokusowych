FactoryBot.define do
  factory :opinion do
    persona
    focus_group { persona.focus_group }
    round { 0 }
    revised { false }
    rating { 4 }
    pros { "Dobra jakość" }
    cons { "Cena wysoka" }
    quote { "Generalnie polecam, ale cena boli." }
    raw_response { { "model" => "test", "tokens" => 123 } }
    status { "collected" }

    trait :round_one do
      round { 1 }
      revised { true }
      revision_rationale { "Po przeczytaniu innych zmieniłam zdanie o cenie." }
    end

    trait :round_one_unchanged do
      round { 1 }
      revised { false }
      revision_rationale { "Po deliberacji moja opinia pozostaje ta sama." }
    end

    trait :failed do
      status { "failed" }
      error_message { "LLM timeout" }
      rating { nil }
      pros { nil }
      cons { nil }
      quote { nil }
    end
  end
end
