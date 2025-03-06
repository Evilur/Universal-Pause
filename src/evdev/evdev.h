#ifndef EVDEV_H
#define EVDEV_H

/* Define null macro */
#define NULL 0

/* Define boolean */
#define bool _Bool
#define true 1
#define false 0

/* Define sync event type code */
#define EV_SYN 0x00

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
struct key_state {
    unsigned short code;        /* Event code */
    signed int value;           /* Event value */
};

/* Initialize the hotkey combination
 * @param arg_c Number of arguments passed to the function
 * @param arg_v Condition pairs. Format: event_code + event_value
 */
void hotkey_init(const unsigned short arg_c, const char* const arg_v[]);

/* Triggering every time the status of any key on the device is updated
 * @param state The latest updated device key
 */
void update_state(const struct key_state state);

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
unsigned short hotkey_size = 0;

#endif
