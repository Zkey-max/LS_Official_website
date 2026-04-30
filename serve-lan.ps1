param(
  [int]$Port = 8080,
  [string]$Root = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

$rootPath = [System.IO.Path]::GetFullPath($Root)
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $Port)
$listener.Start()

$types = @{
  ".html" = "text/html; charset=utf-8"
  ".css"  = "text/css; charset=utf-8"
  ".js"   = "application/javascript; charset=utf-8"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".svg"  = "image/svg+xml"
  ".webp" = "image/webp"
  ".ico"  = "image/x-icon"
}

function Send-Response($stream, [int]$status, [string]$reason, [byte[]]$body, [string]$contentType) {
  $header = "HTTP/1.1 $status $reason`r`nContent-Length: $($body.Length)`r`nContent-Type: $contentType`r`nConnection: close`r`n`r`n"
  $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
  $stream.Write($headerBytes, 0, $headerBytes.Length)
  if ($body.Length -gt 0) {
    $stream.Write($body, 0, $body.Length)
  }
}

while ($true) {
  $client = $listener.AcceptTcpClient()
  try {
    $stream = $client.GetStream()
    $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 4096, $true)
    $line = $reader.ReadLine()
    if ([string]::IsNullOrWhiteSpace($line)) {
      $client.Close()
      continue
    }

    $parts = $line.Split(" ")
    $rawPath = if ($parts.Length -ge 2) { $parts[1] } else { "/" }
    $requestPath = [System.Uri]::UnescapeDataString(($rawPath -split "\?")[0])
    if ($requestPath -eq "/") {
      $requestPath = "/index.html"
    }

    $relative = $requestPath.TrimStart("/").Replace("/", [System.IO.Path]::DirectorySeparatorChar)
    $filePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($rootPath, $relative))

    if (-not $filePath.StartsWith($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
      $body = [System.Text.Encoding]::UTF8.GetBytes("Forbidden")
      Send-Response $stream 403 "Forbidden" $body "text/plain; charset=utf-8"
    } elseif (-not [System.IO.File]::Exists($filePath)) {
      $body = [System.Text.Encoding]::UTF8.GetBytes("Not Found")
      Send-Response $stream 404 "Not Found" $body "text/plain; charset=utf-8"
    } else {
      $ext = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
      $contentType = if ($types.ContainsKey($ext)) { $types[$ext] } else { "application/octet-stream" }
      $body = [System.IO.File]::ReadAllBytes($filePath)
      Send-Response $stream 200 "OK" $body $contentType
    }
  } catch {
    try {
      $body = [System.Text.Encoding]::UTF8.GetBytes("Server Error")
      Send-Response $stream 500 "Server Error" $body "text/plain; charset=utf-8"
    } catch {}
  } finally {
    $client.Close()
  }
}
