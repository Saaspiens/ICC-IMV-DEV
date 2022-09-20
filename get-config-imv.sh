rm -rf /tmp/microservice-efmigration-config/app-config.json /tmp/microservice-efmigration/appsettings.json
mkdir -p /tmp/microservice-efmigration-config
kubectl get cm efmigration-config -o jsonpath="{.data.app-config\.json}" -n microservice-comatic-dev --kubeconfig ~/.kube/config > /tmp/microservice-efmigration-config/app-config.json
kubectl get cm efmigration-config -o jsonpath="{.data.appsettings\.json}" -n microservice-comatic-dev --kubeconfig ~/.kube/config > /tmp/microservice-efmigration-config/appsettings.json