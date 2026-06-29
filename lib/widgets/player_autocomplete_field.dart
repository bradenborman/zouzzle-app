import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// A text input field with autocomplete suggestions for player names.
///
/// Calls [onSearch] on each keystroke to retrieve a filtered list of player
/// name suggestions, displays them in a dropdown overlay, and populates the
/// field when a suggestion is selected. Exposes [onSubmit] for wiring to an
/// external submit button.
///
/// Styled with white text on the app's dark background, consistent with
/// [AppTheme].
class PlayerAutocompleteField extends StatefulWidget {
  const PlayerAutocompleteField({
    super.key,
    required this.onSearch,
    required this.onSubmit,
    this.controller,
  });

  /// Callback invoked on each keystroke to retrieve matching player names.
  /// Receives the current input text and returns a list of matching names.
  final List<String> Function(String) onSearch;

  /// Callback invoked when the user triggers submission (via external button).
  /// Receives the current text value of the field.
  final ValueChanged<String> onSubmit;

  /// Optional external controller. If not provided, the widget creates its own.
  final TextEditingController? controller;

  @override
  State<PlayerAutocompleteField> createState() =>
      PlayerAutocompleteFieldState();
}

/// State for [PlayerAutocompleteField].
///
/// Exposes a [clear] method so parent widgets can reset the field externally.
class PlayerAutocompleteFieldState extends State<PlayerAutocompleteField> {
  late final TextEditingController _controller;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// Clears the text field and hides any open suggestion dropdown.
  void clear() {
    _controller.clear();
    _removeOverlay();
  }

  /// Returns the current text value of the field.
  String get text => _controller.text;

  void _onTextChanged() {
    final query = _controller.text;
    if (query.isEmpty) {
      _removeOverlay();
      setState(() => _suggestions = []);
      return;
    }

    final results = widget.onSearch(query);
    setState(() => _suggestions = results);

    if (_suggestions.isEmpty) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectSuggestion(String name) {
    _controller.removeListener(_onTextChanged);
    _controller.text = name;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: name.length),
    );
    _controller.addListener(_onTextChanged);
    _removeOverlay();
    setState(() => _suggestions = []);
  }

  OverlayEntry _buildOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Calculate available space below vs above to decide direction
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - position.dy - size.height;
    final showAbove = spaceBelow < 250;

    final offset = showAbove
        ? Offset(0, -204) // above the field
        : Offset(0, size.height + 4); // below the field

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: offset,
          child: Material(
            elevation: 4,
            color: AppTheme.missGray,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      suggestion,
                      style: const TextStyle(color: AppTheme.white),
                    ),
                    onTap: () => _selectSuggestion(suggestion),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        autocorrect: false,
        enableSuggestions: false,
        style: const TextStyle(color: AppTheme.white),
        decoration: InputDecoration(
          hintText: 'Enter player name...',
          hintStyle: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: AppTheme.missGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: (_) => widget.onSubmit(_controller.text),
      ),
    );
  }
}
