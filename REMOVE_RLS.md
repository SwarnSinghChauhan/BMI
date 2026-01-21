# Remove Row Level Security - SQL Commands

Run these commands in Supabase SQL Editor to disable all Row Level Security policies.

## Step 1: Disable RLS on all tables

```sql
-- Disable Row Level Security on user_profiles
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- Disable Row Level Security on weight_history
ALTER TABLE weight_history DISABLE ROW LEVEL SECURITY;

-- Disable Row Level Security on bmi_records
ALTER TABLE bmi_records DISABLE ROW LEVEL SECURITY;
```

## Step 2: Drop all policies (optional cleanup)

```sql
-- Drop all policies from user_profiles
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;

-- Drop all policies from weight_history
DROP POLICY IF EXISTS "Users can view own weight history" ON weight_history;
DROP POLICY IF EXISTS "Users can insert own weight history" ON weight_history;

-- Drop all policies from bmi_records
DROP POLICY IF EXISTS "Users can view own BMI records" ON bmi_records;
DROP POLICY IF EXISTS "Users can insert own BMI records" ON bmi_records;
```

## Quick One-Step Solution (Run this)

If you want to do everything in one go, copy and paste this entire block:

```sql
-- Disable RLS
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE weight_history DISABLE ROW LEVEL SECURITY;
ALTER TABLE bmi_records DISABLE ROW LEVEL SECURITY;

-- Drop policies
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own weight history" ON weight_history;
DROP POLICY IF EXISTS "Users can insert own weight history" ON weight_history;
DROP POLICY IF EXISTS "Users can view own BMI records" ON bmi_records;
DROP POLICY IF EXISTS "Users can insert own BMI records" ON bmi_records;
```

## Verify RLS is Disabled

After running the commands, verify that RLS is disabled by running:

```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('user_profiles', 'weight_history', 'bmi_records');
```

**Expected Result:** All tables should show `rowsecurity = false`

---

## ⚠️ Security Note

Disabling RLS means any authenticated user can read/write any data in these tables. This is fine for development/testing, but for production you may want to implement proper policies later.
