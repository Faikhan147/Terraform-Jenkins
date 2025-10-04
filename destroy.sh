echo "🛠️ Initializing Terraform..."
terraform init -reconfigure

echo "✅ Validating configuration..."
terraform validate

echo "📝 Formatting Terraform files..."
terraform fmt -recursive

# Display workspace list
echo "🔢 Listing available workspaces..."
terraform workspace list

echo "🛑 WARNING: This will destroy the jenkins!"
read -p "Are you absolutely sure? Type 'destroy' to continue: " confirm

if [ "$confirm" == "destroy" ]; then
    echo "🔥 Destroying jenkins infrastructure..."
    terraform destroy -var-file="terraform.tfvars"

    echo "📊 Showing the current state after destroy..."
    terraform show
else
    echo "❌ Destroy aborted."
fi
