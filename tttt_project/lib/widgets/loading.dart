import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loading extends StatelessWidget {
  const Loading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 100.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.discreteCircle(
              color: Colors.blue,
              size: 35,
              secondRingColor: Colors.teal,
              thirdRingColor: Colors.orangeAccent),
        ],
      ),
    );
  }
}
