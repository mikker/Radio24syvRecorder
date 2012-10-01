require 'open-uri'

# Fetch playlist and set up the stream
stream = 'http://rrr.sz.xlcdn.com/?account=Radio24syv&file=ENC1_iOS_ABR&type=live&service=wowza&protocol=http&output=playlist.m3u8'
pl = open(stream).read.split("\n").grep(/http/)
stream = pl.last
tld = stream.split("/")
tld.pop
tld = tld.join("/") + "/"

# Name the file the current time
filename = "#{Time.now.to_s}.aac"
outputs_file = File.open(filename, "w+")
puts "Writing to #{filename} -- Stop with Ctrl+c"

# Catch the user stopping the process
stop = false
Signal.trap("INT") do
  stop = true
  puts "x"
  puts "Gracefully shutting down"
end

read_files = []

until stop # Until the user terminates the process
  print "|"
  
  # Find out if theres new audio bits in the stream playlist
  new_files = open(stream).read.split("\n").grep(/\.aac/).select { |f| !read_files.include? f }

  new_files.each do |audio|
    # Append the newly fetched audio bits to the result
    outputs_file << open("#{tld}/#{audio}").read
    print "."
  end
  read_files += new_files

  sleep 10 # wait 10 seconds, then do it again
end
