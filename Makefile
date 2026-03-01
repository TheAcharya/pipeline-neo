SCHEME = PipelineNeo
DESTINATION = platform=macOS
CONFIGURATION = debug

.PHONY: help build build-release test clean resolve lint

help: ## Show available targets
	@grep -E '^[a-z][-a-z]*:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'

resolve: ## Resolve package dependencies
	xcodebuild -resolvePackageDependencies -scheme $(SCHEME) -destination '$(DESTINATION)'

build: ## Build the package (debug)
	xcodebuild build -scheme $(SCHEME) -destination '$(DESTINATION)' -configuration $(CONFIGURATION)

build-release: ## Build the package (release)
	xcodebuild build -scheme $(SCHEME) -destination '$(DESTINATION)' -configuration release

test: ## Run tests
	xcodebuild test -scheme PipelineNeo-Package -destination '$(DESTINATION)'

lint: ## Format Swift source files
	swift format -i -r .

clean: ## Clean build artifacts
	xcodebuild clean -scheme $(SCHEME) -destination '$(DESTINATION)'
	rm -rf .build
