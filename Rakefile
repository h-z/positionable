# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
    Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
    $stderr.puts e.message
    $stderr.puts "Run `bundle install` to install missing gems"
    exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
    gem.name = "positionable"
    gem.homepage = "http://github.com/h-z/positionable"
    gem.license = "MIT"
    gem.summary =  %Q{Positioning gem for positioning ActiveRecord models}
    gem.description = %Q{Help ActiveRecord to position gem}
    gem.email = "hz@muszaki.info"
    gem.authors = ["HEGEDUS Zoltan"]
    # dependencies defined in Gemfile
    gem.add_dependency "activerecord", ">= 0"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
end


task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
    version = File.exist?('VERSION') ? File.read('VERSION') : ""

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "positionable #{version}"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
end
