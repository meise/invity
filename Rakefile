# encoding: utf-8
=begin
Copyright Daniel Meißner <dm@3st.be>, 2011

This file is part of Invity to send email notifications of upcoming Freifunk events.

This script is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This Script is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Invity. If not, see <http://www.gnu.org/licenses/>.
=end

require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rubygems/package_task'
require_relative 'lib/invity/version'

spec = Gem::Specification.new do |s|
  s.name = "invity"
  s.version = Invity::VERSION
  s.date = Time.now.strftime("%Y-%m-%d")

  s.summary = "write summary" # TODO: write summary
  s.description = "desctiption" # TODO: write description

  s.author = "Daniel Meißner"
  s.email = "dm@3st.be"
  s.homepage = "https://github.com/meise/invity"

  s.files = FileList['[A-Z]*', '{bin,lib}/**/*']
  s.test_files = FileList["test/**/*"]
  s.executables = %w[invity]
  s.require_path = "lib"

  s.add_dependency "rainbow"
  s.add_dependency "mechanize"

  s.add_development_dependency "minitest"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"

  s.required_ruby_version = '>= 1.9.2'
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

module Rake
  class TestTask
    # use our custom test loader
    def rake_loader
      'test/rake_test_loader.rb'
    end
  end
end

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.libs << 'test/storage'
  test.pattern = 'test/**/*_test.rb'
  test.warning = false
end


task :compile do
  # nothing to do
end

task :cleanup do
  # nothing to do
end

task :default => [:clobber, :test, :compile, :gem, :cleanup]
