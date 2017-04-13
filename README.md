# cf-suse-stacks-ci

This repository contains the [concourse] pipeline required to build the [SUSE
stack for Cloud Foundry].  The output is a tar file (and associated manifest)
that is meant to be imported via something along the lines of 
[cflinuxfs2-release].  The tar file is uploaded to some S3-compatible storage.

[concourse]: https://concourse.ci/
[SUSE stack for Cloud Foundry]: https://github.com/SUSE/cf-suse-stacks
[cflinuxfs2-release]: https://github.com/cloudfoundry/cflinuxfs2-release

## Deployment

1. Fill out a `secrets.yml` following the the outline of
[`secrets-template.yml`]
2. Target [fly] at your concourse install:
    > `fly -t cc login -c http://concourse.example`

3. Deploy the pipeline:
    > `fly -t cc set-pipeline -p cf-suse-stacks -c cf-suse-stacks.yml -l secrets.yml`

4. Start the pipeline:
    > `fly -t cc unpause-pipeline -p cf-suse-stacks`

[fly]: http://concourse.ci/fly-cli.html
[`secrets-template.yml`]: secrets.template.yml