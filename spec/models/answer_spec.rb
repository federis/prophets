require 'spec_helper'

describe Answer do
  it "sets current prob to initial prob on creation" do
    a = FactoryGirl.build(:answer)
    a.current_probability.should be_nil
    a.save
    a.current_probability.should eq(a.initial_probability)
  end
end
