# Gradle Completion Plugin for Oh My Zsh

Smart tab completion for `./gradlew` commands with module path and task suggestions.

## Features

- Tab-complete module paths: `./gradlew :domains:<TAB>`
- Tab-complete tasks: `./gradlew :features:<ModuleName>:impl:<TAB>`
- Shows task descriptions for bare commands: `./gradlew <TAB>`
- Caches module list for fast completions
- Auto-refreshes cache when `settings.gradle.kts` changes

## Installation

1. Copy this folder to your oh-my-zsh custom plugins directory:

```bash
cp -r gradle-completion ~/.oh-my-zsh/custom/plugins/
```

2. Add `gradle-completion` to your plugins in `~/.zshrc`:

```bash
plugins=(... gradle-completion)
```

3. Reload your shell:

```bash
source ~/.zshrc
```

4. **Important**: Run the cache builder on first use:

```bash
cd /path/to/your/gradle/project
gradle-refresh-cache
```

## Usage

```bash
./gradlew <TAB>                    # List common tasks with descriptions
./gradlew :<TAB>                   # Start module path completion
./gradlew :domains:<TAB>           # Complete module segments
./gradlew :domains:search:<TAB>    # Complete tasks for a module
```

## Commands

| Command | Description |
|---------|-------------|
| `gradle-refresh-cache` | Manually refresh the module cache (run after adding new modules) |

## Requirements

- Python 3
- Oh My Zsh

## Customization

To add or modify available tasks, edit the `_GRADLE_TASKS` array at the top of `gradle-completion.plugin.zsh`.

To change which directories are scanned for modules, edit `scan_dirs` in `gradle-scan-modules.py`.
