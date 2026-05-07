# Debugging a Broken Deployment

This file documents three deliberately broken scenarios you can apply to a working
cluster to practice debugging. For each, you'll find:

- the change that breaks it
- the symptom you'll see in `kubectl get pods`
- the diagnostic commands that reveal the root cause
- the fix

Every scenario assumes the app is already running. To go back to a healthy
state after each experiment, re-run the GitHub Actions pipeline (push any
commit) or `kubectl apply -f k8s/`.

---

## Scenario 1 — `ImagePullBackOff` (wrong image tag)

**Break it.** Edit `k8s/deployment.yaml` and replace the image with a tag
that doesn't exist in ECR:

```yaml
image: 661971210188.dkr.ecr.us-east-1.amazonaws.com/microservice-dev:does-not-exist
```

Then `kubectl apply -f k8s/deployment.yaml`.

**Symptom**

```
$ kubectl get pods -l app=microservice
NAME                            READY   STATUS             RESTARTS   AGE
microservice-7c8d4f9b6c-abcde   0/1     ImagePullBackOff   0          30s
```

**Diagnose**

```bash
kubectl describe pod -l app=microservice | tail -20
# Look at "Events" for: Failed to pull image ... not found

kubectl get events --sort-by=.lastTimestamp | tail -10
```

You'll see something like:
`Failed to pull image "...:does-not-exist": ... manifest unknown`.

**Fix.** Restore a valid tag (e.g. `:latest` or a known SHA) and re-apply.

---

## Scenario 2 — `CrashLoopBackOff` (bad probe path)

**Break it.** Change the readiness probe path in `k8s/deployment.yaml` to
something the app doesn't serve, plus break the liveness so the kubelet
keeps killing the container:

```yaml
readinessProbe:
  httpGet:
    path: /does-not-exist
    port: http
livenessProbe:
  httpGet:
    path: /does-not-exist
    port: http
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 1
```

**Symptom**

```
$ kubectl get pods -l app=microservice
NAME                            READY   STATUS             RESTARTS   AGE
microservice-...                0/1     CrashLoopBackOff   3          90s
```

**Diagnose**

```bash
kubectl describe pod -l app=microservice
# Events show: "Liveness probe failed: HTTP probe failed with statuscode: 404"

kubectl logs -l app=microservice --tail=50
# App logs show 404s for /does-not-exist
```

**Fix.** Change probe paths back to `/health` and re-apply.

---

## Scenario 3 — `CreateContainerConfigError` (missing ConfigMap key)

**Break it.** Reference a ConfigMap that doesn't exist by changing
`envFrom` in `k8s/deployment.yaml`:

```yaml
envFrom:
  - configMapRef:
      name: microservice-config-typo   # this name doesn't exist
  - secretRef:
      name: microservice-secret
```

**Symptom**

```
$ kubectl get pods -l app=microservice
NAME                            READY   STATUS                       RESTARTS   AGE
microservice-...                0/1     CreateContainerConfigError   0          15s
```

**Diagnose**

```bash
kubectl describe pod -l app=microservice | grep -A2 "Warning"
# Events show: configmap "microservice-config-typo" not found
```

**Fix.** Restore the correct ConfigMap name (`microservice-config`) and re-apply.

---

## A general debugging cheat-sheet

```bash
# 1. What state are pods in?
kubectl get pods -l app=microservice -o wide

# 2. Why is a pod unhealthy? (events at the bottom are gold)
kubectl describe pod <pod-name>

# 3. What is the app saying?
kubectl logs <pod-name>
kubectl logs <pod-name> --previous     # if it crashed

# 4. Cluster-wide recent events
kubectl get events --sort-by=.lastTimestamp | tail -20

# 5. Is the Deployment progressing?
kubectl rollout status deployment/microservice
kubectl rollout history deployment/microservice

# 6. Is the Service routing to ready pods?
kubectl get endpoints microservice

# 7. Roll back to the previous good revision
kubectl rollout undo deployment/microservice
```
