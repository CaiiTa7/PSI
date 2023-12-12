#!/bin/bash

#########################
# Ajout de la configuration pour la page de login par défaut
cp /usr/local/apache2/conf/httpd.conf /usr/local/apache2/conf/httpd.conf.backup

# Création de la page de connexion login.php
cat << EOF > /var/www/html/login.php
<!DOCTYPE html>

<html lang="fr">

  <?php

  // Fonction pour vérifier si l'utilisateur est connecté
  function is_connected() {
    // Vérifie si la méthode HTTP est POST
    if (\$_SERVER["REQUEST_METHOD"] == "POST") {

      // Récupère les données du formulaire
      \$username = \$_POST['username'];
      \$password = \$_POST['password'];

      // Connexion à la base de données MySQL
      \$servername = "localhost";
      \$dbusername = \$username; // Utilise le nom d'utilisateur du formulaire
      \$dbpassword = \$password; // Utilise le mot de passe du formulaire
      \$database = "login_page";

      \$conn = mysqli_connect(\$servername, \$dbusername, \$dbpassword, \$database);
     
      // Requête SQL pour vérifier si l'utilisateur existe
      // Exécute la requête
      \$result = mysqli_query(\$conn,\$sql);

      // Retourne vrai si l'utilisateur est connecté
      return mysqli_num_rows(\$result) > 0;
    } else {
      // Retourne faux si la méthode HTTP n'est pas POST
      return false;
    }
  }

  // Fonction pour afficher un message
  function show_message() {
    // Affiche le message dans un pop-up JavaScript
    ?>
    <script>
      alert("Connecté !!!");
    </script>
    Connexion réussie
    <?php
  }

  // Fonction pour afficher un message pour users non connecté
  function show_error() {
    // Affiche le message dans un pop-up JavaScript
    ?>
    <script>
      alert("Bien essayé ... mais ... ce n'est pas ça !!!!");
    </script>
    Connexion non réussie /!\ !!!
    <!-- Hint Pass : https://static.wikia.nocookie.net/hunterxhunter/images/8/8d/Hisoka%27s_favorite_gum.png/revision/latest?cb=20140823135632&path-prefix=fr-->

    <?php
  }

  // Fonction pour afficher le flag
  function show_flag() {
    ?>
    <script>
      var flag = '{groupe1}USER_FLAG_LOGIN_PAGE';
      alert('Flag : ' + flag + '\nFélicitations !!!');
    </script>
    Connexion réussie ... Bienvenue Le magicien, bien joué !!!
    <?php
  }

  // Vérifie si l'utilisateur est connecté
  if (is_connected()) {

    // Vérifie si l'utilisateur est hisoka
    if (\$_POST['username'] == "hisoka") {
      // Affiche le flag
      show_flag();
    } else {
      // Affiche un message de connexion
      show_message();
    }

  } else {
    // Affiche un message d'erreur
    show_error();
  }

  ?>
EOF
chmod 777 /var/www/html/login.php

# Configuration d'Apache pour la page de login par défaut
cat << EOF > /var/www/html/index.html
<html>
<meta charset="UTF-8">
<body style="background-color: Cornsilk;">
  <script>
    function getRandomColor() {
        var letters = '0123456789ABCDEF';
        var color = '#';
        for (var i = 0; i < 6; i++) {
            color += letters[Math.floor(Math.random() * 16)];
        }
        return color;
    }

    setInterval(function() {
        document.getElementById("titre").style.color = getRandomColor();
    }, 1000);  // Change la couleur toutes les 1000 millisecondes (soit 1 seconde)
</script>


  <h1 id="titre" style="text-align: center;">Tu veux essayer de pénétrer dans mon système ?</h1>
  <h2 style="text-align: center;margin-bottom: 25px;">QUE LA FORCE SOIT AVEC TOI</h2>
  <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2pnJsDgkxYUYa-7KyM0gH4rFCLgaIXmnYCb7lO_jm7w-CpF7oEccXI4L3Zkvhix61dv8&usqp=CAU" style="display: block; margin: 0 auto;width:400px;">



  <h3 style="text-align: center;color:purple">Connexion</h3>

  <!-- Hint : "(nom du user) = Il est un utilisateur du ... de type transmutation. Son ... est basé sur les cartes à jouer ...... Passs = ? à toi de trouver :)-->

  <form method="POST" action="login.php">

    <div style="display: flex; justify-content: center; align-items: center;">
      <label for="username" style="font-weight: bold;margin-right: 10px; display: inline-block; min-width: 100px;">Nom d'utilisateur:</label>
      <input type="text" id="username" name="username">
    </div>
    <br>

    <div style="display: flex; justify-content: center; align-items: center;">
      <label for="password" style="font-weight: bold;margin-right: 10px; display: inline-block; min-width: 125px;">Mot de passe:</label>
      <input type="password" id="password" name="password">
    </div>
    <br>

    <div style="display: flex; justify-content: center;">
      <input type="submit" value="Connexion" style ="min-width: 100px;margin-left: 125px;">
    </div>

  </form>

</body>
</html>
EOF
chmod 777 /var/www/html/index.html

# Installation de MariaDB
apt install -y mariadb-server

# Démarrage du service MariaDB
systemctl start mariadb

# Démarrage de MariaDB automatique au démarrage du système
systemctl enable mariadb

# Redémarrage d'Apache pour prendre en compte la nouvelle configuration
systemctl restart apache2.service
systemctl restart mariadb.service
systemctl restart mysql.service

# Création du programme vulnérable
# Insertion du code source du programme vulnérable
######################################################
cat << EOF > /home/luffy/script_config.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <command>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    // Exécute la commande en tant que root
    if (setuid(0) != 0) {
        perror("setuid");
        exit(EXIT_FAILURE);
    }

    // Exécute la commande spécifiée en argument
    if (system(argv[1]) == -1) {
        perror("system");
        exit(EXIT_FAILURE);
    }

    return 0;
}

EOF
############################################
# Compilation du programme vulnérable avec attribut setuid
gcc /home/luffy/script_config.c -o /home/luffy/script_config
chown root:root /home/luffy/script_config
chmod +s /home/luffy/script_config
rm /home/luffy/script_config.c

# Connection à distance mysql
cat << EOF >> /etc/mysql/my.cnf
[mysqld]
bind-address = 0.0.0.0
EOF

# SSH
cat << EOF >> /etc/ssh/sshd_config
AllowUsers killua
EOF
# Network file for hisoka
curl -LJ https://raw.githubusercontent.com/CaiiTa7/PSI/raw/main/network_analyze.pcap --output /home/killua/network_analyze.pcap
curl -LJ https://raw.githubusercontent.com/CaiiTa7/PSI/blob/main/logo.png --output /home/killua/logo.png
cat << EOF > /home/killua/coucou.txt
U : 81cc336187cc054b1bf5bf9ad4a385d7f2c144ba33653b48e0d4408b2d27ea73
P : png ?
EOF
## Effacer l'historique des commandes
rm -f /home/luffy/.bash_history /home/killua/.bash_history /home/Rengoku/.bash_history /home/muten_roshi/.bash_history /root/.bash_history

