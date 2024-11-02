# Territory.dev Build Configuration

This repo contains configurations and scripts used to prepare codebases
for indexing by [territory.dev](https://territory.dev).

# Anatomy of a Territory.dev build

## Step 1: Clone

We fetch the latest revision of a tracked branch.

## Step 2: Prepare

The preparation step varies by language:
- For C/C++, we need to generate a compilation database and ensure all source files are present
- For Go, we need to ensure all dependencies are downloaded and module information is available

At the end of the prepare step we run the Territory client in offline mode
(with the `--tarball-only` flag) to package code into a `territory_upload.tar.gz`
archive.

We run a "prepare" script to ensure that. The script runs in an isolated
Docker container that can be customized with whatever requirements the repository needs.

## Step 3: Parse

In the same environment, we use language-specific parsers to scan code in
the repo. For C/C++, this uses the clang library. For Go, we use Go's native
parsing facilities. Results are passed to an indexer.

## Step 4: Index

We generate a code graph using our proprietary indexer.

# How to add a build for your repo?

We need 2 files:

- repo.yml describing what to build
- prepare.sh script to handle language-specific preparation

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
| lang        | "c" or "go"     | Repository language. Determines which parser will be used. |

Here is an example of configuration for the LLVM repo:

```yaml
# C/C++ example (LLVM)
name: llvm
origin: https://github.com/llvm/llvm-project.git
branches:
  - main
image: flavor-llvm:main
lang: c
```


## Language-Specific Preparation

### C/C++ Projects

For C/C++ projects, we need to generate a `compile_commands.json` compilation database
file. There are several ways to accomplish this:

#### Using Build System Facilities

##### CMake

CMake can generate `compile_commands.json` for you. Set the
[CMAKE_EXPORT_COMPILE_COMMANDS](https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html)
environment variable to enable that feature.

#### Using Build Capture Tools

##### fakecc

We built [fakecc](https://github.com/territory-dev/fakecc) as a simple
way to capture compile commands executed during a build while avoiding
unnecessary work.

Here's an example from the CPython build config. We pre-install
fakecc in the [Docker image](./images/flavor-cpython/Dockerfile):

```dockerfile
RUN \
  python3 -m venv /var/lib/venv &&\
  /var/lib/venv/bin/pip install -e git+https://github.com/territory-dev/fakecc.git#egg=fakecc
```

Then, in the [prepare stage](./repos/cpython/prepare.sh) we wrap
the call to `make` in `fakecc run`:

```sh
#!/bin/bash
set -xeuo pipefail

export CC="clang"
export CCX="clang++"

./configure

source /var/lib/venv/bin/activate
export FAKECC_SOCK=/tmp/fakecc.sock
fakecc run make -j${CORES:-8} --ignore-errors || :

territory upload --tarball-only -l c
```

##### Bear

[Bear](https://github.com/rizsotto/Bear) is another tool for capturing
`compile_commands.json` from a build.

### Go Projects

Territory.dev Go parser will scan modules in your repo.  The prepare
step usually ensures that all dependencies are installed and the
GO paths are set correctly, then runs the territory client.  See
the example of a Kubernetes repo build:


```sh
#!/bin/bash
set -xeuo pipefail

export GOGC=2000
make
territory upload --tarball-only -l go --system
```

## Build environments

The prepare script run in a docker container. You can
provide a docker image suitable for your repository.

See the [Dockerfile](images/flavor-vanilla/Dockerfile)
in `images/flavor-vanilla` for a generic base and other
dockerfiles in this repo for examples.


### Limitations

The build container has limited internet connectivity.  You might want
to bake required dependencies for your repo into the container.

Scripts will run as the `territory` user with UID 2000.

# Build logs

Build logs can be inspected in the [in-app builds page](https://app.territory.dev/builds).
