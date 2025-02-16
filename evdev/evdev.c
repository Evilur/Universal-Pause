#include "evdev.h"
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

int main(const int arg_c, const char* const arg_v[])
{
    /* Open the device for reading */
    int device = open(arg_v[1], O_RDONLY);

    /* Event struct for storing the event data */
    struct input_event event;

    /* Infinite read the events from the device */
    for (;;) {
        /* Read the event */
        read(device, &event, sizeof(event));

        /* Print the debug data */
        printf("Code: %d; Value: %d\n", event.code, event.value);
    }

    return 0;
}