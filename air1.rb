#!/usr/bin/env ruby
# ©2014 Jean-Hugues Roy. GNU GPL v3.

require "nokogiri"
require "open-uri"

listeURL = []
appTotal = 0

iMin = 0
iMax = 1000

(iMin..iMax).step(5) do |n|

	min = n
	max = n + 4

	appFourchette = 0
	
	if max > iMax
		url1 = "https://fr.airbnb.ca/s/Quebec--Canada?price_min=" + min.to_s
	else
		url1 = "https://fr.airbnb.ca/s/Quebec--Canada?price_min=" + min.to_s + "&price_max=" + max.to_s
	end

	page1 = Nokogiri::HTML(open(url1, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))

	nb = page1.css("h1.results-count").text
	nb = nb[0..2].to_i

	if max > iMax
		puts "Il devrait y avoir " + nb.to_s + " apparts de plus de " + min.to_s + "$"
	else
		puts "Il devrait y avoir " + nb.to_s + " apparts entre " + min.to_s + "$ et " + max.to_s + "$"
	end
	
	nbPages = nb/18 + 1
	puts "Il y aura " + nbPages.to_s + " pages à extraire"

	liste = page1.css("a.media-cover").map { |lien| lien["href"] }
	listeURL.push liste
	appFourchette = appFourchette + liste.size
	puts "Il y a " + liste.size.to_s + " apparts à la page 1"

	(2..nbPages).each do |i|

		url2 = "https://fr.airbnb.ca/s/Quebec--Canada?price_min=" + min.to_s + "&price_max=" + max.to_s + "&page=" + i.to_s
		page2 = Nokogiri::HTML(open(url2, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))

		liste = page2.css("a.media-cover").map { |lien| lien["href"] }
		listeURL.push liste
		appFourchette = appFourchette + liste.size
		puts "Il y a " + liste.size.to_s + " apparts à la page " + i.to_s

	end

	if max > iMax
		puts "Nous avons en réalité " + appFourchette.to_s + " apparts de plus de " + min.to_s + "$"
	else
		puts "Nous avons en réalité " + appFourchette.to_s + " apparts entre " + min.to_s + "$ et " + max.to_s + "$"
	end

	appTotal = appTotal + appFourchette

	puts "Et nous avons " + appTotal.to_s + " apparts hasta ahorita."

	puts "-"*50

end

listeURL = listeURL.uniq

File.open("airbnbAdresses.txt", "w+") do |f|

	listeURL.each do |liste|

		liste.each { |urlAppart| f.puts(urlAppart) }

	end
end
