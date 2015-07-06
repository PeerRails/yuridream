require "./lib/grabber"

# http://130.211.73.158/static/images.json

host = ARGV[0] || ""

site = Grab.new(host)
site.download_from_list
