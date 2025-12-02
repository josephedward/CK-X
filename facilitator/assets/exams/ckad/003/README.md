# CKAD-003 Exam Assets

This directory contains the CKAD practice exam 3 for the CK‑X simulator.

Highlights
- Single-cluster design with namespace isolation per question.
- Outputs are written under `/opt/course/exam3/qXX/` and `/opt/course/exam3/p{1..3}/`.
- Setup scripts are idempotent; validators are namespace-aware.

Namespaces
- Questions: `ckad-q01` … `ckad-q22` (where applicable)
- Previews: `ckad-p1`, `ckad-p2`, `ckad-p3`
- Special for Q7: `ckad-q07-source`, `ckad-q07-target`

Gotchas
- Q4 (Helm): Requires `helm`. Setup seeds three initial releases: `internal-issue-report-apiv1` and `internal-issue-report-apiv2` in `ckad-q04`, and a third release `internal-issue-report-pending` stuck in `pending-install` in namespace `ckad-q04-stuck`. The task requires deleting `apiv1`, upgrading `apiv2`, installing a new `internal-issue-report-apache` with 2 replicas, and deleting any `pending-install` releases across namespaces (discover with `helm ls -A`). Validators require Helm; no degraded path.
- Q11 (Docker/Podman): If not available, validators accept a logs file at `/opt/course/exam3/q11/logs` containing the marker `SUN_CIPHER_ID`.
- Q12/13 (Storage): PVC may stay `Pending` without a matching provisioner; validators account for this.
- Q18 (Service): Setup is intentionally broken (wrong selector and wrong targetPort). Validators require both endpoints to exist and the endpoint port to be 4444 after the fix.
- Q19 (NodePort): Validators check type and `nodePort=30100`.

Validate Locally
- Prefer `make up` and `make check-answers` workflows.
- Ensure `.env` reflects `CKX_PLATFORM=linux/arm64` and images support arm64.
