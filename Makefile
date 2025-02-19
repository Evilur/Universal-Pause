# Compiler and its flags
CC=gcc
CFLAGS=-Wall -O3

# Target
TARGET=/usr/share/UniversalPause
TARGET_BIN=/usr/bin

install:
	# Create a target root dir and copy files there
	mkdir $(TARGET)
	cp -r sound $(TARGET)/

	# Set the correct permissions
	chmod 755 $(TARGET)/sound
	chmod 644 $(TARGET)/sound/*

	# Copy the executable to the target bin dir
	cp universal-pause.sh $(TARGET_BIN)/universal-pause
	chmod 755 $(TARGET_BIN)/universal-pause

clean:
	# Remove the target root dir
	rm -f  $(TARGET)/sound/*
	rm -df $(TARGET)/sound/
	rm -f  $(TARGET)/*
	rm -df $(TARGET)

	# Remove the executable from the target bin dir
	rm -f  $(TARGET_BIN)/universal-pause