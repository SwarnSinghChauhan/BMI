# Supabase Database Setup Instructions

Follow these steps to set up the required database tables in Supabase for the BMI Tracker app.

## Prerequisites
- Access to your Supabase project dashboard
- Navigate to SQL Editor in Supabase

## Step 1: Create user_profiles Table

```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  weight DECIMAL(5,2),
  height DECIMAL(5,2),
  gender TEXT,
  weight_unit TEXT DEFAULT 'kg',
  height_unit TEXT DEFAULT 'cm',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to read their own data
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy to allow users to insert their own data
CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to update their own data
CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE
  USING (auth.uid() = user_id);
```

## Step 2: Create weight_history Table

```sql
CREATE TABLE weight_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  weight DECIMAL(5,2),
  unit TEXT DEFAULT 'kg',
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_weight_history_user_date ON weight_history(user_id, recorded_at DESC);

-- Enable Row Level Security
ALTER TABLE weight_history ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to read their own data
CREATE POLICY "Users can view own weight history" ON weight_history
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy to allow users to insert their own data
CREATE POLICY "Users can insert own weight history" ON weight_history
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## Step 3: Create bmi_records Table

```sql
CREATE TABLE bmi_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  bmi DECIMAL(4,2),
  category TEXT,
  calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_bmi_records_user_date ON bmi_records(user_id, calculated_at DESC);

-- Enable Row Level Security
ALTER TABLE bmi_records ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to read their own data
CREATE POLICY "Users can view own BMI records" ON bmi_records
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy to allow users to insert their own data
CREATE POLICY "Users can insert own BMI records" ON bmi_records
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## Step 4: Configure Google Sign-In (if not already done)

1. Go to Authentication → Providers in Supabase
2. Enable Google provider
3. Add your Google OAuth credentials
4. Add authorized redirect URIs

## Step 5: Enable Email Authentication (if not already done)

1. Go to Authentication → Providers in Supabase
2. Ensure Email provider is enabled
3. Configure email templates if needed

## Testing the Setup

After running these SQL commands:

1. Open Supabase Table Editor
2. Verify all three tables are created:
   - user_profiles
   - weight_history
   - bmi_records
3. Check that Row Level Security (RLS) is enabled for each table
4. Verify policies are in place

## Important Notes

- **Row Level Security**: All tables have RLS enabled to ensure users can only access their own data
- **Cascade Deletion**: If a user is deleted from auth.users, all their data will be automatically deleted
- **Indexes**: Created on frequently queried columns for better performance
- **Timestamps**: All tables use TIMESTAMP WITH TIME ZONE for proper timezone handling
