load("@bazel_skylib//lib:shell.bzl", "shell")

def _impl(ctx):
    out = ctx.actions.declare_directory(ctx.label.name + "-static") if ctx.attr.operation == "bundle" else ctx.outputs.out
    work = ctx.label.name + "-work"
    commands = ["set -euo pipefail", 'task_root="$PWD"', "mkdir -p " + work + "/web/node_modules"]
    inputs = list(ctx.files.srcs)
    for f in ctx.files.srcs:
        dest = work + "/" + f.short_path
        commands.append("mkdir -p " + shell.quote(dest.rpartition("/")[0]) + " && cp " + shell.quote(f.path) + " " + shell.quote(dest))
    for package, name in ctx.attr.npm_packages.items():
        files = package[DefaultInfo].files.to_list()
        inputs.extend(files)
        dest = work + "/web/node_modules/" + name
        commands.append("mkdir -p " + shell.quote(dest) + " && cp -R " + shell.quote(package.label.workspace_root + "/.") + " " + shell.quote(dest) + "/")
    commands.append('node_binary="$PWD/' + ctx.file.node.path + '"')
    commands.append('tailwind_binary="$PWD/' + ctx.file.tailwind.path + '"')
    commands.append("cd " + work + "/web")
    if ctx.attr.operation == "typecheck":
        commands += ['"$node_binary" node_modules/typescript/bin/tsc --project tsconfig.json --noEmit', 'touch "$task_root/' + out.path + '"']
    elif ctx.attr.operation == "bundle":
        commands += [
            'mkdir -p static/assets/js static/assets/css',
            'node_modules/@esbuild/platform/bin/esbuild src/app.ts --bundle --minify --target=esnext --define:process.env.NODE_ENV=\\\"production\\\" --outfile=static/assets/js/app.js',
            '"$tailwind_binary" --input styles/app.css --output static/assets/css/app.css --minify',
            'mkdir -p "$task_root/' + out.path + '" && cp -R static/. "$task_root/' + out.path + '/"',
        ]
    ctx.actions.run_shell(
        inputs = depset(inputs + [ctx.file.node, ctx.file.tailwind]), outputs = [out],
        command = "\n".join(commands), mnemonic = "ContourWeb", progress_message = "Frontend " + ctx.attr.operation,
    )
    return [DefaultInfo(files = depset([out]))]

web_build = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True), "operation": attr.string(mandatory = True),
        "npm_packages": attr.label_keyed_string_dict(), "node": attr.label(allow_single_file = True),
        "tailwind": attr.label(allow_single_file = True), "out": attr.output(),
    },
)
