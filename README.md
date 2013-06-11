sinatra-todo
============

Ruby to-do list. Using it for practicing ruby, learning Sinatra + haml...
 Author : Chris Caruso

This todo list tracks my tasks for a given day, changing colors to display their current state.
I'm looking to make a todo list that compensates for my laziness by nagging appropriately and preventing me from simply deleting undone tasks at the end of the day.

- White: New task.
- Red: Uncompleted task, automatically carried over from previous day.
- Green: Task is currently being worked.
- Aqua: Completed task. A red task that is completed will vanish from the current day's display and be aquafied and moved back to the day it was created. Maybe this should be changed to remain on date of completion but with a note including creation date?
- Yellow: You didn't have the guts to finish this task and marked it 'slacked'! A slacked task cannot be deleted, as testament to your laziness.

There are a set of icons under each task, although task state determines which icons are 
displayed:

- ▣				Complete task. This icon is displayed for white, yellow, or aqua tasks(clicking complete on a completed task will toggle back to white).
- ↯       Activate task. Todo will begin to track time spent performing task.
- ↭       Slack on task, you slinking procrastinator. This icon is displayed only for white tasks.
- ☢       Delete task. This icon is available for all tasks except yellow(remember the testament part).
- ...     Postmortem comments. These can be entered for aqua or yellow tasks in order to provide additional information about the task's execution.

Future features:
-  Add some sort of show/hide comments in home display.
-  Add ability to shift position of items in list.
-  Add online database functionality. - COMPLETED, but super ghetto...recall.db is a link to a link to each machine's Dropbox folder.
-  Add PostgreSQL via Heroku.
- When an overdue task accumulates some worked time on present day, move create_date to current day? At least something about avoiding dumping it back to original create date when you finally get around to completing task.

Additional behaviors to add: 

Todo tracks how many times I've created and then deleted a certain task, maybe by checking for 
keywords like 'call annoying uncle' and starts taking the initiative - adding that task on a day that
I've specified as flexible(typically weekends) and then not allowing me to delete it.

