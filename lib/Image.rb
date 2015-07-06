require "sqlite3"
require "sequel"

DB = Sequel.connect('sqlite://test.db')

class Image < Sequel::Model

end
