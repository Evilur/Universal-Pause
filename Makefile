# Compiler and its flags
CC=gcc
CFLAGS=-Wextra -Wall -O3

# Target
TARGET=/usr/share/UniversalPause
TARGET_BIN=/usr/bin

install:
	# Create a target root dir and copy files there
	mkdir $(TARGET)
	cp --recursive src/script $(TARGET)/bin
	cp --recursive locale $(TARGET)/locale
	cp --recursive sound $(TARGET)/sound

	# Copy the executable to the target bin dir
	cp universal-pause.sh $(TARGET_BIN)/universal-pause
	chmod 755 $(TARGET_BIN)/universal-pause

	# Set the correct permissions for directories
	chmod 755 $(TARGET)/bin
	chmod 755 $(TARGET)/locale
	chmod 755 $(TARGET)/locale/*
	chmod 755 $(TARGET)/sound

	# Set the correct permissions for files
	chmod 755 $(TARGET)/bin/*
	chmod 644 $(TARGET)/locale/*/*
	chmod 644 $(TARGET)/sound/*

clean:
	# Remove files from the directories
	rm --force $(TARGET)/bin/*
	rm --force $(TARGET)/locale/*/*
	rm --force $(TARGET)/sound/*

	# Remove directories
	rm --force --dir $(TARGET)/bin/
	rm --force --dir $(TARGET)/locale/*/
	rm --force --dir $(TARGET)/locale/
	rm --force --dir $(TARGET)/sound/
	rm --force --dir $(TARGET)/

	# Remove the executable from the target bin dir
	rm --force $(TARGET_BIN)/universal-pause
