# GitHub Actions CI/CD Setup Guide

Complete guide to set up automatic deployment from GitHub to AWS Elastic Beanstalk.

---

## 🎯 What This CI/CD Pipeline Does

### On Pull Request:
✅ Builds the application  
✅ Runs tests  
✅ Comments on PR with build status  
❌ Does NOT deploy (for safety)

### On Merge to Main/Master:
✅ Builds the application  
✅ Runs tests  
✅ Creates deployment package  
✅ Uploads to AWS S3  
✅ Creates EB application version  
✅ Deploys to Elastic Beanstalk  
✅ Waits for deployment to complete  
✅ Verifies health endpoint  
🔄 Rolls back on failure (optional)

---

## 📋 Prerequisites

Before setting up CI/CD:

- [x] AWS Account with Elastic Beanstalk environment created
- [x] GitHub repository (you have this: CommunityConnect.API)
- [x] IAM user with deployment permissions
- [x] AWS Elastic Beanstalk environment deployed (run `.\deploy\setup-and-deploy.ps1` first)

---

## 🔧 Step-by-Step Setup

### Step 1: Create IAM User for GitHub Actions

Create a dedicated IAM user for GitHub Actions with minimal required permissions:

```powershell
# Create IAM user
aws iam create-user --user-name github-actions-deploy

# Attach necessary policies
aws iam attach-user-policy `
  --user-name github-actions-deploy `
  --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess

aws iam attach-user-policy `
  --user-name github-actions-deploy `
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Create access key
aws iam create-access-key --user-name github-actions-deploy
```

**Save the Access Key ID and Secret Access Key** - you'll need them in the next step!

#### Alternative: Use Custom Policy (More Secure)

Create a custom policy with minimal permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Effect": "Allow",
	  "Action": [
		"elasticbeanstalk:*",
		"s3:GetObject",
		"s3:PutObject",
		"s3:DeleteObject",
		"s3:ListBucket",
		"autoscaling:Describe*",
		"ec2:Describe*",
		"cloudformation:Describe*",
		"cloudformation:GetTemplate",
		"cloudformation:ListStackResources",
		"cloudformation:UpdateStack"
	  ],
	  "Resource": "*"
	}
  ]
}
```

Save this as `github-actions-policy.json` and attach:

```powershell
aws iam put-user-policy `
  --user-name github-actions-deploy `
  --policy-name GitHubActionsDeployPolicy `
  --policy-document file://github-actions-policy.json
```

---

### Step 2: Add Secrets to GitHub Repository

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

Add these secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AWS_ACCESS_KEY_ID` | [Your Access Key] | From Step 1 |
| `AWS_SECRET_ACCESS_KEY` | [Your Secret Key] | From Step 1 |

**Optional secrets** (if you want to customize):
| Secret Name | Value | Default |
|-------------|-------|---------|
| `AWS_REGION` | ap-south-1 | (already set in workflow) |
| `EB_APPLICATION_NAME` | CommunityConnect-API | (already set in workflow) |
| `EB_ENVIRONMENT_NAME` | communityconnect-api-env | (already set in workflow) |

---

### Step 3: Configure GitHub Actions Workflows

The workflows are already created in `.github/workflows/`:

#### **deploy-to-aws.yml** - Main deployment workflow
- Triggers on push to main/master
- Builds, tests, and deploys
- Includes rollback on failure

#### **pr-check.yml** - Pull request checks
- Triggers on pull requests
- Only builds and tests (doesn't deploy)
- Comments on PR with status

---

### Step 4: Initial Deployment (First Time)

Before GitHub Actions can deploy, you need the initial environment:

```powershell
# Run the manual setup script (one-time)
.\deploy\setup-and-deploy.ps1
```

This creates:
- AWS IAM roles
- Elastic Beanstalk application
- Elastic Beanstalk environment
- Initial deployment

---

### Step 5: Test the CI/CD Pipeline

#### Test Pull Request Build:
```bash
# Create a new branch
git checkout -b test-cicd

# Make a small change
echo "# CI/CD Test" >> README.md

# Commit and push
git add .
git commit -m "Test CI/CD pipeline"
git push origin test-cicd

# Create pull request on GitHub
# → CI should run build and test
```

#### Test Deployment:
```bash
# Merge to main
git checkout main
git merge test-cicd
git push origin main

# → CI should build, test, and deploy to AWS
```

---

## 📊 Workflow Details

### Build Job
```yaml
- Checkout code
- Setup .NET 10
- Restore dependencies
- Build (Release)
- Run tests
- Publish application
- Copy .ebextensions
- Create ZIP package
- Upload artifact
```

### Deploy Job (only on main/master push)
```yaml
- Download build artifact
- Configure AWS credentials
- Create version label
- Upload to S3
- Create EB application version
- Deploy to EB environment
- Wait for deployment
- Verify health endpoint
- Report status
```

### Rollback Job (on deploy failure)
```yaml
- Get previous version
- Rollback to previous version
- Notify failure
```

---

## 🔍 Monitor Deployments

### View GitHub Actions
1. Go to your repository on GitHub
2. Click **Actions** tab
3. See all workflow runs

### View Deployment Status
```powershell
# Check EB environment status
aws elasticbeanstalk describe-environments `
  --application-name CommunityConnect-API `
  --environment-names communityconnect-api-env `
  --region ap-south-1
```

### View Deployment Logs
1. Go to AWS Console → Elastic Beanstalk
2. Select your environment
3. Click **Logs**
4. Or use CLI:
```powershell
aws elasticbeanstalk request-environment-info `
  --environment-name communityconnect-api-env `
  --info-type tail `
  --region ap-south-1
```

---

## ⚙️ Customize Workflows

### Change Deployment Trigger

Edit `.github/workflows/deploy-to-aws.yml`:

```yaml
# Deploy on push to specific branches
on:
  push:
	branches:
	  - main
	  - production
	  - staging

# Deploy on tag creation
on:
  push:
	tags:
	  - 'v*.*.*'
```

### Add Environment-Specific Deployments

```yaml
# Multiple environments
deploy-staging:
  if: github.ref == 'refs/heads/staging'
  env:
	EB_ENVIRONMENT_NAME: communityconnect-api-staging

deploy-production:
  if: github.ref == 'refs/heads/main'
  env:
	EB_ENVIRONMENT_NAME: communityconnect-api-prod
```

### Add Slack/Email Notifications

```yaml
- name: Notify Slack
  if: always()
  uses: slackapi/slack-github-action@v1
  with:
	webhook-url: ${{ secrets.SLACK_WEBHOOK }}
	payload: |
	  {
		"text": "Deployment ${{ job.status }}: ${{ github.sha }}"
	  }
```

---

## 🔒 Security Best Practices

### 1. Use Environment-Specific Secrets
```yaml
environment:
  name: production
  url: http://production-env.elasticbeanstalk.com
```

### 2. Enable Branch Protection
1. Go to **Settings** → **Branches**
2. Add rule for `main`
3. Require:
   - ✅ Pull request reviews
   - ✅ Status checks to pass
   - ✅ Branch be up to date

### 3. Limit Permissions
Use minimal IAM permissions (see Step 1 alternative)

### 4. Enable Manual Approval
```yaml
deploy:
  environment:
	name: production
  # Requires manual approval in GitHub
```

---

## 🐛 Troubleshooting

### Build Fails
**Check:**
- .NET version in workflow matches your project
- All dependencies are restored
- No build errors in logs

**Fix:**
```yaml
- name: Build
  run: dotnet build --configuration Release --no-restore
  working-directory: src/Services/CommunityConnect.API  # Adjust path
```

### Deployment Fails
**Check:**
- AWS credentials are valid
- EB environment exists
- S3 bucket permissions

**View logs:**
```powershell
# Get recent workflow run
gh run list --limit 1

# View logs
gh run view [run-id] --log
```

### Rollback Doesn't Work
- Ensure previous version exists
- Check IAM permissions for EB updates

### Health Check Fails
- Verify `/health` endpoint works locally
- Check application logs in EB
- Ensure application is listening on correct port

---

## 📈 Advanced Features

### 1. Blue/Green Deployment
```yaml
- name: Swap environments
  run: |
	aws elasticbeanstalk swap-environment-cnames \
	  --source-environment-name blue-env \
	  --destination-environment-name green-env
```

### 2. Database Migration
```yaml
- name: Run migrations
  run: |
	dotnet ef database update --project src/Services/CommunityConnect.API
  env:
	ConnectionString: ${{ secrets.DB_CONNECTION_STRING }}
```

### 3. Performance Testing
```yaml
- name: Run load tests
  run: |
	artillery quick --count 100 --num 10 http://${{ steps.env-url.outputs.env_url }}
```

### 4. Smoke Tests
```yaml
- name: Smoke tests
  run: |
	curl -f http://${{ steps.env-url.outputs.env_url }}/health
	curl -f http://${{ steps.env-url.outputs.env_url }}/api/status
```

---

## 📊 Deployment Timeline

### First Deployment (Manual):
- ✅ IAM Setup: 2 minutes
- ✅ Environment Create: 5-10 minutes
- ✅ Initial Deploy: 5 minutes
**Total: ~15-20 minutes**

### CI/CD Deployment (Automatic):
- ✅ Build & Test: 2-3 minutes
- ✅ Upload to S3: 30 seconds
- ✅ EB Deployment: 3-5 minutes
- ✅ Health Check: 30 seconds
**Total: ~6-9 minutes**

---

## 🎯 Workflow Status Badges

Add to your README.md:

```markdown
![Deploy](https://github.com/Basawrajsuryawanshi/CommunityConnect.API/actions/workflows/deploy-to-aws.yml/badge.svg)
![PR Check](https://github.com/Basawrajsuryawanshi/CommunityConnect.API/actions/workflows/pr-check.yml/badge.svg)
```

---

## ✅ Checklist

### Initial Setup:
- [ ] Create IAM user for GitHub Actions
- [ ] Add AWS secrets to GitHub
- [ ] Run initial manual deployment
- [ ] Push workflows to GitHub
- [ ] Test PR build
- [ ] Test deployment to main

### Regular Use:
- [ ] Create feature branch
- [ ] Make changes
- [ ] Push branch
- [ ] Create PR (triggers build)
- [ ] Review and merge (triggers deploy)
- [ ] Verify deployment

---

## 📞 Support

### GitHub Actions Issues
- Check workflow logs in Actions tab
- Review AWS CloudWatch logs
- Verify AWS credentials and permissions

### AWS Deployment Issues
- Check EB environment health
- Review EB logs
- Verify security groups and network

### Need Help?
- GitHub Actions Docs: https://docs.github.com/en/actions
- AWS EB Docs: https://docs.aws.amazon.com/elasticbeanstalk
- Workflow logs in GitHub Actions tab

---

## 🚀 You're All Set!

Your CI/CD pipeline is configured. Now:

1. Add AWS secrets to GitHub
2. Push your code
3. Watch it automatically deploy! 🎉

**Workflow will automatically:**
- ✅ Build on every PR
- ✅ Test on every PR
- ✅ Deploy on merge to main
- ✅ Rollback on failure
- ✅ Verify health after deploy

**Simple workflow:**
```
Code → Commit → Push → PR → Merge → Auto Deploy! 🚀
```
