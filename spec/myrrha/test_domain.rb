require 'spec_helper'
describe "Myrrha.domain" do
  
  specify "with only a class" do
    Myrrha.domain(Integer).should be_a(Myrrha::Domain::ClassDomain)
    Myrrha.domain(Integer).clazz.should eq(Integer)
  end
  
  specify "with only a name and a block" do
    dom = Myrrha.domain(:Name){|v| v == :hello}
    dom.should be_a(Myrrha::Domain::PredicateDomain)
    dom.is_value?(:hello).should be_true
    dom.is_value?(:world).should be_false
  end
  
  specify "with a name, superdomain and block" do
    v1 = Myrrha.domain(:Name){|v| v == :hello}
    v2 = Myrrha.domain(:SubName, v1){|v| v == :hello2}
    v2.subdomain_of?(v1).should be_true
    v2.is_value?(:hello).should be_true
    v2.is_value?(:hello2).should be_true
  end
  
end