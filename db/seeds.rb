user = User.find_or_create_by!(email: "dev@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end

puts "User: #{user.email} (id=#{user.id})"

product = user.products.find_or_create_by!(name: "Aplikacja do nauki języków") do |p|
  p.description = "Mobilna aplikacja do nauki języków obcych z elementami grywalizacji. Lekcje 5-minutowe, system streaków, rywalizacja z znajomymi."
end

puts "Product: #{product.name} (id=#{product.id})"

focus_group = user.focus_groups.find_or_create_by!(name: "Pilot — kobiety 25-34, miasta") do |fg|
  fg.product = product
  fg.sample_size = 12
  fg.generation_mode = :proportions
  fg.status = :pending
  fg.target_demographics = {
    "wiek" => { "25-29" => 0.5, "30-34" => 0.5 },
    "plec" => { "kobieta" => 1.0 },
    "miejsce_zamieszkania" => { "duze_miasto" => 0.6, "srednie_miasto" => 0.4 }
  }
end

puts "FocusGroup: #{focus_group.name} (id=#{focus_group.id}, status=#{focus_group.status})"
