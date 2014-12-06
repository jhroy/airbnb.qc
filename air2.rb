#!/usr/bin/env ruby
# ©2014 Jean-Hugues Roy. GNU GPL v3.

require "csv"
require "nokogiri"
require "open-uri"
require "json"

listeURL = []
tout = []

fichier = File.open("airbnbAdresses.txt")
fichier.each_line do |url|
	url = url[0..url.index("?") - 1]
	listeURL.push url
end

listeURL = listeURL.uniq.sort

i = listeURL.size

listeURL.each_with_index do |urlAppart, x|

	appart = {}

	i -= 1

	urlAppart = "https://fr.airbnb.ca" + urlAppart.to_s
	puts urlAppart

	pageAppart = Nokogiri::HTML(open(urlAppart, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))

	# puts pageAppart.css("title").text.strip

	appart["URL"] = urlAppart
	appart["Titre"] = pageAppart.css("h1.h3").text.strip
	puts appart["Titre"]
	appart["Latitude"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:location:latitude']/@content").text
	appart["Longitude"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:location:longitude']/@content").text

	geo = "http://pregeoegl.msp.gouv.qc.ca/Services/glo/V5/gloServeurHTTP.php?type=gps&cle=public&texte=GPS%20" + appart["Latitude"].to_s + "," + appart["Longitude"].to_s + "&epsg=4326&format=xml"
	requete = Nokogiri::XML(open(geo, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca)"))
	municipalite = requete.xpath("//municipalite").text
	espace = municipalite.index(" (").to_i
	region = municipalite[espace+2..-2]
	municipalite = municipalite[0..espace].strip
	if municipalite == ""
		municipalite = "Hors Québec"
	end

	appart["Municipalité"] = municipalite
	appart["Région"] = region

	appart["Localité"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:locality']/@content").text
	appart["Ville"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:city']/@content").text
	appart["Province"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:region']/@content").text
	appart["Pays"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:country']/@content").text

	prix = pageAppart.css("div#price_amount").text.strip[1..-4]
	appart["Prix ($)"] = prix.to_i

	if pageAppart.xpath("//meta[@id='_bootstrap-room_options']/@content").text.size > 2
		meta = pageAppart.xpath("//meta[@id='_bootstrap-room_options']/@content").text
		json = JSON.parse(meta)

		cap = json["airEventData"]["person_capacity"]
		appart["Capacité"] = cap.to_i
		appart["Prix par personne ($)"] = (prix.to_f / cap.to_f).round(2)
	else
		appart["Capacité"] = "?"
		appart["Prix par personne ($)"] = "?"
	end

	appart["Description simple"] = pageAppart.xpath("//meta[@name='description']/@content").text
	appart["Description complète"] = pageAppart.xpath("//meta[@property='og:description']/@content").text
	appart["Photo (URL)"] = pageAppart.xpath("//meta[@property='og:image']/@content").text

	nom = pageAppart.xpath("//a[@class='media-photo media-round']/img/@alt").text
	nom = nom[0..(nom.size/2)-1]
	appart["Loueur_Nom"] = nom
	loueur = pageAppart.xpath("//a[@class='media-photo media-round']/@href").text.strip
	loueur = loueur[(loueur.index("w/").to_i)+2..-1]
	appart["Loueur_Code"] = loueur
	appart["Loueur_URL"] = "https://fr.airbnb.ca/users/show/" + loueur.to_s

	puts appart

	puts (x+1).to_s + " sont faits; il en reste " + i.to_s
	puts "="*80

	tout.push appart

end

CSV.open("airbnb.csv", "wb") do |csv|
	csv << tout.first.keys
	tout.each do |hash|
		csv << hash.values
	end
end
