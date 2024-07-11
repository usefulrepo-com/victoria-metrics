load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@rules_pkg//pkg:pkg.bzl", "pkg_deb", "pkg_tar")


def build_prometheus(version, arch):
    target = "prometheus_{}_{}".format(version.replace(".", "_"), arch)
    pkg_tar(
        name="content_{}".format(target),
        srcs=[
            "@{}//:prometheus".format(target),
            ":prometheus.service",
            ":prometheus.defaults",
        ],
        remap_paths={
            "/prometheus.service": "/lib/systemd/system/prometheus.service",
            "/prometheus.defaults": "/etc/default/prometheus",
            "/prometheus": "/usr/bin/prometheus",
        },
        owner="0.0",
        modes={
            "/usr/bin/prometheus": "0755",
            "/lib/systemd/system/prometheus.service": "0644",
            "/etc/default/prometheus": "0640",
        },
        mode="0755",
        package_dir="/",
    )

    pkg_deb(
        name="deb_{}_{}".format(version, arch),
        architecture=arch,
        data=":content_{}".format(target),
        description="Prometheus",
        package="prometheus",
        version=version,
        maintainer="Dmitry Orlov <me@mosquito.su>",
        postinst="postinst",
        postrm="postrm",
        prerm="prerm",
        conffiles=["/etc/default/prometheus"],
        depends=[
            "bash",
            "libc-bin",
            "passwd",
            "systemd",
        ]
    )
