# Automated deploy to wordpress.org plugin repository from Travis CI

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
    - secure: "xxxxxxxx"
```

You can get `secure` value like following.

```
travis encrypt SVN_USER=<your-account> SVN_PASS=<your-password>
```

http://docs.travis-ci.com/user/encryption-keys/

### `.svnignore`

Example of .svnignore is following.

https://github.com/miya0001/wp-svnignore

Add your `.svnignore` like following projects

https://github.com/miya0001/simple-map

This script runs `svn propset -R` automatically  when there is a `.svnignore`.

### `bin/build.sh`

If you are using `gulp`, `composer` or so, please place the `bin/build.sh`.

`bin/build.sh` will be executed automatically.

## How to commit

When you tag like following, then it will run commit to plugin's repository on wordpress.org.

```
$ git tag 1.0.0
$ git push origin 1.0.0
```

Tag and plugin's version need to be same.

## Integration Checklist

You can use following checklist to integrate this project in your plugin.

1. [ ]  Add `after_success: curl -L https://raw.githubusercontent.com/miya0001/travis2wpplugin/master/deploy.sh | bash` into `.travis.yml` like [this](https://github.com/tarosky/logbook/blob/master/.travis.yml#L57).
2. [ ] Define the `WP_PULUGIN_DEPLOY=1` in the `.travis.yml` like [this](https://github.com/tarosky/logbook/blob/master/.travis.yml#L14).
3. Run `travis encrypt SVN_USER=<your-account> SVN_PASS=<your-password>` and paste the output into `.travis.yml` like [this](https://github.com/tarosky/logbook/blob/master/.travis.yml#L43-L46).
5. [ ] Place the `.distignore` that are list of files to exclude to commit SVN. It is an [example](https://github.com/tarosky/logbook/blob/master/.distignore).
4. [ ] If you need to run `npm install` or `composer install` or so, place the `build.sh` that will be executed automatically. This is an [example](https://github.com/tarosky/logbook/blob/master/bin/build.sh).

Finnaly, you can release your plugin like following.

```
$ git tag 1.0.0
$ git push origin 1.0.0
```

## Example project

We are using this project in following plugins.

Please check logs of Travis CI.

* https://github.com/miya0001/simple-map
* https://github.com/miya0001/oembed-gist
* https://github.com/miya0001/content-template-engine
* https://github.com/miya0001/wp-total-hacks
* https://github.com/torounit/hello-kushimoto/
