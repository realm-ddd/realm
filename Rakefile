module ReleaseHelpers
  def in_release_dir?
    File.basename(File.dirname(__FILE__)) == "realm-release"
  end
end
include ReleaseHelpers


if in_release_dir?
  require "bundler/gem_tasks"
else
  desc "Realese not possible from this directory"
  task :release do
    puts "Switch to a release directory before attempting to release"
    exit 1
  end
end
