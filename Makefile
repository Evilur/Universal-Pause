# Compiler and its flags
CC 	   ?= gcc
CFLAGS ?= -Wall -Wextra -Wpedantic -Wshadow -Wformat=2 -Wuninitialized \
-Wconversion -Wlogical-op -Wnull-dereference -Wduplicated-cond \
-Wredundant-decls -Wstrict-prototypes -Wmissing-declarations \
-Wunreachable-code -Wmissing-prototypes -O3
CFLAGS += -std=c99

# Prefix
PREFIX	    ?= /usr/local
BINPREFIX   ?= $(PREFIX)/bin
SHAREPREFIX ?= $(PREFIX)/share

# Directory with share files
SHAREDIR := $(SHAREPREFIX)/UniversalPause

# Set targets that do not create new files
.PHONY: all clean install uninstall

# Build all C binaries
all: bin/evdev bin/evdev-test

# Clean all compiled C binaries
clean:
	rm --force bin/*
	rm --force --dir bin

# Install the program to the system
install: all
	# Create a share dir and copy files there
	mkdir $(SHAREDIR)
	mkdir $(SHAREDIR)/bin
	cp bin/* $(SHAREDIR)/bin
	cp src/script/* $(SHAREDIR)/bin
	cp src/event-codes/* $(SHAREDIR)/bin
	cp --recursive locale $(SHAREDIR)/locale
	cp --recursive sound $(SHAREDIR)/sound

	# Copy the master script to the bin dir
	cp universal-pause.sh $(BINPREFIX)/universal-pause

	# Replace the environment variable in master script
	sed -i 's|readonly SHAREDIR=.*|readonly SHAREDIR=$(SHAREDIR)|' \
	$(BINPREFIX)/universal-pause

	# Set the correct permissions for master script
	chmod 755 $(BINPREFIX)/universal-pause

	# Set the correct permissions for directories
	chmod 755 $(SHAREDIR)/bin
	chmod 755 $(SHAREDIR)/locale
	chmod 755 $(SHAREDIR)/locale/*
	chmod 755 $(SHAREDIR)/sound

	# Set the correct permissions for files
	chmod 755 $(SHAREDIR)/bin/*
	chmod 644 $(SHAREDIR)/locale/*/*
	chmod 644 $(SHAREDIR)/sound/*

# Uninstall the program from the system
uninstall:
	# Remove files from the directories
	rm --force $(SHAREDIR)/bin/*
	rm --force $(SHAREDIR)/locale/*/*
	rm --force $(SHAREDIR)/sound/*

	# Remove directories
	rm --force --dir $(SHAREDIR)/bin/
	rm --force --dir $(SHAREDIR)/locale/*/
	rm --force --dir $(SHAREDIR)/locale/
	rm --force --dir $(SHAREDIR)/sound/
	rm --force --dir $(SHAREDIR)/

	# Remove the executable from the bin dir
	rm --force $(BINPREFIX)/universal-pause

bin/evdev: src/evdev/evdev.h src/evdev/evdev.c
	mkdir --parent bin
	$(CC) $(CFLAGS) src/evdev/evdev.c -o bin/evdev

bin/evdev-test: src/evdev/evdev.h src/evdev/test.c
	mkdir --parent bin
	$(CC) $(CFLAGS) src/evdev/test.c -o bin/evdev-test
