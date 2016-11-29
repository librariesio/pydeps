require './pydeps'

pd = Pydeps::Resolver.new('fh-fablib', '0.1.0')
puts "#{pd.name} - #{pd.find_dependencies}"
pd = Pydeps::Resolver.new('urpc', '0.0.4')
puts "#{pd.name} - #{pd.find_dependencies.join(', ')}"
pd = Pydeps::Resolver.new('cryptography', '1.2')
puts "#{pd.name} - #{pd.find_dependencies.join(', ')}"
