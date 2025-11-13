# Odin + Raylib + Hot Reload template

This is an [Odin](https://github.com/odin-lang/Odin) + [Raylib](https://github.com/raysan5/raylib) game template with [Hot Reloading](http://zylinski.se/posts/hot-reload-gameplay-code/) pre-setup. It makes it possible to reload gameplay code while the game is running.

Supported platforms: Windows, macOS, Linux and [web](#web-build).

Supported editors and debuggers: [Sublime Text](#sublime-text), [VS Code](#vs-code) and [RAD Debugger](#rad-debugger).

## Hot reload quick start

> [!NOTE]
> These instructions use some Windows terminology. If you are on mac / linux, then replace these words:
> - `bat` -> `sh`
> - `exe` -> `bin`
> - `dll` -> `dylib` (mac), `so` (linux)

1. Run `build_hot_reload.bat` to create `game_hot_reload.exe` (located at the root of the project) and `game.dll` (located in `build/hot_reload`). Note: It expects odin compiler to be part of your PATH environment variable.
2. Run `game_hot_reload.exe`, leave it running.
3. Make changes to the gameplay code in `source/game.odin`. For example, change the line `rl.ClearBackground(rl.BLACK)` so that it instead uses `rl.BLUE`. Save the file.
4. Run `build_hot_reload.bat`, it will recompile `game.dll`.
5. The running `game_hot_reload.exe` will see that `game.dll` changed and reload it. But it will use the same `Game_Memory` (a struct defined in `source/game.odin`) as before. This will make the game use your new code without having to restart.

Note, in step 4: `build_hot_reload.bat` does not rebuild `game_hot_reload.exe`. It checks if `game_hot_reload.exe` is already running. If it is, then it skips compiling it.

## Release builds

Run `build_release.bat` to create a release build in `build/release`. That exe does not have the hot reloading stuff, since you probably do not want that in the released version of your game. This means that the release version does not use `game.dll`, instead it imports the `source` folder as a normal Odin package.

`build_debug.bat` is like `build_release.bat` but makes a debuggable executable, in case you need to debug your non-hot-reload-exe.

## Web build

`build_web.bat` builds a release web executable (no hot reloading!).

### Web build requirements

- Emscripten. Download and install somewhere on your computer. Follow the instructions here: https://emscripten.org/docs/getting_started/downloads.html (follow the stuff under "Installation instructions using the emsdk (recommended)").
- Recent Odin compiler: This uses Raylib binding changes that were done on January 1, 2025.

### Web build quick start

1. Point `EMSCRIPTEN_SDK_DIR` in `build_web.bat/sh` to where you installed emscripten.
2. Run `build_web.bat/sh`.
3. Web game is in the `build/web` folder.

> [!NOTE]
> `build_web.bat` is for windows, `build_web.sh` is for Linux / macOS.

> [!WARNING]
> You can't run `build/web/index.html` directly due to "CORS policy" javascript errors. You can work around that by running a small python web server:
> - Go to `build/web` in a console.
> - Run `python -m http.server`
> - Go to `localhost:8000` in your browser.
>
> _For those who don't have python: Emscripten comes with it. See the `python` folder in your emscripten installation directory._

Build a desktop executable using `build_desktop.bat/sh`. It will end up in the `build/desktop` folder.

There's a wrapper for `read_entire_file` and `write_entire_file` from `core:os` that can files from `assets` directory, even on web. See `source/utils.odin`

### Web build troubleshooting

See the README of the [Odin + Raylib on the web repository](https://github.com/karl-zylinski/odin-raylib-web?tab=readme-ov-file#troubleshooting) for troubleshooting steps.
