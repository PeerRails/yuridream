require "./lib/grabber"

# http://deepdream.pictures/imagejson

host = ARGV[0] || ""

site = Grab.new(host)
site.download_from_list
