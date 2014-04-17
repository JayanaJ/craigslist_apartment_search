class Apartment < ActiveRecord::Base
  attr_accessible :bedrooms, :href, :location, :price, :description, :image_url
  
  LOCATIONS = ["Carroll Gardens", "Cobble Hill / Carroll Gardens", 
    "Cobble Hill", "CARROLL GARDENS", "Carroll Gardents", 
    "Brooklyn Heights - Atlantic Ave & Hicks St", "BOERUM HILL", 
    "Boerum Hill", "brooklyn heights"] 
  
  def self.good
    Apartment.where(:location => LOCATIONS)
  end

  def formatted_url
    "http://newyork.craigslist.org/#{self.href}"
  end
end
