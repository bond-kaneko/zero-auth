# frozen_string_literal: true

require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'should get new' do
    get signup_url
    assert_response :success
  end

  test 'should create user and login' do
    assert_difference('User.count', 1) do
      post signup_url, params: {
        user: {
          email: 'newuser@example.com',
          password: 'Password123',
          password_confirmation: 'Password123',
        },
      }
    end

    assert_redirected_to root_path
    assert_not_nil session[:user_id]
    assert_equal 'アカウントを作成しました', flash[:notice]
  end

  test 'should not create user with invalid email' do
    assert_no_difference('User.count') do
      post signup_url, params: {
        user: {
          email: 'invalid-email',
          password: 'Password123',
          password_confirmation: 'Password123',
        },
      }
    end

    assert_response :unprocessable_entity
  end

  test 'should not create user with mismatched password' do
    assert_no_difference('User.count') do
      post signup_url, params: {
        user: {
          email: 'test@example.com',
          password: 'Password123',
          password_confirmation: 'DifferentPassword',
        },
      }
    end

    assert_response :unprocessable_entity
  end
end
