#ifndef EVDEV_H
#define EVDEV_H

/* Describes the event that we receive from the device */
struct input_event {
    struct {
        unsigned long sec;      /* Seconds */
        unsigned long mc_sec;   /* Microseconds */
    } time;                     /* Event timestamp */
    unsigned short type;        /* Event type */
	unsigned short code;        /* Event code */
	int value;                  /* Event value */
};

#endif