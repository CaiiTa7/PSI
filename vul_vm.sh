#!/bin/bash

# Script de configuration de la machine virtuelle vulnérable

# Mise à jour du système
sudo apt update
sudo apt upgrade -y

# Création des utilisateurs
sudo useradd Rengoku -m -p souffle_delaFl@mme -s /bin/bash
sudo useradd killua -m -p gonforever -s /bin/bash

# Installation des dépendances nécessaires pour la compilation
sudo apt install -y build-essential libpcre3-dev libssl-dev libapr1-dev libaprutil1-dev make cmake gcc software-properties-common ca-certificates lsb-release apt-transport-https 

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
sudo wget https://archive.apache.org/dist/httpd/httpd-2.4.49.tar.gz
sudo tar -xzvf httpd-2.4.49.tar.gz
cd httpd-2.4.49

# Configuration, compilation et installation d'Apache
./configure --prefix=/usr/local/apache2 --enable-mods-shared=all --enable-ssl --enable-so --enable-cgid
sudo make
sudo make install
sudo rm -rf /tmp/httpd-2.4.49.tar.gz /tmp/httpd-2.4.49
# Configuration vulnérabilité Apache

# Création de la page de connexion login.php
sudo cat << EOF > /var/www/html/login.php
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
      
      // Vérifie la connexion
      if (!\$conn) {
        die("Échec de la connexion : " . mysqli_connect_error());
      }
      
      // Requête SQL pour vérifier si l'utilisateur existe
      \$sql = "SELECT * FROM utilisateurs WHERE username = '\$username' AND password = '\$password'";

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
sudo chmod 777 /var/www/html/login.php

# Configuration d'Apache pour la page de login par défaut
sudo cat << EOF > /var/www/html/index.html
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

  <!-- Hint : "Admin = Il est un utilisateur de ... de type transmutation. Son ... est basé sur les cartes à jouer ...... Passs = ? à toi de trouver :)-->



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
sudo chmod 777 /var/www/html/index.html

# Installation de MariaDB
sudo apt install -y mariadb-server

# Démarrage du service MariaDB
sudo systemctl start mariadb

# Démarrage de MariaDB automatique au démarrage du système
sudo systemctl enable mariadb

# Installation de PHP
sudo apt install -y php php-mysql libapache2-mod-php php-cli php-cgi php-gd php-mbstring php-xml php-zip php-curl php-xmlrpc

# Configuration d'Apache avec "require all denied" access control désactivé
sudo sed -i '/Require all denied/s/^/#/' /usr/local/apache2/conf/httpd.conf

# Activation du module mod_auth_form
sudo sed -i '/LoadModule auth_form_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
sudo sed -i '/LoadModule session_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
sudo sed -i '/LoadModule session_cookie_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
sudo sed -i '/LoadModule session_crypto_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
sudo sed -i '/LoadModule authn_socache_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
sudo sed -i '/LoadModule cgid_module modules/s/^#//g' /usr/local/apache2/conf/httpd.conf
sudo sed -i '0,/Require all denied/{s/Require all denied/Require all granted/}' /usr/local/apache2/conf/httpd.conf
sudo sed -i '/<Directory "\/usr\/local\/apache2\/cgi-bin">/ { N; N; s/Options None/Options +ExecCGI/; }' /usr/local/apache2/conf/httpd.conf
sudo sed -i 's/User daemon/User killua/;s/Group daemon/Group user/' /usr/local/apache2/conf/httpd.conf

# Redémarrage d'Apache
sudo systemctl restart apache2.service

# Création DB login_page (pour le site web) et la table utilisateur.
sudo mysql -u root -pTigrou007 -e "CREATE DATABASE login_page;"
sudo mysql -u root -pTigrou007 -e "USE login_page; CREATE TABLE utilisateurs (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(255) NOT NULL, password VARCHAR(255) NOT NULL);"

# Création d'un utilisateur ("Admin") rengoku avec le mot de passe souffle_DelaFlamme avec tous les privilèges sur la base de données login_page.
sudo mysql -u root -pTigrou007 -e "USE login_page; INSERT INTO utilisateurs (username, password) VALUES ('rengoku', 'souffle_DelaFlamme');"
sudo mysql -u root -pTigrou007 -e "GRANT ALL PRIVILEGES ON login_page.* TO 'rengoku'@'localhost';"
sudo mysql -u root -pTigrou007 -e "GRANT ALL PRIVILEGES ON login_page.utilisateurs TO 'rengoku'@'localhost';"
sudo mysql -u root -pTigrou007 -e "USE login_page; GRANT SELECT, INSERT, UPDATE, DELETE ON utilisateurs TO 'rengoku'@'localhost';"

# Ensuite insertion des utilisateurs avec leurs mots de passe.
sudo mysql -u root -pTigrou007 -e "USE login_page; INSERT INTO utilisateurs (username, password) VALUES ('hisoka', 'Bungee_Gum');"
sudo mysql -u root -pTigrou007 -e "CREATE USER 'hisoka'@'localhost' IDENTIFIED BY 'Bungee_Gum';"
sudo mysql -u root -pTigrou007 -e "GRANT USAGE ON login_page.* TO 'hisoka'@'localhost';"
sudo mysql -u root -pTigrou007 -e "GRANT SELECT ON login_page.utilisateurs TO 'hisoka'@'localhost';"

sudo mysql -u root -pTigrou007 -e "USE login_page; INSERT INTO utilisateurs (username, password) VALUES ('sasuke', 'sharing@n');"
sudo mysql -u root -pTigrou007 -e "CREATE USER 'sasuke'@'localhost' IDENTIFIED BY 'sharing@n';"
sudo mysql -u root -pTigrou007 -e "GRANT USAGE ON login_page.* TO 'sasuke'@'localhost';"
sudo mysql -u root -pTigrou007 -e "GRANT SELECT ON login_page.utilisateurs TO 'sasuke'@'localhost';"

sudo mysql -u root -pTigrou007 -e "USE login_page; INSERT INTO utilisateurs (username, password) VALUES ('naruto', '1orbe_tourbillonn@nt');"
sudo mysql -u root -pTigrou007 -e "CREATE USER 'naruto'@'localhost' IDENTIFIED BY '1orbe_tourbillonn@nt';"
sudo mysql -u root -pTigrou007 -e "GRANT USAGE ON login_page.* TO 'naruto'@'localhost';"
sudo mysql -u root -pTigrou007 -e "GRANT SELECT ON login_page.utilisateurs TO 'naruto'@'localhost';"

sudo mysql -u root -pTigrou007 -e "USE login_page; INSERT INTO utilisateurs (username, password) VALUES ('Son_Goku', 'Bouhhle2_cristal4');"
sudo mysql -u root -pTigrou007 -e "CREATE USER 'Son_Goku'@'localhost' IDENTIFIED BY 'Bouhhle2_cristal4';"
sudo mysql -u root -pTigrou007 -e "GRANT USAGE ON login_page.* TO 'Son_Goku'@'localhost';"
sudo mysql -u root -pTigrou007 -e "GRANT SELECT ON login_page.utilisateurs TO 'Son_Goku'@'localhost';"
sudo mysql -u root -pTigrou007 -e "FLUSH PRIVILEGES;"

# Redémarrage d'Apache pour prendre en compte la nouvelle configuration
sudo systemctl restart apache2.service
sudo systemctl restart mariadb.service
sudo systemctl restart mysql.service

sudo cat << EOF >> /etc/ssh/sshd_config
# Ajout de la configuration pour la connexion SSH
AllowGroups sshd
EOF
# Création du programme vulnérable
# Insertion du code source du programme vulnérable
sudo cat << EOF > /home/luffy/script_config.c
#include <stdio.h>
#include <stdlib.h>

void process_input(char *user_input) {
    // Utilisation de la fonction system avec des paramètres
    
    char command[100];
    sprintf(command, "echo %s", user_input);
    
    // Exécution de la commande système
    system(command);
}

int main() {
    char input[50];

    // Code pour obtenir l'entrée utilisateur
    printf("Entrez un texte : ");
    fgets(input, sizeof(input), stdin);

    process_input(input);

    return 0;
}
EOF

sudo chown root:root /home/luffy/script_config.c
sudo chmod +s /home/luffy/script_config.c

# Compilation du programme vulnérable avec attribut setuid
sudo gcc /home/luffy/script_config.c -o /home/luffy/script_config
sudo chmod +s /home/luffy/script_config
sudo chown root:root /home/luffy/script_config
sudo rm /home/luffy/script_config.c

## Effacer l'historique des commandes
history -c
> /home/luffy/.bash_history
> /home/killua/.bash_history
> /home/Rengoku/.bash_history
> /home/muten_roshi/.bash_history
> /root/.bash_history
