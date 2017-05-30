
SHELL=/bin/bash
VIRTUALENV=.virtualenv

FUNCTION=townclock-ping-timercheck
SOURCE=code/lambda_function.py
CODELIB=code/lib
SAM=sam-template.yaml
CLOUDFORMATION=cloudformation-template-$(REGION).yaml
PACKAGE_PREFIX=sam-package
STACK_NAME=townclock-ping-timercheck

.PHONY: help
help:: ## Show help text
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

$(VIRTUALENV)/bin/activate:
	virtualenv --python $$(which python3.6) $(VIRTUALENV)
	source $(VIRTUALENV)/bin/activate; \
	pip3 install requests

virtualenv:: $(VIRTUALENV)/bin/activate

.PHONY: setup
setup:: ## Install development prerequisites and virtualenv
	sudo apt-get install python3.6
	sudo -H pip3 install virtualenv

setup:: virtualenv

ifndef REGION
package deploy::
	@echo "ERROR: PLease specify REGION="
	@exit 1
else
ifndef PACKAGE_BUCKET
package deploy::
	@echo "ERROR: PLease specify PACKAGE_BUCKET="
	@exit 1
else
ifndef TIMER_URL
package deploy::
	@echo "ERROR: PLease specify TIMER_URL="
	@exit 1
else
ifndef TOPIC_ARN
package deploy::
	@echo "ERROR: PLease specify TOPIC_ARN="
	@exit 1
else

$(CLOUDFORMATION): $(SAM) $(SOURCE) Makefile
	aws cloudformation package \
	  --region $(REGION) \
	  --template-file $< \
	  --output-template-file $@ \
	  --s3-bucket $(PACKAGE_BUCKET) \
	  --s3-prefix $(PACKAGE_PREFIX)

$(CODELIB): Makefile
	rsync -va $(VIRTUALENV)/lib/python3.6/site-packages/ $@/

.PHONY: package
package:: ## Package AWS Lambda function and generate CloudFormation template
package:: $(CLOUDFORMATION) $(CODELIB)

.PHONY: deploy
deploy:: package ## Deploy AWS Lambda function
	aws cloudformation deploy \
	  --region $(REGION) \
	  --stack-name $(STACK_NAME) \
	  --template-file $(CLOUDFORMATION) \
	  --parameter-overrides \
	    "topic=$(TOPIC_ARN)" \
	    "url=$(TIMER_URL)" \
	  --capabilities CAPABILITY_IAM
endif # TOPIC_ARN
endif # TIMER_URL
endif # PACKAGE_BUCKET
endif # REGION

.PHONY: test
test:: ## Run in local dev environment
	source $(VIRTUALENV)/bin/activate; \
	./lambda_function.py

.PHONY: clean
clean:: ## Cleanup local directory
	rm -rf $(VIRTUALENV) cloudformation-template-*.yaml $(CODELIB)

