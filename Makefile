SNAPSHOT = $(shell date +%s)
ROOTDIR = $(shell aptly config show | jq -r '.FileSystemPublishEndpoints.repo.rootDir')

all:
	bazel build //...
	rm -fr debs
	mkdir -p debs
	find bazel-bin/ -iname "*.deb" -type f | grep -v "deb_" | xargs aptly repo add victoria-metrics-cluster || true
	aptly snapshot create snapshot-$(SNAPSHOT) from repo victoria-metrics-cluster
	aptly publish drop any filesystem:repo:victoria-metrics-cluster || true
	aptly publish snapshot snapshot-$(SNAPSHOT) filesystem:repo:victoria-metrics-cluster
	python3 autoindex.py $(ROOTDIR)/victoria-metrics-cluster
