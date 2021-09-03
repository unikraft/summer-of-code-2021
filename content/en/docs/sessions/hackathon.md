---
title: "Hackathon"
linkTitle: "Hackathon"
---

Unikraft Summer of Code 2021 (USoC'21) finalizes with an 8 hour hackathon on Saturday, September 4, 2021, 9am CEST - 5pm CEST.

Teams of 3-4 participants will work on adding tests, adding metrics, port libraries, port applications and fix issues in Unikraft components.
Each hackathon challenge will get your team points, depending on the difficulty.
The top three teams will be awarded the most prestigious USoC badges:

* 3rd place: the [Green Dragon badge](https://eu.badgr.com/public/badges/WWBWO7ccTxmYLl7Om6o0Ig)
* 2nd place: the [Red Dragon badge](https://eu.badgr.com/public/badges/bTuLRsqzSKy8fZ5xrCyYSQ)
* 1st place: the [Black Dragon badge](https://eu.badgr.com/public/badges/hBNobLOGRJiydfzsibV2iw)

Challenges are listed below.
You solve a challenge:

* by submitting a pull request to the [corresponding Unikraft repository](https://github.com/unikraft/), or
* by creating a repository for a ported application / library

## New uktest Suites

**Id**: `uktest-suites`

**Description**: Use [uktest](docs/sessions/06-testing-unikraft/#03-unikrafts-testing-framework.md) to add new tests in Unikraft components.

**Points**: 1 point / assert

**Links / Resources**:

* [uktest](docs/sessions/06-testing-unikraft/#03-unikrafts-testing-framework.md): Unikraft's testing framework

## Fix Build Warnings

**Id**: `warnings`

**Description**: Fix build warnings in Unikraft components.

**Points**: 3 points / warning

**Links / Resources**:

* [issue on Unikraft build warnings](https://github.com/unikraft/unikraft/issues/242)

## Add ukstore Entries

**Id**: `ukstore`

**Description**: Add new [ukstore](https://github.com/unikraft/unikraft/pull/275) entries.

**Points**: 1 point / entry

**Links / Resources**:

* [ukstore](https://github.com/unikraft/unikraft/pull/275)

## Add New kraft Tests

**Id**: `kraft-tests`

**Description**: Add new tests in [kraft](https://github.com/unikraft/kraft).

**Points**: 1 point / test

**Links / Resources**:

* [kraft](https://github.com/unikraft/kraft)
* [kraft tests](https://github.com/unikraft/kraft/tree/staging/tests)

## Run Django

**Id**: `app-django`

**Description**: Run [Django](https://www.djangoproject.com/) on top of [lib-python3](https://github.com/unikraft/lib-python3).

**Points**: 10 points

**Links / Resources**:

* [Django](https://www.djangoproject.com/)
* [lib-python3](https://github.com/unikraft/lib-python3).

## Run Flask

**Id**: `app-flask`

**Description**: Run [Flask](https://flask.palletsprojects.com/en/2.0.x/) on top of [lib-python3](https://github.com/unikraft/lib-python3).

**Points**: 10 points

**Links / Resources**:

* [Flask](https://flask.palletsprojects.com/en/2.0.x/)
* [lib-python3](https://github.com/unikraft/lib-python3)

## Run Rails

**Id**: `app-rails`

**Description**: Run [Rails](https://rubyonrails.org/) on top of [lib-ruby](https://github.com/unikraft/lib-ruby/).

**Points**: 15 points

**Links / Resources**:

* [Rails](https://rubyonrails.org/)
* [lib-ruby](https://github.com/unikraft/lib-ruby/)

## Port PHP

**Id**: `lib-php`

**Description**: Port [PHP](https://github.com/php/php-src) as a Unikraft library.

**Points**: 25 points

**Links / Resources**:

* [PHP](https://github.com/php/php-src)

## Port Postgres

**Id**: `lib-postgres`

**Description**: Port [Postgres](https://github.com/postgres/postgres) as a Unikraft library.

**Points**: 25 points

**Links / Resources**:

* [Postgres](https://github.com/postgres/postgres)

## Port MySQL

**Id**: `lib-mysql`

**Description**: Port [MySQl](https://github.com/mysql/mysql-server) as a Unikraft library.

**Points**: 25 points

**Links / Resources**:

* [MySQl](https://github.com/mysql/mysql-server)

## Port libevhtp

**Id**: `lib-libevhtp`

**Description**: Port [libevhtp](https://github.com/criticalstack/libevhtp) as a Unikraft library.

**Points**: 20 points

**Links / Resources**:

* [libevhtp](https://github.com/criticalstack/libevhtp)

## Port goaccess

**Id**: `lib-goaccess`

**Description**: Port [goaccess](https://github.com/allinurl/goaccess) as a Unikraft library.

**Points**: 20 points

**Links / Resources**:

* [goaccess](https://github.com/allinurl/goaccess)

## Port Tinyproxy

**Id**: `lib-tinyproxy`

**Description**: Port [Tinyproxy](https://github.com/tinyproxy/tinyproxy) as a Unikraft library.

**Points**: 25 points

**Links / Resources**:

* [Tinyproxy](https://github.com/tinyproxy/tinyproxy)

## Port Bjoern

**Id**: `lib-bjoern`

**Description**: Port [Bjoern](https://github.com/jonashaag/bjoern) as a Unikraft library.

**Points**: 20 points

**Links / Resources**:

* [Bjoern](https://github.com/php/php-src)

## Lua Telnet shell

**Id**: `lua-telnet`

**Description**: Make use of [lib-lua](https://github.com/unikraft/lib-lua) and add telnet server, maybe also adding custom commands.

**Points**: 15 points

**Links / Resources**:

* [lib-lua](https://github.com/unikraft/lib-lua)

## Port Memcached

**Id**: `app-memcached`

**Description**: Port [memcached](https://github.com/memcached/memcached) as a Unikraft application.

**Points**: 15 points

**Links / Resources**:

* [memcached](https://github.com/memcached/memcached)

## Rewrite an Internal Library in Rust

**Id**: `rust-lib`

**Description**: Rewrite an internal Unikraft Library in Rust.

**Points**: 15 points / library

**Links / Resources**:

* [Embedded Rust support in Unikraft](https://github.com/unikraft/unikraft/commit/825b1150f74a2e809341369bc19757560371b418)
