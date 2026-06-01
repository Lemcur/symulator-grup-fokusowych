FactoryBot.define do
  factory :recommendation do
    focus_group
    strengths { ["Jakość", "Design", "Marka"] }
    weaknesses { ["Cena", "Dostępność", "Wsparcie"] }
    rating_distribution { { "1" => 0, "2" => 1, "3" => 4, "4" => 10, "5" => 5 } }
    segment_insights { { "młodzi" => "ceniona jakość", "starsi" => "krytyka ceny" } }
    agreement_points { ["wszyscy doceniają design"] }
    persuasive_arguments { ["argument o gwarancji przekonał 3 osoby"] }
    persistent_divisions { ["segment 25-34 vs 45+ co do ceny"] }
    generated_at { Time.current }
  end
end
