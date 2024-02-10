# Pronto runner for ESLint

[![Code Climate](https://codeclimate.com/github/prontolabs/pronto-eslint.png)](https://codeclimate.com/github/prontolabs/pronto-eslint)
[![Build Status](https://travis-ci.org/prontolabs/pronto-eslint.png)](https://travis-ci.org/prontolabs/pronto-eslint)
[![Gem Version](https://badge.fury.io/rb/pronto-eslint.png)](http://badge.fury.io/rb/pronto-eslint)
[![Dependency Status](https://gemnasium.com/prontolabs/pronto-eslint.png)](https://gemnasium.com/prontolabs/pronto-eslint)

Pronto runner for [ESlint](http://eslint.org), that uses npm eslint package to lint your Javascript/Typescript code.

[What is Pronto?](https://github.com/prontolabs/pronto)


Make sure you have a [.eslintrc.*](https://eslint.org/docs/latest/use/configure/configuration-files) file in your project directory.

## Configuration

Configuring ESLint via .eslintrc will work just fine with pronto-eslint. You can use `.pronto.yml` to change the default configuration:
```yml
# default config
eslint:
  bin_path: 'npx eslint' # if no binary informed, it will try to run using npx.
  eslint_config_file: '', # Use this to inform a custom .eslintrc file
  files: ['.ts', '.js', '.es6', '.js.es6', '.jsx'] # list of file to be verified
```

