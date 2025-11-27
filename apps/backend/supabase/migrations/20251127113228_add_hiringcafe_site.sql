-- reset the sites id sequence to avoid conflicts with existing data
select setval('public.sites_id_seq', coalesce((select max(id) from public.sites), 0) + 1, false);

-- add HiringCafe as a supported job site (skip if already exists)
insert into public.sites (name, urls, logo_url, blacklisted_paths, provider, deprecated, incognito_support)
select
  'HiringCafe',
  array['https://hiring.cafe'],
  'https://hiring.cafe/hc-apple-logo.png',
  array[]::text[],
  'hiringCafe',
  false,
  true
where not exists (
  select 1 from public.sites where provider = 'hiringCafe'
);
