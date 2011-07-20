require 'spec_helper'
module Myrrha
  describe "Graph#subdomain?" do
    let(:graph){ Graph.new }
    
    specify {
      graph.subdomain?(Symbol, Object).should be_true
    }
      
  end
end