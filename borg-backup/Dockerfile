FROM alpine:3.12

# Install Borg Backup
RUN apk add --no-cache bash borgbackup openssh-client rclone && \
	mkdir /borg && \
	mkdir /mnt/backup

# Copy Files
COPY backup.sh entrypoint.sh rclone.sh scheduler.txt /borg/
RUN chmod +x /borg/*.sh

# Run Entry Point
ENTRYPOINT "/borg/entrypoint.sh"