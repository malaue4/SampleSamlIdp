require "test_helper"

module Management
  class UsersControllerTest < ActionDispatch::IntegrationTest
    def setup
      super
      @user = User.create!(username: "username", password: "password")
      sign_in_as(@user)
    end

    def auth_headers(username = "username", password = "password")
      { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
    end

    def valid_create_params
      {
        user: {
          name_id: "test-name-id",
          email: "email@example.com",
          username: "test_user",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    def invalid_create_params
      {
        user: {
          invalid_param: "invalid_param"
        }
      }
    end

    def valid_update_params
      {
        user: {
          email: "updated@example.com"
        }
      }
    end

    def invalid_update_params
      {
        user: {
          invalid_param: "invalid_param"
        }
      }
    end

    def test_index_html
      get management_users_url, headers: auth_headers
      assert_response :success
      assert_equal "text/html", response.media_type
      assert_select "h1", "Users"
    end

    def test_index_json
      get management_users_url(format: :json), headers: auth_headers
      assert_response :success
      assert_equal "application/json", response.media_type
      assert_equal(
        User.all.order(id: :desc).map do |user|
          user.as_json(only: %i[id name_id name email phone created_at updated_at]).merge("url" => management_user_url(user))
        end,
        response.parsed_body)
    end

    def test_show_html
      get management_user_url(@user), headers: auth_headers
      assert_response :success
      assert_equal "text/html", response.media_type
      assert_select "h1", "User Details"
    end

    def test_show_json
      get management_user_url(@user, format: :json), headers: auth_headers
      assert_response :success
      assert_equal "application/json", response.media_type
      assert_equal @user.as_json(only: %i[id name_id name email phone created_at updated_at]).merge("url" => management_user_url(@user)), response.parsed_body
    end

    def test_new_html
      get new_management_user_url, headers: auth_headers
      assert_response :success
      assert_equal "text/html", response.media_type
      assert_select "h1", "New user"
    end

    def test_edit_html
      get edit_management_user_url(@user), headers: auth_headers
      assert_response :success
      assert_equal "text/html", response.media_type
      assert_select "h1", "Editing user"
    end

    def test_create_html
      assert_difference("User.count") do
        post management_users_url, params: valid_create_params, headers: auth_headers
      end
      assert_redirected_to management_user_url(User.last)
      get response.location, headers: auth_headers
      assert_response :success
      assert_equal "text/html", response.media_type
      assert_select "h1", "User Details"
    end

    def test_create_json
      assert_difference("User.count") do
        post management_users_url(format: :json), params: valid_create_params, headers: auth_headers
      end
      assert_response :created
      assert_equal "application/json", response.media_type
      assert_equal User.last.as_json(only: %i[id name_id name email phone created_at updated_at]).merge("url" => management_user_url(User.last)), response.parsed_body
    end

    def test_create_invalid_html
      assert_no_difference("User.count") do
        post management_users_url, params: invalid_create_params, headers: auth_headers
      end
      assert_response :unprocessable_entity
      assert_equal "text/html", response.media_type
      assert_select "h1", "New user"
    end

    def test_create_invalid_json
      assert_no_difference("User.count") do
        post management_users_url(format: :json), params: invalid_create_params, headers: auth_headers
      end
      assert_response :unprocessable_entity
      assert_equal "application/json", response.media_type
      assert_equal({ "password" => [ "can't be blank" ] }, response.parsed_body)
    end

    def test_update_html
      patch management_user_url(@user), params: valid_update_params, headers: auth_headers
      assert_redirected_to management_user_url(@user)
      get response.location, headers: auth_headers
      assert_response :success
      assert_equal "text/html", response.media_type
      assert_select "h1", "User Details"
    end

    def test_update_json
      assert_changes("@user.reload.email") do
        patch management_user_url(@user, format: :json), params: valid_update_params, headers: auth_headers
      end
      assert_response :success
      assert_equal "application/json", response.media_type
      @user.reload
      assert_equal @user.as_json(only: %i[id name_id name email phone created_at updated_at]).merge("url" => management_user_url(@user)), response.parsed_body
    end

    def test_update_invalid_html
      patch management_user_url(@user), params: { user: { name_id: "" } }, headers: auth_headers
      assert_response :unprocessable_entity
      assert_equal "text/html", response.media_type
      assert_select "h1", "Editing user"
    end

    def test_update_invalid_json
      patch management_user_url(@user, format: :json), params: { user: { name_id: "" } }, headers: auth_headers
      assert_response :unprocessable_entity
      assert_equal "application/json", response.media_type
      assert_equal({ "name_id" => [ "can't be blank" ] }, response.parsed_body)
    end

    def test_destroy_html
      assert_difference("User.count", -1) do
        delete management_user_url(@user), headers: auth_headers
      end
      assert_redirected_to management_users_url
    end

    def test_destroy_json
      assert_difference("User.count", -1) do
        delete management_user_url(@user, format: :json), headers: auth_headers
      end
      assert_response :no_content
    end
  end
end
