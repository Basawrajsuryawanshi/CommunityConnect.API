# Check Prerequisites for CommunityConnect Gateway
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Gateway Prerequisites Check" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Check 1: Redis
Write-Host "[1] Checking Redis..." -ForegroundColor Yellow
try {
	$redisTest = Test-NetConnection -ComputerName localhost -Port 6379 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

	if ($redisTest.TcpTestSucceeded) {
		Write-Host "    ✅ Redis is running on port 6379" -ForegroundColor Green
	} else {
		Write-Host "    ❌ Redis is NOT running on port 6379" -ForegroundColor Red
		Write-Host "    To start Redis:" -ForegroundColor Yellow
		Write-Host "    docker run -d --name redis-gateway -p 6379:6379 redis:latest`n" -ForegroundColor Gray
	}
} catch {
	Write-Host "    ❌ Could not test Redis connection" -ForegroundColor Red
}

# Check 2: Port 5000 availability
Write-Host "`n[2] Checking if port 5000 is available..." -ForegroundColor Yellow
$portTest = Test-NetConnection -ComputerName localhost -Port 5000 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

if ($portTest.TcpTestSucceeded) {
	Write-Host "    ⚠️  Port 5000 is already in use" -ForegroundColor Yellow
	$process = Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue | Select-Object -First 1
	if ($process) {
		Write-Host "    Process ID: $($process.OwningProcess)" -ForegroundColor Gray
		Write-Host "    To kill it: taskkill /PID $($process.OwningProcess) /F" -ForegroundColor Gray
	}
} else {
	Write-Host "    ✅ Port 5000 is available" -ForegroundColor Green
}

# Check 3: SEQ (optional)
Write-Host "`n[3] Checking SEQ (optional)..." -ForegroundColor Yellow
$seqTest = Test-NetConnection -ComputerName localhost -Port 5341 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

if ($seqTest.TcpTestSucceeded) {
	Write-Host "    ✅ SEQ is running on port 5341" -ForegroundColor Green
	Write-Host "    Dashboard: http://localhost:5341" -ForegroundColor Gray
} else {
	Write-Host "    ⚠️  SEQ is not running (optional)" -ForegroundColor Yellow
	Write-Host "    To start SEQ:" -ForegroundColor Yellow
	Write-Host "    docker run -d --name seq-gateway -p 5341:80 -e ACCEPT_EULA=Y datalust/seq:latest`n" -ForegroundColor Gray
}

# Check 4: Docker availability
Write-Host "`n[4] Checking Docker..." -ForegroundColor Yellow
try {
	$dockerVersion = docker --version 2>$null
	if ($dockerVersion) {
		Write-Host "    ✅ Docker is installed: $dockerVersion" -ForegroundColor Green

		# List Redis containers
		$redisContainers = docker ps -a --filter "name=redis" --format "{{.Names}} ({{.Status}})" 2>$null
		if ($redisContainers) {
			Write-Host "    Redis containers:" -ForegroundColor Gray
			$redisContainers | ForEach-Object {
				Write-Host "      - $_" -ForegroundColor Gray
			}
		}
	} else {
		Write-Host "    ⚠️  Docker not found in PATH" -ForegroundColor Yellow
	}
} catch {
	Write-Host "    ⚠️  Docker not available" -ForegroundColor Yellow
}

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$ready = $true

if (-not $redisTest.TcpTestSucceeded) {
	Write-Host "❌ Redis is required - Start it first!" -ForegroundColor Red
	$ready = $false
} else {
	Write-Host "✅ Redis is ready" -ForegroundColor Green
}

if ($portTest.TcpTestSucceeded) {
	Write-Host "⚠️  Port 5000 is occupied - May need to free it" -ForegroundColor Yellow
} else {
	Write-Host "✅ Port 5000 is available" -ForegroundColor Green
}

if ($ready) {
	Write-Host "`n🎉 Ready to start the gateway!" -ForegroundColor Green
	Write-Host "`nRun: dotnet run" -ForegroundColor Cyan
} else {
	Write-Host "`n⚠️  Fix the issues above before starting the gateway" -ForegroundColor Yellow
}

Write-Host ""
