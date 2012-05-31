guard 'rspec', :version => 2 do
  require 'growl' rescue nil
  watch(/^spec\/(.*)_spec\.rb/)
  watch(/^lib\/(.*)\.rb/)           { |m| "spec/#{m[1]}_spec.rb" }
  watch(/^spec\/spec_helper\.rb/)   { "spec" }
  watch(/^spec\/fixtures\/(.*)/)    { "spec" }
end