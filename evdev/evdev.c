#include "evdev.h"
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

void hotkey_init(const int arg_c, const char* const arg_v[]) {
    /* Allocate the memory for the hotkey combination 
     * and for current key states */
    hotkey_size = arg_c / 2;
    hotkey_states = malloc(hotkey_size * sizeof(struct event_state));
    current_states = malloc(hotkey_size * sizeof(struct event_state));

    /* Get the keys from the arguments 
     * for using them as a hotkey in future
     * (if all pressed) */
    printf("The hotkey contains the following:\n");
    for (int i = 0, hotkey_i = 0; i < arg_c; i += 2) {
        /* Init the key state for the hotkey 
         * and put it to the array */
         hotkey_states[hotkey_i] = (struct event_state){
            atoi(arg_v[i]), 
            atoi(arg_v[i + 1])
        };

        /* Print the result */
        printf("Code=%d Value>=%d\n", hotkey_states[hotkey_i].code, hotkey_states[hotkey_i].value);

        /* Increase the hotkey array iterator */
        hotkey_i++;
    }
}

int main(const int arg_c, const char* const arg_v[])
{
    /* Open the device for reading */
    const char* const device_path = arg_v[1];
    int device = open(device_path, O_RDONLY);

    /* Initialize the hotkey combination */
    hotkey_init(arg_c - 2, arg_v + 2);

    /* Event struct for storing the event data */
    struct input_event event;

    /* Infinite read the events from the device */
    printf("Start listening to device input data...\n");
    for (;;) {
        /* Read the event 
         * In case of an error, exit the loop */
        if (read(device, &event, sizeof(event)) == -1) break;

        /* Print the debug data */
        printf("Code=%d Value=%d\n", event.code, event.value);
    }

    /* This code is executed only when 
     * there is an error in reading the device */
    printf("It looks like the input device has been disabled");
    return 100;
}