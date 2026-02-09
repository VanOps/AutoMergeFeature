#!/bin/bash
# check-repo-config.sh

REPO="$1"
if [ -z "$REPO" ]; then
  REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
fi

echo "╔═══════════════════════════════════════════════╗"
echo "║  Feature Auto-Merge Configuration Report     ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""
echo "📁 Repository: $REPO"
echo ""
echo "ℹ️  Strategy: Native GitHub Auto-Merge (no workflow)"
echo ""

echo "🔒 Branch Protection (main):"
gh api repos/$REPO/branches/main/protection 2>/dev/null | jq -r '
  "  Require PRs: \(.required_pull_request_reviews != null)",
  "  Require approvals: \(.required_pull_request_reviews.required_approving_review_count // 0)",
  "  Require up to date: \(.required_status_checks.strict // false)",
  "  Allow force push: \(.allow_force_pushes.enabled // false)",
  "  Allow deletions: \(.allow_deletions.enabled // false)"
' || echo "  No protection rules set"

echo ""
echo "🤖 GitHub Actions:"
gh api repos/$REPO/actions/permissions | jq -r '
  "  Enabled: \(.enabled)",
  "  Allowed actions: \(.allowed_actions)",
  "  Can approve PRs: \(.can_approve_pull_request_reviews // false)"
'

echo ""
echo "🔀 Merge Settings:"
gh api repos/$REPO | jq -r '
  "  Auto-merge allowed: \(.allow_auto_merge)",
  "  Squash merge: \(.allow_squash_merge)",
  "  Merge commit: \(.allow_merge_commit)",
  "  Rebase merge: \(.allow_rebase_merge)",
  "  Delete head branches: \(.delete_branch_on_merge)"
'

echo ""
echo "🛡️ Dependabot:"
gh api repos/$REPO/vulnerability-alerts --jq '.message' | grep -q 'disabled' && echo "  Alerts: Disabled" || echo "  Alerts: Enabled"  
ALERT_COUNT=$(gh api repos/$REPO/dependabot/alerts 2>/dev/null | jq 'length' 2>/dev/null || echo "N/A")
echo "  Open alerts: $ALERT_COUNT"

echo ""
echo "🔑 Secrets & Variables:"
echo "  Actions Secrets: $(gh secret list -a actions 2>/dev/null | wc -l)"
echo "  Dependabot Secrets: $(gh secret list -a dependabot 2>/dev/null | wc -l)"

echo ""
echo "✅ Status Checks Required:"
gh api repos/$REPO/branches/main/protection 2>/dev/null | \
  jq -r '.required_status_checks.checks[]? | "  - \(.context)"' || \
  echo "  None configured"

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║         Configuration Issues Found            ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# Check critical settings for Feature Auto-Merge (Native)
ISSUES_FOUND=0

AUTO_MERGE=$(gh api repos/$REPO | jq -r '.allow_auto_merge')
if [ "$AUTO_MERGE" != "true" ]; then
  echo "❌ CRITICAL: Auto-merge is disabled"
  echo "   Fix: Settings → General → Pull Requests:"
  echo "   ✓ Allow auto-merge"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

UP_TO_DATE=$(gh api repos/$REPO/branches/main/protection 2>/dev/null | jq -r '.required_status_checks.strict // false')
if [ "$UP_TO_DATE" != "true" ]; then
  echo "⚠️  WARNING: Branch not required to be up to date before merging"
  echo "   Fix: Settings → Branches → Branch protection rules → main:"
  echo "   ✓ Require branches to be up to date before merging"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

DELETE_BRANCH=$(gh api repos/$REPO | jq -r '.delete_branch_on_merge')
if [ "$DELETE_BRANCH" != "true" ]; then
  echo "⚠️  WARNING: Branches not deleted after merge"
  echo "   Fix: Settings → General → Pull Requests:"
  echo "   ✓ Automatically delete head branches"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

STATUS_CHECKS=$(gh api repos/$REPO/branches/main/protection 2>/dev/null | jq -r '.required_status_checks.checks | length' 2>/dev/null || echo 0)
if [ "$STATUS_CHECKS" -eq 0 ]; then
  echo "⚠️  WARNING: No required status checks configured"
  echo "   Fix: Settings → Branches → Branch protection rules → main:"
  echo "   Add required checks: '🧪 Run Tests', '🔍 Lint', '🔒 Security Scan'"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Verificar si hay requerimiento de PR reviews
REQUIRE_REVIEWS=$(gh api repos/$REPO/branches/main/protection 2>/dev/null | jq -r '.required_pull_request_reviews != null')
if [ "$REQUIRE_REVIEWS" != "true" ]; then
  echo "⚠️  WARNING: Branch protection doesn't require PR reviews"
  echo "   Fix: Settings → Branches → Branch protection rules → main:"
  echo "   ✓ Require a pull request before merging"
  echo "   ✓ Require approvals: 1 (minimum)"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

echo ""
if [ $ISSUES_FOUND -eq 0 ]; then
  echo "✅ All configurations are correct for Feature Auto-Merge!"
  echo ""
  echo "🚀 How to use:"
  echo "   1. Create PR with feature branch"
  echo "   2. Wait for CI to pass"
  echo "   3. Get PR approved"
  echo "   4. Enable auto-merge: gh pr merge --auto --squash <PR_NUMBER>"
  echo "   5. GitHub will merge automatically when all conditions are met"
else
  echo "Found $ISSUES_FOUND configuration issue(s) that may prevent auto-merge from working."
  echo ""
  echo "📚 See README for detailed setup instructions:"
  echo "   AutoMergeFeature/README.md"
fi