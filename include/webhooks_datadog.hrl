-record(datadog_event, {
  title :: nonempty_string(), % The event title. Limited to 100 characters.
  text :: nonempty_string(), % The body of the event. Limited to 4000 characters.
  date_happened :: 'undefined' | string(), % POSIX timestamp of the event. [default=now]
  priority = normal :: normal | low, % The priority of the event ('normal' or 'low').
  host :: 'undefined' | string(), % Host name to associate with the event.
  tags :: 'undefined' | [string()], % A list of tags to apply to the event.
  alert_type = info :: info | error | warning | success,
  aggregation_key :: 'undefined' | string(), % An arbitrary string to use for aggregation, max length of 100 characters.
  source_type_name :: 'undefined' | string() % The type of event being posted
}).
