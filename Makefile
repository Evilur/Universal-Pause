# Compiler and its flags
CC=gcc
CFLAGS=-Wall -Wextra -Wpedantic -Wshadow -Wformat=2 -Wuninitialized \
-Wconversion -Wlogical-op -Wnull-dereference -Wduplicated-cond \
-Wredundant-decls -Wstrict-prototypes -Wmissing-declarations \
-Wunreachable-code -Wmissing-prototypes -O3

# Target
TARGET=/usr/share/UniversalPause
TARGET_BIN=/usr/bin

# Set targets that do not create new files
.PHONY: build clean install uninstall

# Build all C binaries
build: bin/evdev bin/evdev-test

# Clean all compiled C binaries
clean:
	rm --force bin/*
	rm --force --dir bin

# Install the program to the system
install: build
	# Create a target root dir and copy files there
	mkdir $(TARGET)
	mkdir $(TARGET)/bin
	cp bin/* $(TARGET)/bin
	cp src/script/* $(TARGET)/bin
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

# Uninstall the program from the system
uninstall:
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

bin/evdev: src/evdev/evdev.h src/evdev/evdev.c
	mkdir --parent bin
	$(CC) $(CFLAGS) src/evdev/evdev.c -o bin/evdev

bin/evdev-test: src/evdev/evdev.h src/evdev/test.c
	mkdir --parent bin
	$(CC) $(CFLAGS) src/evdev/test.c -o bin/evdev-test
