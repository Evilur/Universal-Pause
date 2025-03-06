#include "evdev.h"
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

int main(const int arg_c __attribute__((unused)), const char* const arg_v[])
{
    /* Disable buffering */
    setbuf(stdout, NULL);

    /* Open the device for reading */
    const char* const device_path = arg_v[1];
    int device = open(device_path, O_RDONLY);

    /* Infinite read the events from the device */
    for (;;) {
        /* Read the event
         * In case of an error, exit the loop */
        struct input_event event;
        if (read(device, &event, sizeof(event)) == -1) break;

        /* Goto the next iteration if there is an EV_SYN event */
        if (event.type == EV_SYN) continue;

        /* Buffer for env variables */
        char env_buffer[16];

        /* Get the event type name */
        sprintf(env_buffer, "EV_%d", event.type);
        const char* const type_str = getenv(env_buffer);

        /* Get the event code name */
        sprintf(env_buffer, "%s_%d", type_str, event.code);
        const char* const code_str = getenv(env_buffer);

        /* Print the current event
         * If we have NOT an event code name */
        if (code_str == NULL)
            printf("Type %d (EV_%s), Code %d, Value %d\n",
                    event.type, type_str, event.code, event.value);
        /* If we have an event code name
         * \b because env variable ends with space char */
        else
            printf("Type %d (EV_%s), Code %d (%s\b), Value %d\n",
                    event.type, type_str, event.code, code_str, event.value);
    }

    /* This code is executed only when
     * there is an error in reading the device */
    printf("It looks like the input device has been disabled");
    return 100;
}
