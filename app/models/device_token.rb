class DeviceToken < ActiveRecord::Base
  belongs_to :user
  attr_accessible :value

  before_save :upcase_token_value

private

  def upcase_token_value
    value.upcase!  
  end

end
