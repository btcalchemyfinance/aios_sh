#!/bin/bash

# color
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

# log
LOG_FILE="/root/script_progress.log"

# logmessage
log_message() {
    echo -e "$1"
    echo "$(date): $1" >> $LOG_FILE
}

# retry
retry() {
    local n=1
    local max=5
    local delay=10
    while true; do
        "$@" && return 0
        if (( n == max )); then
            return 1
        else
            log_message "Attempt $n/$max failed! Try again in $delay seconds..."
            sleep $delay
        fi
        ((n++))
    done
}

# logo
display_logo() {
    log_message "${GREEN}AlcheyFinanceLogo...${RESET}"
    curl -s https://raw.githubusercontent.com/btcalchemyfinance/Tools/refs/heads/main/logo.sh | bash || handle_error "fail...."
}

# handleerror
handle_error() {
    log_message "$1"
    exit 1
}

# getprivatekey
get_private_key() {
    log_message "${CYAN}Prepare private key...${RESET}"
    read -p "Enter private key: " private_key
    echo -e "$private_key" > /root/key.pem
    chmod 600 /root/key.pem
    log_message "${GREEN}Private key has been saved to /root/key.pem and set the correct permissions.${RESET}"
}

# Check and install Docker
check_and_install_docker() {
    if ! command -v docker &> /dev/null; then
        log_message "${RED}Docker not found. Install Docker...${RESET}"
        retry apt-get update -y || handle_error "Failed to update apt package list. "
        retry apt-get install -y apt-transport-https ca-certificates curl software-properties-common || handle_error "Failed to install dependent packages. "
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - || handle_error "Adding Docker GPG key failed. "
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" || handle_error "Failed to add Docker repository. "
        retry apt update -y || handle_error "Failed to update apt package list. "
        retry apt install -y docker-ce || handle_error "Installation of Docker CE failed. "
        systemctl start docker || handle_error "Failed to start Docker. "
        systemctl enable docker || handle_error "Setting Docker to start automatically after booting fails. "
        log_message "${GREEN}Docker is installed and started. ${RESET}"
    else
        log_message "${GREEN}Docker is installed. ${RESET}"
    fi
}

# Start Docker container
start_container() {
    log_message "${BLUE}Starting Docker container...${RESET}"
    retry docker run -d --name aios-container --restart unless-stopped -v /root:/root kartikhyper/aios-cuda:latest /app/aios-cli start || handle_error "Failed to start Docker container. "
    log_message "${GREEN}Docker container started. ${RESET}"
}

# Waits for container initialization
wait_for_container_to_start() {
    log_message "${CYAN}Waiting for container initialization...${RESET}"
    sleep 60
}

# Check daemon status
check_daemon_status() {
    log_message "${BLUE}Checking daemon status within container...${RESET}"
    docker exec -i aios-container /app/aios-cli status
    if [[ $? -ne 0 ]]; then
        log_message "${RED}Daemon is not running and restarting...${RESET}"
        docker exec -i aios-container /app/aios-cli kill
        sleep 2
        docker exec -i aios-container /app/aios-cli start
        log_message "${GREEN}Daemon has been restarted. ${RESET}"
    else
        log_message "${GREEN}Daemon is running. ${RESET}"
    fi
}

# Install local model
install_local_model() {
    log_message "${BLUE}Installing local model...${RESET}"
    docker exec -i aios-container /app/aios-cli models add hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf || handle_error "Installing local model failed. "
}

# Run inference
run_infer() {
    log_message "${BLUE}Running inference...${RESET}"
    retry docker exec -i aios-container /app/aios-cli infer --model hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf --prompt "What is 'Artificial Intelligence'?" || handle_error "Reasoning task failed. "
    log_message "${GREEN}The reasoning task was successfully completed. ${RESET}"
}

# Login to Hive
hive_login() {
    log_message "${CYAN}Logging in to Hive...${RESET}"
    docker exec -i aios-container /app/aios-cli hive import-keys /root/key.pem || handle_error "Import key failed. "
    docker exec -i aios-container /app/aios-cli hive login || handle_error "Hive login failed. "
    docker exec -i aios-container /app/aios-cli hive connect || handle_error "Failed to connect to Hive. "
    log_message "${GREEN}Hive login successful. ${RESET}"
}

# Run Hive inference
run_hive_infer() {
    log_message "${BLUE}Running Hive Inference...${RESET}"
    retry docker exec -i aios-container /app/aios-cli hive infer --model hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf --prompt "Explain what a server is in simple terms." || handle_error "The Hive inference task failed. "
    log_message "${GREEN}Hive inference task was successfully completed.${RESET}"
}

# Check Hive integration
check_hive_points() {
    log_message "${BLUE}Checking Hive points...${RESET}"
    docker exec -i aios-container /app/aios-cli hive points || log_message "${RED}Unable to obtain Hive credits. ${RESET}"
    log_message "${GREEN}Hive score check completed. ${RESET}"
}

# Get the currently logged in key
get_current_signed_in_keys() {
    log_message "${BLUE}Getting the currently logged in key...${RESET}"
    docker exec -i aios-container /app/aios-cli hive whoami || handle_error "Failed to obtain the key for the current login. "
}

# Clean up the package list
cleanup_package_lists() {
    log_message "${BLUE}Cleaning up package list...${RESET}"
    sudo rm -rf /var/lib/apt/lists/* || handle_error "Failed to clean up package list. "
}

# Main script flow
display_logo
check_and_install_docker
get_private_key
start_container
wait_for_container_to_start
check_daemon_status
install_local_model
run_infer
hive_login
run_hive_infer
check_hive_points
get_current_signed_in_keys
cleanup_package_lists

log_message "${GREEN}All steps completed successfully! ${RESET}"

# A loop that repeats every hour
while true; do
    log_message "${CYAN}Restart the process every 1 hour...${RESET}"

    docker exec -i aios-container /app/aios-cli kill || log_message "${RED}Failed to kill daemon.${RESET}"

    docker exec -i aios-container /app/aios-cli status
    if [[ $? -ne 0 ]]; then
        log_message "${RED}Daemon startup failed, retrying...${RESET}"
    else
        log_message "${GREEN}Daemon is running, status checked. ${RESET}"
    fi

    run_infer

    docker exec -i aios-container /app/aios-cli hive login || log_message "${RED}Hive login failed. ${RESET}"
    docker exec -i aios-container /app/aios-cli hive connect || log_message "${RED}Failed to connect to Hive. ${RESET}"

    run_hive_infer

    log_message "${GREEN}Cycle completed. Wait 1 hour...${RESET}"
    sleep 3600
done &
