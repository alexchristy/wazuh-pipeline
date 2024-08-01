
<h1 align="center">
  <br>
  <a href="https://ufsit.club/teams/blue.html"><img src="https://raw.githubusercontent.com/alexchristy/wazuh-pipeline/main/assets/img/wazuh-pipeline.png" alt="WazuhTest" width="200"></a>
  <br>
  wazuh-pipeline
  <br>
</h1>

<h4 align="center">A CI pipeline built for <a href="https://wazuh.com" target="_blank">Wazuh</a>.</h4>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#quickstart-public">Quickstart</a> •
  <a href="#private-setup">Private Setup</a> •
  <a href="#decoder-resolution">Decoder Resolution</a> •
  <a href="#related">Related</a> •
  <a href="#license">License</a>
</p>

## Key Features

* Test Decoders
  - Verify that your decoders are extracting info from logs.

* Test Rules
  - Ensure that the correct rules alert on logs.

* Maintain Rulesets Easily

* Catch Errors Early

* Prevent Regression

* Decoder Confligt Resolution
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

7. Finished!

    Pushing the main branch will kick off the CI pipeline which should run the default tests. If it passes then the repository is ready for use. If it fails then the repository is not functional and an issue should be filed with the GitHub Action log.

    >**Note:** If this step is failing ensure that the account you are using has proper access to the new repository.

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

## Related

[wazuh-pipeline](https://github.com/alexchristy/wazuh-pipeline) - Wazuh CI pipeline that leverages this tool

## License

GNU General Public License v3.0
