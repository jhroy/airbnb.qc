#!/usr/bin/env ruby
# ©2015 Jean-Hugues Roy. GNU GPL v3.

require "nokogiri"
require "open-uri"

listeURL = []
appTotal = 0
fichTxt = "airbnbAdresses-oct2015.txt"

iMin = 245
iMax = 1500

total = 0
prixTotal = 0
prixMoyen = 0

(iMin..iMax).each do |n|

	fichTxt = "airbnbAdresses-oct2015-#{n}$.txt"
	min = n
	max = n

	appFourchette = 0

	if max > iMax
		url1 = "https://fr.airbnb.ca/s/Quebec--Canada?price_min=" + min.to_s
	else
		url1 = "https://fr.airbnb.ca/s/Quebec--Canada?price_min=" + min.to_s + "&price_max=" + max.to_s
	end

	page1 = Nokogiri::HTML(open(url1, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))

	nb = page1.css("h1.h6").text.strip
	# puts nb
	nb = nb[0..2].to_i

	total = total + nb
	prixTotal = prixTotal.to_f + nb.to_f*n.to_f
	puts prixTotal
	puts total
	if total > 0
		prixMoyen = (prixTotal/total).to_f.round(2)
	end

	puts "#{nb} apparts à #{n}$ (on en a #{total} au total, prix moyen: #{prixMoyen}$)"
	
	nbPages = nb.to_i/18 + 1
	puts "Il y aura " + nbPages.to_s + " pages à extraire"

	liste = page1.css("a.media-cover").map { |lien| lien["href"] }
	listeURL.push liste
	appFourchette = appFourchette + liste.size
	puts "Il y a " + liste.size.to_s + " apparts à la page 1"
	puts liste

	(2..nbPages).each do |i|

		url2 = "https://fr.airbnb.ca/s/Quebec--Canada?price_min=" + min.to_s + "&price_max=" + max.to_s + "&page=" + i.to_s
		page2 = Nokogiri::HTML(open(url2, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))

		liste = page2.css("a.media-cover").map { |lien| lien["href"] }
		listeURL.push liste
		appFourchette = appFourchette + liste.size
		puts "Il y a " + liste.size.to_s + " apparts à la page " + i.to_s
		puts liste

	end

	appTotal = appTotal + appFourchette

	puts "Et nous avons " + appTotal.to_s + " apparts hasta ahorita."

	puts "-"*50

	listeURL = listeURL.uniq


	File.open(fichTxt, "w+") do |f|
		listeURL.each do |liste|
			liste.each { |urlAppart| f.puts(urlAppart) }
		end
	end

end
