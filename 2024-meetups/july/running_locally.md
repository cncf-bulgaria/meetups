# Running Unikraft unikernel locally

## Database preparation

1. Start MariaDB
   ```bash
   docker run --platform linux/amd64 --name mariadb -d -e MARIADB_ROOT_PASSWORD=MySecretPassword -p 3306:3306 mariadb
   ```

1. Wait until MariaDB starts
   ```bash
   docker logs -f mariadb
   clear
   ```

1. Create application database
   ```bash
   docker exec -ti mariadb mariadb -u root -pMySecretPassword -e "CREATE DATABASE company_db;"
   ```

1. Create a table
   ```bash
   docker exec -ti mariadb mariadb -u root -pMySecretPassword -e \
      "USE company_db; \
       CREATE TABLE employee (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL, position VARCHAR(100), salary DECIMAL(10, 2), hire_date DATE);"
   ```

1. Insert data into the table
   ```bash
   docker exec -ti mariadb mariadb -u root -pMySecretPassword -e "USE company_db; INSERT INTO employee (name, position, salary, hire_date) VALUES \
       ('John Doe', 'Software Engineer', 70000, '2020-01-15'), \
       ('Jane Smith', 'Project Manager', 85000, '2020-02-20'), \
       ('Emily Johnson', 'Database Administrator', 90000, '2020-03-25'), \
       ('Michael Brown', 'System Analyst', 75000, '2020-04-30'), \
       ('Jessica Davis', 'Web Developer', 68000, '2020-05-05'), \
       ('Daniel Miller', 'IT Support Specialist', 62000, '2020-06-10'), \
       ('Laura Wilson', 'UX Designer', 76000, '2020-07-15'), \
       ('Robert Moore', 'Cloud Solutions Architect', 98000, '2020-08-20'), \
       ('Sarah Taylor', 'Security Analyst', 83000, '2020-09-25'), \
       ('James Anderson', 'DevOps Engineer', 87000, '2020-10-30');"
   ```

1. Create application user
   ```bash
   docker exec -ti mariadb mariadb -u root -pMySecretPassword -e "CREATE USER 'app_user'@'%' IDENTIFIED VIA unix_socket OR mysql_native_password USING PASSWORD('app_password'); \
       GRANT SELECT ON company_db.employee TO 'app_user'@'%'; \
       FLUSH PRIVILEGES;"
   ```

1. Verify if the application user can read the data
   ```bash
   docker exec -ti mariadb mariadb -u app_user -papp_password -e "USE company_db; SELECT * FROM employee;"
   clear
   ```

## Build and run the unikernel

1. Install the prerequisites
   On MacOS
   ```bash
   brew install yq jq curl
   ```
   On Linux (Debian/Ubuntu)
   ```bash
   sudo apt update
   sudo apt install -y yq jq curl
   ```

1. Update the database address in conf/config.yaml
   Since the unikernel is running in a VM, and the database in a Docker container, they are not in the same network.  
   In order the application to reach the database, we will be using the IP address of our primary interface.  
   On MacOS
   ```bash
   yq e ".db_host = \"$(ipconfig getifaddr en0)\"" -i conf/config.yaml
   ```
   On Linux
   ```bash
   yq -iy ".db_host = \"$(hostname -I | awk '{print $1}')\"" conf/config.yaml
   ```
   Note: On Linux it is possible to configure network which can be used by Docker and Kraft.  

1. Build and run the unikernel
   ```bash
   kraft run --log-level debug --log-type fancy -v ./conf:/conf -p 8080:8080 --plat qemu --arch x86_64
   ```

1. Send an HTTP request to the unikernel
   ```bash
   curl -s http://127.0.0.1:8080/employees | jq
   ```
