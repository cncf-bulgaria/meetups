![CNCF Sofia Meetup](https://secure.meetupstatic.com/photos/event/9/8/2/7/clean_518858951.webp)


# CNCF OWASP Top 10 Kubernetes K01

## Defeating OWASP Security Risks - challenge solutions


## 4. CHALLENGE

Below is the faulty Kubernetes pod specification (`insecure-pod.yaml`) that contains several insecure and incorrect
configurations.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: faulty-pod
spec:
  containers:
  - name: insecure-container
    image: alpine:latest
    command: ["/bin/sh", "-c", "sleep infinity"]
    securityContext:
      runAsUser: 0
      privileged: true
    volumeMounts:
    - name: host-volume
      mountPath: /data
  volumes:
  - name: host-volume
    hostPath:
      path: /var/run
      type: Directory
  hostPID: true
  imagePullPolicy: IfNotPresent
```

Your mission, should you choose to accept it, is to identify the issues using kube-score/kube-linter and fix them. Try
to fix as many issues as you can. We've not discussed `NetworkPolicy`, so you can ignore that one but we'll include it
in the solution just for reference.


## 4.1. Scan the pod with kube-score

Lets start by creating a new directory for the challenge files:

```shell
~$ mkdir ~/owasp-challenge && cd $_
~/owasp-challenge$
```

Create the insecure-pod.yaml with the content provided in the challenge:

```shell
~/owasp-challenge$ nano insecure-pod.yaml && cat $_
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: faulty-pod
spec:
  containers:
  - name: insecure-container
    image: alpine:latest
    command: ["/bin/sh", "-c", "sleep infinity"]
    securityContext:
      runAsUser: 0
      privileged: true
    volumeMounts:
    - name: host-volume
      mountPath: /data
  volumes:
  - name: host-volume
    hostPath:
      path: /var/run
      type: Directory
  hostPID: true
  imagePullPolicy: IfNotPresent
```

```shell
~/owasp-challenge$
```

Run kube-score against the insecure-pod.yaml file.

```shell
~/owasp-challenge$ kube-score score insecure-pod.yaml

v1/Pod faulty-pod                                                             💥
    [CRITICAL] Container Security Context ReadOnlyRootFilesystem
        · insecure-container -> The pod has a container with a writable root filesystem
            Set securityContext.readOnlyRootFilesystem to true
    [CRITICAL] Container Resources
        · insecure-container -> CPU limit is not set
            Resource limits are recommended to avoid resource DDOS. Set resources.limits.cpu
        · insecure-container -> Memory limit is not set
            Resource limits are recommended to avoid resource DDOS. Set resources.limits.memory
        · insecure-container -> CPU request is not set
            Resource requests are recommended to make sure that the application can start and run without
            crashing. Set resources.requests.cpu
        · insecure-container -> Memory request is not set
            Resource requests are recommended to make sure that the application can start and run without
            crashing. Set resources.requests.memory
    [CRITICAL] Container Security Context User Group ID
        · insecure-container -> The container is running with a low user ID
            A userid above 10 000 is recommended to avoid conflicts with the host. Set securityContext.runAsUser
            to a value > 10000
        · insecure-container -> The container running with a low group ID
            A groupid above 10 000 is recommended to avoid conflicts with the host. Set
            securityContext.runAsGroup to a value > 10000
    [CRITICAL] Container Image Tag
        · insecure-container -> Image with latest tag
            Using a fixed tag is recommended to avoid accidental upgrades
    [CRITICAL] Container Ephemeral Storage Request and Limit
        · insecure-container -> Ephemeral Storage limit is not set
            Resource limits are recommended to avoid resource DDOS. Set resources.limits.ephemeral-storage
    [CRITICAL] Pod NetworkPolicy
        · The pod does not have a matching NetworkPolicy
            Create a NetworkPolicy that targets this pod to control who/what can communicate with this pod.
            Note, this feature needs to be supported by the CNI implementation used in the Kubernetes cluster to
            have an effect.
    [CRITICAL] Container Security Context Privileged
        · insecure-container -> The container is privileged
            Set securityContext.privileged to false. Privileged containers can access all devices on the host,
            and grants almost the same access as non-containerized processes on the host.

~/owasp-challenge$
```


## 4.2. Fix the podSpec

Based on the kube-score results we need to make the following changes to the:

- We updated the container's name to `secure-container` to reflect the new config
- We specified a version for the container's image `alpine:3.18.2` instead of using `latest`.
- We changed the `runAsUser` and `runAsGroup` fields to values greater than 10,000.
- We set `readOnlyRootFilesystem` to `true` to make the container's file system read-only.
- We set `privileged` to `false` to - prevent the container from accessing the host's devices.
- We added `resources.requests` and `resources.limits` for CPU, memory, and ephemeral storage. These prevent resource
  DDOS and ensure that the application can run without crashing.
- We replaced the `hostPath` volume with an `emptyDir` volume, which doesn't give the pod access to the host's file
  system.
- `imagePullPolicy: Always` - was added to ensure the latest image is pulled from the registry.


Here are the fixes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  labels:
    app: secure-pod
spec:
  containers:
  - name: secure-container
    image: alpine:3.18.2
    imagePullPolicy: Always
    command: ["/bin/sh", "-c", "sleep infinity"]
    securityContext:
      runAsUser: 10001
      runAsGroup: 10001
      readOnlyRootFilesystem: true
      privileged: false
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
        ephemeral-storage: "1Gi"
      limits:
        memory: "128Mi"
        cpu: "500m"
        ephemeral-storage: "2Gi"
    volumeMounts:
    - name: secure-volume
      mountPath: /data
  volumes:
  - name: secure-volume
    emptyDir: {}
```

The `hostPID` field has also been removed. If it was necessary for some reason, you'd need to evaluate that reason
against the security risk and potentially find a more secure solution.

> Please note that the specific values for the `resources` fields (like `"64Mi"` and `"250m"`) are just examples.

This pod specification doesn't include a network policy, because network policies are typically created separately. Let's
address that now!


## 4.3. Create a network policy

Here is both the pod and the network policy together

```shell
~/owasp-challenge$ nano securepod-and-netpol.yaml && echo $_
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  labels:
    app: secure-pod
spec:
  containers:
  - name: secure-container
    image: alpine:3.18.2
    imagePullPolicy: Always
    command: ["/bin/sh", "-c", "sleep infinity"]
    securityContext:
      runAsUser: 10001
      runAsGroup: 10001
      readOnlyRootFilesystem: true
      privileged: false
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
        ephemeral-storage: "1Gi"
      limits:
        memory: "128Mi"
        cpu: "500m"
        ephemeral-storage: "2Gi"
    volumeMounts:
    - name: secure-volume
      mountPath: /data
  volumes:
  - name: secure-volume
    emptyDir: {}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: secure-pod-network-policy
spec:
  podSelector:
    matchLabels:
      app: secure-pod
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend-service
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend-service
```

And the final kube-score result without any issues:

```shell
~/owasp-challenge$ kube-score score securepod-and-netpol.yaml

networking.k8s.io/v1/NetworkPolicy secure-pod-network-policy                  ✅
v1/Pod secure-pod                                                             ✅

~/owasp-challenge$
```

## Mission completed!

Congratulations, Great Job!
