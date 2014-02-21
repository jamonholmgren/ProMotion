require 'motion-require'

files = [
  "core"
].map { |file| File.expand_path(File.join(File.dirname(__FILE__), "/ProMotion/", "#{file}.rb")) }

Motion::Require.all(files)
