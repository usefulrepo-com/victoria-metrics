load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@rules_pkg//pkg:pkg.bzl", "pkg_deb", "pkg_tar")


def build_prometheus(version, arch):
    target = "prometheus_{}_{}".format(version.replace(".", "_"), arch)
    
    existing_binaries = [
        "@{}//:{}".format(target, binary)
        for binary in binaries
        if native.existing_rule("@{}//:{}".format(target, binary))
    ]
    
    remap_paths = {
        "/prometheus.service": "/lib/systemd/system/prometheus.service",
        "/prometheus.defaults": "/etc/default/prometheus",
    }
    
    for binary in binaries:
        if "@{}//:{}".format(target, binary) in existing_binaries:
            remap_paths["/" + binary] = "/usr/bin/" + binary
    
    modes = {
        "/lib/systemd/system/prometheus.service": "0644",
        "/etc/default/prometheus": "0640",
    }
    
    for binary in binaries:
        if "@{}//:{}".format(target, binary) in existing_binaries:
            modes["/usr/bin/" + binary] = "0755"

    pkg_tar(
        name="content_{}".format(target),
        srcs=existing_binaries + [
            ":prometheus.service",
            ":prometheus.defaults",
        ],
        remap_paths=remap_paths,
        owner="0.0",
        modes=modes,
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
