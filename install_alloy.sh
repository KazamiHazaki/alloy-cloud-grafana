#!/bin/bash

# Step 0: Create the directory
mkdir -p monitoring-vm

# Step 1: Read current VM hostname and store it as an environment variable
current_hostname=$(hostname)
echo "Current hostname is: $current_hostname"
read -p "Do you want to use this hostname? (yes/no): " use_default

if [ "$use_default" != "yes" ] then
    read -p "Enter new hostname: " new_hostname
    export HOSTNAME_ENV="$new_hostname"
else
    export HOSTNAME_ENV="$current_hostname"
fi

# Step 2: Ask for Grafana Cloud API key and save it as an environment variable
read -p "Enter your Grafana Cloud API key: " grafana_api_key
echo
export GCLOUD_RW_API_KEY="$grafana_api_key"

# Step 3: Run the installation command
ARCH="amd64" \
GCLOUD_HOSTED_METRICS_URL="https://prometheus-prod-37-prod-ap-southeast-1.grafana.net/api/prom/push" \
GCLOUD_HOSTED_METRICS_ID="1797825" \
GCLOUD_SCRAPE_INTERVAL="60s" \
GCLOUD_HOSTED_LOGS_URL="https://logs-prod-020.grafana.net/loki/api/v1/push" \
GCLOUD_HOSTED_LOGS_ID="998198" \
GCLOUD_RW_API_KEY="$GCLOUD_RW_API_KEY" \
/bin/sh -c "$(curl -fsSL https://storage.googleapis.com/cloud-onboarding/alloy/scripts/install-linux-binary.sh)"

# Step 4: Create or update the config.alloy file
cat <<EOF > /path/to/config.alloy
discovery.relabel "integrations_node_exporter" {
  targets = prometheus.exporter.unix.integrations_node_exporter.targets

  rule {
    target_label = "instance"
    replacement  = "$HOSTNAME_ENV"
  }

  rule {
    target_label = "job"
    replacement = "integrations/node_exporter"
  }
}

prometheus.exporter.unix "integrations_node_exporter" {
  disable_collectors = ["ipvs", "btrfs", "infiniband", "xfs", "zfs"]

  filesystem {
    fs_types_exclude     = "^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|tmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$"
    mount_points_exclude = "^/(dev|proc|run/credentials/.+|sys|var/lib/docker/.+)($|/)"
    mount_timeout        = "5s"
  }

  netclass {
    ignored_devices = "^(veth.*|cali.*|[a-f0-9]{15})$"
  }

  netdev {
    device_exclude = "^(veth.*|cali.*|[a-f0-9]{15})$"
  }
}

prometheus.scrape "integrations_node_exporter" {
  targets    = discovery.relabel.integrations_node_exporter.output
  forward_to = [prometheus.relabel.integrations_node_exporter.receiver]
}

prometheus.relabel "integrations_node_exporter" {
  forward_to = [prometheus.remote_write.metrics_service.receiver]

  rule {
    source_labels = ["__name__"]
    regex         = "node_scrape_collector_.+"
    action        = "drop"
  }
}

loki.source.journal "logs_integrations_integrations_node_exporter_journal_scrape" {
  max_age       = "24h0m0s"
  relabel_rules = discovery.relabel.logs_integrations_integrations_node_exporter_journal_scrape.rules
  forward_to    = [loki.write.grafana_cloud_loki.receiver]
}

local.file_match "logs_integrations_integrations_node_exporter_direct_scrape" {
  path_targets = [{
    __address__ = "localhost",
    __path__    = "/var/log/{syslog,messages,*.log}",
    instance    = "$HOSTNAME_ENV",
    job         = "integrations/node_exporter",
  }]
}

discovery.relabel "logs_integrations_integrations_node_exporter_journal_scrape" {
  targets = []

  rule {
    source_labels = ["__journal__systemd_unit"]
    target_label  = "unit"
  }

  rule {
    source_labels = ["__journal__boot_id"]
    target_label  = "boot_id"
  }

  rule {
    source_labels = ["__journal__transport"]
    target_label  = "transport"
  }

  rule {
    source_labels = ["__journal_priority_keyword"]
    target_label  = "level"
  }
}

loki.source.file "logs_integrations_integrations_node_exporter_direct_scrape" {
  targets    = local.file_match.logs_integrations_integrations_node_exporter_direct_scrape.targets
  forward_to = [loki.write.grafana_cloud_loki.receiver]
}
EOF

# Step 6: Create the systemd service file
sudo tee /etc/systemd/system/alloy.service <<EOF
[Unit]
Description=Alloy Service
After=network.target

[Service]
ExecStart=$PWD/alloy-linux-amd64 run $PWD/config.alloy
WorkingDirectory=$PWD
Restart=always
RestartSec=10
User=root
Group=root
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Step 7: Reload systemd, start and enable the service
sudo systemctl daemon-reload
sudo systemctl start alloy.service
sudo systemctl enable alloy.service

echo "Grafana Alloy installation and service setup complete."
