const _kMonthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];
const _kMonthsFull = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
];
const _kWeekdaysFull = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];

String formatDateShort(DateTime date) => '${date.day} ${_kMonthsShort[date.month - 1]} ${date.year}';

String formatDateLong(DateTime date) => '${_kWeekdaysFull[date.weekday - 1]}, ${date.day} ${_kMonthsFull[date.month - 1]} ${date.year}';

String formatDayMonth(DateTime date) => '${date.day} ${_kMonthsShort[date.month - 1]}';

String formatMonthYear(DateTime date) => '${_kMonthsFull[date.month - 1]} ${date.year}';

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
