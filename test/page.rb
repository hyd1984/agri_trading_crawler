require_relative '../src/agri_item'
=begin
agri=Agri_table.new
agri.items.each_key do |key|
puts agri.items[key].id
page=Crawler.new(Date.new(2015,3,23),agri.items[key].id,agri.items[key].url)
page.crawling_data
web_page=page.page
#p web_page
report=Report.new(web_page,:vegetable)
if report.result?
p report.records
else
end
end
=end
=begin
page=Crawler.new(Date.new(2015,3,23),"IY",FLOWER_REQUEST_URL)
page.crawling_data
web_page=page.page
#p web_page
report=Report.new(web_page,:vegetable)
if report.result?
p report.records
else
end
=end

agri=Agri_table.new
item=Agri_item.new(Date.new(2015,3,23),agri.items["IY"])
reporter=Format_json.new
p item.gen_report(reporter)
