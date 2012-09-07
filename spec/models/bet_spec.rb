require 'spec_helper'

describe Bet do
  let(:answer){ FactoryGirl.create(:answer) }
  let(:user) do
    user = FactoryGirl.create(:user)
    user.leagues << answer.question.league
    user
  end
  let(:membership){ user.membership_in_league(answer.question.league) }

  it "can't make a bet with an amount larger than the league's max bet" do
    bet = FactoryGirl.build(:bet, :answer => answer, :amount => answer.question.league.max_bet+1)
    
    bet.should_not be_valid
    bet.errors_on(:amount).should include("must be less than or equal to #{answer.question.league.max_bet}")
  end  

  it "increments the answer's bet total by the bet amount after creation" do
    bet = FactoryGirl.build(:bet, :answer => answer, :user => user)
    before_total = answer.bet_total
    bet.save
    answer.reload

    answer.bet_total.should == before_total + bet.amount
  end

  it "decrements the user's balance in that league by the bet amount after creation" do
    membership = user.membership_in_league(answer.question.league)

    bet = FactoryGirl.build(:bet, :answer => answer, :user => user)
    before_balance = membership.balance
    bet.save
    
    membership.reload
    membership.balance.should == before_balance - bet.amount
  end

  it "decrements the answer's bet total by the bet amount and refunds the bet to the user after destruction" do
    bet = FactoryGirl.create(:bet, :answer => answer, :user => user)
    before_total = answer.bet_total
    before_balance = membership.balance

    bet.destroy
    answer.reload

    answer.bet_total.should == before_total - bet.amount
    membership.reload.balance.should == before_balance + bet.amount
  end

  it "#invalidate! decrements the answer's bet total by the bet amount, refunds the bet to the user, and sets the invalidated_at timestamp and saves the bet & answer" do
    bet = FactoryGirl.create(:bet, :answer => answer, :user => user)
    before_total = bet.answer.bet_total
    before_balance = membership.balance

    bet.should_not be_invalidated

    bet.invalidate!

    bet.reload
    bet.should be_invalidated
    bet.invalidated_at.should_not be_nil
    bet.answer.reload.bet_total.should == before_total - bet.amount
    membership.reload.balance.should == before_balance + bet.amount
  end

  it "updates probabilities for all answers in the question after creation" do
    bet = user.bets.build(:answer_id => answer.id, :amount => 1000)
    bet.answer.question.should_receive(:update_answer_probabilities!)
    bet.save
  end

  it "doesn't modify answer bet total or user balance if invalidation fails" do
    bet = FactoryGirl.create(:bet, :answer => answer, :user => user)
    before_total = bet.answer.bet_total
    before_balance = membership.balance

    bet.stub(:save!){ raise ActiveRecord::RecordNotSaved }
    expect{ bet.invalidate! }.to raise_error(ActiveRecord::RecordNotSaved)

    bet.reload
    bet.should_not be_invalidated
    bet.invalidated_at.should be_nil
    bet.answer.reload.bet_total.should == before_total 
    membership.reload.balance.should == before_balance
  end

end
