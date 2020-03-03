require 'gem2deb/rake/spectask'

Gem2Deb::Rake::RSpecTask.new do |spec|
  spec.pattern = FileList['./src/ruby/spec/**/*_spec.rb'] - FileList['./src/ruby/spec/generic/rpc_server_spec.rb','./src/ruby/spec/client_server_spec.rb','./src/ruby/spec/generic/client_stub_spec.rb','./src/ruby/spec/pb/package_with_underscore/checker_spec.rb']
end
