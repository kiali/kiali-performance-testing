
ENV_FILE := .env
include ${ENV_FILE}
export $(shell sed 's/=.*//' ${ENV_FILE})

create-image:
	@echo Building the Kiali Windsock Docker image
	docker build -t ${IMAGE_NAME} docker/windsock

push-image:
	@echo Pushing the Kiali Windsock Docker image
	docker push ${IMAGE_NAME}

clean:
	@echo "Cleaning any build artifacts"
	@echo "  - Removing the _output directory"
	@rm -rf _output


deploy-dashboard-ephemeral:
	@echo Deploying dashboard with no persistent storage
	ansible-playbook ansible/dashboard.yml -e ephemeral=true -vvv

deploy-dashboard-persistent:
	@echo Deploying dashboard with persistent storage 
	ansible-playbook ansible/dashboard.yml -e ephemeral=false  -e storage_size=${STORAGE_SIZE} -e influx_replicas=${INFLUX_REPLICAS}  -vvv

deploy-performance-test:
	@echo Deploying Performance Test Kiali Windsock
	ansible-playbook ansible/performance_test.yml -e route='${ROUTE}' -e kiali_username=${KIALI_USERNAME} -e kiali_password=${KIALI_PASSWORD} -e test_name=${TEST_NAME} -e influx_address='${INFLUX_ADDRESS}' -e influx_username=${INFLUX_USERNAME} -e influx_password=${INFLUX_PASSWORD} -e rate=${RATE} -e duration=${DURATION} -e number_of_users=${NUMBER_OF_USERS}  -v

connect-influxdb:
	influx -host '${INFLUX_HOSTNAME}' -port '80' -username '${INFLUX_USERNAME}' -password '${INFLUX_PASSWORD}'

