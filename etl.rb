require_relative 'extractor'
require_relative 'loader'

puts "Starting at #{Time.now}"
extractor = Extractor.new()
extractor.extract_transform_and_load
puts "Ended at #{Time.now}"
