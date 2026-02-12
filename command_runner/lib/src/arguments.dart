import '../command_runner.dart';
import 'dart:collection';
import 'dart:async';

enum OptionType { flag, option }

// enum represents the type of option.
// useful for representing a fixec set of possible values

///abstract class in Dart is a class that cannot be instantiated directly and is meant to be extended (inherited) or implemented by other classes.
///
// define a common blueprint for multiple related classes.
// Paste this new class below the enum you added
abstract class Argument {
  String get name;
  String? get help;

  // In the case of flags, the default value is a bool.
  // In other options and commands, the default value is a String.
  // NB: flags are just Option objects that don't take arguments
  Object? get defaultValue;
  String? get valueHelp;

  String get usage;
}

// extends keyword establishes the inheritance relationship
class Option extends Argument {
  // define constructors
  Option(
    this.name, { //named parameters
    required this.type, //must be provided
    this.help,
    this.abbr,
    this.defaultValue,
    this.valueHelp,
  });

  // constructor uses @override to provide concrete
  // implementations for the properties defined in Argument

  // use @override fr implementation
  @override
  final String name;

  final OptionType type;

  @override
  final String? help;

  final String? abbr;

  @override
  final Object? defaultValue;

  @override
  final String? valueHelp;

  @override
  String get usage {
    if (abbr != null) {
      return '-$abbr,--$name: $help';
    }

    return '--$name: $help';
  }
}

// The Command class will represent an executable action
abstract class Command extends Argument {
  @override
  String get name;

  String get description;

  bool get requiresArgument => false;

  late CommandRunner runner; //this variable will be assigned later befre use

  @override
  String? help;

  @override
  String? defaultValue;

  @override
  String? valueHelp;

  final List<Option> _options =
      []; // _ makes options private, accessible only inside this file

  // encapsulation
  // convert list to set return read-only version
  UnmodifiableSetView<Option> get options =>
      UnmodifiableSetView(_options.toSet());

  // A flag is an [Option] that's treated as a boolean.
  void addFlag(String name, {String? help, String? abbr, String? valueHelp}) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: false,
        valueHelp: valueHelp,
        type: OptionType.flag,
      ),
    );
  }

  // An option is an [Option] that takes a value.
  void addOption(
    String name, {
    String? help,
    String? abbr,
    String? defaultValue,
    String? valueHelp,
  }) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: defaultValue,
        valueHelp: valueHelp,
        type: OptionType.option,
      ),
    );
  }

  // Any subclass of Command MUST implement:
  // why FutureOr?
  // It can return normal value
  // OR a Future (async)
  FutureOr<Object?> run(ArgResults args);

  @override
  String get usage {
    return '$name:  $description';
  }
}

// stores parsed results
class ArgResults {
  Command? command; //which comand used
  String? commandArg; // arfgumnet passed
  Map<Option, Object?> options = {}; //map of options and their values

  // Returns true if the flag exists.
  bool flag(String name) {
    // Only check flags, because we're sure that flags are booleans.
    for (var option in options.keys.where(
      (option) => option.type == OptionType.flag,
    )) {
      if (option.name == name) {
        return options[option] as bool;
      }
    }
    return false;
  }

  // checks if Option exists at all
  bool hasOption(String name) {
    return options.keys.any((option) => option.name == name);
  }

  ({Option option, Object? input}) getOption(String name) {
    var mapEntry = options.entries.firstWhere(
      (entry) => entry.key.name == name || entry.key.abbr == name,
    );

    return (option: mapEntry.key, input: mapEntry.value);
  }
}
