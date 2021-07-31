## Node Exporter: [official git](https://github.com/prometheus/node_exporter)

**Note:** The node_exporter.sh script utilizes a default user of deploy when setting permission levels for the service. Modify the script if you want to utilize a different user.

1. Decide upon a user for the node_exporter service and modify the node_exporter.service file accordingly. By default it runs with the deploy user/group
2. Put the node_exporter.service file in /etc/systemd/system
3. Run the node_exporter.sh script
4. To see if node_exporter is properly serving metrics, execute: `curl http://localhost:9100/metrics`

## cAdvisor: [official git](https://github.com/google/cadvisor)

**Note:** cAdvisor exposes a web UI at its port: `http://<hostname>:<port>/`

1. Set desired environment variables within the exporters.env file
2. Execute the command: `docker-compose --env-file=exporters.env up -d`
3. To see if cAdvisor is properly serving metrics, execute: `curl http://localhost:8080/metrics`

## Process-Exporter: [official git](https://github.com/ncabatoff/process-exporter)

*Note:* The process_exporter.sh script utilizes a default user of deploy when setting permission levels for the service. Modify the script if you want to utilize a different user.

1. Decide upon a user for the process_exporter service and modify the process_exporter.service file accordingly. By default it runs with the deploy user/group
2. Put the process_exporter.service file in /etc/systemd/system and point it to your configuration file
3. Run the process_exporter.sh script
4. To see if process_exporter is properly serving metrics, execute: `curl http://localhost:9256/metrics`

    - The configuration file for process-exporter can be modified to include all or specific processes for metric scraping. It is currently set to look for all available processes within the /proc directory.

    - The executable is running by default with threads turned off to reduce overhead. Remove the flag -threads within the service file to enable those metrics.

    - There are a few template variables available for how the groupname is formatted on metrics. The configuration is currently set to get the fully qualified path of executables as well as the username. This requires some metric relabeling configuration on the prometheus side prior to scraping the target.

      *Note:* Please read the metric relabeling section under the prometheus folder for more information.


## MySQL: [official git](https://github.com/prometheus/mysqld_exporter)

Supported versions: MySQL >= 5.6 and MariaDB >= 10.2

**Required Grants:**

`CREATE USER 'user'@'localhost' IDENTIFIED BY 'XXXXXXXX' WITH MAX_USER_CONNECTIONS 3;`

`GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'user'@'localhost';`

1. Create a user for metric scraping purposes and execute the grants above
2. Modify the environment variables within mysql.env and/or move them to exporters.env if you are deploying multiple exporters
3. Execute the command: `docker-compose --env-file=exporters.env up -d`
4. To see if MySQL exporter is properly serving metrics, execute: `curl http://localhost:9104/metrics`

## PostgreSQL: [official git](https://github.com/prometheus-community/postgres_exporter)

1. Create a user for metric scraping purposes
2. Modify the environment variables within postgres.env and/or move them to exporters.env if you are deploying multiple exporters
3. Execute the command: `docker-compose --env-file=exporters.env up -d`
4. To see if PostgreSQL exporter is properly serving metrics, execute `curl http://localhost:9187/metrics`
