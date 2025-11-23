-- Quick verification: Check if data exists in database
-- Run this in Supabase SQL Editor

-- 1. Check total rows
SELECT 
    'Total posts in database:' as info,
    COUNT(*) as count 
FROM public."7verse_posts";

-- 2. Check with service_role (bypasses RLS)
SET ROLE service_role;
SELECT 
    'Posts visible to service_role:' as info,
    COUNT(*) as count 
FROM public."7verse_posts";
RESET ROLE;

-- 3. Show first 3 rows if any exist
SELECT 
    id,
    LEFT(caption, 30) as caption_preview,
    created_at,
    is_premium
FROM public."7verse_posts"
ORDER BY created_at DESC
LIMIT 3;

-- 4. If no data, insert sample data
-- Uncomment to insert test data:
/*
INSERT INTO public."7verse_posts" (
    id, 
    profile_id, 
    caption, 
    hashtags, 
    image_url, 
    is_premium
) VALUES (
    gen_random_uuid(),
    gen_random_uuid(),
    'Test post from iOS app',
    ARRAY['test', 'ios', 'app'],
    'https://picsum.photos/400/600',
    false
);
*/

