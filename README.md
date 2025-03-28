## sshh = SSH hub

sshh is a Docker image based on Debian, designed to serve as a hub for containers via SSH.

- Access the container via SSH (be mindful of security risks).
- Restrict access to specific users and IP addresses by configuring **ALLOW_USERS** (`/etc/ssh/sshd_config`).
- Set user and group permissions with User ID and Group ID.
- Execute commands at container startup using `StartupCommand`.
- Automate command execution with `CronJob`.



## Example

This is a simple example of a `docker-compose.yml`.

When using it in a real environment, regenerate and replace the connection keys, and manage them carefully.

```yaml
# Create host/ssh key: ssh-keygen -t ed25519 -f ~/mykey.sk -C mykey
# chmod 600 mykey.sk
# ssh -i mykey -p 2222 ubuntu@127.0.0.1

services:
  sshh:
    image: archidoc422/sshh
    ports:
      - "2222:2222" # Port for SSH connections (Docker side).
    user: "1000:1000" # Specify the PID/GID for access if needed.
    environment:
      TZ: Asia/Tokyo
      SSH_PORT: 2222 # Port for SSH connections (container side).
      SSH_USER: ubuntu # Username for the connection (including root).
      SSH_PUBLIC_KEY: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMRtReLqtm7DEX11mB5rd9FBlypFQvRfJrz3QseiPU1 root" # Public key for the connection (can be retrieved from the environment variable ${SSH_PUBLIC_KEY}).
      HOST_PRIVATE_KEY: |-
        -----BEGIN OPENSSH PRIVATE KEY-----
        b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
        QyNTUxOQAAACBIbQfPhEC0bN2WhqXF46xYHYB5Td4pWpbCWCfievqTIwAAAJCTKnm5kyp5
        uQAAAAtzc2gtZWQyNTUxOQAAACBIbQfPhEC0bN2WhqXF46xYHYB5Td4pWpbCWCfievqTIw
        AAAEDjk41YaFLaLCCPtSTeF/jMzmzNloGZ1pDvEjV0VYpmxkhtB8+EQLRs3ZaGpcXjrFgd
        gHlN3ilalsJYJ+J6+pMjAAAACmtheUBkZXNrLTUBAgM=
        -----END OPENSSH PRIVATE KEY-----
      # Private key for the connection (if not specified, a key will be automatically generated for each container).
      ALLOW_USERS: "ubuntu" #"*@10.* *@172.* *@192.168.*" "root" "root@127.0.0.1" # Restrict access to specific users and IP addresses (/etc/ssh/sshd_config).
      StartupCommand1: "touch /home/ubuntu/Hello2" # Commands to execute when the container starts.
      CronJob1: "* * * * * touch /home/ubuntu/cronfile1" # Commands for automatic execution.
```

