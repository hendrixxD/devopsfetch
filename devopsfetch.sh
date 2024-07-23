#!/bin/bash

# devopsfetch.sh

# 1.0 Function to display all active ports
show_active_ports() {
  echo "Active Ports       Services"
  echo "----------------------------"
  if [ -z "$1" ]; then
    ss -tuln | awk 'NR>1 {print $1, $5}' | while read -r protocol port; do
      service=$(lsof -i -P -n | grep "$port" | awk '{print $1}' | uniq)
      echo "$user $port $service"
    done | column -t
  else
    ss -tuln | grep ":$1" | awk '{print $1, $5}' | while read -r protocol port; do
      service=$(lsof -i -P -n | grep "$port" | awk '{print $1}' | uniq)
      echo "$user $port $service"
    done | column -t
  fi
}

# 1.1 Function to display port info
show_port_info() {
    port=$1
    process=$(lsof -i :$port -sTCP:LISTEN -t)
    if [ ! -z "$process" ]; then
        echo "Port $port is used by $(ps -p $process -o comm=) (PID: $process)"
    else
        echo "No process found listening on port $port"
    fi
}

# 2.0 Function to list all docker images and containers
show_docker_info() {
    echo "Docker Containers:"
    docker ps -a --format "table {{.Image}}\t{{.Names}}\t{{.Status}}"
}

# 2.1 Function to display container info
show_container_info() {
    container=$1
    if docker inspect $container &>/dev/null; then
        docker inspect $container | jq '.[0] | {Name: .Name, Image: .Config.Image, Status: .State.Status, Created: .Created, Ports: .NetworkSettings.Ports}'
    else
        echo "Container '$container' not found"
    fi
}

# Display all Nginx domains and their ports
show_nginx_info() {
    echo "Nginx Domains and Ports:"
    nginx -T 2>/dev/null | awk '
        /server_name/ {
            server_name = $0
            gsub(/;/, "", server_name)
            gsub(/server_name/, "", server_name)
        }
        /listen/ && !/default_server/ {
            listen = $0
            gsub(/;/, "", listen)
            gsub(/listen/, "", listen)
            print server_name " -> " listen
        }
    ' | sort | uniq | sed 's/^ *//'
}

# Function to display Nginx domain info
show_nginx_info() {
    echo "+$(printf '%0.s-' {1..30})+$(printf '%0.s-' {1..25})+$(printf '%0.s-' {1..50})+"
    printf "| %-28s | %-23s | %-48s |\n" "Server Domain" "Proxy" "Configuration File"
    echo "+$(printf '%0.s-' {1..30})+$(printf '%0.s-' {1..25})+$(printf '%0.s-' {1..50})+"

    nginx -T 2>/dev/null | awk '
    function trim(s) {
        sub(/^[ \t\r\n]+/, "", s)
        sub(/[ \t\r\n]+$/, "", s)
        return s
    }
    /server_name/ {
        server_name = $0
        gsub(/;/, "", server_name)
        gsub(/server_name/, "", server_name)
        server_name = trim(server_name)
    }
    /listen/ && !/default_server/ {
        listen = $0
        gsub(/;/, "", listen)
        gsub(/listen/, "", listen)
        listen = trim(listen)
    }
    /include/ && /sites-enabled/ {
        config_file = $2
        gsub(/;/, "", config_file)
        config_file = trim(config_file)
        printf "| %-28s | %-23s | %-48s |\n", server_name, "http://" listen, config_file
    }
    '

    echo "+$(printf '%0.s-' {1..30})+$(printf '%0.s-' {1..25})+$(printf '%0.s-' {1..50})+"
}

# Function to display all users and their last login times
show_user_logins() {
  echo "USERS                Last-Login"
  echo "--------------------------------"
  cut -d: -f1 /etc/passwd | while read -r user; do
    last_login=$(last -n 1 "$user" | awk 'NR==1 {print $4, $5, $6, $7}')
    if [ -z "$last_login" ]; then
      last_login="Never logged in"
    fi
    echo "$user $last_login"
  done | column -t
}

# displays a specfic user info
show_user_info() {
    user=$1
    if id "$user" >/dev/null 2>&1; then
        echo "Detailed information for user: $user"
        echo "--------------------------------------"
        echo "USER ID -- and -- GROUPS:"
        id "$user"
        echo
        echo "Last Login:"
        last -n 1 "$user"
        echo
        echo "Home Directory:"
        eval echo ~"$user"
        echo
        echo "Shell:"
        grep "^$user:" /etc/passwd | cut -d: -f7
    else
        echo "User $user does not exist"
    fi
}

# Function to display activities within a specified time range
display_time_range() {
    local start_date="$1"
    local end_date="$2"

    if [ -z "$end_date" ]; then
        # If only one date is provided, show logs for that entire day
        echo "Displaying logs for $start_date"
        journalctl --since "$start_date" --until "$start_date 23:59:59"
    else
        # If two dates are provided, use them as the range
        echo "Displaying logs from $start_date to $end_date"
        journalctl --since "$start_date" --until "$end_date 23:59:59"
    fi
    journalctl --since "$start_date" --until "$end_date"
}

# Main execution
case "$1" in
    -p|--port)
        if [ -z "$2" ]; then
            show_active_ports
        else
            show_port_info $2
        fi
        ;;
    -d|--docker)
        if [ -z "$2" ]; then
            show_docker_info
        else
            show_container_info $2
        fi
        ;;
    -n|--nginx)
        if [ -z "$2" ]; then
            show_nginx_info
        else
            show_nginx_domain_info $2
        fi
        ;;
    -u|--users)
        if [ -z "$2" ]; then
            show_user_logins
        else
            show_user_info $2
        fi
        shift
        shift
        ;;
    -t|--time)
        if [ -z "$2" ]; then
          echo "Error: At least one date must be provided."
          echo "Usage: devopsfetch -t YYYY-MM-DD [YYYY-MM-DD]"
          exit 1
        elif [ -z "$3" ]; then
          display_time_range "$2"
        else
          display_time_range "$2" "$3"
        fi
        ;;
    -h|--help)
        echo "Usage: devopsfetch [OPTION]"
        echo "|----------------------------------------------------------------------|"
        echo "|  -p                     | Show all active ports                      |"
        echo "|----------------------------------------------------------------------|"
        echo "|  --port [PORT]          | Show info about a specific port            |"
        echo "|----------------------------------------------------------------------|"
        echo "|  -d                     | Show all Docker containers                 |"
        echo "|----------------------------------------------------------------------|"
        echo "|  --docker [NAME]        | Show info about a specific container       |"
        echo "|----------------------------------------------------------------------|"
        echo "|  -n                     | Show all Nginx domains                     |"
        echo "|----------------------------------------------------------------------|"
        echo "|  --nginx [DOMAIN]       | Show info about a specific domain          |"
        echo "|----------------------------------------------------------------------|"
        echo "|  -u                     | Show all user logins                       |"
        echo "|----------------------------------------------------------------------|"
        echo "|  --users [USER]         | Show info about a specific user            |"
        echo "|----------------------------------------------------------------------|"
        echo "|  -t, --time [FROM] [TO] | Show activities within a time range        |"
        echo "|----------------------------------------------------------------------|"
        echo "|  usage:                                                              |"
        echo "|         --time 2024-07-20                                            |"
        echo "|----------------------------------------------------------------------|"
        echo "|         | Displays server infor for this date                        |"
        echo "|----------------------------------------------------------------------|"
        echo "|         --time 2024-07-22 2024-07-23                                 |"
        echo "|--------------------------------------------------------------------- |"
        echo "|         | Displays the server from 22nd to 23rd                      |"
        echo "|----------------------------------------------------------------------|"
        echo "|  -h, --help             | Show this help message                     |"
        echo "|----------------------------------------------------------------------|"
        ;;
    *)
        echo "Invalid option. Use -h or --help for usage information."
        exit 1
        ;;
esac


show_nginx_info() {
    echo "---------------------------------------------------------"
    echo "| Server Domain | Proxy            | Configuration File |"
    echo "---------------------------------------------------------"
    nginx -T 2>/dev/null | awk '
        /server_name/ {
            server_name = $0
            gsub(/;/, "", server_name)
            gsub(/server_name/, "", server_name)
        }
        /listen/ && !/default_server/ {
            listen = $0
            gsub(/;/, "", listen)
            gsub(/listen/, "", listen)
        }
        /location/ {
            proxy = $0
            gsub(/proxy_pass/, "", proxy)
            gsub(/;/, "", proxy)
        }
        /include/ && /conf/ {
            config_file = $0
            gsub(/include/, "", config_file)
            gsub(/;/, "", config_file)
            print "| " server_name " | " listen " | " config_file " |"
        }
    ' | sort | uniq | sed 's/^ *//'
    echo "----------------------------------------------"
}
