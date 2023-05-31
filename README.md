# BLOG
BLOG is Phoenix (elixir) base application where users can add their post and make comment on them

## Installation

clone repo from git:

```bash
git clone https://github.com/talhaarshad123/BLOG.git
```

## Usage

```elixir
cd /BLOG

# run following commands on terminal
mix deps.get
# to create database for app
mix ecto.create

# add database name and credentials in /BLOG/config/dev.ex
config :blog, Blog.Repo,
  username: "#",
  password: "#",
  hostname: "#",
  database: "#",
# For this application we have used PostgreSQL
# run migrations
mix ecto.migrate

# start phoenix server
mix phx.server
# open URL http://localhost:4000/
```
