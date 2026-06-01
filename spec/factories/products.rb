FactoryBot.define do
  factory :product do
    user
    sequence(:name) { |n| "Produkt #{n}" }
    description { "Opis testowego produktu" }
  end
end
