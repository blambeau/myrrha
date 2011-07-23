require 'spec_helper'
module Myrrha
  class Domain
    describe ClassDomain do
      
      specify "name" do
        ClassDomain.new(Integer).name.should eq(:Integer)
      end
      
      specify "belongs_to?" do
        ClassDomain.new(Integer).belongs_to?(12).should be_true
        ClassDomain.new(Integer).belongs_to?(12.0).should be_false
        ClassDomain.new(Numeric).belongs_to?(12.0).should be_true
      end
      
      specify "subdomain_of?" do
        int = ClassDomain.new(Integer)
        num = ClassDomain.new(Numeric)
        int.subdomain_of?(int).should be_true
        int.subdomain_of?(num).should be_true
        num.subdomain_of?(int).should be_false
      end
      
    end
  end
end