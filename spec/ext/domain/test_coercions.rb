require 'spec_helper'
describe Domain, "coercions" do

  let(:domain){ Domain.scalar(:x, :y) }

  context 'without a block' do
    subject{ domain.coercions }

    it{ should be_a(Myrrha::Coercions) }

    it 'should have the main target domain defined' do
      subject.main_target_domain.should eq(domain)
    end
  end

  context 'with a block' do
    subject{ domain.coercions{|c| @seen=c} }

    it 'should yield the coercions' do
      subject
      @seen.should eq(subject)
    end
  end

end
