# v0.1.3 (Sat Oct 05 2024)

#### ⚠️ Pushed to `main`

- Add release config section to README ([@alexchristy](https://github.com/alexchristy))

#### Authors: 1

- Alex Christy ([@alexchristy](https://github.com/alexchristy))

---

# v0.1.2 (Sat Oct 05 2024)

#### ⚠️ Pushed to `main`

- Add PR template ([@alexchristy](https://github.com/alexchristy))

#### Authors: 1

- Alex Christy ([@alexchristy](https://github.com/alexchristy))

---

# v0.1.1 (Sat Oct 05 2024)

#### ⚠️ Pushed to `main`

- Revert from broken commit to main ([@alexchristy](https://github.com/alexchristy))
- Test broken commit to main ([@alexchristy](https://github.com/alexchristy))

#### Authors: 1

- Alex Christy ([@alexchristy](https://github.com/alexchristy))

---

# v0.1.0 (Sat Oct 05 2024)

#### 🚀 Enhancement

- Only create releases when tests pass on main branch [#10](https://github.com/alexchristy/wazuh-pipeline/pull/10) ([@alexchristy](https://github.com/alexchristy))

#### Authors: 1

- Alex Christy ([@alexchristy](https://github.com/alexchristy))

---

# v0.0.1 (Sat Oct 05 2024)

#### 🐛 Bug Fix

- Added extra correct decoder information [#3](https://github.com/alexchristy/wazuh-pipeline/pull/3) ([@alexchristy](https://github.com/alexchristy))

#### ⚠️ Pushed to `main`

- Add release workflow ([@alexchristy](https://github.com/alexchristy))
- README minor grammar fixes ([@alexchristy](https://github.com/alexchristy))
- Update README Quickstart to use templating ([@alexchristy](https://github.com/alexchristy))
- Bump docker/login-action to v3 ([@alexchristy](https://github.com/alexchristy))
- Bump actions/checkout to version 4 ([@alexchristy](https://github.com/alexchristy))
- Update README with common issue solutions ([@alexchristy](https://github.com/alexchristy))
- Key features typo fix ([@alexchristy](https://github.com/alexchristy))
- Add pipeline organization section ([@alexchristy](https://github.com/alexchristy))
- Move to foldable table of contents ([@alexchristy](https://github.com/alexchristy))
- Add supporting sections to README ([@alexchristy](https://github.com/alexchristy))
- Add decoder resolution behavior to README ([@alexchristy](https://github.com/alexchristy))
- Fix README tabbing ([@alexchristy](https://github.com/alexchristy))
- Add inital README ([@alexchristy](https://github.com/alexchristy))
- Simplify git update process ([@alexchristy](https://github.com/alexchristy))
- Remove duplicate repo cloning ([@alexchristy](https://github.com/alexchristy))
- Switch to pull ([@alexchristy](https://github.com/alexchristy))
- More descriptive error message for common repo close fail ([@alexchristy](https://github.com/alexchristy))
- Reset back to /root in interactive docker image ([@alexchristy](https://github.com/alexchristy))
- Reset back to /root as cwd ([@alexchristy](https://github.com/alexchristy))
- Ignore no username error from git ([@alexchristy](https://github.com/alexchristy))
- Add logic to handle private repos ([@alexchristy](https://github.com/alexchristy))
- Add extra debugging statements to init.sh ([@alexchristy](https://github.com/alexchristy))
- Rename github token secret ([@alexchristy](https://github.com/alexchristy))
- Add support for private GitHub repositories ([@alexchristy](https://github.com/alexchristy))
- Add project logo ([@alexchristy](https://github.com/alexchristy))
- Repo cloned at docker runtime to prevent leaking private wazuh rules and decoders ([@alexchristy](https://github.com/alexchristy))
- Ensure that test results are outputted to stdout ([@alexchristy](https://github.com/alexchristy))
- Fix wazuh test exit code check ([@alexchristy](https://github.com/alexchristy))
- Update dockerfiles ([@alexchristy](https://github.com/alexchristy))
- Fix interactive mode ([@alexchristy](https://github.com/alexchristy))
- Fix logic that extracts ref branch ([@alexchristy](https://github.com/alexchristy))
- Rename CI pipeline ([@alexchristy](https://github.com/alexchristy))
- Add logic to check branches based on trigger of CI pipeline ([@alexchristy](https://github.com/alexchristy))
- Add sample CI configuration for PRs ([@alexchristy](https://github.com/alexchristy))
- Remove purposely invalid key ([@alexchristy](https://github.com/alexchristy))
- Exit successfully if all tests complete and pass ([@alexchristy](https://github.com/alexchristy))
- Run WazuhTest in cli mode ([@alexchristy](https://github.com/alexchristy))
- Fixed missing remote repo url ([@alexchristy](https://github.com/alexchristy))
- More debug git statements ([@alexchristy](https://github.com/alexchristy))
- Add debug statements ([@alexchristy](https://github.com/alexchristy))
- Add early exiting for main.sh ([@alexchristy](https://github.com/alexchristy))
- Remove log message breaking count_logical_cpus output ([@alexchristy](https://github.com/alexchristy))
- Save WazuhTest output and send results to stdout ([@alexchristy](https://github.com/alexchristy))
- Add starter tests that work out of the box with no custom rules or decoders ([@alexchristy](https://github.com/alexchristy))
- Add pipeline repo variable to main to allow it to find initial scripts ([@alexchristy](https://github.com/alexchristy))
- Add script to pull down new updates each time container is started ([@alexchristy](https://github.com/alexchristy))
- Important constants ([@alexchristy](https://github.com/alexchristy))
- Switch main echo logs to logging functions ([@alexchristy](https://github.com/alexchristy))
- Split functions into different files ([@alexchristy](https://github.com/alexchristy))
- Break up scripts into smaller components ([@alexchristy](https://github.com/alexchristy))
- Add helpful comment for dockerfile variable change ([@alexchristy](https://github.com/alexchristy))
- Add steps to clone and build WazuhTest ([@alexchristy](https://github.com/alexchristy))
- Fix early exit bug ([@alexchristy](https://github.com/alexchristy))
- Exit early if no decoders or rules are provided ([@alexchristy](https://github.com/alexchristy))
- Ensure decoder exclusions have proper tabbing ([@alexchristy](https://github.com/alexchristy))
- Prevent adding decoder exclusion lines if they already exist ([@alexchristy](https://github.com/alexchristy))
- Prevent container from exiting once scripts finish ([@alexchristy](https://github.com/alexchristy))
- Split dependency and git into seperate commands ([@alexchristy](https://github.com/alexchristy))
- Start wazuh server before running other scripts ([@alexchristy](https://github.com/alexchristy))
- Create entrypoint for docker container ([@alexchristy](https://github.com/alexchristy))
- Increase total delay ([@alexchristy](https://github.com/alexchristy))
- Increase delay and attempts ([@alexchristy](https://github.com/alexchristy))
- Add start delay script ([@alexchristy](https://github.com/alexchristy))
- Exit with an error if we are not able to sucessfully restart wazuh manager ([@alexchristy](https://github.com/alexchristy))
- Remove problematic placeholder files ([@alexchristy](https://github.com/alexchristy))
- Set correct permissions for config file after adding decoder exclusions ([@alexchristy](https://github.com/alexchristy))
- Insert the lines before the closing ruleset tag ([@alexchristy](https://github.com/alexchristy))
- Add decoder exclusion lines to the main ruleset tag ([@alexchristy](https://github.com/alexchristy))
- Use tempfiles to prevent using for loops ([@alexchristy](https://github.com/alexchristy))
- Fix incorrect bool int comparison ([@alexchristy](https://github.com/alexchristy))
- Fix decoder line splitting ([@alexchristy](https://github.com/alexchristy))
- Remove while statements ([@alexchristy](https://github.com/alexchristy))
- Mostly complete logic for custom ruleset and decoder installation ([@alexchristy](https://github.com/alexchristy))
- Use run_command for early verbose exit on one off commands ([@alexchristy](https://github.com/alexchristy))
- Add restart for wazuh server ([@alexchristy](https://github.com/alexchristy))
- Add rules and decoders for testing ([@alexchristy](https://github.com/alexchristy))
- Rename script more appropriately ([@alexchristy](https://github.com/alexchristy))
- Initial commit ([@alexchristy](https://github.com/alexchristy))

#### Authors: 1

- Alex Christy ([@alexchristy](https://github.com/alexchristy))
