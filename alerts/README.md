## AlertManager (Default port 9093): [official git](https://github.com/prometheus/alertmanager)

*Note:* AlertManager exposes a web UI at its port: `http://<hostname>:<port>/`

**<ins>Install:</ins>**

1. Modify the docker.env file with the appropriate environment variables

   - If utilizing a Microsoft Teams integration for alert notifications, first add the "Incoming Webhook" app within Teams and generate a generic webhook under the connectors tab.

   - After generating the webhook, copy paste it directly into the docker.env file.

2. Prometheus does not natively support environment variable substitution for their config files. Utilize a configuration management tool such as ansible or do the following:

   - Modify the alerts.env and template.yml files within the configs folder based upon your deployment needs. The current files are set up to notify via Microsoft Teams and email.

   - Additional alerting integration can be found here: [Alert Configuration](https://prometheus.io/docs/alerting/latest/configuration/)

   - Execute the following commands or run the env.sh script:

     `source alerts.env`
    
     `envsubst < template.yml > alertmanager.yml`

   - This will inject any environment variables from alerts.env and output it as the appropriate alertmanager.yml config file.

3. Execute the command: `docker-compose --env-file=docker.env up -d`

4. Navigate to `http://<hostname>:<port>/`

**<ins>Prom2Teams:</ins>** (default port 8089)

The prom2teams service ([official git](https://github.com/idealista/prom2teams)) acts as the intermediary, forwarding alerts to Microsoft Teams through the webhook.

Swagger UI: `<Host>:<Port>` for API v1 and `<Host>:<Port>/v2` for API v2

**<ins>Auth/Encryption:</ins>**

*Note:* TLS and basic authentication for exposed web ui's on the prometheus and alerting servers is currently in experimental development. It is recommended to utilize a reverse proxy such as nginx in the meantime.

Modify the docker-compose file by adding the following block:

    command:
      - --config.file=/etc/prometheus/alertmanager.yml
      - --web.external-url=https://<fqdn>
      - --web.route-prefix=/

**<ins>Alerting Rules:</ins>**

Alerting rules are written and stored within the Prometheus server config folder under rules.yml
