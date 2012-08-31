require 'spec_helper'

describe Answer do
  it "sets current prob to initial prob on creation" do
    a = FactoryGirl.build(:answer)
    a.current_probability.should be_nil
    a.save
    a.current_probability.should eq(a.initial_probability)
  end

  it "#total_pool_share gives answer's total bet value plus the answer's portion of the initial pool" do
    question = FactoryGirl.create(:question_with_answers, :answer_count => 3)
    answer = question.answers.first
    answer.bet_total = 1000
    answer.save

    answer.total_pool_share.should == 1000 + question.initial_pool * answer.initial_probability
  end
end
