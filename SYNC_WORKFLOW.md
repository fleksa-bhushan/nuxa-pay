# 🔄 NuxaPay - Polar Upstream Sync Workflow

## Overview
This document outlines the **manual review workflow** for syncing upstream changes from the official Polar repository into our NuxaPay fork.

## Branch Structure

```
main      ← Always clean, synced with upstream/main
nuxapay   ← Our stable branch with customizations
upstream  ← Official Polar repository (read-only)
origin    ← Our fork: fleksa-bhushan/nuxa-pay
```

## Remote Configuration

```bash
# Verify current setup
git remote -v
# Should show:
# origin    git@github.com:fleksa-bhushan/nuxa-pay.git
# upstream  git@github.com:polarsource/polar.git
```

## Manual Sync Process

### 1. Check for Upstream Updates (Weekly)

```bash
# Fetch latest from upstream
git fetch upstream

# Check what's new
git log --oneline main..upstream/main

# Review changes (optional)
git diff main..upstream/main
```

### 2. Sync Main Branch

```bash
# Switch to main and update
git checkout main
git merge upstream/main --ff-only
git push origin main
```

### 3. Review Before Merging

**⚠️ IMPORTANT: Always review changes before merging into nuxapay**

```bash
# See what would be merged
git checkout nuxapay
git log --oneline nuxapay..main

# Check for conflicts
git merge-tree $(git merge-base nuxapay main) nuxapay main
```

### 4. Merge Upstream Changes (After Review)

```bash
# Create backup tag before merge
git tag -a "pre-merge-$(date +%Y%m%d)" -m "Backup before upstream merge"

# Merge main into nuxapay
git merge main

# If conflicts occur:
# 1. Resolve conflicts manually
# 2. Keep our customizations
# 3. Accept upstream improvements
# 4. Test thoroughly

git commit  # if there were conflicts
```

### 5. Test and Validate

```bash
# Test production scripts
./restart-prod.sh

# Verify services are working
ps aux | grep -E 'uvicorn|dramatiq|next'

# Check logs for errors
tail -f /tmp/polar-*.log
```

### 6. Push Changes

```bash
# Push updated nuxapay branch
git push origin nuxapay
```

## Conflict Resolution Strategy

### Files to Prioritize (Keep Our Changes)
- `start-prod.sh`, `stop-prod.sh`, `restart-prod.sh` - Our production scripts
- `.gitignore` - Our custom entries
- Any payment integration customizations
- Environment configurations

### Files to Accept (Take Upstream)
- Bug fixes in core Polar code
- Performance improvements
- Security updates
- New features we want to adopt

### Merge Conflict Example

```bash
# When you see conflicts like:
<<<<<<< HEAD
# Our custom code
=======
# Upstream changes
>>>>>>> main

# Decision matrix:
# - Keep our code if it's custom functionality
# - Take upstream if it's a bug fix/improvement
# - Combine both if needed
```

## Emergency Rollback

If something breaks after merge:

```bash
# Rollback to pre-merge state
git reset --hard pre-merge-YYYYMMDD

# Force push (be careful!)
git push origin nuxapay --force-with-lease
```

## Best Practices

### 1. **Review First, Merge Second**
- Always check `git log` and `git diff` before merging
- Understand what changes are coming in
- Plan for potential conflicts

### 2. **Test in Staging**
- Use a separate environment for testing merges
- Run full test suite after merge
- Verify all custom features still work

### 3. **Document Conflicts**
- Keep notes of any conflicts encountered
- Document decisions made during resolution
- Share knowledge with team

### 4. **Regular Sync Schedule**
- Check for updates: **Weekly**
- Review and merge: **Bi-weekly** (if safe)
- Emergency security updates: **Immediately**

## Quick Commands Reference

```bash
# Check upstream changes
git fetch upstream && git log --oneline main..upstream/main

# Safe merge check
git merge-tree $(git merge-base nuxapay main) nuxapay main

# Backup before merge
git tag -a "pre-merge-$(date +%Y%m%d)" -m "Backup"

# Merge workflow
git checkout main && git merge upstream/main --ff-only
git checkout nuxapay && git merge main

# Verify deployment
./restart-prod.sh && tail -f /tmp/polar-*.log
```

## Commit Message Convention

```bash
# For upstream syncs
git commit -m "merge: Sync with upstream main (YYYY-MM-DD)"

# For conflict resolutions
git commit -m "resolve: Merge conflicts in webhook processing"

# For our features
git commit -m "feat: Add NuxaPay commission system"
```

---

**Remember**: This is a **manual review process**. Never merge automatically. Always understand what you're bringing in from upstream.