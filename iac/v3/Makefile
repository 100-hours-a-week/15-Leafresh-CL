# 사용할 모듈 목록
MODULES := aws k8s

# Terraform 명령어
TF := terraform
TF_INIT := $(TF) init
TF_VALIDATE := $(TF) validate
TF_PLAN := $(TF) plan
TF_APPLY := $(TF) apply -auto-approve
TF_DESTROY := $(TF) destroy -auto-approve

.PHONY: all init plan apply destroy $(foreach module,$(MODULES),init-$(module) plan-$(module) apply-$(module) destroy-$(module))

# 전체 모듈 처리
all: init plan

init:
	@echo "Initializing all modules..."
	@for module in $(MODULES); do \
		cd modules/$$module && $(TF_INIT) && cd - >/dev/null; \
	done

validate:
	@echo "Initializing all modules..."
	@for module in $(MODULES); do \
		cd modules/$$module && $(TF_VALIDATE) && cd - >/dev/null; \
	done

plan:
	@echo "Planning all modules..."
	@for module in $(MODULES); do \
		cd modules/$$module && $(TF_PLAN) && cd - >/dev/null; \
	done

apply:
	@echo "Applying all modules..."
	@for module in $(MODULES); do \
		cd modules/$$module && $(TF_APPLY) && cd - >/dev/null; \
	done

destroy:
	@echo "Destroying all modules..."
	@for module in $(MODULES); do \
		cd modules/$$module && $(TF_DESTROY) && cd - >/dev/null; \
	done

# 개별 모듈 명령
$(foreach module,$(MODULES),\
	init-$(module): ; cd modules/$(module) && $(TF_INIT) ;\
	plan-$(module): ; cd modules/$(module) && $(TF_PLAN) ;\
	apply-$(module): ; cd modules/$(module) && $(TF_APPLY) ;\
	destroy-$(module): ; cd modules/$(module) && $(TF_DESTROY) ;\
)
