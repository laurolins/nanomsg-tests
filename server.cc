#include <iostream>

#include <cassert>

#include <nanomsg/nn.h>
#include <nanomsg/reqrep.h>

// create a REP socket and bind it the given URL
//
// ./nanocat --req --connect tcp://127.0.0.1:7777 --ascii --data ping
//
void server(const char* url) {

    auto socket = nn_socket(AF_SP, NN_REP);
    assert(socket >= 0);

    auto endpoint_id = nn_bind(socket, url);
    assert(endpoint_id >= 0);

    char buf [100];
    buf[99] = '\0';

    while (1) {
        auto received_bytes = nn_recv (socket, buf, sizeof(buf) - 1, 0);
        assert(received_bytes >= 0);

        std::cout << "[received]: " << buf << std::endl; 

        auto sent_bytes = nn_send(socket, "pong", 4, 0);
        assert(sent_bytes == 4);
    }

    nn_shutdown(socket,endpoint_id);

}

int main() {

    server("tcp://*:7777");

}

