VALUES.each do |value|
  describe "#{value} (#{value.class})" do
    subject{ value }
    it_should_behave_like "a value" 
  end
end