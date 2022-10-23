#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include "../testing.h/logger.h"
#include "./mongoose.h"
#include "./index.h"

#define WIFI_NAME "TV Licencing Van #269"
#define WIFI_PASSWORD "JamesIsSilly123"

#define VIBE_SHORT 100
#define VIBE_LONG 250
#define VIBE_DELAY 100

#define INT_1 33
#define INT_2 38

typedef enum state_t {
    MESSSAGE,
    WAITING,
    NONE
} state_t;

static char sequence[4096];
static char current_msg;
static state_t state = NONE;
static struct timeval msg_start = {0, 0};
static long front_pointer = 0;
static long back_pointer = 0;

static int add_msg_c(char c)
{
    // Check for a valid message
    if (c == '-' || c == '.') {
        // Check for size
        if (back_pointer + 1 % sizeof(sequence) == front_pointer) {
            lprintf(LOG_ERROR, "The queue is full\n");
            return 0;
        }

        // Add the message then leave
        sequence[back_pointer] = c;
        back_pointer++;
        back_pointer %= sizeof(sequence);
        return 1;
    } else {
        lprintf(LOG_ERROR, "Invalid message char\n");
        return 0;
    }
}

static int get_msg_c(char *ret)
{
    // Check the size of the queue
    if (back_pointer == front_pointer) {
        return 0;
    } else {
        *ret = sequence[front_pointer];
        front_pointer++;
        front_pointer %= sizeof(sequence);
        return 1;
    }
}

static int connect_wifi()
{
    return 0;
}

static void motor_on()
{

}

static void motor_off()
{

}

static long diff_ms(struct timeval stop, struct timeval start)
{
    //gettimeofday(&start, NULL);
    //gettimeofday(&stop, NULL);

    if (stop.tv_sec != start.tv_sec) {
        return (1000 - stop.tv_usec) + (start.tv_usec) + (1000 * stop.tv_sec - start.tv_sec);
    } else {
        return stop.tv_sec - start.tv_sec;
    }
}

#define MAX_MSG_LENGTH_BYTES 4096
static void eventHandler(struct mg_connection *c,
                         int event,
                         void *ev_data,
                         void *fn_data)
{
    if (event == MG_EV_HTTP_MSG) {
        struct mg_http_message *hm = (struct mg_http_message *) ev_data;
        if (mg_http_match_uri(hm, "/index")
                || mg_http_match_uri(hm, "/index/")
                || mg_http_match_uri(hm, "/")) {
            mg_http_reply(c, 200, "", "%s", INDEX);
        }
    } else if (event == MG_EV_POLL) {
        // Transmitting a message
        if (state == MESSSAGE) {
            struct timeval stop;
            gettimeofday(&stop, NULL);

            long diff = diff_ms(msg_start, stop);

            if (current_msg == '.' && diff >= VIBE_SHORT) {
                state = NONE;
            } else if (current_msg == '-' && diff >= VIBE_LONG) {
                state = NONE;
            } else {
                motor_on();
            }
            // Waiting to start next message
        } else if (state == WAITING) {
            struct timeval stop;
            gettimeofday(&stop, NULL);

            long diff = diff_ms(msg_start, stop);

            if (diff >= VIBE_DELAY) {
                state = NONE;
            }

            motor_off();
            // No messages
        } else if (state == NONE) {
            char c;
            if (get_msg_c(&c)) {
                state = WAITING;
                current_msg = c;
            } else {
                motor_off();
            }
        }
    }
}

int app_main()
{
    lprintf(LOG_INFO, "Start chess cheatintator\n.");

    struct mg_mgr mgr;
    struct mg_connection *c;

    mg_mgr_init(&mgr);
    c = mg_http_listen(&mgr,
                       "http://0.0.0.0:8080",
                       eventHandler,
                       NULL);

    if (c == NULL) {
        lprintf(LOG_ERROR, "Unable to init mongoose.\n");
        return 1;
    }

    while (1) {
        mg_mgr_poll(&mgr, 1);
    }

    mg_mgr_free(&mgr);
    return 0;
}
