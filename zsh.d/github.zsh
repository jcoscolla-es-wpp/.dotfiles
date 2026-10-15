# GITHUB HELPERS

# Month-to-date GitHub Copilot cost (net) for the FactoriaDev org.
# Needs billing access on the org. Override with GH_COST_ORG.
# Usage: ghcost | GH_COST_ORG=other ghcost
if command -v gh >/dev/null 2>&1; then
  ghcost() {
    gh api "/orgs/${GH_COST_ORG:-FactoriaDev}/settings/billing/usage?year=$(date +%Y)&month=$(date +%-m)" \
      --jq '[.usageItems[]|select(.product=="copilot")|.netAmount]|add // 0' \
      | awk '{printf "$%.2f USD\n", $1}'
  }
fi
