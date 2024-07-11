load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


def load_prometheus(version, arch):
    http_archive(
        name="prometheus_{}_{}".format(version.replace(".", "_"), arch),
        urls=[
            "https://github.com/prometheus/prometheus/releases/download/v{}/prometheus-{}.linux-{}.tar.gz".format(version, version, arch),
        ],
        build_file_content="""exports_files(["prometheus"], visibility = ["//visibility:public"])""",
        strip_prefix="prometheus-{version}.linux-{arch}".format(version=version, arch=arch),
    )
