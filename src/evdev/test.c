#include "evdev.h"
#include <stdio.h>
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

        /* Print the current event */
        printf("event_type=%d event_code=%d event_value=%d\n",
                    event.type, event.code, event.value);
    }

    /* This code is executed only when
     * there is an error in reading the device */
    return 100;
}
