#!/usr/bin/env ruby
# ©2015 Jean-Hugues Roy. GNU GPL v3.

require "csv"

fich = "airbnb-adresses-oct2015.csv"
n = 0
pauses = 0

total = CSV.readlines(fich).size

CSV.foreach(fich) do |url|
	if url[1] != "URL"
		code = url[0]
		fichier = "html/#{code}.html"
		if File.file?(fichier)
			puts "   >>> #{code}, on l'a déjà"
		else
			nb = Dir["html/*"].length
			n += 1
			pause = (rand()/rand()).round(2)
			if pause < 10
				pauses = pauses + pause
				puts "-"*50
				puts "         -----fichier ##{n}-----"
				puts "     -----on en a #{nb} sur #{total} (#{((nb.to_f/total.to_f)*100).round(1)}%)-----"
				puts "-"*50
				puts "       -----pause de #{pause} seconde(s)-----"
				puts "  -----moyenne de #{(pauses/n).round(2)} seconde(s) par pause-----"
				puts "-"*50
				sleep(pause)
				u = url[1]
				agents = [
					"Mozilla/5.0 (X11; Linux armv6l; rv:10.0.10) Gecko/20160101 Firefox/10.0.10 RaspberryPi/10.0.10",
					"Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; ARM; Trident/6.0; Touch)",
					"Mozilla/3.0 (Macintosh; I; 68K)",
					"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36",
					"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.21 (KHTML, like Gecko) Chrome/19.0.1042.0 Safari/535.21",
					"Mozilla/5.0 (X11; U; Linux i686; ko-KR; rv:1.9.2.12) Gecko/20101027 Ubuntu/10.10 (maverick) Firefox/3.6.12",
					"Lynx/2.8.5dev.16 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7a",
					"NCSA_Mosaic/2.0 (Windows 3.1)",
					"Mozilla/5.0 (BlackBerry; U; BlackBerry 9800; zh-TW) AppleWebKit/534.8+ (KHTML, like Gecko) Version/6.0.0.448 Mobile Safari/534.8+",
					"Mozilla/5.0 (Linux; U; Android 2.3.4; en-us; T-Mobile myTouch 3G Slide Build/GRI40) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
				]
				agent = agents[(rand()*10).round(1)]
				`wget -Phtml -E -d #{u} --no-cookies --no-http-keep-alive --referer=www.berniesanders.com --no-cache --no-check-certificate -U "#{agent}"`
			end
		end
	end
end
