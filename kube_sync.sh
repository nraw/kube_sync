#!/usr/bin/env sh

current_path=$(pwd)
pod_dir='/'
pod=''
namespace=""

if [ -f .kube_sync ]; then 
  . ./.kube_sync
else
  echo 'pod_dir:'
  read pod_dir
  echo "pod_dir=\"$pod_dir\"\n" >> .kube_sync
  echo 'namespace:'
  read namespace
  echo "namespace=\"$namespace\"\n" >> .kube_sync


fi

new_file=$1
new_path=${new_file#$current_path/}
new_dir=$(dirname "$new_path")

if [ -n "$namespace" ]; then
    ns="-n=$namespace"
else
    ns=""
fi

pods=$(kubectl get "$ns" pods)
echo "$pods" | rg $pod || pod=$(
    echo "$pods" | tail -n +2 | fzf | cut -d" " -f1
)

rg -v "^pod=" .kube_sync >.kube_sync_temp && mv .kube_sync_temp .kube_sync &&
    echo "pod=$pod" >>.kube_sync

echo "pod=$pod"

kubectl exec "$ns" "$pod" -- mkdir -p "$new_dir"
kubectl cp "$ns" "$new_path" "$pod":"$pod_dir"/"$new_path" &&
    echo "Transferred: $new_path"
