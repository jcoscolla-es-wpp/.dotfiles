# AWS HELPERS

# Month-to-date unblended cost for the active AWS profile (excludes tax).
# Cost Explorer bills ~$0.01 per call. End date is exclusive, so use tomorrow.
# Usage: awscost | AWS_PROFILE=other awscost
if command -v aws >/dev/null 2>&1; then
  awscost() {
    aws ce get-cost-and-usage --region us-east-1 \
      --time-period "Start=$(date +%Y-%m-01),End=$(date -v+1d +%F)" \
      --granularity MONTHLY --metrics UnblendedCost \
      --query 'ResultsByTime[].Total.UnblendedCost.Amount' --output text \
      | awk '{printf "$%.2f USD\n", $1}'
  }
fi
