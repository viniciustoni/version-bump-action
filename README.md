# Maven Version Bump Action

A simple GitHub Actions to bump the version of Gradle & Maven projects.

When triggered, this action will look at the commit message of HEAD~1 and determine if it contains one of `#major`, `#minor`, or `#patch` (in that order of precedence).
If true, it will use Maven/sed to bump your pom's version/Gradle build's by the X.x.x major, x.X.x minor or x.x.X patch version respectively.
Furthermore, you can define auto commit features such as increase version number on every commit. (e.g. project-1.0.0-SNAPSHOT-INCREASE -> project-1.0.0-SNAPSHOT150)
(Used gradle fork https://github.com/fzacek/gradle-version-bump-action from @fzacek to implement gradle also into this multi use version bump action for any gradle and maven project)


For example, a `#minor` update to version `1.3.9` will result in the version changing to `1.4.0`.
The change will then be committed. Plugily Projects is using it on their projects, to see demo, just watch the repos of them. 

## Sample Usage

```yaml
name: Clojure Version Bump

on:
    push:
        branches: [ development ]
    workflow_dispatch:
        inputs:
            auto-version-bump:
                description: 'Should we bump the version?'
                required: true
                default: 'false'
            tags:
                description: 'Tags'
                
jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - name: Checkout Latest Commit
      uses: actions/checkout@v2

    - name: Bump Version
      id: bump
      uses: Plugily-Projects/version-bump-action@v1
      with:
        github-token: ${{ secrets.github_token }}

    - name: Print Version
      run: "echo 'New Version: ${{steps.bump.outputs.version}}'"
```

## Supported Arguments

* `github-token`: The only required argument. Can either be the default token, as seen above, or a personal access token with write access to the repository
* `git-email`: The email address each commit should be associated with. Defaults to a github provided noreply address
* `git-username`: The GitHub username each commit should be associated with. Defaults to `version-bump[github-action]`
* `pom-path`: The path within your directory the pom.xml you intended to change is located.
* `gradle-path`: The path within your directory the build.gradle you intended to change is located.
* `repo-build`: Using MAVEN or GRADLE to bump version
* `auto-version-bump`: Should we bump the version on every commit?
* `auto-version-bump-splitter`: Version splitter for auto bump
* `auto-version-bump-suffix`: Version suffix for auto bump
* `auto-version-bump-higher`: Should after the suffix a number bumped?
* `auto-version-bump-release`: Should on a automatic bump a tag and release created?

## Outputs

* `version` - The after-bump version. Will return the old version if bump was not necessary.
