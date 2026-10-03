load("@rules_erlang//bzlmod:hex_packages.bzl", "hex_packages_extension", "hex_pkg")
load(":hex_packages.bzl", "HEX_PACKAGES")

hex = hex_packages_extension(packages = [
    hex_pkg(name = app, package_name = package, version = version, sha256 = sha,
            build_file = Label("//third_party/hex:" + app + ".BUILD"))
    for app, package, version, sha in HEX_PACKAGES
])
