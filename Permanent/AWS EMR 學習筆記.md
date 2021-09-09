---
tags: AWS, EMR
---
# AWS EMR 學習筆記

[![hackmd-github-sync-badge](https://hackmd.io/jv2qIGcMTE-PnaglYFfL0g/badge)](https://hackmd.io/jv2qIGcMTE-PnaglYFfL0g)



[TOC]

## Amazon EMR 中的 Clusters 和 Nodes
Amazon EMR 提供一個叢集，其中包含多台 Amazon EC2 作為節點，這些節點共扮演三種角色並有不同的 node type，隨著不同的 node type 也會安裝不同的軟體：

- Master node: 主要用於協調資料分布和任務並且同時會監控其他節點的狀態。每一個叢集之中必要有一個 Master node，單一節點叢集 (single-node cluster) 即僅含 master node。
- Core node: 主要用於執行任務，並同時儲存資料於叢集中的 HDFS，多節點叢集 (Multi-node cluster) 需包含至少一個 core node。
- Task node（選用）: 僅用於執行任務，並不會將資料存於 HDFS。

![](https://i.imgur.com/thiqX0X.png)

## Amazon EMR 中的工作執行
Amazon EMR 可以透過多個方式定義要執行的工作 (works)：
 - 在建立叢集時於定義好 steps 提供需完成的工作，執行個體將會依照定義執行工作並在完成後終止。
 - 建立叢集後，透過 Amazon EMR Console, AWS CLI, Amazon EMR API 提交要執行的步驟，一份工作包含多個 steps，並且每一個 step 中包含多個 Hadoop Jobs
<!-- TO READ https://docs.aws.amazon.com/emr/latest/ManagementGuide/AddingStepstoaJobFlow.html -->
 - 建立叢集後，直接透過 SSH 連線至 master node 和其他 nodes，透過程式提供的介面執行任務


## Amazon EMR 中的資料處理
Amazon EMR 叢集提供兩種方式處理資料，其中包含直接提交 Hadoop Jobs 到執行個體安裝的應用程式和執行使用者給定的 steps：

- 直接提交 Hadoop Jobs 到安裝的程式：使用者僅需透過安全的連線連線至 master node，並可以透過已安裝好的程式介面進行操作。Master node 有一個可見的 DNS 讓使用者可以連線，Amazon EMR 預設一些 security group 規則給叢集中的節點，需注意的是預設並沒有提供 inbound SSH 存取，使用者需自行加入允許 SSH (TCP port 22) 的規則到 security group。

- 執行 steps：使用者可以提交一或多個有順序的 steps 到 Amazon EMR 叢集，執行過程包含以下過程

    1. 當提交後叢集開始執行 steps 時，所有的 step 狀態會被設定成 `PENDING`
    2. 開始執行第一個 step，其狀態會被修改為 `RUNNING`，其他 step 維持 `PENDING`
    3. 第一個 step 成功完成後，狀態會被修改為 `COMPLETED`
    4. 下一個 step 開始執行並將狀態修改為 `RUNNING`，成功完成後將被修改為 `COMPLETED`
    5. 反覆前述步驟直到所有 step 完成

![](https://i.imgur.com/GU83MxD.png)

若執行過程中任何 step 執行失敗，狀態會被修改為 `FAILED`，使用者可以決定是否要繼續執行下一個 step 或是終止 cluster，預設是將後續 step 狀態修改為 CANCELLED 並不執行。

![](https://i.imgur.com/WKorafX.png)

## Amazon EMR 的生命週期

Amazon EMR 叢集建立到終止包含下列的過程（如下圖）：
1. Amzon EMR 會根據使用者設定的規格提供 EC2 執行個體，所有的執行個體 Amazon EMR 會使用預設的 AMI 或是使用者自定的 Amazon Linux AMI。當執行此階段時，叢集狀態為 `STARTING`。
2. Amazon EMR 在每個執行個體上執行使用者給定的 `boostrap actions`，使用者可以在 `bootstrap actions` 階段安裝所需的應用程式並執行客製化設定，此階段叢集的狀態會修改為 `BOOTSTRAPPING`。
3. Amazon EMR 安裝使用者給定的應用程式如 Hive, Hadoop, Spark 等。
4. 在 `bootstrap actions` 成功執行完畢後並安裝完應用程式，叢集的狀態修改為 `RUNNING`，此時使用者可以連線至叢集，並且叢集也會在此時根據使用者給定的 steps 逐步執行，當所有 steps 完成後使用者可以提交附加的 steps。
5. 在所有 steps 執行完畢後，叢集狀態修改為 `WAITING`，假如叢集在最後一個 step 完成時的配置為 `auto-terminate`，叢集的狀態會進入 `TERMINATING` 並進入 `TERMINATED`。若設置為 `wait`，則會等待使用者手動終止叢集，接著叢集的狀態會進入 `TERMINATING` 並進入 `TERMINATED`。

若在上述步驟中出現錯誤，Amazon EMR 將會終止所有的執行個體，並且清除其中的資料，此時狀態會被設定為 `TERMINATED_WITH_ERRORS`。若啟動 `Termination Protection` 則使用者可以在發生錯誤後取回資料並取消 `Termination Protection` 讓 Amazon EMR 終止執行個體。

![](https://i.imgur.com/JbYS90c.png)


## Reference
- [Overview of Amazon EMR](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-overview.html)
- [Connect to the Cluster](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-connect-master-node.html)