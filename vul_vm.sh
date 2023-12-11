#!/bin/bash

# Script de configuration de la machine virtuelle vulnérable

# Mise à jour du système
apt update
apt upgrade -y

# Création des utilisateurs
adduser --disabled-password --gecos "" Rengoku
echo "rengoku:souffle_DelaFlamme" | chpasswd

adduser --disabled-password --gecos "" killua
echo "killua:GonForever" | chpasswd

# Installation des dépendances nécessaires pour la compilation
apt install -y build-essential libpcre3-dev libssl-dev libapr1-dev libaprutil1-dev make cmake gcc software-properties-common ca-certificates lsb-release apt-transport-https 

# Obtenez l'adresse IP de l'interface enp0s3
ip_address=$(ip addr show ens18 | awk '/inet / {print $2}' | cut -d/ -f1)

# Vérifiez si l'adresse IP est valide
if [ -n "$ip_address" ]; then
    # Le domaine que l'on veut associer à cette adresse IP
    domain="groupe1"

    # Ajoutez l'entrée dans /etc/hosts en utilisant sed
    if ! grep -q "$domain" /etc/hosts; then
        sed -i "3i127.0.0.1       $domain" /etc/hosts
        sed -i "4i$ip_address       $domain" /etc/hosts

        echo "L'adresse IP $ip_address a été ajoutée avec succès à /etc/hosts pour le domaine $domain."
    else
        echo "L'adresse IP $ip_address existe déjà dans /etc/hosts pour le domaine $domain."
    fi
else
    echo "Impossible de récupérer l'adresse IP de l'interface enp0s3."
fi

# Installation d'Apache HTTP Server 2.4.49 depuis les sources
cd /tmp
wget https://archive.apache.org/dist/httpd/httpd-2.4.49.tar.gz
tar -xzvf httpd-2.4.49.tar.gz
cd httpd-2.4.49

# Configuration, compilation et installation d'Apache
./configure --prefix=/usr/local/apache2 --enable-mods-shared=all --enable-so --enable-cgid --enable-session
make
make install
rm -rf /tmp/httpd-2.4.49.tar.gz /tmp/httpd-2.4.49
# Configuration vulnérabilité Apache
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

# Installation de PHP
apt install -y php php-mysql libapache2-mod-php php-cli php-cgi php-gd php-mbstring php-xml php-zip php-curl php-xmlrpc

# Configuration d'Apache avec "require all denied" access control désactivé
sed -i '/Require all denied/s/^/#/' /usr/local/apache2/conf/httpd.conf

# Activation du module mod_auth_form
sed -i '/LoadModule auth_form_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
sed -i '/LoadModule session_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
sed -i '/LoadModule session_cookie_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
sed -i '/LoadModule session_crypto_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
sed -i '/LoadModule authn_socache_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
sed -i '/LoadModule cgid_module modules/s/^#//g' /usr/local/apache2/conf/httpd.conf
sed -i '0,/Require all denied/{s/Require all denied/Require all granted/}' /usr/local/apache2/conf/httpd.conf
sed -i '/<Directory "\/usr\/local\/apache2\/cgi-bin">/ { N; N; s/Options None/Options +ExecCGI/; }' /usr/local/apache2/conf/httpd.conf
sed -i 's/User daemon/User killua/;s/Group daemon/Group user/' /usr/local/apache2/conf/httpd.conf

# Redémarrage d'Apache
systemctl restart apache2.service

# Création DB login_page (pour le site web) et la table utilisateur.
mysql -u root -pCeci3stlem0t2passeR0ùt -e "CREATE DATABASE login_page;"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "USE login_page; CREATE TABLE utilisateurs (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(255) NOT NULL, password VARCHAR(255) NOT NULL);"

# Création d'un utilisateur ("Admin") rengoku avec le mot de passe souffle_DelaFlamme avec tous les privilèges sur la base de données login_page.
mysql -u root -pCeci3stlem0t2passeR0ùt -e "USE login_page; INSERT INTO utilisateurs (username, password) VALUES ('rengoku', 'souffle_DelaFlamme');"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "CREATE USER 'rengoku'@'localhost' IDENTIFIED BY 'souffle_DelaFlamme';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT ALL PRIVILEGES ON login_page.* TO 'rengoku'@'localhost';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT ALL PRIVILEGES ON login_page.utilisateurs TO 'rengoku'@'localhost';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT SELECT, INSERT, UPDATE, DELETE ON utilisateurs TO 'rengoku'@'localhost';"

# Ensuite insertion des utilisateurs avec leurs mots de passe.
mysql -u root -pCeci3stlem0t2passeR0ùt -e "USE login_page; INSERT INTO utilisateurs (username, password) VALUES ('hisoka', 'Bungee_Gum');"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "CREATE USER 'hisoka'@'localhost' IDENTIFIED BY 'Bungee_Gum';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT USAGE ON login_page.* TO 'hisoka'@'localhost';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT SELECT ON login_page.utilisateurs TO 'hisoka'@'localhost';"

mysql -u root -pCeci3stlem0t2passeR0ùt -e "USE login_page; INSERT INTO utilisateurs (username, password) VALUES ('sasuke', 'sharing@n');"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "CREATE USER 'sasuke'@'localhost' IDENTIFIED BY 'sharing@n';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT USAGE ON login_page.* TO 'sasuke'@'localhost';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT SELECT ON login_page.utilisateurs TO 'sasuke'@'localhost';"

mysql -u root -pCeci3stlem0t2passeR0ùt -e "USE login_page; INSERT INTO utilisateurs (username, password) VALUES ('naruto', '1orbe_tourbillonn@nt');"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "CREATE USER 'naruto'@'localhost' IDENTIFIED BY '1orbe_tourbillonn@nt';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT USAGE ON login_page.* TO 'naruto'@'localhost';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT SELECT ON login_page.utilisateurs TO 'naruto'@'localhost';"

mysql -u root -pCeci3stlem0t2passeR0ùt -e "USE login_page; INSERT INTO utilisateurs (username, password) VALUES ('Son_Goku', 'Bouhhle2_cristal4');"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "CREATE USER 'Son_Goku'@'localhost' IDENTIFIED BY 'Bouhhle2_cristal4';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT USAGE ON login_page.* TO 'Son_Goku'@'localhost';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "GRANT SELECT ON login_page.utilisateurs TO 'Son_Goku'@'localhost';"
mysql -u root -pCeci3stlem0t2passeR0ùt -e "FLUSH PRIVILEGES;"

# Redémarrage d'Apache pour prendre en compte la nouvelle configuration
systemctl restart apache2.service
systemctl restart mariadb.service
systemctl restart mysql.service

cat << EOF >> /etc/ssh/sshd_config
# Ajout de la configuration pour la connexion SSH
AllowGroups sshd
EOF
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

## Effacer l'historique des commandes
rm -f /home/luffy/.bash_history /home/killua/.bash_history /home/Rengoku/.bash_history /home/muten_roshi/.bash_history /root/.bash_history
