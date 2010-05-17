xpl_free

v0.1
	Premiere version publiée
	Cette application se connecte sur votre console de gestion free.
		- récupère certains éléments d'information utiles (adresse ip publique, passerelle, adresse mac, version freebox)
		- surveillance régulière de la liste des messages téléphoniques laissés en attente
			- notification sur le réseau xPL de la présence d'un message téléphonique
			- download du fichier enregistré
		- Permet l'allumage et l'extinction de la freebox à partir de messages xPL

	L'application se configure à l'aide de xPL Hal - les paramètres à fournir sont les suivants :
		Username : votre identifiant free
		Password : le mot de passe associé à cet identifiant
		StoreDir : répertoire pour la dépose des fichiers wav de la messagerie vocale
		Webroot	 : localisation de la racine web des applications xpl (commun aux autres application xPL clinique).
				Télécharger et décompresser le fichier "Web root for xpl web server apps" disponible dans la section download de glh33.free.fr
		fbox-x10 : code x10 du module (type AM12) sur lequel est connecté la Freebox
		fboxhd-x10 : code x10 du module (type AM12) sur lequel est connecté le boitier TV Freebox
		polling  : délai d'interrogation de la page de messagerie vocale

v0.2	Version qui tente de corriger le pb de socket/port non libéré.

v0.5	Ajoute la recherche des numéros de téléphone dans l'annuaire inversé
		Le serveur web donne accès aux actions associées au module xPL (reboot freebox, allumage/extinction d'un boitier) sans passer par un sender xPL
		L'onglet info contient quelques éléments supplémentaires (clef wep, nom du réseau)
		Icone créée
	
v0.6	* L'interface Free est passée en HTTPS, mise à jour du programme qui peut nécessiter la présence des librairies OpenSSL 
		disponibles ici : http://www.slproweb.com/products/Win32OpenSSL.html
		Microsoft VC++2008 Redistribuable peut aussi être réclamé.
		* xPL Free se connecte maintenant au usenet free pour détecter les mises à jour de firmware - un message OSD est envoyé quand une nouvelle news est postée.
		* Erreur 403 lors de la recherche dans l'annuaire inversé réglé
		
v0.7
		* Modification liée au fait que l'ensemble de l'interface Free est désormais en https

	
Todo : 
	Quand le délai de polling est trop important, la connexion ouverte initialement ne persiste pas, on obtient "Error=2"
		=> catcher l'erreur et réouvrir la connexion
	Récupérer les statistiques de la ligne (vitesse DL)
	Intégrer les informations produites par PyGrenouille ?
	