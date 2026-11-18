# The Data Lens Admin — setup guide

The admin interface is committed under `/admin`. It is a static frontend; authentication, private file storage and database access require a Supabase project.

## Current implementation status

- Implemented in this first admin build: sign-in UI, admin allow-list check, research create/edit/draft/publish/archive, CSV/XLSX/JSON parsing, PDF/image file upload, basic data-quality warnings, dataset catalogue, chart preview from uploaded structured data, PNG chart export, activity logging hooks, responsive layout.
- Requires Supabase configuration: authentication, database tables, RLS policies and private storage bucket.
- Not implemented yet: scheduled publishing execution, AI research assistant, visitor analytics, reusable public dashboard publishing, dataset version/restore UI, CSV/XLSX export of normalized records, automated external data connectors. These are explicitly later milestones; the current schedule screen is a placeholder, not an active scheduler.

## 1. Create Supabase project

1. Create a project at https://supabase.com/ and keep the database password safe.
2. In Project Settings → API, copy the Project URL and the anon/public (publishable) key.
3. In Authentication → Providers, enable Email.
4. In Authentication settings, turn off public sign-ups after you have created your own admin account, if your project settings permit it. Use a strong unique password and enable MFA if available.

## 2. Create your administrator identity

1. In Supabase → Authentication → Users, add your own email/password user (or sign up once through the approved method).
2. Copy the user's UUID from the Users table.
3. Open SQL Editor and run the contents of `supabase-schema.sql`.
4. Then run this one-time statement, replacing the placeholder with your own UUID:

```sql
insert into public.admin_users (user_id)
values ('YOUR-AUTH-USER-UUID');
```

Do not share your password or UUID publicly. Do not add any other user to this allow-list.

## 3. Configure the admin frontend

Edit `admin/config.js` in GitHub and replace:
- `https://YOUR-PROJECT.supabase.co` with your Supabase Project URL
- `YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY` with the anon/public or publishable key

It is expected that this public key is visible in browser code. The database is protected by Auth and Row Level Security. NEVER put the Supabase service_role/secret key in `config.js`, HTML, JavaScript or GitHub.

## 4. Open the admin

Once GitHub Pages is deployed and Supabase is configured:
`https://YOUR-GITHUB-PAGES-HOST/admin/`

Sign in with the user you created and added to `admin_users`.

## 5. Publishing workflow

- Articles: create, preview, save draft, or publish. Publishing requires a source URL.
- Datasets: upload CSV/XLSX/JSON for parsing and a basic quality check; PDF/images are stored as files and recorded as non-tabular assets.
- Dashboard builder: preview a chart from a parsed dataset and export the chart image as PNG.
- Research and dataset data are private to the admin by default. Public article display and public dashboard routes still need to be connected to the public site before content appears there.

## Security and data notes

- The storage bucket is private. Access is mediated by Supabase Storage policies.
- RLS is enabled on all application tables in the supplied schema.
- The admin allow-list is separate from Supabase authentication: a valid login alone does not grant admin access.
- The browser import preview stores at most 5,000 parsed rows in the first implementation. Keep the original uploaded file as the authoritative source for larger datasets.
- Basic validation checks blank cells, duplicate rows and missing columns only; it does not verify the truth of values or source reliability.
- Back up your Supabase project and downloaded source files. Do not upload confidential or licensed datasets unless you have permission.
