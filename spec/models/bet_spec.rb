require 'spec_helper'

describe Bet do
  let(:answer){ FactoryGirl.create(:answer) }
  let(:user) do
    user = FactoryGirl.create(:user)
    user.leagues << answer.question.league
    user
  end
  let(:membership){ user.membership_in_league(answer.question.league) }
  let(:new_bet){ FactoryGirl.build(:bet, :answer => answer, :membership => membership) }
  let(:bet){ FactoryGirl.create(:bet, :answer => answer, :membership => membership) }
  let(:winning_bet){ FactoryGirl.create(:bet, :winner, :answer => answer, :membership => membership) }
  let(:losing_bet){ FactoryGirl.create(:bet, :loser, :answer => answer, :membership => membership) }
  let(:invalidated_bet){ FactoryGirl.create(:bet, :invalidated, :answer => answer, :membership => membership) }

  it "can't be made when betting is closed" do
    answer.stub(:open_for_betting?).and_return(false)

    new_bet.should_not be_valid
    new_bet.errors[:base].should include(I18n.t('activerecord.errors.models.bet.betting_has_been_closed'))
  end

  it "can't be made with an amount greater than that of the user's balance in that league" do
    new_bet.amount = membership.balance + 1
    new_bet.should_not be_valid
    new_bet.errors[:base].should include(I18n.t('activerecord.errors.models.bet.insufficient_funds_to_cover_bet'))
  end

  it "can't be made with an amount larger than the league's max bet" do
    new_bet.amount = answer.question.league.max_bet+1
    
    new_bet.should_not be_valid
    new_bet.errors_on(:amount).should include("must be less than or equal to #{answer.question.league.max_bet}")
  end  

  it "increments the answer's bet total by the bet amount after creation" do
    before_total = answer.bet_total
    new_bet.save
    answer.reload

    answer.bet_total.should == before_total + new_bet.amount
  end

  it "decrements the user's balance in that league by the bet amount after creation" do
    before_balance = membership.balance
    new_bet.save
    
    membership.reload
    membership.balance.should == before_balance - new_bet.amount
  end

  it "decrements the answer's bet total by the bet amount and refunds the bet to the user after destruction" do
    bet #trigger creation
    before_total = answer.bet_total
    before_balance = membership.balance

    bet.destroy
    answer.reload

    answer.bet_total.should == before_total - bet.amount
    membership.reload.balance.should == before_balance + bet.amount
  end

  it "#invalidate! decrements the answer's bet total by the bet amount, refunds the bet to the user, and sets the invalidated_at timestamp and saves the bet & answer" do
    bet #trigger creation
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
    bet = membership.bets.build(:amount => 1000)
    bet.answer = answer
    bet.answer.question.should_receive(:update_answer_probabilities!)
    bet.save
  end

  it "updates probabilities for all answers in the question after invalidation" do
    bet.answer.question.should_receive(:update_answer_probabilities!)
    bet.invalidate!
  end

  it "updates probabilities for all answers in the question after undoing judgement" do
    bet.answer.question.should_receive(:update_answer_probabilities!)
    winning_bet.undo_judgement!
  end

  it "doesn't modify answer bet total or user balance if invalidation fails" do
    bet #trigger creation
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

  it "#pay_bettor! increments the user's balance in that league and sets the bet's payout" do
    bet #trigger creation
    before_balance = membership.balance

    bet.pay_bettor!
    payout = (bet.amount + bet.amount * (1/bet.probability - 1))
    membership.reload.balance.should == before_balance + payout
    bet.reload.payout.should == payout
  end

  it "#pay_bettor! doesn't increment the user's balance or set the bet's payout if the save fails" do
    bet #trigger creation
    before_balance = membership.balance

    bet.stub(:save!){ raise ActiveRecord::RecordNotSaved }
    expect{ bet.pay_bettor! }.to raise_error(ActiveRecord::RecordNotSaved)
    
    membership.reload.balance.should == before_balance
    bet.reload.payout.should be_nil
  end

  it "#zero_payout! sets bet payout to zero and saves the bet" do
    bet.payout.should be_nil
    bet.zero_payout!
    bet.reload.payout.should == 0
  end

  it "#pay_bettor! throws exception when bet has already been judged" do
    bet.pay_bettor!
    expect{ bet.pay_bettor! }.to raise_error(FFP::Exceptions::BetDoubleJudgementError)
  end

  it "#zero_payout! throws exception when bet has already been judged" do
    bet.pay_bettor!
    expect{ bet.zero_payout! }.to raise_error(FFP::Exceptions::BetDoubleJudgementError)
  end
  
  it "#payout_when_correct gives the correct payout" do
    bet = Bet.new(:amount => 2)
    bet.probability = 0.2 # 4:1 odds
    bet.payout_when_correct.should == 10
  end

  it "increments membership's outstanding bets value after creation" do
    FactoryGirl.create(:bet, :answer => answer, :membership => membership, :amount => 2)
    FactoryGirl.create(:bet, :answer => answer, :membership => membership, :amount => 5)
    FactoryGirl.create(:bet, :answer => answer, :membership => membership, :amount => 10)
    other_league_answer = FactoryGirl.create(:answer)
    other_league_answer.question.league.users << user
    FactoryGirl.create(:bet, :answer => other_league_answer, 
                             :membership => user.membership_in_league(other_league_answer.question.league), 
                             :amount => 6)

    membership.outstanding_bets_value.should == 17
  end

  it "decrements membership's outstanding bets value after payout" do
    bet = FactoryGirl.create(:bet, :answer => answer, :membership => membership, :amount => 2)
    FactoryGirl.create(:bet, :answer => answer, :membership => membership, :amount => 5)

    membership.outstanding_bets_value.should == 7
    bet.pay_bettor!
    membership.outstanding_bets_value.should == 5
  end

  it "decrements membership's outstanding bets value after payout is zeroed" do
    bet = FactoryGirl.create(:bet, :answer => answer, :membership => membership, :amount => 2)
    FactoryGirl.create(:bet, :answer => answer, :membership => membership, :amount => 5)

    membership.outstanding_bets_value.should == 7
    bet.zero_payout!
    membership.outstanding_bets_value.should == 5
  end

  it "decrements membership's outstanding bets value after invalidation" do
    bet = FactoryGirl.create(:bet, :answer => answer, :membership => membership, :amount => 2)
    FactoryGirl.create(:bet, :answer => answer, :membership => membership, :amount => 5)

    membership.outstanding_bets_value.should == 7
    bet.invalidate!
    membership.outstanding_bets_value.should == 5
  end

  it "creates an activity entry after creation" do
    activity_count = Activity.count
    bet #trigger creation
    Activity.count.should == activity_count + 1

    activity = Activity.last
    activity.feedable.should == bet
    activity.activity_type.should == Activity::TYPES[:bet_created]
  end

  it "creates an activity entry after payout" do
    bet #trigger creation

    activity_count = Activity.count
    bet.pay_bettor!
    Activity.count.should == activity_count + 1

    activity = Activity.last
    activity.feedable.should == bet
    activity.activity_type.should == Activity::TYPES[:bet_payout]
  end

  it "#delete_bet_payout_activity deletes associated payout activity" do
    bet.pay_bettor!
    Activity.where(activity_type: Activity::TYPES[:bet_payout], feedable_id: bet.id, feedable_type: "Bet").count.should eq(1)
    bet.send(:delete_bet_payout_activity)
    Activity.where(activity_type: Activity::TYPES[:bet_payout], feedable_id: bet.id, feedable_type: "Bet").count.should eq(0)
  end

  describe "#undo_judgement! sets the payout to nil and" do
    it "for a winning bet, it decrements the membership's outstanding balance and increments outstanding bets value" do
      payout = winning_bet.payout
      initial_balance = membership.balance
      initial_outstanding = membership.outstanding_bets_value
      
      winning_bet.undo_judgement!
      
      winning_bet.reload
      winning_bet.payout.should be_nil

      membership.reload
      membership.balance.should == initial_balance - payout
      membership.outstanding_bets_value.should == initial_outstanding + winning_bet.amount
    end

    it "for a losing bet, increments outstanding bets value" do
      payout = losing_bet.payout
      initial_balance = membership.balance
      initial_outstanding = membership.outstanding_bets_value
      
      losing_bet.undo_judgement!
      
      losing_bet.reload
      losing_bet.payout.should be_nil

      membership.reload
      membership.balance.should == initial_balance
      membership.outstanding_bets_value.should == initial_outstanding + losing_bet.amount
    end

    it "for an invalidated bet, it reinstates the bet" do
      invalidated_bet
      initial_balance = membership.balance
      initial_outstanding = membership.outstanding_bets_value
      initial_total = answer.bet_total

      invalidated_bet.undo_judgement!

      membership.balance.should == initial_balance - invalidated_bet.amount
      membership.outstanding_bets_value.should == initial_outstanding + invalidated_bet.amount
      answer.bet_total.should == initial_total + invalidated_bet.amount
    end
  end

end
