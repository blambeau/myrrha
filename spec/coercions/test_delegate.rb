require 'spec_helper'
module Myrrha
  describe Coercions, "delegate" do
    let(:rules){ Coercions.new }

    context 'without block' do
      before{ rules.delegate(:to_a) }

      it "should delegate if the method exists" do
        rules.apply([1, 2, 3]).should eq([1, 2, 3])
      end

      it "should not delegate if the method does not exist" do
        lambda{
          rules.apply(self)
        }.should raise_error(Myrrha::Error)
      end
    end

    context 'with a block' do
      before{ rules.delegate(:to_a){|v,_| v.to_a.reverse} }

      it "should delegate if the method exists" do
        rules.apply([1, 2, 3]).should eq([3,2,1])
      end

      it "should not delegate if the method does not exist" do
        lambda{
          rules.apply(self)
        }.should raise_error(Myrrha::Error)
      end
    end

  end
end
