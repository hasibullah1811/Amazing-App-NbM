import 'package:flutter/material.dart';

class IOSModalStyle extends StatelessWidget {
  final Widget childBody;

  const IOSModalStyle({
    Key? key,
    required this.childBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dividerWidget(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // color of card
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            ),
            height: 300, // body container height
            width: double.infinity,
            child: childBody,
          )
        ],
      ),
    );
  }

  Widget _dividerWidget() {
    return FractionallySizedBox(
      widthFactor: 0.2, // width of top divider bar
      child: Container(
        margin: const EdgeInsets.symmetric(
          // margin of top divider bar
          vertical: 12.0,
        ),
        child: Container(
          height: 5.0,
          decoration: BoxDecoration(
            color: Colors.white, // color of top divider bar
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
      ),
    );
  }
}
