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
    
  end
end
