FactoryBot.define do
  factory :focus_group do
    product
    user { product.user }
    sequence(:name) { |n| "Sesja #{n}" }
    sample_size { 4 }
    generation_mode { "proportions" }
    target_demographics do
      {
        "gender" => { "kobieta" => 0.5, "mezczyzna" => 0.5 },
        "age"    => { "25-34" => 0.5, "35-44" => 0.5 }
      }
    end
    status { "pending" }

    trait :with_slots do
      generation_mode { "slots" }
      target_demographics do
        [
          { "count" => 2, "gender" => "kobieta",   "age" => "25-34" },
          { "count" => 2, "gender" => "mezczyzna", "age" => "35-44" }
        ]
      end
    end

    trait :deliberating do
      status { "deliberating" }
      started_at { 1.minute.ago }
      deliberation_started_at { Time.current }
    end

    trait :completed do
      status { "completed" }
      started_at { 5.minutes.ago }
      completed_at { Time.current }
    end
  end
end
