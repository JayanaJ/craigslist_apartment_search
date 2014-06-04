require 'open-uri'
require 'pry'
require 'pry-nav'
require 'nokogiri'

class Search
  URL = "http://newyork.craigslist.org/search/aap/brk?s="
  URL2 = "catAbb=aap&query=&minAsk="
  URL3 = "&maxAsk="
  URL4 = "&bedrooms=2&housing_type=1&excats="

  attr_accessor :min, :max, :links

  def initialize(min = 2000, max = 3000)
    @min = min
    @max = max
    @links = []
  end

  def url(index)
    URL + paginate(index) + URL2 + min.to_s + URL3 + max.to_s + URL4
  end

  def paginate(index)
    (index * 100).to_s
  end

  def run
    (1..25).each do |index|
      doc = Nokogiri::HTML(open(url(index)))
      get_links(doc)
      puts "saved links #{index}-#{index * 100}"
    end
  end

  def get_links(doc)
    doc.css(".row .pl").each_with_index do |node, index|
      bedrooms = parse_bedroom(index, doc)
      next if bedrooms.to_i > 2
      next if Apartment.exists?(:description => parse_description(node))
      href = parse_href(index,node)
      image_url = get_image(href)
      next if image_exists?(image_url, links)
      links << {:href => href,
       :price => parse_price(index, doc),
       :location => parse_location(index, doc),
       :bedrooms => bedrooms,
       :description => parse_description(node),
       :image_url => image_url
     }
    end
  end

  def image_exists?(image_url, links)
    links.collect {|link| link[:image_url]}.include?(image_url)
  end

  def format_url(href)
    "http://newyork.craigslist.org#{href}"
  end

  def get_image(href)
    doc = Nokogiri::HTML(open(format_url(href)))
    parse_image_url(doc)
  end

  def parse_image_url(doc)
    image_url = ""
    if doc.css("#ci").present?
      image_url = doc.css("#ci").first.children[1].attributes["src"].value
    end
  end

  def parse_description(node)
    node.children[1].children.text
  end

  def parse_href(index, node)
    node.children[1].attributes["href"].value
  end

  def parse_price(index, doc)
    doc.css(".row .l2")[index].children[1].children.first.text
  end

  def parse_location(index, doc)
    remove_crud(doc.css(".row .l2")[index].children[3].children[1].children.text)
  end

  def remove_crud(location)
    location.gsub("(", "").gsub(")","").strip
  end

  def parse_bedroom(index, doc)
    # node.children[7].children[2].text.match(/\d\w{2}/)[0]
    doc.css(".row .l2")[index].children[2].text.match(/\d\w{2}/)[0]
  end

  def persist
    links.each do |link|
      Apartment.create(link)
    end
  end

end

search = Search.new
search.run