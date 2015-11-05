# nanomsg-tests

Here is a [nanomsg](http://nanomsg.org) experiment that I wanted to run, but couldn't find
on the web. It is the multithreaded dealer/router example explained
in the `ZeroMQ` guide:

http://zguide.zeromq.org/page:all#Multithreading-with-ZeroMQ

I tried to reconstruct what I think is the `nanomsg` way of the example
above following the hints from this conversation:

http://www.freelists.org/post/nanomsg/a-stupid-load-balancing-question

Here is what I got in a simple C++ program:

``` c++
//
// nanomsg simple nn_device example for load balancing a tcp server.
//
// compile; run; and then use the nanocat program to test the
// messages being redirected and responded in a round-robin 
// fashion among the three workers
// 
// $ nanocat --req --connect tcp://127.0.0.1:7777 --data ping -A
// [1] pong
// $ nanocat --req --connect tcp://127.0.0.1:7777 --data ping -A
// [2] pong
// $ nanocat --req --connect tcp://127.0.0.1:7777 --data ping -A
// [3] pong
// $ nanocat --req --connect tcp://127.0.0.1:7777 --data ping -A
// [1] pong
// $ nanocat --req --connect tcp://127.0.0.1:7777 --data ping -A
// [2] pong
// $ nanocat --req --connect tcp://127.0.0.1:7777 --data ping -A
// [3] pong
//

#include <iostream>
#include <thread>
#include <cassert>

#include <nanomsg/nn.h>
#include <nanomsg/reqrep.h>

// worker thread to process requests in "parallel"
void worker(int worker_id)
{
    auto socket   = nn_socket(AF_SP, NN_REP); 
    assert(socket>= 0);
    auto endpoint = nn_connect(socket, "inproc://test"); 
    assert(endpoint >= 0);

    char buf [100]; buf[99]='\0';
    char msg[] = "[n] pong";
    msg[1] = (int) '0' + worker_id;

    while (1) {
        auto received_bytes = nn_recv (socket, buf, sizeof(buf) - 1, 0);
        assert(received_bytes >= 0);

        std::cerr << "[" << worker_id << "] received request '" << buf << "'" << std::endl; 

        auto sent_bytes = nn_send(socket, msg, 8, 0);
        assert(sent_bytes == 8);
    }
    nn_shutdown(socket,endpoint);
}

// redirect requests to worker threads
int main() {

    auto frontend_socket   = nn_socket(AF_SP_RAW, NN_REP);  
    assert(frontend_socket >= 0);
    auto frontend_endpoint = nn_bind(frontend_socket, "tcp://127.0.0.1:7777"); 
    assert(frontend_endpoint >= 0);

    auto backend_socket    = nn_socket(AF_SP_RAW, NN_REQ);
    assert(backend_socket >= 0);
    auto backend_endpoint  = nn_bind(backend_socket, "inproc://test");
    assert(backend_endpoint >= 0);

    // start three worker threads
    std::thread t1(worker, 1);
    std::thread t2(worker, 2);
    std::thread t3(worker, 3);

    auto exit_status = nn_device(frontend_socket, backend_socket);

    nn_shutdown(frontend_socket,frontend_endpoint);
    nn_shutdown(backend_socket,backend_endpoint);

    return 0;
}

```
