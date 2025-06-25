# SSH Once For All

This project provides a script that allows you to easily create an SSH key for connecting to different servers and save it in your SSH configuration file. The script also enables you to quickly connect to the server using the command `ssh host`.

## Prerequisites

- Make sure `ssh` is installed on your system.
- You need access to the server to run SSH commands.

## How to Use

To use the script, simply run the following command:

```bash
curl -sSL https://github.com/alirezkarami/ssh-once-for-all/raw/main/ssh-once-forever.sh | bash -s "<email>" "<username>" "<server_ip/domain>" "<ssh_port>" "<host_name>"
```
```
ssh host_name
```
