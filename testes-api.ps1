$base = "http://localhost:8080"
function Show($t){ Write-Host "PS> $t" -ForegroundColor Cyan }
Show 'Invoke-RestMethod "$base/"'; Invoke-RestMethod "$base/" | Format-List
Show 'Invoke-RestMethod "$base/health/live"'; Invoke-RestMethod "$base/health/live" | Format-List
Show 'Invoke-RestMethod "$base/health/ready"'; Invoke-RestMethod "$base/health/ready" | Format-List
Show 'Invoke-RestMethod "$base/produtos"   (lista vazia)'; (Invoke-RestMethod "$base/produtos") | ConvertTo-Json
Show '$json = @{ nome = "Caderno"; preco = 19.90 } | ConvertTo-Json'
$json = @{ nome = "Caderno"; preco = 19.90 } | ConvertTo-Json
Show '$criado = Invoke-RestMethod -Method Post -Uri "$base/produtos" -ContentType "application/json" -Body $json; $criado'
$criado = Invoke-RestMethod -Method Post -Uri "$base/produtos" -ContentType "application/json" -Body $json; $criado | Format-List
Show 'Invoke-RestMethod "$base/produtos/$($criado.id)"'; Invoke-RestMethod "$base/produtos/$($criado.id)" | Format-List
$novo = @{ nome = "Caderno universitario"; preco = 24.90 } | ConvertTo-Json
Show 'Invoke-RestMethod -Method Put -Uri "$base/produtos/$($criado.id)" -ContentType "application/json" -Body $novo'
Invoke-RestMethod -Method Put -Uri "$base/produtos/$($criado.id)" -ContentType "application/json" -Body $novo | Format-List
Show 'Invoke-RestMethod "$base/produtos"'; Invoke-RestMethod "$base/produtos" | Format-Table
Show 'Validacao: POST com nome vazio e preco negativo (esperado: 400)'
try { Invoke-RestMethod -Method Post -Uri "$base/produtos" -ContentType "application/json" -Body (@{nome="";preco=-1}|ConvertTo-Json) } catch { "HTTP " + [int]$_.Exception.Response.StatusCode }
