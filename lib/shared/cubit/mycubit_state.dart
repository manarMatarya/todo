part of 'mycubit_cubit.dart';

@immutable
abstract class MycubitState {}

class MycubitInitial extends MycubitState {}

class BottomNavigationState extends MycubitState {}

class CreateDatadaseState extends MycubitState {}

class InsertToDatabaseState extends MycubitState {}

class UpdateDatabaseState extends MycubitState {}

class DeleteDatabaseState extends MycubitState {}

class GetDataFromDatabaseState extends MycubitState {}

class FAPPressedState extends MycubitState {}
