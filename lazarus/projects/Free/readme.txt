xpl_free

v0.1
	Premiere version publi�e
	Cette application se connecte sur votre console de gestion free.
		- r�cup�re certains �l�ments d'information utiles (adresse ip publique, passerelle, adresse mac, version freebox)
		- surveillance r�guli�re de la liste des messages t�l�phoniques laiss�s en attente
			- notification sur le r�seau xPL de la pr�sence d'un message t�l�phonique
			- download du fichier enregistr�
		- Permet l'allumage et l'extinction de la freebox � partir de messages xPL

	L'application se configure � l'aide de xPL Hal - les param�tres � fournir sont les suivants :
		Username : votre identifiant free
		Password : le mot de passe associ� � cet identifiant
		StoreDir : r�pertoire pour la d�pose des fichiers wav de la messagerie vocale
		Webroot	 : localisation de la racine web des applications xpl (commun aux autres application xPL clinique).
				T�l�charger et d�compresser le fichier "Web root for xpl web server apps" disponible dans la section download de glh33.free.fr
		fbox-x10 : code x10 du module (type AM12) sur lequel est connect� la Freebox
		fboxhd-x10 : code x10 du module (type AM12) sur lequel est connect� le boitier TV Freebox
		polling  : d�lai d'interrogation de la page de messagerie vocale

v0.2	Version qui tente de corriger le pb de socket/port non lib�r�.

v0.5	Ajoute la recherche des num�ros de t�l�phone dans l'annuaire invers�
		Le serveur web donne acc�s aux actions associ�es au module xPL (reboot freebox, allumage/extinction d'un boitier) sans passer par un sender xPL
		L'onglet info contient quelques �l�ments suppl�mentaires (clef wep, nom du r�seau)
		Icone cr��e
	
v0.6	* L'interface Free est pass�e en HTTPS, mise � jour du programme qui peut n�cessiter la pr�sence des librairies OpenSSL 
		disponibles ici : http://www.slproweb.com/products/Win32OpenSSL.html
		Microsoft VC++2008 Redistribuable peut aussi �tre r�clam�.
		* xPL Free se connecte maintenant au usenet free pour d�tecter les mises � jour de firmware - un message OSD est envoy� quand une nouvelle news est post�e.
		* Erreur 403 lors de la recherche dans l'annuaire invers� r�gl�
		
v0.7
		* Modification li�e au fait que l'ensemble de l'interface Free est d�sormais en https

	
Todo : 
	Quand le d�lai de polling est trop important, la connexion ouverte initialement ne persiste pas, on obtient "Error=2"
		=> catcher l'erreur et r�ouvrir la connexion
	R�cup�rer les statistiques de la ligne (vitesse DL)
	Int�grer les informations produites par PyGrenouille ?
	Utiliser les nouvelles API : 
	* API d�export de la liste des cha�nes et des abonnements :
	* API de t�l�commande virtuelle :
	R�cup�rer le nom du NRA et l'adresse de l'installation qui sont disponibles dans la console de gestion
		(cel� permettrait d'identifier automatiquement la latitude / longitude par exemple).
		
	