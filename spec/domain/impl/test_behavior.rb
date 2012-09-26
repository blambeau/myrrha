require 'spec_helper'
module Myrrha
  describe Domain, 'when included' do

    let(:point){
      Class.new{
        include Myrrha::Domain::Impl.new([:r, :theta])

        coercions do |c|
          c.upon(NilClass)     {|v,t| new(0.0,0.0)                   }
          c.coercion(String)   {|v,t| new(*v.split(',').map(&:to_f)) }
          c.coercion(TrueClass){|v,t| throw :nextrule                }
          c.fallback(TrueClass){|v,t| new(1.0, 1.0)                  }
        end
      }
    }

    let(:origin){ point.new(0.0, 0.0) }
    let(:oneone){ point.new(1.0, 1.0) }

    it 'installs the domain component names' do
      point.component_names.should eq([:r, :theta])
    end

    it 'installs the component readers' do
      origin.r.should eq(0.0)
      origin.theta.should eq(0.0)
    end

    it 'has coercions properly installed' do
      point.coercions.main_target_domain.should eq(point)
    end

    it 'supports expected coercions' do
      point.coerce(nil).should eq(origin)
      point.coerce(true).should eq(oneone)
      point.coerce("2.0,3.0").should eq(point.new(2.0, 3.0))
    end

  end
end