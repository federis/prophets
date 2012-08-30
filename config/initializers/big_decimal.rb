BigDecimal('0').to_json

# Force BigDecimal serialization to numeric instead of wrapping them into strings
class BigDecimal
  def as_json(options = nil)
    self
  end
end