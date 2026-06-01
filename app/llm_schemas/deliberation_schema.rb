class DeliberationSchema < RubyLLM::Schema
  number :rating, description: "Ocena 1-5 po uwzględnieniu opinii innych uczestników grupy"
  string :pros, description: "Konkretne plusy produktu po rozważeniu opinii innych"
  string :cons, description: "Konkretne minusy/obawy po rozważeniu opinii innych"
  string :quote, description: "Charakterystyczny cytat w pierwszej osobie po deliberacji"
  boolean :revised, description: "Czy zrewidowałaś/zrewidowałeś swoją pierwotną opinię po wysłuchaniu innych? (true=zmieniam, false=zostaję przy swoim)"
  string :revision_rationale, description: "Jeśli revised=true: krótko jaki konkretny argument innego uczestnika Cię przekonał. Jeśli revised=false: pusty string."
end
