all:
	g++ -mmacosx-version-min=10.11 -std=c++11 -stdlib=libc++ server_mt.cc /usr/local/lib/libnanomsg.a -o server-mt
	g++ -mmacosx-version-min=10.11 -std=c++11 -stdlib=libc++ server.cc /usr/local/lib/libnanomsg.a -o server

