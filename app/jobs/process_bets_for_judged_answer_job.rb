class ProcessBetsForJudgedAnswerJob
  @queue = :jobs

  def self.perform(answer_id, is_correct, known_at = nil)
    answer = Answer.find(answer_id)
    answer.process_bets_for_judgement(is_correct, known_at)
  end
end