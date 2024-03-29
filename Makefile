VOLUME_MOUNTS= --bind ../autoreduce:/autoreduce --bind /instrument:/instrument --bind /isis:/isis --bind /isis:/archive

DATE_LABEL := $(shell date +%Y-%m-%dT%H%M)

GHCR=ghcr.io/autoreduction

all: base qp mantid_6.4 mantid_6.3 webapp dbmanage devtest

dev:
	docker build . -f development.D -t autoreduction/dev

qp:
	sudo docker build -t $(GHCR)/autoreduce:$(DATE_LABEL) -f ../queue-processor/container/qp_py38.Dockerfile ../queue-processor
	sudo docker tag $(GHCR)/autoreduce:$(DATE_LABEL) $(GHCR)/autoreduce:latest
	sudo docker push $(GHCR)/autoreduce:$(DATE_LABEL)
	sudo docker push $(GHCR)/autoreduce:latest

mantid_latest:
	sudo docker build -t $(GHCR)/runner-mantid:$(DATE_LABEL) -f ../queue-processor/container/runner_py38_mantid.Dockerfile ../queue-processor
	sudo docker tag $(GHCR)/runner-mantid:$(DATE_LABEL) $(GHCR)/runner-mantid:latest
	sudo docker push $(GHCR)/runner-mantid:$(DATE_LABEL)
	sudo docker push $(GHCR)/runner-mantid:latest

mantid_nightly:
	sudo docker build -t $(GHCR)/runner-mantid:$(DATE_LABEL) -f ../queue-processor/container/runner_py38_mantid.Dockerfile ../queue-processor --build-arg NIGHTLY=True
	sudo docker tag $(GHCR)/runner-mantid:$(DATE_LABEL) $(GHCR)/runner-mantid:nightly
	sudo docker push $(GHCR)/runner-mantid:$(DATE_LABEL)
	sudo docker push $(GHCR)/runner-mantid:nightly

webapp:
	sudo docker build -t $(GHCR)/autoreduce-frontend:$(DATE_LABEL) -f ../frontend/container/webapp.D ../frontend
	sudo docker tag $(GHCR)/autoreduce-frontend:$(DATE_LABEL) $(GHCR)/autoreduce-frontend:latest
	sudo docker push $(GHCR)/autoreduce-frontend:$(DATE_LABEL)
	sudo docker push $(GHCR)/autoreduce-frontend:latest

rest-api:
	sudo docker build -t $(GHCR)/autoreduce-rest-api:$(DATE_LABEL) -f ../rest-api/container/rest-api.D ../rest-api
	sudo docker tag $(GHCR)/autoreduce-rest-api:$(DATE_LABEL) $(GHCR)/autoreduce-rest-api:latest
	sudo docker push $(GHCR)/autoreduce-rest-api:$(DATE_LABEL)
	sudo docker push $(GHCR)/autoreduce-rest-api:latest

run-detection:
	sudo docker build -t $(GHCR)/autoreduce-run-detection:$(DATE_LABEL) -f ../run-detection/container/run-detection.D ../run-detection
	sudo docker tag $(GHCR)/autoreduce-run-detection:$(DATE_LABEL) $(GHCR)/autoreduce-run-detection:latest
	sudo docker push $(GHCR)/autoreduce-run-detection:$(DATE_LABEL)
	sudo docker push $(GHCR)/autoreduce-run-detection:latest

dbmanage: base
	sudo singularity build -F dbmanage.sif dbmanage.def

monitoring-checks:
	sudo singularity build -F monitoring-checks.sif monitoring-checks.def

base:
	sudo docker build -t $(GHCR)/base -f autoreduce_base.D ../queue-processor
	sudo docker push $(GHCR)/base
