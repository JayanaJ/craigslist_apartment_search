namespace :db do
  desc "clear all apartments"
  task :populate => :environment do
    search = Search.new
    search.run
    search.persist
  end
end