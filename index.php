<!DOCTYPE html>
<html>
<head>
    <title>Students Mess Info</title>
    <style>
        /* Increase font size to 20 pixels */
        pre {
            font-size: 20px;
        }
    </style>
</head>
<body>
    <pre>
        <?php
        $filePath = '/home/HAD/mess.txt';
        if (file_exists($filePath)) {
            $content = file_get_contents($filePath);
            echo $content;
        } else {
            echo 'File not found.';
        }
        ?>
    </pre>
</body>
</html>
