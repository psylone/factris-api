# Factris API

Simple [factris](https://factris.com) API.

# Dependencies

- Ruby `2.7+`
- Bundler `2.1.4`
- Rails `6.0+`
- Puma `4.3+`
- PostgreSQL `9.3+`

# Getting started

1. Clone repository:

```
git clone git@github.com:psylone/factris-api.git && cd factris-api
```

2. Setup dependencies and create database:

```
bin/setup
```

3. Populate the database with seeds (optional):

```
bin/rails db:seed
```

4. Start application:

```
bin/rails s
```

# Running test suite

```
bin/rspec
```
