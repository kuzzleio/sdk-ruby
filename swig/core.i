%module(directors="1") kuzzlesdk
%{
#include "exceptions.hpp"
#include "kuzzle.hpp"
#include "collection.hpp"
#include "index.hpp"
#include "server.hpp"
#include "document.hpp"
#include "realtime.hpp"
#include "auth.hpp"
#include <assert.h>
%}


%ignore *::error;
%ignore *::status;
%ignore *::stack;

%feature("director") NotificationListener;
%feature("director") EventListener;
%feature("director") SubscribeListener;

%{
#include "kuzzle.cpp"
#include "collection.cpp"
#include "auth.cpp"
#include "index.cpp"
#include "server.cpp"
#include "document.cpp"
#include "realtime.cpp"

#define SWIG_FILE_WITH_INIT
%}

%include "stl.i"

%define _Complex
%enddef

%include "exceptions.hpp"
%include "kuzzle.hpp"
%include "collection.hpp"
%include "index.hpp"
%include "server.hpp"
%include "document.hpp"
%include "realtime.hpp"
%include "auth.hpp"

%extend options {
    options() {
        options *o = kuzzle_new_options();
        return o;
    }

    ~options() {
        free($self);
    }
}

%extend kuzzleio::kuzzle_response {
    ~kuzzle_response() {
        kuzzle_free_kuzzle_response($self);
    }
}

%include "kuzzle.cpp"
%include "collection.cpp"
%include "document.cpp"
%include "realtime.cpp"
%include "auth.cpp"
%include "index.cpp"
%include "server.cpp"
