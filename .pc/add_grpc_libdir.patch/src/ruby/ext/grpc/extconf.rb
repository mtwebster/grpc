# Copyright 2015 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'etc'
require 'mkmf'

windows = RUBY_PLATFORM =~ /mingw|mswin/
bsd = RUBY_PLATFORM =~ /bsd/

grpc_root = File.expand_path(File.join(File.dirname(__FILE__), '../../../..'))

grpc_config = ENV['GRPC_CONFIG'] || 'opt'

ENV['MACOSX_DEPLOYMENT_TARGET'] = '10.7'

ENV['AR'] = RbConfig::CONFIG['AR'] + ' rcs'
ENV['CC'] = RbConfig::CONFIG['CC']
ENV['CXX'] = RbConfig::CONFIG['CXX']
ENV['LD'] = ENV['CC']

ENV['AR'] = 'libtool -o' if RUBY_PLATFORM =~ /darwin/

ENV['EMBED_OPENSSL'] = 'false'
ENV['EMBED_ZLIB'] = 'false'
ENV['EMBED_CARES'] = 'false'
ENV['ARCH_FLAGS'] = RbConfig::CONFIG['ARCH_FLAG']
ENV['ARCH_FLAGS'] = '-arch i386 -arch x86_64' if RUBY_PLATFORM =~ /darwin/
ENV['CPPFLAGS'] = '-DGPR_BACKWARDS_COMPATIBILITY_MODE'

output_dir = File.expand_path(RbConfig::CONFIG['topdir'])
grpc_lib_dir = File.join(output_dir, 'libs', grpc_config)
ENV['BUILDDIR'] = output_dir

$CFLAGS << ' -I' + File.join(grpc_root, 'include')
$LDFLAGS << ' ' + '-Wl,-wrap,memcpy -lgrpc' unless windows
if grpc_config == 'gcov'
  $CFLAGS << ' -O0 -fprofile-arcs -ftest-coverage'
  $LDFLAGS << ' -fprofile-arcs -ftest-coverage -rdynamic'
end

if grpc_config == 'dbg'
  $CFLAGS << ' -O0 -ggdb3'
end

$LDFLAGS << ' -Wl,-wrap,memcpy' if RUBY_PLATFORM =~ /linux/
$LDFLAGS << ' -static' if windows

$CFLAGS << ' -std=c99 '
$CFLAGS << ' -Wall '
$CFLAGS << ' -Wextra '
$CFLAGS << ' -pedantic '

output = File.join('grpc', 'grpc_c')
puts 'Generating Makefile for ' + output
create_makefile(output)

strip_tool = RbConfig::CONFIG['STRIP']
strip_tool = 'strip -x' if RUBY_PLATFORM =~ /darwin/

if grpc_config == 'opt'
  File.open('Makefile.new', 'w') do |o|
    o.puts 'hijack: all strip'
    o.puts
    File.foreach('Makefile') do |i|
      o.puts i
    end
    o.puts
    o.puts 'strip: $(DLLIB)'
    o.puts "\t$(ECHO) Stripping $(DLLIB)"
    o.puts "\t$(Q) #{strip_tool} $(DLLIB)"
  end
  File.rename('Makefile.new', 'Makefile')
end
