load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":npm_packages.bzl", "NPM_PACKAGES")

def _npm(_ctx):
    for package in NPM_PACKAGES:
        http_archive(
            name = package["name"], urls = [package["url"]], integrity = package["integrity"],
            strip_prefix = package["package"].removeprefix("@types/") if package["package"].startswith("@types/") else "package",
            build_file_content = 'filegroup(name="files", srcs=glob(["**"], exclude=["BUILD.bazel"]), visibility=["//visibility:public"])',
        )

npm = module_extension(implementation = _npm)
