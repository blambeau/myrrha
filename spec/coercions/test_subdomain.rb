require 'spec_helper'
module Myrrha
  describe "Coercions#subdomain?" do
    let(:r){ Coercions.new }

    before(:all) do
      class Coercions
        public :subdomain?
      end
    end

    specify {
      r.subdomain?(Symbol, Object).should be_true
      r.subdomain?(Class, Module).should be_true
    }

  end
end
