#pragma once

template <typename T, T, typename U, U> struct MemberWrapper;
template<typename T, T&(*pObjGet)(), typename RT, typename... Args, RT(T::*pF)(Args...)>
struct MemberWrapper<RT(T::*)(Args...), pF, T&(*)(), pObjGet>
{
    /*static RT Call(Args&&... args)
    {
        return ((pObjGet()).*pF)(std::forward<Args>(args)...);
    }*/

    static RT Call(Args... args)
    {
        return ((pObjGet()).*pF)(args...);
    }
};

namespace Util
{
    std::wstring Widen(const std::string& input);
    std::string Narrow(const std::wstring& input);
    std::string DataToHex(const char* input, size_t len);
    void SuspendAllOtherThreads();
    void ResumeAllOtherThreads();

    struct ThreadSuspender
    {
        ThreadSuspender();
        ~ThreadSuspender();
    };

    constexpr const char* GetContextName(ExecutionContext context)
    {
        if (context == CONTEXT_CLIENT)
        {
            return "CLIENT";
        }
        else if (context == CONTEXT_SERVER)
        {
            return "SERVER";
        }
        else
        {
            return "UNKNOWN";
        }
    }

    void FindAndReplaceAll(std::string& data, const std::string& search, const std::string& replace);
    void* ResolveLibraryExport(const std::string& module, const std::string& exportName);
    void FixSlashes(char* pname, char separator);
    std::string ConcatStrings(const std::vector<std::string>& strings, const char* delim);
    HMODULE WaitForModuleHandle(const std::string& moduleName);
    std::string ReadFileToString(std::ifstream& f);
	std::vector<std::string> Split( const std::string & s, char delim );
}
