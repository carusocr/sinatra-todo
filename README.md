sinatra-todo
============

Ruby to-do list. That's it. Using it for practicing ruby, learning Sinatra + haml.
 Author : Chris Caruso Dec 2012

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
- 5. Add some sort of show/hide comments in home display.
- 6. Ability to note amount of time spent on each task if desired...pomodoro count?
- 7. Rating of quality of task performance? * Nah, the comments section has served this purpose well during testing.
- 8. Add ability to shift position of items in list.
- 10. Add online database functionality. - COMPLETED, but super ghetto...recall.db is a link to a link to each machine's Dropbox folder.
- 11. Add PostgreSQL via Heroku.
- 12. Clean up time tracking functionality. By clean up I mean make it actually work.

Additional behaviors to add: 

Todo tracks how many times I've created and then deleted a certain task, maybe by checking for 
keywords like 'call annoying uncle' and starts taking the initiative - adding that task on a day that
I've specified as flexible(typically weekends) and then not allowing me to delete it.

