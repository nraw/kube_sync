#!/usr/bin/env sh

current_path=$(pwd)
pod_dir='/'
pod=''

. ./.kube_sync

new_file=$1
new_path=${new_file#$current_path/}
new_dir=$(dirname "$new_path")
pods=$(kubectl get pods)
echo "$pods" | rg $pod || pod=$(echo "$pods" | tail -n +2 | fzf | cut -d" " -f1)
echo "pod=$pod"
kubectl exec "$pod" -- mkdir -p "$new_dir"
kubectl cp "$new_path" "$pod":"$pod_dir"/"$new_path" &&
    echo "Transferred: $new_path"
