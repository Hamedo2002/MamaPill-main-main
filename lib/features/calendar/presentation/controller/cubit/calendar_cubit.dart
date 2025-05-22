import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarCubit extends Cubit<DateTime> {
  // Static instance to ensure we're using the same instance throughout the app
  static CalendarCubit? _instance;
  
  // Factory constructor to return the singleton instance
  factory CalendarCubit() {
    _instance ??= CalendarCubit._internal();
    return _instance!;
  }
  
  // Private constructor for singleton pattern
  CalendarCubit._internal() : super(DateTime.now());
  
  // Flag to track if the cubit has been closed
  bool _isClosed = false;
  
  void changeSelectedDate(DateTime selectedDate) {
    // Don't emit if the cubit is closed
    if (_isClosed) {
      print('CalendarCubit: Attempted to emit after close');
      return;
    }
    
    // Don't emit if it's the same date (to prevent unnecessary rebuilds)
    if (state.year == selectedDate.year && 
        state.month == selectedDate.month && 
        state.day == selectedDate.day) {
      return;
    }
    
    emit(selectedDate);
  }
  
  // Override close to prevent actual closing for the singleton instance
  @override
  Future<void> close() async {
    // For the singleton instance, we don't actually close it
    // We just pretend to close it but actually reset it
    if (identical(this, _instance)) {
      // Instead of marking as closed, we'll just reset the state
      // This prevents 'Attempted to emit after close' messages
      reset();
      return Future.value();
    }
    
    // For any other instances (which shouldn't exist in this pattern)
    // proceed with normal close
    _isClosed = true;
    return super.close();
  }
  
  // Method to reset the closed state (useful when navigating back to screens)
  void reset() {
    // Reset the closed state to allow emissions again
    _isClosed = false;
    
    // If we're resetting after a close, we might need to re-emit the current state
    // to ensure all listeners are properly updated
    // We use a microtask to avoid doing this during build
    Future.microtask(() {
      if (!_isClosed) {
        emit(state);
      }
    });
  }
}
