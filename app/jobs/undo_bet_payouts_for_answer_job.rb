class UndoBetPayoutsForAnswerJob
  @queue = :bet_payout_undo

  def self.perform(answer_id)
    answer = Answer.find(answer_id)
    answer.undo_bet_judgements!
  end
end