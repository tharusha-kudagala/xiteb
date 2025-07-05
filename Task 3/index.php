<?php
$host = '34.10.65.134';        // Your DB public IP
$db   = 'wordpress';           // DB name
$user = 'wp_user';             // DB user
$pass = 'bDlBh3ItC2wHzEL';         // DB password

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    echo "❌ Connection failed: " . $conn->connect_error;
} else {
    echo "✅ Successfully connected to MySQL!";
}
