module Myrrha
  module Domain
    describe Native, 'when used by extension' do

      class NegInt < Integer
        extend Myrrha::Domain::Native

        def self.predicate
          @predicate ||= lambda{|i| i<0}
        end

      end

      specify("#name") {
        NegInt.name.should eq("Myrrha::Domain::NegInt")
      }

      specify("#new") {
        NegInt.new(-12).should eq(-12)
        lambda {
          NegInt.new(12)
        }.should raise_error(ArgumentError)
      }

      specify("#superclass"){
        NegInt.superclass.should eql(Integer)
      }

      specify("#superdomain_of?"){
        NegInt.superdomain_of?(Object).should be_false
        NegInt.superdomain_of?(Integer).should be_false
      }

      it "should be usable in a case" do
        [-12, 12].map{|i|
          case i
          when NegInt
            :negint
          when Integer
            :integer
          end
        }.should eq([:negint, :integer])
      end

    end
  end
end