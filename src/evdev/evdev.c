#include "evdev.h"
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

/* Initialize the hotkey combination
 * @param arg_c Number of arguments passed to the function
 * @param arg_v Condition pairs. Format: event_code + event_value
 */
void hotkey_init(const int arg_c, const char* const arg_v[]) {
    /* Allocate the memory for the hotkey combination
     * and for current key states */
    hotkey_size = arg_c / 2;
    hotkey_states = malloc(hotkey_size * sizeof(struct key_state));
    current_states = malloc(hotkey_size * sizeof(struct key_state));

    /* Get the keys from the arguments
     * for using them as a hotkey in future
     * (if all pressed) */
    printf("The hotkey contains the following:\n");
    for (int i = 0, hotkey_i = 0; i < arg_c; i += 2) {
        /* Init the key state for the hotkey
         * and put it to the array */
        hotkey_states[hotkey_i] = (struct key_state){
            atoi(arg_v[i]),
            atoi(arg_v[i + 1])
        };
        current_states[hotkey_i].code = hotkey_states[hotkey_i].code;

        /* Print the result */
        printf("Code=%d Value>=%d\n",
            hotkey_states[hotkey_i].code,
            hotkey_states[hotkey_i].value);

        /* Increase the hotkey array iterator */
        hotkey_i++;
    }
}

/* Triggering every time the status of any key on the device is updated
 * @param state The latest updated device key
 */
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
        /* Check if the key is pressed */
        if (current_states[i].value >= hotkey_states[i].value
            && state.code != current_states[i].code) pressed++;

        /* Check if the key we just pressed exists in our hotkey combination */
        if (state.code != current_states[i].code) continue;

        /* Check whether the state of the key is really updated */
        if (current_states[i].value < hotkey_states[i].value) is_updated = true;

        /* Update the value */
        current_states[i].value = state.value;

        /* Now we can check the value of this key and increase it if necessary */
        if (state.value >= hotkey_states[i].value) pressed++;
    }

    /* If all keys are pressed and this has just happened (is_updated variable),
     * then we can run the command */
    if (pressed == hotkey_size && is_updated) system(pause_command);
}

int main(const int arg_c, const char* const arg_v[])
{
    /* Open the device for reading */
    const char* const device_path = arg_v[1];
    int device = open(device_path, O_RDONLY);

    /* Set the universal-pause command */
    pause_command = arg_v[2];

    /* Initialize the hotkey combination */
    hotkey_init(arg_c - 3, arg_v + 3);

    /* Infinite read the events from the device */
    printf("Start listening to device input data...\n");
    for (;;) {
        /* Read the event
         * In case of an error, exit the loop */
        struct input_event event;
        if (read(device, &event, sizeof(event)) == -1) break;

        /* Goto the next iteration if there is a garbage event */
        if (event.code == 0) continue;

        /* Update the current state */
        update_state((struct key_state){ event.code, event.value });
    }

    /* This code is executed only when
     * there is an error in reading the device */
    printf("It looks like the input device has been disabled");
    return 100;
}
