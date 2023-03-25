#!/usr/bin/env bash
set -eou pipefail

# Secrets loaded via the 1Password CLI
echo "Loading credentials..."
export MASTODON_RDS_USER=$(op item get "<<snip>>" --vault "<<snip>>" --fields label=username)
export MASTODON_RDS_PASSWORD=$(op item get "<<snip>>" --vault "<<snip>>" --fields label=password)
export MASTODON_RAILS_SECRET_BASE=$(op item get "<<snip>>" --vault "<<snip>>" --fields label=password)
export MASTODON_RAILS_OTP_SECRET=$(op item get "<<snip>>" --vault "<<snip>>" --fields label=password)
export MASTODON_RAILS_PRIVATE_KEY=$(op item get "<<snip>>" --vault "<<snip>>" --fields label=password)
export MASTODON_RAILS_PUBLIC_KEY=$(op item get "<<snip>>" --vault "<<snip>>" --fields label=password)
export MASTODON_SMTP_USER=$(op item get "<<snip>>" --vault "<<snip>>" --fields label=username)
export MASTODON_SMTP_PASSWORD=$(op item get "<<snip>>" --vault "<<snip>>" --fields label=password)
export MASTODON_S3_ACCESS_KEY_ID=$(op item get "<<snip>>" --vault "<<snip>>" --fields label=username)
export MASTODON_S3_SECRET_ACCESS_KEY=$(op item get "<<snip>>" --vault "<<snip>>" --fields label=password)

# Nomad configuration options
export MASTODON_VERSION="v4.1.1"
export MASTODON_NGINX_VERSION="1.23.3"
export MASTODON_DOMAIN="<<YOUR_DOMAIN>>"
export MASTODON_RAILS_PORT="3000"
export MASTODON_REDIS_HOST="<<YOUR_REDIS_URL>>"
export MASTODON_REDIS_PORT="6379"
export MASTODON_RDS_ENDPOINT="<<YOUR_RDS_URL>>"
export MASTODON_RDS_USER="mastodon"
export MASTODON_RDS_NAME="mastodon_production"
export MASTODON_RDS_PORT="5432"
export MASTODON_ES_ENABLED="false"
export MASTODON_ES_HOST="localhost"
export MASTODON_ES_PORT="9200"
export MASTODON_ES_USER="elastic"
export MASTODON_ES_PASSWORD="password" # todo: if you use elasticsearch this should be replaced
export MASTODON_SMTP_SERVER="<<YOUR_SMTP_DOMAIN>>"
export MASTODON_SMTP_PORT="587"
export MASTODON_SMTP_USER="<<SNIP>>"
export MASTODON_SMTP_FROM_ADDRESS="mastodon@<<YOUR_DOMAIN>>"
export MASTODON_S3_ENABLED="true"
export MASTODON_S3_PERMISSION="private"
export MASTODON_S3_ENDPOINT="<<YOUR_S3_DOMAIN>>"
export MASTODON_S3_BUCKET_NAME="<<YOUR_DOMAIN>>-files"
export MASTODON_S3_BUCKET_ACCESS_KEY="<<YOUR_S3_ACCESS_KEY>>"
export MASTODON_S3_ALIAS_HOST="files.<<YOUR_DOMAIN>>"
export MASTODON_IP_RETENTION_PERIOD="31556952"
export MASTODON_SESSION_RETENTION_PERIOD="31556952"
export MASTODON_STREAMING_PORT="4000"
export MASTODON_MEDIA_RETENTION_DAYS="30"

# Shared Nomad variables
export NOMAD_VAR_mastodon_domain="${MASTODON_DOMAIN}"
export NOMAD_VAR_rails_port="${MASTODON_RAILS_PORT}"
export NOMAD_VAR_redis_host="${MASTODON_REDIS_HOST}"
export NOMAD_VAR_redis_port="${MASTODON_REDIS_PORT}"
export NOMAD_VAR_rds_endpoint="${MASTODON_RDS_ENDPOINT}"
export NOMAD_VAR_rds_user="${MASTODON_RDS_USER}"
export NOMAD_VAR_rds_name="${MASTODON_RDS_NAME}"
export NOMAD_VAR_rds_port="${MASTODON_RDS_PORT}"
export NOMAD_VAR_es_enabled="${MASTODON_ES_ENABLED}"
export NOMAD_VAR_es_host="${MASTODON_ES_HOST}"
export NOMAD_VAR_es_port="${MASTODON_ES_PORT}"
export NOMAD_VAR_es_user="${MASTODON_ES_USER}"
export NOMAD_VAR_es_password="${MASTODON_ES_PASSWORD}"
export NOMAD_VAR_smtp_server="${MASTODON_SMTP_SERVER}"
export NOMAD_VAR_smtp_port="${MASTODON_SMTP_PORT}"
export NOMAD_VAR_smtp_user="${MASTODON_SMTP_USER}"
export NOMAD_VAR_smtp_from_address="${MASTODON_SMTP_FROM_ADDRESS}"
export NOMAD_VAR_s3_enabled="${MASTODON_S3_ENABLED}"
export NOMAD_VAR_s3_permission="${MASTODON_S3_PERMISSION}"
export NOMAD_VAR_s3_endpoint="${MASTODON_S3_ENDPOINT}"
export NOMAD_VAR_s3_bucket_name="${MASTODON_S3_BUCKET_NAME}"
export NOMAD_VAR_s3_bucket_access_key="${MASTODON_S3_BUCKET_ACCESS_KEY}"
export NOMAD_VAR_s3_alias_host="${MASTODON_S3_ALIAS_HOST}"
export NOMAD_VAR_ip_retention_period="${MASTODON_IP_RETENTION_PERIOD}"
export NOMAD_VAR_session_retention_period="${MASTODON_SESSION_RETENTION_PERIOD}"
export NOMAD_VAR_streaming_port="${MASTODON_STREAMING_PORT}"
export NOMAD_VAR_rds_user="${MASTODON_RDS_USER}"
export NOMAD_VAR_rds_password="${MASTODON_RDS_PASSWORD}"
export NOMAD_VAR_rails_secret_key_base="${MASTODON_RAILS_SECRET_BASE}"
export NOMAD_VAR_rails_otp_secret="${MASTODON_RAILS_OTP_SECRET}"
export NOMAD_VAR_rails_push_private_key="${MASTODON_RAILS_PRIVATE_KEY}"
export NOMAD_VAR_rails_push_public_key="${MASTODON_RAILS_PUBLIC_KEY}"
export NOMAD_VAR_smtp_user="${MASTODON_SMTP_USER}"
export NOMAD_VAR_smtp_password="${MASTODON_SMTP_PASSWORD}"
export NOMAD_VAR_s3_bucket_access_key="${MASTODON_S3_ACCESS_KEY_ID}"
export NOMAD_VAR_s3_bucket_secret_key="${MASTODON_S3_SECRET_ACCESS_KEY}"
export NOMAD_VAR_media_retention_days="${MASTODON_MEDIA_RETENTION_DAYS}"

echo "Deploying Mastodon migrations..."
NOMAD_VAR_container_tag="${MASTODON_VERSION}" \
nomad job run -address=http://localhost:4647 jobs/mastodon-migrations.nomad

echo "Deploying Mastodon front..."
NOMAD_VAR_container_tag="${MASTODON_NGINX_VERSION}" \
nomad job run -address=http://localhost:4647 jobs/mastodon-front.nomad

echo "Deploying Mastodon web..."
NOMAD_VAR_container_tag="${MASTODON_VERSION}" \
nomad job run -address=http://localhost:4647 jobs/mastodon-web.nomad

echo "Deploying Mastodon sidekiq..."
NOMAD_VAR_container_tag="${MASTODON_VERSION}" \
nomad job run -address=http://localhost:4647 jobs/mastodon-sidekiq.nomad

echo "Deploying Mastodon streaming..."
NOMAD_VAR_container_tag="${MASTODON_VERSION}" \
nomad job run -address=http://localhost:4647 jobs/mastodon-streaming.nomad

echo "Deploying Mastodon cleanup cron..."
NOMAD_VAR_container_tag="${MASTODON_VERSION}" \
nomad job run -address=http://localhost:4647 jobs/mastodon-cleanup.nomad