CREATE  TABLE public.7verse_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL,
  profile_name text NOT NULL,
  bio text NULL,
  avatar_url text NULL,
  followers_count integer NULL DEFAULT 0,
  following_count integer NULL DEFAULT 0,
  created_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT 7verse_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT 7verse_profiles_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES next_auth.users(id)
) TABLESPACE pg_default;