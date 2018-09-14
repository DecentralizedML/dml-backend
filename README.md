# DML Marketplace - Backend API

[![Build Status](https://travis-ci.org/DecentralizedML/dml-backend.svg?branch=master)](https://travis-ci.org/DecentralizedML/dml-backend)

Backend API for the [Decentralized Machine Learning][dml] project.

## Getting Started

### Dependencies

* Elixir **1.7.2**
* PostgreSQL **10**

### Setup

After cloning the repository, `cd` into it and install the hex dependencies:

```bash
mix deps.get
```

Copy the development secrets file:

```bash
# Edit this file with your Google & Facebook APP credentials
cp config/dev.secret.exs.sample config/dev.secret.exs
```

Then create & setup the database:

```bash
mix ecto.setup
```

You can also run `mix ecto.reset` if your database is already created and need some cleanup.

And run the server:

```bash
mix phx.server
```

You should be able to access the sever on http://0.0.0.0:4000

## Running the tests

Run the tests using

```bash
mix test
```

You should see something like this:

```bash
❯ mix test
..

Finished in 0.05 seconds
2 tests, 0 failures

Randomized with seed 789913
```

### Coding style tests

Check your code for code style & good practices using:

```bash
mix credo
```

## Deployment

#### Staging

* Install [Gigalixir][gigalixir]
* Deploy the project using `git push gigalixir master`
* Point the front-end application to [staging][staging]

## Built With

* [Elixir][elixir] - Language
* [Phoenix][phoenix] - Web framework
* [Hex][hex] - Dependency management

## Contributing

TODO

[dml]:https://decentralizedml.com/
[elixir]:https://elixir-lang.org/
[phoenix]:https://phoenixframework.org/
[hex]:https://hex.pm/
[gigalixir]:https://gigalixir.com/
[staging]:https://elegant-brisk-indianjackal.gigalixirapp.com/
