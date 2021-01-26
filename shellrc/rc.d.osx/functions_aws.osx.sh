
function ec2-ip-from-id() {
  echo $(aws ec2 describe-instances --region us-east-1 --instance-ids $1 --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')
}

function ec2-ip-from-name() {
  echo $(aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=\"$1\"" --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')
}

function ec2-ip-from-tags {
  local ec2_data selected_instance

  ec2_data=$( \
    aws ec2 describe-instances \
      --region us-east-1 \
      --query 'Reservations[*].Instances[*].{Tags:Tags, IP:PrivateIpAddress}' \
      --filters "Name=instance-state-name,Values=running"
  )

  selected_instance=$( \
    echo "$ec2_data" \
    | jq -r '.[][] | select(.Tags != null) | [ "IP=\(.IP)", (.Tags | map("\(.Key)=\(.Value|tostring)") | sort | join("|")) ] | join("|")' \
    | sort \
    | fzf --prompt="Select instance > " \
  )

  echo "$selected_instance" | sed 's/^.*[[:<:]]IP=\([^\|]*\)\|.*$/\1/'
}

function rds-find-endpoint {
  local rds_data selected_instance

  rds_data=$( \
    aws rds describe-db-clusters \
      --region us-east-1 \
      --query 'DBClusters[*].[Endpoint]' \
      --output text
  )

  selected_instance=$( \
    echo "$rds_data" \
    | sort \
    | fzf --prompt="Select cluster > " \
  )

  echo "$selected_instance"
}

function ssh-ec2-id() {
  ssh $(ec2-ip-from-id "$1") "${@:2}"
}

function ssh-ec2-name() {
  ssh $(ec2-ip-from-name "$1") "${@:2}"
}

function ssh-ec2 {
  local instance_ip

  instance_ip=$(ec2-ip-from-tags)
  echo "Connecting to $instance_ip..."
  history -s ssh -o UserKnownHostsFile=/dev/null "$instance_ip"
  ssh -o UserKnownHostsFile=/dev/null "$instance_ip"
}

function pgcli-ec2 {
  local instance_ip database local_port remote_port
  instance_ip=$(ec2-ip-from-tags)
  database="${1-postgres}"
  local_port="$(awk 'BEGIN{srand();print int(rand()*(63000-2000))+2000 }')"
  remote_port=5432
  remote_user="rball"
  echo "Connecting to $instance_ip..."
  ssh -f -o ExitOnForwardFailure=yes -L "$local_port:$instance_ip:$remote_port" "$remote_user@$instance_ip" sleep 10
  pgcli -h "localhost" -p "$local_port" -U "$remote_user" -d "$database"
  history -s pgcli -h "localhost" -p "$local_port" -U "$remote_user" -d "$database"
}

function pgcli-rds {
  local instance_endpoint

  instance_endpoint=$(rds-find-endpoint)
  echo "Connecting to $instance_endpoint..."
  pgcli -h "$instance_endpoint" -U rball -d postgres
  history -s pgcli -h "$instance_endpoint" -U rball -d postgres
}
