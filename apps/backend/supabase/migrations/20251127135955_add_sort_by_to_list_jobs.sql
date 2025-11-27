-- Add jobs_sort_by parameter to list_jobs function for dynamic sorting
-- Supports sorting by: listedAt_desc, listedAt_asc, updatedAt_desc, updatedAt_asc

create or replace function list_jobs(
    jobs_status "Job Status", 
    jobs_after text, 
    jobs_page_size integer, 
    jobs_search text default null,
    jobs_site_ids integer[] default null,
    jobs_link_ids integer[] default null,
    jobs_labels text[] default null,
    jobs_sort_by text default 'updatedAt_desc'
)
returns setof jobs as $$
declare
  after_id integer;
  after_updated_at timestamp;
begin
  if jobs_after is not null then
    after_id := split_part(jobs_after, '!', 1)::integer;
    after_updated_at := split_part(jobs_after, '!', 2)::timestamp;
  end if;

  return query
  select *
  from jobs
  where status = jobs_status
    and (jobs_after is null or (updated_at, id) < (after_updated_at, after_id))
    and (array_length(jobs_site_ids, 1) is null or "siteId" = any(jobs_site_ids))
    and (array_length(jobs_link_ids, 1) is null or link_id = any(jobs_link_ids))
    and (array_length(jobs_labels, 1) is null or labels && jobs_labels)
    and (jobs_search is null or job_search_vector @@ plainto_tsquery('english', jobs_search))
  order by 
    case when jobs_sort_by = 'listedAt_desc' then "listedAt" end desc nulls last,
    case when jobs_sort_by = 'listedAt_asc' then "listedAt" end asc nulls last,
    case when jobs_sort_by = 'updatedAt_desc' then updated_at end desc,
    case when jobs_sort_by = 'updatedAt_asc' then updated_at end asc,
    id desc
  limit jobs_page_size;
end; $$
language plpgsql;
