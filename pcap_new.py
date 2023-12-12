from scapy.all import *
import random
import socket
import binascii
import base64

# Liste des protocoles possibles
protocols = [TCP, UDP, ICMP]

# Initialise la liste pour stocker les paquets
icmp_packets = []
http_dns_smtp_packets = []

# Génération aléatoire des paquets pour différents protocoles
for protocol in protocols:
    for _ in range(20):
        # Génération aléatoire des adresses IP source et destination
        source_ip = socket.inet_ntoa(struct.pack('>I', random.randint(1, 0xffffffff)))
        destination_ip = socket.inet_ntoa(struct.pack('>I', random.randint(1, 0xffffffff)))

        # Génération de ports source et destination aléatoires
        source_port = random.randint(1024, 65535)
        destination_port = random.randint(1024, 65535)

        # Création d'un paquet en fonction du protocole choisi
        if protocol == TCP:
            # Données TCP aléatoires
            if random.randint(0, 1) == 1:
                tcp_data = binascii.b2a_hex(os.urandom(10)).decode()
            else:
                tcp_data = ""
            packet = IP(src=source_ip, dst=destination_ip) / TCP(sport=source_port, dport=destination_port) / Raw(load=tcp_data)
        elif protocol == UDP:
            # Données UDP aléatoires
            if random.randint(0, 1) == 1:
                udp_data = binascii.b2a_hex(os.urandom(10)).decode()
            else:
                udp_data = ""
            packet = IP(src=source_ip, dst=destination_ip) / UDP(sport=source_port, dport=destination_port) / Raw(load=udp_data)

        elif protocol == ICMP:
            icmp_id = random.randint(1, 65535)
            icmp_request = IP(src=source_ip, dst=destination_ip) / ICMP(type="echo-request", id=icmp_id)
            icmp_reply = IP(src=destination_ip, dst=source_ip) / ICMP(type="echo-reply", id=icmp_id)

            # Ajouter le paquet ICMP (ping request) à la liste
            icmp_packets.append(icmp_request)
            # Ajouter le paquet ICMP (ping reply) à la liste
            icmp_packets.append(icmp_reply)

        http_dns_smtp_packets.append(packet)

# Messages aléatoires pour HTTP, DNS et SMTP
messages = ["Bien essayé !", "Essaie encore", "Pas ici !", "Tu y es presque", "Continue comme ça"]

# Types DNS possibles
dns_types = ["A", "AAAA", "MX", "NS", "TXT", "SRV"]

# Génération de paquets DNS avec des messages aléatoires et types aléatoires
for _ in range(20):
    source_ip = socket.inet_ntoa(struct.pack('>I', random.randint(1, 0xffffffff)))
    destination_ip = socket.inet_ntoa(struct.pack('>I', random.randint(1, 0xffffffff)))
    source_port = random.randint(1024, 65535)
    destination_port = 53  # Port DNS
    dns_type = random.choice(dns_types)
    dns_query = DNS(rd=1, qd=DNSQR(qname="example.com", qtype=dns_type))
    if random.randint(0, 1) == 1:
        dns_query /= random.choice(messages)
    packet = IP(src=source_ip, dst=destination_ip) / UDP(sport=source_port, dport=destination_port) / dns_query
    http_dns_smtp_packets.append(packet)
# Créer un paquet DNS avec base64_message
base64_message = "RkxBRzp7V2VsbCBET25lIHUgRm91bmQgaXRfIE1heWJlL2l0J3Mgbm90IGZpbmlzaC4uLiBTU0ggPyBUcnkgdXNlciBtdXRlbl9yb3NoaX0="
dns_packet = IP(dst=destination_ip) / UDP(sport=source_port, dport=53) / \
             DNS(rd=1, qd=DNSQR(qname="@henallux.be", qtype=dns_type), ar=DNSRR(rrname="henallux.be", type="TXT", rdata=base64_message))
http_dns_smtp_packets.append(dns_packet)
# Génération de paquets SMTP avec des messages aléatoires
for _ in range(20):
    source_ip = socket.inet_ntoa(struct.pack('>I', random.randint(1, 0xffffffff)))
    destination_ip = socket.inet_ntoa(struct.pack('>I', random.randint(1, 0xffffffff)))
    source_port = random.randint(1024, 65535)
    destination_port = 25  # Port SMTP
    smtp_data = "HELO hint.com\r\nMAIL FROM: <muten_roshi@ssh.hugehint>\r\nRCPT TO: <ihopeyouhaveit@henallux.com>\r\nDATA\r\n"
    if random.randint(0, 1) == 1:
        smtp_data += random.choice(messages) + "\r\n"
    smtp_data += ".\r\nQUIT"
    packet = IP(src=source_ip, dst=destination_ip) / TCP(sport=source_port, dport=destination_port) / smtp_data
    http_dns_smtp_packets.append(packet)

# Génération de paquets HTTP avec des messages aléatoires
for _ in range(20):
    source_ip = socket.inet_ntoa(struct.pack('>I', random.randint(1, 0xffffffff)))
    destination_ip = socket.inet_ntoa(struct.pack('>I', random.randint(1, 0xffffffff)))
    source_port = random.randint(1024, 65535)
    destination_port = 80  # Port HTTP
    http_data = "GET / HTTP/1.1\r\nHost: example.com\r\n\r\n"
    if random.randint(0, 1) == 1:
        http_data += random.choice(messages)
    packet = IP(src=source_ip, dst=destination_ip) / TCP(sport=source_port, dport=destination_port) / http_data
    http_dns_smtp_packets.append(packet)

# Lien YouTube
youtube_link = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
# Créer un paquet HTTP avec la méthode GET pour accéder au lien YouTube
http_request = IP(dst=destination_ip) / TCP() /  Raw(f"GET / HTTP/1.1\r\n{youtube_link}\r\n\r\n")
# Ajouter le paquet HTTP à la liste des paquets
http_dns_smtp_packets.append(http_request)

combined_packets = icmp_packets + http_dns_smtp_packets

# Écrire la liste de paquets combinés dans un fichier PCAP
wrpcap("network.pcap", combined_packets)
