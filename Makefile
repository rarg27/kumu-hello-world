.PHONY: linkerd traefik

HELLO_PORT := 8000
DASHBOARD_PORT := 8080

repo:
	helm repo add traefik https://traefik.github.io/charts
	helm repo add linkerd https://helm.linkerd.io/stable
	helm repo update

crds:
	kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.9/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
	kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.9/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml
	helm upgrade --install linkerd-crds -n linkerd --create-namespace linkerd/linkerd-crds

linkerd:
	helm upgrade --install --wait linkerd -n linkerd linkerd/linkerd-control-plane -f ./linkerd/values.yml
	helm upgrade --install --wait linkerd-viz -n linkerd-viz --create-namespace linkerd/linkerd-viz

traefik:
	helm upgrade --install traefik traefik/traefik -f ./traefik/values.yml

app:
	kubectl apply -f .

install: repo crds linkerd traefik app

hello:
	kubectl port-forward service/traefik ${HELLO_PORT}:80

dashboard:
	kubectl port-forward -n linkerd-viz service/web ${DASHBOARD_PORT}:8084

# Added "|| true" to continue executing all delete commands in spite of "release not found" errors
delete:
	helm uninstall traefik --wait || true
	helm uninstall linkerd-viz -n linkerd-viz --wait || true
	helm uninstall linkerd -n linkerd --wait || true
	kubectl delete --ignore-not-found=true -f .
