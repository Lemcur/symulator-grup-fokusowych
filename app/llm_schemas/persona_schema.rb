class PersonaSchema < RubyLLM::Schema
  string :name, description: "Pełne imię i nazwisko (np. 'Anna Kowalska')"
  string :description, description: "3-4 zdania backstory: kim jest, gdzie mieszka, czym się zajmuje, jakie ma życie. Konkretnie, nie ogólnie."

  object :demographics_extras, description: "Dodatkowe atrybuty demograficzne wymyślone przez LLM (te z ograniczeń są dodawane przez kod)" do
    string :miasto, description: "Konkretne polskie miasto"
    string :zawod, description: "Konkretny zawód lub stanowisko"
  end

  object :traits, description: "Cechy zachowań i preferencji wpływające na decyzje produktowe" do
    array :wartosci, description: "3-5 wartości życiowych (np. 'rozwój', 'rodzina', 'wolność')" do
      string
    end
    string :lifestyle, description: "1-2 zdania o stylu życia"
    array :obawy_zakupowe, description: "2-3 konkretne obawy/wątpliwości tej osoby przy podejmowaniu decyzji zakupowych" do
      string
    end
    string :styl_komunikacji, description: "np. bezpośredni, dyplomatyczny, emocjonalny, analityczny, ironiczny"
  end
end
