require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
	def setup
		@user = users(:harsh)
	end

	test "unsuccesful edit" do 
		get edit_user_path(@user)	
		assert_template 'users/edit'

		patch user_path(@user), user: { name:  "",
														email: "foo@invalid",
														password: "foo",
														password_cofirmation: "bar" }

		assert_template 'users/edit'
	end

	test "successful edit" do
		get edit_user_path(@user)
		assert_template 'users/edit'
		name = "Foo Bar"
		email = "foo@bar.com"

		patch user_path(@user), user: { name:  name,
														email: email,
														password: "",
														password_cofirmation: "" }

		assert_not flash.empty?
		assert_redirected_to @user
		@user.reload
		assert_equal @user.name, name
		assert_equal @user.email, email
	end
end
