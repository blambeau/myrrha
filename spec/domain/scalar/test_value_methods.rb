require 'spec_helper'
module Myrrha
  module Domain
    class Scalar
      describe ValueMethods do

        let(:domain){
          Class.new{
            def self.component_names
              [:a, :b]
            end
            include ValueMethods
            attr_reader :a, :b
            def initialize(a, b)
              @a, @b = a, b
            end
          }
        }

        let(:object){ domain.new(1, 2) }

        describe "==" do
          subject{ object == other }

          context 'with itself' do
            let(:other){ object }
            it{ should be_true }
          end

          context 'with dupped' do
            let(:other){ object.dup }
            it{ should be_true }
          end

          context 'with equivalent' do
            let(:other){ domain.new(1, 2) }
            it{ should be_true }
          end

          context 'with equivalent of a subclass' do
            let(:other){ Class.new(domain).new(1, 2) }
            it{ should be_true }
          end

          context 'with non equivalent' do
            let(:other){ domain.new(1, 3) }
            it{ should be_false }
          end

          context 'with other class' do
            let(:other){ self }
            it{ should be_false }
          end
        end

        describe "eql?" do
          subject{ object.eql?(other) }

          context 'with itself' do
            let(:other){ object }
            it{ should be_true }
          end

          context 'with dupped' do
            let(:other){ object.dup }
            it{ should be_true }
          end

          context 'with equivalent' do
            let(:other){ domain.new(1, 2) }
            it{ should be_true }
          end

          context 'with equivalent of a subclass' do
            let(:other){ Class.new(domain).new(1, 2) }
            it{ should be_false }
          end

          context 'with non equivalent' do
            let(:other){ domain.new(1, 3) }
            it{ should be_false }
          end

          context 'with other class' do
            let(:other){ self }
            it{ should be_false }
          end
        end

        describe "hash" do
          subject{ object.hash }

          it 'should be consistent with equal' do
            subject.should eq(domain.new(1,2).hash)
          end
        end

      end
    end
  end
end