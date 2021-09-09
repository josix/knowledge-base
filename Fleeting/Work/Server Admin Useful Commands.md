---
tags: Note,
---
# Server Admin Useful Commands

- General:

    ```bash
    who;
    w;
    whoami;
    whois;
    getent; # get entries from NSS
    tty; # return user's terminal name
    ps -aux # show all processes
    last # displays a list of all users logged in (and out) -> /var/log/wtmp
    lastb # displays all the bad login attempts -> var/log/btmp
    lastlog # reports the most recent login of all users or of a given user -> /var/log/lastlog
    ```

- Server Info:
    - Check System info:

        ```bash
        lsb_release -a
        less /etc/os-release
        less /etc/lsb-release
        uname -a # print system information
        ```

    - Check Hardware Info:

        ```bash
        sudo dmidecode -t processor [-t memory] [-t cache] [-t slot] [-t system] [-t baseboard]
        # DMI (some say SMBIOS) table decoder
        sudo lshw -class memory [-class disk] [-class storage] [-class network]
        lsmod # Show the status of modules
        lsusb # List USB devices
        lspci # List all PCI devices
        sudo hdparm -I /dev/sda1 # get/set SATA/IDE device parameters
        smartctl -i /dev/sda
        ```

    - Check CPU Info:

        ```bash
        cat /proc/cpuinfo;
        lscpu
        ```

    - Check Memory Info:

        ```bash
        free -h
        sudo lshw -class memory
        ```

    - Check HD Info:

        ```bash
        lshw -class disk -storage
        sudo fdsik -l
        lsblk
        df -h
        du -d 1 -h
        less /etc/fstab # 磁碟mount資訊
        ```

    - Check GPU Info:

        ```bash
        lspci | grep -i vga
        lspci | grep -i nvidia
        nvidia-smi
        watch -n 10 nvidia-smi
        ```

- Server Shotdown:
    - Shotdown:

        ```bash
        shutdown [OPTION] TIME [MESSAGE]
        # Example:
        # Shotdown Immediately
        shutdown -h now
        shutdown -h +0
        shutdown -h 0
        # Shotdown at specific moment
        shutdown -h 12:51
        shutdown -h 12:51 &
        # Shotdown Simulation
        shutdown -k 18:30
        ```

        Ref: [https://blog.gtwang.org/linux/how-to-shutdown-linux/](https://blog.gtwang.org/linux/how-to-shutdown-linux/)

    - Restart:
        1. Restart Server: 

            ```bash
            sudo shutdown -r now;
            # or cmd: sudo reboot
            ```

        2. Restart NFS:

            ```bash
            sudo service rpcbind start
            sudo service ypbind restart
            ```

- Package Management:
    - List All Installed Packages:

        ```bash
        apt list --installed
        ```

    - System Update:

        ```bash
        sudo apt-get upgrade
        # then reboot
        ```

    - Remove Unused Packages:

        ```bash
        sudo apt-get autoremove
        ```

- Modify User/Group Info:

    Note:
    Add user to clipTitan
    1. login and modify clipTitan: vim /etc/security/access.conf
    2. add user into file (把帳號加在最後一行)

    - Add New User:

        ```bash
        sudo adduser [username]
        cd /var/yp; sudo make
        echo username >> /etc/ssh_users # At CLIP6 For Security
        # And add user to Match User section
        ```

    - Add Group:

        ```bash
        sudo addgroup [groupName]
        sudo cd /var/yp; sudo make
        ```

    - Add User to Group:

        ```bash
        usermod -aG [groupName] [userName]
        sudo cd /var/yp ; sudo make
        ```

    - Unlock User:

        ```bash
        sudo usermod -U [username]
        ```

    - Allow or Deny SSH Access to a Particular User or Group in Linux

        Disable Root user login:  
        **Root ssh access is considered a bad practice in terms of security.**
        Set `PermitRootLogin no` in `/etc/ssh/sshd_config`

        1. Edit **sshd_config** file:

            ```bash
            $ sudo vim /etc/ssh/sshd_config
            ```

        2. Add or edit the following line:

            ```bash
            AllowUsers [userName1] [userName2] ...
            DenyUsers [userName1] [userName2] ...

            # AllowUsers alex@140.119.164.64 alex@140.119.* alex@2001:288:5400:*
            ```

        3. To allow/deny an entire group, say for example root, add/edit the following line:

            ```bash
            AllowGroups [groupName1] [groupName2] ...
            DenyGroups [groupName1] [groupName2] ...
            ```

        4. Save and quit the SSH config file. Restart SSH service to take effect the changes.

            ```bash
            sudo systemctl restart sshd # centOS
            # or
            sudo service sshd restart # ubuntu
            ```

    - Lock / Unlock User:

        ```bash
        passwd -l [username] # Lock user
        passwd -u [username] # Unlock user
        ```

        Using `passwd -S [username]` to check if the user is locked (LK: Password locked, NP: No password PS: Password set)

    - Delete Account:

        ```bash
        userdel [username]
        userdel -r [username]
        # delete a user including user’s home directory and mail spool
        ```

        Default values are taken from the information provided in the `/etc/login.defs` file for RHEL (Red Hat) based distros. Debian and Ubuntu Linux based system use `/etc/deluser.conf` file:

        - Complete example to remove user account from Linux

            ```bash
            passwd -l [username]
            tar -zcvf /backup/account/deleted/v/[username].tar.gz /home/[username]/
            pgrep -u [username]
            crontab -r -u [username]
            lprm [username]
            userdel -r vivek
            ```

- Network:

    Find name server of given host:

    ```bash
    dig +short NS hostname
    nslookup -type=NS hostname
    ```

    ```bash
    ip [link] [route] [addr] 
    ifconfig (interface confing) # from /etc/network/interfaces
    mtr [host] (ping + traceroute)
    netstat
    tcpdump
    /etc/init.d/network [start, stop, restart]
    ```

    Refs:

    [https://blog.toright.com/posts/6293/ubuntu-18-04-透過-netplan-設定網路卡-ip.html](https://blog.toright.com/posts/6293/ubuntu-18-04-%E9%80%8F%E9%81%8E-netplan-%E8%A8%AD%E5%AE%9A%E7%B6%B2%E8%B7%AF%E5%8D%A1-ip.html)

    Files:

    - /etc/netplan (18.04)

    ```bash
    sudo netplan try # Recovery in 120s
    sudo netplan apply
    ```

    - /etc/network/interfaces (16.04)
- Quota:

    ```bash
    quotaoff
    mount -o remount /home
    quotacheck -avu
    quotaon -avu
    ```

    Refs:

    - [http://note.drx.tw/2008/03/disk-quota.html](http://note.drx.tw/2008/03/disk-quota.html)
- Firewall:

    ```bash
    sudo ufw status
    sudo ufw status verbose # 檢查incoming (連入) / outgoing (連出)的狀況
    sudo ufw status numbered
    sudo ufw disable
    sudo ufw default allow # 預設允許所有連入連線通過
    sudo ufw <allow/deny>
    # sudo ufw allow http / sudo ufw deny ssh
    sudo ufw delete <allow http/tcp or number>
    ufw allow / deny from / to ip
    # sudo ufw allow http from 140.119.55.171

    ```

- Service Management:

    If the service has an initialization (init) script installed, you can use the `service` command to start, stop, and check the status of the service. This command references a service by using its init script, which is stored in the `/etc/init.d`

    ```bash
    sudo service httpd status
    sudo service networking [start, stop, restart]
    sudo systemctl -l --type service --all # show all services
    ```

- Others:

    FIx Slow Login
    1. Edit Unit
    vim /lib/systemd/system/systemd-logind.service
    #IPAddressDeny=any
    or 
    mkdir /lib/systemd/system/systemd-logind.service.d
    vim /lib/systemd/system/systemd-logind.service.d/auth.conf
    [Service]
    IPAddressAllow=any
    2. Daemon Reload
    systemctl daemon-reload
    3. Force SSH client to use password authentication instead of public key
    ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no user@host

- Important Files and Directories:

    [Important Files and Directories](https://www.notion.so/2fdd4e42f6994059bd8518c6a7e14de2)