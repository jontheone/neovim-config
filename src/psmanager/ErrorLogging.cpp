#include "ErrorLogging.h"
#include "yamlread.h"
#include <ctime>
#include <iomanip>

void yamlErrorMessage(ErrorLogging &err, int code)
{
    switch (code)
    {
        case YAML_SUCCESS:
            err.message << "Yaml extracted successfully from file\n";
            break;
        case YAML_FAILURE:
            err.message << "Fail to extract yaml from file\n";
            break;
        case YAML_EMPTY:
            err.message << "The file does not contain any yaml headers\n";
            break;
        case YAML_INVALID_FILE:
            err.message << "The path provided is invalid\n";
            break;
        default:
            err.message << "You literally did not predict this\n";
            break;
    }
}

void yamlErrorMessage(ErrorLogging &err, int code, char* filepath)
{
    switch (code)
    {
        case YAML_SUCCESS:
            err.message << "Yaml extracted successfully from file: " << filepath << "\n";
            break;
        case YAML_FAILURE:
            err.message << "Fail to extract yaml from file: " << filepath << "\n";
            break;
        case YAML_EMPTY:
            err.message << "The file does not contain any yaml headers: " << filepath << "\n";
            break;
        case YAML_INVALID_FILE:
            err.message << "The path provided is invalid: " << filepath << "\n";
            break;
        default:
            err.message << "You literally did not predict this: " << filepath << "\n";
            break;
    }
}

void LogErr(ErrorLogging &err, const char* action) 
{

    std::time_t t = std::time(nullptr);
    std::tm buf{};
    localtime_r(&t, &buf); 
    std::stringstream message;
    message << std::left;
    message << "================================================================== ";
    message << "[" << buf.tm_mday << "-" << (buf.tm_mon + 1) << "-" << (buf.tm_year + 1900) << " " << buf.tm_hour << ":" << buf.tm_min << ":" << buf.tm_sec << "]" <<"\n";
    message << std::setw(35) <<"Error while processing task: " << action << "\n";
    message << std::setw(35) <<"Error:" << err.message.str() << "\n";
    message << "==================================================================\n";
    fputs(message.str().c_str(), err.errlogs);
    err.message.clear();
    err.returnstatus = S_WARNINGS;
}

void LogErr(ErrorLogging &err, const char* action, int status) 
{

    std::time_t t = std::time(nullptr);
    std::tm buf{};
    localtime_r(&t, &buf);
    std::stringstream message;
    message << std::left;
    message << "================================================================== ";
    message << "[" << (buf.tm_year + 1900) << "-" << (buf.tm_mon + 1) << "-" << buf.tm_mday << " " << buf.tm_hour << ":" << buf.tm_min << ":" << buf.tm_sec << "]" <<"\n";
    message << std::setw(30) <<"Error while processing task: " << action << "\n";
    message << std::setw(30) <<"Error:" << err.message.str() << "\n";
    message << "==================================================================\n";
    fputs(message.str().c_str(), err.errlogs);
    err.message.clear();
    err.returnstatus = status;
}
