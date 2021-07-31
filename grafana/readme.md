## Grafana (Default port 3000): [official git](https://github.com/grafana/grafana)

*Note:* Grafana exposes a web UI at its port: `http://<hostname>:<port>/`

**<ins>Install:</ins>**

1. Modify the docker.env file with the appropriate environment variables

2. Provisioning datasources and/or dashboards: ([provisioning docs](https://grafana.com/docs/grafana/latest/administration/provisioning/))

     *Note:* Environment variable substitution is allowed in all 3 provisoning configuration types

    <ins>Dashboards:</ins> The folder containing dashboards in JSON format must also have a file named dashboard.yml with the following basic format

       apiVersion: 1

       providers:

         - name: '<string>'
           orgId: <integer>			 # defaults to 1
           folder: '<string>'           # name of dashboard folder, defaults to General
           disableDeletion: <bool>      # true or false
           updateIntervalSeconds: 10
           allowUiUpdates: <bool>       # whether to allow dashboards to be updated from UI
           options:
             path: /path/to/provisioned/dashboards

   - When Grafana starts, it will update/insert all dashboards available in the configured path. Then later on poll that path looking for updated json files.

   - It’s possible to make changes to a provisioned dashboard in the Grafana UI. However, it is not possible to automatically save the changes back to the provisioning source. If allowUiUpdates is set to true and you make changes to a provisioned dashboard, you can save the dashboard then changes will be persisted to the Grafana database

    <ins>Datasources:</ins> The folder containing datasource files must have the following basic format

       apiVersion: 1

       datasources:

         - name: <string>
           type: prometheus
           access:                          # proxy or direct
           orgId:                           # defaults to 1
           uid:                             # generated automatically if not defined
           url: http://<hostname>:<port>    # this will be the address for prometheus
           basicAuth: <bool>                # if authentication is set up to access prometheus endpoint through NGINX proxy        
           basicAuthUser: <string>
           secureJsonData: 
             basicAuthPassword: <string>
           isDefault: <bool>                # whether this is the default datasource or not
           allowUiUpdates: <bool>
           version: <integer>
           editable: <bool>                  

   - If a datasource already exists, then Grafana updates it to match the configuration file.

   - Datasources can be deleted by including the following block within the datasource.yml file:

         deleteDataSources:
           - name: <string>
             orgId: <integer>

3. Everything in the grafana.ini file has defaults, so you only need to uncomment things you want to change. One area of note is the security section. By default grafana will create an admin user for web GUI access. This default user can be changed by uncommenting the following:

        disable_initial_admin_creation = <bool>    (true or false)
        admin_user = admin
        admin_password = admin

   - Environment variable subsitution for grafana.ini works by referencing the section name followed by the name. For example, to set the default admin creation:

          GF_SECURITY_DISABLE_INITIAL_ADMIN_CREATION=false
          GF_SECURITY_ADMIN_USER=student
          GF_SECURITY_ADMIN_PASSWORD

   - Modify them within the grafana.env file as needed.

4. Execute the command: `docker-compose --env-file=docker.env up -d`

5. Navigate to `http://<hostname>:<port>/`

**<ins>LDAP Integration:</ins>** ([LDAP docs](https://grafana.com/docs/grafana/latest/auth/ldap/))

  *Note:* The LDAP integration in Grafana allows your Grafana users to login with their LDAP credentials. You can also specify mappings between LDAP group memberships and Grafana Organization user roles

  1. Enable ldap within the main config file (towards the bottom) and specify the path to the LDAP specific configuration file (default: /etc/grafana/ldap.toml)

     ![](images/authldap.JPG)

  2. Make sure the ldap.toml file is properly mapped within the docker-compose file

  3. Edit the ldap.toml file according to your specific production environment

     *Note:* If your ldap server doesn't have the member_of attribute, you'll need to utilize the group_search_filter within the ldap.toml file:
    
       `group_search_filter = "(&(objectClass=<posixGroup>)(memberUid=%s))"`

  4. Grafana has an LDAP debug view built-in which allows you to test your LDAP configuration directly within Grafana. The LDAP debug view is located under the shield icon on the left side of the gui.


**<ins>GUI Tips:</ins>**

  - The dashboards are using variable names to help with easier query generation and create drop down menus to select various endpoints. You can reach the variable section by clicking the cog on the top right of the dashboard page:

    ![](images/variables.JPG)

  - To filter out values within visualizations, click on the "Filter by name" button located on the transform tab next to querys:

    ![](images/transformation.JPG)

  - When creating a table with multiple queries, utilize the "Outer join" button located on the transform tab to join values based on a common label.

  - Utilize the overrides button on the top right to relabel value names, set specific units, or choose what to show when there is no value:

    ![](images/overrides.JPG)

  - If you need to write a query utilizing the rate operator, set the range to `$__rate_interval`. This makes it so that the interval is never smaller than four times the scrape interval.

**<ins>Alerting:</ins>**

  - To set up alerting through grafana, first create a notification channel by clicking on the bell icon on left side.

  - Grafana does not allow the use of template variables when setting up alerts. You will have to create a duplicate query and replace all template variables with defined labels.

  - After labels have been defined, you will be able to create an alert threshhold for the specific query and which notification channel to send it to.

  - You can then hide the query from showing up on the graph, but the alert threshhold will still be shown.
