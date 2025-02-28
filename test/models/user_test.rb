require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user_one = users(:user_one)
    @user_two = users(:user_two)
  end

  test "provider cannot be nil" do
    user = User.new(
      uid: "123",
      email: "test@example.com"
    )
    refute user.valid? "User should be invalid without a provider"
    assert user.errors.of_kind? :provider, :blank
  end

  test "uid cannot be nil" do
    user = User.new(
      provider: "github",
      email: "test@example.com"
    )
    refute user.valid? "User should be invalid without a uid"
    assert user.errors.of_kind? :uid, :blank
  end

  test "uid must be unique" do
    user = User.new(
      provider: "github",
      uid: @user_one.uid,
      email: "test@example.com"
    )  
    refute user.valid? "User should be invalid with a duplicate uid"
    assert user.errors.of_kind? :uid, :taken
  end

  test "email must be a valid email" do
    user = User.new(
      provider: "github",
      uid: "123",
      email: "test"
    )
    refute user.valid? "User should be invalid with an invalid email"
    assert user.errors.of_kind? :email, :invalid
  end

  test "email cannot be nil" do
    user = User.new(
      provider: "github",
      uid: "123"
    )
    refute user.valid? "User should be invalid without an email"
    assert user.errors.of_kind? :email, :blank
  end

  test "email must be unique" do
    user = User.new(
      provider: "github",
      uid: "123",
      email: @user_one.email
    )
    refute user.valid? "User should be invalid with a duplicate email"
    assert user.errors.of_kind? :email, :taken
  end
end
