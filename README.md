airbnb.qc
=========

:rocket: Données sur les logements offerts sur AirBnb au Québec extraits à deux occasions, d'abord en décembre 2014, puis en octobre 2015.

###Décembre 2014

L'extraction effectuée en décembre 2014 a nécessité 2 scripts et produits 2 fichiers: 

**air1.rb**
  * Ce premier script fait une recherche sur AirBnb.ca en demandant tous les logements se trouvant au Québec.
  * En fait, il fait plusieurs recherches par tranche de prix en intervalles de cinq dollars (0-4$, 5-9$, 10-14$, et ainsi de suite).
  * Ensuite, il recueille les URL de toutes les fiches de logement affichées dans les résultats, page par page (il y a 18 résultats par page).
  * Enfin, il exporte un fichier texte contenant tous les URLs recueillis (plus de 10 000).

**airbnbAdresses.txt**
  * Liste de tous les URLs recueillis par air1.rb le 3 décembre 2014.

**air2.rb**
  * Ce second script prend la liste dans airbnbAdresses.txt, élimine les doublons, puis ouvre une fiche à la fois et va chercher certaines informations: le prix demandé, le locateur, etc.
  * Il effectue aussi une vérification du nom de la municipalité où se trouve le logement en fonction des coordonnées fournies par la fiche à l'aide du [Service de géolocalisation du gouvernement québécois](http://geoegl.msp.gouv.qc.ca/accueil/aideglo.htm).
  * Il recueille des infos sur plus de 8 000 logements, mais quelques centaines sont hors Québec, donc le total réel de logements offerts au Québec par AirBnb, début décembre 2014, est de 7 687 logements.
 
**airbnb.csv**
  * Résultat de l'extraction de données du script air2.rb
  * Le CSV contient, notamment, les coordonnées (latitude, longitude) du logement, le titre de la fiche, l'URL, la photo principale, le prix, la capacité, la description et diverses infos sur le locateur.

[Résultat final sur CartoDB](http://cdb.io/1yob6Nn)

###Octobre 2015

L'extraction d'octobre 2015 a nécessité 3 scripts et produit plusieurs fichiers TXT et CSV, mais je ne vais en donner qu'un seul, le dernier.

**air1-oct15.rb**
 * Ce premier script effectue une recherche dans tous les logements annoncés au Québec sur Airbnb.ca
 * Il procède par tranche de prix demandé, c'est-à-dire qu'il recherche tous les logements pour lesquels on demande de 10$ à 11$ la nuit, puis de 11$ à 12$, puis de 12$ à 13$, et ainsi de suite jusqu'au prix maximum de 1500$, seuil au-delà duquel il y a assez peu de logements pour pouvoir les extraire en une seule requête demandant les prix de 1500$ et plus.
 * Il met toutes les URL trouvées dans un fichier texte.

**air2-oct15.rb**
* Ce 2e script part d'un fichier CSV créé à partir du fichier texte produit par le premier script.
* Il prend chaque code de logement Airbnb et télécharge dans un dossier le fichier HTML de la page du logement en question à l'aide de la commande ```wget```.
* Pour minimiser les risques de rejet par Airbnb, il utilise 2 tactiques: une pause aléatoire (entre 0 et 10 secondes) à chaque requête sur le serveur et l'envoi d'entêtes changeant aléatoirement.

**air3-oct15.rb**
* Ce 3e script extrait ensuite les informations contenues dans chacun des fichiers HTML téléchargés par le 2e script et les place dans un fichier CSV final.
* Il géolocalise chaque inscription comme je l'avais fait en décembre 2014, ce qui permet ensuite de nettoyer le CSV pour en retirer les inscriptions hors Québec. Ce fichier nettoyé est **airbnb-oct15-nettoye.csv**. Il contient **6407 logements**.

[Résultat final sur CartoDB](http://cdb.io/1jKhkaT).

####Ajout, 28 décembre 2015

[Florent Daudens](http://fdaudens.com/), journaliste à Radio-Canada.ca, a réalisé [une comparaison semblable, mais arrivant à des conclusions radicalement différentes](http://ici.radio-canada.ca/regions/montreal/2015/12/04/004-hausse-annonces-location-appartements-tourisme-airbnb-loi-quebec-carte.shtml). Il a partagé avec moi son fichier de résultats, que je dépose ici en lui donnant le nom de **air_florent.csv**.
