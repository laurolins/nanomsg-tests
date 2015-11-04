all:
	g++ -mmacosx-version-min=10.11 -std=c++11 -stdlib=libc++ server_mt.cc /usr/local/lib/libnanomsg.a -o server-mt
	g++ -mmacosx-version-min=10.11 -std=c++11 -stdlib=libc++ server.cc /usr/local/lib/libnanomsg.a -o server


old:
	gcc -mmacosx-version-min=10.11 reqrep.c /usr/local/lib/libnanomsg.a -o reqrep



test:
	./reqrep node0 ipc:///tmp/reqrep.ipc & node0=$! && sleep 1
	./reqrep node1 ipc:///tmp/reqrep.ipc msg1 msg2