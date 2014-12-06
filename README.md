airbnb.qc
=========

Données sur les logements offerts sur AirBnb au Québec

Ce répertoire contient 2 scripts en ruby et les 2 fichiers produits par ces scripts:

**air1.rb**
  * Ce premier script fait une recherche sur AirBnb.ca en demandant tous les logements se trouvant au Québec.
  En fait, il fait plusieurs recherches par tranche de prix en intervalles de cinq dollars (0-4$, 5-9$, 10-14$, et ainsi de suite).
  Ensuite, il recueille les URL de toutes les fiches de logement affichées dans les résultats, page par page (il y a 18 résultats par page).
  Enfin, il exporte un fichier texte contenant tous les URLs recueillis.

**airbnbAdresses.txt**
  * Liste de tous les URLs recueillis par air1.rb le 3 décembre 2014.

**air2.rb**
  * Ce second script prend la liste dans airbnbAdresses.txt, élimine les doublons, puis ouvre une fiche à la fois et va chercher certaines informations: le prix demandé, le locateur, etc.
  Il effectue aussi une vérification du nom de la municipalité où se trouve le logement en fonction des coordonnées fournies par la fiche à l'aide du [Service de géolocalisation du gouvernement québécois](http://geoegl.msp.gouv.qc.ca/accueil/aideglo.htm)

[Résultat final sur CartoDB](http://cdb.io/1yob6Nn)
