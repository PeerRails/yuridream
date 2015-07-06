require "sequel"

connect_url = ENV["YURIDREAMS_DB_URL"] || 'postgres://yuri:123456@localhost/yuridreams'

DB = Sequel.connect(connect_url)

class Image < Sequel::Model
  def validate
    super
    errors.add(:url, 'is already here') if Image[:url=>url]
  end
end
