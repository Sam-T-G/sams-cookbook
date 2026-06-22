# CI workflow definitions (parked)

These are the repository's CI workflows: `ci.yml` (build and test all recipes), `manifest-check.yml`
(assert `recipes.yaml` matches the `recipes/` tree), and `model-currency.yml` (flag a stale Claude model
id).

They live here, not in `.github/workflows/`, for one reason: the initial push used a GitHub OAuth token
without the `workflow` scope, and GitHub refuses to create files under `.github/workflows/` from such a
token (the same restriction applies to the API). Parking them one directory over let the rest of the repo
push cleanly.

## To activate CI

Move the three files into `.github/workflows/` and push. That push needs the `workflow` scope, so do one of:

- Grant the scope to the CLI, then move and push:
  ```sh
  gh auth refresh -h github.com -s workflow
  git mv ci/github-workflows/*.yml .github/workflows/   # create the dir first if needed
  git commit -m "Activate CI workflows"
  git push
  ```
- Or add the three files through the GitHub web UI under `.github/workflows/`, which is allowed from the
  browser, and delete this directory.

The workflow contents are final and reference `scripts/test_all.sh` and `scripts/check_manifest.sh`, which
already exist at the repo root. Nothing else needs to change when you move them.
