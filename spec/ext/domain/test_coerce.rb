require 'spec_helper'
describe Domain, "coerce" do

  let(:domain){ Domain.scalar(:x, :y) }

  before do
    domain.coercions do |c|
      c.coercion(String){|v,_| domain.new(1,2) }
    end
  end

  it 'should delegate to coercions' do
    domain.coerce("blah").should eq(domain.new(1,2))
  end

end
