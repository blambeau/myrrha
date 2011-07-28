task :examples do
  dir = File.expand_path('../../examples', __FILE__)
  Dir["#{dir}/*.rb"].each do |file|
    str = `ruby #{file}`
    if $?.exitstatus == 0
      print '.'
    else
      print '*'
      raise "Example #{file} failed." 
    end
  end
end
task :spec => :examples
task :test => :examples