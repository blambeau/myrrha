require 'spec_helper'
module Myrrha
  module Domain
    describe ".impl" do

      it 'returns a Module' do
        Domain.impl(:x, :y).should be_a(Module)
      end

    end
  end
end
