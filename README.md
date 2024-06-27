This repo contains configurations and scripts used to prepare codebases
for indexing by [territory.dev](https://territory.dev).


# Anatomy of a Territory.dev build

## Step 1: Clone

We fetch the latest revision of a tracked branch.

## Step 2: Prepare

To index properly, all the source files and a `compile_commands.json`
file need to be present.  We run a "prepare" script to do whatever
needs to be done to ensure that.  The script runs in an isolated
Docker container that can be customized with whatever requirements
the repository needs.

## Step 3: Parse

In the same environment we use the clang library to scan code in
the repo.  Results are passed to an indexer.

## Step 4: Index

We generate a code graph using our proprietary indexer.


# How to add a build for your repo?

We need 2 files:

- repo.yml describing what to build
- prepare.sh script to generate a compilation database file (`compile_commands.json`)

You also need to choose a Docker image that will serve as the environment for
the Prepare and Parse steps.

## Repository specification file: repo.yml

Indexing configuration is determined by `repos/*/repo.yml` YAML files.
The YAML encodes an object with the following fields:

| Field       | Type            | Description                                  |
|  ---        |   ---           |  ---                                         |
| name        | string          | Display name of the repository.              |
| origin      | string          | URL of the git repository. Must be HTTPS.    |
| image       | string          | Docker image to use for building.  Either name of one of the pre-built flavors or a full path to an image in a docker repository.  |
| env         | object          | Environment variables passed to the build.   |
| prepare     | string          | Path to prepare script. Defaults to prepare.sh in same directory.  |
| branches    | list of strings | Which branches to index.                     |

Here is an example of configuration for the LLVM repo:

```yaml
name: llvm
origin: https://github.com/llvm/llvm-project.git
branches:
  - main
image: flavor-llvm:main
```

## How do I generate `compile_commands.json`?

We need a `prepare.sh` script to generate the compilation database
file (and potentially any source files to index that are not in the repo).
How to do that depends on the build system you use.

### Use your build tool's facilities

#### CMake

CMake can generate `compile_commands.json` for you.  Set the
[CMAKE_EXPORT_COMPILE_COMMANDS](https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html)
environment variable to enable that feature.

### Use a build capture tool

#### fakecc

We built [fakecc](https://github.com/territory-dev/fakecc) as a simple
way to capture compile commands executed during a build while avoiding
unnnecessary work.

Let's take a look at the CPython build config.  We pre-install
fakecc in the [Docker image](./images/flavor-cpython/Dockerfile):

```dockerfile
RUN \
  python3 -m venv /var/lib/venv &&\
  /var/lib/venv/bin/pip install -e git+https://github.com/territory-dev/fakecc.git#egg=fakecc
```

Then, in the [prepare stage](./repos/cpython/prepare.sh) we wrap
the call to `make` in `fakecc run`.  This will capture arguments to
`clang` every time `make` executes it and save them to `compile_commands.json`.

```sh
#!/bin/bash
set -xeuo pipefail

export CC="clang"
export CCX="clang++"

./configure

source /var/lib/venv/bin/activate
export FAKECC_SOCK=/tmp/fakecc.sock
fakecc run make -j${CORES:-8} --ignore-errors || :
```


#### Bear

[Bear](https://github.com/rizsotto/Bear) is another tool for capturing
`compile_commands.json` from a build.


## Build environments

The prepare script and parser run in a docker container.  You can
provide a docker image suitable for your repository.

See the [Dockerfile](images/flavor-vanilla/Dockerfile)
in `images/flavor-vanilla` for a generic base.

### Requirements

Since our parser executes within the container, libclang 18 must be present.

### Limitations

The build container is disconnected from the Internet.  Any requirements
your prepare script needs have to be provided in the docker image.

Scripts will run as the `territory` user with UID 2000.


# Build logs

Build logs can be inspected in the [in-app builds page](https://app.territory.dev/builds).
