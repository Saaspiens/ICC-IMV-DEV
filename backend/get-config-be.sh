kubectl get cm imv-backend-config -o jsonpath="{.data.appsettings\.json}" -n imv-dev --kubeconfig ~/.kube/config > src-build/SRC/Backend/SRC/Applications/DebugRunning.Application/appsettings.json