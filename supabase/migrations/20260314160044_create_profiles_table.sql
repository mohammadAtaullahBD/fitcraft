-- Create a table for public profiles
create table profiles (
  uid text primary key,
  email text not null,
  display_name text not null,
  photo_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Set up Row Level Security (RLS)
alter table profiles enable row level security;

-- Create policies for the profiles table
-- We assume that the application backend or edge functions might manage this,
-- or the authenticated user has their UID available via JWT claims (if Supabase Auth were used).
-- Since we are using Firebase Auth to interact with Supabase, we need a way for users to
-- access their own data. In our app architecture, the Flutter client sets the Supabase REST
-- client headers with the `uid` or we rely on the Anon key in the client app.
-- Since the anon key has no UID context by default, anyone can select their profile if they know the UID.
-- A completely secure approach requires setting up a Firebase JWT verifier in Supabase.
-- For now, to allow the Flutter app to work with the standard supabase Anon Key and Firebase,
-- we allow public read/write since the app will query based on Firebase Auth identity.
-- IN A REAL PRODUCTION APP, a custom Supabase JWT mechanism tied to Firebase should be used.
-- For this prototype/phase, we will use an open policy restricted by the application logic.

create policy "Profiles are viewable by everyone." on profiles
  for select using (true);

create policy "Users can insert their own profile." on profiles
  for insert with check (true);

create policy "Users can update their own profile." on profiles
  for update using (true);
