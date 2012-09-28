require 'spec_helper'
describe Domain, "coerce" do

  let(:domain){ Domain.scalar(:x, :y) }

  let(:expected){ domain.new(1, 2) }

  before do
    domain.coercions do |c|
      c.coercion(String){|v,_| expected       }
      c.coercion(Array) {|v,_| domain.new(*v) }
    end
  end

  it 'should delegate to coercions' do
    domain.coerce("blah").should be(expected)
  end

  it 'raises a TypeError if something goes wrong' do
    lambda{
      domain.coerce(12)
    }.should raise_error(TypeError, /Can't convert `12`/)
  end

  describe "the [] alias" do

    it 'delegates to coerce when one argument' do
      domain["12"].should be(expected)
    end

    it 'supports Array literals' do
      domain[1, 3].should eq(domain.new(1, 3))
    end
  end

end
