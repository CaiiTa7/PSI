#!/bin/bash
cat << EOF > /home/luffy/script_config.c
#include <stdio.h>
#include <stdlib.h>

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
