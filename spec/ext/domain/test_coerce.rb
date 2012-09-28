require 'spec_helper'
describe Domain, "coerce" do

  class Point
    extend Domain::Scalar.new(:x, :y)

    coercions do |c|
      c.coercion(String){|v,_| Point.new(*v.split(',').map(&:to_i)) }
      c.coercion(Array) {|v,_| Point.new(*v) }
    end

    EMPTY = Point.new(0, 0)
  end

  let(:point_1_1){ Point.new(1, 1) }
  let(:point_2_2){ Point.new(2, 2) }

  it 'should delegate to coercions' do
    Point.coerce("1, 1").should eq(point_1_1)
  end

  it 'raises a TypeError if something goes wrong' do
    lambda{
      Point.coerce(12)
    }.should raise_error(TypeError, /Can't convert `12`/)
  end

  describe "the [] alias" do

    it 'delegates to coerce when one argument' do
      Point["1,1"].should eq(point_1_1)
    end

    it 'supports Array' do
      Point[[2, 2]].should eq(point_2_2)
    end

    it 'supports Array literals' do
      Point[2, 2].should eq(point_2_2)
    end

    it 'supports empty Array literals' do
      Point[].should be(Point::EMPTY)
    end
  end

end
