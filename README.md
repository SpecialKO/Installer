# Installer
![Screenshot of the main Special K installer](https://sk-data.special-k.info/artwork/screens/installer_75percent.png)

These are the Inno Setup scripts (.iss) and assets used to compile the various types of installers that the Special K team provides.

* The main packaged Special K installer can be downloaded from https://special-k.info/.
* The other packaged installers from their respective location.

## About the repository

Note that this repository includes the core framework required by the installers &mdash; it does not include *all* required game/mod/software files, folders, and dependencies to build a specific installer as such files are outside the scope of this repository. Inno Setup users should therefor not expect to be able to build a specific installer using solely the files in this repository. The scripts are provided primarily for historical as well as educational purposes.

| Inno Setup Script       | What it does  |
| ----------------------: | ------------- |
| `SpecialK.iss`          | Builds a combined installer of [Special K](https://github.com/SpecialKO/SpecialK), [SKIF](https://github.com/SpecialKO/SKIF), and [SKIFsvc](https://github.com/SpecialKO/SKIFsvc). |
| `SKIFdrv.iss`           | Builds an installer for [SKIFdrv](https://github.com/SpecialKO/SKIFdrv). |
| `Mod.iss`               | Builds installers for the game mods: <br>- **TBFix** for *Tales of Berseria* <br>- **TVFix** for *Tales of Vesperia* <br>- **UnX** for *Final Fantasy X\|X-2 HD Remaster* |
| `Mod_TSFix.iss`         | Builds installers for the game mods: <br>- **TSFix** for *Tales of Symphonia* |
| `ValvePlug.iss`         | Builds an installer for [Valve Plug](https://github.com/SpecialKO/ValvePlug). |
| `SpecialK_Shared.iss`   | Shared helper code, procedures, functions, and logic used by the build scripts. |
| `CodeDependencies.iss`  | Shared dependency handler: [Inno Setup Dependency Installer](https://github.com/DomGries/InnoDependencyInstaller) |

## Building the installers

1. Download Inno Setup from https://jrsoftware.org/isinfo.php
2. Clone the whole repository.
3. Create the necessary input and output subfolders based on which installer is being build:
   * Main Special K installer uses `Source` as the input folder and `Builds` as the output folder.
   * Game-specific installers uses `Source_<ModName>` (e.g. `Source_UnX`) as the input folder and `Builds_Mods` as the output folder.
   * SKIFdrv (the kernel driver installer) uses `Source_SKIFdrv` as input and `Builds_SKIFdrv` as the output.
   * ValvePlug uses `Source_ValvePlug` as input and `Builds_ValvePlug` as output folders.
4. The source folders are structured identically as the desired post-install folder state should be (except for untouched game files, of course).
   * The easiest way to set a source folder up is to just extract the relevant .7z archive of said mod/package straight into it, and then add/remove files as wanted.
   * Note that `SpecialK.iss` and `Source` requires combining the compiled versions of Special K, SKIF, and SKIFsvc in their relevant places/subfolders.
5. Right click the relevant Inno Setup Install Script (.iss) file, and click **Compile**.
   * See the section above on which file corresponds to which installer.
   * `Mod.iss` is shared between multiple installers -- edit the file and (un)comment the appropriate `#define <ModName>` at the top of the file to select which installer to build.
6. Once the installer has been built, perform an install and uninstall for testing purposes to verify that everything works as intended.
   * Uninstalls of game-specific mods are intended to restore the original untouched game state as much as possible (e.g. restoring original LAA-unaware executables).

## Third-party code

* Features the music track [Stargazer](https://opengameart.org/content/stargazer) by [Centurion_of_war](https://opengameart.org/users/centurionofwar), licensed under [CC0 1.0 Universal (CC0 1.0) Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/).

* Uses [Inno Setup Dependency Installer](https://github.com/DomGries/InnoDependencyInstaller), licensed under [The Code Project Open License (CPOL) 1.02](https://github.com/DomGries/InnoDependencyInstaller/blob/master/LICENSE.md).

* Includes various snippets of code from [Stack Overflow](https://stackoverflow.com/), licensed under [Creative Commons Attribution-ShareAlike](https://stackoverflow.com/help/licensing).
