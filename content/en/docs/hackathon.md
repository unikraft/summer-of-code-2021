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

Points listed in challenges are a rough indication of difficulty.
It is possible to solve more than one challenge and earn all points from all challenges solved.

Additional points will be awarded for:

* Signing off your commits with `git commit -s`, as part of [Developer Certificate of Origin](https://en.wikipedia.org/wiki/Developer_Certificate_of_Origin) (1 point per commit) (note, teams of multiple people should have multiple sign-offs);
* Every commit should include a precise explanation of the changes made (1 point per commit);
* Every commit of the solution should leave the project in a working state (2 points per commit).

## Challenges

### 1. New `uktest` Suites, Cases & Expectations

| ID | Points | Short description |
|----|--------|-------------------|
| `uktest-entries` | 1 point per `*EXPECT*` | Use [uktest](/docs/sessions/06-testing-unikraft/#03-unikrafts-testing-framework.md) to add new tests in Unikraft components. |

#### Description

In this challenge, introduce new test suites, cases and assertions/expects in the Unikraft core repository.
New tests should be introduced as new files under a new directory `tests/` of internal microlibraries.
For example, for `vfscore`, a new directory will be located at `libs/vfscore/tests/`.

To create a suite, such as for `stat()` in `vfscore`, introduce a new file `test_stat.c` where you register the suite, cases and create expectations from the `stat()` syscall provided by `vfscore`.
Expectations and tests can usually be checked by programming different scenarios and checking whether the return code or `errno` is set correctly.
Check out the relevant POSIX document for the function in question.

Every new `*_EXPECT_*` test assertion will receive 1 point.

#### Links and Additional Resources

* [uktest](docs/sessions/06-testing-unikraft/#03-unikrafts-testing-framework.md): Unikraft's testing framework


---


### 2. Fix Build Warnings

| ID | Points | Short description |
|----|--------|-------------------|
| `fix-warnings` | 1 point per warning | Fix build warnings in Unikraft components. |

#### Description

In this challenge, fix compiler warnings during builds of internal Unikraft libraries.
(There may be other warnings in other Unikraft repositories.)

Every warning (1 line) will receive 1 point.

#### Links and Additional Resources

* [Issue on Unikraft build warnings](https://github.com/unikraft/unikraft/issues/242)


---


### 3. Add ukstore Entries

| ID | Points | Short description |
|----|--------|-------------------|
| `ukstore-entries` | 1 point per entry | Add new [ukstore](https://github.com/unikraft/unikraft/pull/275) entries. |

#### Description

`ukstore` is a new internal library for storing and retrieving information, such as statistics or state.
Introduce new counters, stats, or states via `ukstore` in other libraries that generate information.

#### Links and Additional Resources

* [ukstore](https://github.com/unikraft/unikraft/pull/275) Library
* [Example of adding new `ukstore` entries related to `ukalloc`](https://github.com/unikraft/unikraft/pull/279/commits/0d659369abf0b6c841c36cf0981ac8258b5630da)
* [Example of adding new counters to `uknetdev`](https://github.com/unikraft/unikraft/pull/226)
* [Document explaining `ukstore` usage (chapters 1. and 3.)](https://docs.google.com/document/d/1g50nGvjiQDCHwdLUZNco9XsBGCfiKkqjcYckTSgC7fk/edit?usp=sharing)

---


### 3. Add new unit tests to `kraft`

| ID | Points | Short description |
|----|--------|-------------------|
| `kraft-unit-tests` | 1 point per test | Add new tests in [kraft](https://github.com/unikraft/kraft). |

#### Description

`kraft` is a Python-based toolchain and acts as the companion tool for managing, configuring, building and running Unikraft unikernels.
It has very limited unit tests.
In this challenge, add more unit tests to `kraft`

#### Links and Additional Resources

* [kraft repository](https://github.com/unikraft/kraft)
* [kraft tests folder](https://github.com/unikraft/kraft/tree/staging/tests)


---


### 4. Run Django on Unikraft

| ID | Points | Short description |
|----|--------|-------------------|
| `app-django` | 10 points | Run [Django](https://www.djangoproject.com/) on top of [lib-python3](https://github.com/unikraft/lib-python3). |

#### Description

Create a new Python 3 application based on the [Django](https://www.djangoproject.com/) web framework.
Serve a simple HTTP response and run this via [lib-python3](https://github.com/unikraft/lib-python3).
Create a relevant `kraft.yaml` file with corresponding required KConfig values.
A user should be able to run the project via:

```bash
kraft list add https://github.com/$USERNAME/app-django.git
kraft list update
kraft init -t django@staging ./my-django-app
```

#### Links and Additional Resources

* [Django](https://www.djangoproject.com/)
* [app-python3](https://github.com/unikraft/app-python3)
* [lib-python3](https://github.com/unikraft/lib-python3)
* [Session 04: Complex Applications](/docs/sessions/04-complex-applications/)


---


### 5. Run Flask on Unikraft

| ID | Points | Short description |
|----|--------|-------------------|
| `app-flask` | 10 points  | Run [Flask](https://flask.palletsprojects.com/en/2.0.x/) on top of [lib-python3](https://github.com/unikraft/lib-python3) |

#### Description

Create a new Python 3 application based on the [Flask](https://flask.palletsprojects.com/en/2.0.x/) web framework.
Serve a simple HTTP response and run this via [lib-python3](https://github.com/unikraft/lib-python3).
Create a relevant `kraft.yaml` file with corresponding required KConfig values.
A user should be able to run the project via:

```bash
kraft list add https://github.com/$USERNAME/app-flask.git
kraft list update
kraft init -t flask@staging ./my-flask-app
```


#### Links and Additional Resources

* [Flask](https://flask.palletsprojects.com/en/2.0.x/)
* [app-python3](https://github.com/unikraft/app-python3)
* [lib-python3](https://github.com/unikraft/lib-python3)
* [Session 04: Complex Applications](/docs/sessions/04-complex-applications/)


---


### 6. Run Ruby on Rails on Unikraft

| ID | Points | Short description |
|----|--------|-------------------|
| `app-rails` | 15 points | Run [Ruby on Rails](https://rubyonrails.org/) on top of [lib-ruby](https://github.com/unikraft/lib-ruby/). |

#### Description

Create a new Ruby application based on the [Ruby on Rails](https://rubyonrails.org/) web framework.
Serve a simple HTTP response and run this via [lib-ruby](https://github.com/unikraft/lib-ruby).
Create a relevant `kraft.yaml` file with corresponding required KConfig values.
A user should be able to run the project via:

```bash
kraft list add https://github.com/$USERNAME/app-rails.git
kraft list update
kraft init -t rails@staging ./my-rails-app
```

#### Links and Additional Resources

* [Rails](https://rubyonrails.org/)
* [app-ruby](https://github.com/unikraft/app-ruby/)
* [lib-ruby](https://github.com/unikraft/lib-ruby/)
* [Session 04: Complex Applications](/docs/sessions/04-complex-applications/)


---


### 7. Port PHP to Unikraft

| ID | Points | Short description |
|----|--------|-------------------|
| `lib-php` | 25 points | Port [PHP](https://github.com/php/php-src) as a Unikraft library. |

#### Description

Port the interpreted language runtime [PHP](https://github.com/php/php-src) so it can be run on top of Unikraft.
Create a matching application component, so a simple PHP program can be run via Unikraft.
A user should be able to run the project via:

```bash
kraft list add https://github.com/$USERNAME/app-php.git
kraft list update
kraft init -t php@staging ./my-php-app
```

#### Links and Additional Resources

* [PHP source code](https://github.com/php/php-src)
* [PHP main website](https://www.php.net/)
* [Session 08: Basic App Porting](/docs/sessions/08-basic-app-porting/)


### 8. Port Postgres to Unikraft

| ID | Points | Short description |
|----|--------|-------------------|
| `lib-postgres` | 25 points | Port [Postgres](https://github.com/postgres/postgres) as a Unikraft library. |

#### Description

Port the object-relational database program [Postgres](https://www.postgresql.org/) so it can run as a Unikraft unikernel.
Create a matching application component.
A user should be able to run the project via:

```bash
kraft list add https://github.com/$USERNAME/app-postgres.git
kraft list update
kraft init -t postgres@staging ./my-postgres-app
```

#### Links and Additional Resources

* [Postgres source code](https://github.com/postgres/postgres)
* [Postgres main website](https://www.postgresql.org/)
* [Session 08: Basic App Porting](/docs/sessions/08-basic-app-porting/)


---


### 9. Port MySQL to Unikraft

| ID | Points | Short description |
|----|--------|-------------------|
| `lib-mysql` | 25 points| Port [MySQL](https://github.com/mysql/mysql-server) as a Unikraft library. |


#### Description

Port the relational database program [MySQL](https://www.mysql.com/) so it can run as a Unikraft unikernel.
Create a matching application component.
A user should be able to run the project via:

```bash
kraft list add https://github.com/$USERNAME/app-mysql.git
kraft list update
kraft init -t mysql@staging ./my-mysql-app
```

#### Links and Additional Resources

* [MySQL source code](https://github.com/mysql/mysql-server)
* [MySQL main website](https://www.mysql.com/)
* [Session 08: Basic App Porting](/docs/sessions/08-basic-app-porting/)


---


### 10. Port Tinyproxy to Unikraft

| ID | Points | Short description |
|----|--------|-------------------|
| `lib-tinyproxy` | 25 points | Port [Tinyproxy](https://github.com/tinyproxy/tinyproxy) as a Unikraft library. |

#### Description

[Tinyproxy](https://github.com/tinyproxy/tinyproxy) is a fast HTTP/HTTPS server.
Port this as a new library and application to Unikraft.
A user should be able to run the project via:

```bash
kraft list add https://github.com/$USERNAME/app-tinyproxy.git
kraft list update
kraft init -t tinyproxy@staging ./my-tinyproxy-app
```

#### Links and Additional Resources

* [Tinyproxy source code](https://github.com/tinyproxy/tinyproxy)
* [Session 08: Basic App Porting](/docs/sessions/08-basic-app-porting/)


---


### 11. Port Bjoern to Unikraft

| ID | Points | Short description |
|----|--------|-------------------|
| `lib-bjoern` | 25 points | Port [Bjoern](https://github.com/jonashaag/bjoern) as a Unikraft library. |

#### Description

[Bjoern](https://github.com/jonashaag/bjoern) is a fast And ultra-lightweight HTTP/1.1 WSGI Server.
Port this as a new library and application to Unikraft.
A user should be able to run the project via:

```bash
kraft list add https://github.com/$USERNAME/app-bjoern.git
kraft list update
kraft init -t bjoern@staging ./my-bjoern-app
```

#### Links and Additional Resources

* [Bjoern source code](https://github.com/jonashaag/bjoern)
* [Session 08: Basic App Porting](/docs/sessions/08-basic-app-porting/)


---


### 12. Lua Telnet shell


| ID | Points | Short description |
|----|--------|-------------------|
| `lua-telnet` | 10 points | Make use of [lib-lua](https://github.com/unikraft/lib-lua) and add telnet server |


#### Description

[Telnet](https://en.wikipedia.org/wiki/Telnet) is a protocol for doing bi-directional text communication.
Create a simple telnet server on top of the Lua language and run it on Unikraft.

#### Links and Additional Resources

* [app-lua](https://github.com/unikraft/app-lua)
* [lib-lua](https://github.com/unikraft/lib-lua)
* [lib-lwip](https://github.com/unikraft/lib-lwip)
* [Session 04: Complex Applications](/docs/sessions/04-complex-applications/)


---


### 13. Port Memcached to Unikraft

| ID | Points | Short description |
|----|--------|-------------------|
| `lib-memcached` | 25 points | Port [memcached](https://github.com/memcached/memcached) as a Unikraft library. |

#### Description

[memcached](https://memcached.org/) is a general purpose key-value store.
Port this as a new library and application to Unikraft.
A user should be able to run the project via:

```bash
kraft list add https://github.com/$USERNAME/app-memcached.git
kraft list update
kraft init -t memcached@staging ./my-memcached-app
```


#### Links and Additional Resources

* [memcached source code](https://github.com/memcached/memcached)
* [memcached main website](https://memcached.org/)

---


### 14. Rewrite a Unikraft Internal Library in Rust

| ID | Points | Short description |
|----|--------|-------------------|
| `internal-rust` | 25 points per library | Rewrite an internal Unikraft Library in Rust. |

#### Description

Rust is proving itself to be a type-safe, fast language suitable for the kernel.
Use the [newly added capabilities of compiling Rust with Unikraft](https://github.com/unikraft/unikraft/commit/825b1150f74a2e809341369bc19757560371b418) to re-write an [internal library](https://github.com/unikraft/unikraft/tree/staging/lib).
A successful port of an internal library, e.g. `vfscore` to `vfscore-rs`, should work as the original is expected.

Additional points will be awarded for benchmarks.


#### Links and Additional Resources

* [Embedded Rust support in Unikraft](https://github.com/unikraft/unikraft/commit/825b1150f74a2e809341369bc19757560371b418)


---


### 15. Port PicoTCP to Unikraft

| ID | Points | Short description |
|----|--------|-------------------|
| `lib-picotcp` | 25 points | Port [PicoTCP](https://github.com/tass-belgium/picotcp) to Unikraft. |

#### Description

PicoTCP is a TCP/IP stack written in C.
Port this as an alternative to [LwIP](https://github.com/unikraft/lib-lwip) so it can be used with other network-based applications built with Unikraft.
A successful port will allow the user to replace LwIP completely with PicoTCP.

#### Links and Additional Resources

* [PicoTCP source code](https://github.com/tass-belgium/picotcp)
* [lib-lwip](https://github.com/unikraft/lib-lwip)
* [Session 04: Complex Applications](/docs/sessions/04-complex-applications/)


---


### 16. Fix an Open Bug in the Core

| ID | Points | Short description |
|----|--------|-------------------|
| `bug-fix` | Depends on bug, contact TA. | Fix an internal bug in the core. |

#### Description

There are a number of outstanding issues/bugs with the Unikraft core repository.
To help increase the stability and solve problems for edge cases and other issues, solve an open issue that has been reported.

#### Links

 * [List of open bugs](https://github.com/unikraft/unikraft/issues?q=is%3Aissue+is%3Aopen+label%3Akind%2Fbug)
