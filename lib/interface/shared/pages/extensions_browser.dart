// ignore_for_file: prefer_const_constructors
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/extensions/extension_manager.dart';
import 'package:oshi/extensions/models/extension_manifest.dart';
import 'package:oshi/interface/components/shim/page_routes.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Opens the in-app Extensions & Repositories Browser (adaptive for Material 3 and Cupertino).
Future<void> openExtensionsBrowser(BuildContext context, {bool showDevProviders = false}) async {
  await Navigator.of(context).push(
    AdaptivePageRoute(
      builder: (context) => ExtensionsBrowserPage(showDevProviders: showDevProviders),
    ),
  );
}

class ExtensionsBrowserPage extends StatefulWidget {
  const ExtensionsBrowserPage({super.key, this.showDevProviders = false});

  final bool showDevProviders;

  @override
  State<ExtensionsBrowserPage> createState() => _ExtensionsBrowserPageState();
}

class _ExtensionsBrowserPageState extends State<ExtensionsBrowserPage> {
  final ExtensionManager _manager = ExtensionManager.instance;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _busyIds = {};
  int _selectedTab = 0; // 0 = Browse / Available, 1 = Installed

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onManagerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _manager.refreshCatalogIfNeeded();
    });
  }

  @override
  void dispose() {
    _manager.removeListener(_onManagerChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onManagerChanged() {
    if (mounted) setState(() {});
  }

  List<ExtensionManifest> get _filteredAvailable {
    final q = _searchController.text.trim().toLowerCase();
    return _manager.available.where((ext) {
      if (ext.isDevOnly && !widget.showDevProviders && !_manager.isInstalled(ext.id)) {
        return false;
      }
      if (q.isEmpty) return true;
      return ext.localizedName.toLowerCase().contains(q) ||
          ext.localizedDescription.toLowerCase().contains(q) ||
          ext.id.toLowerCase().contains(q) ||
          ext.lang.toLowerCase().contains(q) ||
          ext.author.toLowerCase().contains(q);
    }).toList();
  }

  List<ExtensionManifest> get _filteredInstalled {
    final q = _searchController.text.trim().toLowerCase();
    return _manager.installed.values.where((ext) {
      if (q.isEmpty) return true;
      return ext.localizedName.toLowerCase().contains(q) ||
          ext.localizedDescription.toLowerCase().contains(q) ||
          ext.id.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _installOrUpdate(ExtensionManifest manifest) async {
    if (_busyIds.contains(manifest.id)) return;
    setState(() => _busyIds.add(manifest.id));
    try {
      await _manager.installExtension(manifest);
      if (!mounted) return;
      _showFeedback('Zainstalowano dodatek: ${manifest.localizedName} (v${manifest.version})');
    } catch (e) {
      if (!mounted) return;
      _showFeedback('Błąd instalacji: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busyIds.remove(manifest.id));
    }
  }

  Future<void> _uninstall(ExtensionManifest manifest) async {
    if (_busyIds.contains(manifest.id)) return;
    setState(() => _busyIds.add(manifest.id));
    try {
      await _manager.uninstallExtension(manifest.id);
      if (!mounted) return;
      _showFeedback('Usunięto dodatek: ${manifest.localizedName}');
    } catch (e) {
      if (!mounted) return;
      _showFeedback('Błąd usuwania: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busyIds.remove(manifest.id));
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
    } else if (Share.settings.appSettings.useCupertino) {
      showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(isError ? 'Błąd' : 'Informacja'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _openRepositoriesSheet() {
    if (Share.settings.appSettings.useCupertino) {
      showCupertinoModalBottomSheet(
        context: context,
        builder: (ctx) => _RepositoriesSheet(manager: _manager),
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (ctx) => _RepositoriesSheet(manager: _manager),
      );
    }
  }

  void _openExtensionDetails(ExtensionManifest manifest) {
    final installed = _manager.getInstalled(manifest.id) ?? manifest;
    if (Share.settings.appSettings.useCupertino) {
      showCupertinoModalBottomSheet(
        context: context,
        builder: (ctx) => _ExtensionDetailsSheet(
          manifest: installed,
          isInstalled: _manager.isInstalled(manifest.id),
          hasUpdate: _manager.hasUpdate(manifest),
          onInstall: () => _installOrUpdate(manifest),
          onUninstall: () => _uninstall(manifest),
        ),
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (ctx) => _ExtensionDetailsSheet(
          manifest: installed,
          isInstalled: _manager.isInstalled(manifest.id),
          hasUpdate: _manager.hasUpdate(manifest),
          onInstall: () => _installOrUpdate(manifest),
          onUninstall: () => _uninstall(manifest),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Share.settings.appSettings.useCupertino ? _buildCupertino(context) : _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final list = _selectedTab == 0 ? _filteredAvailable : _filteredInstalled;

    return DefaultTabController(
      length: 2,
      initialIndex: _selectedTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dostawcy dziennika (Dodatki)'),
          actions: [
            IconButton(
              tooltip: 'Odśwież katalog',
              onPressed: _manager.isLoadingCatalog ? null : () => _manager.refreshCatalog(force: true),
              icon: _manager.isLoadingCatalog
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Repozytoria URL',
              onPressed: _openRepositoriesSheet,
              icon: const Icon(Icons.source_outlined),
            ),
          ],
          bottom: TabBar(
            onTap: (index) => setState(() => _selectedTab = index),
            tabs: [
              Tab(text: 'Dostępne (${_filteredAvailable.length})'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Zainstalowane (${_manager.installed.length})'),
                    if (_manager.updatesCount > 0) ...[
                      const SizedBox(width: 6),
                      Badge.count(count: _manager.updatesCount),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _searchController.clear()),
                        )
                      : null,
                  hintText: 'Szukaj dostawcy (np. Librus, eduVULCAN, PL)...',
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            if (_manager.lastCatalogError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card.filled(
                  color: scheme.errorContainer,
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
                    title: Text(
                      'Problem z pobraniem repozytorium',
                      style: TextStyle(color: scheme.onErrorContainer, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _manager.lastCatalogError!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                    trailing: TextButton(
                      onPressed: _openRepositoriesSheet,
                      child: const Text('Repozytoria'),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _selectedTab == 0 ? Icons.extension_off_outlined : Icons.download_for_offline_outlined,
                              size: 48,
                              color: scheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedTab == 0
                                  ? 'Brak dostawców w katalogu pasujących do wyszukiwania.'
                                  : 'Nie zainstalowano jeszcze żadnego dostawcy dziennika.\nPrzejdź do zakładki „Dostępne”, aby dodać np. Librus lub eduVULCAN.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.tonalIcon(
                              onPressed: _selectedTab == 0
                                  ? _openRepositoriesSheet
                                  : () {
                                      DefaultTabController.of(context).animateTo(0);
                                      setState(() => _selectedTab = 0);
                                    },
                              icon: Icon(_selectedTab == 0 ? Icons.add_link : Icons.explore_outlined),
                              label: Text(_selectedTab == 0 ? 'Zarządzaj repozytoriami' : 'Przeglądaj dostępne dodatki'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final ext = list[index];
                        final isInstalled = _manager.isInstalled(ext.id);
                        final hasUpdate = _manager.hasUpdate(ext);
                        final isBusy = _busyIds.contains(ext.id);

                        return Card.filled(
                          color: scheme.surfaceContainerLow,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _openExtensionDetails(ext),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      color: scheme.surfaceContainerHighest,
                                      padding: const EdgeInsets.all(6),
                                      child: ext.iconUrl.isNotEmpty
                                          ? FadeInImage.memoryNetwork(
                                              placeholder: kTransparentImage,
                                              image: ext.iconUrl,
                                              fit: BoxFit.contain,
                                              imageErrorBuilder: (_, _, _) =>
                                                  Image.asset('assets/resources/images/logo_fit.png', fit: BoxFit.contain),
                                            )
                                          : Image.asset('assets/resources/images/logo_fit.png', fit: BoxFit.contain),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                ext.localizedName,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: scheme.secondaryContainer,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'v${ext.version} • ${ext.lang.toUpperCase()}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: scheme.onSecondaryContainer,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ext.localizedDescription,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              (ext.isOfficial || ext.author.toLowerCase() == 'ogaku')
                                                  ? Icons.verified_user_outlined
                                                  : Icons.person_outline_rounded,
                                              size: 14,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Autor: ${ext.author}',
                                              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: (ext.isOfficial || ext.author.toLowerCase() == 'ogaku')
                                                    ? scheme.primaryContainer
                                                    : scheme.secondaryContainer.withValues(alpha: 0.7),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                (ext.isOfficial || ext.author.toLowerCase() == 'ogaku')
                                                    ? 'Oficjalne'
                                                    : 'Społeczność',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: (ext.isOfficial || ext.author.toLowerCase() == 'ogaku')
                                                      ? scheme.onPrimaryContainer
                                                      : scheme.onSecondaryContainer,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (isBusy)
                                    const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    )
                                  else if (!isInstalled)
                                    FilledButton.tonalIcon(
                                      onPressed: () => _installOrUpdate(ext),
                                      icon: const Icon(Icons.download, size: 18),
                                      label: const Text('Dodaj'),
                                    )
                                  else if (hasUpdate)
                                    FilledButton.icon(
                                      onPressed: () => _installOrUpdate(ext),
                                      icon: const Icon(Icons.system_update_alt, size: 18),
                                      label: const Text('Aktualizuj'),
                                    )
                                  else
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Odinstaluj dostawcę',
                                          onPressed: () => _uninstall(ext),
                                          icon: Icon(Icons.delete_outline, color: scheme.error),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final list = _selectedTab == 0 ? _filteredAvailable : _filteredInstalled;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Dostawcy (Dodatki)'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _manager.isLoadingCatalog ? null : () => _manager.refreshCatalog(force: true),
              child: _manager.isLoadingCatalog
                  ? const CupertinoActivityIndicator()
                  : const Icon(CupertinoIcons.refresh, size: 22),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _openRepositoriesSheet,
              child: const Icon(CupertinoIcons.link, size: 22),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedTab,
                children: {
                  0: Text('Dostępne (${_filteredAvailable.length})'),
                  1: Text('Zainstalowane (${_manager.installed.length})'),
                },
                onValueChanged: (v) {
                  if (v != null) setState(() => _selectedTab = v);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Szukaj dostawcy (Librus, eduVULCAN)...',
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (list.isEmpty)
              CardContainer(
                children: [
                  AdaptiveCard(
                    centered: true,
                    secondary: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Text(
                            _selectedTab == 0
                                ? 'Brak dostawców pasujących do zapytania.'
                                : 'Nie zainstalowano jeszcze żadnego dostawcy dziennika.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          CupertinoButton(
                            onPressed: _selectedTab == 0
                                ? _openRepositoriesSheet
                                : () => setState(() => _selectedTab = 0),
                            child: Text(_selectedTab == 0 ? 'Repozytoria URL' : 'Przeglądaj dostępne dodatki'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              CardContainer(
                children: list.map((ext) {
                  final isInstalled = _manager.isInstalled(ext.id);
                  final hasUpdate = _manager.hasUpdate(ext);
                  final isBusy = _busyIds.contains(ext.id);

                  return AdaptiveCard(
                    click: () => _openExtensionDetails(ext),
                    hideChevron: true,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${ext.localizedName} (v${ext.version})',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              const SizedBox(height: 3),
                              Opacity(
                                opacity: 0.65,
                                child: Text(
                                  ext.localizedDescription,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    (ext.isOfficial || ext.author.toLowerCase() == 'ogaku')
                                        ? CupertinoIcons.checkmark_seal_fill
                                        : CupertinoIcons.person,
                                    size: 13,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Autor: ${ext.author}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: CupertinoColors.secondaryLabel,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (ext.isOfficial || ext.author.toLowerCase() == 'ogaku') ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Oficjalne',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: CupertinoColors.activeBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isBusy)
                          const CupertinoActivityIndicator()
                        else if (!isInstalled || hasUpdate)
                          CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            minimumSize: const Size(32, 32),
                            onPressed: () => _installOrUpdate(ext),
                            child: Text(hasUpdate ? 'Aktualizuj' : 'Dodaj', style: const TextStyle(fontSize: 13)),
                          )
                        else
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(32, 32),
                            onPressed: () => _uninstall(ext),
                            child: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed, size: 20),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _RepositoriesSheet extends StatefulWidget {
  const _RepositoriesSheet({required this.manager});

  final ExtensionManager manager;

  @override
  State<_RepositoriesSheet> createState() => _RepositoriesSheetState();
}

class _RepositoriesSheetState extends State<_RepositoriesSheet> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isAdding = false;
  String? _statusMessage;

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addRepo() async {
    final raw = _urlController.text.trim();
    if (raw.isEmpty || _isAdding) return;

    setState(() {
      _isAdding = true;
      _statusMessage = null;
    });

    final res = await widget.manager.addRepository(
      raw,
      customName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _isAdding = false;
      if (res.success) {
        _urlController.clear();
        _nameController.clear();
        _statusMessage = 'Dodano repozytorium (${res.count} dostawców).';
      } else {
        _statusMessage = 'Błąd: ${res.message}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repos = widget.manager.repositories;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Repozytoria dodatków', style: Theme.of(context).textTheme.titleLarge),
                  TextButton.icon(
                    onPressed: () async {
                      await widget.manager.resetDefaultRepository();
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Domyślne'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Wklej link do index.json, repozytorium GitHub (np. https://github.com/Ogaku/Oshi-Extensions) lub bezpośredni URL pliku .dart:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                enabled: !_isAdding,
                decoration: const InputDecoration(
                  labelText: 'URL repozytorium lub pliku .dart',
                  hintText: 'https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/index.json',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      enabled: !_isAdding,
                      decoration: const InputDecoration(
                        labelText: 'Nazwa (opcjonalnie)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _isAdding ? null : _addRepo,
                    icon: _isAdding
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add),
                    label: const Text('Dodaj'),
                  ),
                ],
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.startsWith('Błąd')
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(),
              for (final repo in repos)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(repo.isOfficial ? Icons.verified_outlined : Icons.public),
                  title: Text(repo.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(repo.url, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: repo.enabled,
                        onChanged: (v) async {
                          await widget.manager.toggleRepository(repo.url, v);
                          if (mounted) setState(() {});
                        },
                      ),
                      IconButton(
                        tooltip: 'Kopiuj URL',
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => Clipboard.setData(ClipboardData(text: repo.url)),
                      ),
                      IconButton(
                        tooltip: 'Usuń repozytorium',
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () async {
                          await widget.manager.removeRepository(repo.url);
                          if (mounted) setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExtensionDetailsSheet extends StatelessWidget {
  const _ExtensionDetailsSheet({
    required this.manifest,
    required this.isInstalled,
    required this.hasUpdate,
    required this.onInstall,
    required this.onUninstall,
  });

  final ExtensionManifest manifest;
  final bool isInstalled;
  final bool hasUpdate;
  final VoidCallback onInstall;
  final VoidCallback onUninstall;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(manifest.localizedName, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${manifest.id}\nWersja: ${manifest.version} • Autor: ${manifest.author} • Język: ${manifest.lang.toUpperCase()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (!isInstalled || hasUpdate)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onInstall();
                      },
                      icon: Icon(hasUpdate ? Icons.system_update_alt : Icons.download),
                      label: Text(hasUpdate ? 'Aktualizuj' : 'Zainstaluj'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onUninstall();
                      },
                      icon: Icon(Icons.delete_outline, color: scheme.error),
                      label: Text('Odinstaluj', style: TextStyle(color: scheme.error)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(manifest.localizedDescription),
              const SizedBox(height: 12),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.code),
                title: const Text('Źródło skryptu (.dart / d4rt)'),
                subtitle: Text(manifest.sourceCodeUrl, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => launchUrlString(manifest.sourceCodeUrl),
                ),
              ),
              if (manifest.sourceCode != null && manifest.sourceCode!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Zainstalowany kod źródłowy Dart (d4rt):', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 240),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      manifest.sourceCode!,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
