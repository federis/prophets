require 'spec_helper'

describe "Omniauth" do

  before do
    OmniAuth.config.test_mode = true
  end

  context "for successful facebook calls," do
    before do
      OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
        :provider => "facebook",
        :uid => '100004368094432',
        :info => {
            :email => "xpmyiom_narayananson_1347542317@tfbnw.net",
            :name => "Barbara Amdcfhjiddcb Narayananson",
            :first_name => "Barbara",
            :last_name => "Narayananson",
            :image => "http://graph.facebook.com/100004368094432/picture?type=square",
            :urls => { :Facebook => "http://www.facebook.com/profile.php?id=100004368094432" }
        },
        :credentials => {
          :token => "AAACCkriDW3MBAKDq640HIjiRZBZCccwf3TF2Eze5A1iMdu7DVvSX4giNSSRZBsb1UXVdKZBkoa4arDcvRD6cuC5aFqSBZCnDSozvmFm8S7wizKMz9YiGE",
          :expires_at => 1347548401,
          :expires => true
        },
        :extra => {
          :raw_info => {
            :id => '100004368094432',
            :name => "Barbara Amdcfhjiddcb Narayananson",
            :first_name => "Barbara",
            :middle_name => "Amdcfhjiddcb",
            :last_name => "Narayananson",
            :link => "http://www.facebook.com/profile.php?id=100004368094432",
            :gender => "female",
            :email => "xpmyiom_narayananson_1347542317@tfbnw.net",
            :timezone => 0,
            :locale => "en_US",
            :updated_time => '2012-09-13T13:18:41+0000'
          }
        }
      })

    end

    it "signs in an existing user" do
      user = FactoryGirl.create(:user, :fb_uid => '100004368094432')
      visit new_user_session_path
      click_link "Sign in with Facebook"

      page.current_path.should == "/"
    end

    it "registers new users" do
      user_count = User.count

      visit new_user_session_path
      click_link "Sign in with Facebook"

      page.current_url.should == new_user_registration_url(:fb => true)
      
      find_field('user_email').value.should == "xpmyiom_narayananson_1347542317@tfbnw.net"
      find_field('user_name').value.should == "Barbara Amdcfhjiddcb Narayananson"

      fill_in 'user_password', :with => "password"
      fill_in 'user_password_confirmation', :with => "password"

      click_button "Sign up"

      page.current_path.should == "/"
      User.count.should == user_count + 1
    end
  end

  context "for failed facebook calls," do
    before do
      OmniAuth.config.mock_auth[:facebook] = :access_denied
    end

    it "doesn't create or sign in user who denies access" do
      user_count = User.count

      visit new_user_session_path
      click_link "Sign in with Facebook"

      page.current_path.should == new_user_session_path
      User.count.should == user_count
    end
  end

end
