require 'spec_helper'
module Myrrha
  describe "Coercions#subdomain?" do
    let(:r){ Coercions.new }
    
    specify {
      r.subdomain?(Symbol, Object).should be_true
      r.subdomain?(Class, Module).should be_true
    }
    
  end
end