# Compiler and its flags
CC=gcc
CFLAGS=-Wextra -Wall -O3

# Target
TARGET=/usr/share/UniversalPause
TARGET_BIN=/usr/bin

install:
	# Create a target root dir and copy files there
	mkdir $(TARGET)
	cp -r src/script $(TARGET)/bin
	cp -r locale $(TARGET)/locale
	cp -r sound $(TARGET)/sound

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
	rm -f $(TARGET)/bin/*
	rm -f $(TARGET)/locale/*/*
	rm -f $(TARGET)/sound/*

	# Remove directories
	rm -df $(TARGET)/bin/
	rm -df $(TARGET)/locale/*/
	rm -df $(TARGET)/locale/
	rm -df $(TARGET)/sound/
	rm -df $(TARGET)/

	# Remove the executable from the target bin dir
	rm -f  $(TARGET_BIN)/universal-pause
