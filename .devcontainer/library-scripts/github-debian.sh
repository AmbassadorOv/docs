

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enhancing Shell Script Quality and Robustness</title>
</head>
<body>
    <h1>Enhancing Shell Script Quality and Robustness</h1>
    <p>Shell scripting is a powerful tool for automating tasks and managing systems. However, writing robust and maintainable scripts requires adherence to best practices and effective error handling. This essay explores various strategies to improve the quality of shell scripts, focusing on error handling, best practices, and handling multiple commands.</p>

    <h2>Setting the Foundation</h2>
    <p>A solid foundation for any shell script begins with setting strict error handling modes. Using <code>set -euo pipefail</code> ensures that the script exits on errors, treats unset variables as errors, and catches errors in pipelines. This combination is crucial for preventing unexpected behavior and making debugging easier.</p>
    <pre><code>set -euo pipefail</code></pre>

    <h2>Meaningful Variable Names and Comments</h2>
    <p>Using clear and descriptive variable names enhances the readability and maintainability of scripts. Additionally, commenting on complex commands or sections helps others (and your future self) understand the script's purpose and logic.</p>
    <pre><code>CLI_VERSION=${1:-"latest"}</code></pre>

    <h2>Checking for Dependencies</h2>
    <p>Before running commands, it's essential to ensure that all required tools are available. This can be done using <code>command -v</code> to check if a command exists, providing a graceful exit if a dependency is missing.</p>
    <pre><code>if ! command -v curl &gt; /dev/null; then
    echo "curl could not be found"
    exit 1
fi</code></pre>

    <h2>Using Functions and Traps</h2>
    <p>Breaking the script into functions makes it modular and easier to read. Functions also facilitate reusability and testing. Additionally, using <code>trap</code> to handle signals ensures that cleanup actions are performed even if the script exits unexpectedly.</p>
    <pre><code>cleanup() {
    echo "Cleaning up..."
    # Add cleanup commands here
}
trap cleanup EXIT</code></pre>

    <h2>Error Handling with Specific Codes</h2>
    <p>Handling specific error codes allows for more precise responses to different types of errors. Using a <code>case</code> statement to handle different exit codes provides clear feedback on what went wrong.</p>
    <pre><code>handle_error() {
    local exit_code=$1
    case $exit_code in
        6)
            echo "Error: Could not resolve host (exit code 6)"
            ;;
        7)
            echo "Error: Failed to connect to host (exit code 7)"
            ;;
        22)
            echo "Error: HTTP page not retrieved (exit code 22)"
            ;;
        28)
            echo "Error: Operation timeout (exit code 28)"
            ;;
        *)
            echo "Error: Unknown error (exit code $exit_code)"
            ;;
    esac
    exit $exit_code
}</code></pre>

    <h2>Handling Multiple Commands</h2>
    <p>When handling multiple commands, it's important to check the exit status of each command and handle errors appropriately. This ensures that each step is verified for success, and appropriate actions are taken if any command fails.</p>
    <pre><code>echo "Updating package list..."
if ! apt-get update; then
    exit_code=$?
    handle_error $exit_code
fi

echo "Installing curl..."
if ! apt-get install -y curl; then
    exit_code=$?
    handle_error $exit_code
fi

echo "Downloading file from $URL..."
if ! curl -o "$OUTPUT" -sSL "$URL"; then
    exit_code=$?
    handle_error $exit_code
fi

echo "File downloaded successfully to $OUTPUT"

echo "Installing downloaded file..."
if ! dpkg -i "$OUTPUT"; then
    exit_code=$?
    handle_error $exit_code
fi

echo "Installation completed successfully"</code></pre>

    <h2>Conclusion</h2>
    <p>By following these best practices and focusing on robust error handling, you can significantly improve the quality and reliability of your shell scripts. Clear variable names, comprehensive comments, dependency checks, modular functions, and specific error handling all contribute to creating maintainable and effective scripts. These strategies ensure that your scripts not only perform their intended tasks but also handle errors gracefully, providing a better user experience and easier maintenance.</p>

    <h2>Real-World Script Examples</h2>

    <h3>1. Automated Backup Script</h3>
    <pre><code>#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="/path/to/source"
BACKUP_DIR="/path/to/backup"
LOG_FILE="/var/log/backup.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

backup() {
    if [ ! -d "$SOURCE_DIR" ]; then
        log "Error: Source directory $SOURCE_DIR does not exist."
        exit 1
    fi

    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi

    rsync -av --delete "$SOURCE_DIR" "$BACKUP_DIR"
    log "Backup of $SOURCE_DIR completed successfully."
}

trap 'log "Backup script terminated unexpectedly."; exit 1' ERR
log "Starting backup of $SOURCE_DIR to $BACKUP_DIR"
backup
log "Backup script completed successfully."</code></pre>

    <h3>2. System Monitoring Script</h3>
    <pre><code>#!/usr/bin/env bash
set -euo pipefail

CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90
ALERT_EMAIL="admin@example.com"

check_cpu() {
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        echo "CPU usage is above threshold: $cpu_usage%" | mail -s "CPU Alert" "$ALERT_EMAIL"
    fi
}

check_memory() {
    local mem_usage
    mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    if (( $(echo "$mem_usage > $MEM_THRESHOLD" | bc -l) )); then
        echo "Memory usage is above threshold: $mem_usage%" | mail -s "Memory Alert" "$ALERT_EMAIL"
    fi
}

check_disk() {
    local disk_usage
    disk_usage=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        echo "Disk usage is above threshold: $disk_usage%" | mail -s "Disk Alert" "$ALERT_EMAIL"
    fi
}

check_cpu
check_memory
check_disk</code></pre>

    <h3>3. Log Rotation Script</h3>
    <pre><code>#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/myapp.log"
BACKUP_DIR="/var/log/backup"
MAX_BACKUPS=5

rotate_logs() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi

    mv "$LOG_FILE" "$BACKUP_DIR/myapp.log.$(date '+%Y%m%d%H%M%S')"
    touch "$LOG_FILE"

    local backups
    backups=$(ls -1 "$BACKUP_DIR" | wc -l)
    if [ "$backups" -gt "$MAX_BACKUPS" ]; then
        ls -1t "$BACKUP_DIR" | tail -n +$(($MAX_BACKUPS + 1)) | xargs -I {} rm -f "$BACKUP_DIR/{}"
    fi
}

rotate_logs</code></pre>

    <h3>4. User Account Management Script</h3>
    <pre><code>#!/usr/bin/env bash
set -euo pipefail

USERNAME=$1
PASSWORD=$2

if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
    exit 1
fi

useradd -m -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "User $USERNAME created successfully."</code></pre>
</body>
</html>
```

This HTML document includes all the content we discussed, formatted for easy reading and understanding. You can save this as an `.html` file and open it in a web browser to view the formatted content. If you need any further adjustments or additions, feel free to let me know!

מקור: שיחה עם Copilot 13.11.2024
(1) github.com. https://github.com/captainlee1024/scripts/tree/423b6b36e0309b0daa5c6f985aff5f6c61673330/dwm-status.sh.