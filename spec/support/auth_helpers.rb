module AuthHelpers
  # Loguje (lub tworzy + loguje) usera, zwraca go.
  # Działa w request specs i system specs dzięki Devise::Test::IntegrationHelpers
  # załadowanym w rails_helper.rb.
  #
  # Użycie:
  #   user = sign_in!                    # tworzy nowego i loguje
  #   sign_in!(existing_user)            # loguje istniejącego
  #   user = sign_in!(create(:user, email: "x@y.pl"))
  def sign_in!(user = nil)
    user ||= create(:user)
    sign_in user
    user
  end
end
