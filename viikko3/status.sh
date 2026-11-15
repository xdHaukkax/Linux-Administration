
#!/bin/bash

OUTPUT="/var/www/html/viikko3/index.html"
TEMP_FILE=$(mktemp /var/www/html/viikko3/report.XXXXXX)

GENERATED_AT=$(date '+%Y-%m-%d %H:%M:%S %Z %z')
UPTIME_TEXT=$(uptime -p)
DISK_PERCENT=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')
DISK_USAGE="${DISK_PERCENT}%"

MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_AVAILABLE=$(free -m | awk '/Mem:/ {print $7}')

GITHUB_URL="https://github.com/xdHaukkax/Linux-Administration"

generate_report() {
    if [ "$DISK_PERCENT" -lt 80 ]; then
        DISK_STATUS="OK"
    else
        DISK_STATUS="WARNING"
    fi

    cat > "$TEMP_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Week 3 - Server Status Report</title>
<style>
body {
    font-family: Arial, sans-serif;
    max-width: 900px;
    margin: 40px auto;
    padding: 0 20px;
    line-height: 1.6;
    background: #edf2f7;
    color: #243247;
}
h1, h2 { color: #173b65; }
header {
    background: #243b55;
    color: white;
    padding: 25px;
    border-radius: 12px;
}
header h1 { color: white; }
section {
    margin: 24px 0;
    padding: 24px;
    background: white;
    border-radius: 12px;
}
table {
    border-collapse: collapse;
    width: 100%;
}
th, td {
    border: 1px solid #cbd5e1;
    padding: 12px;
    text-align: left;
}
th { background: #dbeafe; }
code {
    background: #e2e8f0;
    padding: 2px 5px;
    border-radius: 4px;
}
a { color: #1746a2; }
.note { color: #475569; }
</style>
</head>
<body>

<header>
<h1>Server Status Report</h1>
<p>Week 3: Linux command line and Bash scripting</p>
<p>This page monitors my Ubuntu server automatically.</p>
</header>

<section>
<h2>Current server status</h2>
<table>
<tr><th>Information</th><th>Value</th></tr>
<tr><td>Report generated</td><td>$GENERATED_AT</td></tr>
<tr><td>Server uptime</td><td>$UPTIME_TEXT</td></tr>
<tr><td>Root filesystem disk usage</td><td>$DISK_USAGE</td></tr>
<tr><td>Disk space status</td><td><strong>$DISK_STATUS</strong></td></tr>
<tr><td>Total RAM</td><td>$MEM_TOTAL MiB</td></tr>
<tr><td>Available RAM</td><td>$MEM_AVAILABLE MiB</td></tr>
</table>
<p>Disk status is OK below 80% usage and WARNING at 80% or above.</p>
<p class="note">The report is automatically updated once per minute.</p>
</section>

<section>
<h2>Commands used</h2>
<ul>
<li><code>date</code>: displays the date, time and time zone.</li>
<li><code>uptime -p</code>: displays server uptime.</li>
<li><code>df -P / | awk 'NR==2 {print $5}'</code>: uses a pipe to extract root filesystem disk usage.</li>
<li><code>free -m</code>: displays memory information in MiB.</li>
</ul>
</section>

<section>
<h2>How the script works</h2>
<p>The script collects server information and stores the results in Bash variables using command substitution with <code>$()</code>.</p>
<p>The <code>generate_report</code> function creates the HTML report. An if statement checks disk usage: below 80% is OK, while 80% or above is WARNING.</p>
<p>The script first writes a temporary HTML file and then moves it into place as index.html. This prevents visitors from seeing a partially written report.</p>
</section>

<section>
<h2>Scheduling</h2>
<p>I used cron to run the Bash script once every minute.</p>
<p>The root crontab contains:</p>
<code>* * * * * /home/ubuntu/viikko3/status.sh</code>
<p>Cron was enabled with <code>sudo systemctl enable --now cron</code>. The schedule continued working after the server reboot.</p>
</section>

<section>
<h2>Test results</h2>
<h3>Syntax check and manual execution</h3>
<p>The script was checked with <code>bash -n</code> and executed manually on the Ubuntu server.</p>

<h3>Disk space status tests</h3>
<table>
<tr><th>Test input</th><th>Expected status</th><th>Actual status</th></tr>
<tr><td>50%</td><td>OK</td><td>OK - Passed</td></tr>
<tr><td>80%</td><td>WARNING</td><td>WARNING - Passed</td></tr>
<tr><td>90%</td><td>WARNING</td><td>WARNING - Passed</td></tr>
</table>

<h3>Automatic updates</h3>
<p>Passed. The report generation time changed after waiting and reloading the page.</p>

<h3>Reboot test</h3>
<p>Passed. The Week 2 website and Week 3 report were accessible after reboot. Cron continued updating the report.</p>
</section>

<section>
<h2>A problem solved or a lesson learned</h2>
<p>I learned how to use Bash variables, command substitution, pipes, functions and if statements to collect server information and generate an HTML report. I also learned how to schedule recurring tasks with cron and verify that they continue after a reboot.</p>
</section>

<section>
<h2>Navigation</h2>
<p><a href="/viikko1/">Week 1</a> |
<a href="/viikko2/">Week 2</a> |
<a href="/viikko3/">Week 3</a></p>
</section>

<footer>
<p><a href="$GITHUB_URL">View the source code on GitHub</a></p>
</footer>

</body>
</html>
EOF

mv "$TEMP_FILE" "$OUTPUT"
chmod 644 "$OUTPUT"
}

generate_report
