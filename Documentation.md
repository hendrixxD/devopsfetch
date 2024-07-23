                                                            devopsfetch

DevOpsFetch is a bash-based system information retrieval and monitoring tool designed for DevOps professionals. It collects and displays information about active ports, user logins, Nginx configurations, Docker images, and container statuses.

### Installation

1. Clone this repository

   ```ssh
   git clone https://github.com/yourusername/devopsfetch.git
   ```
   ```
   cd devopsfetch
   ```

2. Run the installation script with root privileges:
   ```ssh
   chmod +x install.sh
   ```
   ```
   sudo ./install.sh
   ```
   This will install the necessary dependencies, set up the `devopsfetch` script, and create a systemd service for continuous monitoring.

## Usage

_`devopsfetch`_ can be used with the following command-line flags:

- `-p` or `--port`: Display active ports or info about a specific port
  - `devopsfetch -p` : List all active ports
  - `devopsfetch -p 80` : Get information about port 80

- `-d` or `--docker`: Display Docker information or info about a specific container
  - `devopsfetch -d` : List all Docker containers
  - `devopsfetch -d container_name` : Get information about a specific container

- `-n` or `--nginx`: Display Nginx information or info about a specific domain
  - `devopsfetch -n` : List all Nginx domains and their ports
  - `devopsfetch -n <domain>` : Get configuration for example.com

- `-u` or `--users`: Display user login information or info about a specific user
  - `devopsfetch -u` : List all users and their last login times
  - `devopsfetch -u username` : Get detailed information about a specific user

- `-t` or `--time`: Display activities within a specified time range
  - `devopsfetch -t 2023-07-18 2023-07-22` : Get activities between the specified dates
  - `devopsfetch --time 2024-07-18 2024-07-23`: returns all server activities from 18th till today.
  - `devopsfetch --time 2024-07-22`: returns all server activities `july 22nd`.

Also, for help on how to use any of the flags
- `-h` or `--help`: Display help information

## Continuous Monitoring

The installation script sets up a systemd service that runs `devopsfetch` every hour, collecting information from the past hour.

The service logs can be viewed using:
  ```ssh
  sudo journalctl -u devopsfetch.service
  ```
**To manually start, stop, or restart the service**
  ```ssh
  sudo systemctl start devopsfetch.service
  ```
  ```
  sudo systemctl stop devopsfetch.service
  ```
  ```
  sudo systemctl restart devopsfetch.service
  ```

## Log Rotation

Log rotation is handled by systemd's built-in log management. By default, it will compress and rotate logs when they reach a certain size or age. this behavior can be customized by editing the journald configuration file:

  ```ssh
  sudo vim /etc/systemd/journald.conf
  ```
If you wish to make any change, edit the file and restart the `journald` service:
  ```ssh
  sudo systemctl restart systemd-journald
  ```

## Troubleshooting

If  at anypoint you encounter any issues, please check the following:

1. Ensure all dependencies are correctly installed.
2. Verify that the `devopsfetch` script has execute permissions.
   ```ssh
   chmod +x devopsfetch
   ```
3. Check the systemd service status:
   ```ssh
   sudo systemctl _status devopsfetch.service
   ```
4. Review the service logs for any error messages
   ```
   sudo journalctl -u devopsfetch.service
   ```

## Detailed Usage Examples

1. Ports Information:
- To display all active ports:
  ```
  devopsfetch -p
  ```
- To get info about a specific port (e.g., 80):
  ```
  devopsfetch -p 80
  ```

2. Docker Information:
- To list all Docker containers:
  ```
  devopsfetch -d
  ```
- To get info about a specific container:
  ```
  devopsfetch -d my_container
  ```

3. Nginx Information:
- To display all Nginx domains and their ports:
  ```
  devopsfetch -n
  ```
- To get configuration for a specific domain:
  ```
  devopsfetch -n <domain>
  ```

4. User Information:
- To list all users and their last login times:
  ```
  devopsfetch -u
  ```
- To get detailed info about a specific user:
  ```
  devopsfetch -u hendrixx
  ```

5. Time Range Information:
- To display activities within a specified time range:
  ```
  devopsfetch -t 2023-07-18 2023-07-22
  ```

Remember, you will require root privileges to run these commands. In such cases, use `sudo`
