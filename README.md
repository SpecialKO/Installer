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
| `SpecialK_Shared.iss`   | Shared helper scripts, procedures, functions, and logic used by the build scripts. |
| `CodeDependencies.iss`  | Shared dependency handler: [Inno Setup Dependency Installer](https://github.com/DomGries/InnoDependencyInstaller) |

## Third-party code

* Features the music track [Stargazer](https://opengameart.org/content/stargazer) by [Centurion_of_war](https://opengameart.org/users/centurionofwar), licensed under [CC0 1.0 Universal (CC0 1.0) Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/).

* Uses [Inno Setup Dependency Installer](https://github.com/DomGries/InnoDependencyInstaller), licensed under [The Code Project Open License (CPOL) 1.02](https://github.com/DomGries/InnoDependencyInstaller/blob/master/LICENSE.md).

* Includes various snippets of code from [Stack Overflow](https://stackoverflow.com/), licensed under [Creative Commons Attribution-ShareAlike](https://stackoverflow.com/help/licensing).