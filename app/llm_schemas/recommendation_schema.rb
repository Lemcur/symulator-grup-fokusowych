class RecommendationSchema < RubyLLM::Schema
  string :summary, description: "Główny wniosek z grupy fokusowej, 3-4 zdania syntetycznego streszczenia"

  array :strengths, description: "Mocne strony produktu wyciągnięte z opinii uczestników (3-5 punktów)" do
    string
  end
  array :weaknesses, description: "Słabe strony produktu wyciągnięte z opinii uczestników (3-5 punktów)" do
    string
  end
  array :agreement_points, description: "Punkty na których uczestnicy się zgadzają po deliberacji (3-5 punktów)" do
    string
  end
  array :persuasive_arguments, description: "Argumenty które przekonały innych do zmiany zdania w deliberacji - co działa argumentacyjnie (2-4 punkty)" do
    string
  end
  array :persistent_divisions, description: "Obszary trwałego podziału - gdzie debata nie doprowadziła do zgody (2-4 punkty)" do
    string
  end
  array :segment_insights, description: "Insights specyficzne dla segmentów demograficznych, np. 'młodzi marketingowcy doceniają X, starsi obawiają się Y' (2-4 punkty)" do
    string
  end
end
