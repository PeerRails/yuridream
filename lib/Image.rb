require "sequel"

DB = Sequel.connect(ENV["YURIDREAMS_DB_URL"])

class Image < Sequel::Model

end
