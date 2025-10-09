<!--
SPDX-FileCopyrightText: 2020 Zach Daniel

SPDX-License-Identifier: MIT
-->

# Upgrading to 2.0

This guide covers the key changes when upgrading to AshArchival 2.0.

## New archive_related_authorize? Option

Version 2.0 introduces the `archive_related_authorize?` configuration option that controls whether authorization checks are enforced when archiving related records.

```elixir
defmodule MyApp.User do
  use Ash.Resource,
    extensions: [AshArchival.Resource]

  archive do
    archive_related([:posts, :comments])
    archive_related_authorize?(false)  # Recommended setting
  end
end
```

## Breaking Change

This is a **breaking change** because in some cases when reading records during the archival process, we previously used `authorize?: false`, but now we respect the `archive_related_authorize?` setting.

**What changed:**
- Default behavior: `archive_related_authorize?: true` (authorization is enforced)
- Previously: authorization was inconsistently applied when reading related records for archival
- Now: explicit control over authorization behavior

## Recommended Action

For most applications, you should set `archive_related_authorize?: false`:

```elixir
archive do
  archive_related([:posts, :comments])
  archive_related_authorize?(false)
end
```

The reason you want it to be `false` is because you typically want to just authorize access to archive the parent record, and if that is allowed, then all related records will be archived without additional authorization checks.

## When to Keep Default (true)

Only keep the default `true` if you need fine-grained authorization control where some related records should only be archived if the actor has explicit permission to destroy them.
