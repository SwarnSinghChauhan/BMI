# SQL Fix for User Profiles Table

If you're experiencing issues with the user_profiles table (like unique constraint violations), you can run these commands to ensure the table is configured correctly for upsert operations.

## Check Current Constraints

```sql
-- View all constraints on user_profiles table
SELECT conname, contype 
FROM pg_constraint 
WHERE conrelid = 'user_profiles'::regclass;
```

## The unique constraint on user_id is CORRECT and necessary

The `user_profiles_user_id_key` unique constraint ensures each user has only ONE profile. This is the correct design.

**The app has been fixed** to:
1. Check if a profile exists before trying to insert
2. Use UPDATE for existing profiles
3. Use INSERT only for new profiles

## If you still want to allow multiple profiles per user (NOT RECOMMENDED)

Only run this if you truly need multiple profiles per user:

```sql
-- Drop the unique constraint (NOT RECOMMENDED)
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_user_id_key;
```

## Recommended: Keep the constraint and use the updated app code

The app code has been fixed to properly handle updates, so the unique constraint should no longer cause errors. The constraint is important for data integrity.

## Verify Everything is Working

After the app fixes, test by:
1. Creating a new profile (first time)
2. Updating the profile (subsequent times)
3. Both operations should work without errors

If you still see errors, check:
- That you're running the latest code from the `main` branch
- That RLS has been disabled (as per REMOVE_RLS.md)
- That the user is authenticated when saving/updating
