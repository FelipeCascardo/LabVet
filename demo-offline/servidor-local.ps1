param([int]$Port = 4174)

$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath($PSScriptRoot)
$rootPrefix = $root.TrimEnd('\') + '\'
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://127.0.0.1:$Port/")

$mime = @{
  '.css' = 'text/css; charset=utf-8'
  '.html' = 'text/html; charset=utf-8'
  '.js' = 'text/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
}

try {
  $listener.Start()
  Write-Host "LabVet Demonstracao esta aberta em http://127.0.0.1:$Port/."
  Write-Host 'Mantenha esta janela aberta durante a demonstracao. Para encerrar, pressione Ctrl+C.'

  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $relativePath = [uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))
    if ([string]::IsNullOrWhiteSpace($relativePath)) { $relativePath = 'index.html' }
    $filePath = [System.IO.Path]::GetFullPath((Join-Path $root $relativePath))

    if (-not $filePath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
      $context.Response.StatusCode = 404
      $context.Response.Close()
      continue
    }

    $extension = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
    $context.Response.ContentType = if ($mime.ContainsKey($extension)) { $mime[$extension] } else { 'application/octet-stream' }
    $content = [System.IO.File]::ReadAllBytes($filePath)
    $context.Response.ContentLength64 = $content.Length
    $context.Response.OutputStream.Write($content, 0, $content.Length)
    $context.Response.Close()
  }
} finally {
  if ($listener.IsListening) { $listener.Stop() }
  $listener.Close()
}
