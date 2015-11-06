# Automated deploy to WordPress plugin repository from Travis CI

## How to setup

### Please add following lines into `.travis.yml`.

Deployment should be executed only `after_success`.

```
after_success: curl -L https://raw.githubusercontent.com/miya0001/travis2wpplugin/master/deploy.sh | bash
```

This script will run when `WP_PULUGIN_DEPLOY` is `true`.

```
matrix:
  include:
    - php: 5.3
      env: WP_VERSION=latest WP_MULTISITE=0 WP_PULUGIN_DEPLOY=1
```

Finally, please add environments variables like following in global section.

```
env:
  global:
    - SVN_REPO: https://plugins.svn.wordpress.org/<plugin-slug>/
    - GH_REF: https://github.com/<your-github-account>/<your-github-repository>.git
    - secure: "xxxxxxxx"
```

You can get `secure` value like following.

```
travis encrypt SVN_USER=<your-account> SVN_PASS=<your-password>
```

http://docs.travis-ci.com/user/encryption-keys/

### `.svnignore`

Add your `.svnignore` like following projects.

https://github.com/miya0001/simple-map

This script runs `svn propset -R` automatically  when there is a `.svnignore`.

### Running a building

Please place the `bin/build.sh`.

`bin/build.sh` will be executed automatically.

## How to commit

```
$ git commit -m "Some fix"
$ git push
```

When you would push tag, then it will run commit,

```
$ git tag 1.0.0
$ git push origin 1.0.0
```

See following projects.

* https://github.com/miya0001/simple-map
* https://github.com/miya0001/oembed-gist
* https://github.com/miya0001/content-template-engine

