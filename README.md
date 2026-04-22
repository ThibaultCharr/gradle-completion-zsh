# Gradle Completion Plugin for Oh My Zsh

Smart tab completion for `./gradlew` commands with module path and task suggestions. Unlike completion plugins that invoke Gradle on every key press, this plugin uses a local index for instant results — even on large multi-module projects.

## Features

- Tab-complete module paths: `./gradlew :domains:<TAB>`
- Tab-complete tasks: `./gradlew :<ModuleName>:<TAB>`
- Shows task descriptions for bare commands: `./gradlew <TAB>`
- Caches module list for fast completions
- Auto-refreshes cache when `settings.gradle.kts` changes

## Installation

1. Copy the cloned folder into your oh-my-zsh custom plugins directory:

```bash
cp -r gradle-completion-zsh ~/.oh-my-zsh/custom/plugins/gradle-completion
```

2. Add `gradle-completion` to your plugins in `~/.zshrc`:

```bash
plugins=(... gradle-completion)
```

3. Reload your shell:

```bash
source ~/.zshrc
```

4. **Important**: Index your project's modules on first use:

```bash
cd /path/to/your/gradle/project
gradle-completion-index-modules
```

## Usage

```bash
./gradlew <TAB>                    # List common tasks with descriptions
./gradlew :<TAB>                   # Start module path completion
./gradlew :domains:<TAB>           # Complete module segments
./gradlew :<ModuleName>:<TAB>       # Complete tasks for a module
```

## Built-in Tasks

These tasks are available for completion out of the box:

| Task | Description |
|------|-------------|
| `assembleDebug` | Build debug APK |
| `assembleRelease` | Build release APK |
| `installDebug` | Install debug APK on device |
| `testReleaseUnitTest` | Run unit tests (release) |
| `testDebugUnitTest` | Run unit tests (debug) |
| `recordScreenshots` | Record Paparazzi screenshot baselines |
| `verifyScreenshots` | Verify Paparazzi screenshots |
| `lint` | Run lint checks |
| `clean` | Clean build outputs |
| `dependencyGuard` | Verify dependency guard |
| `dependencyGuardBaseline` | Update dependency guard baseline |
| `assemble` | Build all variants |
| `test` | Run all tests |
| `tasks` | List available tasks |

To add or modify tasks, see the [Customization](#customization) section.

## Troubleshooting

If tab completion doesn't find a module (e.g. after adding a new one), re-index:

```bash
cd /path/to/your/gradle/project
gradle-completion-index-modules
```

## Commands

| Command | Description |
|---------|-------------|
| `gradle-completion-index-modules` | Index all modules in the current Gradle project |

## Requirements

- Python 3
- Oh My Zsh

## Customization

To add or modify available tasks, edit the `_GRADLE_TASKS` array at the top of `gradle-completion.plugin.zsh`.

To change which directories are scanned for modules, edit `scan_dirs` in `gradle-scan-modules.py`.
