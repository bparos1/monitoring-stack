# InfluxDB (Version 1.8 Default port 8086)       [Official GIT](https://github.com/influxdata/influxdb)

*Note:* InfluxDB exposes a web UI at its port: `http://<hostname>:<port>/`

## Single Node:

#### Install:  
The following steps will create a working Influx Database node that will work with the Prometheus machine. 

  1. Modify the docker.env file with the appropriate environment variables.

  2. Modify the './config/influx.env' file with the appropriate variables.

  3. Execute the following command: `chmod 0770 config.sh ./config/env.sh ./backup/backup.sh`
    
  4. Run the configuration script: `./config.sh`
  
  - The script runs the `./config/env.sh` script:  
    - The `./config/env.sh` script replaces variables  
    
    
  - The configuration script nexts creates the influx docker container  
    `docker-compose --env-file=docker.env up -d`

  - The config script copies the `./config/database.sh` script into the container and executes the script

  - Finally, The config script runs the `./backup/backup.sh` script
    
  
  
#### Backup:
  
- InfluxDB requires backups for both the container image and container volume

- The configuration script begins backup by running the './backup/backup.sh' script:  

    - The backup script creates a  backup directory at '~/backup'
    
    - The script replaces variables in the 'cron_backup_template.sh'
    
    - The script saves an image of the container after configurations have been issued.

    - The script creates a file that contains the command  to issues a volume backup daily at midnight

  - Run the commands:
  ``` 
  su root
  cat ./backup/cron_text.txt > /var/spool/cron/crontabs/root
  exit
  ```
    - The commands will create a cronjob that issues the daily volume backup

#### Recovery:

- In the './backup' directory issue: `chmod 0770 recovery.sh`

- Run the './recovery.sh' script:

    - The script loads the backup image

    - The script prepares the backup volume data

    - The script attaches the volume data to the backup image
  
  
  
## Future Considerations:

#### InfluxDB Node Clustering
*Note:* Based upon [recommended configurations](https://www.influxdata.com/blog/influxdb-clustering/)  
 ![InfluxDB Clustering Overview](https://www.influxdata.com/wp-content/uploads/influxdb-clustering.png)

  1. Meta Nodes     
  - Requires odd number of Nodes     
  - 3 nodes 
  - [Meta Node setup](https://docs.influxdata.com/enterprise_influxdb/v1.8/install-and-deploy/production_installation/meta_node_installation/)

  
  2. Data Nodes  
  - Requires even number of Nodes 
  - 4 nodes 
  - [Data Node setup](https://docs.influxdata.com/enterprise_influxdb/v1.8/install-and-deploy/production_installation/data_node_installation/)

#### Architecture Configuration Management
  - Handle configuration of docker image without need of command injection
  - Handle initiation, service setup, and backup implimentation




