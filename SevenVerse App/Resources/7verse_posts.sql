CREATE  TABLE public.7verse_posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NULL,
  caption text NOT NULL,
  hashtags text[] NULL DEFAULT '{}'::text[],
  image_url text NOT NULL,
  cta_url text NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  is_premium boolean NOT NULL DEFAULT false,
  views integer NOT NULL,
  greetings_video jsonb NULL,
  thumbnail_url text NULL,
  CONSTRAINT 7verse_posts_pkey PRIMARY KEY (id),
  CONSTRAINT 7verse_posts_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES "7verse_profiles"(id)
) TABLESPACE pg_default;