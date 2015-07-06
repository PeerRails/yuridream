require 'nokogiri'
require 'uri'
require 'open-uri'
require "sequel"
require "json"
#https://storage.googleapis.com/dreamscape-bucket1/output/a0244a11-ad52-4610-8fc4-f2322f4b4659.jpg
class Grab

  def initialize(url=nil, db=nil, path="images")
    @path = path
    @url = check_url(url)
    check_db
    list_all
  end

  def list_all
    json = JSON.parse(open(@url).read)
    @links = json.map {|j| "https://storage.googleapis.com/dreamscape-bucket1/#{j["src"]}"}
  end

  def check_db
    connect = ENV["YURIDREAMS_DB_URL"] || 'postgres://yuri:123456@localhost/yuridreams'
    @db = Sequel.connect(connect)
    @db.run <<-SQL
      CREATE TABLE IF NOT EXISTS images (

        id serial PRIMARY KEY,
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
    cuerl = @db[:images].where(url: url).all
    @db.run "insert into images (url, path, name) values ( \'#{url}\', \'#{path}\', \'#{path.split("/").last.split(".").first}\' )" if cuerl.empty?
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