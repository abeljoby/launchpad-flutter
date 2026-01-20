import 'package:flutter/material.dart';

class Preview extends StatefulWidget {
  const Preview({super.key, required this.pages, required this.sizes});

  final List<(String name, WidgetBuilder builder)> pages;
  final List<Size> sizes;

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<int>(
          onChanged: (value) => setState(() => _index = value!),
          value: _index,
          items: [
            for (var i = 0; i < widget.pages.length; i++)
              DropdownMenuItem(value: i, child: Text(widget.pages[i].$1)),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              runSpacing: 8,
              spacing: 8,
              children: [
                for (final size in widget.sizes)
                  _Screen(size: size, child: widget.pages[_index].$2(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Screen extends StatelessWidget {
  const _Screen({this.size = const Size(320, 480), required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black87,
          width: 16,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(size: size),
        child: child,
      ),
    );
  }
}