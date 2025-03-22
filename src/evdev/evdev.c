#include "evdev.h"
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

int main(const int arg_c, const char* const arg_v[])
{
    /* Open the device for reading */
    const char* const device_path = arg_v[1];
    int device = open(device_path, O_RDONLY);

    /* Set the universal-pause command */
    pause_command = arg_v[2];

    /* Initialize the hotkey combination */
    hotkey_init((unsigned short)(arg_c - 3), arg_v + 3);

    /* Infinite read the events from the device */
    printf("%s\n", getenv("START_LISTEN_DEVICE"));
    for (;;) {
        /* Read the event
         * In case of an error, exit the loop */
        struct input_event event;
        if (read(device, &event, sizeof(event)) == -1) break;

        /* Goto the next iteration if there is an EV_SYN event */
        if (event.type == EV_SYN) continue;

        /* Update the current state */
        update_state((struct key_state){
            event.type,
            event.code,
            event.value
        });
    }

    /* This code is executed only when
     * there is an error in reading the device */
    printf("%s\n", getenv("DEVICE_IS_DISABLED"));
    return 100;
}

void hotkey_init(const unsigned short arg_c, const char* const arg_v[]) {
    /* Allocate the memory for the hotkey combination
     * and for current key states */
    hotkey_size = arg_c / 4;
    current_states = malloc(hotkey_size * sizeof(struct key_state));
    hotkey_states = malloc(hotkey_size * sizeof(struct key_state));
    hotkey_comparison = malloc(hotkey_size * sizeof(comparison_func));

    /* Get the keys from the arguments
     * for using them as a hotkey in future
     * (if all pressed) */
    for (int i = 0, hotkey_i = 0; i < arg_c; i += 4) {
        /* Init the key state for the hotkey
         * and put it to the array */
        hotkey_states[hotkey_i] = (struct key_state){
            (unsigned short)atoi(arg_v[i]),
            (unsigned short)atoi(arg_v[i + 1]),
            atoi(arg_v[i + 3])
        };

        /* Init the current state and set its value to 0 */
        current_states[hotkey_i] = (struct key_state){
            hotkey_states[hotkey_i].type,
            hotkey_states[hotkey_i].code,
            0
        };

        /* Set the comparison function */
        const char* comp_arg = arg_v[i + 2];
        if (comp_arg[1] == 'e' && comp_arg[2] == 'q')
            hotkey_comparison[hotkey_i] = compare_eq;
        else if (comp_arg[1] == 'n' && comp_arg[2] == 'e')
            hotkey_comparison[hotkey_i] = compare_ne;
        else if (comp_arg[1] == 'l' && comp_arg[2] == 't')
            hotkey_comparison[hotkey_i] = compare_lt;
        else if (comp_arg[1] == 'g' && comp_arg[2] == 't')
            hotkey_comparison[hotkey_i] = compare_gt;
        else if (comp_arg[1] == 'l' && comp_arg[2] == 'e')
            hotkey_comparison[hotkey_i] = compare_le;
        else if (comp_arg[1] == 'g' && comp_arg[2] == 'e')
            hotkey_comparison[hotkey_i] = compare_ge;

        /* Increase the hotkey array iterator */
        hotkey_i++;
    }
}

bool compare_eq(signed int val1, signed int val2) { return val1 == val2; }
bool compare_ne(signed int val1, signed int val2) { return val1 != val2; }
bool compare_lt(signed int val1, signed int val2) { return val1 < val2; }
bool compare_gt(signed int val1, signed int val2) { return val1 > val2; }
bool compare_le(signed int val1, signed int val2) { return val1 <= val2; }
bool compare_ge(signed int val1, signed int val2) { return val1 >= val2; }

void update_state(const struct key_state state) {
    /* The number of pressed keys required to activate the hotkey */
    short pressed = 0;

    /* True if our hotkey state is being updated.
     * For example, if we have a 50% trigger press in our hotkey combination,
     * we can push the trigger all the way down. In this case,
     * is_updated variable will be true until we reach the 50%, then false */
    bool is_updated = false;

    /* Cycle through all the keys needed for the combination */
    for (short i = 0; i < hotkey_size; i++) {
        /* Get the comparison function */
        comparison_func compare = hotkey_comparison[i];

        /* Get the current state */
        struct key_state* current_state = current_states + i;

        /* Get the necessary hotkey state */
        struct key_state* hotkey_state = hotkey_states + i;

        /* If we found the last event state in our array */
        if (state.code == current_state->code &&
            state.type == current_state->type) {
            /* Check if the event state didn't just match the condition */
            if (!compare(current_state->value, hotkey_state->value))
                is_updated = true;

            /* Update the value */
            current_state->value = state.value;
        }

        /* Check each state for triggering the condition */
        if (compare(current_state->value, hotkey_state->value)) pressed++;
    }

    /* If all keys are pressed and this has just happened (is_updated variable),
     * then we can run the command */
    if (pressed == hotkey_size && is_updated) system(pause_command);
}
