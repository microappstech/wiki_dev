# Kubernetes Cheatsheet — Senior DevOps Summary

Quick cluster choices:
- Local/dev: Kind, k3s, minikube.
- Managed: AKS, EKS, GKE for production-grade operations.

Essential `kubectl` commands:

```
kubectl config get-contexts
kubectl config use-context <ctx>
kubectl get ns
kubectl get all -n <ns>
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -c <container> -n <ns>
kubectl exec -it <pod> -n <ns> -- /bin/sh
kubectl apply -f k8s.yaml
kubectl rollout status deployment/<name> -n <ns>
kubectl rollout undo deployment/<name> -n <ns>
kubectl port-forward svc/<svc> 8080:80 -n <ns>
```

Deployment tips:
- Use readiness and liveness probes for safe rollouts.
- Prefer Deployments with pod disruption budgets and resource requests/limits.
- Use ConfigMaps and Secrets (externalize secrets to Vault or cloud KMS).

Observability & debugging:
- Collect metrics with Prometheus; use Fluentd/FluentBit or Vector for logs.
- Use `kubectl top pods` (metrics-server) for resource insights.

Networking:
- Use NetworkPolicies to restrict pod-to-pod traffic.
- For ingress, prefer managed ingress controllers (NGINX, Traefik) or cloud ingress.

.NET-specific notes:
- Containers should run as non-root where possible.
- Build with `dotnet publish -c Release -o out` and use minimal runtime image.
- Probe endpoints should be lightweight and fast.

Security & policies:
- Use admission controllers (OPA/Gatekeeper) to enforce policies.
- Scan images (Trivy) and enforce image provenance via SBOM and signatures.
