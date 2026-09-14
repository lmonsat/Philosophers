# Philosophers

42 school project: a simulation of the [dining philosophers problem](https://en.wikipedia.org/wiki/Dining_philosophers_problem) using **POSIX threads** and **mutexes**.

Philosophers sit around a table. Each one needs two forks to eat. Forks are shared with neighbors, so threads must coordinate without deadlock, data races, or starving a philosopher to death.

## Build

```bash
make
```

This produces the `philo` binary.

```bash
make clean    # remove object files
make fclean   # remove objects and the binary
make re       # rebuild from scratch
```

## Usage

```bash
./philo number_of_philosophers time_to_die time_to_eat time_to_sleep [number_of_times_each_philosopher_must_eat]
```

Times are in **milliseconds**.

| Argument | Description |
| --- | --- |
| `number_of_philosophers` | Number of philosophers (and forks). Maximum: **200**. |
| `time_to_die` | A philosopher dies if they do not start eating within this time since their last meal (or since the start). |
| `time_to_eat` | Time spent eating (holding two forks). |
| `time_to_sleep` | Time spent sleeping after a meal. |
| `number_of_times_each_philosopher_must_eat` | Optional. If set, the simulation stops when every philosopher has eaten at least this many times. |

All arguments must be positive integers.

### Examples

```bash
# One philosopher: takes a fork and dies (only one fork on the table)
./philo 1 800 200 200

# Should not die
./philo 5 800 200 200

# Stop after each philosopher has eaten 7 times
./philo 5 800 200 200 7

# Tight timing: a death is expected
./philo 4 310 200 100
```

## Output

Each action is printed as:

```text
{timestamp_ms} [philosopher_id] action
```

Possible actions:

- `has taken a fork`
- `is eating`
- `is sleeping`
- `is thinking`
- `died`

Printing is protected by a mutex so logs stay readable and a death is reported once.

## Implementation

This is the **mandatory** part of the subject (`philo`): threads + mutexes. There is no bonus (`philo_bonus` with processes and semaphores).

- One thread per philosopher, plus shared data (timing, stop flag, death flag).
- One mutex per fork; extra mutexes protect printing, meal timestamps, and death/stop state.
- Even/odd philosophers lock forks in opposite order so two neighbors do not grab the same first fork (deadlock avoidance).
- Odd philosophers wait a short delay at start so the table does not all rush the forks at once.
- A single philosopher uses a dedicated path: they take the only fork and die after `time_to_die`.
- The simulation ends when someone dies, or when the optional meal count is reached.

## Project layout

```text
.
├── Makefile
├── includes/
│   └── philosopher.h
├── srcs/
│   ├── main.c                  # args, init, launch
│   ├── assign.c                # philosopher + fork assignment
│   ├── routine.c               # eat / sleep / think loop
│   ├── died.c                  # death checks
│   ├── mutexes.c               # mutex init / destroy
│   ├── time.c                  # timestamps and wait helpers
│   ├── utils.c                 # print, join, free
│   └── strings_manipulation.c  # parsing
└── test_philo*.sh              # local test helpers
```

## Tests

Helper scripts in the repo (run from the project root after `make`):

```bash
./test_philo.sh              # invalid args, death, survival, meal-count cases
./test_philo_leak.sh         # memory leak checks
./test_philo_data_race.sh    # data-race checks
```

Typical evaluator cases:

| Command | Expected |
| --- | --- |
| `./philo 1 800 200 200` | Death |
| `./philo 5 800 200 200` | No death |
| `./philo 5 800 200 200 7` | Stops after 7 meals each |
| `./philo 4 410 200 200` | No death |
| `./philo 4 310 200 100` | Death |

## Subject constraints (recap)

- No global variables.
- `pthread_mutex_*` and `pthread_*` for synchronization.
- Do not use `usleep` / `sleep` in a way that makes death detection late; waiting is split so the stop/death flag can be checked.
- Death must be reported as soon as it happens, and the simulation must stop cleanly.

## Author

[lmonsat](https://profile.intra.42.fr/users/lmonsat)

## 42 School

This project was developed as part of the school's curriculum (https://42luxembourg.lu/).