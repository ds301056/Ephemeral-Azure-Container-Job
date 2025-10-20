

Ephemeral-Azure-Container-Job/
  ├─ app/
  │   ├─ index.js
  │   ├─ package.json
  │   └─ Dockerfile
  ├─ infra/
  │   └─ bootstrap.sh
  ├─ .github/
  │   └─ workflows/
  │       └─ deploy-run.yml
  └─ README.md


  # Ephemeral Azure Container Job

**A self-terminating, cost-efficient Azure Container Apps Job that demonstrates cloud-native DevOps practices.**

## 🎯 What This Does

- Fetches trending GitHub repositories via public API
- Writes results to a JSON artifact
- Runs as an ephemeral container (scales to zero after completion)
- Deploys automatically via GitHub Actions CI/CD
- Demonstrates Azure Container Apps + ACR + automated workflows

## 🏗️ Architecture

```
Push to main → GitHub Actions → Build Docker image → Push to ACR 
→ Update ACA Job → Start execution → Run job → Auto-terminate → Zero cost
```

## 🚀 Setup Instructions

### Prerequisites

- Azure CLI installed (`az --version`)
- Docker installed
- Node.js 20+ (for local testing)
- Azure subscription with contributor access

### Step 1: Bootstrap Azure Infrastructure

```bash
# Make the script executable
chmod +x infra/bootstrap.sh

# Run the bootstrap (creates all Azure resources)
cd infra
bash bootstrap.sh
```

**Save the output!** You'll need these values for GitHub Secrets.

### Step 2: Create Service Principal for GitHub Actions

```bash
# Get your subscription ID
az account show --query id -o tsv

# Create service principal (replace <YOUR_SUB_ID>)
az ad sp create-for-rbac \
  --name ephemeral-job-sp \
  --role contributor \
  --scopes /subscriptions/<YOUR_SUB_ID> \
  --sdk-auth
```

Copy the entire JSON output (including the curly braces).

### Step 3: Configure GitHub Secrets

Go to your repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS` | Full JSON output from service principal creation |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID |
| `AZURE_RESOURCE_GROUP` | From bootstrap output (e.g., `rg-ephemeral-demo`) |
| `AZURE_REGION` | From bootstrap output (e.g., `eastus`) |
| `ACR_LOGIN_SERVER` | From bootstrap output (e.g., `acrephemeraldemo123456.azurecr.io`) |
| `ACR_USERNAME` | From bootstrap output |
| `ACR_PASSWORD` | From bootstrap output |

### Step 4: Push to Main Branch

```bash
# Initialize git (if not already)
git init
git add .
git commit -m "Initial commit: Ephemeral Azure Container Job"

# Add your GitHub remote and push
git remote add origin https://github.com/YOUR_USERNAME/Ephemeral-Azure-Container-Job.git
git branch -M main
git push -u origin main
```

The GitHub Actions workflow will automatically:
1. Build the Docker image
2. Push it to Azure Container Registry
3. Update the Container Apps Job
4. Start a job execution
5. Display the results

### Step 5: View Results

#### In GitHub Actions
- Go to **Actions** tab in your repo
- Click the latest workflow run
- Expand the steps to see job output

#### In Azure Portal
- Navigate to your Container Apps Job
- Go to **Executions** to see run history
- View logs for each execution

## 🧪 Local Testing

```bash
# Navigate to app directory
cd app

# Install dependencies
npm install

# Run locally
npm start
```

## 🔧 Tech Stack

**Cloud & Infrastructure:**
- Azure Container Apps (Jobs)
- Azure Container Registry
- Azure CLI automation

**DevOps & CI/CD:**
- GitHub Actions
- Docker containerization
- Automated build → push → deploy pipeline

**Application:**
- Node.js 20 (ES modules)
- node-fetch (HTTP client)
- Public API integration (GitHub)

## 💰 Cost Efficiency

- **Container Apps Jobs**: Pay only for execution time (scales to zero)
- **ACR Basic tier**: ~$5/month
- **Typical job execution**: ~5-10 seconds = pennies per run
- **Total monthly cost**: <$10 for unlimited runs

## 🎓 What This Demonstrates

✅ **Cloud Architecture**: Serverless containers with scale-to-zero  
✅ **DevOps Automation**: Full CI/CD pipeline from code to deployment  
✅ **Container Expertise**: Multi-stage builds, registry management  
✅ **Cost Optimization**: Ephemeral workloads that don't waste resources  
✅ **Modern Practices**: Infrastructure as Code, GitOps, automated workflows  

## 🔄 Next Steps

- Add Azure Blob Storage for artifact persistence
- Create a Static Web App to display results
- Add Application Insights for monitoring
- Implement scheduled triggers (cron-based execution)
- Add more complex data processing tasks

## 📚 Resources

- [Azure Container Apps Jobs Documentation](https://learn.microsoft.com/azure/container-apps/jobs)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Azure CLI Reference](https://learn.microsoft.com/cli/azure/)

## 🧹 Cleanup

To delete all Azure resources:

```bash
az group delete --name rg-ephemeral-demo --yes --no-wait
```

---

**Built to showcase cloud-native DevOps skills for technical interviews and portfolio demonstrations.**