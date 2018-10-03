# kubepress Makefile

LOADBALANCER = $(shell kubectl get svc --namespace default wordpress-demo-wordpress --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
WPPASSWORD = $(shell kubectl get secret --namespace default wordpress-demo-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)

setup:
	cd terraform && terraform init

terraform: setup
	cd terraform && terraform apply -auto-approve

kubeconfig: terraform
	cd terraform && terraform output kubeconfig > $(HOME)/.kube/config
	@echo ============================================
	cat $(HOME)/.kube/config
	@echo ============================================

config-map-aws-auth.yaml: kubeconfig
	cd terraform && terraform output config_map_aws_auth > config-map-aws-auth.yaml
	kubectl apply -f terraform/config-map-aws-auth.yaml

cluster: kubeconfig config-map-aws-auth.yaml
	kubectl cluster-info
	@echo Cluster Ready!

storage: cluster
	kubectl apply -f resources/storage/gp2-storage-class.yaml

storage-clean: wordpress-clean
	kubectl delete -f resources/storage/gp2-storage-class.yaml

tiller: cluster
	kubectl apply -f resources/tiller/tiller-service-account.yaml
	kubectl apply -f resources/tiller/tiller-rbac.yaml
	helm init --wait --upgrade --service-account tiller

tiller-clean: wordpress-clean
	-helm reset
	kubectl delete -f resources/tiller/tiller-rbac.yaml
	kubectl delete -f resources/tiller/tiller-service-account.yaml

chart: tiller
	helm install -f values.yaml --wait --name wordpress-demo stable/wordpress

kubepress: storage chart
	@echo ============================================
	@echo WordPress URL: http://$(LOADBALANCER)/
	@echo WordPress Admin URL: http://$(LOADBALANCER)/admin
	@echo Username: user
	@echo Password: $(WPPASSWORD)
	@echo ============================================

kubepress-clean:
	-helm delete --purge wordpress-demo

clean: wordpress-clean tiller-clean storage-clean
	@echo removed everything from the cluster

destroy:
	cd terraform && terraform destroy
	rm -f terraform/config-map-aws-auth.yaml
