#ifndef EVDEV_H
#define EVDEV_H

#define NULL 0

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

/* Describes the most important part of the input_event */
struct event_state {
    unsigned short code;        /* Event code */
    signed int value;           /* Event value */
};

/* An array that stores data about the current 
 * event state required by the hotkey */
struct event_state* current_states = NULL;

/* An array that stores the necessary states 
 * for triggering a hotkey */
struct event_state* hotkey_states = NULL;
int hotkey_size = 0;

#endif