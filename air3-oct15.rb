#!/usr/bin/env ruby
# ©2015 Jean-Hugues Roy. GNU GPL v3.

require "csv"
require "nokogiri"
require "open-uri"
require "json"

listeURL = []
tout = []

fich = "airbnb-adresses-oct2015.csv"

CSV.foreach(fich) do |url|
	if url[1] != "URL"
		code = url[0]
		fichier = "html/#{code}.html"
		if File.file?(fichier)
			appart = {}
			pageAppart = Nokogiri::HTML(open(fichier))

			if pageAppart.xpath("//link[@rel='canonical']/@href").text == "https://fr.airbnb.ca/rooms/#{code}"

				appart["Code"] = code
				appart["URL"] = url[1]
				appart["Titre"] = pageAppart.css("h1#listing_name").text.strip
				appart["Latitude"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:location:latitude']/@content").text
				appart["Longitude"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:location:longitude']/@content").text

				appart["Localité (Airbnb)"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:locality']/@content").text
				appart["Ville (Airbnb)"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:city']/@content").text
				appart["Province (Airbnb)"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:region']/@content").text
				appart["Pays (Airbnb)"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:country']/@content").text

				geo = "http://pregeoegl.msp.gouv.qc.ca/Services/glo/V5/gloServeurHTTP.php?type=gps&cle=public&texte=GPS%20" + appart["Latitude"].to_s + "," + appart["Longitude"].to_s + "&epsg=4326&format=xml"
				requete = Nokogiri::XML(open(geo, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca)"))
				municipalite = requete.xpath("//municipalite").text
				espace = municipalite.index(" (").to_i
				region = municipalite[espace+2..-2]
				municipalite = municipalite[0..espace].strip
				if municipalite == ""
					municipalite = "Hors Québec"
				end

				appart["Municipalité (géocodée)"] = municipalite
				appart["Région (géocodée)"] = region

				if pageAppart.xpath("//meta[@id='_bootstrap-room_options']/@content").text.size > 2
					meta = pageAppart.xpath("//meta[@id='_bootstrap-room_options']/@content").text
					json = JSON.parse(meta)

					cap = json["airEventData"]["person_capacity"]
					appart["Capacité"] = cap.to_i
					prix = json["airEventData"]["price"]
					appart["Prix"] = prix.to_f
					appart["Prix par personne ($)"] = (prix/cap).round(2)
				else
					appart["Prix"] = pageAppart.xpath("//meta[@itemprop='price']/@content").text.to_f
					appart["Capacité"] = "?"
					appart["Prix par personne ($)"] = "?"
				end

				appart["Description complète"] = pageAppart.xpath("//meta[@property='og:description']/@content").text
				appart["Description simple"] = pageAppart.xpath("//meta[@name='description']/@content").text
				appart["Photo (URL)"] = pageAppart.xpath("//meta[@property='og:image']/@content").text
				appart["Note"] = pageAppart.xpath("//meta[@property='airbedandbreakfast:rating']/@content").text.to_f.round(1)

				if pageAppart.xpath("//div[@class='___iso-state___p3summarybundlejs']/@data-state").text.size > 2
					meta2 = pageAppart.xpath("//div[@class='___iso-state___p3summarybundlejs']/@data-state").text
					json2 = JSON.parse(meta2)
					codeLocateur = json2["displayUser"]["id"]
					superLocateur = json2["displayUser"]["is_superhost"]
					type = json2["summaryIconRow"][0]["label"]
					classe = type["label"]
					appart["Classe"] = type
					if superLocateur == true
						appart["«Superhost?»"] = "Oui"
					else
						appart["«Superhost?»"] = "Non"
					end
					appart["Nombre de commentaires"] = json2["visibleReviewCount"]
				else
					appart["Classe"] = "Inconnu"
					appart["«Superhost?»"] = "Inconnu"
					appart["Nombre de commentaires"] = "?"
				end

				appart["Locateur - Nom"] = pageAppart.xpath("//meta[@name='em:host:name']/@content").text
				appart["Locateur - Code"] = codeLocateur
				if pageAppart.xpath("//meta[@name='em:host:image']/@content") != nil
					locateur = pageAppart.xpath("//meta[@name='em:host:image']/@content").text
					appart["Locateur - Photo"] = locateur[0..locateur.index("?")-1]
				else
					appart["Locateur - Photo"] = "https://a2.muscache.com/defaults/user_pic-225x225.png"
				end
				appart["Locateur - URL"] = "https://fr.airbnb.ca/users/show/#{codeLocateur}"

				puts appart
				tout.push appart
			end
		end
	end
end

CSV.open("airbnb-oct2015.csv", "wb") do |csv|
	csv << tout.first.keys
	tout.each do |hash|
		csv << hash.values
	end
end
