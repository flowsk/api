require "wordsmith"

if ARGV.size > 0
  print Wordsmith::Inflector.camelize(ARGV[0])
else
  print ""
end
