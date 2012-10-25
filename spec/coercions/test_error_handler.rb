require 'spec_helper'
module Myrrha
  describe Coercions, "error_handler" do

    subject{ rules.apply(12, Float) }

    context 'with the default error handler' do
      let(:rules){ 
        Coercions.new
      }

      it "raises a Myrrha::Error when coercion fails" do
        lambda{
          subject
        }.should raise_error(Myrrha::Error, /Unable to coerce `12` to Float/)
      end
    end

    context 'with a user-defined error handler' do
      let(:rules){ 
        Coercions.new{|c|
          c.error_handler = lambda{|*args| args }
        }
      }

      it "calls the handler when coercion fails" do
        subject.should eq([12, Float, nil])
      end
    end

  end
end
