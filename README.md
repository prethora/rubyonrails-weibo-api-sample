# README

## Setup

Create an appropriate directory within the project to store the contents of the `~/.wsapi` directory (or other location, if you configured it otherwise).

```bash
mkdir -p config/wsapi
```

Copy over the contents.

```bash
cp -r ~/.wsapi/* config/wsapi/
```

Set the production environment variable.

```bash
heroku config:set WSAPI_CONFIG_PATH=./config/wsapi/config.yaml
```

Copy the same value to the local `.env` file (loaded automatically when you call `heroku local`).

```bash
heroku config:get WSAPI_CONFIG_PATH -s  >> .env
```

This should now work locally with `heroku local` and in production when you push to heroku.

## Updating

If you ever use the CLI to add a new account, run the following to update:

```bash
rm -rf config/wsapi && mkdir -p config/wsapi && cp -r ~/.wsapi/* config/wsapi/
```
## Note

To be able to use ruby version `2.7.0` on heroku, you need to have a line with `ruby '2.7.0'` in the Gemfile, and you also need to run the following command in the project:

```bash
heroku stack:set heroku-18
```
