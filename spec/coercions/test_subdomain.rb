require 'spec_helper'
module Myrrha
  describe "Coercions#subdomain?" do
    let(:r){ Coercions.new }

    before(:all) do
      class Coercions
        public :subdomain?
      end
    end

    it 'works as expected with modules and classes' do
      r.subdomain?(Symbol, Object).should be_true
      r.subdomain?(Class, Module).should be_true
    end

    it 'works as expected with Symbol target domains' do
      r.subdomain?(:to_ruby_literal, :to_ruby_literal).should be_true
      r.subdomain?(:to_ruby_literal, :none).should be_false
    end

  end
end
