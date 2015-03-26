require 'restclient'
require 'nokogiri'
require 'date'
require 'csv'
require 'json'
VEGETABLE_REQUEST_URL = "http://amis.afa.gov.tw/v-asp/v101r.asp"
FRUIT_REQUEST_URL = "http://amis.afa.gov.tw/t-asp/v103r.asp"
FLOWER_REQUEST_URL="http://amis.afa.gov.tw/l-asp/v101r.asp"
class Http_argument
	attr_reader :date,:item,:argument
	def initialize(date,item)
		year=(date.year-1911).to_s
		mon="%02d" % date.mon
		day="%02d" % date.day
		mpno=item.split(' ')[0]
		mpnoname=item.split(' ')[1]
		@argument={'mhidden1'=>'1','myy'=>year,'mmm'=>mon,'mdd'=>day,'mpno'=>mpno,'mpnoname'=>''}
	end
end
class Report
	attr_reader :records
	def initialize(page,type)
		@page=page
		@records=[]
		@type=type
		if result?
		table=get_lower_table()
		rows=get_lower_rows(table)
		rows.each do |row|
			columns=get_lower_columns(row)
			record=[]
			columns.each do |column|
				record<<column.text.chomp.gsub(/[[:space:]]/, '').strip
			end
			@records<<record
		end
		else
			p "查無結果!!"
		end
	end
	def result?
		@page.xpath("//p")[0].text.chomp.gsub(/[[:space:]]/, '').strip!="查無結果!"
	end
	def get_lower_table()
		@page.css('table')[1]
	end
	def get_lower_rows(table)
		table.css('tr')
	end
	def get_lower_columns(row)
		row.css('td')
	end
	def output
		arr=[]
		@records.each do |row|
			arr<<row.output.values.to_csv
		end
		arr
	end
end
class Crawler
	attr_reader :date,:item,:page
        def initialize(date,item,url)
		@date=date
		@item=item
		@page=nil
		@url=url
		@argument=Http_argument.new(@date,@item).argument
	end
	def crawling_data
		@page=get_page(@argument,@url)
	end
	def get_page(argument,url)
		        Nokogiri::HTML(RestClient.post(url,argument).body)
	end

end
class Agri_argument
	attr_reader :id,:url,:name
	def initialize(id,name,url)
		@id=id
		@url=url
		@name=name
	end
	def to_s
		id+" "+url
	end
end
class Agri_table
	attr_reader :items
	def initialize()
		@items=Hash.new(0)
		File.open("../agri_data/vegetable.txt","r") do |f|
			f.each_line do |line|
				key=line.split(' ')[1]
				value=line.split(' ')[0]
				items[key]=Agri_argument.new(value,key,VEGETABLE_REQUEST_URL)
			end
		end	
		File.open("../agri_data/flowers.txt","r") do |f|
			f.each_line do |line|
				name=line.split(' ')[1]
				id=line.split(' ')[0]
				items[id]=Agri_argument.new(id,name,FLOWER_REQUEST_URL)
			end
		end	
	end

end
class Format_json
	attr_reader :output
	def initialize()
		@output=Hash.new(0)
		@date=0
		@name=0
		@id=0

	end
	def generate(date,item,data)
		@date=date
		@name=item.name
		@id=item.id
		output['date']=@date
		output['name']=@name
		output['id']=@id
		output['description']=data[0]
		output['content']=data[1..-1]
	        JSON.generate(output)
	end
end
class Agri_item
	attr_reader :date ,:item, :crawlers
	def initialize(date,item)
		@date=date
		@item=item
		page=Crawler.new(@date,@item.id,@item.url)
		page.crawling_data
		web_page=page.page
		report=Report.new(web_page,:vegetable)
		if report.result?
			@data=report.records
		else
			puts "查無結果!"
		end
	end
	def gen_report(reporter)
		reporter.generate(@date,@item,@data)
	end
end
