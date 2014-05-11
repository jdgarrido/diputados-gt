# This is a template for a Ruby scraper on Morph (https://morph.io)
# including some code snippets below that you should find helpful

require 'scraperwiki'
require 'mechanize'

class Diputados

  # For each parliamentarian
  def per_person profile_url, uid, party, current_stand
    agent = Mechanize.new
    profile_page = agent.get(profile_url)
    profile_img = profile_page.at('#contenido').search('article > img')
    profile = profile_page.at('#datos_contacto #votos').search('li')
    
    puts '+++++++'
    p profile_img.get('src')
    puts '+++++++'

    record = {
      "uid" => uid,
      "name" => (profile[0].inner_text).gsub('Nombre:','').squeeze(' ').strip,
      "party" => party,
      "current_stand" => current_stand,
      "email" => '', #(profile[1].inner_text).gsub('E-mail:','').squeeze(' ').strip, #Can't scrape this value, it's protected by Cloudflare http://www.cloudflare.com/email-protection
      "phone" => (profile[2].inner_text).gsub('Telefono de Oficina:','').strip,
      "address" => (profile[3].inner_text).gsub('Direccion de Oficina:','').strip,
      "url" => profile_url,
      "image" => 'http://congreso.gob.gt/manager' + profile_img.get('src')
    }

    #puts '<---------------'
    #puts record
    #puts '--------------/>'
    #ScraperWiki.save_sqlite(["uid"], record)
    #puts "Adds new record " + record['name']
  end

  # Obtains the profiles
  def process
    agent = Mechanize.new
    url = "http://www.congreso.gob.gt/legislaturas.php"

    # Read in a page
    page = agent.get(url)

    page.search('.dir_tabla tr').drop(1).each do |li|
      @uid = (li.search('td')[0]).inner_text
      @party = (li.search('td')[2]).inner_text
      @current_stand = (li.search('td')[3]).inner_text
      url = (li.search('td')[1]).at('a')["href"]
      per_person url, @uid, @party, @current_stand
      # exit # for fast testing, only the first parliamentarian
    end
  end
end

# # Find somehing on the page using css selectors
# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries. You can use whatever gems are installed
# on Morph for Ruby (https://github.com/openaustralia/morph-docker-ruby/blob/master/Gemfile) and all that matters
# is that your final data is written to an Sqlite database called data.sqlite in the current working directory which
# has at least a table called data.

# Runner
if !(defined? Test::Unit::TestCase)
  Diputados.new.process
end
