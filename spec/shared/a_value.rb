shared_examples_for "a value" do

  def dup(val)
    Kernel.eval(val.to_ruby_literal)
  end
  
  it "should implement == correctly" do
    subject.should eq(dup(subject))
  end
  
  it "should implement eql? correctly" do
    {subject => true, dup(subject) => false}.size.should eq(1)
  end
  
  it "should implement class.parse / #to_s correctly" do
    if subject.class.respond_to?(:parse) && subject.respond_to?(:to_s)
      begin
        subject.class.parse(subject.to_s).should eq(subject)
      rescue
        t1 = subject.class.parse(subject.to_s)
        t2 = subject.class.parse(subject.to_s)
        t1.should eq(t2)
      end
    end
  end
  
  it "should implement Kernel.eval / to_ruby_literal correctly" do
    if subject.respond_to?(:to_ruby_literal)
      Kernel.eval(subject.to_ruby_literal).should eq(subject)
    end
  end

end