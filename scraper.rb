require 'scraperwiki'
require 'mechanize'

class Diputados

  # For each parliamentarian
  def per_person profile_url, uid, party, current_stand
    agent = Mechanize.new
    profile_page = agent.get(profile_url)
    profile_page.encoding = 'ISO-8859-1'
    profile = profile_page.at('#datos_contacto #votos').search('li')
    profile_img = profile_page.at('#contenido > article > img')[:src].gsub('./manager/.','http://congreso.gob.gt/manager')
    
    record = {
      "uid" => uid,
      "name" => (profile[0].inner_text).gsub('Nombre:','').squeeze(' ').strip,
      "party" => party,
      "current_stand" => current_stand,
      "email" => '', #(profile[1].inner_text).gsub('E-mail:','').squeeze(' ').strip, #Can't scrape this value, it's protected by Cloudflare http://www.cloudflare.com/email-protection
      "phone" => (profile[2].inner_text).gsub('Telefono de Oficina:','').strip,
      "address" => (profile[3].inner_text).gsub('Direccion de Oficina:','').strip,
      "url" => profile_url,
      "image" => profile_img
    }

    #puts '<---------------'
    #puts record
    #puts '--------------/>'
    ScraperWiki.save_sqlite(["uid"], record)
    puts "Adds new record " + record['name']
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

# Runner
if !(defined? Test::Unit::TestCase)
  Diputados.new.process
end
