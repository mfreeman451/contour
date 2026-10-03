# Working in CONTOUR

## Development

- Use Elixir 1.20.4, Ash domains/resources, AshPostgres, and AshOban for application data and background work. Use Tailwind v4 for CSS.
- Write all first-party frontend code in strict TypeScript, including Three.js, renderer, protocol, and worker code. Keep type checking in the build; esbuild transpilation alone is insufficient.
- Target `ESNext` with pinned TypeScript/esbuild versions. Browser capabilities such as WebGPU require explicit runtime checks.
- The daily loop is a persistent stock CNPG PostgreSQL container through Apple's `container` CLI, with the application running locally through BEAM and `mix phx.server`.
- Bazel and BuildBuddy RBE own reproducible builds and CI tests. Kubernetes deployment is an occasional staging check until MVP.
- Kubernetes manifests belong in `k8s/` and use Kustomize. Staging targets `farm01`; production targets `carverauto` and promotion is deferred.
- Keep actual credentials, local `.env` files, and `.bazelrc.remote` out of Git and Bazel inputs. Never print secrets when inspecting configuration.

## Testing

- Prefer a small number of end-to-end and integration tests that exercise real workflows and boundaries: HTTP authentication, PostgreSQL persistence, cluster placement, and browser behavior.
- Add unit tests only for hard logic with meaningful edge cases, an important invariant that integration coverage cannot reach efficiently, or a specific regression. Explain the contract they protect.
- Do not generate a test for every function or module. Do not test framework boilerplate, copy implementation details into assertions, or add mocks that merely reproduce the behavior under test.
- Before adding coverage, identify the credible failure it detects and check whether an existing integration test already owns that contract. Extend that test when practical.
- Fix failures at their owner boundary. Run the checks relevant to a change; avoid repeated full-suite runs without a new reason.
- Use invented fixtures and isolated databases. Never run destructive tests against a staging or production database.

## Collaboration

- **mfreeman451/rts-game**: GitHub, default branch `main`. Use `gh-axi`/`gh` for issues, PRs, reviews, and comments. Build and test through Bazel/BuildBuddy. Shared infrastructure uses `registry.carverauto.dev`; this application's images live under `contour/`.

## Collaboration hosts

- **carverauto/serviceradar** (product): GitHub. Issues, PRs, reviews, comments via `gh-axi`/`gh` on https://github.com/carverauto/serviceradar. Default branch `staging`. Never `fj pr` / `fj issue` for this repo. Lint/check = GitHub Actions on ARC (`self-hosted, Linux, X64, arc-runner-set`). Tests = BuildBuddy. Harbor stays `registry.carverauto.dev`. Until remotes flip, `origin` may still be Forgejo — push to `git@github.com:carverauto/serviceradar.git` (remote `github`) and open the PR with `gh`.
- **carverauto/gitops**: moving to GitHub. New issues/PRs via `gh-axi`/`gh` on https://github.com/carverauto/gitops. Merge the Argo repoURL flip through Forgejo first.
- **carverauto/crm**, **carverauto/serviceradar-control**: stay on Forgejo. Use `fj`.
