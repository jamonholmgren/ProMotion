require 'motion-require'

Motion::Require.all(Dir.glob(File.expand_path('../ProMotion/**/*.rb', __FILE__)))