module AuthHelpers
  def sign_in!(user = nil)
    user ||= create(:user)
    sign_in user
    user
  end
end
