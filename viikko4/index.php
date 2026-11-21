
<?php
$config = require '/etc/viikko4-db.php';

$host = $config['host'];
$dbname = $config['database'];
$username = $config['username'];
$password = $config['password'];
try {
    $pdo = new PDO(
        "mysql:host=$host;dbname=$dbname;charset=utf8mb4",
        $username,
        $password,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]
    );

    $stmt = $pdo->query("SELECT count FROM visits WHERE id = 1");
    $result = $stmt->fetch();

    $visits = $result ? $result["count"] : 0;
    $status = "Connected";

} catch (PDOException $e) {
    $visits = "Unavailable";
    $status = "Database connection failed";
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Week 4 - Database Replication</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #edf2f7;
            color: #243247;
        }
        header {
            background: #17365d;
            color: white;
            text-align: center;
            padding: 45px 20px;
        }
        main {
            max-width: 850px;
            margin: 35px auto;
            padding: 20px;
        }
        .card {
            background: white;
            padding: 25px;
            margin-bottom: 20px;
            border-radius: 12px;
            box-shadow: 0 3px 12px #00000012;
        }
        h2 {
            color: #1769aa;
        }
        .counter {
            font-size: 48px;
            font-weight: bold;
            color: #1769aa;
            text-align: center;
        }
        .status {
            color: #16803c;
            font-weight: bold;
        }
        footer {
            text-align: center;
            padding: 25px;
        }
    </style>
</head>
<body>
<header>
    <h1>Week 4 - Database Replication</h1>
    <p>CSC Pouta | Ubuntu | Nginx | MariaDB</p>
</header>

<main>
    <section class="card">
        <h2>Server B - Replicated Visitor Counter</h2>
        <div class="counter">
            <?= htmlspecialchars((string)$visits, ENT_QUOTES, 'UTF-8') ?>
        </div>
        <p style="text-align:center">
            Total page visits replicated from Server A
        </p>
    </section>

    <section class="card">
        <h2>Replication Information</h2>
        <p>Server A: 192.168.1.35</p>
        <p>Server B: 192.168.1.65</p>
        <p>Database: visitor_db</p>
        <p>Database status: <span class="status"><?= htmlspecialchars($status) ?></span></p>
    </section>

    <section class="card">
        <h2>Read-only Database Access</h2>
        <p>
            This page reads the visitor counter from the local
            MariaDB replica on Server B.
        </p>
        <p>
            The database account has SELECT permission only.
            It cannot increase or modify the visitor counter.
        </p>
        <p>
            The counter is updated on Server A and replicated
            automatically to Server B.
        </p>
<p>
    GitHub Repository:
    <a href="https://github.com/xdHaukkax/Linux-Administration"
       target="_blank">
        Linux Administration – GitHub
    </a>
</p>
<p>
	Server A
        <a href="http://128.214.252.10/viikko2/" target="_blank">
            Week 2
        </a>
    </p>
    </section>
</main>

    <footer>
    <p>Week 4 Cloud Computing Project | CSC Pouta</p>
</footer>
</body>
</html>
