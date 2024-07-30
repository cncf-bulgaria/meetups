# Running Unikraft unikernel on Unikraft Cloud

## Database preparation

1. Create a storage volume
   ```bash
   kraft cloud volume create --size 500 --name mariadb-data
   kraft cloud volume get mariadb-data
   ```

1. Create a service
   ```bash
   kraft cloud service create --name mariadb 3306:3306/tls
   kraft cloud service get mariadb
   ```

1. Create a TLS runnel to the database
   ```bash
   export MARIADB_HOST=$(kraft cloud svc get mariadb -o json | jq -r '.[0].fqdn')
   socat tcp-listen:3306,bind=127.0.0.1,fork,reuseaddr openssl:${MARIADB_HOST}:3306 2>/dev/null &
   ```

1. Wait for the database to become ready
   ```bash
   watch -n 0.5 'mariadb --ssl=false -h 127.0.0.1 -u root -punikraft -e "SELECT host,user,plugin FROM mysql.user;"'
   ```

1. Create a MariaDB instance
   ```bash
   kraft cloud inst create --start --name mariadb -M 512 --volumes mariadb-data:/root/var/lib/mysql --service mariadb mariadb --entrypoint "/usr/sbin/mariadbd --user=root --log-bin=mariadb --skip_name_resolve=on"
   kraft cloud inst get mariadb
   ```

1. Display the logs of MariaDB
   ```bash
   kraft cloud inst logs -f mariadb
   clear
   ```

1. Create application database
   ```bash
   mariadb --ssl=false -h 127.0.0.1 -u root -punikraft -e "CREATE DATABASE company_db;"
   ```

1. Create a table
   ```bash
   mariadb --ssl=false -h 127.0.0.1 -u root -punikraft -e \
      "USE company_db; \
       CREATE TABLE employee (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL, position VARCHAR(100), salary DECIMAL(10, 2), hire_date DATE);"
   ```

1. Insert data into the table
   ```bash
   mariadb --ssl=false -h 127.0.0.1 -u root -punikraft -e "USE company_db; INSERT INTO employee (name, position, salary, hire_date) VALUES \
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
   mariadb --ssl=false -h 127.0.0.1 -u root -punikraft -e "CREATE USER 'app_user'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD('app_password'); \
       GRANT SELECT ON company_db.employee TO 'app_user'@'%'; \
       FLUSH PRIVILEGES;"
   ```

1. Verify if the application user can read the data
   ```bash
   mariadb --ssl=false -h 127.0.0.1 -u app_user -papp_password -e "USE company_db; SELECT * FROM employee;"
   ```

## Build and run the unikernel
Note: Replace <USERNAME> with your actual username displayed by `kraft cloud quotas`
1. Update the database address in conf/config.yaml
   ```
   export DB_HOST=$(kraft cloud inst get mariadb -o json | jq -r '.[0].private_fqdn')
   yq e ".db_host = \"${DB_HOST}\"" -i conf/config.yaml
   ```

1. Build the unikernel and create an OCI image
   ```bash
   kraft pkg --plat kraftcloud --as oci --name index.unikraft.io/<USERNAME>/webapp:latest
   ```

1. Push the OCI image to Unikraft's registry
   ```bash
   kraft pkg push index.unikraft.io/<USERNAME>/webapp:latest
   ```

1. List my OCI images
```bash
kraft cloud image ls
```

1. Create a storage volume for the configuration
   ```bash
   kraft cloud volume create --size 1 --name webapp-cfg
   kraft cloud volume get webapp-cfg
   ```

1. Import the configuration to the volume
   ```bash
   kraft cloud volume import --volume webapp-cfg --source ./conf/
   ```

1. Create a service
   ```bash
   kraft cloud service create --name webapp 443:8080/http+tls
   kraft cloud service get webapp
   ```

1. Wait for the webapp to become ready
   ```bash
   export WEBAPP_HOST=$(kraft cloud svc get webapp -o json | jq -r '.[0].fqdn')
   watch -n 0.5 curl -s https://${WEBAPP_HOST}
   ```

1. Create an app instance
   ```bash
   kraft cloud inst create --start --name webapp -M 128 --volumes webapp-cfg:/root/conf:ro --service webapp <USERNAME>/webapp
   kraft cloud inst get webapp
   ```

1. Send a request to the web app
   ```bash
   export WEBAPP_HOST=$(kraft cloud svc get webapp -o json | jq -r '.[0].fqdn')
   curl https://${WEBAPP_HOST}/employees | jq
   ```

## Cleanup
   ```bash
   kraft cloud inst rm --all
   kraft cloud svc rm --all
   kraft cloud vol rm webapp-cfg mariadb-data
   kraft cloud img rm <USERNAME>/webapp
   ```
