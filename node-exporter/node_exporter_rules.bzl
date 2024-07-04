load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@rules_pkg//pkg:pkg.bzl", "pkg_deb", "pkg_tar")


def build_node_exporter(version, arch):
    target = "node_exporter_{}_{}".format(version.replace(".", "_"), arch)
    pkg_tar(
        name="content_{}".format(target),
        srcs=[
            "@{}//:node_exporter".format(target),
            ":node-exporter.service",
            ":node-exporter.defaults",
        ],
        remap_paths={
            "/node_exporter": "/usr/bin/node-exporter",
            "/node-exporter.service": "/lib/systemd/system/node-exporter.service",
            "/node-exporter.defaults": "/etc/default/node-exporter",
        },
        owner="0.0",
        modes={
            "/usr/bin/node-exporter": "0755",
            "/lib/systemd/system/node-exporter.service": "0644",
            "/etc/default/node-exporter": "0640",
        },
        mode="0755",
        package_dir="/",
    )

    pkg_deb(
        name="deb_{}_{}".format(version, arch),
        architecture=arch,
        data=":content_{}".format(target),
        description="Node exporter",
        package="node-exporter",
        version=version,
        maintainer="Dmitry Orlov <me@mosquito.su>",
        postinst="postinst",
        postrm="postrm",
        prerm="prerm",
        conffiles=["/etc/default/node-exporter"],
        depends=[
            "bash",
            "libc-bin",
            "passwd",
            "systemd",
        ]
    )
