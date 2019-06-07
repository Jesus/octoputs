require 'bundler/setup'
require 'rake/extensiontask'
require 'bundler/gem_tasks'

file 'ext/puma_http11/http11_parser.c' => ['ext/puma_http11/http11_parser.rl'] do |t|
  begin
    sh "ragel #{t.prerequisites.last} -C -G2 -I ext/puma_http11 -o #{t.name}"
  rescue
    fail "Could not build wrapper using Ragel (it failed or not installed?)"
  end
end
task :ragel => ['ext/puma_http11/http11_parser.c']

Rake::ExtensionTask.new("puma_http11") do |ext|
  # place extension inside namespace
  ext.lib_dir = "lib/octoputs"
end

task :test => [:compile]
task :default => [:test]
