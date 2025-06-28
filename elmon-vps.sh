#!/bin/bash

#----------[ COLOR CODES ]----------#
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
purple='\e[1;35m'
cyan='\e[1;36m'
plain='\e[0m'

#----------[ LANGUAGE SELECTION ]----------#
echo -e "${green}Choose language | اختر اللغة"
echo -e "${cyan}1) English"
echo -e "2) العربية"
read -p "Select | اختر: " lang

if [[ $lang == "2" ]]; then
  export LANG=ar
else
  export LANG=en
fi

#----------[ SHOW BANNER ]----------#
show_banner() {
  echo -e "${blue}"
  echo "═══════════════════════════════════"
  echo "      🚀 EL-MON VPS MANAGER 🚀     "
  echo "═══════════════════════════════════"
  echo -e "${plain}"
}

#----------[ MAIN MENU ]----------#
main_menu() {
  clear
  show_banner
  echo -e "${green}"
  echo "1) Create SSH Account"
  echo "2) Create Trial Account"
  echo "3) Delete Account"
  echo "4) List Users"
  echo "5) Generate Config Files"
  echo "6) Show Active Ports"
  echo "7) Show Protocol Ports"
  echo "8) Server Info"
  echo "9) Change Language"
  echo "00) Exit"
  echo -e "${plain}"
  read -p "Select: " menu
  case $menu in
    1) create_account ;;
    2) create_trial ;;
    3) delete_account ;;
    4) list_users ;;
    5) generate_config ;;
    6) show_open_ports ;;
    7) show_protocol_ports ;;
    8) server_info ;;
    9) change_language ;;
    00) exit ;;
    *) echo -e "${red}Invalid option" ; sleep 1 ; main_menu ;;
  esac
}

#----------[ CREATE SSH ACCOUNT ]----------#
create_account() {
  clear
  show_banner
  read -p "Enter username: " user
  read -p "Enter password: " pass
  echo -e "${green}Choose validity period:"
  echo "1) 1 day"
  echo "2) 3 days"
  echo "3) 7 days"
  echo "4) 14 days"
  echo "5) 30 days"
  read -p "Select: " period
  case $period in
    1) expire=$(date -d "+1 day" +%Y-%m-%d) ;;
    2) expire=$(date -d "+3 day" +%Y-%m-%d) ;;
    3) expire=$(date -d "+7 day" +%Y-%m-%d) ;;
    4) expire=$(date -d "+14 day" +%Y-%m-%d) ;;
    5) expire=$(date -d "+30 day" +%Y-%m-%d) ;;
    *) echo "Invalid"; sleep 1; main_menu ;;
  esac
  useradd -e $expire -s /bin/false -M $user
  echo "$user:$pass" | chpasswd
  echo -e "${green}Account Created!"
  echo "Username: $user"
  echo "Password: $pass"
  echo "Expires: $expire"
  sleep 2
  choose_app "$user" "$pass" "$expire"
}

#----------[ CREATE TRIAL ACCOUNT ]----------#
create_trial() {
  clear
  show_banner
  user="Trial-$(tr -dc A-Za-z0-9 </dev/urandom | head -c4)"
  pass="123"
  echo -e "${green}Enter trial duration:"
  read -p "Hours: " hr
  if [[ $hr == "0" ]]; then
    read -p "Minutes: " min
    expire=$(date -d "+$min minutes" +%Y-%m-%dT%H:%M)
  else
    read -p "Minutes: " min
    expire=$(date -d "+$hr hour +$min minute" +%Y-%m-%dT%H:%M)
  fi
  useradd -e $(date -d "$expire" +%Y-%m-%d) -s /bin/false -M $user
  echo "$user:$pass" | chpasswd
  echo -e "${green}Trial Account Created!"
  echo "Username: $user"
  echo "Password: $pass"
  echo "Expires at: $expire"
  sleep 2
  choose_app "$user" "$pass" "$expire"
}
#----------[ CHOOSE CONFIG APP ]----------#
choose_app() {
  clear
  echo -e "${cyan}Choose config format:"
  echo "1) HTTP Custom (.hc)"
  echo "2) NapsternetV (.txt)"
  echo "3) v2rayNG (.json)"
  echo "4) ShadowSocks (ss://)"
  echo "5) HA Tunnel (.hat)"
  echo "6) DarkTunnel (.dark)"
  echo "7) OpenVPN (.ovpn)"
  echo "8) TLS Tunnel (.tls)"
  echo "9) NetMod (.nm)"
  echo "10) HTTP Injector (.ehi)"
  echo "0) Back"
  echo "00) Exit"
  read -p "Select: " app
  case $app in
    1) generate_config_file "$1" "$2" "$3" "hc" ;;
    2) generate_config_file "$1" "$2" "$3" "txt" ;;
    3) generate_config_file "$1" "$2" "$3" "json" ;;
    4) generate_config_file "$1" "$2" "$3" "ss" ;;
    5) generate_config_file "$1" "$2" "$3" "hat" ;;
    6) generate_config_file "$1" "$2" "$3" "dark" ;;
    7) generate_config_file "$1" "$2" "$3" "ovpn" ;;
    8) generate_config_file "$1" "$2" "$3" "tls" ;;
    9) generate_config_file "$1" "$2" "$3" "nm" ;;
    10) generate_config_file "$1" "$2" "$3" "ehi" ;;
    0) main_menu ;;
    00) exit ;;
    *) echo "Invalid"; sleep 1; choose_app "$1" "$2" "$3" ;;
  esac
}

#----------[ GENERATE CONFIG FILE ]----------#
generate_config_file() {
  mkdir -p config-files
  filename="${1}_config.$4"
  echo "Username: $1" > config-files/$filename
  echo "Password: $2" >> config-files/$filename
  echo "Expires: $3" >> config-files/$filename
  echo "Protocol: $4" >> config-files/$filename
  echo -e "${green}Config file saved as config-files/$filename"
  sleep 2
  show_connection_banner
  sleep 1
  main_menu
}

#----------[ DELETE ACCOUNT OR CONFIG FILE ]----------#
delete_account() {
  clear
  show_banner
  echo -e "${cyan}Choose what to delete:"
  echo "1) Delete SSH Account"
  echo "2) Delete Config File"
  echo "0) Back"
  echo "00) Exit"
  read -p "Select: " del
  case $del in
    1)
      read -p "Enter username to delete: " deluser
      userdel -r $deluser && echo -e "${green}User $deluser deleted!"
      sleep 2
      main_menu
      ;;
    2)
      cd config-files 2>/dev/null || mkdir -p config-files && cd config-files
      echo -e "${cyan}Available config files:"
      ls
      echo -e "${plain}"
      read -p "Enter file name to delete: " file
      rm -f "$file" && echo -e "${green}File $file deleted!"
      sleep 2
      main_menu
      ;;
    0) main_menu ;;
    00) exit ;;
    *) echo "Invalid"; sleep 1; delete_account ;;
  esac
}

#----------[ LIST USERS ]----------#
list_users() {
  clear
  show_banner
  echo -e "${cyan}Active SSH users:"
  echo "-----------------------------"
  cut -d: -f1 /etc/passwd | grep -v -E "root|nobody|sys" | while read user; do
    exp_date=$(chage -l "$user" | grep "Account expires" | cut -d: -f2)
    echo "$user - Expires:$exp_date"
  done
  echo "-----------------------------"
  read -p "Press enter to return..." temp
  main_menu
}

#----------[ ACTIVE OPEN PORTS ]----------#
show_open_ports() {
  clear
  show_banner
  echo -e "${cyan}Active Listening Ports:"
  ss -tunlp | grep LISTEN
  echo -e "${plain}"
  read -p "Press Enter to return..." temp
  main_menu
}

#----------[ PROTOCOL DEFAULT PORTS ]----------#
show_protocol_ports() {
  clear
  show_banner
  echo -e "${cyan}Default Protocol Ports:"
  echo -e "SSH:            22, 443, 143, 80"
  echo -e "Dropbear:       109, 110, 442"
  echo -e "Stunnel:        443, 444"
  echo -e "OpenVPN:        1194"
  echo -e "WebSocket:      80, 8080, 2082"
  echo -e "V2Ray:          8080, 8880, 8443"
  echo -e "Trojan:         2222, 2083"
  echo -e "Shadowsocks:    8388"
  echo -e "WireGuard:      51820"
  echo -e "${plain}"
  read -p "Press Enter to return..." temp
  main_menu
}
#----------[ SERVER INFO ]----------#
server_info() {
  clear
  show_banner
  echo -e "${cyan}Server Information:"
  echo -e "${yellow}IP Address: ${plain}$(curl -s ifconfig.me)"
  echo -e "${yellow}Hostname: ${plain}$(hostname)"
  echo -e "${yellow}Uptime: ${plain}$(uptime -p)"
  echo -e "${yellow}Memory Usage: ${plain}$(free -h | awk '/Mem/ {print $3 "/" $2}')"
  echo -e "${yellow}Disk Usage: ${plain}$(df -h / | awk '/\// {print $3 "/" $2}')"
  echo -e "${yellow}Open Ports: ${plain}$(ss -tuln | grep -c LISTEN)"
  echo -e "${plain}"
  read -p "Press Enter to return..." temp
  main_menu
}

#----------[ BANNER AFTER CONNECTION ]----------#
show_connection_banner() {
  echo -e "\n${blue}╔══════════════════════════════════╗"
  echo -e "${blue}║           ✨ EL-MON VPN ✨        ║"
  echo -e "${blue}║   🔐 جميع البروتوكولات مدعومة    ║"
  echo -e "${blue}║   🎮 يدعم الألعاب والمكالمات     ║"
  echo -e "${blue}║   📱 للتواصل: @M_M_S3            ║"
  echo -e "${blue}╚══════════════════════════════════╝"
}

#----------[ CHANGE LANGUAGE ]----------#
change_language() {
  clear
  echo -e "${green}Choose language | اختر اللغة"
  echo -e "${cyan}1) English"
  echo -e "2) العربية"
  read -p "Select | اختر: " lang
  if [[ $lang == "2" ]]; then
    export LANG=ar
  else
    export LANG=en
  fi
  main_menu
}

#----------[ START SCRIPT ]----------#
main_menu

#----------[ FOOTER ]----------#
# This script is designed by ElMon Dev 💻
# Telegram: @M_M_S3
# Supported by جميع بروتوكولات النت المجاني
# Enjoy and share freely ✨