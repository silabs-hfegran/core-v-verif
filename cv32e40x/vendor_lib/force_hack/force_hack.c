#include <stdint.h>

extern "C" {

  
  struct SimException {
    SimException() : mExceptionID(0), mExceptionAttributes(0), mpComments(""), mEPC(0) {}
    SimException(uint32_t exceptionID, uint32_t exceptionAttributes, const char* comments, uint64_t epc) :
      mExceptionID(exceptionID), mExceptionAttributes(exceptionAttributes), mpComments(comments), mEPC(epc) {}
    uint32_t mExceptionID; //!< 0x4E: eret. Others are scause or mcause values.
    uint32_t  mExceptionAttributes;  //!< copied from tval.
    const char* mpComments; //!<  exception comments, indicate exit / enter and m versus s mode.
    uint64_t mEPC; //!< exception program counter
  };

  void update_generator_register(uint32_t cpuid, const char *pRegName, uint64_t rval_in, uint64_t mask, const char *pAccessType) { }
  void update_generator_memory(uint32_t cpuid, uint64_t virtualAddress, uint32_t memBank, uint64_t physicalAddress, uint32_t size, const char *pBytes, const char *pAccessType) { }
  void update_exception_event(const SimException *exception) { }
}
