#ifndef YAMLREAD_H
#define YAMLREAD_H
#include <stdlib.h>
#include <cstring>
#include <iostream>

constexpr int SIZE_OF_STATIC_BUF {6};
constexpr int SIZE_OF_STATIC_HEADER {40};
constexpr int SIZE_OF_STATIC_DATA {100};

enum typeHeader {
    T_LIST,
    T_LINE,
    T_NULL
};

enum yamlstatus {
    YAML_SUCCESS,
    YAML_FAILURE,
    YAML_EMPTY,
    YAML_INVALID_FILE
};

struct header_s {
    int type {T_NULL};
    char *header;
    char *data;
    char static_header[SIZE_OF_STATIC_HEADER] = {0};
    char static_data[SIZE_OF_STATIC_DATA] = {0};

    header_s() : header{static_header}, data{static_data} {}

    header_s(const header_s& other) : type{other.type} {
        if (other.header == other.static_header) {
            memcpy(static_header, other.static_header, SIZE_OF_STATIC_HEADER);
            header = static_header;
        } else {
            header = strdup(other.header);
        }

        if (other.data == other.static_data) {
            memcpy(static_data, other.static_data, SIZE_OF_STATIC_DATA);
            data = static_data;
        } else {
            data = strdup(other.data);
        }
    }


    void alloc_if_needed_header(int buffer_len) {
        if (buffer_len > SIZE_OF_STATIC_HEADER)  {
            if (header == static_header) {
                header = (char*)calloc(buffer_len+1, sizeof(char));
            } else {
                header = (char*)realloc(header, strlen(header) + buffer_len + 1);
            }
        }
    }
    void alloc_if_needed_data(int buffer_len) {
        if (strlen(data) + buffer_len + 3 > SIZE_OF_STATIC_HEADER)  {
            if (data == static_data) {
            ////std::cout << "dynamically allocating memory" << std::endl;
                data = (char*)calloc(SIZE_OF_STATIC_DATA + buffer_len + 3, sizeof(char));
            } else {
                data = (char*)realloc(data, strlen(data) + buffer_len + 3);
            }
        }
    }

    ~header_s() {
        ////std::cout << &data << "\t" << &static_data << std::endl;
        if (data != static_data) {
            ////std::cout << "freeing memory for: " << data << std::endl;
            free(data);
        }
        if (header != static_header) {
            ////std::cout << "freeing memory for: " << header << std::endl;
            free(header);
        }
    }
};

struct yaml_s {
    header_s static_buf[SIZE_OF_STATIC_BUF];
    header_s* headers;
    int nheaders {};
    int capacity {SIZE_OF_STATIC_BUF};
    int yamlstatus {YAML_SUCCESS};

    yaml_s() : headers{static_buf} {}

    void alloc_if_needed() {
        if (nheaders > capacity-1) {
            //std::cout << "reached" << std::endl;
            capacity *= 2;
            if (static_buf == headers) {
                header_s* new_buffer = (header_s*)calloc(capacity, sizeof(header_s));
                for (int i = 0; i < nheaders; ++i) {
                    new (&new_buffer[i]) header_s(headers[i]);
                }
                headers = new_buffer;
            } else {
                headers = (header_s*)realloc(headers, capacity * sizeof(header_s));
            }
        }
    }

    ~yaml_s() {
        if (headers != static_buf) {
            ////std::cout << "Freeing yaml headers" << std::endl;
            for (int i = 0; i<nheaders; i++) {
                ////std::cout << i << std::endl;
                headers[i].~header_s();
            }
            free(headers);
        }
    }
};

yaml_s collectyaml(char* filepath);

#endif
