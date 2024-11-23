# Mon workflow OpenFOAM
Il s'agit de mes notes officielles pour utiliser les scripts efficacements et lancer rapidement une simulation OpenFOAM.

## Get started
Lancer un cas sur of est assez simple, en revance d'un point de vue informatique, il est utile de suivre les étapes ci-dessous pour pouvoir ensuire faire des études paramétriques très simplement.
```bash
clone "file from my github repo"
cd file
```

on peut initer les premiers paramètres avec:
```bash
bash ./SCRIPTS/BASH/get_started.sh
```

### Lancer le cas : run_all.sh ou run_all_parrallel.sh
run_all.sh permet de run toute les étapes du calcul. Comme il n'y a pas grand chose à faire on peut se permettre de tout mettre dedans, maillage + calcul.
Pour l'utiliser correctement : 
- Prérequis du script résidus : Ajouter
```txt
# includeFunc residuals
```

- Prérequis du script force : Ajouter
```txt
# includeFunc forceCoeffsIncompressible
```

NB : Ce sont des forces objects qui ici tournent en même temps que le calcul, et permet de regarder en direct la convergence du calcul (ou non). Force compressible, ne fonctionne pas en parallele, mais on peut sans effort le faire tourner arpès coup.

### Post-traitement : PP.sh
Les choses se compliquent un peu mais restont calme....
Dans le cas du script simple, pas d'étude paramétrique ou quoi que ce soit. Il faut se poser la question de ce qu'on veut extraire. 
Et ensuite, on rédige un script (non dépendant du cas), simplement avec des chemins relatifs, afin d'extraire ce que l'on veut.
Exemple : 
    On souhaite extraire faire une courbe Cd en fonction du Re. Pour un cas de base à Re fixé, on souhaite récup le Cd pour un certain Re. Donc on fait un script (bash/python) qui renvoie un fichier .dat avec les 2 données. Dans la suite on verra ce qu'on en fait. C'est aussi l'exemple pour les polaires. On récupère les coeffs pour l'incidence donnée.

## Mise en place d'une étude paramétrique
Objectif : On se donne une ou plusieurs variables à changer (cela peut être n'importe quoi), par exemple le Re.

### Lancer le cas : run_parametric.sh
L'idée du script est simplement de crée autant de cas nécessaire et de les faire tourner. 
On peut décider de soit just crée les rép ou de crée les rép + lancer les calculs.
D'un point de vue utilisateur, l'idée est de juste donner un fichier en entrée en expliquant ce qu'on veut faire ie : 
nom du fichier et variable à remplacer + sa nouvelle valeur. 

1. Crée un répertoire "baseCase" avec au moins 0/, constant/, system/ (appelle du script init.sh)
2. Modifier le fichier input_template avec les paramètres que l'on souhaite en utilisant le scipt python dédié.

### Post-traitement de l'ensemble des cas 
La philo est assez simple. Il y'a 3 scripts à remplire dont 2 qui sont setup et PP qui sont deja fait. Toute les magouilles d'après coup pour faire des remues ménages sont dans le script moving data.





