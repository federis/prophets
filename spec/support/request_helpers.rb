module RequestHelpers
  def decode_json(json)
    ActiveSupport::JSON.decode(json)
  end
end

RSpec.configure do |c|
  c.include RequestHelpers, :type => :request
end