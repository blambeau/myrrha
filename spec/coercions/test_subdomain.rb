require 'spec_helper'
module Myrrha
  describe "Coercions#subdomain?" do
    let(:graph){ Coercions.new }
    
    specify {
      graph.subdomain?(Symbol, Object).should be_true
    }
      
  end
end