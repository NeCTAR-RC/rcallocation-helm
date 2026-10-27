{{- define "rcallocation-conf" }}
[DEFAULT]
auth_strategy=keystone
{{- if .Values.conf.debug }}
debug=true
{{- end }}

[api]
enable_swagger_ui={{ .Values.conf.api.enable_swagger_ui }}
{{- with .Values.conf.api.page_size }}
page_size={{ . }}
{{- end }}
{{- with .Values.conf.api.max_page_size }}
max_page_size={{ . }}
{{- end }}

[database]
connection_recycle_time=600

[allocations]
for_code_series={{ .Values.conf.allocations.for_code_series }}
mappings_file=/etc/rcallocation/mappings.yaml
tenant_manager_role={{ .Values.conf.allocations.tenant_manager_role }}
{{- with .Values.conf.allocations.role_assignment_cache_seconds }}
role_assignment_cache_seconds={{ . }}
{{- end }}

[notifications]
driver={{ .Values.conf.notifications.driver }}
enabled={{ .Values.conf.notifications.enabled }}
{{- with .Values.conf.notifications.cc }}
cc={{ join "," . }}
{{- end }}
dashboard_url={{ .Values.conf.notifications.dashboard_url }}

[oslo_middleware]
enable_proxy_headers_parsing=True

[sentry]
environment={{ .Values.conf.sentry.environment }}

[service_auth]
auth_url={{ .Values.conf.keystone.auth_url }}
username={{ .Values.conf.keystone.username }}
user_domain_name=Default
system_scope=all
auth_type=password

[keystone_authtoken]
auth_url={{ .Values.conf.keystone.auth_url }}
www_authenticate_uri={{ .Values.conf.keystone.auth_url }}
username={{ .Values.conf.keystone.username }}
project_name={{ .Values.conf.keystone.project_name }}
user_domain_name=Default
project_domain_name=Default
auth_type=password
service_token_roles_required=True
# Both are the service's own defaults, stated here because anonymous
# read access depends on them: the auth decision is left to the
# application, and application credential access rules are matched
# against the catalog type.
delay_auth_decision=True
service_type=allocations
{{- if .Values.conf.keystone.memcached_servers }}
memcached_servers={{ join "," .Values.conf.keystone.memcached_servers }}
{{- end }}

{{- end }}
