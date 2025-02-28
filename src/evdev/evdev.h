#ifndef EVDEV_H
#define EVDEV_H

/* Define null macro */
#define NULL 0

/* Define boolean */
#define bool _Bool
#define true 1
#define false 0

/* Describes the event that we receive from the device */
struct input_event {
    struct {
        unsigned long sec;      /* Seconds */
        unsigned long mc_sec;   /* Microseconds */
    } time;                     /* Event timestamp */
    unsigned short type;        /* Event type */
	unsigned short code;        /* Event code */
	signed int value;           /* Event value */
};

/* Define event types */
#define EV_SYN 0x00
#define EV_KEY 0x01
#define EV_REL 0x02
#define EV_ABS 0x03

/* Describes the most important part of the input_event */
struct key_state {
    unsigned short code;        /* Event code */
    signed int value;           /* Event value */
};

/* The command that needs to be executed when
 * all the necessary keys are pressed */
const char* pause_command = NULL;

/* An array that stores data about the current
 * event state required by the hotkey */
struct key_state* current_states = NULL;

/* An array that stores the necessary states
 * for triggering a hotkey */
struct key_state* hotkey_states = NULL;

/* Contains a size of the arrays: hotkey_states, hotkey_states */
short hotkey_size = 0;

#endif
