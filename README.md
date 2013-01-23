sinatra-todo
============

Ruby to-do list. That's it. Using it for practicing ruby, learning Sinatra + haml.
 Author : Chris Caruso

This todo list tracks my tasks for a given day, changing colors to display their current state.
I'm looking to make a todo list that compensates for my laziness by nagging appropriately and preventing me from simply deleting undone tasks at the end of the day.

- White: uncompleted task.
- Aqua: completed task.
- Red: uncompleted task, automatically carried over from previous day. A red task that is completed will vanish from the current day's display and reappear in aqua on the day of creation, with a footnote listing completion date.
- Yellow: You didn't have the guts to finish this task and marked it 'slacked'! A slacked task cannot be deleted, as testament to procrastination.

There are a set of icons under each task, although task state determines which icons are 
displayed:

- ✎       Edit task. This icon is available only for uncompleted tasks.
- ↯       Complete task. This icon is displayed for uncomplete, slacked, or completed tasks.
- ↭       Slack on task. This icon is displayed only for uncomplete tasks.
- ☢       Delete task. This icon is available for all tasks except slack(testament!).
- ...     Postmortem comments. These can be entered for completed or slacked tasks in order to provide additional information about the task's execution.

Future features:
- 3. Add duration and comments section to database.
- 5. Add some sort of show/hide comments in home display.
- 6. Ability to note amount of time spent on each task if desired...pomodoro count?
- 7. Rating of quality of task performance?
- 8. Add ability to shift position of items in list
- 10. Add online database functionality. - iriscouch is proving to be a pain in the ass.

Additional behaviors: 

Todo tracks how many times I've created and then deleted a certain task, maybe by checking for 
keywords like 'call annoying uncle' and starts taking the initiative - adding that task on a day that
I've specified as flexible(typically weekends) and then not allowing me to delete it.

