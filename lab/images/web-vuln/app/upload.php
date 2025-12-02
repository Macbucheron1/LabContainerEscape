<?php
$upload_dir = "/var/www/html/uploads/";
$max_file_size = 10 * 1024 * 1024; // 10MB

if (!file_exists($upload_dir)) {
    mkdir($upload_dir, 0777, true);
}

?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Result - SecureDocs™</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 600px;
            width: 100%;
            padding: 40px;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            color: #333;
            font-size: 2em;
            margin-bottom: 10px;
        }
        .success {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .error {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .info {
            background: #e3f2fd;
            border-left: 4px solid #2196F3;
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
        }
        .btn {
            display: inline-block;
            padding: 12px 30px;
            background: #667eea;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 20px;
            transition: background 0.3s;
        }
        .btn:hover {
            background: #5568d3;
        }
        .file-details {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 5px;
            margin: 15px 0;
            font-family: monospace;
            font-size: 0.9em;
        }
        .file-details div {
            margin: 8px 0;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #999;
            font-size: 0.85em;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔒 SecureDocs™</h1>
            <p>Upload Result</p>
        </div>

<?php
if (isset($_POST["submit"])) {
    
    if (!isset($_FILES["fileToUpload"]) || $_FILES["fileToUpload"]["error"] == UPLOAD_ERR_NO_FILE) {
        echo '<div class="error">';
        echo '<h3>❌ Error</h3>';
        echo '<p>No file was selected. Please choose a file to upload.</p>';
        echo '</div>';
        echo '<a href="index.php" class="btn">← Back to Upload</a>';
        echo '</div></body></html>';
        exit;
    }

    $file = $_FILES["fileToUpload"];
    $original_filename = basename($file["name"]);
    $file_size = $file["size"];
    $file_tmp = $file["tmp_name"];
    $file_type = $file["type"];
        
    if ($file_size > $max_file_size) {
        echo '<div class="error">';
        echo '<h3>❌ File Too Large</h3>';
        echo '<p>The file size exceeds the maximum limit of 10MB.</p>';
        echo '<p>Your file size: ' . round($file_size / 1024 / 1024, 2) . ' MB</p>';
        echo '</div>';
        echo '<a href="index.php" class="btn">← Back to Upload</a>';
        echo '</div></body></html>';
        exit;
    }
    
    $timestamp = date("Y-m-d_H-i-s");
    $target_file = $upload_dir . $timestamp . "_" . $original_filename;
    
    if (move_uploaded_file($file_tmp, $target_file)) {
        echo '<div class="success">';
        echo '<h3>✅ Upload Successful!</h3>';
        echo '<p>Your file has been uploaded successfully.</p>';
        echo '</div>';
        
        echo '<div class="file-details">';
        echo '<strong>File Information:</strong><br>';
        echo '<div>📄 Original Name: ' . htmlspecialchars($original_filename) . '</div>';
        echo '<div>💾 Saved As: ' . basename($target_file) . '</div>';
        echo '<div>📊 Size: ' . round($file_size / 1024, 2) . ' KB</div>';
        echo '<div>🔗 Type: ' . htmlspecialchars($file_type) . '</div>';
        echo '<div>📅 Upload Time: ' . $timestamp . '</div>';
        echo '</div>';
        
        echo '<div class="info">';
        echo '<p><strong>ℹ️ Access your file:</strong></p>';
        echo '<p>Your file is now available at:</p>';
        echo '<p><code>uploads/' . basename($target_file) . '</code></p>';
        echo '</div>';
        
        echo '<!-- DEBUG: File uploaded to ' . $target_file . ' -->';
        echo '<!-- Tip: PHP files can be executed if uploaded... -->';
        
    } else {
        echo '<div class="error">';
        echo '<h3>❌ Upload Failed</h3>';
        echo '<p>An error occurred while uploading your file.</p>';
        echo '<p>Please try again or contact support.</p>';
        echo '</div>';
    }
    
    echo '<a href="index.php" class="btn">← Upload Another File</a>';
    
} else {
    echo '<div class="error">';
    echo '<h3>⚠️ Invalid Access</h3>';
    echo '<p>Please use the upload form to submit files.</p>';
    echo '</div>';
    echo '<a href="index.php" class="btn">← Go to Upload Form</a>';
}
?>

        <div class="footer">
            <p>© 2024 SecureDocs™ - All Rights Reserved</p>
        </div>
    </div>
</body>
</html>
