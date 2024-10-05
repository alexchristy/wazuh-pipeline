
<h1 align="center">
  <br>
  <a href="https://ufsit.club/teams/blue.html"><img src="https://raw.githubusercontent.com/alexchristy/wazuh-pipeline/main/assets/img/wazuh-pipeline.png" alt="WazuhTest" width="200"></a>
  <br>
  wazuh-pipeline
  <br>
</h1>

<h4 align="center">A CI pipeline built for <a href="https://wazuh.com" target="_blank">Wazuh</a>.</h4>

<h4 align="center">Link to <a href="https://github.com/alexchristy/wazuh-pipeline" target="_blank">original repository</a>.</h4>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#key-features">Key Features</a></li>
    <li><a href="#quickstart-public">Quickstart</a></li>
    <li><a href="#private-setup">Private Setup</a></li>
    <li>
      <a href="#pipeline-organization">Pipeline Organization</a>
      <ul>
        <li><a href="#decoders-folder">Decoders folder</a></li>
        <li><a href="#rules-folder">Rules folder</a></li>
        <li><a href="#tests-folder">Tests folder</a></li>
      </ul>
    </li>
    <li><a href="#decoder-resolution">Decoder Resolution</a></li>
    <li><a href="#building-containers">Building Containers</a></li>
    <li><a href="#running-locally">Running Locally</a></li>
    <li><a href="#debugging">Debugging</a></li>
    <li><a href="#troubleshooting">Troubleshooting</a></li>
    <li><a href="#related">Related</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>


## Key Features

* Test Decoders
  - Verify that your decoders are extracting info from logs.

* Test Rules
  - Ensure that the correct rules alert on logs.

* Maintain Rulesets Easily

* Catch Errors Early

* Prevent Regression

* Decoder Conflict Resolution
  - Automatically disables default decoders that overlap with custom decoders.

## Quickstart (Public)

1. Fork this repository and only copy the main branch
    
    ![Fork repo button](https://github.com/user-attachments/assets/f6e3dbbc-e7f3-4d79-9d38-3e82511d3bb0)
    
    ![Fork main branch only](https://github.com/user-attachments/assets/90a0ceae-fb0e-42b2-b22c-0d9c836cc724)

2. Configure the three following Action secrets:

    * `DOCKER_IMAGE` - The docker image used for testing. Publicly supported docker image: `alexchristy/wazuh-test-pipeline`
    * `DOCKER_USERNAME` - Username for the docker account pulling the docker image. Ex: `user@example.com`
    * `DOCKER_PASSWORD` - Password for the docker account pulling the docker image.

    ![Visual secret setup](https://github.com/user-attachments/assets/535f8523-6b15-42f8-9adb-57b830a772ec)

3. Enable GitHub Actions

    ![Enable GitHub Actions steps](https://github.com/user-attachments/assets/b89fba97-9aad-40cb-9560-437ad26aaa91)

4. Done!

    You can now start creating pull requests or committing directly to main and see the tests run automatically. However, due to the nature of forked repositories, you repository will always be public. If this is an issue, follow the steps for a private repoistory setup.

## Private Setup

*This section is for the people people who need to run this pipeline in a private repository.*



1. [Create a new private repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository) in GitHub.

    > **Note:** Ensure that the repository is **NOT** initialized with a README.md or any other files.

2. Create a fine-grained [GitHub token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) for the next step.

    The token should only have access to the new private repository we just created.

    Required Repository permissions:
    * Pull requests (Read-only)
    * Metadata (Read-only)
    * Contents (Read-only)

3. Configure the GitHub Action secrets, from step 2 in the [Quickstart](#quickstart-public) and an additional secret called `TOKEN` with the value of the token created in the previous step.

4. Clone this repository.

    ```bash
    git clone --bare https://github.com/alexchristy/wazuh-pipeline
    ```

5. Enter directory.

    ```bash
    cd wazuh-pipeline.git
    ```

5. Add a new remote

    ```bash
    git remote add private {NEW_REPO_URL}
    ```

6. Push main branch to new repository

    ```bash
    git push private main
    ```
    
    >**Note:** If this step is failing ensure that the account you are using has proper access to the new repository.

7. Finished!

    Pushing the main branch will kick off the CI pipeline which should run the default tests. If it passes then the repository is ready for use. If it fails then the repository is not functional and an issue should be filed with the GitHub Action log.

## Pipeline Organization

The pipeline repository has three main folders: `decoders`, `rules`, and `tests`. The `.sh` scripts in the root of repository should **not** be modified unless explicitly trying to change the behavior of the pipeline.

### Decoders folder

Located at `decoders/`, this folder is where you should put all the custom decoder files (`.xml`) that will get automatically installed when the container is run. 

> **Note:** If there is a decoder name in this folder that conflicts/overlaps with a default Wazuh decoder, the default decoder file will be disabled. (See the [Decoder Resolution](#decoder-resolution) section for more information.)

### Rules folder

Located at `rules/`, this folder is where you should put all custom rule files (`.xml`) that will get automatically installed when the container is run.

### Tests folder

Located at `tests/`, this folder is where you should put all of your [WazuhTest](https://github.com/alexchristy/WazuhTest) files (`.json`) and associated raw log files. See the [WazuhTest repository](https://github.com/alexchristy/WazuhTest) for information on test syntax and organization.

> **Note:** If a rule's ID conflicts with an existing/default rule only the first rule definition will be used.

## Decoder Resolution

If a custom decoder name overlaps with an default Wazuh decoder's name, the Wazuh manager will fail to startup. To address this, this pipeline will automatically disable default decoder names that overlap/conflict with custom decoders names.

This can be useful, but it can also break detection logic as the pipeline will exclude entire default decoder files when any conflict with a custom decoder file is detected.

**Example:**

You add the custom [auditd](https://www.redhat.com/sysadmin/configure-linux-auditing-auditd) decoder below to the `decoders/` folder in this pipeline.

`custom_auditd_decoder.xml` contents:

```xml
<decoder name="auditd">
  <prematch>My Special Custom Pattern</prematch>
</decoder>
```

The pipeline scripts will find an overlapping default decoder `0040-auditd_decoders.xml` and disable the entire file. This is because both files contain a decoder with the name `auditd`. As a result of being in the same file, the decoder `auditd-syscall` will also be disabled.

`0040-auditd_decoders.xml` contents:

```xml
<html><body><decoder name="auditd">
  <prematch>^type=</prematch>
</decoder>

<decoder name="auditd-syscall">
  <parent>auditd</parent>
  <prematch offset="after_parent">^SYSCALL </prematch>
  <regex offset="after_parent">^(SYSCALL) msg=audit\(\d\d\d\d\d\d\d\d\d\d.\d\d\d:(\d+)\): </regex>
  <order>audit.type,audit.id</order>
</decoder>

(...)
```

Because of this behavior, it is recommended that when you are modifying default decoders copy the entire original decoder file and make the modifications inside of the copy.

## Building Containers

> *This project maintains a public docker image for ease of use [here](https://hub.docker.com/r/alexchristy/wazuh-test-pipeline).*

If you wish to build your own docker images for the pipeline you can build them using the two Dockerfiles.

**Dockerfiles:**
  - `Dockerfile.auto` - This is the image **used for the pipeline** or other automations.
  - `Dockerfile.live` - This is an interactive image that will run indefinitely after running the pipeline logic. 
    - Mainly used for [debugging](#debugging) or local testing.

**Build image:**

```bash
docker build --no-cache -f Dockerfile.{auto or live} -t local-wazuh-pipeline-image .
```


For the pipeline to work correctly in GitHub you will need to upload your docker image to [Docker Hub](https://hub.docker.com/) and then set the value of the `DOCKER_IMAGE` GitHub Action secret to your new image name.

**Example Image Name:**

Docker Hub image link: `https://hub.docker.com/r/alexchristy/wazuh-test-pipeline`

DOCKER_IMAGE secret value: `alexchristy/wazuh-test-pipeline`

## Running Locally

1. Clone the repository.

    ```bash
    git clone https://github.com/alexchristy/wazuh-pipeline
    ```

2. Enter repository directory.

    ```bash
    cd wazuh-pipeline
    ```

3. Build docker image.

    ```bash
    docker build --no-cache -f Dockerfile.{auto or live} -t local-wazuh-pipeline-image .
    ```

    > Choose the `.live` image if you are trying to debug the container.

4. Run docker container.

    ```bash
    docker run -d --name wazuh-pipeline-container \
    -e REPO_URL={URL_TO_YOUR_REPO} \
    -e BRANCH_NAME=main \
    -e TOKEN={GITHUB_TOKEN_IF_REPO_PRIVATE} \
    local-wazuh-pipeline-image
    ```

## Debugging

The pipeline scripts generate three logs during runtime inside of the `/root/wazuh_pipeline/` directory.

**Logs:**
  - `wazuh_pipeline_script.log` - Human friendly and easily readable log.
  - `wazuh_pipeline_shell.log` - Debug shell logging with done with `set -x`.
  - `wazuh_pipeline_wazuh_test.log` - [WazuhTest](https://github.com/alexchristy/wazuh-pipeline) tool log.

The easiest way to debug the container is to build the interactive image (`Dockerfile.live`) and [run the image locally](#running-locally). The interactive image will execute the pipeline scripts initially and then you can connect and inspect the logs.

## Troubleshooting

### Push Repository not Found

When creating a copy of this pipeline in your own private repository you might run into an error like the one below when trying to push the files to your newly created repo:

```bash
me@hostname:/tmp/wazuh-pipeline.git$ git push private main
remote: Repository not found.
fatal: repository 'https://github.com/myusername/wazuh-pipeline/' not found
```

**Fix Steps:**

1. Create a new SSH key for authenticating to GitHub (or use an exiting one).

2. Add the SSH key to your GitHub account ([GitHub Documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)).

3. Add the SSH key to your SSH client. On Ubuntu:

    ```bash
    ssh-add /path/to/ssh_key
    ```

4. Add configuration for the new SSH key. On Ubuntu, edit or create `~/.ssh/config`:

    ```txt
    Host github.com
      HostName github.com
      User git
      IdentityFile /path/to/ssh_key
    ```

5. Change to the remote URL for the repo clone:

    ```bash
    git remote remove private
    git remote add git@github.com:$MY_USERNAME/$REPO_NAME.git
    git push private main
    ```

### Pipeline Could not Read Username

This error causes the pipeline step named `Run container with branch and repo info` to fail on the first run. Usually this happens after pushing the copied files to your **private** repository. The error in the pipeline log will say something like:

```txt
Cloning repository without token
Cloning into '/root/wazuh_pipeline'...
fatal: could not read Username for 'https://github.com': No such device or address
Could not cd in repo directory. The repo was likely not cloned properly!
If this is a private repo, make sure to include a GitHub token.
/root/init.sh: line 17: cd: /root/wazuh_pipeline: No such file or directory
Error: Process completed with exit code 1.
```

This happens because the pipeline does not have the `TOKEN` secret configured, so it assumes that your Wazuh pipeline repository that you created is public.

**Fix Steps:**

1. Create a fine-grained GitHub token for accessing this repository following **Step 2** in the [Private Setup](#private-setup) section. Save this value for the next step.

2. Navigate to `Settings > Secrets and variables > Actions`.

3. Create a new repository secret called `TOKEN` with the value of the GitHub fine-grained token you created earlier.

4. Navigate to `Actions` and click the failed workflow run. (Usually there is only one run)

5. In the top right, click `Re-run jobs`, then click `Re-run all jobs`

6. On the pop up click the green button `Re-run job`

7. The pipeline should completed successfully.

*If this did not work, look at other sections in the [Troubleshooting](#troubleshooting) section for other solutions.*

## Related

[wazuh-pipeline](https://github.com/alexchristy/wazuh-pipeline) - Wazuh CI pipeline that leverages this tool

## License

GNU General Public License v3.0
