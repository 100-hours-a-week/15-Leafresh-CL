MODULES := aws k8s

TF := terraform
TF_INIT := $(TF) init
TF_VALIDATE := $(TF) validate
TF_PLAN := $(TF) plan
TF_APPLY := $(TF) apply -auto-approve
TF_DESTROY := $(TF) destroy -auto-approve

.PHONY: all init validate plan apply destroy $(foreach module,$(MODULES),init-$(module) validate-$(module) plan-$(module) apply-$(module) destroy-$(module))

all: init plan

init:
	@echo "Initializing all modules..."
	@for module in $(MODULES); do \
		cd $$module && $(TF_INIT) && cd - >/dev/null; \
	done

validate:
	@echo "Validating all modules..."
	@for module in $(MODULES); do \
		cd $$module && $(TF_VALIDATE) && cd - >/dev/null; \
	done

plan:
	@echo "Planning all modules..."
	@for module in $(MODULES); do \
		cd $$module && $(TF_PLAN) && cd - >/dev/null; \
	done

apply:
	@echo "Applying all modules..."
	@for module in $(MODULES); do \
		cd $$module && $(TF_APPLY) && cd - >/dev/null; \
	done

destroy:
	@echo "Destroying all modules..."
	@for module in $(MODULES); do \
		cd $$module && $(TF_DESTROY) && cd - >/dev/null; \
	done

# 개별 모듈 명령 정의
$(foreach module,$(MODULES), \
	$(eval init-$(module): ; @cd $(module) && $(TF_INIT)) \
	$(eval validate-$(module): ; @cd $(module) && $(TF_VALIDATE)) \
	$(eval plan-$(module): ; @cd $(module) && $(TF_PLAN)) \
	$(eval apply-$(module): ; @cd $(module) && $(TF_APPLY)) \
	$(eval destroy-$(module): ; @cd $(module) && $(TF_DESTROY)) \
)
