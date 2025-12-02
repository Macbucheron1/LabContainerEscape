<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Corporate File Sharing - SecureDocs™</title>
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
        .header .subtitle {
            color: #666;
            font-size: 0.9em;
        }
        .badge {
            display: inline-block;
            background: #4CAF50;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.8em;
            margin-top: 10px;
        }
        .upload-section {
            margin: 30px 0;
            padding: 30px;
            border: 2px dashed #ccc;
            border-radius: 10px;
            text-align: center;
            background: #f9f9f9;
        }
        .upload-section h2 {
            color: #555;
            margin-bottom: 20px;
            font-size: 1.3em;
        }
        .file-input-wrapper {
            position: relative;
            overflow: hidden;
            display: inline-block;
            margin-bottom: 20px;
        }
        .file-input-wrapper input[type=file] {
            position: absolute;
            left: -9999px;
        }
        .file-input-label {
            display: inline-block;
            padding: 12px 30px;
            background: #667eea;
            color: white;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s;
            font-weight: 500;
        }
        .file-input-label:hover {
            background: #5568d3;
        }
        .submit-btn {
            background: #764ba2;
            color: white;
            border: none;
            padding: 12px 40px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            font-weight: 500;
            transition: background 0.3s;
        }
        .submit-btn:hover {
            background: #653a91;
        }
        .file-name {
            margin: 10px 0;
            color: #666;
            font-style: italic;
        }
        .info-box {
            background: #e3f2fd;
            border-left: 4px solid #2196F3;
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
        }
        .info-box p {
            color: #1976D2;
            margin: 5px 0;
            font-size: 0.9em;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #999;
            font-size: 0.85em;
        }
        .version {
            background: #f5f5f5;
            padding: 10px;
            border-radius: 5px;
            margin-top: 20px;
            font-family: monospace;
            font-size: 0.8em;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔒 SecureDocs™</h1>
            <p class="subtitle">Enterprise File Sharing Platform</p>
            <span class="badge">✓ ISO 27001 Certified</span>
        </div>

        <div class="upload-section">
            <h2>📤 Upload Your Files</h2>
            <form action="upload.php" method="post" enctype="multipart/form-data" id="uploadForm">
                <div class="file-input-wrapper">
                    <label for="fileToUpload" class="file-input-label">
                        Choose File
                    </label>
                    <input type="file" name="fileToUpload" id="fileToUpload">
                </div>
                <div class="file-name" id="fileName">No file selected</div>
                <button type="submit" class="submit-btn" name="submit">Upload File</button>
            </form>
        </div>

        <div class="info-box">
            <p><strong>ℹ️ Supported formats:</strong></p>
            <p>Documents: PDF, DOC, DOCX, TXT</p>
            <p>Images: JPG, PNG, GIF</p>
            <p>Archives: ZIP, TAR, GZ</p>
            <p>Maximum file size: 10MB</p>
        </div>

        <div class="version">
            <strong>System Information:</strong><br>
            Version: 2.4.1-beta<br>
            Environment: Production<br>
            Container ID: <?php echo gethostname(); ?><br>
            PHP Version: <?php echo phpversion(); ?>
        </div>

        <div class="footer">
            <p>© 2024 SecureDocs™ - All Rights Reserved</p>
            <p>Powered by Apache & PHP</p>
        </div>
    </div>

    <script>
        document.getElementById('fileToUpload').addEventListener('change', function(e) {
            const fileName = e.target.files[0]?.name || 'No file selected';
            document.getElementById('fileName').textContent = fileName;
        });
    </script>
</body>
</html>
