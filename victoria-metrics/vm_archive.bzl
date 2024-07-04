load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


def load_victoria_metrics(version, arch):
    http_archive(
        name="victoria_metrics_{}_{}".format(version.replace(".", "_"), arch),
        urls=[
            "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v{}/victoria-metrics-linux-{}-v{}-cluster.tar.gz".format(version, arch, version),
        ],
        build_file_content="""exports_files(["vmselect-prod", "vmstorage-prod", "vminsert-prod"], visibility=["//visibility:public"])""",
    )
    http_archive(
        name="victoria_metrics_utils_{}_{}".format(version.replace(".", "_"), arch),
        urls=[
            "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v{}/vmutils-linux-{}-v{}.tar.gz".format(version, arch, version),
        ],
        build_file_content="""exports_files(["vmagent-prod", "vmalert-prod", "vmalert-tool-prod", "vmauth-prod", "vmbackup-prod", "vmctl-prod", "vmrestore-prod"], visibility = ["//visibility:public"])""",
    )
