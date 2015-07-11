require 'nokogiri'
require 'uri'
require 'open-uri'
require "sequel"
require "json"
require 'digest'
require 'yajl'
require 'json-compare'
require './lib/ZipFileGenerator'
#https://storage.googleapis.com/dreamscape-bucket1/output/a0244a11-ad52-4610-8fc4-f2322f4b4659.jpg
class Grab

  def initialize(url=nil, db=nil, path="images")
    @path = path
    @url = check_url(url)
    @last = nil
    @current = "#{Dir.pwd}/json/last.json"
    check_db
    #list_all
    @links = get_links
  end

  def dl_json
    if File.exists?(@current)
      @last = "#{Dir.pwd}/json/#{DateTime.now.strftime("%Y%m%d%H%M%S")}.json"
      File.rename(@current, @last)
    end
    open(@current, 'wb') do |file|
      file << open(@url).read
    end
  end

  def get_links
    dl_json
    res = []
    src = []
    unless @last.nil?
      json1, json2 = Yajl::Parser.parse(File.new(@last, "r")), Yajl::Parser.parse(File.new(@current, "r"))
      res = JsonCompare.get_diff(json1,json2) 
    else
      res = Yajl::Parser.parse(File.new(@current, "r"))
      src = res.map {|j| "https://storage.googleapis.com/dreamscape-bucket1/"+j["src"]}
    end

    if res.class == Hash
      res.each do |j|
        j[1].each do |k,v|
          src.push "https://storage.googleapis.com/dreamscape-bucket1/"+v["src"] unless v["src"].nil? 
        end 
      end
    end 
    return src
  end

  def check_db
    connect = ENV["YURIDREAMS_DB_URL"] || 'postgres://yuri:123456@localhost/yuridreams'
    @db = Sequel.connect(connect)
    @db.run <<-SQL
      CREATE TABLE IF NOT EXISTS images (

        id serial PRIMARY KEY,
        url TEXT,
        path TEXT,
        name TEXT,
        md5 TEXT
      );
    SQL
  end

  def download_from_list(list=@links)
    unless list.empty?
      list.each do |url|
        cuerl = @db[:images].where(url: url).all
        if cuerl.empty?
          path = "#{@path}/#{url.split("/").last}"
          open(path, 'wb') do |file|
            file << open(url).read
          end
          md5 = Digest::MD5.file(path).hexdigest
          mdrl = @db[:images].where(md5: md5).all 
          if  mdrl.empty?
            insert_to_db(url, path, md5)
          end
        end
      end
    end
    #make_zip    
  end

  def make_zip
    folder = "#{Dir.pwd}/images"
    count = Dir[File.join(folder, '**', '*')].count { |file| File.file?(file) }
    azip = "#{Dir.pwd}/archives/yuridream-last.zip"
    zf = ZipFileGenerator.new(folder, azip)
    zf.write()
    FileUtils.chown 'www-data', 'www-data', azip
  end

  def insert_to_db(url, path, md5)
    @db.run "insert into images (url, path, name, md5) values ( \'#{url}\', \'#{path}\', \'#{path.split("/").last.split(".").first}\', \'#{md5}\' )"
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
