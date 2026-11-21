# Week 4 – Server Replication and Backups

## 1. Overview

This assignment implements two Linux servers with website backup and MariaDB replication.

- Server A: 128.214.252.10
- Server A private IP: 192.168.1.35
- Server B: 86.50.22.190
- Server B private IP: 192.168.1.65

Server B was created in CSC cPouta using a snapshot of Server A.

The Week 2 visitor counter runs on Server A. Server B displays the replicated counter using its local MariaDB database.

## 2. MariaDB Replication

MariaDB replication was configured between the two servers.

Server A is the primary database server:
- Private IP: 192.168.1.35
- Server ID: 1
- Binary logging enabled

Server B is the replica:
- Private IP: 192.168.1.65
- Server ID: 2
- Read-only mode enabled

Replication uses a dedicated database account named `replicator`.

Replication status was checked with:

```bash
sudo mariadb -e "SHOW SLAVE STATUS\G"
```

The verified results were:

- Slave_IO_Running: Yes
- Slave_SQL_Running: Yes
- Seconds_Behind_Master: 0

## 3. Visitor Counter

The visitor counter application runs on Server A.

When the Week 2 page is opened on Server A, the counter increases by one. The database change is replicated to Server B.

The database is named `visitor_db`, and the counter is stored in the `visits` table.

Server A application database user:
- `viikko2_app`
- Localhost access
- SELECT, INSERT and UPDATE permissions

Server B uses a separate database account:
- `week4_reader`
- Localhost access
- SELECT permission only on `visitor_db`

The Week 4 page on Server B reads the counter from its local database. It does not modify the counter.

Links:
- [Server A – Week 2](http://128.214.252.10/viikko2/)
- [Server B – Week 4](http://86.50.22.190/viikko4/)

## 4. Storage, Users and Permissions

The Linux user `ubuntu` is used for administration and running the scheduled website backup.

The backup script is stored at:

`/usr/local/bin/backup-website.sh`

The script is owned by `root` and has executable permissions (755).

The SSH key used for transferring backups from Server A to Server B is stored in:

`/home/ubuntu/.ssh/backup_to_b`

The private key is restricted to its owner.

On Server B, website backups are stored in:

`/var/backups/website/`

The backup directory is owned by `ubuntu` and has permissions 700. Backup archives are owned by `ubuntu` and have permissions 600.

Database passwords are stored outside the public website directory in protected configuration files.

On Server A, the application database credentials are stored in `/etc/viikko2.env`.

On Server B, the read-only database credentials are stored in `/etc/viikko4-db.php`. This file is owned by `root`, belongs to the `www-data` group and has permissions 640.

The PHP page uses the `week4_reader` database account, which only has SELECT permission.

## 5. Automated Website Backups

Server A backs up `/var/www/html` to Server B.

The backup script:
1. Creates a timestamped compressed archive.
2. Transfers the archive to Server B using SSH and rsync.
3. Stores the archive in `/var/backups/website/` on Server B.
4. Keeps the seven most recent backups.
5. Writes progress and errors to a log file.

The backup script is:

`/usr/local/bin/backup-website.sh`

## 6. Cron Scheduling

The backup is scheduled to run automatically once every hour on Server A.

The cron entry is:

```cron
0 * * * * /usr/local/bin/backup-website.sh >> /var/log/website-backup-cron.log 2>&1
```

The cron service is enabled and running.

Two consecutive automatic backup runs were verified successfully on November 21, 2026, at 19:00 and 20:00.

Timestamped backup archives were found on Server B.

## 7. Restoration Test

A backup archive was extracted into a temporary test directory on Server B.

The restored files were checked using SHA-256 checksums:

```bash
sha256sum -c /tmp/website-source.sha256
```

The following files passed the checksum verification:

- html/index.html: OK
- html/index.nginx-debian.html: OK
- html/viikko3/index.html: OK

The restoration test was successful.

## 8. Testing

### MariaDB Replication Test

Passed.

The visitor counter on Server A was initially 102. After opening the Week 2 page once, the counter increased to 103.

The database on Server B also showed the value 103.

Replication status showed:

- Slave_IO_Running: Yes
- Slave_SQL_Running: Yes
- Seconds_Behind_Master: 0

### Read-only Counter Test

Passed.

The Week 4 page on Server B reads the counter from the local replicated database. It does not increase the counter.

The database account used by the page has SELECT permission only.

### Automatic Backup Test

Passed.

Two consecutive automatic hourly backups completed successfully. The timestamped archives were visible in the backup directory on Server B.

### Restoration Test

Passed.

The restored website files passed SHA-256 checksum verification.

### Reboot Test

Passed.

Both servers were rebooted.

After reboot:
- Nginx was running.
- MariaDB was running.
- PHP-FPM was running on Server B.
- The Week 2 application was running on Server A.
- Cron was running on Server A.
- The visitor counter was still available.
- MariaDB replication was running.
- Automatic backups continued after reboot.

## 9. Conclusion

The two-server environment was successfully configured.

Server A hosts the visitor counter application and sends database changes to Server B. Server B displays the replicated counter without modifying it.

Website files are backed up automatically from Server A to Server B every hour. Backup restoration, replication and reboot tests were successful.

## 10. GitHub Repository

The source code and project documentation are available here:

[Linux Administration – GitHub Repository](https://github.com/xdHaukkax/Linux-Administration)
