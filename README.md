# Unikraft Summer of Code (2021)

**Unikraft Summer of Code is a Unikernel and library Operating Systems workshop
held by members of the Unikraft community** including professors, lecturers and
PhD students from University POLITEHNICA of Bucharest, Lancaster University,
Manchester University and industry partners NEC Laboratories Europe GmbH.

In this **free** two week event, you will learn about how to build Unikraft
unikernels, including zero-to-hero workshops on how to get started using
Unikraft. As the week progresses, we will dive into more in-depth topics of
Unikraft, including programming structures and architectures, how it is
organized, methodologies for porting libraries and applications to Unikraft and
more!

The workshop will be hands-on and will take place for 10 days, between August 23
and September 3, 2021, 4pm-8pm CEST.  And an 8 hours hackathon on September 4,
2021, 9am-5pm CEST.  It will be online and in English. Topics include building
unikernels, benchmarking, debugging, porting applications, virtualization and
platform specifics.

## Running the website locally

Building and running the site locally requires a recent `extended` version of
[Hugo](https://gohugo.io). You can find out more about how to install Hugo for
your environment in our [Getting
started](https://www.docsy.dev/docs/getting-started/#prerequisites-and-installation)
guide.

Once you've made your working copy of the site repo, from the repo root folder, run:

```
hugo server
```

## Running a container locally

You can run docsy-example inside a [Docker](https://docs.docker.com/) container,
the container runs with a volume bound to the `docsy-example` folder. This
approach doesn't require you to install any dependencies other than [Docker
Desktop](https://www.docker.com/products/docker-desktop) on Windows and Mac, and
[Docker Compose](https://docs.docker.com/compose/install/) on Linux.

1. Build the docker image 

   ```bash
   docker-compose build
   ```

1. Run the built image

   ```bash
   docker-compose up
   ```

   > NOTE: You can run both commands at once with `docker-compose up --build`.

1. Verify that the service is working. 

   Open your web browser and type `http://localhost:1313` in your navigation bar,
   This opens a local instance of the docsy-example homepage. You can now make
   changes to the docsy example and those changes will immediately show up in your
   browser after you save.

### Cleanup

To stop Docker Compose, on your terminal window, press **Ctrl + C**. 

To remove the produced images run:

```console
docker-compose rm
```
For more information see the [Docker Compose
documentation](https://docs.docker.com/compose/gettingstarted/).

## Troubleshooting

As you run the website locally, you may run into the following error:

```
➜ hugo server

INFO 2021/01/21 21:07:55 Using config file: 
Building sites … INFO 2021/01/21 21:07:55 syncing static files to /
Built in 288 ms
Error: Error building site: TOCSS: failed to transform "scss/main.scss" (text/x-scss): resource "scss/scss/main.scss_9fadf33d895a46083cdd64396b57ef68" not found in file cache
```

This error occurs if you have not installed the extended version of Hugo.
See our [user guide](https://www.docsy.dev/docs/getting-started/) for instructions on how to install Hugo.

