export AWS_MAX_ATTEMPTS = 360
export AWS_POLL_DELAY_SECONDS = 10

AMI = prozzie-ami.json

.PHONY: all ami packer-validate

all: packer-validate ami

output:
	mkdir -p output

packer-validate: $(AMI)
	packer validate $^

ami: $(AMI) output
	packer build $< | tee output/packer.log
