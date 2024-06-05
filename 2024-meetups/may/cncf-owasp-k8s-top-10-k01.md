![CNCF Sofia Meetup](https://secure.meetupstatic.com/photos/event/9/8/2/7/clean_518858951.webp)

# CNCF OWASP Top 10 Kubernetes K01

## Defeating OWASP Security Risks

The OWASP Kubernetes Top 10 was created to help SecDevOps, DevOps, SREs, and Developers prioritize addressing Kubernetes
risks. The Top 10 risks range from workload misconfigurations, permissive RBAC policies to network segmentation, and
others. The latest version of the list is from 2022, and you can find it [here](https://owasp.org/www-project-kubernetes-top-ten/)

In this workshop, we will focus on the first of those risks, "K01: Insecure Workload Configurations."

# 0. Pre-requisites

If you attend the `CNCF Bulgaria Meetup 2024 May Edition` in person, you will have access to a VM based on
`Ubuntu 24.04` deployed in the cloud.

> Note: That VM will be available only for the workshop.

You'll need a computer with an `SSH` client to access the Workshop VM. If you are using a Windows machine and you don't
have an ssh client installed, you can try the free version of [MobaXterm](https://mobaxterm.mobatek.net/download.html).

## 0.1. Offline setup

> Note: Please skip this step if you are attending the workshop in person

We'll need a Virtual Machine (VM) based on `Ubuntu 24.04` to complete the workshop offline. We can create one using
any of the freely available desktop hypervisors:

Free and Open Source:

- [VirtualBox](https://www.virtualbox.org)

Free for personal use:
> Note: VMware Workstation Pro and Fusion Pro are now free for personal use. More details you can find
 [here](https://blogs.vmware.com/workstation/2024/05/vmware-workstation-pro-now-available-free-for-personal-use.html)

- [VMware Workstation Pro](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro)
- [VMware Fusion Pro](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Fusion)

Build-in:

- Hyper-V in Windows 11 Pro or Enterprise
- KVM/XEN in Linux Desktops

To save some time (and effort), we can use [Vagrant](https://www.vagrantup.com) to automate the creation of the VM.
Vagrant by HashiCorp is an easy-to-use tool that allows us to create virtual machine-based development
environments using automation quickly.

> Note: We will not spend much time explaining Vagrant in detail here. A good starting point to learn more about
> is the [Get Started](https://developer.hashicorp.com/vagrant/tutorials/getting-started) tutorial.
> If you have any questions/problems, please don't hesitate to contact us.

## 0.1.1. Workshop VM setup using Vagrant

To set up your VM, please make sure that:

- You have installed Vagrant following the [installation instructions](https://developer.hashicorp.com/vagrant/docs/installation)
- Your desktop Virtualization software of choice is configured

Next, we'll create a `Vagrantfile`:

```shell
~$ nano Vagrantfile && cat $_
```

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202404.26.0"
end
```

More details about the Vagrant Box that we'll be using can be found here](https://app.vagrantup.com/bento/boxes/ubuntu-24.04)
Next, we are going to create the VM using the `vagrant up` command:

> Note: The output on your machine might differ based on the platform and hypervisor you are using

```bash
~$ vagrant up
```

```shell
Bringing machine 'default' up with 'vmware_desktop' provider...
==> default: Box 'bento/ubuntu-24.04' could not be found. Attempting to find and install...
    default: Box Provider: vmware_desktop, vmware_fusion, vmware_workstation
    default: Box Version: 202404.26.0
==> default: Loading metadata for box 'bento/ubuntu-24.04'
    default: URL: https://vagrantcloud.com/api/v2/vagrant/bento/ubuntu-24.04
==> default: Adding box 'bento/ubuntu-24.04' (v202404.26.0) for provider: vmware_desktop (arm64)
    default: Downloading: https://vagrantcloud.com/bento/boxes/ubuntu-24.04/versions/202404.26.0/providers/vmware_desktop/arm64/vagrant.box
==> default: Successfully added box 'bento/ubuntu-24.04' (v202404.26.0) for 'vmware_desktop (arm64)'!
==> default: Cloning VMware VM: 'bento/ubuntu-24.04'. This can take some time...
==> default: Checking if box 'bento/ubuntu-24.04' version '202404.26.0' is up to date...
==> default: Verifying vmnet devices are healthy...
==> default: Preparing network adapters...
==> default: Starting the VMware VM...
==> default: Waiting for the VM to receive an address...
==> default: Forwarding ports...
    default: -- 22 => 2222
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default:
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default:
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Configuring network adapters within the VM...
==> default: Waiting for HGFS to become available...
==> default: Enabling and configuring shared folders...
    default: -- /hands-on: /vagrant

~$
```

```shell
~$ vagrant box list
bento/ubuntu-24.04 (vmware_desktop, 202404.26.0, (arm64))

~$ vagrant status default
Current machine states:

default                   running (vmware_desktop)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down, or you can run `vagrant suspend` to simply suspend
the virtual machine. In either case, to restart it again, run
~$
```

Let's get into the VM:

```bash
~$ vagrant ssh
```

```shell
Welcome to Ubuntu 24.04 LTS (GNU/Linux 6.8.0-31-generic aarch64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Fri May 24 02:03:53 PM UTC 2024

  System load:  0.0                Processes:             252
  Usage of /:   10.7% of 29.82GB   Users logged in:       0
  Memory usage: 10%                IPv4 address for eth0: 172.16.237.134
  Swap usage:   0%

vagrant@ubuntu:~$
```

## 0.2. Pre-requisites CNCF Sofia Meetup

If you are attending the workshop in person, you will receive a physical paper sheet with all the details on accessing
your individual, pre-deployed, cloud-based VM. Please talk with the workshop instructors if you have any questions.

You can log in to your machine using an SSH client:

```shell
@laptop:~$ chmod 400 key.pem
@laptop:~$ ssh -i key.pem ubuntu@55.55.55.55
Welcome to Ubuntu 24.04 LTS (GNU/Linux 6.8.0-1008-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro
...

~$
```


## 0.3. Install Kubernetes

To complete the workshop exercises, we'll need a working Kubernetes cluster.  We provide the following script to install
Kubernetes on your VM:

> Note: The script execution might take a few minutes, depending on the machine and internet connection speed.

```shell
~$ wget -qO - https://raw.githubusercontent.com/DojoBits/Toolbox/main/k8s-up.sh | sh

net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
* Applying /usr/lib/sysctl.d/10-apparmor.conf ...
* Applying /etc/sysctl.d/10-console-messages.conf ...
* Applying /etc/sysctl.d/10-ipv6-privacy.conf ...
* Applying /etc/sysctl.d/10-kernel-hardening.conf ...
* Applying /etc/sysctl.d/10-magic-sysrq.conf ...
* Applying /etc/sysctl.d/10-map-count.conf ...
* Applying /etc/sysctl.d/10-network-security.conf ...

...

cilium-linux-amd64.tar.gz: OK
cilium
node/ip-172-31-16-31 patched
~$
```

Once the script completes, you'll have a fully functional single node Kubernetes cluster.

Let's validate that the k8s cluster is up and running.

> Note: It may take a few seconds for the cluster status to become `Ready`:

```bash
~$ kubectl get node
NAME      STATUS   ROLES           AGE    VERSION
vagrant   Ready    control-plane   154m   v1.30.1

~$
```


## 0.4. Enable Auto-completion [optional]

Command auto-completion in the shell is not simply a convenience but an essential productivity feature. This
could be one of the reasons why Kubernetes prioritizes it as the foremost feature of the
[kubectl quick-reference](https://kubernetes.io/docs/reference/kubectl/quick-reference/) guide.

To enable autocompletion in the bash shell in a persistent way, execute:

```bash
~$ sudo apt install bash-completion
~$ echo "source <(kubectl completion bash)" >> ~/.bashrc
```

Many administrators prefer short aliases like `k` for longer commands like `kubectl`. Others use variants like `kc`,
`kctl`, etc. They are all good; it's up to your personal preference. Let's see an example with `k`:

```bash
~$ echo "alias k=kubectl" >> ~/.bashrc
~$ echo "complete -o default -F __start_kubectl k" >> ~/.bashrc
```

Refresh the shell to make sure the changes take effect:

```bash
~$ source ~/.bashrc
```

Let's give it a try! We need to type some commands and press the `<TAB>` key. In the example below, the tab key is
pressed after typing `k get pods --all`, and it provides suggestions:

```bash
~$ k get pods  --all

--all-namespaces               (If present, list the requested object(s) across all namespace…)
--allow-missing-template-keys  (If true, ignore any errors in templates when a field or map k…)

~$
```


# 1. OWASP K01 - insecure workload configurations

The overview of the OWASP K01 risk states:

> The security context of a workload in Kubernetes is highly configurable, which can lead to serious security
> misconfigurations propagating across an organization’s workloads and clusters. The Kubernetes adoption, security, and
> market trends report 2022 from Redhat stated that nearly 53% of respondents have experienced a misconfiguration
> incident in their Kubernetes environments in the last 12 months.

Let's create a pod definition using some `bad security practices` to illustrate this risk:

```shell
~$ mkdir k01 && cd $_
~/k01$ nano priv-pod.yaml && cat $_
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: priv-pod
spec:
  # Bad host volume mount
  volumes:
  - name: nicehost
    hostPath:
      path: /
  # Host PID can lead to container breakouts
  hostPID: true
  containers:
  - name: root-user
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: nicehost
      mountPath: /host
    securityContext:
      # priviliged enables all system calls
      privileged: true
      # root user - an obvious problem
      runAsUser: 0
```

```shell
~/k01$
```

Let's review the security issues with this configuration:

- **Host volume mount**: The container mounts the host's root filesystem (`path: /`). This provides the container full
  read-write access to the host's file system, which is a significant security risk.

- **Host PID namespace**: The configuration specifies that the container should share the host's PID namespace
  (`hostPID: true`). This allows processes within the container to see and interact with all processes on the host as
  well as the `/proc` filesystem where secrets exist!

- **Privileged mode**: The container runs in privileged mode (`privileged: true`). This means it has access to all
  devices on the host and can make any system call to the kernel.

- **Running as Root**: In the `securityContext`, the container is configured to run as root (`runAsUser: 0`). Running
  containers as root (default) can potentially escalate to root on the host, especially if combined with
  `privileged: true`.

These settings significantly reduce the isolation between the container and the host and should be avoided
unless necessary. Generally, containers should be run with the least privilege necessary to
accomplish their tasks.

Let's apply the yaml file and create the pod:

```shell
~/k01$ kubectl apply -f priv-pod.yaml
pod/root-user created

~/k01$
```

```shell
~/k01$ kubectl get po
NAME        READY   STATUS    RESTARTS   AGE
priv-pod   1/1     Running   0          3s

~/k01$
```

Let's explore what we can do from the privileged container within the pod we've just created. First, we'll open a shell
within the container:

```shell
~/k01$ kubectl exec -it priv-pod -- sh
```

Next, we'll validate that we have root privileges:

```shell
/ # id

uid=0(root) gid=0(root) groups=0(root),10(wheel)

/ #
```

As we've mounted the host filesystem into the container and we have root privileges, we can access `any` file on the
host file system. For example, let's check the `/etc/shadow` file, which contains the password hashes of all the users on
the host:

```shell
/ # head -5 /host/etc/shadow

root:*:19516:0:99999:7:::
daemon:*:19516:0:99999:7:::
bin:*:19516:0:99999:7:::
sys:*:19516:0:99999:7:::
sync:*:19516:0:99999:7:::

/ #
```

We can also browse the entire host filesystem:

```shell
/ # ls /host

bin         home        libx32      opt         sbin        tmp
boot        lib         lost+found  proc        snap        usr
dev         lib32       media       root        srv         var
etc         lib64       mnt         run         sys

/ #
```

We see the host root ( `/` ) filesystem.

We can create or modify files:

```shell
/ # echo 'Sneaky' >> /host/gothacked.txt

/ # ls -l /host/gothacked.txt

-rw-r--r--    1 root     root             7 May 30 10:05 /host/gothacked.txt

/ # cat /host/gothacked.txt

Sneaky

/ #
```

You can see all host processes:

```shell
/ # ps aux
PID   USER     TIME  COMMAND
    1 root      0:02 {systemd} /sbin/init autoinstall
    2 root      0:00 [kthreadd]
    3 root      0:00 [pool_workqueue_]
    4 root      0:00 [kworker/R-rcu_g]
    ...
  439 root      0:00 /usr/lib/systemd/systemd-journald
  443 root      0:00 [kworker/R-kmpat]
  ...
 1204 root      0:00 /sbin/agetty -o -p -- \u --noclear - linux
 1240 root      0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
 1246 1000      0:00 /usr/lib/systemd/systemd --user
 1247 1000      0:00 (sd-pam)
 2133 root      0:00 vmhgfs-fuse -o allow_other,default_permissions,uid=1000,gid=
 3039 root      1:07 /usr/bin/containerd
 4136 root      0:02 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id ecf6e
 4137 root      0:02 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 558d3
 4182 root      0:02 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 709a8
 4198 root      0:02 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id b074d
 4236 65535     0:00 /pause
 4243 65535     0:00 /pause
 4248 65535     0:00 /pause
 4250 65535     0:00 /pause
 4371 root      4:19 etcd --advertise-client-urls=https://172.16.237.141:2379 --c
 4380 root     11:21 kube-apiserver --advertise-address=172.16.237.141 --allow-pr
 4384 root      2:52 kube-controller-manager --authentication-kubeconfig=/etc/kub
 4393 root      0:37 kube-scheduler --authentication-kubeconfig=/etc/kubernetes/s
 4499 root      0:00 [psimon]
 4503 root      4:28 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/boot
 5065 root      0:03 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 0c991
 5086 65535     0:00 /pause
 5115 root      0:03 /usr/local/bin/kube-proxy --config=/var/lib/kube-proxy/confi
 5281 root      0:02 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id b77be
 5301 65535     0:00 /pause
 5312 root      0:03 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 85d2c
 5340 65535     0:00 /pause
 5388 root      0:47 cilium-operator-generic --config-dir=/tmp/cilium/config-map
 5791 root      2:54 cilium-agent --config-dir=/tmp/cilium/config-map
 6015 root      0:00 cilium-health-responder --listen 4240 --pidfile /var/run/cil
 6157 root      0:02 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 54e56
 6176 root      0:02 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 1b372
 6207 65535     0:00 /pause
 6213 65535     0:00 /pause
 6264 65532     0:11 /coredns -conf /etc/coredns/Corefile
 6271 65532     0:11 /coredns -conf /etc/coredns/Corefile
 6823 root      0:00 [kworker/1:0-rcu]
 7064 root      0:00 [kworker/u4:1-ev]
 7136 root      0:03 [kworker/0:0-eve]
 7491 root      0:00 [kworker/u4:2-ev]
 7667 root      0:00 sshd: vagrant [priv]
 7687 1000      0:01 sshd: vagrant@pts/0
 7688 1000      0:00 -bash
 7822 root      0:00 [kworker/0:1-eve]
 8044 root      0:00 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 84463
 8065 65535     0:00 /pause
 8077 root      0:00 [kworker/u4:3-ev]
 8102 root      0:00 sleep 3600
 8119 1000      0:00 kubectl exec -it root-user -- sh
 8138 root      0:00 sh
 8160 root      0:00 [kworker/0:2-cgr]
 8161 root      0:00 [kworker/0:3]
 8188 root      0:00 ps aux

/ #
```

Another attack is to use the _container runtime socket_ to gain access to other containers running on this host. We can
use two approaches to find it:

- Leveraging our access to the host PID namespace and getting info from running processes
- Using our access to the root filesystem on the host and searching for config file(s)

List processes that are referencing a unix socket file:

```shell
/ # ps aux | grep container-runtime-endpoint

 4503 root      4:35 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.9

/ #
```

The Kubernetes kubelet daemon communicates to a container runtime using the `--container-runtime-endpoint=` configuration
flag, in our case it points to `/var/run/containerd/containerd.sock`.

We have learned two things:

- what the container runtime is: `containerd`
- where it is listening: `/var/run/containerd/containerd.sock`

In our second approach, we can find containerd's config typically found in the `/etc` directory on a host:

```shell
/ # ls -l /host/etc/containerd/
total 8
-rw-r--r--    1 root     root          7004 May 25 14:44 config.toml

/ #
```

There is its config (`.toml`) file! We can confirm that it is configured to listen on a unix socket by searching the
config:

```shell
/ # cat /host/etc/containerd/config.toml  | grep sock

  address = "/run/containerd/containerd.sock"

/ #
```

Confirmed! The socket is at `/run/containerd/containerd.sock`. Let's exit from the container and go back to our host:

```shell
/ # exit

~/k01$
```

Since our runtime is `containerd`, we can use the containerd cli (`crictl`) to interact with it through the unix socket
file.

Next, we'll create a new container that has the `crictl` binary installed:

```shell
~/k01$ nano priv-user-crictl.yaml && cat $_
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: priv-user-crictl
spec:
  # Bad host volumene mount
  volumes:
  - name: nicehost
    hostPath:
      path: /
  # Host PID
  hostPID: true
  containers:
  - name: root-user-crictl
    image: docker.io/dojobits/crictl:v1.30.0
    command: ["sleep", "3600"]
    volumeMounts:
    - name: nicehost
      mountPath: /host
    securityContext:
      # priviliged
      privileged: true
      # root user:
      runAsUser: 0
```

```shell
~/k01$
```

Let's create the pod:

```shell
~/k01$ kubectl apply -f priv-user-crictl.yaml

pod/priv-user-crictl created

~/k01$
```

Confirm that our pod is running:

```shell
~/k01$ kubectl get po

NAME               READY   STATUS    RESTARTS   AGE
prinv-pod          1/1     Running   0          3m37s
prinv-user-crictl   1/1     Running   0          10s

~/k01$
```

Next, we'll open a shell into the pod's container:

```shell
~/k01$ kubectl exec -it priv-user-crictl -- sh

/ #
```


We are all set! We can now use `crictl` to connect to the containerd by passing the following arguments:

- `--runtime-endpoint` is the path to the containerd socket from the host filesystem mounted inside our container
- `pods` - crictl instruction to list all running pods


```shell
sh-4.2# crictl --runtime-endpoint="unix:///host/run/containerd/containerd.sock" pods

POD ID              CREATED             STATE               NAME                               NAMESPACE           ATTEMPT             RUNTIME
8059109da767b       4 minutes ago       Ready               root-user-crictl                   default             0                   (default)
9c71ddc705548       30 minutes ago      Ready               root-user                          default             0                   (default)
1b3728bfe668e       4 hours ago         Ready               coredns-7db6d8ff4d-pt9x9           kube-system         0                   (default)
54e56320af6ab       4 hours ago         Ready               coredns-7db6d8ff4d-26l84           kube-system         0                   (default)
85d2c2c0e1286       4 hours ago         Ready               cilium-66w47                       kube-system         0                   (default)
b77be1ea8d0c9       4 hours ago         Ready               cilium-operator-6df6cdb59b-sfjwv   kube-system         0                   (default)
0c9916d55859a       4 hours ago         Ready               kube-proxy-qqzdc                   kube-system         0                   (default)
b074d97420b93       4 hours ago         Ready               etcd-vagrant                       kube-system         0                   (default)
709a80aa952f4       4 hours ago         Ready               kube-scheduler-vagrant             kube-system         0                   (default)
ecf6e81b6e413       4 hours ago         Ready               kube-controller-manager-vagrant    kube-system         0                   (default)
558d3bea29780       4 hours ago         Ready               kube-apiserver-vagrant             kube-system         0                   (default)
sh-4.2#
```

From here, it is up to our imagination about what we can do because we are `root` and we have full control over the
entire host and its containers.

Let's exit from the pod shell and get back to the host:

```shell
sh-4.2# exit

~/k01$
```

# 2. OWASP K01 Prevention

The "How to Prevent" section of the OWASP K01 risk states:

> To prevent misconfigurations, they must first be detected in both runtime and code.

Let's fix our pod by making it more secure. We will use the static code analysis approach for this job to find the
issues in our pod definition ("in code" as mentioned in the risk text). Ideally, we would also use these tools in our
**CI/CD** pipeline to prevent insecure pod definitions from being committed to our version control systems and then
deployed.

A good idea is to combine the static code scanners with Kubernetes Admission Controllers as a second line of defense (at
"runtime" as mentioned in the OWASP text) to prevent insecure pods from being deployed if our linter(s) and static
analysis tools fail to detect a configuration issue (this subject is beyond the scope of this workshop).


## 2.1. OWASP K01 Prevention - Kube-score

The first tool that we'll review is called **kube-score**. It can scan Kubernetes manifests and provide recommendations
for improving security and resiliency based on kube-score's pre-defined [checks](https://github.com/zegl/kube-score/blob/master/README_CHECKS.md). Some of them include:

- Pods have resource limits and requests set
- Pods have the same requests as limits on resources set
- Container images use an explicit non-latest tag
- Ingresses targets a Service
- CronJobs has a configured deadline
- NetworkPolicies targets at least one Pod

To install kube-score, we have to download the archive, extract it, and move it to a directory in the PATH list:

```shell
~/k01$ wget -q https://github.com/zegl/kube-score/releases/download/v1.18.0/kube-score_1.18.0_linux_amd64.tar.gz
~/k01$ sudo tar -zxf kube-score_*_linux_amd64.tar.gz -C /usr/local/bin kube-score && rm kube-score_*_linux_amd64.tar.gz
~/k01$ kube-score version

kube-score version: 1.18.0, commit: 0fb5f668e153c22696aa75ec769b080c41b5dd3d, built: 2024-02-05T14:13:15Z

~/k01$
```

Let's run `kube-score` against our pod definition and see what it says:

```shell
~/k01$ kube-score score priv-pod.yaml

v1/Pod priv-pod                                                              💥
    path=/home/ubuntu/k01/priv-pod.yaml
    [CRITICAL] Container Ephemeral Storage Request and Limit
        · root-user -> Ephemeral Storage limit is not set
            Resource limits are recommended to avoid resource DDOS. Set
            resources.limits.ephemeral-storage
        · root-user -> Ephemeral Storage request is not set
            Resource requests are recommended to make sure the application can start and
            run without crashing. Set resource.requests.ephemeral-storage
    [CRITICAL] Pod NetworkPolicy
        · The pod does not have a matching NetworkPolicy
            Create a NetworkPolicy that targets this pod to control who/what can
            communicate with this pod. Note, this feature needs to be supported by the CNI
            implementation used in the Kubernetes cluster to have an effect.
    [CRITICAL] Container Image Tag
        · root-user -> Image with latest tag
            Using a fixed tag is recommended to avoid accidental upgrades
    [CRITICAL] Container Security Context User Group ID
        · root-user -> The container is running with a low user ID
            A userid above 10 000 is recommended to avoid conflicts with the host. Set
            securityContext.runAsUser to a value > 10000
        · root-user -> The container running with a low group ID
            A groupid above 10 000 is recommended to avoid conflicts with the host. Set
            securityContext.runAsGroup to a value > 10000
    [CRITICAL] Container Security Context Privileged
        · root-user -> The container is privileged
            Set securityContext.privileged to false. Privileged containers can access all
            devices on the host, and grants almost the same access as non-containerized
            processes on the host.
    [CRITICAL] Container Security Context ReadOnlyRootFilesystem
        · root-user -> The pod has a container with a writable root filesystem
            Set securityContext.readOnlyRootFilesystem to true
    [CRITICAL] Container Resources
        · root-user -> CPU limit is not set
            Resource limits are recommended to avoid resource DDOS. Set
            resources.limits.cpu
        · root-user -> Memory limit is not set
            Resource limits are recommended to avoid resource DDOS. Set
            resources.limits.memory
        · root-user -> CPU request is not set
            Resource requests are recommended to make sure that the application can start
            and run without crashing. Set resources.requests.cpu
        · root-user -> Memory request is not set
            Resource requests are recommended to make sure that the application can start
            and run without crashing. Set resources.requests.memory

~/k01$
```

Let's review the issues with the pod definition and how we can fix them:

- Set the `hostPID` field to false so that the Pod won't share the host's PID namespace. This one has not been reported by
  kube-score!
- Remove the `privileged` field
- Change the value of the `runAsUser` field in the `securityContext` so that the container will run as `non-root`
  user having user ID and group ID of `10001`.
- Add `readOnlyRootFilesystem: true` to make the container's filesystem read-only
- Pull an image by its FQIN (fully qualified image name) with a pinned version `docker.io/busybox:1.36.1` instead of
  using the latest tag.
- Set both resource requests and limits for CPU, memory, and ephemeral storage to mitigate potential host resource
  exhaustion due to an attack or problem with the containerized application.
- Set the `imagePullPolicy` to Always. This ensures that Kubernetes always pulls the image from the registry to make
  sure, it's always using the correct version.
- Remove the `hostPath` volume and set ephemeral storage ( or other volumes ) with a size limit. This ensures that your
  application has enough ephemeral storage to start and run without crashing.

Let's fix the issues by creating a new pod definition file called `safer-pod.yaml`:

```shell
~/k01$ nano safer-pod.yaml && cat $_
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: safer-pod
spec:
  volumes:
  - name: safer-volume
    emptyDir: {}
  hostPID: false
  containers:
  - name: safer-container
    image: docker.io/dojobits/crictl:v1.30.0
    imagePullPolicy: Always
    command: ["sleep", "3600"]
    volumeMounts:
    - name: safer-volume
      mountPath: /host
    securityContext:
      privileged: false
      runAsUser: 10001
      runAsGroup: 10001
      readOnlyRootFilesystem: true
    resources:
      limits:
        cpu: "1"
        memory: "1Gi"
        ephemeral-storage: "1Gi"
      requests:
        cpu: "500m"
        memory: "500Mi"
        ephemeral-storage: "500Mi"
```

```shell
~/k01$
```

Run `kube-score` again and see what it says after our changes.

```shell
~/k01$ kube-score score safer-pod.yaml

v1/Pod safer-pod                                                              💥
    [CRITICAL] Pod NetworkPolicy
        · The pod does not have a matching NetworkPolicy
            Create a NetworkPolicy that targets this pod to control who/what can communicate
            with this pod. Note, this feature needs to be supported by the CNI implementation
            used in the Kubernetes cluster to have an effect.

~/k01$
```

As we can see, all the critical issues are gone! The only one left is the `NetworkPolicy`, which is beyond the scope of
this workshop.

> Note: Creating a NetworkPolicy is part of the Challenge at the end.


## 2.2. OWASP K01 Prevention - KubeLinter

Let's try another static code analysis tool called **KubeLinter**. [KubeLinter](https://github.com/stackrox/kube-linter)
is a Go-based static analysis tool from StackRox:

```text
KubeLinter analyzes Kubernetes YAML files and Helm charts and checks them against a variety of best practices, with a
focus on production readiness and security.
```

To install KubeLinter, we have to download the archive, extract it, and move it to a directory in the PATH list:

```shell
~/k01$ wget -q https://github.com/stackrox/kube-linter/releases/download/v0.6.8/kube-linter-linux.tar.gz
~/k01$ sudo tar -zxf kube-linter-linux.tar.gz -C /usr/local/bin kube-linter && rm kube-linter-linux.tar.gz
~/k01$ kube-linter version

v0.6.8

~/k01$
```

The default KubeLinter checks can be summarized as follows:

- Service selectors should match one deployment labels
- Deployments that use the deprecated serviceAccount field instead of the serviceAccountName field
- Secrets used in an environment variable instead of as a file or secretKeyRef
- Deployments  selector doesn't match the pod template labels
- Deployments with multiple replicas that don't specify inter pod anti-affinity
- Objects that use deprecated API versions under extensions v1beta
- Containers not running with a read-only root filesystem
- Pods that reference a non-existing service account
- Deployments with containers that run in privileged mode
- Containers not set to runAsNonRoot
- Deployments that expose port 22, commonly reserved for SSH access
- Containers without CPU requests and limits
- Containers without memory requests and limits

Let's run `kube-linter` on our `priv` and `safer` pod definitions. First, we will run it against the `priv-pod.yaml` file:

```shell
~/k01$ kube-linter lint priv-pod.yaml
KubeLinter 0.6.8

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) object shares the host's process namespace (via hostPID=true). (check: host-pid, remediation: Ensure the host's process namespace is not shared.)

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) The container "root-user" is using an invalid container image, "busybox". Please use images that are not blocked by the `BlockList` criteria : [".*:(latest)$" "^[^:]*$" "(.*/[^:]+)$"] (check: latest-tag, remediation: Use a container image with a specific tag other than latest.)

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) container "root-user" does not have a read-only root file system (check: no-read-only-root-fs, remediation: Set readOnlyRootFilesystem to true in the container securityContext.)

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) container "root-user" is Privileged hence allows privilege escalation. (check: privilege-escalation-container, remediation: Ensure containers do not allow privilege escalation by setting allowPrivilegeEscalation=false, privileged=false and removing CAP_SYS_ADMIN capability. See https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ for more details.)

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) container "root-user" is privileged (check: privileged-container, remediation: Do not run your container as privileged unless it is required.)

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) container "root-user" is not set to runAsNonRoot (check: run-as-non-root, remediation: Set runAsUser to a non-zero number and runAsNonRoot to true in your pod or container securityContext. Refer to https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ for details.)

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) host system directory "/" is mounted on container "root-user" (check: sensitive-host-mounts, remediation: Ensure sensitive host system directories are not mounted in containers by removing those Volumes and VolumeMounts.)

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) container "root-user" has cpu request 0 (check: unset-cpu-requirements, remediation: Set CPU requests and limits for your container based on its requirements. Refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for details.)

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) container "root-user" has cpu limit 0 (check: unset-cpu-requirements, remediation: Set CPU requests and limits for your container based on its requirements. Refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for details.)

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) container "root-user" has memory request 0 (check: unset-memory-requirements, remediation: Set memory requests and limits for your container based on its requirements. Refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for details.)

/home/ubuntu/k01/priv-pod.yaml: (object: <no namespace>/root-user /v1, Kind=Pod) container "root-user" has memory limit 0 (check: unset-memory-requirements, remediation: Set memory requests and limits for your container based on its requirements. Refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for details.)

Error: found 11 lint errors

~/k01$
```

The output shows that `kube-linter` gives us many suggestions about issues and provides some remediation
steps. Let's check our `safer-pod.yaml` file.

```shell
~/k01$ kube-linter lint safer-pod.yaml

KubeLinter v0.6.8

No lint errors found!

~/k01$
```

KubeLinter doesn't complain about a missing network policy like kube-score did. Not all linting tools are created equal.

Deploy the `safer-pod.yaml` file and see if it works on our cluster:

```shell
~/k01$ kubectl apply -f safer-pod.yaml

pod/safer-pod created

~/k01$
```

Let's check if the pod is running.

```shell
~/k01$ kubectl get po

NAME               READY   STATUS    RESTARTS   AGE
priv-pod           1/1     Running   0          51m
priv-user-crictl   1/1     Running   0          36m
safer-pod          1/1     Running   0          2s
```

`exec` inside the pod and check if we are root:

```shell
~/k01$ kubectl exec -it safer-pod -- /bin/sh

~ $ id

uid=10001 gid=10001 groups=10001

~ $
```

As you can see, we are not root inside the container.

Check if we have access to the host's containerd socket. We will use the same command as we did before:

```shell
~ $ crictl --runtime-endpoint="unix:///host/run/containerd/containerd.sock" pods

FATA[0002] connect: connect endpoint 'unix:///host/run/containerd/containerd.sock', make sure you are running as root, and the endpoint has been started: context deadline exceeded

~ $
```

We don't have the `/host` volume mounted in the container, so we cannot access the host's containerd
socket. Also, to do that, we need the `HostPID` to be true. The `ps` command will output container-level processes.

```shell
~ $ ps
PID   USER     TIME  COMMAND
    1 10001     0:00 sleep 3600
    7 10001     0:00 /bin/sh
   14 10001     0:00 ps
~ $
```

Let's exit from the container:

```shell
~ $ exit
~/k01$
```


## 3. Conclusion

Maintaining robust security configurations across a sprawling Kubernetes environment can pose a considerable challenge.
Most of these configurations are often established in the manifest's `securityContext`. However, there's
also a range of other potential misconfigurations that may be found elsewhere. To prevent these misconfigurations,
detecting them both in real-time operation *and* within the code itself is crucial.

Consequently, we should enforce the following policies for our applications:

- Containerized applications should be executed using non-root users (if possible)
- Containers should be run in non-privileged mode
- We should ensure `AllowPrivilegeEscalation` is set to `False` to prevent child processes from obtaining higher
  privileges than their parent processes

Various tools, like the Open Policy Agent, can serve as a policy engine to identify these prevalent misconfigurations.
Additionally, the CIS Benchmark for Kubernetes can provide an initial reference point for identifying potential
misconfigurations.


## 4. CHALLENGE

Below is a faulty Kubernetes pod specification (`pod.yaml`) that contains several insecure and incorrect configurations.

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
to fix as many issues as you can. We've not discussed `NetworkPolicy`, so you can ignore that one, but we'll include it
in the solution for reference.


## 5. Clean up

Delete the pods we've' created:

```shell
~$ kubectl delete po/priv-pod po/priv-user-crictl po/safer-pod --now

pod "priv-user" deleted
pod "priv-user-crictl" deleted
pod "safer-pod" deleted

~$
```

## 6. You Did it!

Congratulations, You've Aced the Workshop!
