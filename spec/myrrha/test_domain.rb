require 'spec_helper'
module Myrrha
  describe "#domain" do
    
    describe "with only a predicate" do
      subject{ Myrrha.domain{|s| s == 12} }
      specify{ 
        subject.should be_a(Class) 
        subject.superclass.should eq(Object)
        (subject === 12).should be_true
        (subject === 13).should be_false
      }
    end
    
    describe "with a super domain and a predicate" do
      subject{ Myrrha.domain(Integer){|i| i > 0} }
      specify{ 
        subject.should be_a(Class) 
        subject.superclass.should eq(Integer)
        (subject === 12).should be_true
        (subject === 0).should be_false
      }
    end
    
  end
end
