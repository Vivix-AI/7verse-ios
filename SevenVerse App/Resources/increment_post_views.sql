-- Create a function to increment post views atomically
-- This function should be executed in Supabase SQL Editor

CREATE OR REPLACE FUNCTION increment_post_views(post_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public."7verse_posts"
  SET views = COALESCE(views, 0) + 1
  WHERE id = post_id;
END;
$$;

-- Grant execute permission to authenticated and anon roles
GRANT EXECUTE ON FUNCTION increment_post_views(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION increment_post_views(UUID) TO anon;
GRANT EXECUTE ON FUNCTION increment_post_views(UUID) TO service_role;

