class OpinionSchema < RubyLLM::Schema
  number :rating, description: "Ocena produktu w skali 1-5 (1=zdecydowanie nie kupię/nie użyję, 5=zdecydowanie kupię/użyję)"
  string :pros, description: "Konkretne plusy produktu z perspektywy TEJ osoby (nie ogólne marketingowe slogany)"
  string :cons, description: "Konkretne minusy, obawy, zastrzeżenia tej osoby"
  string :quote, description: "Charakterystyczny cytat w pierwszej osobie - coś co ta osoba naprawdę by powiedziała o produkcie"
end
