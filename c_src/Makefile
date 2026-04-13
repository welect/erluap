
PROJECT_NIF_NAME=erluap_nif
ERLUAP_STATIC_LINK ?= 0

ERLUAP_UAPCPP_LIB ?= -luaparser_cpp
ERLUAP_RE2_LIB ?= -lre2
ERLUAP_YAMLCPP_LIB ?= -lyaml-cpp
ERLUAP_STDCXX_LIB ?= -lstdc++
ERLUAP_EXTRA_DYNAMIC_LIBS ?=

include nif.mk

ifeq ($(UNAME_SYS), darwin)
    YAML_CPP_ROOT := $(shell brew --prefix yaml-cpp)
    RE2_CPP_ROOT := $(shell brew --prefix re2)

    CXXFLAGS += -I$(YAML_CPP_ROOT)/include -I$(RE2_CPP_ROOT)/include
    LDFLAGS  += -L$(YAML_CPP_ROOT)/lib -L$(RE2_CPP_ROOT)/lib

    LDFLAGS +=  -Wl,-U,_enif_inspect_binary \
                -Wl,-U,_enif_inspect_iolist_as_binary \
                -Wl,-U,_enif_is_binary \
                -Wl,-U,_enif_is_identical \
                -Wl,-U,_enif_make_atom \
                -Wl,-U,_enif_make_existing_atom \
                -Wl,-U,_enif_make_new_binary \
                -Wl,-U,_enif_make_tuple
endif

CXXFLAGS += -I ../_build/deps/uap-cpp -DNDEBUG -g -Wextra -Werror -Wno-missing-field-initializers -std=c++17
LDFLAGS += -L ../_build/deps/uap-cpp/build

ifeq ($(ERLUAP_STATIC_LINK),1)
    ifeq ($(UNAME_SYS),darwin)
        $(error ERLUAP_STATIC_LINK=1 is not supported on darwin)
    endif

    LDFLAGS += -Wl,-Bstatic \
        $(ERLUAP_UAPCPP_LIB) \
        $(ERLUAP_RE2_LIB) \
        $(ERLUAP_YAMLCPP_LIB) \
        $(ERLUAP_STDCXX_LIB) \
        -Wl,-Bdynamic \
        $(ERLUAP_EXTRA_DYNAMIC_LIBS)
else
    LDFLAGS += \
        $(ERLUAP_UAPCPP_LIB) \
        $(ERLUAP_RE2_LIB) \
        $(ERLUAP_YAMLCPP_LIB) \
        $(ERLUAP_STDCXX_LIB) \
        $(ERLUAP_EXTRA_DYNAMIC_LIBS)
endif
