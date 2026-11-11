# Oshi Extensions (`Ogaku/Oshi-Extensions`)

This repository contains the official school-register provider extensions for **Oshi**, modeled after [Mangayomi Extensions](https://github.com/kodjodevf/mangayomi-extensions) and powered by the [`d4rt`](https://pub.dev/packages/d4rt) Dart runtime.

## Adding this repository in Oshi

1. Open **Oshi** -> **Add Register / Browse Extensions** (or **Settings** -> **Extensions & Repositories**).
2. Open **Repositories** and add any of the following URLs (Oshi resolves both raw JSON indexes and GitHub repository URLs directly):

```text
https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/index.json
```

or the repository URL directly:

```text
https://github.com/Ogaku/Oshi-Extensions
```

Or via deep link:

```text
oshi://add-repo?repo_name=Oshi-Extensions&repo_url=https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/index.json
```

## Available Providers

| Provider | ID | Language | Path |
| --- | --- | --- | --- |
| **Librus Synergia** | `PROVGUID-RGLR-PROV-LIBR-LIBRSYNERGIA` | `pl` | [`dart/librus/librus.dart`](./dart/librus/librus.dart) |
| **eduVULCAN / UONET+** | `PROVGUID-RGLR-PROV-VULC-EDUVULCANAPI` | `pl` | [`dart/vulcan/vulcan.dart`](./dart/vulcan/vulcan.dart) |
| **Sample / Demo Register** | `PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER` | `all` | [`dart/sample/sample.dart`](./dart/sample/sample.dart) |

## Developing Extensions

See [CONTRIBUTING-DART.md](./CONTRIBUTING-DART.md) for instructions on writing new register providers in Dart for `d4rt`.

