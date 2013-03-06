class DeviceToken < ActiveRecord::Base
  belongs_to :user
  attr_accessible :value
end
