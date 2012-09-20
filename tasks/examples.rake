task :examples => :spec_test do
  lib = File.expand_path('../../lib', __FILE__)
  dir = File.expand_path('../../examples', __FILE__)
  Dir["#{dir}/*.rb"].each do |file|
    str = `ruby -I#{lib} #{file}`
    if $?.exitstatus == 0
      print '.'
    else
      print '*'
      raise "Example #{file} failed." 
    end
  end
  puts
end
task :spec => :examples
task :test => :examples