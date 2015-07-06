require 'nokogiri'
require 'uri'
require 'open-uri'
require "sqlite3"
require "json"

class Grab

  def initialize(url=nil, db=nil, path="images")
    @path = path
    @url = check_url(url)
    @db = db || SQLite3::Database.new("test.db")
    list_all
    check_db
  end

  def list_all
    json = JSON.parse(open(@url).read).to_s
    @links = URI.extract json
  end

  def check_db
    rows = @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS images (

        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT,
        path TEXT,
        name TEXT
      );
    SQL
  end

  def download_from_list(list=@links)
    list.each do |url|
      path = "#{@path}/#{url.split("/").last}"
      open(path, 'wb') do |file|
        file << open(url).read
      end
      insert_to_db(url, path)
    end    
  end

  def insert_to_db(url, path)
    count = 0
    @db.execute( "select * from images where url = \"#{url}\"" ) do |row|
      count += 1
    end
    @db.execute "insert into images (url, path, name) values ( \"#{url}\", \"#{path}\", \"#{path.split("/").last}\" )" if count == 0
  end

  def links
    @links
  end

  def check_url(url)
    if url.empty?
      abort "No url provided"
    end
    if !(url =~ /\A#{URI::regexp}\z/)
      abort "bad url"
    end  
    url
  end
  
end