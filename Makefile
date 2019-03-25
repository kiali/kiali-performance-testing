
ENV_FILE := .env
include ${ENV_FILE}
export $(shell sed 's/=.*//' ${ENV_FILE})

all: docker-build

docker-build:
	@echo Building the Kiali Windsock Docker image
	docker build -t ${DOCKER_NAME}:${DOCKER_TAG} docker/windsock
	docker push ${DOCKER_NAME}

clean:
	@echo "Cleaning any build artifacts"
	@echo "  - Removing the _output directory"
	@rm -rf _output


deploy-dashboard-ephemeral:
	@echo Deploying dashboard with no persistent storage
	ansible-playbook ansible/dashboard.yml -e ephemeral=true -vvv

deploy-dashboard-persistent:
	@echo Deploying dashboard with persistent storage 
	ansible-playbook ansible/dashboard.yml -e ephemeral=false -vvv

deploy-performance-test:
	@echo Deploying Performance Test Kiali Windsock
	ansible-playbook ansible/performance_test.yml -e route='${ROUTE}' -e kiali_username=${KIALI_USERNAME} -e kiali_password=${KIALI_PASSWORD} -e test_name=${TEST_NAME} -e influx_address='${INFLUX_ADDRESS}' -e influx_username=${INFLUX_USERNAME} -e influx_password=${INFLUX_PASSWORD} -e rate=${RATE} -e duration=${DURATION} -e number_of_users=${NUMBER_OF_USERS}  -v
