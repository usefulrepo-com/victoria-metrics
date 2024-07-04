load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


def load_node_exporter(version, arch):
    http_archive(
        name="node_exporter_{}_{}".format(version.replace(".", "_"), arch),
        urls=[
            "https://github.com/prometheus/node_exporter/releases/download/v{}/node_exporter-{}.linux-{}.tar.gz".format(version, version, arch),
        ],
        build_file_content="""exports_files(["node_exporter"], visibility = ["//visibility:public"])""",
        strip_prefix="node_exporter-{version}.linux-{arch}".format(version=version, arch=arch),
    )
