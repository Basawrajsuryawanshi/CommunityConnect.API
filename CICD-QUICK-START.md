# 🚀 GitHub Actions CI/CD - Quick Start

Automatic deployment from GitHub to AWS Elastic Beanstalk whenever you merge to main!

---

## ⚡ 3-Step Setup

### Step 1: Create IAM User for GitHub

```powershell
# Create user
aws iam create-user --user-name github-actions-deploy

# Attach policies
aws iam attach-user-policy `
  --user-name github-actions-deploy `
  --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess

aws iam attach-user-policy `
  --user-name github-actions-deploy `
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Create access key
aws iam create-access-key --user-name github-actions-deploy
```

**Save the Access Key ID and Secret Access Key!**

---

### Step 2: Add Secrets to GitHub

1. Go to: https://github.com/Basawrajsuryawanshi/CommunityConnect.API/settings/secrets/actions
2. Click **New repository secret**
3. Add TWO secrets:

| Name | Value |
|------|-------|
| `AWS_ACCESS_KEY_ID` | [Your Access Key from Step 1] |
| `AWS_SECRET_ACCESS_KEY` | [Your Secret Key from Step 1] |

---

### Step 3: Deploy Initial Environment

```powershell
# One-time initial setup
.\deploy\setup-and-deploy.ps1
```

This creates the AWS environment that GitHub Actions will deploy to.

---

## 🎉 That's It! You're Done!

### What Happens Now:

#### **On Pull Request:**
```
Create PR → GitHub Actions runs:
  ✅ Build
  ✅ Test
  ✅ Comment on PR with results
  ❌ Does NOT deploy (safe!)
```

#### **On Merge to Main:**
```
Merge PR → GitHub Actions runs:
  ✅ Build
  ✅ Test
  ✅ Create package
  ✅ Upload to AWS
  ✅ Deploy to Elastic Beanstalk
  ✅ Verify health
  🎉 Your app is live!
```

Time: 6-9 minutes

---

## 🧪 Test Your CI/CD

### Test 1: PR Build
```bash
# Create branch
git checkout -b test-cicd

# Make change
echo "# CI/CD Test" >> README.md

# Push
git add .
git commit -m "Test CI/CD"
git push origin test-cicd

# Create PR on GitHub
# → Watch Actions tab - build will run!
```

### Test 2: Deploy
```bash
# Merge your PR on GitHub
# → Watch Actions tab - deploy will run!

# Or via command line:
git checkout main
git merge test-cicd
git push origin main
```

---

## 📊 Monitor Deployments

### GitHub:
https://github.com/Basawrajsuryawanshi/CommunityConnect.API/actions

### AWS Console:
https://console.aws.amazon.com/elasticbeanstalk

### Command Line:
```powershell
# Check deployment status
aws elasticbeanstalk describe-environments `
  --application-name CommunityConnect-API `
  --environment-names communityconnect-api-env `
  --region ap-south-1
```

---

## 🔄 Your New Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    Make Code Changes                        │
└────────────────────┬────────────────────────────────────────┘
					 │
					 ▼
┌─────────────────────────────────────────────────────────────┐
│              git push origin feature-branch                 │
└────────────────────┬────────────────────────────────────────┘
					 │
					 ▼
┌─────────────────────────────────────────────────────────────┐
│              Create Pull Request on GitHub                  │
└────────────────────┬────────────────────────────────────────┘
					 │
					 ▼
┌─────────────────────────────────────────────────────────────┐
│    GitHub Actions: Build & Test (2-3 minutes)              │
│    ✅ Build success ✅ Tests pass                           │
└────────────────────┬────────────────────────────────────────┘
					 │
					 ▼
┌─────────────────────────────────────────────────────────────┐
│                 Review & Merge PR                           │
└────────────────────┬────────────────────────────────────────┘
					 │
					 ▼
┌─────────────────────────────────────────────────────────────┐
│    GitHub Actions: Build, Test & Deploy (6-9 minutes)      │
│    ✅ Build ✅ Test ✅ Package ✅ Upload ✅ Deploy          │
└────────────────────┬────────────────────────────────────────┘
					 │
					 ▼
┌─────────────────────────────────────────────────────────────┐
│             🎉 Your API is LIVE on AWS! 🎉                  │
│   http://communityconnect-api-env.[id].elasticbeanstalk.com│
└─────────────────────────────────────────────────────────────┘
```

---

## 🆘 Quick Troubleshooting

### "Deployment failed"
Check:
1. AWS credentials in GitHub secrets
2. EB environment exists (run setup script)
3. Workflow logs in GitHub Actions tab

### "Build failed"
Check:
1. Code compiles locally: `dotnet build`
2. Tests pass locally: `dotnet test`
3. Workflow logs for specific error

### "No workflows running"
Check:
1. Workflows are in `.github/workflows/` folder
2. Pushed to main/master branch
3. GitHub Actions enabled for repo

---

## 📚 Full Documentation

- **Detailed Setup**: [GITHUB-ACTIONS-SETUP.md](./GITHUB-ACTIONS-SETUP.md)
- **Manual Deployment**: [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
- **Architecture**: [AWS-ARCHITECTURE.md](./AWS-ARCHITECTURE.md)

---

## ✅ Setup Checklist

- [ ] IAM user created
- [ ] AWS secrets added to GitHub
- [ ] Initial environment deployed (`setup-and-deploy.ps1`)
- [ ] Workflows committed to repository
- [ ] Test PR created and built successfully
- [ ] Test deployment to main successful

---

## 🎯 Summary

**Before:** Manual deployment with scripts  
**After:** Push code → Automatic deployment!

**No more manual deployments!** 🎉

Just:
1. Code
2. Commit
3. Push
4. Create PR
5. Merge
6. ☕ Grab coffee while GitHub deploys

---

## 📞 Need Help?

Check:
- GitHub Actions tab for workflow logs
- [GITHUB-ACTIONS-SETUP.md](./GITHUB-ACTIONS-SETUP.md) for detailed guide
- AWS Console for deployment status

---

**Ready to automate?**

1. Run Step 1-3 above
2. Push your code
3. Watch the magic happen! ✨
