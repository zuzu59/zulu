zf 1200607.1649

Configuration MyPrint
 
Simplement, et UNIQUEMENT, choisir nouvelle imprimante réseau/Imprimante Windows via SAMBA, puis mettre ceci:
 
smb://intranet/username:password@print1.epfl.ch/MAA0944-A4-C2-PS
ou
smb://intranet/username:password@print1.epfl.ch/pool1
 
Puis choisir: Fournir un fichier PPD.
  
Attention, le mot de passe sera sauvé dans le fichier /etc/cups/printers.conf et printers.conf.0 !
Si on ne désire pas sauvegarder en clair le password il faut alors mettre comme URI:
 
smb://print1.epfl.ch/MAA0944-A4-C2-PS
ou
smb://print1.epfl.ch/pool1
 
Il faudra alors, à chaque impression, indiquer comme user: intranet/user (en minuscule avec un seul slash) et son password
  
Remarques:
Le bouton 'vérifier' ne fonctionne pas tout le temps, ne pas en tenir compte !
Par défaut on imprime sur le TRAY 1, c'est le chargeur de papier manuel, il ne faut donc pas oublier de changer de TRAY avant d'imprimer la page de test !
 
J'ai mis les PPD de Xerox myPrint dans le dossier du zpack !

 
