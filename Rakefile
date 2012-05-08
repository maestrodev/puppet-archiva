require 'bundler'
Bundler.require(:rake)

require 'rake/clean'
require 'puppet-lint/tasks/puppet-lint'
require 'rspec/core/rake_task'

CLEAN.include('pkg', 'doc')

PuppetLint.configuration.send("disable_80chars")

desc "Check syntax."
task :syntax do |t, args|
  begin
    require 'puppet/face'
  rescue LoadError
    fail 'Cannot load puppet/face, are you sure you have Puppet 2.7?'
  end

  def validate_manifest(file)
    Puppet::Face[:parser, '0.0.1'].validate(file)
  rescue Puppet::Error => error
    puts error.message
  end

  files = File.join("**", "*.pp")
  Dir.glob(files).each do|manifest|
    puts "Evaluating syntax for #{manifest}"
    validate_manifest manifest
 end
end

desc "Run RSpec tests."
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--format", "doc", "--color"]
  t.pattern = 'spec/*/*_spec.rb'
end

namespace "spec" do

  desc "Run modules RSpec tests."
  task :modules do |t, args|
    FileList['modules/*/Rakefile'].each do |r|
      puts "Running #{r}"
      sh("cd #{File.dirname(r)} && rake spec")
    end
  end

  desc "Run all RSpec tests, including submodules."
  task :all => [:spec, :modules]
end

desc "Generate documentation."
task :doc do |t, args|
  puts "Generating puppet documentation..."
  work_dir = File.dirname(__FILE__)
  sh %{puppet doc \
    --outputdir #{work_dir}/doc \
    --mode rdoc \
    --manifestdir #{work_dir}/manifests \
    --modulepath #{work_dir}/modules \
    --manifest #{work_dir}/site.pp}

  if File.exists? "#{work_dir}/doc/files/#{work_dir}/modules"
    FileUtils.mv "#{work_dir}/doc/files/#{work_dir}", "#{work_dir}/doc/files"
  end
  Dir.glob('doc/**/*.*').each do |file|
    if File.file? "#{file}"
      sh %{sed -i "" "s@#{work_dir}/@/@g" "#{file}"}
    end
  end
end

task :default => [:spec,:lint]
