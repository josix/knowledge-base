---
tags: bincentive, profyu
---
# EKS 管理筆記

> [TOC]


## TO READ
- https://developer.cisco.com/learning/tracks/containers/containers-mgmt/containers-deploy-to-k8s/step/2
- [Troubleshooting Kubernetes](https://cloud.gov/docs/ops/runbook/troubleshooting-kubernetes/)
- [How To Restart Kubernetes Pods](https://phoenixnap.com/kb/how-to-restart-kubernetes-pods)
- [Overview](https://kubernetes.io/docs/concepts/overview/)
- [Cointainers](https://kubernetes.io/docs/concepts/containers/)
- [Workloads](https://kubernetes.io/docs/concepts/workloads/)
- [Service](https://kubernetes.io/docs/concepts/services-networking/)
- [Tutorial](https://kubernetes.io/docs/tutorials/)
- [k8s the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- [A visual guide on troubleshooting Kubernetes deployments](https://learnk8s.io/troubleshooting-deployments)
## Docker
### Overlayfs
- https://jvns.ca/blog/2019/11/18/how-containers-work--overlayfs/
## K8S

### Pods
- Pods are the smallest deployable units of computing that you can create and manage in Kubernetes.
- A "logical host" that contains one or more application containers which are relatively tightly coupled. (like non-cloud)
- A set of Linux namespaces, cgroups, and potentially other facets of isolation
- Within a Pod's context, the individual applications may have further sub-isolations applied.
- like a group of Docker containers with shared namespaces and shared filesystem volumes.

#### Two types of pods
1. **Pods that only run a single container**: one-container-per-Pos: think pod as a wrapper around a single container;(Note. k8s manages Pods rather than containers directly)
2. **Pods that run multiple containers that need to work together**: A Pod can encapsulate multiple co-located containers that are tightly coupled and need to share resoures like networking and storage. (form a single cohesive unit of service).

    e.g. [Sidecar Pattern](https://tachingchen.com/tw/blog/desigining-distributed-systems-the-sidecar-pattern-concept/#%E9%82%8A%E8%BB%8A%E6%A8%A1%E5%BC%8F) (Application Container is responsible for core logic; Sidecar container is responsible for argumenting and improving the application)

##### How Pods Manage Multiple Containers
![](https://i.imgur.com/fAx9Evf.png)

### Stateful Sets

#### Stateful vs stateless
- Stateless: A process or application can be understood in isolation. No stored knowledge of or reference to past transactions. (e.g. vending machine)
- Stateless: Can be returned to again and again, like online banking or email. Performed with the context of previous transactions and the current may be affected by what happened during previous transactions. 
### Services

#### Ref. 
- [Stateful vs stateless](https://www.redhat.com/en/topics/cloud-native-apps/stateful-vs-stateless)

### Probe
### Volumes
- 
### PV && PVC
- 
### Ingress
- 
### Commands
```bash=
kubectl get svc (kubectl get services)
kubectl get ns (kubectl get namespaces)
kubectl get po (kubectl get pods)
kubectl get rs (kubectl get replicasets)
kubectl get deploy (kubectl get deployments)
kubectl get pv (kubectl get )
kubectl get pvc (kubectl get )
kubectl describe pods <pod-name> --namespace <ns>
kubectl logs <pod-name> --namespace <ns>
kubectl get pod my-pod -o yaml 
kubectl get pod my-pod -o wide
kubectl describe pv <pv>  -n <ns>
kubectl describe persistentvolumeclaims <pvc>  -n <ns>
```
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
#### Ref
- [k8s documentation](https://kubernetes.io/docs/concepts/)
- [k8s workshop](https://training.play-with-kubernetes.com/kubernetes-workshop/)

## traefik
(TBD)

## etcd
(TBD)

## Case Solving Record
### 重啟wordpress在sit的環境下
#### Problem: wordpress-prod pods 需要重建在 sit 環境下
1. 找到目前的 prod 環境下 wordpress 用的 volumes
    ![](https://i.imgur.com/vQd0paH.png)
2. 建立 snapshot 再從 snapshot 重建 volumn ([ref](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-creating-snapshot.html))
- wordpress-prod-mariadb-0 backup (snap-06f4b1a3ec398b7e6 -> vol-0cf25c1691a8efe11)
- wordpress-prod backup(snap-00a81e57da30d4ad5 -> vol-085750c78504bb0c5)
3. 新增 wordpress resource 和 helm chart 到 `eks_cluster_experiment_resources_stack` 並且 cdk synth && cdk deploy
```python=
        # wordpress-sit
        eks.KubernetesResource(
            self, 'wordpress-sit-pv-pvc',
            cluster=cluster,
            manifest=read_k8s_resource('eks_cluster/kubernetes_resources/wordpress-sit-pv-pvc.yaml')
        )

        eks.HelmChart(
            self, 'wordpress-sit',
            release='wordpress-sit',
            cluster=cluster,
            repository=bitnami_chart,
            chart='wordpress',
            version='9.5.4',
            namespace='sit',
            values={
                'wordpressPassword': ssm.wordpress_prod_wordpress_password,
                'ingress': {'enabled': True,
                    'hostname': 'wp.bincentive.com',
                    'annotations': {
                        'kubernetes.io/ingress.class': 'traefik-internal'
                    }
                },
                'persistence': {'existingClaim': 'wordpress-sit-pvc'},
                'mariadb': {
                    'db': {'password': ssm.wordpress_prod_db_password},
                    'rootUser': {'password': ssm.wordpress_rootuser_password}
                }
            }
        )
```
eks_cluster/kubernetes_resources/wordpress-sit-pv-pvc.yaml (這份執行時會無法 bind pv 和 pvc 需改成下方 claimRef 的版本，因還需查原因故留下)
```yaml=
apiVersion: v1
kind: PersistentVolume
metadata:
  name: wordpress-sit-pv
  labels:
    pvc-selector: wordpress-sit-pv
    failure-domain.beta.kubernetes.io/region: ap-northeast-2
    failure-domain.beta.kubernetes.io/zone: ap-northeast-2a
spec:
  accessModes:
  - ReadWriteOnce
  awsElasticBlockStore:
    fsType: ext4
    volumeID: aws://ap-northeast-2a/vol-085750c78504bb0c5
  capacity:
    storage: 10Gi
  storageClassName: gp2
  volumeMode: Filesystem
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: failure-domain.beta.kubernetes.io/zone
          operator: In
          values:
          - ap-northeast-2a
        - key: failure-domain.beta.kubernetes.io/region
          operator: In
          values:
          - ap-northeast-2
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wordpress-sit-pvc
  namespace: sit
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: gp2
  volumeMode: Filesystem
  selector:
    matchLabels:
      pvc-selector: "wordpress-sit-pv"

```
4. Attach snapshot 建立的 volumne 並複製內容到新的 volume 中 (In terminal) [Mount Ref](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html) [Attach Ref](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-attaching-volume.html)
![](https://i.imgur.com/xkVMma7.png)
![](https://i.imgur.com/Zz4r8lC.png)

```
[root@ip-172-31-32-239 vol-013798b1ea8ae5712]# lsblk
NAME          MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
nvme0n1       259:0    0  20G  0 disk
├─nvme0n1p1   259:1    0  20G  0 part /
└─nvme0n1p128 259:2    0   1M  0 part
nvme1n1       259:3    0   1G  0 disk /var/lib/kubelet/pods/4d0618bc-d977-4c25-99b1-853c3c1a0539/volumes/kubernetes.io~aws-ebs/pvc-a827716e-412e-4c75-a420-91c825368386
nvme2n1       259:4    0   8G  0 disk /var/lib/kubelet/pods/e06c87c2-9921-47b6-8ecc-d69e39bef85a/volumes/kubernetes.io~aws-ebs/jenkins-pv
nvme3n1       259:5    0   1G  0 disk /var/lib/kubelet/pods/a2a48b3f-c3f1-499f-beb4-a83a1545e808/volumes/kubernetes.io~aws-ebs/pvc-c6590685-c025-41f1-aeee-1cd69506514a
nvme4n1       259:6    0   1G  0 disk /var/lib/kubelet/pods/da6ca49d-4e2c-4a16-ad02-644f198f1a4e/volumes/kubernetes.io~aws-ebs/pvc-4af71d25-2021-4163-8526-f1197d96c7e1
nvme5n1       259:7    0   1G  0 disk /var/lib/kubelet/pods/164a2e5b-f824-40ff-a6f7-f50499faeb85/volumes/kubernetes.io~aws-ebs/pvc-100b55ec-1714-421d-9604-fa1118e5ec6b
nvme6n1       259:8    0   1G  0 disk /var/lib/kubelet/pods/3ade6548-7d8d-45f4-86bb-91dba4b61cce/volumes/kubernetes.io~aws-ebs/pvc-59555193-ec2d-43f0-83c5-89868b11f645
nvme7n1       259:9    0   8G  0 disk /var/lib/kubelet/pods/68f3c577-0db5-4061-8e1e-2364051f241b/volumes/kubernetes.io~aws-ebs/nexus-pv
nvme8n1       259:10   0  32G  0 disk /var/lib/kubelet/pods/13b2d707-af76-4946-bbc6-f0ef2fbb2349/volumes/kubernetes.io~aws-ebs/pvc-d8dfae72-9ee6-4184-b0f4-ca306a25b7ab
nvme9n1       259:11   0   1G  0 disk /var/lib/kubelet/pods/05a1c25d-ec4b-4319-9634-cae0eab54cd5/volumes/kubernetes.io~aws-ebs/pvc-6054415e-5bc6-40d1-b633-5e88f687244e
nvme10n1      259:12   0   1G  0 disk /var/lib/kubelet/pods/ed75746e-f0e1-4067-9656-b3da10724cf1/volumes/kubernetes.io~aws-ebs/pvc-ea826704-0ea9-45b6-a0bc-1e971e01b24c
nvme11n1      259:13   0  16G  0 disk /var/lib/kubelet/pods/7e035b13-419e-4c1e-b093-44475e7b2a08/volumes/kubernetes.io~aws-ebs/postgres-stg-pv
nvme12n1      259:14   0   1G  0 disk /var/lib/kubelet/pods/40fc0597-92b2-4252-808d-05ccb7c31113/volumes/kubernetes.io~aws-ebs/pvc-863598c6-fbfa-4cfb-a98b-f84ad0946a51
nvme13n1      259:15   0   8G  0 disk /var/lib/kubelet/pods/ab2acae2-6f72-4881-8e4b-369d50911599/volumes/kubernetes.io~aws-ebs/pvc-8b1076f3-fdfd-4698-ac0d-7281bdf87f7d
nvme14n1      259:16   0   8G  0 disk
[root@ip-172-31-32-239 vol-013798b1ea8ae5712]# df -hT /dev/xvdci
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/nvme13n1  ext4  7.8G  158M  7.6G   2% /var/lib/kubelet/plugins/kubernetes.io/aws-ebs/mounts/aws/ap-northeast-2c/vol-08790cd630ca8d5db
[root@ip-172-31-32-239 vol-013798b1ea8ae5712]# cd /var/lib/kubelet/plugins/kubernetes.io/aws-ebs/mounts/aws/ap-northeast-2c
[root@ip-172-31-32-239 ap-northeast-2c]# mkdir vol-0cf25c1691a8efe11
[root@ip-172-31-32-239 ap-northeast-2c]# mount /dev/sdg vol-0cf25c1691a8efe11
[root@ip-172-31-32-239 ap-northeast-2c]# ls -alth vol-0cf25c1691a8efe11/data -lath vol-08790cd630ca8d5db/data
vol-08790cd630ca8d5db/data:
total 121M
-rw-rw---- 1 docker 1001  12M Mar 16 17:26 ibtmp1
-rw-rw---- 1 docker 1001  48M Mar 16 17:26 ib_logfile0
drwxrwsr-x 6 docker 1001 4.0K Mar 16 17:26 .
-rw-rw---- 1 docker 1001  24K Mar 16 17:26 tc.log
-rw-rw---- 1 docker 1001  12M Mar 16 17:26 ibdata1
-rw-rw---- 1 docker 1001  16K Mar 16 17:26 aria_log.00000001
-rw-rw---- 1 docker 1001   52 Mar 16 17:26 aria_log_control
-rw-rw---- 1 docker 1001  976 Mar 16 17:26 ib_buffer_pool
-rw-rw-r-- 1 docker 1001   16 Mar 16 17:26 mysql_upgrade_info
drwx--S--- 2 docker 1001 4.0K Mar 16 17:26 performance_schema
drwxrws--- 2 docker 1001 4.0K Mar 16 17:26 mysql
drwxrws--- 2 docker 1001 4.0K Mar 16 08:25 bitnami_wordpress
-rw-rw---- 1 docker 1001    0 Mar 16 08:25 multi-master.info
drwxrws--- 2 docker 1001 4.0K Mar 16 08:25 test
-rw-rw---- 1 docker 1001  48M Mar 16 08:25 ib_logfile1
drwxrwsr-x 4 root   1001 4.0K Mar 16 08:25 ..

vol-0cf25c1691a8efe11/data:
total 121M
-rw-rw---- 1 docker 1001  12M Mar  7 07:19 ibtmp1
-rw-rw---- 1 docker 1001  48M Mar  7 07:19 ib_logfile0
drwxrwsr-x 6 docker 1001 4.0K Mar  7 07:19 .
-rw-rw---- 1 docker 1001  24K Mar  7 07:19 tc.log
-rw-rw---- 1 docker 1001  12M Mar  7 07:19 ibdata1
-rw-rw---- 1 docker 1001 4.8K Mar  7 07:19 ib_buffer_pool
-rw-rw---- 1 docker 1001  24K Mar  7 07:19 aria_log.00000001
-rw-rw---- 1 docker 1001   52 Mar  7 07:19 aria_log_control
-rw-rw-r-- 1 docker 1001   16 Mar  7 07:19 mysql_upgrade_info
drwx--S--- 2 docker 1001 4.0K Mar  7 07:19 performance_schema
drwxrws--- 2 docker 1001 4.0K Mar  7 07:19 mysql
-rw-rw---- 1 docker 1001  48M Feb  5 02:17 ib_logfile1
drwxrws--- 2 docker 1001 4.0K Sep 16  2020 bitnami_wordpress
-rw-rw---- 1 docker 1001    0 Sep 16  2020 multi-master.info
drwxrws--- 2 docker 1001 4.0K Sep 16  2020 test
drwxrwsr-x 4 root   1001 4.0K Sep 16  2020 ..
```




<!-- 
1. data -> snapshot -> export disk -> existing pvc
2. db -> (no arguments) -> chart built pv/pvc -> mounton spefic instancy -> snapshot -> export disk -> backup

3. pod without closing 
-->

#### Trouble Shooting
##### wordpress-sit pod 無法正常啟動 (PENDING)
1. 確認 EBS Volume 的 AZ 是可能有變動在 pv-pvc yaml 修改正確的 AZ
2. 改成正確的 AZ 後 pod status 為 PENDING, 原因如下
- `kubectl describe pods wordpress-sit-54898fd9b7-l69bf -n sit`
> selectedNode annotation value "" not set to scheduled node "ip-172-31-32-239.ap-northeast-2.compute.internal"

- `kubectl describe pv wordpress-sit-pv -n sit`

```
...

Events:         <none>
```
- `kubectl describe persistentvolumeclaims wordpress-sit-pvc  -n sit`
>  Failed to provision volume with StorageClass "gp2": claim.Spec.Selector is not supported for dynamic provisioning on AWS

===> PV and pvc is not bond

原 pv-pvc.yaml 檔案 pvc 無法 bind 到指定的 pv 上參考[文件](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reserving-a-persistentvolume)重新更新 yaml （移除 label selector加入 claimRef）如下： 
```yaml=
apiVersion: v1
kind: PersistentVolume
metadata:
  name: wordpress-sit-pv
  labels:
    pvc-selector: wordpress-sit-pv
    failure-domain.beta.kubernetes.io/region: ap-northeast-2
    failure-domain.beta.kubernetes.io/zone: ap-northeast-2a
spec:
  claimRef:
    name: wordpress-sit-pvc
    namespace: sit
  accessModes:
  - ReadWriteOnce
  awsElasticBlockStore:
    fsType: ext4
    volumeID: aws://ap-northeast-2a/vol-085750c78504bb0c5
  capacity:
    storage: 10Gi
  storageClassName: gp2
  volumeMode: Filesystem
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: failure-domain.beta.kubernetes.io/zone
          operator: In
          values:
          - ap-northeast-2a
        - key: failure-domain.beta.kubernetes.io/region
          operator: In
          values:
          - ap-northeast-2
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wordpress-sit-pvc
  namespace: sit
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: gp2
  volumeMode: Filesystem
  volumeName: wordpress-sit-pv

```

##### Related Issues
- https://stackoverflow.com/questions/61122011/k8s-dynamic-volume-provisioning-claim-spec-selector-is-not-supported-for-dynami
- https://github.com/kubernetes/kubernetes/issues/42503

##### wordpress-sit pod 已啟動 (RUNNING 但 Liveness, Readiness probe Failed)

1. 看 logs 顯示
```

Welcome to the Bitnami wordpress container
Subscribe to project updates by watching https://github.com/bitnami/bitnami-docker-wordpress
Submit issues and feature requests at https://github.com/bitnami/bitnami-docker-wordpress/issues

WARN  ==> You set the environment variable ALLOW_EMPTY_PASSWORD=yes. For safety reasons, do not use this flag in a production environment.
nami    INFO  Initializing apache
nami    INFO  apache successfully initialized
nami    INFO  Initializing mysql-client
nami    INFO  mysql-client successfully initialized
nami    INFO  Initializing wordpress
wordpre INFO  ==> Preparing Varnish environment
wordpre INFO  ==> Preparing Apache environment
wordpre INFO  ==> Preparing PHP environment
wordpre INFO  WordPress has been already initialized, restoring...
mysql-c INFO  Trying to connect to MySQL server
```
2. 需修改 wp-config.php 的 DB_HOST 從 wordpress-prod-mariadb:3306改為 wordpress-sit-mariadb:3306

#### Miscellaneous
- pv & pvc
- how to create snapshot and attach/detach Volume 
- mount device and checking mount path 
    - (df -hT /dev/xxxx, mount)



### etcd 無法成功重啟所有的 pods

#### Problem: Image 損毀，需要直接重啟並升級 chart version，並且無需搬遷資料需求 （重建於 stg）

#### Solution
1. 在 cdk 中找到 etcd pod 建立 resource 的腳本
2. 更新 HelmChart version 4.11.0 (App Version 3.4.13) -> 5.0.0, namespace 'prod' -> 'stg', values 中 statefulset replicaCount 4 -> 6
    至 https://artifacthub.io/ 找尋符合 app version 的 chart version 
    ```python
            eks.HelmChart(
            self, 'etcd-prod',
            release='etcd-prod',
            cluster=cluster,
            repository=bitnami_chart,
            chart='etcd',
            version='5.0.0',
            namespace='stg',
            values={
                'statefulset': {'replicaCount': 6},
                'persistence': {'size': '1Gi'},
                'auth': {'rbac': {'enabled': False}},
                'service': {'type': 'LoadBalancer',
                    'loadBalancerSourceRanges': ['172.24.207.0/24', '172.27.207.0/24'],
                    'annotations': {
                        'service.beta.kubernetes.io/aws-load-balancer-internal': 'true',
                        'service.beta.kubernetes.io/aws-load-balancer-type': 'nlb',
                        'external-dns.alpha.kubernetes.io/hostname': 'etcd-stg.bincentive.local'
                    }
                }
            }
        )
    ```

#### Trouble Shooting
- 新增的三個 node log 會有以下 error:
> etcdmain: error validating peerURLs {ClusterID:4b97b5f28b03c44d Members:[&{ID:4814890d37ab67a4 RaftAttributes:{PeerURLs:[http://etcd-stg-0.etcd-stg-headless.stg.svc.cluster.local:2380] IsLearner:false} Attributes:{Name:etcd-stg-0 ClientURLs:[http://etcd-stg-0.etcd-stg-headless.stg.svc.cluster.local:2379]}}] RemovedMemberIDs:[]}: member count is unequal

- Related Issue:
    - https://www.jianshu.com/p/587faa31eb9c
    - https://github.com/bitnami/charts/issues/4393

參照這個 [issue](https://github.com/bitnami/charts/issues/4393) 將 replicas 數量從 1 -> 2 -> 3 -> 6 逐步加機器上去沒意外可以成功跑起來，但在 etcd-stg-3 log 上出現 **(尚未解決)**
```
==> Bash debug is off
==> Detected data from previous deployments...
==> The data directory is already configured with the proper permissions
==> Updating member in existing cluster...
Error: bad member ID arg (strconv.ParseUint: parsing "": invalid syntax), expecting ID in Hex
```
> Related Issue: https://github.com/bitnami/charts/issues/3190
 

#### Miscellaneous
- [CDK Helm Charts API](https://docs.aws.amazon.com/cdk/api/latest/docs/aws-eks-readme.html#helm-charts)
    - Helm charts will be installed and updated using helm upgrade --install, where a few parameters are being passed down (such as repo, values, version, namespace, wait, timeout, etc). 
    - Helm charts are implemented as CloudFormation resources in CDK. This means that if the chart is deleted from your code (or the stack is deleted), the next cdk deploy will issue a helm uninstall command and the Helm chart will be deleted.
- [Helm Chart Concepts](https://helm.sh/docs/topics/charts/)
    - A packaging format to describe related set of kubernetes resourcs.
    - Created as files and could ve versioned archives to be deployed
- [aws-eks Doc](https://github.com/aws/aws-cdk/blob/master/packages/%40aws-cdk/aws-eks/README.md)


### 連不上 cluster
#### Saws eks --region <region-code> update-kubeconfig --name <cluster_name>