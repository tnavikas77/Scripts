# GitHub Actions → Helm → Tanzu: NGINX

This repository deploys **an existing image** to Tanzu using Helm. It does not build or push images. The NGINX image must support unprivileged startup and HTTP on port `8080`, like `nginxinc/nginx-unprivileged`.

## Before first run

1. Push these files to your selected GitHub repository's default branch.
2. The workflow runs on a **Telia-managed Ubuntu GitHub Actions runner**. Set the repository variable `DEPLOY_RUNNER_LABEL` to the **exact runner label** supplied by your GitHub/Telia administrator. Confirm that the runner has `bash`, Git, and Helm installed, and can reach the private Tanzu API (`10.195.17.155:6443` for dev). The fact that the runner is managed does not itself prove that its network reaches Tanzu. Do not expose the control-plane API publicly just to make this workflow work.
3. Create GitHub Environments named `dev`, `staging`, `production`.
4. Within **each** environment, configure:

   | Setting | Type | Example for dev |
   | --- | --- | --- |
   | `KUBECONFIG` | Environment secret | Full kubeconfig YAML for the corresponding cluster (use a least-privilege deploy identity) |
   | `NGINX_IMAGE_REPOSITORY` | Environment variable | `your-company.jfrog.io/docker-local/nginx-unprivileged` |
   | `K8S_CONTEXT` | Environment variable | `cl-hby-dev-dac-00-admin@cl-hby-dev-dac-00` (prefer a scoped deploy account/context) |
   | `K8S_NAMESPACE` | Environment variable | `test-web` |

   Set staging and production to their **own** correct cluster contexts, kubeconfigs, namespaces and registry policies. Do not copy the dev admin kubeconfig into production. Set GitHub environment protection rules and branch restrictions.

5. Verify the image and tag are present in your **internal JFrog** registry and **worker nodes** can reach it on HTTPS. The cluster previously failed to pull directly from Docker Hub due to TCP 443 timeout.
6. For a private JFrog registry, create a `kubernetes.io/dockerconfigjson` image-pull Secret in the deployment namespace via your approved secret management workflow; then populate `imagePullSecrets` in the environment values file, e.g.:

   ```yaml
   imagePullSecrets:
     - name: jfrog-pull
   ```

   Do not commit passwords or tokens. The Kubernetes **worker nodes**, not the runner, pull the image.

## Run

Go to **Actions → Deploy NGINX to Tanzu → Run workflow**. Select the branch, environment, and enter the existing JFrog image tag (editable text). The built-in GitHub branch selector chooses which workflow/chart branch executes.

The chart installs the separate Helm release **`nginx-demo`**. It does not modify the pre-existing unmanaged `nginx-test` deployment currently stuck in `ImagePullBackOff` in namespace `test-web`.

After success, verify from an authorized laptop:

```powershell
kubectl -n test-web get deploy,po,svc
kubectl -n test-web port-forward svc/nginx-demo 8080:80
```

Open `http://localhost:8080` while port forwarding is running. The default Service is `ClusterIP`, so it does not allocate a new external load balancer address.

## Operational notes

- If Helm exits with `ImagePullBackOff`, verify JFrog host, image/tag, registry trust, network, and pull-secret configuration.
- A `--wait` deployment fails if pods don't become ready; this workflow does not auto-rollback.
- No Kubernetes changes are made until someone actually triggers the workflow with configured credentials and working private connectivity.
