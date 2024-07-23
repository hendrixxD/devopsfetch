
# Building _`devopsfetch`_ for Server Information Retrieval and Monitoring

## Objective

To develop a tool for devops named `devopsfetch` that collects and displays system information, including `active ports`, `user logins`, `Nginx configurations`, `Docker images`, and `container statuses`.

This project Implements a _**systemd service**_ to monitor and log these activities continuously.

### Requirements
Information Retrieval:
1. Ports:
   - Display all active ports and services (-p or --port)

     ```ssh
     devopsfetch -p
     ```
     ```
     devopsfetch --port
     ```

   - Provide detailed information about a specific port (-p <port_number>).
     ```ssh
     devopsfetch -p <port_number>
     ```

2. Docker:
   - List all Docker images and containers (-d or --docker).
      ```ssh
      devopsfetch -d
      ```
      ```
      devopsfetch --docker
      ```
   - Provide detailed information about a specific container (-d <container_name>).
     ```ssh
     devopsfetch -d <container_name>
     ```

3. Nginx:
   - Display all Nginx domains and their ports (-n or --nginx).
      ```ssh
      devopsfetch -n
      ```
      ```
      devopsfetch --nginx
      ```
   - Provide detailed configuration information for a specific domain (-n <domain>).
     ```ssh
     devopsfetch -n <domain>
     ```
4. Users:
   - List all users and their last login times (-u or --users)
     ```ssh
      devopsfetch -u
      ```
      ```
      devopsfetch --users
      ```
   - Provide detailed information about a specific user (-u <username>)
     ```ssh
     devopsfetch -u <username>
     ```
5. Time Range:
   - Display activities within a specified time range (-t or --time).
     ```ssh
      devopsfetch -t <from_date_or_time> <to_date_or_time>
      ```
      or
      ```
      devopsfetch --time <date>
      ```

### Output Formatting
- All outputs are formatted for readability, in well formatted tables with descriptive column names.

### Installation Script
- An `install.sh` script is available with necessary dependencies and set up a systemd service to monitor and log activities.
- Continuous monitoring mode is implemented with logging to a file, ensuring log rotation and management.
Help and Documentation:
- A help flag -h or --help guide is implemenetd to provide usage instructions for the program.
- A clear and comprehensive documentation covering:
   - Installation and configuration steps.
   - Usage examples for each command-line flag.
   - The logging mechanism and how to retrieve logs
  is available in [Documentation](./Documentation.md)


_Stage5 Devops MID INTERNSHIP TASK_
