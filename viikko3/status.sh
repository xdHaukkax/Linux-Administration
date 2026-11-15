
#!/bin/bash

OUTPUT="/var/www/html/viikko3/index.html"

DATE_TIME=$(date '+%Y-%m-%d %H:%M:%S')
TIMEZONE=$(date '+%Z %z')
UPTIME=$(uptime -p)
DISK_USAGE=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')
MEMORY=$(free -h | awk '/Mem:/ {print $2}')
AVAILABLE_MEMORY=$(free -h | awk '/Mem:/ {print $7}')

generate_report() {
    if [ "$DISK_USAGE" -lt 80 ]; then
        DISK_STATUS="OK"
    else
        DISK_STATUS="WARNING"
    fi

    mkdir -p /var/www/html/viikko3

    cat > "$OUTPUT" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Week 3 - Server Status Report</title>
<style>
body {font-family: Arial; background:#edf2f7; color:#243247; margin:0;}
header {background:#243b55; color:white; padding:30px; text-align:center;}
main {max-width:850px; margin:30px auto; padding:20px;}
section {background:white; padding:20px; margin-bottom:20px; border-radius:10px;}
a {color:#1769aa;}
</style>
</head>
<body>
<header>
<h1>Week 3 - Server Status Report</h1>
<p>Bash scripting and Linux server monitoring</p>
</header>
<main>
<section>
<h2>Server Status</h2>
<p><b>Date and time:</b> $DATE_TIME</p>
<p><b>Timezone:</b> $TIMEZONE</p>
<p><b>Uptime:</b> $UPTIME</p>
<p><b>Root disk usage:</b> $DISK_USAGE%</p>
<p><b>Disk status:</b> $DISK_STATUS</p>
<p><b>Total RAM:</b> $MEMORY</p>
<p><b>Available RAM:</b> $AVAILABLE_MEMORY</p>
</section>
<section>
<h2>How the Script Works</h2>
<p>The Bash script collects server information using Linux commands.</p>
<p>It uses variables, command substitution, a pipe, an if statement and a function.</p>
<p>The disk status is OK below 80% and WARNING at 80% or above.</p>
</section>
<section>
<h2>Testing and Results</h2>
<p>Disk tests: 50% = OK, 80% = WARNING, 90% = WARNING.</p>
<p>Automatic updates: every minute using cron.</p>
<p>Server reboot test: Passed. The website and automatic updates continued after reboot.</p>
</section>
<section>
<h2>Linux Commands Used</h2>
<p>date, uptime, df, awk, free, mkdir, cat and crontab.</p>
</section>
<section>
<h2>Navigation</h2>
<p><a href="/viikko1/">Week 1</a> |
<a href="/viikko2/">Week 2</a> |
<a href="/viikko3/">Week 3</a></p>
</section>
</main>
</body>
</html>
EOF
}

generate_report
