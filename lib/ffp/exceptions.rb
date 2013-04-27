module FFP
  module Exceptions
    class BetDoubleJudgementError < StandardError; end
    class UndoUnjudgedBetError < StandardError; end
  end
end