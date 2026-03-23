# Winsomnia-noPython

## Usage

Inspired by [Winsomnia-ssh](https://github.com/nullpo-head/winsomnia-ssh/tree/main/winsomnia_ssh) but works without python (just uses bash ans wsl). Usage

- Set Powershell path in `winsomnia-nopython.sh`
- Set (absolute WSL) path to `keep_awake.ps1` in `winsomnia-nopython.sh`
- Add the line `. /path/to/winsomnia-nopython.sh` to your `~/.bashrc` or other shell initialization script. The `. ` prefix is crucial.

## How does it work?

Whenever a new shell is initialized, the script checks if it is inside an ssh session. If that is the case, a Powershell child process is started that sets the `SetThreadExecutionState` to `ES_CONTINUOUS | ES_SYSTEM_REQUIRED`. This state is active until the windows thread exits. Fortunately, the windows process will be killed when the corresponding linux process is killed (see [here](https://github.com/microsoft/WSL/issues/2151)), which is done using the `trap ... EXIT`.