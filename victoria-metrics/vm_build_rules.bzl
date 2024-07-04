load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@rules_pkg//pkg:pkg.bzl", "pkg_deb", "pkg_tar")


def build_victoria_metrics(version, arch):
    target="victoria_metrics_{}_{}".format(version.replace(".", "_"), arch)
    pkg_tar(
        name="content_{}".format(target),
        srcs=[
            "@{}//:vmselect-prod".format(target),
            "@{}//:vmstorage-prod".format(target),
            "@{}//:vminsert-prod".format(target),
            ":vmselect.service",
            ":vmselect.defaults",
            ":vminsert.service",
            ":vminsert.defaults",
            ":vmstorage.service",
            ":vmstorage.defaults",
            ":preset",
        ],
        remap_paths={
            "/vmselect": "/usr/bin/vmselect",
            "/vmselect.service": "/lib/systemd/system/vmselect.service",
            "/vminsert": "/usr/bin/vminsert",
            "/vminsert.service": "/lib/systemd/system/vminsert.service",
            "/vmstorage": "/usr/bin/vmstorage",
            "/vmstorage.service": "/lib/systemd/system/vmstorage.service",
            "/preset": "/usr/lib/systemd/system-preset/victoria-metrics-cluster.preset",
            "/vmstorage.defaults": "/etc/default/vmstorage",
            "/vminsert.defaults": "/etc/default/vminsert",
            "/vmselect.defaults": "/etc/default/vmselect",
        },
        owner="0.0",
        modes={
            "/usr/bin/vmselect": "0755",
            "/usr/bin/vminsert": "0755",
            "/usr/bin/vmstorage": "0755",
            "/usr/lib/systemd/system-preset/victoria-metrics-cluster.preset": "0644",
            "/lib/systemd/system/vmselect.service": "0644",
            "/lib/systemd/system/vminsert.service": "0644",
            "/lib/systemd/system/vmstorage.service": "0644",
            "/etc/default/vminsert": "0640",
            "/etc/default/vmselect": "0640",
            "/etc/default/vmstorage": "0640",
        },
        mode="0755",
        package_dir="/",
    )

    pkg_deb(
        name="deb_{}_{}".format(version, arch),
        architecture=arch,
        data=":content_{}".format(target),
        description="Victoria Metrics Cluster binaries",
        package="victoria-metrics-cluster",
        version=version,
        maintainer="Dmitry Orlov <me@mosquito.su>",
        postinst="postinst",
        postrm="postrm",
        prerm="prerm",
        conffiles=[
            "/etc/default/vmstorage",
            "/etc/default/vmselect",
            "/etc/default/vminsert",
        ],
        depends=[
            "bash",
            "libc-bin",
            "passwd",
            "systemd",
        ]
    )

    target_utils="victoria_metrics_utils_{}_{}".format(version.replace(".", "_"), arch)
    pkg_tar(
        name="content_{}".format(target_utils),
        srcs=[
          "@{}//:vmagent-prod".format(target_utils),
          "@{}//:vmalert-prod".format(target_utils),
          "@{}//:vmalert-tool-prod".format(target_utils),
          "@{}//:vmauth-prod".format(target_utils),
          "@{}//:vmbackup-prod".format(target_utils),
          "@{}//:vmctl-prod".format(target_utils),
          "@{}//:vmrestore-prod".format(target_utils),
        ],
        remap_paths={
          "/vmagent-prod": "/usr/bin/vmagent",
          "/vmalert-prod": "/usr/bin/vmalert",
          "/vmalert-tool-prod": "/usr/bin/vmalert-tool",
          "/vmauth-prod": "/usr/bin/vmauth",
          "/vmbackup-prod": "/usr/bin/vmbackup",
          "/vmctl-prod": "/usr/bin/vmctl",
          "/vmrestore-prod": "/usr/bin/vmrestore",
        },
        owner="0.0",
        modes={
            "/usr/bin/vmagent": "0755",
            "/usr/bin/vmalert": "0755",
            "/usr/bin/vmalert-tool": "0755",
            "/usr/bin/vmauth": "0755",
            "/usr/bin/vmbackup": "0755",
            "/usr/bin/vmctl": "0755",
            "/usr/bin/vmrestore": "0755",
        },
        mode="0755",
        package_dir="/",
    )

    pkg_deb(
        name="deb_utils_{}_{}".format(version, arch),
        architecture=arch,
        data=":content_{}".format(target_utils),
        description="Victoria Metrics urils binaries",
        package="victoria-metrics-utils",
        version=version,
        maintainer="Dmitry Orlov <me@mosquito.su>",
    )
