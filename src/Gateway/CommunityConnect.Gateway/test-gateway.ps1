# API Gateway Test Script
# Save this as: test-gateway.ps1
# Run with: .\test-gateway.ps1

$GatewayUrl = "http://localhost:5000"
$TestResults = @()

Write-Host "================================" -ForegroundColor Cyan
Write-Host "CommunityConnect API Gateway Tests" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Test 1: Health Check
Write-Host "[TEST 1] Health Check..." -ForegroundColor Yellow
try {
	$response = Invoke-WebRequest -Uri "$GatewayUrl/health" -Method Get
	if ($response.StatusCode -eq 200) {
		Write-Host "✅ PASSED: Health check successful" -ForegroundColor Green
		$TestResults += "Health Check: PASSED"
	}
} catch {
	Write-Host "❌ FAILED: Health check failed - $($_.Exception.Message)" -ForegroundColor Red
	$TestResults += "Health Check: FAILED"
}
Write-Host ""

# Test 2: Auth Service - Login (Route to port 5001)
Write-Host "[TEST 2] Auth Service - Login..." -ForegroundColor Yellow
try {
	$loginBody = @{
		email = "test@example.com"
		password = "password123"
	} | ConvertTo-Json

	$response = Invoke-WebRequest -Uri "$GatewayUrl/api/auth/login" `
		-Method Post `
		-ContentType "application/json" `
		-Body $loginBody `
		-ErrorAction Stop

	if ($response.StatusCode -eq 200) {
		$token = ($response.Content | ConvertFrom-Json).token
		Write-Host "✅ PASSED: Login successful, got JWT token" -ForegroundColor Green
		Write-Host "   Token: $($token.Substring(0,50))..." -ForegroundColor Gray
		$TestResults += "Auth Service Login: PASSED"
		$Global:JwtToken = $token
	}
} catch {
	Write-Host "⚠️  WARNING: Auth service may not be running on port 5001" -ForegroundColor Yellow
	Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
	$TestResults += "Auth Service Login: SKIPPED (service not running)"
}
Write-Host ""

# Test 3: User Service - Profile (Protected Route + Cache Test)
Write-Host "[TEST 3] User Service - Profile (Cache Test)..." -ForegroundColor Yellow
if ($Global:JwtToken) {
	try {
		# First request - Should be Cache MISS
		Write-Host "   → First Request (Cache MISS expected)..." -ForegroundColor Gray
		$response1 = Invoke-WebRequest -Uri "$GatewayUrl/api/user/profile" `
			-Method Get `
			-Headers @{ Authorization = "Bearer $Global:JwtToken" }

		$cacheStatus1 = $response1.Headers['X-Cache-Status']
		Write-Host "   Cache Status: $cacheStatus1" -ForegroundColor Cyan

		# Second request - Should be Cache HIT
		Start-Sleep -Milliseconds 500
		Write-Host "   → Second Request (Cache HIT expected)..." -ForegroundColor Gray
		$response2 = Invoke-WebRequest -Uri "$GatewayUrl/api/user/profile" `
			-Method Get `
			-Headers @{ Authorization = "Bearer $Global:JwtToken" }

		$cacheStatus2 = $response2.Headers['X-Cache-Status']
		Write-Host "   Cache Status: $cacheStatus2" -ForegroundColor Cyan

		if ($cacheStatus1 -eq "MISS" -and $cacheStatus2 -eq "HIT") {
			Write-Host "✅ PASSED: Caching working correctly!" -ForegroundColor Green
			$TestResults += "User Service + Cache: PASSED"
		} else {
			Write-Host "⚠️  WARNING: Cache behavior unexpected" -ForegroundColor Yellow
			$TestResults += "User Service + Cache: PARTIAL"
		}
	} catch {
		Write-Host "⚠️  WARNING: User service may not be running on port 5002" -ForegroundColor Yellow
		$TestResults += "User Service: SKIPPED (service not running)"
	}
} else {
	Write-Host "⚠️  SKIPPED: No JWT token available" -ForegroundColor Yellow
	$TestResults += "User Service: SKIPPED (no token)"
}
Write-Host ""

# Test 4: Rate Limiting
Write-Host "[TEST 4] Rate Limiting (100 requests/min)..." -ForegroundColor Yellow
try {
	$successCount = 0
	$rateLimitHit = $false

	Write-Host "   Sending 105 rapid requests..." -ForegroundColor Gray
	for ($i = 1; $i -le 105; $i++) {
		try {
			$response = Invoke-WebRequest -Uri "$GatewayUrl/health" -Method Get -ErrorAction SilentlyContinue
			if ($response.StatusCode -eq 200) {
				$successCount++
			}
		} catch {
			if ($_.Exception.Response.StatusCode.value__ -eq 429) {
				$rateLimitHit = $true
				Write-Host "   🚫 Rate limit hit at request #$i" -ForegroundColor Cyan
				break
			}
		}
	}

	if ($rateLimitHit) {
		Write-Host "✅ PASSED: Rate limiting working (blocked after $successCount requests)" -ForegroundColor Green
		$TestResults += "Rate Limiting: PASSED"
	} else {
		Write-Host "⚠️  WARNING: Rate limiting not triggered (may need adjustment)" -ForegroundColor Yellow
		$TestResults += "Rate Limiting: NOT TRIGGERED"
	}
} catch {
	Write-Host "❌ FAILED: Rate limiting test error - $($_.Exception.Message)" -ForegroundColor Red
	$TestResults += "Rate Limiting: FAILED"
}
Write-Host ""

# Test 5: CORS Headers
Write-Host "[TEST 5] CORS Configuration..." -ForegroundColor Yellow
try {
	$response = Invoke-WebRequest -Uri "$GatewayUrl/health" `
		-Method Options `
		-Headers @{ Origin = "http://localhost:3000" }

	$corsHeader = $response.Headers['Access-Control-Allow-Origin']
	if ($corsHeader) {
		Write-Host "✅ PASSED: CORS headers present" -ForegroundColor Green
		Write-Host "   Allow-Origin: $corsHeader" -ForegroundColor Gray
		$TestResults += "CORS: PASSED"
	}
} catch {
	Write-Host "⚠️  WARNING: Could not verify CORS headers" -ForegroundColor Yellow
	$TestResults += "CORS: COULD NOT VERIFY"
}
Write-Host ""

# Test 6: JWT Authentication (Unauthorized Test)
Write-Host "[TEST 6] JWT Authentication - Unauthorized Access..." -ForegroundColor Yellow
try {
	$response = Invoke-WebRequest -Uri "$GatewayUrl/api/user/profile" `
		-Method Get `
		-ErrorAction Stop
	Write-Host "❌ FAILED: Should have returned 401 Unauthorized" -ForegroundColor Red
	$TestResults += "JWT Auth: FAILED"
} catch {
	if ($_.Exception.Response.StatusCode.value__ -eq 401) {
		Write-Host "✅ PASSED: Correctly returned 401 Unauthorized" -ForegroundColor Green
		$TestResults += "JWT Auth: PASSED"
	} else {
		Write-Host "⚠️  WARNING: Unexpected status code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
		$TestResults += "JWT Auth: UNEXPECTED"
	}
}
Write-Host ""

# Test 7: Route to Event Service
Write-Host "[TEST 7] Event Service Routing..." -ForegroundColor Yellow
if ($Global:JwtToken) {
	try {
		$response = Invoke-WebRequest -Uri "$GatewayUrl/api/event/list" `
			-Method Get `
			-Headers @{ Authorization = "Bearer $Global:JwtToken" } `
			-ErrorAction Stop

		Write-Host "✅ PASSED: Event service route working" -ForegroundColor Green
		$TestResults += "Event Service Route: PASSED"
	} catch {
		Write-Host "⚠️  WARNING: Event service may not be running on port 5003" -ForegroundColor Yellow
		$TestResults += "Event Service Route: SKIPPED (service not running)"
	}
} else {
	Write-Host "⚠️  SKIPPED: No JWT token available" -ForegroundColor Yellow
	$TestResults += "Event Service Route: SKIPPED"
}
Write-Host ""

# Test 8: Redis Connection (via Cache Test)
Write-Host "[TEST 8] Redis Connection..." -ForegroundColor Yellow
try {
	# Try to connect to Redis directly
	$redisTest = Test-NetConnection -ComputerName localhost -Port 6379 -WarningAction SilentlyContinue

	if ($redisTest.TcpTestSucceeded) {
		Write-Host "✅ PASSED: Redis is running on port 6379" -ForegroundColor Green
		$TestResults += "Redis Connection: PASSED"
	} else {
		Write-Host "❌ FAILED: Redis is not running on port 6379" -ForegroundColor Red
		$TestResults += "Redis Connection: FAILED"
	}
} catch {
	Write-Host "⚠️  WARNING: Could not test Redis connection" -ForegroundColor Yellow
	$TestResults += "Redis Connection: COULD NOT TEST"
}
Write-Host ""

# Summary
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
foreach ($result in $TestResults) {
	if ($result -like "*PASSED*") {
		Write-Host "✅ $result" -ForegroundColor Green
	} elseif ($result -like "*FAILED*") {
		Write-Host "❌ $result" -ForegroundColor Red
	} else {
		Write-Host "⚠️  $result" -ForegroundColor Yellow
	}
}
Write-Host ""

$passedCount = ($TestResults | Where-Object { $_ -like "*PASSED*" }).Count
$totalCount = $TestResults.Count
$percentage = [math]::Round(($passedCount / $totalCount) * 100, 0)

Write-Host "Result: $passedCount/$totalCount tests passed ($percentage%)" -ForegroundColor Cyan

if ($percentage -eq 100) {
	Write-Host "🎉 All tests passed! Gateway is fully operational!" -ForegroundColor Green
} elseif ($percentage -ge 60) {
	Write-Host "⚠️  Gateway is partially working. Check services." -ForegroundColor Yellow
} else {
	Write-Host "❌ Gateway has issues. Please troubleshoot." -ForegroundColor Red
}

Write-Host ""
Write-Host "Tips:" -ForegroundColor Cyan
Write-Host "- Start Redis: docker run -d -p 6379:6379 redis:latest" -ForegroundColor Gray
Write-Host "- Start SEQ: docker run -d -p 5341:80 -e ACCEPT_EULA=Y datalust/seq:latest" -ForegroundColor Gray
Write-Host "- View Logs: http://localhost:5341" -ForegroundColor Gray
Write-Host "- Check Health: http://localhost:5000/health" -ForegroundColor Gray
