# Changelog

## 1.0.0

Change code to use eslint npm package instead of using eslintrb(no longer maintained).

### New features

- Use npx to run eslint, if no bin is passed.
- Expand pronto configuration:
  - Enables to pass eslint bin path.
  - Enables to pass the list of javascript or typescript file extensions to be analyzed.
  - Enables to pass .eslintrc.* file path. Make sure you have a [.eslintrc.*](https://eslint.org/docs/latest/use/configure/configuration-files) file in your project directory.

