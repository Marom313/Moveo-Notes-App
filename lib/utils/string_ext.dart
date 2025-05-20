extension ValidatorString on String {
  bool isValidEmail() => RegExp(
    r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  ).hasMatch(this);

  bool isPassValid() => RegExp(r'^(?=.?[a-z])(?=.?[0-9]).{6,}$').hasMatch(this);
}
