# discourse-hide-topic-views

A tiny Discourse plugin that hides topic view counts more properly than CSS-only tweaks.

It does three things:

1. Removes `views` from `TopicListItemSerializer`, which affects topic list JSON such as `/latest.json`, category lists, tag lists, etc.
2. Removes `views` from `TopicViewSerializer`, which affects topic page JSON such as `/t/example-topic/123.json`.
3. Removes the desktop topic-list `views` column with Discourse's modern `topic-list-columns` frontend transformer.
4. Removes `views` from `TopicQuery::SORTABLE_MAPPING`, so `?order=views` no longer sorts topics by view count.

## Important notes

This plugin hides view counts from the normal public Discourse UI and the main topic/topic-list JSON payloads.

It does **not** erase existing database values, and it does **not** stop Discourse from tracking views internally. That is intentional, because view tracking is used by Discourse internals, admin reports, and ranking logic.

If you need nuclear-mode privacy where view counts are not collected at all, that should be done as a separate, carefully tested patch.

## Install option A: recommended GitHub repo install

1. Create a new GitHub repository named `discourse-hide-topic-views`.
2. Upload these plugin files to that repository.
3. On your Discourse server:

```bash
cd /var/discourse
nano containers/app.yml
```

4. Add this under `hooks: after_code:`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/YOUR_GITHUB_USERNAME/discourse-hide-topic-views.git
```

5. Rebuild:

```bash
cd /var/discourse
./launcher rebuild app
```

## Install option B: local plugin install from this zip

This is useful if you do not want to publish the plugin to GitHub.

1. Upload `discourse-hide-topic-views.zip` to your Discourse server.
2. Extract it into the local Discourse plugin directory:

```bash
cd /var/discourse
mkdir -p plugins
unzip /path/to/discourse-hide-topic-views.zip -d plugins
```

You should end up with:

```text
/var/discourse/plugins/discourse-hide-topic-views/plugin.rb
```

3. Rebuild:

```bash
cd /var/discourse
./launcher rebuild app
```

If your Discourse install does not load local plugins from `/var/discourse/plugins`, use the GitHub repo method instead. Standard self-hosted Discourse installs most commonly use the `containers/app.yml` git-clone approach.

## Test after install

Replace `https://forum.example.com` and topic id/slug with your real forum.

```bash
curl -s https://forum.example.com/latest.json | jq '.topic_list.topics[0] | has("views")'
```

Expected:

```text
false
```

Then test a topic:

```bash
curl -s https://forum.example.com/t/some-topic/123.json | jq 'has("views")'
```

Expected:

```text
false
```

Also test that sorting by views is neutralized:

```bash
curl -I "https://forum.example.com/latest?order=views"
```

It should not error, but it should no longer be using the views column as a sort key.

## Compatibility

Built for modern Discourse versions using:

- Ruby plugin patching via `plugin.rb`
- `TopicListItemSerializer#include_views?`
- `TopicViewSerializer#include_views?`
- Frontend API initializer with `topic-list-columns`

Because Discourse changes quickly, test on staging first before production.
