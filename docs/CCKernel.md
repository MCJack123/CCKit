A task manager that allows multiple CCKit programs to run simultaneously.
## Functions
* *string* basename(*string* p): Returns the end of a path name.
    * p: The path to trim
    * Returns: The file name of the path
* *nil* main([*string* first_program, *string* args...]): Starts the kernel run loop, and runs first_program or shell after starting.
    * first_program: The program that will be executed as PID 1, defaults to shell
    * args: Any arguments to pass to the program
* *nil* exec(*string* path[, *string* args...]): Executes a new program alongside the current program
    * path: The full path to the program to execute
    * args: Any arguments to pass to the program
* *table* get_processes(): Returns a table of the currently running processes.
    * Returns: A table with keys [coro, path, started, filter, args]
* *nil* kill(*number* pid): Kills a process.
    * pid: The Process ID to target
* *nil* send(*number* pid, *string* ev[, *any* params...]): Sends an event to a process's queue.
    * pid: The Process ID to target
    * ev: The name of the event
    * params: Any parameters to send in the event
* *nil* broadcast(*string* ev[, *any* params...]): Sends an event to every process's queue.
    * ev: The name of the event
    * params: Any parameters to send in the event
## Notes
This file can both be executed on its own and loaded as an API. If run, it will run main() with the parameters supplied on the command line.  
When main is called, some things will be made available to every process:

* os.queueEvent() will only send events to the current process. To send to other processes, use send() or broadcast().
* All processes will recieve events sent by ComputerCraft, though.
* If a shell is available, then the `ktools` directory inside CCKit will be added to the path. This folder adds some tools that can be run:
    * `kill <pid>`: Kills a process.
    * `kstart <path> [args...]`: Starts a new process.
    * `ps` : Lists all of the running processes with textutils.tabulate().
* Some new kernel calls are available:
    * kcall_get_process_table: Sends back a copy of the process table.
    * kcall_kill_process: Kills a process.
    * kcall_start_process: Starts a process.
* These calls are used internally by the functions provided by CCKernel.
* A debugger can be accessed by pressing the F12 key. When pressed, the Lua interpreter will open, allowing you to access global variables.
    * A function called kill_kernel() is available, which kills the kernel and returns to the shell (or the calling program). This is useful if a program gets stuck in an infinite loop.
    * The process table is also available to inspect
    * Unfortunately, it isn't possible to access the environment of the running programs, so this only allows accessing global variables.