FactoryBot.define do
  factory :persona do
    focus_group
    sequence(:name) { |n| "Persona #{n}" }
    description { "Krótki opis tej persony" }
    demographics { { "gender" => "kobieta", "age" => "25-34", "income" => "sredni" } }
    traits { { "personality" => "ostrożna", "interests" => ["technologia"] } }
  end
end
