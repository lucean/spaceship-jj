<h1 align="center">
  😍 + 🚀
  <br>Spaceship JJ<br>
</h1>

<h4 align="center">
  A <a href="https://www.jj-vcs.dev/latest/" target="_blank">Jujutsu</a> section for the Spaceship prompt
</h4>

<p align="center">
  <a href="https://github.com/lucean/spaceship-jj/releases">
    <img src="https://img.shields.io/github/v/release/lucean/spaceship-jj.svg?style=flat-square"
      alt="GitHub Release" />
  </a>
</p>

For jj-vcs v0.39.0.

## Installing

You need to source this plugin somewhere in your dotfiles. Here's how to do it with some popular tools:

### [Oh-My-Zsh]

Execute this command to clone this repo into Oh-My-Zsh plugin's folder:

```zsh
git clone https://github.com/lucean/spaceship-jj.git $ZSH_CUSTOM/plugins/spaceship-jj
```

Include `spaceship-jj` in Oh-My-Zsh plugins list:

```zsh
plugins=($plugins spaceship-jj)
```

### [zplug]

```zsh
zplug "lucean/spaceship-jj"
```

### [antigen]

```zsh
antigen bundle "lucean/spaceship-jj"
```

### [antibody]

```zsh
antibody bundle "lucean/spaceship-jj"
```

### [zinit]

```zsh
zinit light "lucean/spaceship-jj"
```

### [zgen]

```zsh
zgen load "lucean/spaceship-jj"
```

### [sheldon]

```toml
[plugins.spaceship-section]
github = "lucean/spaceship-jj"
```

### Manual

If none of the above methods works for you, you can install Spaceship manually.

1. Clone this repo somewhere, for example to `$HOME/.zsh/spaceship-jj`.
2. Source this section in your `~/.zshrc`.

### Example

```zsh
mkdir -p "$HOME/.zsh"
git clone --depth=1 https://github.com/lucean/spaceship-jj.git "$HOME/.zsh/spaceship-jj"
```

For initializing prompt system add this to your `.zshrc`:

```zsh title=".zshrc"
source "~/.zsh/spaceship-jj/spaceship-jj.plugin.zsh"
```

## Usage

After installing, add the following line to your `.zshrc` in order to include jj in the prompt:

```zsh
spaceship add --before git jj
```

Adding the section before the `git` section ensures that the `jj` section appears in a reasonable position relative to the other sections that may be active.

Alternatively, the above line can be added to `.config/spaceship.zsh`.

### Suppressing the Git section when using `jj`

Spaceship’s `git` section is enabled by default. Because `jj` repositories are usually backed by git repositories internally, the git prompt will still appear alongside the `jj` prompt.
This can be resolved by setting `SPACESHIP_SHOW_GIT=false` in any repositories where `jj` is being used.
One way to do this is to use **direnv** to disable the git section automatically when entering those directories.

* Install `direnv`:

  ```bash
  # e.g. on macOS:
  brew install direnv
  ```

* Enable the direnv hook in zsh

  ```bash
  echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
  ```

* Reload your shell:

  ```bash
  exec zsh
  ```

* Create a `.envrc` file in your `jj` repository

  ```bash
  cd <path/to/jj_repository>
  echo 'export SPACESHIP_GIT_SHOW=false' > .envrc
  ```

* Allow direnv to load the environment

  ```bash
  direnv allow <path/to/jj_repository>
  ```

After this, the git sections will be hidden inside the `jj` repository.

* (Optional) Silence direnv load/unload messages

By default, direnv prints a message whenever an environment is loaded or unloaded. To suppress this:

```bash
cat <<'EOF' >> ~/.config/direnv/direnv.toml
[global]
log_filter = "^$"
EOF
```

## Options

This section is shown only in directories within a foobar context.

| Variable              |              Default               | Meaning                              |
|:----------------------|:----------------------------------:| ------------------------------------ |
| `SPACESHIP_JJ_SHOW`   |               `true`               | Show current section                 |
| `SPACESHIP_JJ_PREFIX` | `$SPACESHIP_PROMPT_DEFAULT_PREFIX` | Prefix before section                |
| `SPACESHIP_JJ_SUFFIX` | `$SPACESHIP_PROMPT_DEFAULT_SUFFIX` | Suffix after section                 |
| `SPACESHIP_JJ_SYMBOL` |                `🥋`                | Character to be shown before version |
| `SPACESHIP_JJ_COLOR`  |              `yellow`              | Color of section                     |

## Contributing

First, thanks for your interest in contributing!

Contribute to this repo by submitting a pull request. Please use [conventional commits](https://www.conventionalcommits.org/), since this project adheres to [semver](https://semver.org/) and is automatically released via [semantic-release](https://github.com/semantic-release/semantic-release).

## License

MIT © [lucean](http://github.com/lucean)

<!-- References -->

[Oh-My-Zsh]: https://ohmyz.sh/
[zplug]: https://github.com/zplug/zplug
[antigen]: https://antigen.sharats.me/
[antibody]: https://getantibody.github.io/
[zinit]: https://github.com/zdharma/zinit
[zgen]: https://github.com/tarjoilija/zgen
[sheldon]: https://sheldon.cli.rs/
