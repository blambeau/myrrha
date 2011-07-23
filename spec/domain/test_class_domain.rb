require 'spec_helper'
module Myrrha
  class Domain
    describe ClassDomain do
      
      specify "name" do
        ClassDomain.new(Integer).name.should eq(:Integer)
      end
      
      specify "is_value?" do
        ClassDomain.new(Integer).is_value?(12).should be_true
        ClassDomain.new(Integer).is_value?(12.0).should be_false
        ClassDomain.new(Numeric).is_value?(12.0).should be_true
      end
      
      specify "===" do
        ClassDomain.new(Integer).===(12).should be_true
        ClassDomain.new(Integer).===(:hello).should be_false
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