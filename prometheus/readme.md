## Prometheus (Default port 9090): [official git](https://github.com/prometheus/prometheus)

*Note:* Prometheus exposes a web UI at its port: `http://<hostname>:<port>/`

**<ins>Install:</ins>**

1. Modify the docker.env file with the appropriate environment variables.

2. Prometheus does not natively support environment variable substitution for their config files. Utilize a configuration management tool such as ansible or do the following:

   - Modify the prometheus.env and template.yml files within the configs folder based upon your deployment needs. 

   - Execute the following commands or run the env.sh script:

     `source prometheus.env`
    
     `envsubst < template.yml > prometheus.yml`

     This will inject any environment variables from prometheus.env and output it as the appropriate prometheus.yml config file.

3. Execute the command: `docker-compose --env-file=docker.env up -d`

4. Navigate to `http://<hostname>:<port>/`

**<ins>Auth/Encryption:</ins>**

*Note:* TLS and basic authentication for exposed web ui's on the prometheus and alerting servers is currently in experimental development. It is recommended to utilize a reverse proxy such as nginx in the meantime.

Modify the docker-compose file by adding the following block:

    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --web.external-url=https://<fqdn>
      - --web.route-prefix=/

**<ins>Adding additional endpoints to be scraped:</ins>**

The basic format for adding additional endpoints to the prometheus.yml config file is:

    scrape_configs:
      - job_name: <name>
        metrics_path: </path>  (This is the web ui being exposed by the exporter, usually /metrics)
        scheme: http or https
        tls_config:
          ca_file: <certificate>.crt
        basic_auth:
          username: <user>
          password_file: <path/to/file>  (This must be in plaintext)
        static_configs:
          - targets: ['<hostname>:<port>']

  Simply restart the docker container and it should be utilizing the updated config file.
    
**<ins>Alerting:</ins>**

Alerting rules for Prometheus are stored within the rules.yml file and have the following basic format:

    groups:
    - name: <name of the alert group>
      rules:
      - alert: <alert name>                  (example: InstanceDown)
        expr: <query of the alert you want>  (example: up == 0)
        for: <duration of the alert>         (example: 5m)
        labels:
          severity: <severity level>         (example: critical)
        annotations:
          description: '<description of the alert>'
          summary: '<summary of the alert>'

To reference a specific label associated with the query expression, use: `{{ $labels.<label_name> }}`

For example: `{{ $labels.job }}`

**<ins>Storage:</ins>**

Prometheus does include a local on-disk time series database for storing metrics, but can also integrate with [remote storage systems](https://prometheus.io/docs/operating/integrations/#remote-endpoints-and-storage) 

Add the following to the prometheus.yml config file:

    remote_write:
      - url: "<url used for remote write via API>"
        basic_auth:
          username: <user>
          password: <password>
          password_file: <path/to/file>   (must be in plaintext)
    remote_read:
      - url: "<url used for remote read via API>"
        basic_auth:
          username: <user>
          password: <password>
          password_file: <path/to/file>

**<ins>Prometheus Query Language:</ins>** [query docs](https://prometheus.io/docs/prometheus/latest/querying/basics/)

  - Prometheus metrics are read from key value pairs: the key describes the metric monitored and the value is the value associated with that metric.

  - Metrics may also contain labels that give additional information.

  - Example:

    ![](images/metric.JPG)
  
  - Labels can be used to drilldown on specific metrics you are interested in, for example:

    The query `node_cpu_seconds_total{cpu="0"}` will only show cpu time for the 1st core.

  - Labels can also be used to help combine the values from querys based on a common label:

    The query `sum by (cpu) (node_cpu_seconds_total)` will sum up the idle, iowait, irq, nice, softirq, steal, system and user values based on the cpu resulting in a single aggregated value for each core

  - When you need to combine values from multiple querys where the exact labels do not match, you can utilize the ignoring operator. For example if you wanted to combine the system and user cpu time for running processes:

    `namedprocess_namegroup_cpu_seconds_total{mode="system"} + ignoring(mode) namedprocess_namegroup_cpu_seconds_total{mode="user"}`

  - Things get tricky when you want to use operators on multiple querys when there is a many-to-one or one-to-many vector match. 

  - Many-to-one and one-to-many matchings refer to the case where each vector element on the "one"-side can match with multiple elements on the "many"-side. This has to be explicitly requested using the group_left or group_right modifier, where left/right determines which vector has the higher cardinality:

    Take this query for example `method_code:http_errors:rate5m / ignoring(code) group_left method:http_requests:rate5m`

    In this case the left vector contains more than one entry per method label value. Thus, we indicate this using group_left. The elements from the right side are now matched with multiple elements with the same method label on the left:

    ![](images/methodlabels.JPG)


**<ins>Metric Relabeling:</ins>** [labeling docs](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config)

  *Note*: Another good resource on [metric relabeling](https://valyala.medium.com/how-to-use-relabeling-in-prometheus-and-victoriametrics-8b90fc22c4b2)

  - Relabeling is a way to dynamically rewrite the label set of a target before it gets scraped. Multiple relabeling steps can be configured per scrape configuration. They are applied to the label set of each target in order of their appearance in the configuration file.

  - Relabeling is useful for changing the names, reformatting, and removing pre-defined labels.

  - The basic format of a metric relabel is:

         source_labels: [<"string">]
         regex: <matching regex of the label format>    # RE2 regular expression format                                          
         replacement: "<string>"                        # The replacement value based on regex match | default = $1
         target_label: "<string>"                       # The name for the new label       
         action:                                        # Action to perform when there is a match | default = replace

  - The default configuration for process-exporter sets the label groupname as "groupname="name";username. Utilizing metric relabeling we can parse out the username portion as its own unique label.

  - For each endpoint that you want to measure process metrics on, add the following configuration underneath their static_configs:

        metric_relabel_configs:
          - source_labels: ["groupname"]
            regex: "(.*);(.*)"
            target_label: "username"
            replacement: "$2"
       
          - source_labels: ["groupname"]
            regex: "(.*);(.*)"
            target_label: "groupname"
            replacement: "$1"
  


