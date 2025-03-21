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

/* A function that compare values of key_state */
typedef bool (*comparison_func)(signed int, signed int);

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
    unsigned short type;        /* Event type */
    unsigned short code;        /* Event code */
    signed int value;           /* Event value */
};

/* Initialize the hotkey combination
 * @param arg_c Number of arguments passed to the function
 * @param arg_v Condition pairs. Format: arg_v[i]: event type
 *                                       arg_v[i + 1]: event code
 *                                       arg_v[i + 2]: comparison type
 *                                       arg_v[i + 3]: comparison value
 */
void hotkey_init(const unsigned short arg_c, const char* const arg_v[]);

/* Compare two values
 * eq - equal (==)
 * ne - not equal (!=)
 * lt - less than (<)
 * gt - greater than (>)
 * le - less or equal (<=)
 * ge - greater or equal (>=)
 */
bool compare_eq(signed int val1, signed int val2);
bool compare_ne(signed int val1, signed int val2);
bool compare_lt(signed int val1, signed int val2);
bool compare_gt(signed int val1, signed int val2);
bool compare_le(signed int val1, signed int val2);
bool compare_ge(signed int val1, signed int val2);

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

/* An array that stores the comparison function
 * for comparing values of the current event state and the necessary one */
comparison_func* hotkey_comparison = NULL;

/* Contains a size of the arrays: hotkey_states, hotkey_states */
unsigned short hotkey_size = 0;

#endif
