# CommunityConnect API - AWS Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                            INTERNET / USERS                                 │
│                                                                             │
└────────────────────────────────┬────────────────────────────────────────────┘
								 │
								 │ HTTPS (Port 443)
								 │ HTTP (Port 80)
								 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                    AWS Route 53 (Optional)                                  │
│                    DNS: api.communityconnect.com                            │
│                                                                             │
└────────────────────────────────┬────────────────────────────────────────────┘
								 │
								 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│              Application Load Balancer (ALB)                                │
│              - Health Checks: /health                                       │
│              - SSL/TLS Termination (ACM Certificate)                        │
│              - Request Distribution                                         │
│                                                                             │
└──────┬──────────────────────────────┬───────────────────────────────────────┘
	   │                              │
	   │  Port 80                     │  Port 80
	   ▼                              ▼
┌──────────────────────┐      ┌──────────────────────┐
│                      │      │                      │
│   EC2 Instance 1     │      │   EC2 Instance 2-4   │
│   t3.small           │      │   t3.small           │
│   Windows Server 2022│      │   Windows Server 2022│
│                      │      │                      │
│   ┌──────────────┐   │      │   ┌──────────────┐   │
│   │   IIS 10.0   │   │      │   │   IIS 10.0   │   │
│   │   ┌──────┐   │   │      │   │   ┌──────┐   │   │
│   │   │ .NET │   │   │      │   │   │ .NET │   │   │
│   │   │ 10.0 │   │   │      │   │   │ 10.0 │   │   │
│   │   │ API  │   │   │      │   │   │ API  │   │   │
│   │   └──────┘   │   │      │   │   └──────┘   │   │
│   └──────────────┘   │      │   └──────────────┘   │
│                      │      │                      │
│   CloudWatch Agent   │      │   CloudWatch Agent   │
│                      │      │                      │
└──────────┬───────────┘      └──────────┬───────────┘
		   │                             │
		   │                             │
		   └──────────────┬──────────────┘
						  │
						  │ Port 1433
						  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                  AWS RDS - SQL Server                                       │
│                  communityconnect-dev-db.cv4komqwqjgi.ap-south-1            │
│                  Instance: db.t3.small                                      │
│                  Storage: 20GB                                              │
│                  Multi-AZ: No (Dev) / Yes (Prod recommended)                │
│                                                                             │
│                  Security Group: Allow port 1433 from EB                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│              AWS ElastiCache - Redis (Optional)                             │
│              For caching and session management                             │
│              Instance: cache.t3.micro                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                    AWS CloudWatch                                           │
│                    - Application Logs                                       │
│                    - Metrics & Alarms                                       │
│                    - Dashboards                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                    AWS Secrets Manager (Recommended)                        │
│                    - Database Passwords                                     │
│                    - JWT Secret Keys                                        │
│                    - API Keys                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                    Auto Scaling Group                                       │
│                    Min: 1 instance                                          │
│                    Max: 4 instances                                         │
│                    Scaling Triggers:                                        │
│                    - CPU > 70%: Scale Up                                    │
│                    - CPU < 30%: Scale Down                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Details

### 1. **Route 53 (Optional - Future)**
- **Purpose**: DNS management and custom domain routing
- **Configuration**: Create A record pointing to ALB
- **Cost**: ~$0.50/month per hosted zone

### 2. **Application Load Balancer (ALB)**
- **Purpose**: 
  - Distribute traffic across EC2 instances
  - SSL/TLS termination
  - Health checks
- **Health Check**: GET `/health` every 15 seconds
- **Target Group**: EC2 instances running your API
- **Cost**: ~$20/month

### 3. **EC2 Instances**
- **Type**: t3.small (2 vCPU, 2GB RAM)
- **OS**: Windows Server 2022
- **Web Server**: IIS 10.0
- **Runtime**: .NET 10.0
- **Scale**: 1-4 instances (auto-scaling)
- **Cost**: ~$15/month per instance

### 4. **Auto Scaling Group**
- **Min Instances**: 1 (for cost savings)
- **Max Instances**: 4 (for traffic spikes)
- **Target Tracking**: CPU utilization (target: 50%)
- **Health Check Grace Period**: 300 seconds

### 5. **RDS SQL Server**
- **Endpoint**: `communityconnect-dev-db.cv4komqwqjgi.ap-south-1.rds.amazonaws.com`
- **Port**: 1433
- **Engine**: SQL Server Express/Standard
- **Storage**: 20GB (adjustable)
- **Backups**: Automated daily snapshots
- **Security**: VPC Security Group restricting access to EB instances only

### 6. **ElastiCache Redis (Optional)**
- **Purpose**: Caching and session management
- **Type**: cache.t3.micro
- **Replication**: None (single node for dev)
- **Cost**: ~$12/month

### 7. **CloudWatch**
- **Logs**: Application logs from all instances
- **Metrics**: CPU, Memory, Network, Request Count, Response Time
- **Alarms**: High error rate, high CPU, unhealthy instances
- **Retention**: 7 days (configurable)
- **Cost**: ~$5/month

### 8. **Secrets Manager (Recommended)**
- **Purpose**: Securely store sensitive configuration
- **Secrets**: Database password, JWT secret, API keys
- **Rotation**: Automatic credential rotation
- **Cost**: ~$0.40/secret/month

---

## Traffic Flow

### Incoming Request Flow:
```
User Request
	↓
Route 53 (DNS Resolution)
	↓
Application Load Balancer (SSL Termination)
	↓
Target Group (Health Check)
	↓
EC2 Instance (Round-robin or least connections)
	↓
IIS Web Server
	↓
.NET 10 API Application
	↓
Entity Framework Core
	↓
RDS SQL Server Database
	↓
Response back through same path
```

### Logging Flow:
```
Application Log Entry (Serilog)
	↓
CloudWatch Logs Agent
	↓
CloudWatch Logs (Stream)
	↓
Log Group: /aws/elasticbeanstalk/communityconnect-api-env
	↓
CloudWatch Insights (Querying)
```

---

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Region                          │
│                        ap-south-1                           │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                     VPC                               │  │
│  │                 10.0.0.0/16                          │  │
│  │                                                       │  │
│  │  ┌─────────────────────┐  ┌─────────────────────┐   │  │
│  │  │   Public Subnet A   │  │   Public Subnet B   │   │  │
│  │  │    10.0.1.0/24      │  │    10.0.2.0/24      │   │  │
│  │  │                     │  │                     │   │  │
│  │  │  - EC2 Instance 1   │  │  - EC2 Instance 2-4 │   │  │
│  │  │  - ALB              │  │                     │   │  │
│  │  │                     │  │                     │   │  │
│  │  └─────────────────────┘  └─────────────────────┘   │  │
│  │                                                       │  │
│  │  ┌─────────────────────┐  ┌─────────────────────┐   │  │
│  │  │  Private Subnet A   │  │  Private Subnet B   │   │  │
│  │  │    10.0.3.0/24      │  │    10.0.4.0/24      │   │  │
│  │  │                     │  │                     │   │  │
│  │  │  - RDS Primary      │  │  - RDS Standby      │   │  │
│  │  │  - ElastiCache      │  │                     │   │  │
│  │  │                     │  │                     │   │  │
│  │  └─────────────────────┘  └─────────────────────┘   │  │
│  │                                                       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Security Groups

### ALB Security Group
```
Inbound:
- Port 80 (HTTP) from 0.0.0.0/0
- Port 443 (HTTPS) from 0.0.0.0/0

Outbound:
- Port 80 to EC2 Security Group
```

### EC2 Security Group
```
Inbound:
- Port 80 from ALB Security Group
- Port 443 from ALB Security Group (if needed)

Outbound:
- Port 1433 to RDS Security Group
- Port 6379 to ElastiCache Security Group
- Port 443 to AWS Services (CloudWatch, Secrets Manager)
```

### RDS Security Group
```
Inbound:
- Port 1433 from EC2 Security Group

Outbound:
- None required
```

### ElastiCache Security Group
```
Inbound:
- Port 6379 from EC2 Security Group

Outbound:
- None required
```

---

## IAM Roles

### EC2 Instance Role (aws-elasticbeanstalk-ec2-role)
**Permissions:**
- Read from Secrets Manager
- Write to CloudWatch Logs
- Read from Systems Manager Parameter Store
- Download application bundle from S3

### Service Role (aws-elasticbeanstalk-service-role)
**Permissions:**
- Manage EC2 instances
- Manage Auto Scaling Groups
- Manage Load Balancers
- Enhanced health monitoring

---

## Monitoring & Alarms

### Key Metrics
1. **Application Health**: HTTP 5xx error count
2. **Instance Health**: CPU, Memory, Disk usage
3. **Database Health**: Connection count, CPU, IOPS
4. **Network**: Request count, response time, bandwidth

### Recommended Alarms
1. **High Error Rate**: 5xx count > 10 in 5 minutes
2. **High CPU**: CPU > 80% for 5 minutes
3. **Unhealthy Instances**: Any instance unhealthy for 2 minutes
4. **Database Connections**: Connection count > 80% of max

---

## Cost Breakdown (Monthly Estimate)

| Service | Configuration | Cost |
|---------|--------------|------|
| EC2 (t3.small x 1-4) | Windows, 1-4 instances | $15-60 |
| Application Load Balancer | Standard | $20 |
| RDS SQL Server | Already exists | $0* |
| CloudWatch Logs | 7-day retention | $5 |
| Data Transfer | Moderate | $5 |
| ElastiCache (Optional) | cache.t3.micro | $12 |
| Secrets Manager | 2-3 secrets | $1 |
| **Total (without RDS)** | | **$58-103** |

*RDS costs not included as you already have it

---

## Disaster Recovery

### Backup Strategy
- **RDS**: Automated daily snapshots, 7-day retention
- **Application**: Version controlled in GitHub
- **Configuration**: Stored in .ebextensions and appsettings

### Recovery Time Objective (RTO)
- **Application**: ~15 minutes (deploy previous version)
- **Database**: ~30 minutes (restore from snapshot)

### Recovery Point Objective (RPO)
- **Application**: Instant (version control)
- **Database**: Up to 24 hours (snapshot frequency)

---

This architecture provides:
- ✅ High availability (multiple instances + auto-scaling)
- ✅ Fault tolerance (ALB routes around unhealthy instances)
- ✅ Scalability (auto-scales based on demand)
- ✅ Security (VPC, Security Groups, Secrets Manager)
- ✅ Monitoring (CloudWatch metrics and logs)
- ✅ Cost optimization (scales down during low traffic)
